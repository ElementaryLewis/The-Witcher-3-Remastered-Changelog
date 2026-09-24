/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class CQuestScriptedCondition extends IQuestCondition
{
	function Activate();
	function Deactivate();
	function Evaluate() : bool;
};