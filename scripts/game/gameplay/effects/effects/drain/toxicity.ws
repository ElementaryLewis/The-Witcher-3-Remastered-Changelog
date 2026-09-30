/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Toxicity extends CBaseGameplayEffect
{
	
	default effectType = EET_Toxicity;
	default attributeName = 'toxicityRegen';
	default isPositive = false;
	default isNeutral = true;
	default isNegative = false;	
		
	
	private saved var dmgTypeName 			: name;							
	private saved var toxThresholdEffect	: int;
	private var delayToNextVFXUpdate		: float;
		
	
	public function CacheSettings()
	{
		dmgTypeName = theGame.params.DAMAGE_NAME_DIRECT;
		
		super.CacheSettings();
	}
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		var witcher : W3PlayerWitcher;
	
		if( !((W3PlayerWitcher)target) )
		{
			LogAssert(false, "W3Effect_Toxicity.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			return false;
		}
		
		witcher = GetWitcherPlayer();
	
		
		if( witcher.GetStatPercents(BCS_Toxicity) >= witcher.GetToxicityDamageThreshold())
			switchCameraEffect = true;
		else
			switchCameraEffect = false;
			
		
		super.OnEffectAdded(customParams);	
	}

	
	
	event OnUpdate(deltaTime : float)
	{
		var dmg, maxStat, toxicity, threshold, drainVal : float;
		var dmgValue, min, max : SAbilityAttributeValue;
		var currentStateName 	: name;
		var currentThreshold	: int;

		super.OnUpdate(deltaTime);
		
		
		toxicity = GetWitcherPlayer().GetStat(BCS_Toxicity, false) / GetWitcherPlayer().GetStatMax(BCS_Toxicity);
		threshold = GetWitcherPlayer().GetToxicityDamageThreshold();

		
		if( toxicity >= threshold && !isPlayingCameraEffect)	
			switchCameraEffect = true;
		else if(toxicity < threshold && isPlayingCameraEffect)	
			switchCameraEffect = true;

		
		if( delayToNextVFXUpdate <= 0 )
		{				
			
			
			
			if(toxicity <= 0.0f)		currentThreshold = 0;
			else if(toxicity < 0.25f)	currentThreshold = 1;
			else if(toxicity < 0.5f)	currentThreshold = 2;
			else if(toxicity < 0.75f)	currentThreshold = 3;
			else if(toxicity >= 0.75f)	currentThreshold = 4;

			
			if(  toxThresholdEffect != currentThreshold &&  !target.IsEffectActive('invisible' ) )
			{
				
				
				
				if (toxThresholdEffect < 0) 
					toxThresholdEffect = 0;
				
				switch ( toxThresholdEffect )
				{
					case 0: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_000_025'); 
							toxThresholdEffect += 1; 							
						} 
						break;
					case 1: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_025_050'); 
							toxThresholdEffect += 1; 
						} 
						else 
						{ 
							PlayHeadEffect('toxic_025_000'); 
							toxThresholdEffect -= 1; 
						} 
						break;
					case 2: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_050_075'); 
							toxThresholdEffect += 1; 
						} 
						else 
						{ 
							PlayHeadEffect('toxic_050_025'); 
							toxThresholdEffect -= 1; 
						} 
						break;
					case 3: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_075_100'); 
							toxThresholdEffect += 1; 
						}
						else 
						{ 
							PlayHeadEffect('toxic_075_050'); 
							toxThresholdEffect -= 1; 
						} 
						break;
					case 4: 
						PlayHeadEffect('toxic_100_075'); 
						toxThresholdEffect -= 1; 
						break;
				}
				
				
				
				delayToNextVFXUpdate = 2;
			}		
			
		}
		else
		{
			delayToNextVFXUpdate -= deltaTime;
		}
				
		
		if(toxicity >= threshold)
		{
			currentStateName = thePlayer.GetCurrentStateName();
			if(currentStateName != 'Meditation' && currentStateName != 'MeditationWaiting')
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, dmgTypeName, min, max);	
			
				if(DamageHitsVitality(dmgTypeName))
					maxStat = target.GetStatMax(BCS_Vitality);
				else
					maxStat = target.GetStatMax(BCS_Essence);
				
				dmgValue = GetAttributeRandomizedValue(min, max);
				dmg = MaxF(0, deltaTime * ( dmgValue.valueAdditive + (dmgValue.valueMultiplicative * (maxStat + dmgValue.valueBase) ) ));
				
				
				
				
				
				
			
				if(dmg > 0)
					effectManager.CacheDamage(dmgTypeName,dmg,NULL,this,deltaTime,true,CPS_Undefined,false);
				else
					LogAssert(false, "W3Effect_Toxicity: should deal damage but deals 0 damage!");
			}
			
			
			if(thePlayer.CanUseSkill(S_Alchemy_s20) && !target.HasBuff(EET_IgnorePain))
				target.AddEffectDefault(EET_IgnorePain, target, 'IgnorePain');
		}
		else
		{
			
			target.RemoveBuff(EET_IgnorePain);
		}
			
		
		drainVal = deltaTime * (effectValue.valueAdditive + (effectValue.valueMultiplicative * (effectValue.valueBase + target.GetStatMax(BCS_Toxicity)) ) );
		
		
		if(!target.IsInCombat())
			drainVal *= 1.1; 
			
		effectManager.CacheStatUpdate(BCS_Toxicity, drainVal);
	}
	
	function PlayHeadEffect( effect : name, optional stop : bool )
	{
		var inv : CInventoryComponent;
		var headIds : array<SItemUniqueId>;
		var headId : SItemUniqueId;
		var head : CItemEntity;
		var i : int;
		
		inv = target.GetInventory();
		headIds = inv.GetItemsByCategory('head');
		
		for ( i = 0; i < headIds.Size(); i+=1 )
		{
			if ( !inv.IsItemMounted( headIds[i] ) )
			{
				continue;
			}
			
			headId = headIds[i];
					
			if(!inv.IsIdValid( headId ))
			{
				LogAssert(false, "W3Effect_Toxicity : Can't find head item");
				return;
			}
			
			head = inv.GetItemEntityUnsafe( headId );
			
			if( !head )
			{
				LogAssert(false, "W3Effect_Toxicity : head item is null");
				return;
			}

			if ( stop )
			{
				if ( head.IsEffectActive( effect ) ) 	
					head.StopEffect( effect );
			}
			else
			{
				if ( head.IsEffectActive( effect ) ) 	
					head.StopEffect( effect );			
				head.PlayEffectSingle( effect );
			}
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		toxThresholdEffect = -1;
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		
		if(thePlayer.CanUseSkill(S_Alchemy_s20) && target.HasBuff(EET_IgnorePain))
			target.RemoveBuff(EET_IgnorePain);
			
		
		
		
		
		PlayHeadEffect( 'toxic_000_025', true );
		PlayHeadEffect( 'toxic_025_050', true );
		PlayHeadEffect( 'toxic_050_075', true );
		PlayHeadEffect( 'toxic_075_100', true );
		
		PlayHeadEffect( 'toxic_050_025', true );
		PlayHeadEffect( 'toxic_075_050', true );
		PlayHeadEffect( 'toxic_100_075', true );
		
		
		PlayHeadEffect( 'toxic_025_000', true ); 
		
		toxThresholdEffect = 0;
	}
	
	protected function SetEffectValue()
	{
		RecalcEffectValue();
	}
	
	public function RecalcEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
	
		if(!IsNameValid(abilityName))
			return;
	
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue(abilityName, attributeName, min, max);
		effectValue = GetAttributeRandomizedValue(min, max);
		
		
		if(thePlayer.CanUseSkill(S_Alchemy_s15))
			effectValue += thePlayer.GetSkillAttributeValue(S_Alchemy_s15, attributeName, false, true) * thePlayer.GetSkillLevel(S_Alchemy_s15);
			
		if(thePlayer.HasAbility('Runeword 8 Regen'))
			effectValue += thePlayer.GetAbilityAttributeValue('Runeword 8 Regen', 'toxicityRegen');
	}
}