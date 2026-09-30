/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3AdvancedProjectile extends CThrowable
{
	editable var projSpeed 						: float;
	editable var projAngle 						: float;
	editable var projDMG   						: float;
	editable var projSilverDMG					: float;
	editable var ignoreArmor					: bool;
	editable var projEfect 						: EEffectType;
	editable var persistFxAfterCollision		: bool;
	editable var dealDamageEvenIfDodging		: bool; 
	var ignore : bool;

	
	
	protected var isActive : bool;
	protected var collidedEntities : array<CGameplayEntity>;
	
	protected var lifeSpan : float; 	default lifeSpan = 20;
	
	default projSpeed = 10.f;
	default projAngle = 5.f;
	default projDMG = 20.f;
	default projEfect = EET_Undefined;
	default persistFxAfterCollision = false;
	default dealDamageEvenIfDodging = false;
	default ignore = false;
	
	public function SetLifeSpan( _duration: float )
	{
		lifeSpan = _duration;
		DestroyAfter(lifeSpan);
	}
	
	public function AddColidedEntity ( _colider : CGameplayEntity )
	{
		collidedEntities.PushBack(_colider);
	}
	
	public function ClearColidedEntities()
	{
		collidedEntities.Clear();
	}
	
	timer function TimeDestroy( deltaTime : float , id : int)
	{
		Destroy();
	}
	
	
	final function ShootProjectileAtPosition( angle : float, velocity : float, target : Vector, optional range : float, optional collisionGroups : array<name> )
	{
		super.ShootProjectileAtPosition( angle, velocity, target, range, collisionGroups );
		this.OnProjectileShot(target);
	}
	
	
	final function ShootProjectileAtNode( angle : float, velocity : float, target : CNode, optional range : float, optional collisionGroups : array<name> )
	{
		super.ShootProjectileAtNode( angle, velocity, target, range, collisionGroups);
		this.OnProjectileShot(target.GetWorldPosition());
	}
	
	
	final function ShootProjectileAtBone( angle : float, velocity : float, target : CEntity, targetBone : name, optional range : float, optional collisionGroups : array<name> )
	{
		super.ShootProjectileAtBone( angle, velocity, target, targetBone, range, collisionGroups );
		this.OnProjectileShot(target.GetWorldPosition());
	}	
	
	
	final function ShootCakeProjectileAtPosition( cakeAngle : float, cakeHeight : float, shootAngle : float, velocity : float, target : Vector, range : float, optional collisionGroups : array<name> )
	{
		super.ShootCakeProjectileAtPosition( cakeAngle, cakeHeight, shootAngle, velocity, target, range, collisionGroups);
		this.OnProjectileShot(target);
	}
	
	event OnProjectileInit()
	{
		isActive = false;
	}
	
	event OnProjectileShot( targetCurrentPosition : Vector, optional target : CNode )
	{
		isActive = true;
	}
	
	function DestroyRequest()
	{
		Destroy();
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var dmgMult : float; 
	
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if ( !dealDamageEvenIfDodging && victim == thePlayer && ( GetAttitudeBetween( victim, caster ) == AIA_Friendly || ( thePlayer.IsCurrentlyDodging() && ( thePlayer.IsCiri() || thePlayer.GetBehaviorVariable( 'isRolling' ) == 1.f ) ) ) )
		{
			victim = NULL;
			ignore = true;
		}
		
		
		if ( thePlayer.IsCiri() && (CActor)victim )
		{
			projDMG = projDMG + (( projDMG * 0.025f ) * ((CActor)victim).GetLevel());
		}
		else
		{
			projDMG = projDMG + (( projDMG * 0.025f ) * thePlayer.GetLevel());
		}
		
	}	
}

class W3BoulderProjectile extends W3AdvancedProjectile
{
	editable var initFxName 					: name;
	editable var onCollisionFxName 				: name;
	editable var spawnEntityTemplate 			: CEntityTemplate;
	editable var onCollisionAppearanceName 		: name;
	
	private var projectileHitGround : bool;
	
	event OnProjectileInit()
	{
		this.PlayEffect(initFxName);
		projectileHitGround = false;
		isActive = true;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		
		
		
		if ( victim && !hitCollisionsGroups.Contains( 'Static' ) && !projectileHitGround && !collidedEntities.Contains(victim) )
		{
			VictimCollision(victim);
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) )
		{
			ProjectileHitGround();
		}
		else if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			ProjectileHitGround();
		}
	}
	
	protected function VictimCollision( victim : CGameplayEntity )
	{	
		DealDamageToVictim(victim);
		DeactivateProjectile(victim);
	}

	protected function DealDamageToVictim( victim : CGameplayEntity )
	{
		var action : W3DamageAction;
		
		action = new W3DamageAction in this;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Heavy,CPS_AttackPower,false,true,false,false);
		if ( projEfect != EET_Undefined )
		{
			action.AddEffectInfo(projEfect);
		}
		
		
		action.AddDamage( theGame.params.DAMAGE_NAME_RENDING, projDMG ); 
		
		if ( ((CActor)victim).UsesEssence() )
		{
			
		}
		
		else
		{
			action.SetIgnoreArmor( ignoreArmor );
		}
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;
		
		collidedEntities.PushBack(victim);
	}
	
	protected function PlayCollisionEffect( optional victim : CGameplayEntity )
	{
		if ( victim == thePlayer && thePlayer.GetCurrentlyCastSign() == ST_Quen && ((W3PlayerWitcher)thePlayer).IsCurrentSignChanneled() )
		{}
		else
			this.PlayEffect(onCollisionFxName);
	}
	
	protected function DeactivateProjectile( optional victim : CGameplayEntity )
	{
		this.StopEffect(initFxName);
		if ( IsNameValid( onCollisionAppearanceName ))
		{
			this.ApplyAppearance( onCollisionAppearanceName );
		}
		PlayCollisionEffect ( victim );
		isActive = false;
		this.DestroyAfter(5.0);
	}
	
	protected function ProjectileHitGround()
	{
		var ent : CEntity;
		var damageAreaEntity : CDamageAreaEntity;
		
		if ( spawnEntityTemplate )
		{
			ent = theGame.CreateEntity( spawnEntityTemplate, this.GetWorldPosition(), this.GetWorldRotation() );
			damageAreaEntity = (CDamageAreaEntity)ent;
			if ( damageAreaEntity )
			{
				damageAreaEntity.owner = (CActor)caster;
				this.StopEffect(initFxName);
				projectileHitGround = true;
			}
		}
		DeactivateProjectile();
	}
	
	
	event OnAardHit( sign : W3AardProjectile )
	{
		var rigidMesh		 	: CMeshComponent;
		var randAngleOffset 	: float;
		var level 				: int;
		
		super.OnAardHit(sign);
		
		StopProjectile();
		
		rigidMesh = (CMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
		
		if ( rigidMesh )
		{
			rigidMesh.SetEnabled( true );
		}
		else
		{
			randAngleOffset = RandRangeF( 10, -10 );
			
			
			
			if(sign.signEntity.IsAlternateCast())
			{
				if(thePlayer.CanUseSkill(S_Magic_s01))
				{
					level = thePlayer.GetSkillLevel(S_Magic_s01);
					if(level == 1)
						this.bounceOfVelocityPreserve = 0.3;
					else if(level == 2)
						this.bounceOfVelocityPreserve = 0.5;
					else if(level >= 3)
						this.bounceOfVelocityPreserve = 0.7;
				}
				else if(thePlayer.CanUseSkill(S_Magic_s12))
				{
					level = thePlayer.GetSkillLevel(S_Magic_s12);
					if(level == 1)
						this.bounceOfVelocityPreserve = 0.3;
					else if(level == 2)
						this.bounceOfVelocityPreserve = 0.5;
					else if(level >= 3)
						this.bounceOfVelocityPreserve = 0.7;
				}
				else
				{
					this.bounceOfVelocityPreserve = 0.1;
				}
			}
			else
			{
				if(thePlayer.CanUseSkill(S_Magic_s12))
				{
					level = thePlayer.GetSkillLevel(S_Magic_s12);
					if(level == 1)
						this.bounceOfVelocityPreserve = 0.3;
					else if(level == 2)
						this.bounceOfVelocityPreserve = 0.5;
					else if(level >= 3)
						this.bounceOfVelocityPreserve = 0.7;
				}
				else
				{
					this.bounceOfVelocityPreserve = 0.1;
				}
			}
			
			this.BounceOff( VecFromHeading( thePlayer.GetHeading() + randAngleOffset ),this.GetWorldPosition() );
			this.Init( thePlayer );
		}
	}
	
}

