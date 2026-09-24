/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CMoveSCScriptedCondition extends IMoveSteeringCondition
{
};



class CMoveSCPlayerIsRunning extends CMoveSCScriptedCondition
{
	function GetConditionName( out caption : string )
	{
		caption = "PlayerIsRunning";
	}

	
	function Evaluate( agent : CMovingAgentComponent, goal : SMoveLocomotionGoal ) : bool
	{
		var entity : CEntity = agent.GetEntity();
		var player : CPlayer;
	
		player = (CPlayer)entity;
		
		if( player )
		{
			return player.GetIsSprinting();
		}
		
		return false;
	}
};


class CMoveSCPlayerIsStrafing extends CMoveSCScriptedCondition
{
	function GetConditionName( out caption : string )
	{
		caption = "PlayerIsStrafing";
	}

	
	function Evaluate( agent : CMovingAgentComponent, goal : SMoveLocomotionGoal ) : bool
	{
		var entity : CEntity = agent.GetEntity();
		var player : CR4Player;
	
		player = (CR4Player)entity;
		
		if( player )
		{
			switch( player.GetOrientationTarget() )
			{
				case OT_Player :	
				{
					return false;
				}
				case OT_Actor :
				{
					return true;
				}
				case OT_CustomHeading :
				{
					return true;
				}
				default:
				{
					return false;
				}
			}
		}
		
		return false;
	}
};

class CMoveSCIsSmallCreature extends CMoveSCScriptedCondition
{
	function GetConditionName( out caption : string )
	{
		caption = "Is small creature";
	}
	
	function Evaluate( agent : CMovingAgentComponent, goal : SMoveLocomotionGoal ) : bool
	{
		var radius : float;
		radius = ((CMovingPhysicalAgentComponent) agent).GetCapsuleRadius();
		
		if( radius < 0.3f )
		{
			return true;
		}
		
		return false;
	}
};

