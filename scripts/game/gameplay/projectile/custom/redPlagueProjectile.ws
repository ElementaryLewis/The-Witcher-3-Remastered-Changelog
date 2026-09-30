/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3RedPlagueProjectile extends W3LeshyRootProjectile
{
	
	default projExpired = false;
	default collisions = 0;
	
	var surface : CGameplayFXSurfacePost;
	
	private var damageAction 			: W3DamageAction;
	
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		surface = theGame.GetSurfacePostFX();
	
		super.OnSpawned(spawnData);
		AddTimer('SurfacePostFXTimer', 0.01f, true);
	}	

	timer function SurfacePostFXTimer( deltaTime : float, id : int )
	{
		var z : float;
		var position : Vector;
		
		position = this.GetWorldPosition();
		theGame.GetWorld().NavigationComputeZ( position, -5.0, 5.0, z );
		position.Z = z + 0.3;
		this.Teleport(position);
	
		surface.AddSurfacePostFXGroup(this.GetWorldPosition(),  0.3,  5,  2 ,  1,  1 );	
		this.PlayEffect('line_fx');
	}

	function SetOwner( actor : CActor )
	{
		owner = actor;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{	
		var victim 			: CGameplayEntity;
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		if ( victim && victim == ((CActor)caster).GetTarget() )
		{
			collisions += 1;
			
			if ( collisions == 1 )
			{
				this.StopEffect( 'ground_fx' );
				projPos = this.GetWorldPosition();
				theGame.GetWorld().StaticTrace( projPos + Vector(0,0,3), projPos - Vector(0,0,3), projPos, normal );
				projRot = this.GetWorldRotation();
				fxEntity = theGame.CreateEntity( fxEntityTemplate, projPos, projRot );
				fxEntity.PlayEffect( 'attack_fx1', fxEntity );
				fxEntity.DestroyAfter( 10.0 );
				GCameraShake(1.0, true, fxEntity.GetWorldPosition(), 30.0f);
				DelayDamage( 0.01 );
				AddTimer('TimeDestroyNew', 5.0, false);
				projExpired = true;

				surface.AddSurfacePostFXGroup(fxEntity.GetWorldPosition(),  0.3,  5,  2 ,  2,  1 );
			}
		}
		RemoveTimer('SurfacePostFXTimer');
		
		delete damageAction;
	}
	
	function DelayDamage( time : float )
	{
		AddTimer('DelayDamageTimerNew',time,false);
	}
	
	timer function DelayDamageTimerNew( delta : float , id : int)
	{
		var attributeName 	: name;
		var victims 		: array<CGameplayEntity>;
		var rootDmg 		: float;
		var i 				: int;
		
		attributeName = GetBasicAttackDamageAttributeName(theGame.params.ATTACK_NAME_HEAVY, theGame.params.DAMAGE_NAME_PHYSICAL);
		rootDmg = MaxF( RandRangeF(300,200) , CalculateAttributeValue(((CActor)caster).GetAttributeValue(attributeName)) + 200.0  );
		
		damageAction = new W3DamageAction in this;
		damageAction.SetHitAnimationPlayType(EAHA_ForceYes);
		damageAction.attacker = owner;
		
		
		FindGameplayEntitiesInRange( victims, fxEntity, 2, 99, , FLAG_OnlyAliveActors );
		if ( victims.Size() > 0 )
		{
			for ( i = 0 ; i < victims.Size() ; i += 1 )
			{
				if ( !((CActor)victims[i]).IsCurrentlyDodging() )
				{
					damageAction.Initialize( (CGameplayEntity)caster, victims[i], this, caster.GetName()+"_"+"root_projectile", EHRT_Light, CPS_AttackPower, false, true, false, false);
					damageAction.AddDamage(theGame.params.DAMAGE_NAME_ELEMENTAL, rootDmg );
					theGame.damageMgr.ProcessAction( damageAction );
					victims[i].OnRootHit();
				}
			}
		}
		
		delete damageAction;
	}
	
	event OnRangeReached()
	{
		var normal : Vector;
		
		StopAllEffects();
		StopProjectile();
		
		if( !projExpired )
		{
			projExpired = true;
			projPos = this.GetWorldPosition();
			theGame.GetWorld().StaticTrace( projPos + Vector(0,0,3), projPos - Vector(0,0,3), projPos, normal );
			projRot = this.GetWorldRotation();
			fxEntity = theGame.CreateEntity( fxEntityTemplate, projPos, projRot );
			fxEntity.PlayEffect( 'attack_fx1', fxEntity );
			GCameraShake(1.0, true, fxEntity.GetWorldPosition(), 30.0f);
			DelayDamage( 0.3 );
			fxEntity.DestroyAfter( 10.0 );
			AddTimer('TimeDestroyNew', 5.0, false);

			surface.AddSurfacePostFXGroup(fxEntity.GetWorldPosition(),  0.3,  5,  2 ,  2,  1 );	
		}
		RemoveTimer('SurfacePostFXTimer');
	}
	
	function Expired() : bool
	{
		return projExpired;
	}
	
	timer function TimeDestroyNew( deltaTime : float, id : int )
	{
		Destroy();
	}
}

class W3RedPlagueGroundEffect extends CEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		
	}
}