class W3TraceGroundProjectile extends W3AdvancedProjectile
{
	editable var samplingFreq : float;
	editable var effectName : name;
	editable var onRangedReachedDestroyAfter : float;
	editable var deactivateOnCollisionWithVictim : bool;
	
	default samplingFreq = 0.05f;
	default effectName = 'effect';
	default onRangedReachedDestroyAfter = 5.f;
	default deactivateOnCollisionWithVictim = true;

	

	protected var comp : CEffectDummyComponent;
	
	
	event OnProjectileInit()
	{
		comp = (CEffectDummyComponent)this.GetComponentByClassName('CEffectDummyComponent');
		
		if ( comp )
		{
			isActive = true;
			AddTimer('Sampling', samplingFreq, true);
			Sampling(0.f);
		}
		
	}
	
	event OnRangeReached()
	{
		RemoveTimer('Sampling');
		StopAllEffects();
		StopProjectile();
		AddTimer('TimeDestroy', onRangedReachedDestroyAfter, false);
		
	}
	
	timer function Sampling ( dt : float, optional id : int)
	{
		var newPosition : Vector;
		var zDiff : float;
		
		if ( !isActive )
		{
			return;
		}
		
		newPosition = comp.GetLocalPosition();
		
		
		
		if ( doTrace ( comp, zDiff) )
		{
			newPosition.Z += zDiff;
			comp.SetPosition( newPosition );
			Loop();
		}
	}
	
	private function Loop()
	{
		PlayEffect(effectName);
	}
	
	private function doTrace( comp: CComponent, out outZdiff : float ) : bool
	{
		var currPosition,outPosition, outNormal, tempPosition1, tempPosition2 : Vector;
		
		currPosition = comp.GetWorldPosition();
		
		tempPosition1 = currPosition;
		tempPosition1.Z -= 5;
		
		tempPosition2 = currPosition;
		tempPosition2.Z += 2;
		
		if ( theGame.GetWorld().StaticTrace( tempPosition2, tempPosition1, outPosition, outNormal ) )
		{
			outZdiff = outPosition.Z - currPosition.Z;
			return true;
		}
		
		return false;
	}
}

class W3SpawnEntityProjectile extends W3TraceGroundProjectile
{
	editable var entityTemplate : CEntityTemplate;
	
	protected var entity : CEntity;
	
	private function Loop()
	{
		var entityPos : Vector;
		var entityRot : EulerAngles;
		var damageAreaEntity : CDamageAreaEntity;
		
		entityPos = comp.GetWorldPosition();
		entityRot = comp.GetWorldRotation();
		
		entity = theGame.CreateEntity( entityTemplate, entityPos, entityRot );
		damageAreaEntity = (CDamageAreaEntity)entity;
		if ( damageAreaEntity )
		{
			damageAreaEntity.owner = (CActor)caster;
		}
	}
}

class W3ElementalIfrytProjectile extends W3TraceGroundProjectile
{
	private var action : W3DamageAction;
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if ( victim && !collidedEntities.Contains(victim) )
		{
			action = new W3DamageAction in this;
			action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_SpellPower,false,true,false,false);
			action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, 200.f );		
			action.AddEffectInfo(EET_Burning, 2.0);
			action.SetCanPlayHitParticle(false);
			theGame.damageMgr.ProcessAction( action );
			collidedEntities.PushBack(victim);
			if ( deactivateOnCollisionWithVictim )
			{
				isActive = false;
			}
			delete action;
		}
		
	}
}

class W3EredinFrostProjectile extends W3TraceGroundProjectile
{
	private var action : W3DamageAction;
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if ( victim && !collidedEntities.Contains(victim) )
		{
			action = new W3DamageAction in this;
			action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Heavy,CPS_SpellPower,false,true,false,false);
			action.AddDamage(theGame.params.DAMAGE_NAME_FROST, projDMG );
			action.AddEffectInfo( projEfect, 2.0 );
			action.SetCanPlayHitParticle(false);
			theGame.damageMgr.ProcessAction( action );
			collidedEntities.PushBack(victim);
			if ( deactivateOnCollisionWithVictim )
			{
				isActive = false;
			}
			delete action;
		}
		
	}
}

class W3ElementalDaoProjectile extends W3TraceGroundProjectile
{
	private var action : W3DamageAction;
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if ( victim && !collidedEntities.Contains(victim) )
		{
			action = new W3DamageAction in this;
			action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_None,CPS_AttackPower,false,true,false,false);
			action.AddEffectInfo(EET_Knockdown);
			action.AddDamage(theGame.params.DAMAGE_NAME_ELEMENTAL, 200.f );	
			theGame.damageMgr.ProcessAction( action );
			collidedEntities.PushBack(victim);
			if ( deactivateOnCollisionWithVictim )
			{
				isActive = false;
			}
			delete action;
		}
	}
}

class W3StoneProjectile extends W3AdvancedProjectile
{
	editable var initFxName : name;
	editable var onCollisionFxName : name;
	editable var stoneTemplate : CEntityTemplate;
	
	private var action : W3DamageAction;
	
	private autobind comp : CMeshComponent = single;

