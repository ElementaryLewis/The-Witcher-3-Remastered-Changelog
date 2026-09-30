/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Swarm extends W3CriticalDOTEffect
{
	default effectType = EET_Swarm;
	default criticalStateType = ECST_Swarm;
	
	public function CacheSettings()
	{
		super.CacheSettings();
	
		blockedActions.PushBack(EIAB_ThrowBomb);
		blockedActions.PushBack(EIAB_Crossbow);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Counter);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var dot : SDoTDamage;
		
		
		if((effectValue.valueAdditive + effectValue.valueMultiplicative) > 0)
		{
			dot.damageTypeName = theGame.params.DAMAGE_NAME_PHYSICAL;
			dot.hitsVitality = DamageHitsVitality(dot.damageTypeName);
			dot.hitsEssence = DamageHitsEssence(dot.damageTypeName);
			
			damages.PushBack(dot);
		}
	
		super.OnEffectAdded(customParams);
		
		if( isOnPlayer )
		{
			thePlayer.SoundEvent( "animals_crow_swarm_attack_hit_loop" );
			thePlayer.SoundEvent( "grunt_vo_geralt_impact_light_loop" );
			
			if ( thePlayer.playerAiming.GetCurrentStateName() == 'Waiting' )
				thePlayer.AddCustomOrientationTarget(OT_CustomHeading, 'SwarmEffect');
		}	
	}
	
	event OnUpdate(deltaTime : float)
	{
		var player : CR4Player = thePlayer;	
	
		super.OnUpdate(deltaTime);
		
		if ( isOnPlayer ) 
		{
			if( player.bLAxisReleased )
				player.SetOrientationTargetCustomHeading( player.GetHeading(), 'SwarmEffect' );
			else if( player.GetPlayerCombatStance() == PCS_AlertNear )
				player.SetOrientationTargetCustomHeading( VecHeading( player.moveTarget.GetWorldPosition() - player.GetWorldPosition() ), 'SwarmEffect' );
			else
				player.SetOrientationTargetCustomHeading( VecHeading( theCamera.GetCameraDirection() ), 'SwarmEffect' );
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		if( isOnPlayer )
		{
			thePlayer.SoundEvent( "animals_crow_swarm_attack_hit_loop_end" );
			thePlayer.SoundEvent( "grunt_vo_geralt_impact_light_loop_end" );
			
			thePlayer.RemoveCustomOrientationTarget( 'SwarmEffect' );
		}
	}
	
	
	protected function IsImmuneToAllDamage(dt : float) : bool
	{
		if(damages.Size() == 0)
			return false;
			
		return super.IsImmuneToAllDamage(dt);
	}
}