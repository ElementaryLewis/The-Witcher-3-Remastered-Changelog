/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskLeshyRootAttack extends CBTTaskAttack
{
	public var loopTime 				: float;
	public var attackRange				: float;
	public var dodgeable				: float;
	public var projEntity				: CEntityTemplate;

	private var collisionGroups 		: array<name>;


	function Initialize()
	{
		collisionGroups.PushBack('Ragdoll');
		collisionGroups.PushBack('Terrain');
		collisionGroups.PushBack('Static');
		collisionGroups.PushBack('Water');
	}

	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor;
		var loopRes : bool;
		var projectile : W3LeshyRootProjectile;

		npc.SetBehaviorVariable( 'AttackEnd', 0.0 );

		if( npc.RaiseForceEvent( '3StateAttack' ) )
		{
			npc.WaitForBehaviorNodeDeactivation( 'AttackStart', 10.0f );
		}
		else
		{
			return BTNS_Failed;
		}
		
		
		loopRes = Loop();

		npc.SetBehaviorVariable( 'AttackEnd', 1.0 );

		npc.WaitForBehaviorNodeDeactivation('AttackEnd', 3.0 );

		return BTNS_Completed;
	}

	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		ChooseAnim();
		npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
		super.OnDeactivate();
	}

	latent function Loop() : bool
	{
		GetNPC().WaitForBehaviorNodeDeactivation('AttackLoopEnd',loopTime);
		return false;
	}

	function ChooseAnim()
	{
		return;
	}

	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;

		res = super.OnAnimEvent(animEventName,animEventType, animInfo);

		if ( animEventName == 'AllowBlend' )
		{
			Complete(true);
			return true;
		}

		if ( animEventName == 'RootProjectile' )
		{
			ShootProjectile();
			return true;
		}

		return res;
	}

	function ShootProjectile()
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var projRot : EulerAngles;
		var projPos, targetPos : Vector;
		var projectile : W3LeshyRootProjectile;
		var distanceToTarget, projectileFlightTime : float;

		projPos = npc.GetWorldPosition() + ( VecFromHeading( npc.GetHeading() )*3.0 );
		projPos.Z += 1.5f;
		projRot = npc.GetWorldRotation();
		projectile = (W3LeshyRootProjectile)theGame.CreateEntity( projEntity, projPos, projRot );
		projectile.Init( npc );

		targetPos = target.GetWorldPosition();

		distanceToTarget = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );
		if ( distanceToTarget < attackRange )
			attackRange = distanceToTarget;

		projectile.ShootProjectileAtPosition( 0, 20,  targetPos, attackRange );

		if ( dodgeable )
		{
			distanceToTarget = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );

			
			projectileFlightTime = distanceToTarget / 20;
			target.SignalGameplayEventParamFloat('Time2DodgeBomb', projectileFlightTime );
		}

		projectile.PlayEffect( 'ground_fx' );
	}
}

class CBTTaskLeshyRootAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskLeshyRootAttack';

	editable var loopTime 	 				: float;
	editable var attackRange 				: float;
	editable var dodgeable					: float;
	editable var projEntity	 				: CEntityTemplate;

	default loopTime = 4.0;
	default attackRange = 10.0;
}