	event OnProjectileInit()
	{
		this.PlayEffect(initFxName);
		isActive = true;
		AddTimer('Rotate',0.0000001f,true);
	}
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		
		if ( victim && !collidedEntities.Contains(victim) )
		{
			action = new W3DamageAction in this;
			action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_None,CPS_AttackPower,false,true,false,false);
			action.AddEffectInfo(EET_Knockdown);
			action.AddDamage(theGame.params.DAMAGE_NAME_BLUDGEONING, 200.f );		
			theGame.damageMgr.ProcessAction( action );
			collidedEntities.PushBack(victim);
			isActive = false;
			this.PlayEffect(onCollisionFxName);
			this.StopEffect(initFxName);
			delete action;
		}
		
		return true;
	}
	
	event OnRangeReached()
	{
		var ent : CEntity;
		this.PlayEffect(onCollisionFxName);
		this.StopEffect(initFxName);
		
		if( comp )
		{
			comp.SetVisible(false);
		}
		
		ent = theGame.CreateEntity( stoneTemplate, this.GetWorldPosition(), this.GetWorldRotation() );
		ent.PlayEffect('destroy');
		isActive = false;
		this.DestroyAfter(5.f);
		return true;
	}
	
	timer function Rotate( dt : float , id : int)
	{
		
		var rot : EulerAngles;
		
		
		if( !comp )
		{
			return;
		}
		
		rot = comp.GetLocalRotation();
		rot.Yaw += 0.5;
		comp.SetRotation( rot );
		
	}
	
	
	event OnAardHit( sign : W3AardProjectile )
	{
		var rigidMesh		 	: CMeshComponent;
		var randAngleOffset 	: float;
		var level 				: int;
		
		super.OnAardHit(sign);
		
		StopProjectile();
		
		rigidMesh = (CMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
		
		if ( rigidMesh )
		{
			rigidMesh.SetEnabled( true );
		}
		else
		{
			randAngleOffset = RandRangeF( 10, -10 );
			
			
			
			if(sign.signEntity.IsAlternateCast())
			{
				if(thePlayer.CanUseSkill(S_Magic_s01))
				{
					level = thePlayer.GetSkillLevel(S_Magic_s01);
					if(level == 1)
						this.bounceOfVelocityPreserve = 0.3;
					else if(level == 2)
						this.bounceOfVelocityPreserve = 0.5;
					else if(level >= 3)
						this.bounceOfVelocityPreserve = 0.7;
				}
				else if(thePlayer.CanUseSkill(S_Magic_s12))
				{
					level = thePlayer.GetSkillLevel(S_Magic_s12);
					if(level == 1)
						this.bounceOfVelocityPreserve = 0.3;
					else if(level == 2)
						this.bounceOfVelocityPreserve = 0.5;
					else if(level >= 3)
						this.bounceOfVelocityPreserve = 0.7;
				}
				else
				{
					this.bounceOfVelocityPreserve = 0.1;
				}
			}
			else
			{
				if(thePlayer.CanUseSkill(S_Magic_s12))
				{
					level = thePlayer.GetSkillLevel(S_Magic_s12);
					if(level == 1)
						this.bounceOfVelocityPreserve = 0.3;
					else if(level == 2)
						this.bounceOfVelocityPreserve = 0.5;
					else if(level >= 3)
						this.bounceOfVelocityPreserve = 0.7;
				}
				else
				{
					this.bounceOfVelocityPreserve = 0.1;
				}
			}
			
			this.BounceOff( VecFromHeading( thePlayer.GetHeading() + randAngleOffset ),this.GetWorldPosition() );
			this.Init( thePlayer );
		}
	}
	
}

class W3EnvironmentProjectile extends W3AdvancedProjectile
{
	editable var initFxName 			: name;
	editable var stopFxOnDeactivate		: name;
	editable var onCollisionFxName		: name;
	editable var ignoreVictimsWithTag 	: name;
	
	private var action : W3DamageAction;
	
	private autobind comp : CMeshComponent = single;

	event OnProjectileInit()
	{
		this.PlayEffect(initFxName);
		isActive = true;
		AddTimer('Rotate',0.0000001f,true);
	}
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		
		
		
		
		if ( victim && !collidedEntities.Contains(victim) && victim != caster )
		{
			action = new W3DamageAction in this;
			action.Initialize(( CGameplayEntity )caster, victim, this, caster.GetName(), EHRT_None, CPS_AttackPower, false, true, false, false );
			action.AddEffectInfo( EET_Stagger );
			action.AddDamage( theGame.params.DAMAGE_NAME_BLUDGEONING, 200.f );		
			theGame.damageMgr.ProcessAction( action );
			collidedEntities.PushBack(victim);
			if ( IsNameValid( onCollisionFxName ))
				this.PlayEffect( onCollisionFxName );
			if ( IsNameValid( initFxName ))
				this.StopEffect(initFxName);
			if ( IsNameValid( stopFxOnDeactivate ))
				this.StopEffect(stopFxOnDeactivate);
			delete action;
			
			bounceOfVelocityPreserve = 0.2;
			BounceOff(normal,pos);
			this.Init( victim );
			return true;
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) )
		{
			StopProjectile();
			if ( IsNameValid( initFxName ))
				this.StopEffect(initFxName);
			if ( IsNameValid( stopFxOnDeactivate ))
				this.StopEffect(stopFxOnDeactivate);
			isActive = false;
			
			return true;
		}
	}
	
	event OnRangeReached()
	{
		var ent : CEntity;
		if ( IsNameValid( onCollisionFxName ))
			this.PlayEffect(onCollisionFxName);
		if ( IsNameValid( initFxName ))
			this.StopEffect(initFxName);
		if ( IsNameValid( stopFxOnDeactivate ))
			this.StopEffect(stopFxOnDeactivate);
		
		return true;
	}
	
	timer function Rotate( dt : float , id : int)
	{
		var rot : EulerAngles;
		
		if( !comp )
		{
			return;
		}
		
		rot = comp.GetLocalRotation();
		rot.Yaw += 0.5;
		comp.SetRotation( rot );
	}
	
	
	
	event OnAardHit( sign : W3AardProjectile )
	{
		var rigidMesh		 	: CMeshComponent;
		var randAngleOffset 	: float;
		var level 				: int;
		
		super.OnAardHit(sign);
		
		StopProjectile();
		
		rigidMesh = (CMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
		
		if ( rigidMesh )
		{
			rigidMesh.SetEnabled( true );
		}
		else
		{
			randAngleOffset = RandRangeF( 10, -10 );
			
			
			
			if(sign.signEntity.IsAlternateCast())
			{
				if(thePlayer.CanUseSkill(S_Magic_s01))
				{
					level = thePlayer.GetSkillLevel(S_Magic_s01);
					if(level == 1)
						this.bounceOfVelocityPreserve = 0.3;
					else if(level == 2)
						this.bounceOfVelocityPreserve = 0.5;
					else if(level >= 3)
						this.bounceOfVelocityPreserve = 0.7;
				}
				else if(thePlayer.CanUseSkill(S_Magic_s12))
				{
					level = thePlayer.GetSkillLevel(S_Magic_s12);
					if(level == 1)
						this.bounceOfVelocityPreserve = 0.3;
					else if(level == 2)
						this.bounceOfVelocityPreserve = 0.5;
					else if(level >= 3)
						this.bounceOfVelocityPreserve = 0.7;
				}
				else
				{
					this.bounceOfVelocityPreserve = 0.1;
				}
			}
			else
			{
				if(thePlayer.CanUseSkill(S_Magic_s12))
				{
					level = thePlayer.GetSkillLevel(S_Magic_s12);
					if(level == 1)
						this.bounceOfVelocityPreserve = 0.3;
					else if(level == 2)
						this.bounceOfVelocityPreserve = 0.5;
					else if(level >= 3)
						this.bounceOfVelocityPreserve = 0.7;
				}
				else
				{
					this.bounceOfVelocityPreserve = 0.1;
				}
			}
			
			this.BounceOff( VecFromHeading( thePlayer.GetHeading() + randAngleOffset ),this.GetWorldPosition() );
			this.Init( thePlayer );
		}
	}
}

