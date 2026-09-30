/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskActionFail extends CBTTaskPlayAnimationEventDecorator
{
	var failedActionType : EActionFail;
	default failedActionType = EAF_ActionFail1;

	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( npc )
		{
			npc.SetBehaviorVariable( 'FailedAction', (int)failedActionType );
		}
		else
		{
			BTNS_Failed;
		}
		return super.OnActivate();
	}
}

class CBTTaskActionFailDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskActionFail';

	editable var failedActionType : EActionFail;

	default failedActionType = EAF_ActionFail1;
}