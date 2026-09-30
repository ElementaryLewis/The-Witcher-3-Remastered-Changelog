/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTask3StateProjectileAttack extends CBTTask3StateAttack
{
	public var attackRange							: float;
	public var projEntity							: CEntityTemplate;
	public var projectileName	 					: name;
	public var dodgeable							: bool;
	public var useLookatTarget						: bool;
	public var dontShootAboveAngleDistanceToTarget 	: float;
	
	public var projectiles 							: array<W3AdvancedProjectile>;
	private var collisionGroups 					: array<name>;
	
	
	function Initialize()
	{
		collisionGroups.PushBack('Ragdoll');
		collisionGroups.PushBack('Terrain');
		collisionGroups.PushBack('Static');
		collisionGroups.PushBack('Water');
	}
	
	latent function Main() : EBTNodeStatus
	{
		var res : EBTNodeStatus;
		if ( !projEntity )
		{
			projEntity = (CEntityTemplate)LoadResourceAsync( projectileName );
		}
		
		if ( !projEntity )
		{
			return BTNS_Failed;
		}
		
		res = super.Main();
		
		return res;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		if ( animEventName == 'ShootProjectile' )
		{
			ShootProjectile();
			return true;
		}
		else if ( animEventName == 'Shoot3Projectiles' )
		{
			ShootProjectile();
			ShootProjectile(GetActor().GetHeading()+5);
			ShootProjectile(GetActor().GetHeading()-5);
			return true;
		}
		else if ( animEventName == 'Shoot5Projectiles' )
		{
			ShootProjectile();
			ShootProjectile(GetActor().GetHeading()+5);
			ShootProjectile(GetActor().GetHeading()-5);
			ShootProjectile(GetActor().GetHeading()+10);
			ShootProjectile(GetActor().GetHeading()-10);
			return true;
		}
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		return res;
	}
	
	function ShootProjectile(optional customHeading : float)
	{
		var npc : CNewNPC = GetNPC();
		var projRot : EulerAngles;
		var projPos, targetPos : Vector;
		var projectile : W3AdvancedProjectile;
		var distanceToTarget : float;
		var projectileFlightTime : float;
		var target : CActor = GetCombatTarget();
		
		var projOriginMat : Matrix;
		
		
		if ( dontShootAboveAngleDistanceToTarget > 0 && AbsF( NodeToNodeAngleDistance( target, npc ) ) > dontShootAboveAngleDistanceToTarget )
		{
			return;
		}
		
		if ( npc.CalcEntitySlotMatrix( 'projectile_origin', projOriginMat ) )
		{
			projPos	= MatrixGetTranslation( projOriginMat );
		}
		else
		{
			projPos = npc.GetWorldPosition();
			projPos.Z += 1.5f;
		}
		
		projRot = npc.GetWorldRotation();
		projectile = (W3AdvancedProjectile)theGame.CreateEntity( projEntity, projPos, projRot );
		projectile.Init( npc );
		
		
		if ( useLookatTarget )
		{
			targetPos = npc.GetBehaviorVectorVariable('lookAtTarget');
		}
		else if ( customHeading )
			targetPos = projPos + VecFromHeading(customHeading)*attackRange;
		else
			targetPos = projPos +  npc.GetHeadingVector()*attackRange;
			
		projectile.ShootProjectileAtPosition( 0, projectile.projSpeed, targetPos, attackRange, collisionGroups );
		
		if ( dodgeable )
		{
			distanceToTarget = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );		
			
			
			projectileFlightTime = distanceToTarget / projectile.projSpeed;
			target.SignalGameplayEventParamFloat('Time2DodgeProjectile', projectileFlightTime );
		}
		
		projectiles.PushBack( projectile );
	}
}

class CBTTask3StateProjectileAttackDef extends CBTTask3StateAttackDef
{
	default instanceClass = 'CBTTask3StateProjectileAttack';

	editable var attackRange 							: float;
	
	editable var projectileName	 						: name;
	editable var dodgeable								: bool;
	editable var useLookatTarget						: bool;
	editable var dontShootAboveAngleDistanceToTarget 	: float;
	
	hint projEntity = "!!Obsolete!! - use projectileName instead";
	
	default dodgeable = true;
	default attackRange = 10.0;
}