class BeamProjectile extends W3AdvancedProjectile
{
	editable var beamFx : name;
	editable var pullEffectDuration	: float;
	
	
	
	default pullEffectDuration = 1.5f;
	
	event OnProjectileInit()
	{
		caster.PlayEffect( beamFx, this);
		isActive = true;		
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var customDamageValuePerSec : SAbilityAttributeValue;
		var res : bool;
		var comp : CComponent;
		var params : SCustomEffectParams;
		var targetCmp 	: CComponent;
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CActor)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if ( victim && !collidedEntities.Contains(victim) )
		{
			this.StopProjectile();
			this.DestroyAfter(5.f);
			
			res = this.CreateAttachment(victim,'torso3_effect');
			
			if ( !res )
				this.CreateAttachment(victim);
				
			targetCmp = victim.GetComponent('torso3effect');
			if( targetCmp )			
				caster.PlayEffect( beamFx, targetCmp );
			else
				caster.PlayEffect( beamFx, victim );
			
			params.effectType = EET_Pull;
			params.creator = (CGameplayEntity)caster;
			params.duration = pullEffectDuration;
			params.effectValue = customDamageValuePerSec;
			
			((CActor)victim).AddEffectCustom(params);
			collidedEntities.PushBack(victim);
			isActive = false;
		}
		return false;
	}
	
	event OnRangeReached()
	{
		if ( !isActive )
			return true;
			
		isActive = false;
		if ( !victim )
		{
			caster.StopEffect( beamFx );
			((CActor)caster).SignalGameplayEvent('ProjectileMissed');
		}
		this.DestroyAfter(1.f);
	}
}

class WebLineProjectile extends PoisonProjectile
{	
	protected function VictimCollision( victim : CGameplayEntity )
	{
		var params : SCustomEffectParams;
		var customDamageValuePerSec : SAbilityAttributeValue;
		var player : W3PlayerWitcher;
		var quen : W3QuenEntity;
		var damageData : W3DamageAction;

		if ( victim != thePlayer )
			return;
		
		player = (W3PlayerWitcher)thePlayer;
		
		if ( player.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
			player.OnRangedForceHolster( true, true, false );
			
		PlayCollisionEffect( victim );
		this.StopEffect(initFxName);
		this.StopProjectile();
		this.DestroyAfter(5.0f);
		
		
		quen = (W3QuenEntity)( player.GetSignEntity( ST_Quen ) );

		if ( victim == thePlayer && quen )
		{
			damageData =  new W3DamageAction in this;
			damageData.attacker = (CGameplayEntity)caster;
			quen.OnTargetHit( damageData );
			
			if ( !((W3PlayerWitcher)thePlayer).IsCurrentSignChanneled() )
			{
				quen.ForceFinishQuen( true );
			}
		}
		else
		{
			params.effectType = EET_Tangled;
			params.creator = (CGameplayEntity)caster;
			params.duration = 1.f;
			params.effectValue = customDamageValuePerSec;
			
			((CActor)victim).AddEffectCustom(params);
			collidedEntities.PushBack(victim);
		}
		isActive = false;
	}	
}

class FakeProjectile extends W3AdvancedProjectile
{
	event OnProjectileInit()
	{
		isActive = true;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
	}
	
	event OnRangeReached()
	{
		this.StopAllEffects();
        this.DestroyAfter( 60.0 );
	}
}

class PoisonProjectile extends W3AdvancedProjectile
{
	editable var initFxName				: name;
	editable var onCollisionFxName 		: name;
	editable var spawnEntityOnGround	: bool;
	editable var spawnEntityTemplate 	: CEntityTemplate;

	
	var projectileHitGround : bool;
	
	default projDMG = 40.f;
	default projEfect = EET_Poison;

	
	event OnProjectileInit()
	{
		this.PlayEffect(initFxName);
		projectileHitGround = false;
		isActive = true;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
				
		if ( victim && !projectileHitGround && !collidedEntities.Contains(victim) )
		{
			VictimCollision(victim);
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) )
		{
			ProjectileHitGround();
		}
		else if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			ProjectileHitGround();
		}
	}
	
	protected function VictimCollision( victim : CGameplayEntity )
	{
		DealDamageToVictim(victim);
		PlayCollisionEffect(victim);
		SpawnEntity( spawnEntityOnGround );
		DeactivateProjectile();
	}
	
	protected function DealDamageToVictim( victim : CGameplayEntity )
	{
		var action : W3DamageAction;
		var actorCaster, actorVictim : CActor;
		
		actorCaster = (CActor)caster;
		actorVictim = (CActor)victim;
		
		if( actorCaster && actorVictim && GetAttitudeBetween( actorCaster, actorVictim ) != AIA_Hostile )
		{
			return;
		}
		
		action = new W3DamageAction in theGame;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_SpellPower,false,true,false,false);
		action.AddDamage(theGame.params.DAMAGE_NAME_POISON, projDMG );
		action.AddEffectInfo(EET_Poison, 2.0);
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;
		
		collidedEntities.PushBack(victim);
	}
	
	protected function PlayCollisionEffect( optional victim : CGameplayEntity)
	{
		if ( victim == thePlayer && thePlayer.GetCurrentlyCastSign() == ST_Quen && ((W3PlayerWitcher)thePlayer).IsCurrentSignChanneled() )
		{}
		else
			this.PlayEffect(onCollisionFxName);
	}
	
	protected function DeactivateProjectile()
	{
		isActive = false;
		if( !persistFxAfterCollision )
		{
			this.StopEffect(initFxName);	
		}
		this.DestroyAfter(1.f);
	}
	
	protected function ProjectileHitGround()
	{
		SpawnEntity( spawnEntityOnGround );
		this.PlayEffect(onCollisionFxName);
		DeactivateProjectile();
	}
	
	function SpawnEntity( onGround : bool )
	{
		var ent : CEntity;
		var damageAreaEntity : CDamageAreaEntity;
		var entPos, normal : Vector;
		
		if ( spawnEntityTemplate )
		{
			entPos = this.GetWorldPosition();
			if ( onGround )
				theGame.GetWorld().StaticTrace( entPos + Vector(0,0,3), entPos - Vector(0,0,3), entPos, normal );
			ent = theGame.CreateEntity( spawnEntityTemplate, entPos, this.GetWorldRotation() );
			damageAreaEntity = (CDamageAreaEntity)ent;
			if ( damageAreaEntity )
			{
				damageAreaEntity.owner = (CActor)caster;
				this.StopEffect(initFxName);
				projectileHitGround = true;
			}
		}
	}
	
	event OnRangeReached()
	{
		
		
		
		this.DestroyAfter(5.0f);
	}
}

