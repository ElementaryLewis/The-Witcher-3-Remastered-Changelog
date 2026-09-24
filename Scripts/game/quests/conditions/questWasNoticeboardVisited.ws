/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_WasNoticeboardVisited extends CQuestScriptedCondition
{
	editable var entityName : name;
	
	function Evaluate() : bool
	{
		var board : W3NoticeBoard;
		
		if ( !IsNameValid( entityName ) )
		{
			return false;
		}
		board = (W3NoticeBoard)theGame.GetEntityByTag( entityName );
		if ( !board )
		{
			return false;
		}
		return board.WasVisited();
	}
}