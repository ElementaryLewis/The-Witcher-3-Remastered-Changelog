/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ArchesporBulb extends CNewNPC
{
	private var parentEntity : CNewNPC;
	private var entitiesInRange : array< CGameplayEntity >;
	private var isDestroyed : bool;
	private var hitsTaken : int;
	private var lastHitTimestamp : float;
	private var hitCooldown : float;
	
	private var damageRadius : float;
	private var damageVal : float;
	private var hitsToDeath : int;
	
	default lastHitTimestamp = 0.0;
	default hitCooldown = 0.5;
	default damageRadius = 2.5;
	default damageVal = 750.0;
	default hitsToDeath = 1;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		AddAnimEventCallback( 'DealExplosionDamage', 'OnAnimEvent_DealExplosionDamage' );
	}
	
	event OnIdleStart()
	{
		if( ShouldExplode() )
		{
			ExplodeAfter( RandRangeF( 1.0 ) );
		}
		else if( ShouldExplodeImmediately() )
		{
			RaiseEvent( 'ImmediateExplode' );
			DisableEntity();
		}
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if( !IsCurrentlyUsed() )
		{
			ExplodeAfter( 0.0 );
		}
	}
	
	event OnWeaponHit( act : W3DamageAction )
	{
		if( lastHitTimestamp + hitCooldown < theGame.GetEngineTimeAsSeconds() )
		{
			ProcessDamageTaken( act );
			lastHitTimestamp = theGame.GetEngineTimeAsSeconds();
		}
	}
	
	function OnAnimEvent_DealExplosionDamage( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{	
		if( animEventName == 'DealExplosionDamage' )
		{
			DealExplosionDamage();
			SetIsDestroyed( 20.0 );
		}
		
		return true;
	}
	
	private timer function CheckIfParentIsDead( t : float , id : int )
	{
		if( !parentEntity.IsAlive() )
		{
			if( !IsCurrentlyUsed() )
			{
				ExplodeAfter( RandRangeF( 2.0 ) );
			}
			else
			{
				SetBehaviorVariable( 'deathType', 1.0 );
				RaiseEvent( 'Death' );
				DisableEntity();
				SetIsDestroyed( -1 );
				AddTimer( 'DestroyLastBaseEntity', 1.0, true );
			}

			RemoveTimer( 'CheckIfParentIsDead' );
		}
	}
	
	private timer function DestroyLastBaseEntity( td: float, id : int )
	{
		if( !parentEntity )
		{
			RemoveTimer( 'DestroyLastBaseEntity' );
			DestroyAfter( 1.0 );
		}
	}
	
	private timer function Explode( td: float, id : int )
	{
		RaiseEvent( 'Explode' );
		DisableEntity();
	}
	
	public function ExplodeGlobal()
	{
		RaiseForceEvent( 'ExplodeGlobal' );
		DisableEntity();
	}
	
	private function DisableEntity()
	{
		RemoveTag( 'archespor_base' ); 
		RefreshBaseEntitiesList();
		thePlayer.OnBecomeUnawareOrCannotAttack( this );
	}
	
	private function DealExplosionDamage()
	{
		var damage : W3DamageAction;
		var i : int;
		var actor : CActor;
		
		GCameraShake( 0.5, true, GetWorldPosition(), 10.0f );
	
		FindGameplayEntitiesInSphere( entitiesInRange, GetWorldPosition(), damageRadius, 10 );
	
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			actor = (CActor)entitiesInRange[i];
			if( actor && !actor.HasTag( 'archespor' ) && !actor.IsCurrentlyDodging() && GetAttitudeBetween( this, actor ) == AIA_Hostile )
			{
				damage = new W3DamageAction in this;
				damage.Initialize( this, entitiesInRange[i], NULL, this, EHRT_Heavy, CPS_Undefined, false, false, false, true );
				damage.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, damageVal );
				damage.AddEffectInfo( EET_Stagger );
				damage.AddEffectInfo( EET_Poison );
				theGame.damageMgr.ProcessAction( damage );
				
				delete damage;
			}
		}	
	}
	
	private function ProcessDamageTaken( act : W3DamageAction )
	{
		if( !((CR4Player)act.attacker) || IsDestroyed() || HasTag( 'cantBeDestroyed' ) )
		{
			return;
		}
		
		if( IsCurrentlyUsed() )
		{
			RaiseEvent( 'Hit' );
		}
		else
		{
			hitsTaken += 1;
		
			if( hitsTaken >= hitsToDeath )
			{
				RaiseEvent( 'Death' );
				DisableEntity();
				SetIsDestroyed( 20.0 );
			}
			else
			{
				RaiseEvent( 'BulbHit' );
			}
		}
	}
	
	private function SetIsDestroyed( destroyAfter : float )
	{
		isDestroyed = true;
		
		RemoveTag( 'softLock' );
		RemoveTag( 'softLock_Bomb' );
		RemoveTag( 'softLock_Bolt' );
		RemoveTag( 'softLock_Aard' );
		RemoveTag( 'softLock_Igni' );
		RemoveTag( 'softLock_Weapon' );
		
		EnableCollisions( false );
		EnableCharacterCollisions( false );
		SetAlive( false );
		
		SetGameplayVisibility( false );
		
		if( destroyAfter != -1 )
		{
			DestroyAfter( destroyAfter );
		}
	}
	
	private function IsDestroyed() : bool
	{
		return isDestroyed;
	}
	
	private function ShouldExplode() : bool
	{
		return HasTag( 'suicideBulb' );
	}
	
	private function ShouldExplodeImmediately() : bool
	{
		return HasTag( 'immediateExplode' );
	}

	private function IsCurrentlyUsed() : bool
	{
		return HasTag( 'currentlyUsedBase' );
	}
	
	private function RefreshBaseEntitiesList()
	{
		parentEntity.SignalGameplayEventParamObject( 'RefreshBaseEntitiesList', this );
	}
	
	public function ExplodeAfter( time : float )
	{
		AddTimer( 'Explode', time );
	}
	
	public function SetParentEntity( entity : CNewNPC )
	{
		parentEntity = entity;
		
		AddTimer( 'CheckIfParentIsDead', 2.0, true );
	}
}