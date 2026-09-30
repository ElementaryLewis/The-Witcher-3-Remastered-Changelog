/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3FairytaleWitchFluid extends CGameplayEntity
{
	private var entitiesInRange : array< CGameplayEntity >;

	editable var damageRadius : float;
	editable var damageVal : float;

	default damageRadius = 1.25;
	default damageVal = 50.0;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		DealDamage();
		DestroyAfter( 5.0 );
	}
	
	private function DealDamage()
	{
		var damage : W3DamageAction;
		var i : int;
		var actor : CActor;
		
		GCameraShake( 0.1, true, GetWorldPosition(), 5.0f );
	
		FindGameplayEntitiesInSphere( entitiesInRange, GetWorldPosition(), damageRadius, 10 );
	
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			actor = (CActor)entitiesInRange[i];
			if( actor && !actor.HasTag( 'fairytale_witch' ) && !actor.HasBuff( EET_Poison ) )
			{
				damage = new W3DamageAction in this;
				damage.Initialize( this, entitiesInRange[i], NULL, this, EHRT_Heavy, CPS_Undefined, false, false, false, true );
				damage.AddDamage( theGame.params.DAMAGE_NAME_POISON, damageVal );
				damage.AddEffectInfo( EET_Poison );
				theGame.damageMgr.ProcessAction( damage );
				
				delete damage;
			}
		}	
	}
}