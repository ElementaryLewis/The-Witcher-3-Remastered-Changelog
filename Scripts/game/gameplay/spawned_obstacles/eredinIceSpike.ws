/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3EredinIceSpike extends W3DurationObstacle
{
	editable var explodeAfter : float;
	editable var damageRadius : float;
	editable var damageVal : float;
	editable var effectDuration : float;
	
	var meshComp : CMeshComponent;
	var destructionComp	: CDestructionSystemComponent;
	var entitiesInRange : array< CGameplayEntity >;
	
	default explodeAfter = 2.0;
	default damageRadius = 2.5;
	default damageVal = 50;
	default effectDuration = 4.0;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		destructionComp = (CDestructionSystemComponent)GetComponentByClassName( 'CDestructionSystemComponent' );
		meshComp = (CMeshComponent)GetComponentByClassName( 'CMeshComponent' );
		if( meshComp )
		{
			meshComp.SetVisible( false );
		}
	}
	
	public function Appear()
	{
		meshComp.SetVisible( true );
		PlayEffect( 'appear' );
		PlayEffect( 'tell' );
		AddTimer( 'Explode', explodeAfter );
		DestroyAfter( explodeAfter + 5.0 );
	}
	
	timer function Explode( deltaTime : float, optional id : int )
	{
		var damage : W3DamageAction;
		var i : int;
		var actor : CActor;

		StopAllEffects();
		PlayEffect( 'explosion' );
		meshComp.SetVisible( false );
		
		GCameraShake( 0.5, true, GetWorldPosition(), 20.0f );

		FindGameplayEntitiesInRange( entitiesInRange, this, damageRadius, 1000 );	
		entitiesInRange.Remove( this );
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			actor = (CActor)entitiesInRange[i];
			if( actor )
			{
				damage = new W3DamageAction in this;
				damage.Initialize( this, entitiesInRange[i], NULL, this, EHRT_Heavy, CPS_Undefined, false, false, false, true );
				damage.AddDamage( theGame.params.DAMAGE_NAME_FROST, damageVal );
				damage.AddEffectInfo( EET_Snowstorm, effectDuration );
				damage.AddEffectInfo( EET_Stagger, effectDuration );
				theGame.damageMgr.ProcessAction( damage );
				
				delete damage;
				
				
			}
		}
		
		
	}
	
	
}