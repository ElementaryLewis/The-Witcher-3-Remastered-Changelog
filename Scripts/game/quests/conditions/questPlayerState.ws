/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EQuestConditionPlayerState
{
	QCPS_None,
	QCPS_Walking,
	QCPS_Running,
	QCPS_Sprinting,
	QCPS_Swimming,  
	QCPS_Diving,	
	QCPS_Climbing,	
	QCPS_CastingSign,
	QCPS_ParryStance,
	QCPS_Preparation	
}

class W3QuestCond_PlayerState extends CQuestScriptedCondition
{
	
	editable var stateName 	: name;
	default stateName = '';

	editable var playerState 	: EQuestConditionPlayerState;
	editable var inverted		: bool;
	
	default playerState = QCPS_None;
	default inverted = false;
	
	function Evaluate() : bool
	{	
		var condition : bool;
				
		if ( stateName != '' )
		{
			condition = thePlayer.GetCurrentStateName() == stateName;
		}
		else
		{
			condition = CheckCondition();
		}
		
		if ( inverted )
		{
			return !condition;
		}
		return condition;
	}
	
	function CheckCondition() : bool
	{
		if ( playerState == QCPS_Walking ||
			 playerState == QCPS_Running ||
			 playerState == QCPS_Sprinting )
		{
			return playerState == GetWalkState();
		}
		else if ( playerState == QCPS_Swimming || 
				  playerState == QCPS_Diving)
		{
			return playerState == GetSwimState();
		}
		else if ( playerState == QCPS_Climbing )
		{
			if( thePlayer.GetCurrentStateName() == 'TraverseExploration' )
			{
				return true;
			}
			else if( thePlayer.substateManager.GetStateCur() == 'Climb' )
			{
				return true;
			}
			return false;
		}
		else if ( playerState == QCPS_CastingSign)
		{
			return thePlayer.IsCastingSign();
		}
		else if (playerState == QCPS_ParryStance)
		{
			return thePlayer.GetPlayerCombatStance() == PCS_Guarded;
		}
		else if (playerState == QCPS_Preparation)
		{
			return thePlayer.GetCurrentStateName() == 'Meditation';
		}
		
		LogAssert( false, "W3QuestCond_PlayerState: playerState was not set." );
		return false;
	}

	function GetWalkState() : EQuestConditionPlayerState
	{
		if ( thePlayer.substateManager.GetStateCur() == 'Idle' ) 
		{
			if( thePlayer.GetIsSprinting() )
			{
				return QCPS_Sprinting;
			}
			else if ( thePlayer.GetIsRunning() )
			{
				return QCPS_Running;
			}
			else if( VecLengthSquared( thePlayer.GetMovingAgentComponent().GetVelocity() ) > 0.10f )
			{
				return QCPS_Walking;
			}			
		}
		return QCPS_None;
	}
	
	function GetSwimState() : EQuestConditionPlayerState
	{
		var mpac : CMovingPhysicalAgentComponent;
				
		if ( thePlayer.GetCurrentStateName() == 'Swimming' )
		{
			mpac = (CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent();
			if ( mpac.IsDiving() )
			{
				return QCPS_Diving;
			}
			else
			{
				return QCPS_Swimming;			
			}
		}
		return QCPS_None;
	}	
}
