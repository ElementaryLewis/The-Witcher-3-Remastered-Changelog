/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskManageFact extends IBehTreeTask
{
	var fact		: string;
	var value		: int;
	var validFor	: int;
	var add			: bool;
	var doNotCompleteAfter : bool;
	var onActivate 	: bool;
	var onAnimEvent : bool;
	var eventName	: name;
	
	hint add = "false - remove fact";
	
	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			if( add )
			{
				FactsAdd( fact, value, validFor );
			}
			else
			{
				FactsRemove( fact );
			}
			
			if ( doNotCompleteAfter )
				return BTNS_Active;
				
			return BTNS_Completed;
		}
		else return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( onAnimEvent && animEventName == eventName )
		{
			if( add )
			{
				FactsAdd( fact, value, validFor );
			}
			else
			{
				FactsRemove( fact );
			}
			return true;
		}
		else return false;
		
	}
}

class CBTTaskManageFactDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskManageFact';

	editable var fact		: string;
	editable var value		: int;
	editable var add		: bool;
	editable var validFor	: int;
	editable var doNotCompleteAfter : bool;
	editable var onActivate 	: bool;
	editable var onAnimEvent 	: bool;
	editable var eventName		: name;
	
	default onActivate = true;
	default add = true;
	default doNotCompleteAfter = false;
}