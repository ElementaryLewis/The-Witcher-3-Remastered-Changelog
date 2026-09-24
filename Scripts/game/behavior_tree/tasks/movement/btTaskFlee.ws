/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CMoveTRGActorFlee extends CMoveTRGScript
{
	public var dangerNode : CNode;
	public var distance : float;
	public var pursue : bool;
	
	default pursue = false;
	
	
	function UpdateChannels( out goal : SMoveLocomotionGoal )
	{
		var newHeading : Vector;
		
		if( VecDistance( ((CActor)dangerNode).GetBoneWorldPosition('pelvis'), agent.GetWorldPosition() ) > distance )
		{
			SetFulfilled( goal, true );
			return;
		}
		else
		{
			SetFulfilled( goal, false );
		}
		
		if ( pursue )
		{
			newHeading = Pursue( ((CActor)dangerNode).GetMovingAgentComponent() );
		}
		else
		{
			newHeading = Flee( ((CActor)dangerNode).GetBoneWorldPosition('pelvis') );
		}
		
		
		SetSpeedGoal( goal, 1.0f );
		SetHeadingGoal( goal, newHeading );
		SetOrientationGoal( goal, VecHeading( newHeading ) );
	}
};

class CBehTreeActorTaskRunFromDanger extends IBehTreeTask
{
	public var dangerRadius, fleeDistance : float;
	
	private var dangerNode : CNode;
	
	var pursue : bool;
	
	function IsAvailable() : bool
	{
		if( VecDistance( thePlayer.GetBoneWorldPosition('pelvis'), GetActor().GetWorldPosition() ) < dangerRadius )
		{
			dangerNode = thePlayer;
			return true;
		}
		
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		var targeter : CMoveTRGActorFlee;
		
		targeter = new CMoveTRGActorFlee in owner;
		targeter.dangerNode = dangerNode;
		targeter.distance = fleeDistance;
		targeter.pursue = pursue;
		
		owner.ActionMoveCustom( targeter );
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		GetActor().ActionCancelAll();
	}
};


class CBehTreeActorTaskRunFromDangerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeActorTaskRunFromDanger';

	editable var dangerRadius : float;
	editable var fleeDistance : float;
	editable var pursue : bool;
	
	default pursue = false;
};