/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3LeshyRootProjectile extends CProjectileTrajectory
{
	editable var fxEntityTemplate 	: CEntityTemplate;
	protected var fxEntity 			: CEntity;
	
	
	private var action 				: W3Action_Attack;
	
	protected var owner 				: CActor;
	protected var projPos 			: Vector;
	protected var projRot 			: EulerAngles;
	protected var projExpired 		: bool;
	var collisions 					: int;
	
	default projExpired = false;
	default collisions = 0;
	
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
				DelayDamage( 0.3 );
				AddTimer('TimeDestroy', 5.0, false);
				projExpired = true;
			}
		}
		delete action;
	}
	
	function DelayDamage( time : float )
	{
		AddTimer('DelayDamageTimer',time,false);
	}
	
	timer function DelayDamageTimer( delta : float , id : int)
	{
		var attributeName 	: name;
		var victims 		: array<CGameplayEntity>;
		var rootDmg 		: float;
		var i 				: int;
		
		attributeName = GetBasicAttackDamageAttributeName(theGame.params.ATTACK_NAME_HEAVY, theGame.params.DAMAGE_NAME_PHYSICAL);
		rootDmg = CalculateAttributeValue(((CActor)caster).GetAttributeValue(attributeName));
		
		
		action = new W3Action_Attack in theGame.damageMgr;
		
		
		FindGameplayEntitiesInRange( victims, fxEntity, 2, 99, , FLAG_OnlyAliveActors );
		
		if ( victims.Size() > 0 )
		{
			for ( i = 0 ; i < victims.Size() ; i += 1 )
			{
				if ( !((CActor)victims[i]).IsCurrentlyDodging() )
				{
					
					action.Init( (CGameplayEntity)caster, victims[i], NULL, ((CGameplayEntity)caster).GetInventory().GetItemFromSlot( 'r_weapon' ), 'attack_heavy', ((CGameplayEntity)caster).GetName(), EHRT_Heavy, false, true, 'attack_heavy', AST_Jab, ASD_DownUp, false, false, false, true );
					theGame.damageMgr.ProcessAction( action );
					
					
					victims[i].OnRootHit();
				}
			}
		}
		
		delete action;
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
			AddTimer('TimeDestroy', 5.0, false);
		}
	}
	
	function Expired() : bool
	{
		return projExpired;
	}
	
	timer function TimeDestroy( deltaTime : float, id : int )
	{
		Destroy();
	}
}

class W3LeshyBirdProjectile extends CProjectileTrajectory
{
	editable var fxEntityTemplate : CEntityTemplate;
	private var fxEntity : CEntity;
	private var action : W3DamageAction;
	private var owner : CActor;
	private var projPos : Vector;
	private var projRot : EulerAngles;
	private var projExpired : bool;
	
	default projExpired = false;
	
	function SetOwner( actor : CActor )
	{
		owner = actor;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var victim : CGameplayEntity;
		var birdDmg : float;
		var attributeName : name;
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		if ( victim && victim == ((CActor)caster).GetTarget() )
		{
			projExpired = true;
			attributeName = GetBasicAttackDamageAttributeName(theGame.params.ATTACK_NAME_LIGHT, theGame.params.DAMAGE_NAME_PHYSICAL);
			birdDmg = CalculateAttributeValue(((CActor)caster).GetAttributeValue(attributeName));
			
			action = new W3DamageAction in this;			
			action.Initialize(owner, victim, this, caster.GetName()+"_"+"root_projectile", EHRT_None, CPS_AttackPower,false,false,false,true);
			action.SetHitAnimationPlayType(EAHA_ForceYes);
			action.AddDamage(theGame.params.DAMAGE_NAME_RENDING, birdDmg );
			theGame.damageMgr.ProcessAction( action );
			
			AddTimer('TimeDestroy', 5.0, false);
		}
		delete action;
	}
	
	event OnRangeReached()
	{
		StopAllEffects();
		StopProjectile();
		
		if( !projExpired )
		{
			AddTimer('TimeDestroy', 5.0, false);
		}
	}
	
	function Expired() : bool
	{
		return projExpired;
	}
	
	timer function TimeDestroy( deltaTime : float, id : int )
	{
		Destroy();
	}
}