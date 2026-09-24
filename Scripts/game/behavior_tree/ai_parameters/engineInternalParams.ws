/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CAIQuestScriptedActionsTree extends IAITree
{
	default aiTreeName = "resdef:ai\internal\scripted_actions";
};

import class CAIDespawnTree extends IAIActionTree
{
	default aiTreeName = "resdef:ai\internal\despawn";
};