class SpawnMultipleEntitiesPoisonProjectile extends PoisonProjectile
{
	editable var numberOfSpawns			: int;
	editable var minDistFromTarget		: int;
	editable var maxDistFromTarget		: int;
	
	function SpawnEntity( onGround : bool )
	{
		var ent : CEntity;
		var damageAreaEntity 	: CDamageAreaEntity;
		var entPos, normal 				: Vector;
		var i					: int;
		
		if ( spawnEntityTemplate )
		{
			for( i=0; i<numberOfSpawns; i+=1 )
			{
				entPos = this.GetWorldPosition();
				if ( onGround )
					theGame.GetWorld().StaticTrace( entPos + Vector(0,0,3), entPos - Vector(0,0,3), entPos, normal );
				ent = theGame.CreateEntity( spawnEntityTemplate, FindRandomPosition(entPos), this.GetWorldRotation() );
				damageAreaEntity = (CDamageAreaEntity)ent;
				
				if ( damageAreaEntity )
				{
					damageAreaEntity.owner = (CActor)caster;
					this.StopEffect(initFxName);
					projectileHitGround = true;
				}
			}
		}
		
	}
	
	function FindRandomPosition( pos : Vector ) : Vector
	{
		var randVec : Vector = Vector( 0.f, 0.f, 0.f );
		var outPos : Vector;
		
		randVec = VecRingRand( minDistFromTarget, maxDistFromTarget );
		outPos = pos + randVec;
		
		return outPos;
	}
}

class DebuffProjectile extends W3AdvancedProjectile
{
	editable var debuffType 					: EEffectType;
	editable var hitReactionType 				: EHitReactionType;
	editable var damageTypeName 				: name;
	editable var destroyQuen 					: bool;
	editable var customDuration					: float;
	editable var initFxName 					: name;
	editable var onCollisionFxName 				: name;
	editable var specialFxOnVictimName 			: name;
	editable var applyDebuffIfNoDmgWasDealt 	: bool;
	editable var bounceOnVictimHit 				: bool;
	editable var signalDamageInstigatedEvent	: bool;
	editable var destroyAfterFloat				: float;
	editable var stopProjectileAfterCollision	: bool;
	editable var sendGameplayEventToVicitm 		: name;

	
	default customDuration = 3;
	default hitReactionType = EHRT_Light;
	default destroyAfterFloat = 5.0f;
	default stopProjectileAfterCollision = true;
	default dealDamageEvenIfDodging = false;
	
	
	
	hint specialFxOnVictimName = "will be played on collision when applyDebuffIfNoDmgWasDealt is set to true";
	
	event OnProjectileInit()
	{
		this.PlayEffect( initFxName );
		if ( !IsNameValid( damageTypeName ) )
			damageTypeName = theGame.params.DAMAGE_NAME_PIERCING;
		isActive = true;
	}
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var action : W3DamageAction;
		var params : SCustomEffectParams;
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CActor)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		
		if ( victim && !collidedEntities.Contains(victim) )
		{
			if( stopProjectileAfterCollision )
			{
				this.StopProjectile();
			}
			this.DestroyAfter( destroyAfterFloat );
			if( !persistFxAfterCollision )
			{
				this.StopEffect( initFxName );
			}
			this.PlayEffect(onCollisionFxName);
			
			if ( IsNameValid( sendGameplayEventToVicitm ) )
			{
				( (CActor)victim ).SignalGameplayEvent( sendGameplayEventToVicitm );
			}
			
			
			
			action = new W3DamageAction in this;
			action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),hitReactionType,CPS_AttackPower, false, true, false, false);
			if ( this.projDMG > 0 )
			{
				
				if ( ((CActor)victim).UsesEssence() )
				{
					
				}
				
				else
				{
					action.SetIgnoreArmor( ignoreArmor );
				}
				action.AddDamage(damageTypeName, projDMG );
				
				
				if ( !DamageHitsEssence( damageTypeName ) )
				{
					action.AddDamage(theGame.params.DAMAGE_NAME_RENDING, projDMG );
				}
				
			}
			
			if ( customDuration > 0 && (CActor)victim )
			{
				if ( !destroyQuen && (W3PlayerWitcher)victim && (((W3PlayerWitcher)victim).IsQuenActive( false ) || ((W3PlayerWitcher)victim).IsQuenActive( true )) ) {}
				else
				{
					params.effectType = debuffType;
					params.creator = NULL;
					params.sourceName = "debuff_projectile";
					params.duration = customDuration;
					
					((CActor)victim).AddEffectCustom(params);
				}
			}
			else
			{
				action.AddEffectInfo(debuffType);
				action.SetProcessBuffsIfNoDamage(applyDebuffIfNoDmgWasDealt);
			}
			
			action.SetCanPlayHitParticle(false);
			theGame.damageMgr.ProcessAction( action );
			if ( signalDamageInstigatedEvent )
			{
				((CActor)caster).SignalGameplayEventParamObject( 'DamageInstigated', action );
			}
			if ( destroyQuen && ((W3PlayerWitcher)victim).IsQuenActive( false ) )
			{
				((W3PlayerWitcher)victim).FinishQuen( false );
			}
			
			delete action;
			
			
			if ( applyDebuffIfNoDmgWasDealt )
				victim.PlayEffect(specialFxOnVictimName);
			
			if ( bounceOnVictimHit )
			{
				this.BounceOff(normal,pos);
				this.Init(victim);				
				return true;
			}
			
			collidedEntities.PushBack(victim);
			isActive = false;
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) || hitCollisionsGroups.Contains( 'Water' ) )
		{
			if( stopProjectileAfterCollision )
			{
				this.StopProjectile();
			}
			this.DestroyAfter( destroyAfterFloat );
			if( !persistFxAfterCollision )
			{
				this.StopEffect( initFxName );
			}
			this.PlayEffect(onCollisionFxName);
			isActive = false;
		}
		
		return false;
	}
	
	event OnRangeReached()
	{
		isActive = false;
		this.StopEffect( initFxName );
		this.DestroyAfter(1.f);
	}
}




