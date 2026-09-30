/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4LocomotionSwimToStop extends CR4LocomotionDirectControllerScript
{
	var player 		: CR4Player;
	var targetPoint	: Vector;
	var closeEnough	: bool;
	
	
	function Activate() : bool
	{
		var exploration : SExplorationQueryToken;
		
		player		= (CR4Player)agent.GetEntity();
		
		
		exploration	= thePlayer.substateManager.m_SharedDataO.GetLastExploration();
		targetPoint	= exploration.pointOnEdge;
		
		
		closeEnough	= false;
		
		
		return super.Activate();
	}

	function Deactivate()
	{
		player.UpdateRequestedDirectionVariables_PlayerDefault();
		
		super.Deactivate();
	}
	
	function UpdateLocomotion()
	{
		var direction		: Vector;
		var directionYaw	: float;
		
		
		
		
		
		direction		= targetPoint - player.GetWorldPosition();
		directionYaw	= VecHeading( direction );
		directionYaw	= AngleNormalize180( AngleDistance( player.GetHeading(), directionYaw ) );
		directionYaw	= ClampF( directionYaw, -90.0f, 90.0f ) / 90.0f;
		closeEnough		= AbsF( directionYaw ) < 0.3f;
		
		player.GetMovingAgentComponent().ResetMoveRequests();
		
		
	}
	
	public function GetIsCloseEnough() : bool
	{
		return closeEnough;
	}
};
