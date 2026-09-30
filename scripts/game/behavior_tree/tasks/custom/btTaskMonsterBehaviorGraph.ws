/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeTaskMonsterBehaviorGraph extends IBehTreeTask
{
	var graphName : name;
	var res : bool;
	var owner : CNewNPC;
	
	latent function Main() : EBTNodeStatus
	{
		owner  = GetNPC();
		
		if ( !IsNameValid(graphName) )
		{
			return BTNS_Failed;
		}
		
		res = owner.ActivateAndSyncBehavior( graphName );

		return BTNS_Active;
	}
}

class CBehTreeMonsterBehaviorGraphDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskMonsterBehaviorGraph';

	editable var graphName : name;
}