class W3FireballProjectile extends W3AdvancedProjectile
{
	editable var initFxName 			: name;
	editable var onCollisionFxName 		: name;
	editable var spawnEntityTemplate 	: CEntityTemplate;
	editable var decreasePlayerDmgBy	: float; default decreasePlayerDmgBy = 0.f;

	private var projectileHitGround : bool;
	
	default projDMG = 200.f;
	default projEfect = EET_Burning;

	event OnProjectileInit()
	{
		this.PlayEffect(initFxName);
		projectileHitGround = false;
		isActive = true;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		
		if ( victim && !hitCollisionsGroups.Contains( 'Static' ) && !projectileHitGround && !collidedEntities.Contains(victim) )
		{
			VictimCollision(victim);
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) )
		{
			ProjectileHitGround();
		}
		else if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			ProjectileHitGround();
		}
	}
	
	protected function VictimCollision( victim : CGameplayEntity )
	{
		DealDamageToVictim(victim);
		DeactivateProjectile(victim);
	}
	
	protected function DealDamageToVictim( victim : CGameplayEntity )
	{
		var action : W3DamageAction;
		
		action = new W3DamageAction in theGame;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_SpellPower,false,true,false,false);
		
		if ( victim == thePlayer )
		{
			projDMG = projDMG - (projDMG * decreasePlayerDmgBy);
		}
		
		action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, projDMG );
		action.AddEffectInfo(EET_Burning, 2.0);
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;
		
		collidedEntities.PushBack(victim);
	}
	
	protected function PlayCollisionEffect( optional victim : CGameplayEntity )
	{
		if ( victim == thePlayer && thePlayer.GetCurrentlyCastSign() == ST_Quen && ((W3PlayerWitcher)thePlayer).IsCurrentSignChanneled() )
		{}
		else
			this.PlayEffect(onCollisionFxName);
	}
	
	protected function DeactivateProjectile( optional victim : CGameplayEntity )
	{
		isActive = false;
		this.StopEffect(initFxName);
		this.DestroyAfter(5.0);
		PlayCollisionEffect ( victim );
	}
	
	protected function ProjectileHitGround()
	{
		var ent 				: CEntity;
		var damageAreaEntity 	: CDamageAreaEntity;
		var actorsAround	 	: array<CActor>;
		var i					: int;
		
		if ( spawnEntityTemplate )
		{
			ent = theGame.CreateEntity( spawnEntityTemplate, this.GetWorldPosition(), this.GetWorldRotation() );
			damageAreaEntity = (CDamageAreaEntity)ent;
			if ( damageAreaEntity )
			{
				damageAreaEntity.owner = (CActor)caster;
				projectileHitGround = true;
			}
		}
		
		else
		{
			actorsAround = GetActorsInRange( this, 2, , , true );
			for( i = 0; i < actorsAround.Size(); i += 1 )
			{
				DealDamageToVictim( actorsAround[i] );
			}
		}
		DeactivateProjectile();
	}
	
	event OnRangeReached()
	{
		
		
		
		this.DestroyAfter(5.f);
	}
	
	function SetProjectileHitGround( b : bool )
	{
		projectileHitGround = b;
	}
}

class W3DracolizardFireball extends W3FireballProjectile
{
	editable var range				: float;
	editable var burningDur			: float;
	editable var destroyAfter		: float;
	editable var surfaceFX 			: SFXSurfacePostParams;
	
	protected function PlayCollisionEffect( optional victim : CGameplayEntity)
	{
		if ( victim == thePlayer && thePlayer.GetCurrentlyCastSign() == ST_Quen && ((W3PlayerWitcher)thePlayer).IsCurrentSignChanneled() )
		{
			DeactivateProjectile();
		}
		else
			this.PlayEffect(onCollisionFxName);
	}
	
	protected function ProjectileHitGround()
	{
		var ent 				: CEntity;
		var damageAreaEntity 	: CDamageAreaEntity;
		var actorsAround	 	: array<CActor>;
		var i					: int;
		var surface				: CGameplayFXSurfacePost;
		
		if ( spawnEntityTemplate )
		{
			ent = theGame.CreateEntity( spawnEntityTemplate, this.GetWorldPosition(), this.GetWorldRotation() );
			ent.DestroyAfter(destroyAfter);
			damageAreaEntity = (CDamageAreaEntity)ent;
			actorsAround = GetActorsInRange( this, range, , , true );
			for( i = 0; i < actorsAround.Size(); i += 1 )
			{
				DealDamageToVictim( actorsAround[i] );
			}
			if ( damageAreaEntity )
			{
				damageAreaEntity.owner = (CActor)caster;
				SetProjectileHitGround( true );
			}
		}
		
		else
		{
			actorsAround = GetActorsInRange( this, range, , , true );
			for( i = 0; i < actorsAround.Size(); i += 1 )
			{
				DealDamageToVictim( actorsAround[i] );
			}
		}
		surface = theGame.GetSurfacePostFX();
		surface.AddSurfacePostFXGroup( GetWorldPosition(), surfaceFX.fxFadeInTime, surfaceFX.fxLastingTime, surfaceFX.fxFadeOutTime, surfaceFX.fxRadius, surfaceFX.fxType );
		
		DeactivateProjectile();
	}
	
	protected function DealDamageToVictim( victim : CGameplayEntity )
	{
		var action : W3DamageAction;
		
		action = new W3DamageAction in theGame;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_SpellPower,false,true,false,false);
		
		if ( victim == thePlayer )
		{
			projDMG = projDMG - (projDMG * decreasePlayerDmgBy);
		}
		
		action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, projDMG );
		action.AddEffectInfo(EET_Burning, burningDur );
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;
		
		collidedEntities.PushBack(victim);
	}
	
	protected function DeactivateProjectile( optional victim : CGameplayEntity )
	{
		isActive = false;
		GCameraShake( 3, 5, GetWorldPosition() );
		this.DestroyAfter(destroyAfter);
		PlayCollisionEffect ( victim );
		
	}
	event OnRangeReached()
	{
		return true;
	}
	
}

class W3MeteorProjectile_CreateMarkerEntityHelper extends CCreateEntityHelper
{
	var owner : W3MeteorProjectile;
	
	event OnEntityCreated( entity : CEntity )
	{
		if ( owner )
		{
			owner.markerEntity = entity;
			theGame.GetBehTreeReactionManager().CreateReactionEvent( owner, 'MeteorMarker', owner.destroyMarkerAfter, owner.explosionRadius, 0.1f, 999, true );
			owner = NULL;
		}
		else
		{
			entity.StopAllEffects();
			entity.DestroyAfter(2.f);
		}
	}
}

class W3MeteorProjectile extends W3FireballProjectile
{
	editable var explosionRadius 		: float;
	editable var markerEntityTemplate	: CEntityTemplate;
	editable var destroyMarkerAfter		: float;

	var markerEntity 			: CEntity;
	
	default projSpeed = 10;
	default projAngle = 0;
	
