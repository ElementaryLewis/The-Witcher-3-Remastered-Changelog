/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBaseGameplayEffect extends CObject
{
	
	protected var timeActive : float;							
	protected saved var initialDuration : float;				
	protected var duration : float;								
	protected var timeLeft : float;								
	protected var pauseCounters : array<SBuffPauseLock>;		
	protected var isActive : bool;								
	private   var resistStat : ECharacterDefenseStats;			
	protected var resistance : float;	 						
	protected var creatorPowerStat : SAbilityAttributeValue;	
	protected var isPausedDuringDialogAndCutscene : bool;		
	protected var dontAddAbilityOnTarget : bool;				
	protected var canBeAppliedOnDeadTarget : bool;				
	protected var effectManager : W3EffectManager;				
		
		default isActive = false;
		default duration = 0;
		default resistance = 0;
		default isPausedDuringDialogAndCutscene = true;
		default dontAddAbilityOnTarget = false;
		default canBeAppliedOnDeadTarget = false;

	
	protected var isPositive : bool;							
	protected var isNeutral : bool;							
	protected var isNegative : bool;							
	
		default isPositive = false;
		default isNeutral = false;
		default isNegative = false;
	
	protected var isOnPlayer : bool;								
	protected var isSignEffect : bool;						
	protected var isPotionEffect : bool;						
	protected var abilityName : name;							
	protected  var attributeName : name;						
	protected const var effectType : EEffectType;				
	protected var target : CActor;									
	protected var creatorHandle : EntityHandle;					
	protected var effectValue : SAbilityAttributeValue;		
	protected var potionItemName : name;						

		default isPotionEffect = false;
		default isSignEffect = false;
		default abilityName = '';
		

	
	protected var deny : array<EEffectType>;					
	protected var override : array<EEffectType>;				
	protected var sourceName : string;						
	
	
	
	
	protected var cameraEffectName : name;				
	protected var isPlayingCameraEffect : bool;			
	protected var switchCameraEffect : bool;			
	protected var isCameraEffectNameValid : bool;		
	
		default isPlayingCameraEffect 	= false;
		default switchCameraEffect 		= true;
		
	
	protected var iconPath : string;								
	protected var showOnHUD : bool;									
	protected var effectNameLocalisationKey : string;				
	protected var effectDescriptionLocalisationKey : string;		
	
		default showOnHUD = true;														
		default effectNameLocalisationKey = "MISSING_LOCALISATION_KEY_NAME";			
		default effectDescriptionLocalisationKey = "MISSING_LOCALISATION_KEY_DESC";		
	
	
	
	protected var targetEffectName : name;						
	protected var shouldPlayTargetEffect : bool;				
	
		default shouldPlayTargetEffect = true;
	
	
	private var onAddedSound, onRemovedSound : name;			
	
	
	protected var vibratePadLowFreq, vibratePadHighFreq : float;	
	
		default vibratePadLowFreq = 0;
		default vibratePadHighFreq = 0;
		
	
	
	public function Init(params : SEffectInitInfo)
	{
		var min, max, null : SAbilityAttributeValue;
		var durationSet : bool;
		var points : float;
		var dm : CDefinitionsManagerAccessor;
	
		EntityHandleSet(creatorHandle, params.owner);
		effectManager = params.targetEffectManager;
		target = params.target;	
		sourceName = params.sourceName;
		durationSet = false;
		isSignEffect = params.isSignEffect;
		
		if(params.vibratePadLowFreq > 0)
			vibratePadLowFreq = params.vibratePadLowFreq;
		if(params.vibratePadHighFreq > 0)
			vibratePadHighFreq = params.vibratePadHighFreq;
		
		
		if(IsNameValid(params.customAbilityName))
		{
			abilityName = params.customAbilityName;		
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributeValue(abilityName, 'duration', min, max);
			duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			durationSet = true;
		}
			
		if(params.duration != 0 && (!durationSet || (durationSet && duration == 0)) )	
			duration = params.duration;
			
		isOnPlayer = (CPlayer)target;
		target.GetResistValue(resistStat, points, resistance);
		
		if(params.powerStatValue == null)
			params.powerStatValue.valueMultiplicative = 1;					
		creatorPowerStat = params.powerStatValue;
			
		CalculateDuration(true);			
		timeLeft = duration;
		
		if(!IsNameValid(params.customAbilityName) && (params.customEffectValue != null))
			effectValue = params.customEffectValue;		
		else
			SetEffectValue();	
		
		if(IsNameValid(params.customFXName))
			targetEffectName = params.customFXName;
	}
		
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		target = t;
		effectManager = eff;
		isOnPlayer = (CR4Player)t;
		if(isOnPlayer && !IsPaused())
		{
			isPlayingCameraEffect 	= false;
			switchCameraEffect 		= true;
		}
	}
	
	
	protected function SetEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
	
		if(!IsNameValid(abilityName))
			return;
	
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue(abilityName, attributeName, min, max);
		effectValue = GetAttributeRandomizedValue(min, max);
	}
		
	
	public function CacheSettings()
	{
		var i,size : int;
		var tmpString : string;
		var dm : CDefinitionsManagerAccessor;
		var main,temp : SCustomNode;
		var tmpBool : bool;
		var tmpName, customAbilityName : name;
		var tmpFloat : float;		
		var type : EEffectType;		
							
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			EffectNameToType(tmpName, type, customAbilityName);
			if(effectType == type)
			{
				if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'iconType_name', tmpName))
					iconPath = theGame.effectMgr.GetPathForEffectIconTypeName(tmpName);
				if( dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'showOnHUD', tmpBool))
					showOnHUD = tmpBool;
				
				
				
								
				
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'defaultAbilityName_name', tmpName))
					abilityName = tmpName;
									
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cameraEffectName_name', tmpName))
					cameraEffectName = tmpName;				
				if( !IsNameValid(targetEffectName) && dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'targetEffectName_name', tmpName))
					targetEffectName = tmpName;
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'resistStatName_name', tmpName))		
					resistStat = ResistStatNameToEnum(tmpName, tmpBool);
				if( dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'isPotionEffect', tmpBool))		
					isPotionEffect = tmpBool;
					
				
				if(isPotionEffect && !isPositive && !isNeutral && !isNegative)
				{
					isPositive = true;
					isNeutral = false;
					isNegative = false;
				}
					
				
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'onStartSound_name', tmpName))		
					onAddedSound = tmpName;
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'onStopSound_name', tmpName))		
					onRemovedSound = tmpName;	
					
				
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'effectNameLocalisationKey_name', tmpName))		
					effectNameLocalisationKey = tmpName;
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'effectDescriptionLocalisationKey_name', tmpName))		
					effectDescriptionLocalisationKey = tmpName;
					
				
				temp = dm.GetCustomDefinitionSubNode(main.subNodes[i],'denies');
				if(temp.values.Size() > 0)
				{
					size = temp.values.Size();
					for(i=0; i<size; i+=1)
					{
						if(IsNameValid(temp.values[i]))
						{
							EffectNameToType(temp.values[i], type, tmpName);
							deny.PushBack(type);
						}
					}
				}
				temp = dm.GetCustomDefinitionSubNode(main.subNodes[i],'overrides');
				if(temp.values.Size() > 0)
				{
					size = temp.values.Size();
					for(i=0; i<size; i+=1)
					{
						if(IsNameValid(temp.values[i]))
						{
							EffectNameToType(temp.values[i], type, tmpName);
							override.PushBack(type);
						}
					}
				}
	
				if(iconPath=="" && showOnHUD)
					LogEffects("BaseEffect.Initialize: Effect " + this + " should show in GUI but has no icon defined!");
					
				return;
			}			
		}

		
		LogEffects("BaseEffect.Initialize: Cannot find GUI definitions in xml file for effect " + this);
	}
	
	
	public function RecalcDuration()
	{
		var prevDuration, points : float;
		
		if(duration == -1)
			return;
		
		
		target.GetResistValue(resistStat, points, resistance);
		
		
		prevDuration = duration;
		CalculateDuration();
		
		
		timeLeft = timeLeft * duration / prevDuration;
	}
	
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var durationResistance : float;
		var min, max : SAbilityAttributeValue;
		
		if(duration == 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'duration', min, max);
			duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		}
		
		if(setInitialDuration)
			initialDuration = duration;
	
		if( duration == -1)
			return;
			
		
		if(isNegative)
		{
			
			if(IsCriticalEffect(this))
				durationResistance = MinF(0.99f, resistance);
			else
				durationResistance = resistance;
				
			duration = MaxF(0, initialDuration * MaxF(0, creatorPowerStat.valueMultiplicative) * (1 - durationResistance) );
			LogEffects("BaseEffect.CalculateDuration: " + effectType + " duration with target resistance (" + NoTrailZeros(resistance) + ") and attacker power mul of (" + NoTrailZeros(creatorPowerStat.valueMultiplicative) + ") is " + NoTrailZeros(duration) + ", base was " + NoTrailZeros(initialDuration));
		}		
	}
	
	public function GetAbilityName() : name
	{
		return abilityName;
	}
	
	
	event OnEffectAddedPost()
	{
		var localizationKey : string;
		
		if(target == thePlayer.GetTarget())
		{
			localizationKey = GetEffectNameLocalisationKey();
			
			if(localizationKey != "")
				target.ShowFloatingValue(EFVT_Buff, 0.f, false, localizationKey);
		}
	}
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var i : int;
		var potParams : W3PotionParams;
			
		LogAssert(target, "OnEffectAdded: target is NULL!");
		isActive = true;		
		timeActive = 0.0f;
		
		
		if(IsNameValid(abilityName) && !dontAddAbilityOnTarget)
			target.AddAbility(abilityName, true);	
				
		
		PlayTargetFX();
				
		
		isCameraEffectNameValid = IsNameValid(cameraEffectName);		
		if(isOnPlayer && switchCameraEffect && isCameraEffectNameValid)
		{
			thePlayer.PlayEffectSingle(cameraEffectName);
			isPlayingCameraEffect = true;
			switchCameraEffect = false;
		}
		else
		{
			isPlayingCameraEffect = false;
		}
		
		
		if(isOnPlayer && IsNameValid(onAddedSound))
			theSound.SoundEvent(onAddedSound);
				
		
		if(isOnPlayer && (vibratePadLowFreq > 0 || vibratePadHighFreq > 0) )
		{
			theGame.VibrateController(vibratePadLowFreq, vibratePadHighFreq, duration);
		}
		
		if(isPotionEffect)
		{
			potParams = (W3PotionParams)customParams;
			if(potParams)
				potionItemName = potParams.potionItemName;
		}
	
		LogEffects("BaseEffect.OnEffectAdded: effect " + this + " added to " + target + ", duration="+NoTrailZeros(duration));
	}
	
	
	protected function PlayTargetFX()
	{
		if(IsNameValid(targetEffectName) && shouldPlayTargetEffect)
		{				
			
			if(!effectManager.IsPlayingFX(targetEffectName))
			{
				target.DestroyEffectIfActive(targetEffectName);
				target.PlayEffect(targetEffectName);
			}
				
			
			effectManager.AddPlayedFX(targetEffectName, sourceName);
		}
	}
	
		
	protected function StopTargetFX()
	{
		if(IsNameValid(targetEffectName) && !shouldPlayTargetEffect)
		{			
			
			if(effectManager.ShouldStopFx(targetEffectName))
				target.StopEffect(targetEffectName);
				
			
			effectManager.RemovePlayedFX(targetEffectName, sourceName);
		}
	}
	
	
	event OnEffectRemoved()
	{
		var i : int;
	
		isActive = false;
		
		
		if(IsNameValid(abilityName))
			target.RemoveAbility(abilityName);
		
		
		if(isOnPlayer && isPlayingCameraEffect && isCameraEffectNameValid)
			thePlayer.StopEffect(cameraEffectName);
		
		
		shouldPlayTargetEffect = false;
		StopTargetFX();
						
		
		if(isOnPlayer && IsNameValid(onRemovedSound))
			theSound.SoundEvent(onRemovedSound);
			
		if(isOnPlayer && theGame.IsSpecificRumbleActive(vibratePadLowFreq, vibratePadHighFreq))
			theGame.RemoveSpecificRumble(vibratePadLowFreq, vibratePadHighFreq);
		
		LogEffects("BaseEffect.OnEffectRemoved: effect <<" + this + ">> removed from <<" + target + ">>");
	}
	
	
	event OnUpdate(dt : float)
	{
		SwitchCameraEffect();
		PlayTargetFX();		
	}
	
	
	private function SwitchCameraEffect()
	{
		
		if(isCameraEffectNameValid && isOnPlayer && switchCameraEffect)
		{
			if(isPlayingCameraEffect)
				thePlayer.StopEffect(cameraEffectName);
			else
				thePlayer.PlayEffectSingle(cameraEffectName);
			
			isPlayingCameraEffect = !isPlayingCameraEffect;
			switchCameraEffect = false;
		}
	}
	
	public function OnTargetDeath()
	{
		target.RemoveEffect(this, true);
	}
	
	public function OnTargetUnconscious()
	{
		target.RemoveEffect(this, true);
	}
	
	public function OnTargetDeathAnimFinished(){}
	
	
	
	
	
	
	public final function GetInteraction( effect : CBaseGameplayEffect) : EEffectInteract
	{
		var i,size : int;
		var tmp : EEffectInteract;
		
		
		size = deny.Size();
		for(i=0; i<size; i+=1)
		{
			if(deny[i] == effect.effectType)
				return EI_Deny;
		}
		
		
		size = override.Size();
		for(i=0; i<size; i+=1)
		{
			if(override[i] == effect.effectType)
				return EI_Override;
		}
		
		
		if(effectType == effect.effectType)
		{
			tmp = GetSelfInteraction(effect);
			if(tmp != EI_Undefined)
				return tmp;
		}
				
		
		return EI_Pass;
	}
	
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var thisVal, otherVal : float;
		
		
		if( isPotionEffect && e.isPotionEffect && e.sourceName == "alchemy_s4" )
		{
			return EI_Override;
		}
		
		
		if(sourceName != e.sourceName)
		{
			return EI_Undefined;
		}

		thisVal = GetEffectStrength();
		otherVal = e.GetEffectStrength();
		
		if(thisVal > otherVal)
		{
			return EI_Override;
		}
		else if(thisVal < otherVal)
		{
			return EI_Pass;				
		}
		else
		{
			
			if(timeLeft <= 0 && IsCriticalEffect(this))
				return EI_Pass;
		
			if(timeLeft > e.timeLeft)
				return EI_Override;
			
			return EI_Cumulate;
		}
	}
	
	
	protected function GetEffectStrength() : float
	{
		
		return CalculateAttributeValue(effectValue);
	}
	
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		timeLeft = effect.timeLeft;
		duration = effect.duration;
		isPotionEffect = effect.isPotionEffect;
		creatorHandle = effect.creatorHandle;
		sourceName = effect.sourceName;
		
		if(abilityName != effect.abilityName && !dontAddAbilityOnTarget)
		{
			target.RemoveAbility(abilityName);
			target.AddAbility(effect.abilityName);
		}
		
		abilityName = effect.abilityName;	
		
		if(isOnPlayer)
		{
			vibratePadLowFreq = effect.vibratePadLowFreq;
			vibratePadHighFreq = effect.vibratePadHighFreq;
			
			if(vibratePadLowFreq > 0 || vibratePadHighFreq > 0)
				theGame.OverrideRumbleDuration(vibratePadLowFreq, vibratePadHighFreq, timeLeft);
		}
		
		
		if(isOnPlayer && IsNameValid(onAddedSound))
			theSound.SoundEvent(onAddedSound);
	}
	
	
	
	
		
	
	public function OnTimeUpdated(dt : float)
	{	
		var toxicityThreshold : float;
		var isDecoction : bool;

		isDecoction = effectType >= EET_Mutagen01 && effectType <= EET_Mutagen28;
		
		if( isActive && pauseCounters.Size() == 0)
		{
			timeActive += dt;	
			if( duration != -1 )
			{
				timeLeft -= dt;				
				if( timeLeft <= 0 )
				{
					if(isPotionEffect && isOnPlayer && thePlayer.CanUseSkill(S_Alchemy_s03) && effectType != EET_WhiteRaffardDecoction && !isDecoction )				
					{
						isActive = false;

											
					}
					else
					{
						isActive = false;		
					}
				}
			}
			OnUpdate(dt);	
		}
	}
	
	
	public function Pause( sourceName : name, optional singleLock : bool )
	{
		var i : int;
		var counter : SBuffPauseLock;
		
		for(i=0; i<pauseCounters.Size(); i+=1)
		{
			if(pauseCounters[i].sourceName == sourceName)
			{
				if(singleLock)
					pauseCounters[i].counter = 1;
				else
					pauseCounters[i].counter += 1;
					
				return;
			}
		}
		
		counter.sourceName = sourceName;
		counter.counter = 1;
		pauseCounters.PushBack(counter);
		
		shouldPlayTargetEffect = false;
		StopTargetFX();
		
		if(isPlayingCameraEffect)
		{
			switchCameraEffect = true;
			SwitchCameraEffect();	
		}
		
		OnPaused();
	}
	
	protected function OnPaused(){}
	protected function OnResumed(){}
	
	public final function Resume( sourceName : name )
	{
		ResumeInternal(sourceName);
	}
	
	
	public final function ResumeForced()
	{
		ResumeInternal('', true);
	}
	
	private final function ResumeInternal(optional sourceName : name, optional forced : bool)
	{
		var i : int;
		
		for(i=pauseCounters.Size()-1; i>=0; i-=1)
		{
			if(forced || pauseCounters[i].sourceName == sourceName)
			{
				if(pauseCounters[i].counter == 1)
				{
					pauseCounters.EraseFast(i);
					
					shouldPlayTargetEffect = true;
					PlayTargetFX();
					switchCameraEffect = true;
					OnResumed();
				}
				else
				{
					pauseCounters[i].counter -= 1;
				}
				
				if(!forced)
					return;
			}
		}
	}
	
	public function IsPaused( optional sourceName : name ) : bool
	{
		var i : int;
	
		if(sourceName == 'None' )
		{
			return pauseCounters.Size() > 0;
		}
			
		for(i=0; i<pauseCounters.Size(); i+=1)
			if(pauseCounters[i].sourceName == sourceName)
				return true;

		return false;
	}
		
	
	public function GetDurationLeft() : float							{return timeLeft;}	
	
	
	public function GetInitialDurationAfterResists() : float			{return duration;}	
	
	
	public function GetInitialDuration() : float 						{return initialDuration;}
	
	
	public function GetCreator() : CGameplayEntity
	{
		return (CGameplayEntity)EntityHandleGet(creatorHandle);
	}
	
	public function IsPositive() : bool									{return isPositive;}
	public function IsNegative() : bool									{return isNegative;}
	public function IsNeutral() : bool									{return isNeutral;}
	public function ShowOnHUD() : bool									{return showOnHUD;}
	public function SetShowOnHUD( b : bool )							{ showOnHUD = b; }
	public function GetShowOnHUD() : bool								{return showOnHUD;}
	public function GetIcon() : string									{return iconPath;}
	public function IsActive() : bool									{return isActive;}	
	public function GetEffectNameLocalisationKey() : string				
	{
		var str: string;
		
		switch( effectType )
		{
			case EET_Mutagen01 :
			case EET_Mutagen02 :
			case EET_Mutagen03 :
			case EET_Mutagen04 :
			case EET_Mutagen05 :
			case EET_Mutagen06 :
			case EET_Mutagen07 :
			case EET_Mutagen08 :
			case EET_Mutagen09 :
				str = StrReplace( effectNameLocalisationKey, "effect_Mutagen0", "item_name_mutagen_" );
				str = StrReplace( str, "Effect", "" );
				return str;
			case EET_Mutagen10 :
			case EET_Mutagen11 :
			case EET_Mutagen12 :
			case EET_Mutagen13 :
			case EET_Mutagen14 :
			case EET_Mutagen15 :
			case EET_Mutagen16 :
			case EET_Mutagen17 :
			case EET_Mutagen18 :
			case EET_Mutagen19 :
			case EET_Mutagen20 :
			case EET_Mutagen21 :
			case EET_Mutagen22 :
			case EET_Mutagen23 :
			case EET_Mutagen24 :
			case EET_Mutagen25 :
			case EET_Mutagen26 :
			case EET_Mutagen27 :
			case EET_Mutagen28 :
				str = StrReplace( effectNameLocalisationKey, "effect_Mutagen", "item_name_mutagen_" );
				str = StrReplace( str, "Effect", "" );
				return str;
				
			default:
				break;
		}
		
		return effectNameLocalisationKey;
	}	
	
	public function GetEffectDescriptionLocalisationKey() : string		{return effectDescriptionLocalisationKey;}	
	public function GetEffectType() : EEffectType						{return effectType;}	
	public function IsPotionEffect() : bool								{return isPotionEffect;}
	public function IsSignEffect() : bool								{return isSignEffect;}
	public function SetTimeLeft(t : float)								{timeLeft = t;}
	public function GetTimeLeft() : float								{return timeLeft;}
	public function IsPausedDuringDialogAndCutscene() : bool			{return isPausedDuringDialogAndCutscene;}
	public function GetSourceName() : string							{return sourceName;}
	public function IsOnPlayer() : bool									{return isOnPlayer;}
	public function GetTimeActive() : float								{return timeActive;}
	public function CanBeAppliedOnDeadTarget() : bool					{return canBeAppliedOnDeadTarget;}
	public function GetResistStat() : ECharacterDefenseStats			{return resistStat;}
	public function GetBuffResist() : float								{return resistance;}
	
	public function GetBuffLevel() : int
	{
		var level : string;
			
		level = StrAfterLast(abilityName, "_");
		
		if(level == "Level3" || level == "3")
			return 3;
		else if(level == "Level2" || level == "2")
			return 2;
		else
			return 1;
	}
	
	public final function Debug_HAX_FIX(t : CActor)
	{
		target=t;
		EntityHandleSet(creatorHandle, t);
	}
	
	public final function RecalcPotionDuration()
	{
		var leftRatio, newDuration : float;
		
		if(!isPotionEffect)
			return;
		
		leftRatio = timeLeft / duration;
		newDuration = GetWitcherPlayer().CalculatePotionDuration(GetInvalidUniqueId(), (W3Mutagen_Effect)this, potionItemName);
		
		duration = newDuration;
		timeLeft = newDuration * leftRatio;
	}

	public function DelayedRecoveryPotionDurationIncrease()
	{
		if (isPotionEffect)
		{
			if (timeLeft + 5 <= duration)
			{
				timeLeft += 5;
			}
			else
			{
				timeLeft = duration;
			}
		}
	}
	
	public function GetTargetEffectName() : name
	{
		return targetEffectName;
	}
	
	public function GetCreatorPowerStat() : SAbilityAttributeValue
	{
		return creatorPowerStat;
	}
	
	public function GetVibratePadLowFreq() : float
	{
		return vibratePadLowFreq;
	}
	
	public function GetVibratePadHighFreq() : float
	{
		return vibratePadHighFreq;
	}
	public function GetEffectValue() : SAbilityAttributeValue
	{
		return effectValue;
	}
	
	public function IsAddedByPlayer() : bool
	{
		var gpEnt : CGameplayEntity;
		var sign : W3SignEntity;
		var petard : W3Petard;
		
		gpEnt = GetCreator();
		
		if( gpEnt == thePlayer )
		{
			return true;
		}
		
		petard = (W3Petard)gpEnt;
		if( petard && petard.GetOwner() == thePlayer )
		{
			return true;
		}
		
		sign = (W3SignEntity)gpEnt;
		if( sign && sign.GetOwner() == thePlayer )
		{
			return true;
		}
		
		return false;
	}
}