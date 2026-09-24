/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskLeshyBirdAttack extends CBTTaskSwarm
{
	var loopTime 		: float;
	var attackRange		: float;
	var time 			: float;
	var startingTime	: float;
	var attackGroupID	: CFlyingGroupId;
	var activeSwarm 	: bool;
	var projEntity		: CEntityTemplate;
	var raiseEventName	: name;
	var dodgeable		: bool;

	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		super.OnActivate();
		attackGroupID = lair.GetGroupId( 'shield' );
		if ( lair )
		{
			lair.SignalArrivalAtNode( 'shieldToAttackPlayer', GetCombatTarget(), 'idle', attackGroupID );
		}
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor;
		var loopRes : bool;
		var projectile : W3LeshyRootProjectile;
		
		npc.SetBehaviorVariable( 'AttackEndOverride', 0.0 );
		startingTime = GetLocalTime();
		
		if( npc.RaiseForceEvent( raiseEventName ) )
		{
			npc.WaitForBehaviorNodeDeactivation( 'AttackStartOverride', 10.0f );
		}
		else
		{
			return BTNS_Failed;
		}
		
		while( activeSwarm )
		{
			time = GetLocalTime();
			if( time - startingTime >= loopTime )
			{
				npc.SetBehaviorVariable( 'AttackEndOverride', 1.0 );
				activeSwarm = false;
			}
			Sleep( 0.01f );
		}
		
		npc.WaitForBehaviorNodeDeactivation( 'AttackEndOverride', 2.0 );
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		npc.SetBehaviorVariable( 'AttackEndOverride', 1.0 );
		super.OnDeactivate();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		var npc : CNewNPC = GetNPC();
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if ( animEventName == 'AllowBlend' )
		{
			Complete(true);
			return true;
		}
		
		if ( animEventName == 'BirdProjectile' )
		{
			npc.SetBehaviorVariable( 'BirdFX', 0 );		
			activeSwarm = true;
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
		var projectile : CProjectileTrajectory;
		var distanceToTarget, projectileFlightTime : float;
		
		if( activeSwarm )
		{
			activeSwarm = false;
			projPos = npc.GetWorldPosition() + ( VecFromHeading( npc.GetHeading() )*2.5 );
			projPos.Z += 1.0f;
			projRot = npc.GetWorldRotation();
			projectile = (W3LeshyBirdProjectile)theGame.CreateEntity( projEntity, projPos, projRot );
			projectile.Init( npc );
			projectile.ShootProjectileAtPosition( 0, 8,  npc.GetTarget().GetBoneWorldPosition( 'torso' ), attackRange );
			
			if ( dodgeable )
			{
				distanceToTarget = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );		
				
				
				projectileFlightTime = distanceToTarget / 8;
				target.SignalGameplayEventParamFloat('Time2DodgeProjectile', projectileFlightTime );
			}
			
			time = GetLocalTime();
		}
	}
};

class CBTTaskLeshyBirdAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskLeshyBirdAttack';

	editable var loopTime 	 	: float;
	editable var attackRange 	: float;
	editable var projEntity	 	: CEntityTemplate;
	editable var raiseEventName	: name;
	editable var dodgeable		: bool;
	
	default loopTime = 4.0;
	default attackRange = 10.0;
	default raiseEventName = '3StateAttack';
};