	default explosionRadius = 3;
	default destroyMarkerAfter = 2.f;
	
	protected function VictimCollision( victim : CGameplayEntity )
	{
		
	}
	
	protected function DeactivateProjectile( optional victim : CGameplayEntity)
	{
		if ( !isActive )
			return;
		
		Explode();
		
		
		if ( markerEntity )
		{
			markerEntity.StopAllEffects();
			markerEntity.DestroyAfter( destroyMarkerAfter );
		}
		
		super.DeactivateProjectile(victim);
		
	}
	
	protected function Explode()
	{
		var entities 		: array<CGameplayEntity>;
		var i				: int;
		
		FindGameplayEntitiesInCylinder( entities, this.GetWorldPosition(), explosionRadius, 2.f, 99 ,'',FLAG_ExcludeTarget, this );
		
		for( i = 0; i < entities.Size(); i += 1 )
		{
			if ( !collidedEntities.Contains(entities[i]) )
				DealDamageToVictim(entities[i]);
		}
		
		GCameraShake( 3, 5, GetWorldPosition() );
	}
	
	protected function ProjectileHitGround()
	{
		var entities 		: array<CGameplayEntity>;
		var i				: int;
		var landPos			: Vector;
		
		landPos = this.GetWorldPosition();
		
		FindGameplayEntitiesInSphere( entities, this.GetWorldPosition(), 2, 10, '', FLAG_ExcludeTarget, this );
		
		for( i = 0; i < entities.Size(); i += 1 )
		{
			entities[i].ApplyAppearance( "hole" );			
			if( theGame.GetWorld().GetWaterLevel( landPos ) > landPos.Z )
			{
				entities[i].PlayEffect('explosion_water');			
			}
			else
			{
				entities[i].PlayEffect('explosion');
			}
		}
		
		super.ProjectileHitGround();
	}
	
	event OnProjectileShot( targetCurrentPosition : Vector, optional target : CNode )
	{
		var createEntityHelper : W3MeteorProjectile_CreateMarkerEntityHelper;
	
		super.OnProjectileShot(targetCurrentPosition, target);
		
		createEntityHelper = new W3MeteorProjectile_CreateMarkerEntityHelper in theGame;
		createEntityHelper.owner = this;
		createEntityHelper.SetPostAttachedCallback( createEntityHelper, 'OnEntityCreated' );

		theGame.CreateEntityAsync( createEntityHelper, markerEntityTemplate, targetCurrentPosition, EulerAngles(0,0,0) );
	}
}

class W3IceMeteorProjectile extends W3MeteorProjectile
{
	protected function DealDamageToVictim( victim : CGameplayEntity )
	{
		var action : W3DamageAction;
		
		action = new W3DamageAction in theGame;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Heavy,CPS_SpellPower,false,true,false,false);
		action.AddDamage(theGame.params.DAMAGE_NAME_FROST, projDMG );
		action.AddEffectInfo(EET_SlowdownFrost, 2.0);
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;
		
		collidedEntities.PushBack(victim);
	}
}


class W3LightningStrikeProjectile extends W3MeteorProjectile
{
	protected function DealDamageToVictim( victim : CGameplayEntity )
	{
		var action : W3DamageAction;
		
		action = new W3DamageAction in this;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_SpellPower,false,true,false,false);
		action.AddDamage(theGame.params.DAMAGE_NAME_SHOCK , projDMG );
		action.AddEffectInfo(EET_Paralyzed, 2.0);
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;
		
		collidedEntities.PushBack(victim);
	}
}


class W3LightningBoltProjectile extends W3AdvancedProjectile
{
	editable var initFxName : name;
	editable var onCollisionFxName : name;
	editable var spawnEntityTemplate : CEntityTemplate;

	private var projectileHitGround : bool;
	
	default projDMG = 40.f;
	default projEfect = EET_Paralyzed;

	event OnProjectileInit()
	{
		this.PlayEffect(initFxName);
		projectileHitGround = false;
		isActive = true;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if ( victim && !projectileHitGround && !collidedEntities.Contains(victim) )
		{
			VictimCollision(victim);
		}
		else if ( !victim && !ignore ) 
		{
			ProjectileHitGround();
		}
	}
	
	protected function VictimCollision( victim : CGameplayEntity )
	{
			DealDamageToVictim(victim);
			PlayCollisionEffect(victim);
			DeactivateProjectile();
	}
	
	protected function DealDamageToVictim( victim : CGameplayEntity )
	{
		var action : W3DamageAction;
		
		action = new W3DamageAction in this;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_SpellPower,false,true,false,false);
		action.AddDamage(theGame.params.DAMAGE_NAME_SHOCK , projDMG );
		action.AddEffectInfo(EET_Paralyzed, 2.0);
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;
		
		collidedEntities.PushBack(victim);
	}
	
	protected function PlayCollisionEffect( optional victim : CGameplayEntity)
	{
		if ( victim == thePlayer && thePlayer.GetCurrentlyCastSign() == ST_Quen && ((W3PlayerWitcher)thePlayer).IsCurrentSignChanneled() )
		{}
		else
			this.PlayEffect(onCollisionFxName);
	}
	
	protected function DeactivateProjectile()
	{
		isActive = false;
		this.StopEffect(initFxName);
	}
	
	protected function ProjectileHitGround()
	{
		var ent : CEntity;
		var damageAreaEntity : CDamageAreaEntity;
		
		this.PlayEffect(onCollisionFxName);
		if ( spawnEntityTemplate )
		{
			
			ent = theGame.CreateEntity( spawnEntityTemplate, this.GetWorldPosition(), this.GetWorldRotation() );
			damageAreaEntity = (CDamageAreaEntity)ent;
			if ( damageAreaEntity )
			{
				damageAreaEntity.owner = (CActor)caster;
				this.StopEffect(initFxName);
				projectileHitGround = true;
			}
		}
		DeactivateProjectile();
	}
	
	event OnRangeReached()
	{
		
		
		
		this.DestroyAfter(5.f);
	}
}


class W3IceSpearProjectile extends W3AdvancedProjectile
{
	editable var initFxName 				: name;
	editable var onCollisionFxName 			: name;
	editable var spawnEntityTemplate 		: CEntityTemplate;
	editable var customDuration				: float;
	editable var onCollisionVictimFxName	: name;
	editable var immediatelyStopVictimFX	: bool;
	
	private var projectileHitGround : bool;
	
	default projDMG = 40.f;
	default projEfect = EET_SlowdownFrost;
	default customDuration = 2.0;
		

	event OnProjectileInit()
	{
		this.PlayEffect(initFxName);
		projectileHitGround = false;
		isActive = true;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		if ( !isActive )
		{
			return true;
		}
		
		if ( collidingComponent )
			victim = ( CGameplayEntity )collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
		
		if ( victim && !projectileHitGround && !collidedEntities.Contains( victim ) )
		{
			VictimCollision();
		}
		else if ( !victim && !ignore ) 
		{
			ProjectileHitGround();
		}
	}
	
