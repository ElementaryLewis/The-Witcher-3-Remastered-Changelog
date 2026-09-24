/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SignOwner
{
	protected var	actor	: CActor;
	
	protected function BaseInit( parentActor : CActor )
	{
		actor = parentActor;
	}

	public function GetActor() : CActor
	{
		return actor;
	}

	public function GetPlayer() : W3PlayerWitcher
	{
		return NULL;
	}

	public function IsPlayer() : bool
	{
		return false;
	}
	
	public function InitCastSign( signEntity : W3SignEntity ) : bool
	{
		return true;
	}
	
	public function ChangeAspect( signEntity : W3SignEntity, newSkill : ESkill ) : bool
	{
		return false;
	}
	
	public function SetCurrentlyCastSign( type : ESignType, entity : W3SignEntity )
	{
	}
	
	public function GetSkillAbilityName( skill : ESkill ) : name
	{
		return '';
	}
	
	public function GetSkillLevel(skill : ESkill) : int
	{
		return 1;
	}
	
	public function GetSkillAttributeValue( skill : ESkill, attributeName : name, addBaseCharAttribute : bool, addSkillModsAttribute : bool ) : SAbilityAttributeValue
	{
		var dummy : SAbilityAttributeValue;
		return dummy;
	}	
	
	public function GetPowerStatValue( stat : ECharacterPowerStats, optional abilityTag : name ) : SAbilityAttributeValue
	{
		var dummy : SAbilityAttributeValue;
		return dummy;	
	}
	
	public function CanUseSkill( skill : ESkill ) : bool
	{
		return false;
	}

	public function IsSkillEquipped( skill : ESkill ) : bool
	{
		return false;
	}
	
	public function HasStaminaToUseSkill( skill : ESkill, optional perSec : bool, optional signHack : bool ) : bool
	{
		return false;
	}	
	
	public function LockCameraToTarget( flag : bool )
	{
	}	
	
	public function LockActorToTarget( flag : bool )
	{
	}
		
	public function RemoveTemporarySkills()
	{
	}
	
	public function GetHandAimPitch() : float
	{
		return 0.0f;
	}
	
	public function HasCustomAttackRange() : bool
	{
		return false;
	}

	public function GetCustomAttackRange() : name
	{
		return '';
	}
	
	event OnDelayOrientationChange()
	{
		return true;
	}
	
	event OnProcessCastingOrientation( isContinueCasting : bool )
	{
		return true;
	}	
}




class W3SignOwnerBTTaskCastSign extends W3SignOwner
{
	var btTask : CBTTaskCastSign;
	
	public function Init( parentActor : CActor, task : CBTTaskCastSign )
	{
		super.BaseInit( parentActor );
		btTask = task;
	}
	
	public function HasStaminaToUseSkill( skill : ESkill, optional perSec : bool, optional signHack : bool ) : bool
	{
		return true;
	}	
	
	public function HasCustomAttackRange() : bool
	{
		return IsNameValid( btTask.GetAttackRangeType() );
	}

	public function GetCustomAttackRange() : name
	{
		return btTask.GetAttackRangeType();
	}	
}




class W3SignOwnerPlayer extends W3SignOwner
{
	var	player	: W3PlayerWitcher;
	
	public function Init( parentActor : CActor )
	{
		super.BaseInit( parentActor );
		player = (W3PlayerWitcher)parentActor;
		LogAssert( player, "W3SignOwnerPlayer initialized with actor that is not a W3PlayerWitcher" );
	}
	
	public function GetPlayer() : W3PlayerWitcher
	{
		return player;
	}
	
	public function IsPlayer() : bool
	{
		return true;
	}
	
	public function InitCastSign( signEntity : W3SignEntity ) : bool
	{
		if ( player.HasStaminaToUseSkill( signEntity.GetSkill() ) && player.OnRaiseSignEvent() )
		{
			player.OnProcessCastingOrientation( false );
		
			player.SetBehaviorVariable( 'alternateSignCast', 0 );
			player.SetBehaviorVariable( 'IsCastingSign', 1 );
						
			
			player.BreakPheromoneEffect();
			
			return true;			
		}	
		return false;
	}
		
