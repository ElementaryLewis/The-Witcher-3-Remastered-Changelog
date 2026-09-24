/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CMagicMineEntity extends CInteractiveEntity
{
	editable var tellTime : float;
	editable var damageVal : float;
	editable var boatDamageVal : float;
	editable var damageRadius : float;
	var mineTrigger : CTriggerAreaComponent;
	

	default tellTime = 3.0;
	default damageVal = 100.0;
	default boatDamageVal = 50.0;
	default damageRadius = 10.0;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		mineTrigger = (CTriggerAreaComponent)GetComponent( "mineTrigger" );
		Enable( bIsEnabled );
	}
	
	function Enable( flag : bool )
	{
		mineTrigger.SetEnabled( flag );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( area == mineTrigger && ( activator.GetEntity() == thePlayer || (CBoatComponent)activator ) )
		{
			Countdown();
		}
	}
	
	function Countdown()
	{
		PlayEffect( 'tell' );
		AddTimer( 'Explode', tellTime, , , , true );
	}
	
	timer function Explode( td : float , id : int)
	{	
		StopAllEffects();
		PlayEffect( 'explode' );
		DealDamage();
		GCameraShake( 1.5, true, thePlayer.GetWorldPosition(), 30.0f );
	}
	
	function DealDamage()
	{
		var entitiesInRange : array<CGameplayEntity>;
		var victim : CActor;
		var i : int;
		var damage : W3DamageAction;
		var destructionComp : CBoatDestructionComponent;
	
		entitiesInRange.Clear();
		FindGameplayEntitiesInRange( entitiesInRange, this, damageRadius, 99 );
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			if( (CActor)entitiesInRange[i] )
			{
				victim = (CActor)entitiesInRange[i];
				victim.AddEffectDefault( EET_KnockdownTypeApplicator, this, this.GetName() );
				
				damage = new W3DamageAction in this;
				damage.Initialize( this, entitiesInRange[i], this, this.GetName(), EHRT_None, CPS_Undefined, false, false, false, true );
				damage.AddDamage( theGame.params.DAMAGE_NAME_PHYSICAL, damageVal );
				theGame.damageMgr.ProcessAction( damage );
				delete damage;
			}
			else if( (W3Boat)entitiesInRange[i] )
			{
				destructionComp = ( (CBoatDestructionComponent)entitiesInRange[i].GetComponentByClassName( 'CBoatDestructionComponent' ) );
				destructionComp.DealDmgToNearestVolume( boatDamageVal, this.GetWorldPosition() );
			}
		}
	}
}