	protected function DestroyRequest()
	{
		StopEffect( initFxName );
		PlayEffect( onCollisionFxName );
		DestroyAfter( 2.f );
	}
	
	protected function PlayCollisionEffect()
	{
		PlayEffect(onCollisionFxName);
	}
	
	protected function VictimCollision()
	{
		DealDamageToVictim();
		PlayCollisionEffect();
		DeactivateProjectile();
	}
	
	protected function DealDamageToVictim()
	{
		var targetSlowdown 	: CActor;		
		var action : W3DamageAction;
		
		action = new W3DamageAction in this;
		action.Initialize( ( CGameplayEntity)caster, victim, this, caster.GetName(), EHRT_Light, CPS_SpellPower, false, true, false, false );
		action.AddDamage( theGame.params.DAMAGE_NAME_FROST , projDMG );
		
		if ( projEfect != EET_Undefined )
		{
			if ( customDuration > 0 )
				action.AddEffectInfo( projEfect, customDuration );
			else
				action.AddEffectInfo( projEfect );
		}
		
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;	
		
		if ( IsNameValid( onCollisionVictimFxName ) )
			victim.PlayEffect( onCollisionVictimFxName );
		if ( immediatelyStopVictimFX )
			victim.StopEffect( onCollisionVictimFxName );
	}
	
	protected function DeactivateProjectile()
	{
		isActive = false;
		this.StopEffect( initFxName );
		this.DestroyAfter( 5.f );
	}
	
	protected function ProjectileHitGround()
	{
		var ent : CEntity;
		var damageAreaEntity : CDamageAreaEntity;
		
		this.PlayEffect( onCollisionFxName );
		if ( spawnEntityTemplate )
		{
			
			ent = theGame.CreateEntity( spawnEntityTemplate, this.GetWorldPosition(), this.GetWorldRotation() );
			damageAreaEntity = (CDamageAreaEntity)ent;
			if ( damageAreaEntity )
			{
				damageAreaEntity.owner = (CActor)caster;
				this.StopEffect( initFxName );
				projectileHitGround = true;
			}
		}
		DeactivateProjectile();
	}
	
}
	
class W3SpawnMeteor extends W3AdvancedProjectile
{
	editable 	var initFxName 				: name;
	editable 	var onCollisionFxName 		: name;
	editable 	var onCollisionFxName2		: name;
	editable 	var startFxName				: name;
	
	private 	var ent 					: CEntity;
	private		var projectileHitGround 	: bool;
	private 	var playerPos 				: Vector;
	private 	var projPos					: Vector;
	private		var projSpawnPos			: Vector;
	
	
	default projSpeed = 10;
	default projAngle = 0;
	default projDMG = 150.f;
	
	
	event OnProjectileInit()
	{
		var ent : CEntity;
		var spawnEntityTemplate 	: CEntityTemplate;
		this.PlayEffect(initFxName);
		projectileHitGround = false;
		isActive = true;
		
		
	}
	
	
	protected function VictimCollision( victim : CGameplayEntity )
	{
		DealDamageToVictim(victim);
		DeactivateProjectile();
		
	}
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if ( victim && !projectileHitGround && !collidedEntities.Contains(victim) )
		{
			VictimCollision(victim);
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) )
		{
			ProjectileHitGround();
		}
		else if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			ProjectileHitGround();
		}
	}
	
	protected function DeactivateProjectile()
	{
		isActive = false;
		this.StopEffect(initFxName);
		this.DestroyAfter(5.f);
	}
	
	protected function PlayCollisionEffect( optional victim : CGameplayEntity)
	{
		this.PlayEffect(onCollisionFxName);
		this.PlayEffect(onCollisionFxName2);
		
	}
	
	protected function SummonCreatureEvent()
	{
		
	}
	
	function ProjectileHitGround()
	{
		var entities 		: array<CGameplayEntity>;
		var landPos			: Vector;
		var action			: W3DamageAction;
		
		
		
		
		landPos = GetWorldPosition();
		this.PlayCollisionEffect();
		GCameraShake( 3, 5, landPos );
		this.SummonCreatureEvent();
		
		
		FindGameplayEntitiesInSphere( entities, landPos, 5, 1, 'PLAYER');
		victim = (CActor)entities[0];
		
		if( victim )
		{
			action = new W3DamageAction in this;
			action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_None,CPS_AttackPower,false,true,false,false);
			action.AddEffectInfo(EET_Stagger);
			theGame.damageMgr.ProcessAction( action );
			collidedEntities.PushBack(victim);
			isActive = false;
			delete action;
			
		}
		
		DeactivateProjectile();
		
	}
	
	protected function DealDamageToVictim( victim : CGameplayEntity )
	{
		var targetSlowdown 	: CActor;		
		var action : W3DamageAction;		
		action = new W3DamageAction in this;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_SpellPower,false,true,false,false);
		action.AddDamage(theGame.params.DAMAGE_NAME_FROST , projDMG );
		targetSlowdown = (CActor)victim;
		action.AddEffectInfo(EET_HeavyKnockdown);
		
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;	
		
	}
}

class W3AirDrainProjectile extends W3AdvancedProjectile
{
	editable var destructionEntity : CEntityTemplate;
	
	editable var markerEntityTemplate	: CEntityTemplate;
	
	editable var	AirToDrain	: float;
	
	editable var initFxName : name;
	
	editable var onCollisionFxName : name;
	editable var onCollisionFxName2 : name;

	private var markerEntity : CEntity;
	private var projectileHitGround : bool;
	default projSpeed = 10;
	default projAngle = 0;
	
	
	
	
	event OnProjectileInit()
	{
		this.PlayEffect(initFxName);
		projectileHitGround = false;
		isActive = true;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		
		if ( !isActive )
		{
			return true;
		}
		
		if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		if ( victim && !projectileHitGround && !collidedEntities.Contains(victim) )
		{
			VictimCollision(victim);
			return true;
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) )
		{
			DeactivateProjectile(true);
			return true;
		}
		
		return false;
		
		
	}
	
	protected function DeactivateProjectile( optional fast : bool)
	{
		isActive = false;
		this.StopEffect(initFxName);
		
			
		
			
		
		PlayCollisionEffect();
	}
	
	protected function PlayCollisionEffect()
	{
		var animComp : CAnimatedComponent;
		this.PlayEffect(onCollisionFxName);
		this.PlayEffect(onCollisionFxName2);
		animComp = (CAnimatedComponent)GetComponentByClassName('CAnimatedComponent');
		if ( animComp )
		{
			RaiseEvent( 'destroy' );
		}
		else
		{
			
		}
		
	}
	protected function VictimCollision( victim : CGameplayEntity )
	{
		if ( victim == thePlayer)
		{
			thePlayer.DrainAir(AirToDrain, 0);
			GCameraShake( 3, 5, GetWorldPosition() );
		}
		DeactivateProjectile();
		
	}
}

