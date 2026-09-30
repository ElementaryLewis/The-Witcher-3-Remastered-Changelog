/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SSignProjectile
{
	
	editable var speed				: float;
	
	editable var flyEffect			: name;
	editable var hitEffect			: name;
	editable var targetHitEffect	: name;
	editable var lastingTime		: float;
}

abstract class W3SignProjectile extends CProjectileTrajectory
{
	editable var projData		: SSignProjectile;
	
	protected var owner			: W3SignOwner;
	protected var action 		: W3DamageAction;
	protected var signSkill 	: ESkill;
	protected var wantedTarget	: CGameplayEntity;
	public var signEntity 	: W3SignEntity;
	default signSkill = S_SUndefined;

	protected var hitEntities 	: array< CGameplayEntity >;
	protected var attackRange 	: CAIAttackRange;
		
	protected var isReusable	: bool; 
	
	protected var isSupercharged : bool; 

	public function ExtInit( signOwner : W3SignOwner, sign : ESkill, signEnt : W3SignEntity, optional reusable : bool )
	{
		Init( signOwner.GetActor() );
		owner = signOwner;
		signEntity = signEnt;
		signSkill = sign;
		isReusable = reusable;
	}
		
	function ShootTarget( target : CNode, distance : float, optional hitOnlyTarget : bool, optional collisionGroups : array<name> )
	{
		var targetPos : Vector;
		
		targetPos = target.GetWorldPosition();
		targetPos.Z += 1;
		
		if ( hitOnlyTarget )
			this.wantedTarget = (CGameplayEntity)target; 
			
		PlayEffect( projData.flyEffect );
		this.ShootProjectileAtPosition(0.f, 55, targetPos, distance, collisionGroups );
	}
		
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var victim : CGameplayEntity;
		var collisionNames : array<name>;
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
			
		
		if ( (signSkill != S_Magic_s02) && (signSkill != S_Magic_s28) && (!victim || !victim.IsAlive()) )
		{
			return false;
		}
		
		if ( wantedTarget && wantedTarget != victim )	
			return false;

		collisionNames.PushBack( 'Terrain' );
		collisionNames.PushBack( 'Static' );
		collisionNames.PushBack( 'Dynamic' );
		collisionNames.PushBack( 'Door' );
		collisionNames.PushBack( 'Destructible' );
		if( this.IsBehindWall( collidingComponent, collisionNames ) )
		{
			return false;
		}
		
		
		if ( (CActor)victim && ShouldCheckAttitude() )
		{
			
			if( !IsRequiredAttitudeBetween(victim, caster, true, true) )
			{
				return false;
			}
		}
		
		
		
		
		{
			LogChannel( 'Signs', "SignProjectile.OnProjectileCollision: <<" + this + ">> will process collision with <<" + victim + ">>");
			
			ProcessCollision( victim, pos, normal );
			delete action;	

			
			if( projData.hitEffect != projData.flyEffect )
			{
				StopEffect( projData.flyEffect );
				PlayEffect( projData.hitEffect );
			}		
			
			
			DestroyAfter( projData.lastingTime );
		}
		
	}
	
	public function SetAttackRange( ar : CAIAttackRange )
	{
		attackRange = ar;		
	}
	
	public function GetSignEntity() : W3SignEntity
	{
		return signEntity;
	}
	
	protected function ShouldCheckAttitude() : bool
	{
		return true;
	}
	
	public function GetOwner() : W3SignOwner
	{
		return owner;
	}
	
	function ProcessAttackRange()
	{
		var i, size  	: int;
		var entities 	: array< CGameplayEntity >;
		var e		 	: CGameplayEntity;
		var pos, entPos	: Vector;

		if ( !attackRange )
		{
			return;
		}

		attackRange.GatherEntities( signEntity, entities );
		entities.Remove( owner.GetActor() );
		size = entities.Size();
		pos = GetWorldPosition();
		for( i = 0; i < size; i += 1 )
		{
			e = entities[i];
			
			if(hitEntities.Contains(e))			
				continue;
			
			
			if ( (CActor)e )
			{
				
				if( !IsRequiredAttitudeBetween(e, caster, true, true) )
				{
					continue;
				}
			}
			
			
			if( (W3SignProjectile)e || (W3IgniEntity)e )
				continue;
			
			
			if( (W3AardProjectile)this && (W3Boat)e )
				continue;
			
			entPos = e.GetWorldPosition();
			ProcessCollision( e, entPos, entPos - pos );
		}	
	}
	
	event OnAttackRangeHit( entity : CGameplayEntity )
	{	
	}
	
	event OnRangeReached()
	{
		ProcessAttackRange();
		StopAllEffects();
		StopProjectile();
		hitEntities.Clear();
		if ( !isReusable )
		{
			Destroy();
		}
	}
		
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var gameplayEnt : CGameplayEntity;
		
		gameplayEnt = (CGameplayEntity)caster;
	
		if ( gameplayEnt )
		{		
			action =  new W3DamageAction in theGame.damageMgr;
			action.Initialize( gameplayEnt, collider, this, caster.GetName()+"_sign", EHRT_Light, CPS_SpellPower, false, false, true, false);
			signEntity.InitSignDataForDamageAction(action);
			action.hitLocation = pos;
			action.SetHitEffect( projData.targetHitEffect );
			action.SetHitEffect( projData.targetHitEffect, true );
			action.SetHitEffect( projData.targetHitEffect, false, true);
			action.SetHitEffect( projData.targetHitEffect, true, true);
		}
		else if ( collider )
		{
			collider.PlayEffect( projData.targetHitEffect );
		}
	}
		
	public function ClearHitEntities()
	{
		hitEntities.Clear();
	}
		
	public function GetSignSkill() : ESkill
	{
		return signSkill;
	}
	
	public function GetCaster() : CEntity
	{
		return caster;
	}
}