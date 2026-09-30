/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3KnifeProjectile extends W3AdvancedProjectile
{
	editable var damageTypeName : name;
	editable var initFxName : name;
	editable var onCollisionFxName : name;
	editable var applyDebuffIfNoDmgWasDealt : bool;
	editable var spawnEntityTemplate 	: CEntityTemplate;
	
	
	event OnProjectileInit()
	{
		
		damageTypeName = theGame.params.DAMAGE_NAME_PIERCING;
		isActive = true;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var action : W3DamageAction;
		
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
			this.DestroyAfter(1.f);
			this.SetHideInGame(true);
			this.StopEffect( initFxName );
			this.PlayEffect(onCollisionFxName);
			 
			
			
			action = new W3DamageAction in this;
			action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_AttackPower, false, true, false, false);
			if ( this.projDMG > 0 )
			{
				action.AddDamage(damageTypeName, projDMG );
			}
			action.AddEffectInfo(this.projEfect);
			action.SetCanPlayHitParticle(false);
			action.SetProcessBuffsIfNoDamage(applyDebuffIfNoDmgWasDealt);
			theGame.damageMgr.ProcessAction( action );
			delete action;
			
			collidedEntities.PushBack(victim);
			ProjectileHitGround();
			isActive = false;
		}
		else if ( !victim )
		{
			this.StopProjectile();
			this.DestroyAfter(1.f);
			this.SetHideInGame(true);
			this.StopEffect( initFxName );
			this.PlayEffect(onCollisionFxName);
			ProjectileHitGround();
			isActive = false;
		}
		return false;
	}
	
	event OnRangeReached()
	{
		isActive = false;
		this.SetHideInGame(true);
		this.StopEffect( initFxName );
		this.DestroyAfter(1.f);
	}
	
	protected function ProjectileHitGround()
	{
		SpawnEntity( true );
	}
	
	function SpawnEntity( onGround : bool )
	{
		var ent : CEntity;
		var entPos, normal : Vector;
		
		if ( spawnEntityTemplate )
		{
			entPos = this.GetWorldPosition();
			if ( onGround )
				theGame.GetWorld().StaticTrace( entPos + Vector(0,0,3), entPos - Vector(0,0,3), entPos, normal );
			ent = theGame.CreateEntity( spawnEntityTemplate, entPos + Vector(0,-0.5f,1.5f), this.GetWorldRotation() );
		}
	}
}