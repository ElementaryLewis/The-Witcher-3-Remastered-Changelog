/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3CriticalDOTEffect extends W3DamageOverTimeEffect
{
	protected var criticalStateType 		: ECriticalStateType;				
	protected saved var allowedHits 		: array<bool>;						
	private var timeEndedHandled 			: bool;
	private var isDestroyedOnInterrupt 		: bool;								
	private var canPlayAnimation 			: bool;								
	protected var blockedActions 			: array<EInputActionBlock>;			
	protected var postponeHandling 			: ECriticalHandling;				
	protected var airHandling 				: ECriticalHandling;				
	protected var attachedHandling 			: ECriticalHandling;				
	protected var onHorseHandling 			: ECriticalHandling;				
	public var explorationStateHandling 	: ECriticalHandling;				
	private var usesFullBodyAnim			: bool;
	
		default criticalStateType 			= ECST_None;									
		default isNegative 					= true;
		default timeEndedHandled 			= false;
		default isDestroyedOnInterrupt 		= false;
		default canPlayAnimation 			= true;
		default postponeHandling 			= ECH_Postpone;
		default airHandling 				= ECH_Postpone;
		default attachedHandling 			= ECH_HandleNow;
		default onHorseHandling 			= ECH_HandleNow;
		default	explorationStateHandling 	= ECH_Postpone;
		default usesFullBodyAnim			= false;
			
	public function CacheSettings()
	{
		var i :int;
		
		super.CacheSettings();
		
		allowedHits.Grow( EnumGetMax('EHitReactionType')+1 );
		for(i=0; i<allowedHits.Size(); i+=1)
			allowedHits[i] = true;
			
		
		blockedActions.PushBack(EIAB_ExplorationFocus);
		blockedActions.PushBack(EIAB_Dive);
		blockedActions.PushBack(EIAB_Interactions);
		blockedActions.PushBack(EIAB_FastTravel);
	}
	
	event OnUpdate(dt : float)
	{
		
		if(IsImmuneToAllDamage(dt))
		{
			timeLeft = 0;
			return true;
		}
		
		super.OnUpdate(dt);
	}
	
	public function OnTimeUpdated(deltaTime : float)
	{
		if(pauseCounters.Size() == 0)
		{							
			if( duration != -1 )
				timeLeft -= deltaTime;				
			OnUpdate(deltaTime);	
			
			
			if(!this)
				return;
		}
		
		
		
		
		if(timeLeft <= 0 && !timeEndedHandled)
		{
			timeEndedHandled = true;
			target.SignalGameplayEvent('DisableFinisher');
			
			if(isOnPlayer)
				LogCriticalPlayer("CriticalDOT.OnTimeUpdated() | " + this + " - timeout");
			
			
			if(isActive && this == target.GetCurrentlyAnimatedCS())
			{				
				target.RequestCriticalAnimStop();
			}
			else
			{
				LogCritical("Deactivating not animated CS <<" + criticalStateType + ">>");
				
				if(isOnPlayer)
					LogCriticalPlayer("CriticalDOT.OnTimeUpdated() | " + this + " - deactivating as it's not animated currently");
				
				isActive = false;			
			}
		}
		else if(timeLeft <= 0 && !target.IsAlive())
		{
			
			if(isOnPlayer)
				LogCriticalPlayer("CriticalDOT.OnTimeUpdated() | " + this + " - isAlive set to false as target is dead");
				
			isActive = false;
		}
	}
	
	public function GetCriticalStateType() : ECriticalStateType			{return criticalStateType;}	
	public function IsHitAllowed(hit : EHitReactionType) : bool			{return allowedHits[hit];}
	public function IsDestroyedOnInterrupt() : bool						{return isDestroyedOnInterrupt;}
	public function CanPlayAnimation() : bool							{return canPlayAnimation;}
	public function DisallowPlayAnimation()								{canPlayAnimation = false;}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var i : int;
		var animHandling : ECriticalHandling;
		var veh : CGameplayEntity;
		var horseComp : W3HorseComponent;
		var boatComp : CBoatComponent;
		var params : W3BuffDoTParams;
		var perk20Bonus : SAbilityAttributeValue;
		
		var skillPassiveMod : float; 
				
		
		if(IsImmuneToAllDamage(100000))		
		{
			isActive = false;
			return true;
		}
		
		params = (W3BuffDoTParams)customParams;
		
		
		if( params )
		{
			if( params.isFromBomb )
			{
				skillPassiveMod = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('potion_duration'));
				effectValue.valueAdditive *= ( 1 + skillPassiveMod );
			}
			
			if( params.isPerk20Active )
			{
				
				
				
			}
		}
		
		
		
			
		
		super.OnEffectAdded(customParams);
		
		
		if(isOnPlayer)
		{
			for(i=0; i<blockedActions.Size(); i+=1)
			{
				thePlayer.BlockAction( blockedActions[i], EffectTypeToName( effectType ) );
			}
		}
		
		
		if(!isOnPlayer)
			target.PauseStaminaRegen('in_critical_state');
			
		
		if(target.IsCriticalTypeHigherThanAllCurrent(criticalStateType))		
		{			
			if(target.IsInAir())
			{
				animHandling = airHandling;
			}			
			else
			{
				
				if(isOnPlayer)
				{
					if( !thePlayer.CanReactToCriticalState() )
					{
						animHandling = explorationStateHandling;
					}
					
					else
					{
						veh = thePlayer.GetUsedVehicle();
						
						if((W3Boat)veh)
						{
							
							
							animHandling = attachedHandling;
						}
						
						else if(veh)
						{
							horseComp = ((CNewNPC)veh).GetHorseComponent();
							horseComp.OnCriticalEffectAdded( criticalStateType );
							animHandling = onHorseHandling;
						}	
						
						else
						{
							animHandling = ECH_HandleNow;
						}
					}
				}
				
				else
				{
					
					animHandling = ECH_HandleNow;
				}
			}
		}
		
		else
		{
			animHandling = postponeHandling;
		}
		
		
		if(animHandling == ECH_HandleNow)
		{
			target.StartCSAnim(this);
		}
		else if(animHandling == ECH_Abort)
		{
			LogCritical("Cancelling CS <<" + criticalStateType + ">> as it cannot play anim right now and its handling wishes to abort in such case");
			isActive = false;
		}
		
		
		if(isOnPlayer)
			theGame.VibrateControllerVeryHard();	
	}
	
	event OnEffectRemoved()
	{
		var i : int;
	
		super.OnEffectRemoved();
	
		
		if(isOnPlayer)
		{
			for(i=0; i<blockedActions.Size(); i+=1)
			{
				thePlayer.UnblockAction( blockedActions[i], EffectTypeToName( effectType ) );
			}
		}
		
		
		target.ResumeStaminaRegen('in_critical_state');
		
		if(isOnPlayer)
		{
			LogCriticalPlayer("CriticalDOT.OnEffectRemoved() | " + this);
			LogCriticalPlayer("");
		}
			
		if(this == target.GetCurrentlyAnimatedCS())
			target.RequestCriticalAnimStop();
	}
	
	public final function UsesFullBodyAnim() : bool
	{
		return usesFullBodyAnim;
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		
		if(duration < 0.1f)
		{
			duration = 0.f;
			LogEffects("W3CriticalDOTEffect.CalculateDuration(): final duration is below 0.1, setting to 0");
		}
	}
}