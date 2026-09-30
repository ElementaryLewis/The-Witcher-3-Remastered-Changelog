/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskLeshyStageMonitor extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		var combatStage : ENPCFightStage;
		
		combatStage = owner.GetCurrentFightStage();
		
		while ( true )
		{
			if ( NoMinionCheck() && owner.GetStatPercents( BCS_Essence ) > 0.2 )
			{
				owner.ChangeFightStage( NFS_Stage1 );
				
			}
			else
			{
				owner.ChangeFightStage( NFS_Stage2 );
				
			}
			Sleep(2.0);
		}
		return BTNS_Active;
	}
	
	function NoMinionCheck() : bool
	{
		var npc : CNewNPC = GetNPC();
		var i : int;
		var minion : CEntity;
		var minions : array< CNode >;
		
		
		
		theGame.GetNodesByTag( 'leshy_minion', minions );
		for ( i = 0 ; i < minions.Size() ; i += 1 )
		{
			if ( VecDistance( npc.GetWorldPosition(), minions[i].GetWorldPosition() ) < 50 )
			{
				return true;
			}
		}
		return false;
	}
};

class CBTTaskLeshyStageMonitorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskLeshyStageMonitor';
};






class CBTCondLeshyStage extends IBehTreeTask
{
	var activeInStage 				: ENPCFightStage;
	var equalHigherThanStage		: bool;
	
	function IsAvailable() 	: bool
	{
		var npc : CNewNPC = GetNPC();
		var combatStage : int;
		
		combatStage = (int)npc.GetCurrentFightStage();
		
		if ( equalHigherThanStage && combatStage >= (int)activeInStage )
		{
			return true;
		}
		else if ( combatStage == (int)activeInStage )
		{
			return true;
		}
		return false;
	}
};

class CBTCondLeshyStageDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondLeshyStage';

	editable	var equalHigherThanStage	: bool;
	editable	var activeInStage 			: ENPCFightStage;
	
	default activeInStage = NFS_Stage1;
	default equalHigherThanStage = false;
};