	public function ChangeAspect( signEntity : W3SignEntity, newSkill : ESkill ) : bool
	{
		var newTarget : CActor;
		var ret : bool;
		
		
		
		var shouldAltCast : bool;
		var altInputHeld : bool;
		if(!theInput.LastUsedPCInput() && thePlayer.GetInputHandler().GetIsAltSignCasting())
		{
			if( ((W3AardEntity)signEntity) && (theInput.IsActionPressed('Sprint') || theInput.IsActionPressed('CbtRoll')) )
			{
				shouldAltCast = true;
			} 
			else if( ((W3IgniEntity)signEntity) && (theInput.IsActionPressed('LockAndGuard') || theInput.IsActionPressed('Focus')) )
			{
				shouldAltCast = true;
			}
			else if( ((W3YrdenEntity)signEntity) && theInput.IsActionPressed('AttackHeavy') )
			{
				shouldAltCast = true;
			}
			else if( ((W3QuenEntity)signEntity) && (theInput.IsActionPressed('AltQuenCasting') || theInput.IsActionPressed('Dodge')) )
			{
				shouldAltCast = true;
			}
			else if( ((W3AxiiEntity)signEntity) && theInput.IsActionPressed('AttackLight') )
			{
				shouldAltCast = true;
			}
		}
		else if(theInput.LastUsedPCInput() && thePlayer.GetInputHandler().GetIsAltSignCasting())
		{
			if( ((W3AardEntity)signEntity) && (theInput.IsActionPressed('SelectAard') || theInput.IsActionPressed( 'CastSign' )) )
			{
				shouldAltCast = true;
				altInputHeld = true;
			} 
			else if( ((W3IgniEntity)signEntity) && (theInput.IsActionPressed('SelectIgni') || theInput.IsActionPressed( 'CastSign' )) )
			{
				shouldAltCast = true;
				altInputHeld = true;
			}
			else if( ((W3YrdenEntity)signEntity) && (theInput.IsActionPressed('SelectYrden') || theInput.IsActionPressed( 'CastSign' )) )
			{
				shouldAltCast = true;
				altInputHeld = true;
			}
			else if( ((W3QuenEntity)signEntity) && (theInput.IsActionPressed('SelectQuen') || theInput.IsActionPressed( 'CastSign' )) )
			{
				shouldAltCast = true;
				altInputHeld = true;
			}
			else if( ((W3AxiiEntity)signEntity) && (theInput.IsActionPressed('SelectAxii') || theInput.IsActionPressed( 'CastSign' )) )
			{
				shouldAltCast = true;
				altInputHeld = true;
			}
		}
		else
		{
			shouldAltCast = true;
		}
		

		if ( !player.CanUseSkill( newSkill ) )
		{
			ret = false;
		}	
		else if ( (theInput.IsActionPressed( 'CastSign' ) || theInput.GetActionValue( 'CastSignHold' ) > 0.f || altInputHeld) && shouldAltCast ) 
		{
			if ( !player.IsCombatMusicEnabled() && !player.CanAttackWhenNotInCombat( EBAT_CastSign, true, newTarget ) )
			{
				ret = false;
			}
			else if( player.HasBuff( EET_GryphonSetBonus ) && player.GetStatPercents( BCS_Stamina ) < 1.f )
			{
				ret = false;
			}
			else
			{
				signEntity.SetAlternateCast( newSkill );
				player.SetBehaviorVariable( 'alternateSignCast', 1 );
				ret = true;
			}
		}
		else 
		{
			ret = false;
		}
		
		if(!ret)
			signEntity.OnNormalCast();
		
		return ret;
	}
	
	public function GetSkillLevel(skill : ESkill) : int
	{
		return player.GetSkillLevel(skill);
	}

	public function SetCurrentlyCastSign( type : ESignType, entity : W3SignEntity )
	{
		player.SetCurrentlyCastSign( type, entity );
	}

	public function GetSkillAbilityName( skill : ESkill ) : name
	{
		return player.GetSkillAbilityName( skill );
	}
	
	public function GetSkillAttributeValue( skill : ESkill, attributeName : name, addBaseCharAttribute : bool, addSkillModsAttribute : bool ) : SAbilityAttributeValue
	{
		return player.GetSkillAttributeValue( skill, attributeName, addBaseCharAttribute, addSkillModsAttribute );
	}
	
	public function GetPowerStatValue( stat : ECharacterPowerStats, optional abilityTag : name ) : SAbilityAttributeValue
	{
		return player.GetPowerStatValue( stat, abilityTag );
	}
	
	public function CanUseSkill( skill : ESkill ) : bool
	{
		return player.CanUseSkill( skill );
	}	
	
	public function IsSkillEquipped( skill : ESkill ) : bool
	{
		return player.IsSkillEquipped( skill );
	}
	
	public function HasStaminaToUseSkill( skill : ESkill, optional perSec : bool, optional signHack : bool ) : bool
	{
		return player.HasStaminaToUseSkill( skill, perSec, signHack );
	}	

	public function RemoveTemporarySkills()
	{
		player.ResetRawPlayerHeading();
	}
	
	public function GetHandAimPitch() : float
	{
		return player.handAimPitch;
	}

	event OnDelayOrientationChange()
	{
		return player.OnDelayOrientationChange();
	}
	
	event OnProcessCastingOrientation( isContinueCasting : bool )
	{
		return player.OnProcessCastingOrientation( isContinueCasting );
	}	
}