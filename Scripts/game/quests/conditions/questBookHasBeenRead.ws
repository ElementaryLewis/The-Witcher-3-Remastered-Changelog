/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_BookHasBeenRead_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_BookHasBeenRead;
	
	event OnGlobalEventString( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : string )
	{
		if ( condition && eventParam == condition.bookFactName )
		{
			condition.EvaluateImpl();		
		}	
	}	
}

class W3QuestCond_BookHasBeenRead_Listener_Ext extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_BookHasBeenReadExt;
	
	event OnGlobalEventString( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : string )
	{
		if ( condition && eventParam == condition.bookFactName )
		{
			condition.EvaluateImpl();		
		}	
	}	
}

class W3QuestCond_BookHasBeenRead extends CQuestScriptedCondition
{
	editable var bookName 	: name;
	var bookFactName 		: string;	
	var isFulfilled			: bool;	
	var listener 			: W3QuestCond_BookHasBeenRead_Listener;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_BookHasBeenRead_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterString( GEC_Fact, listener, bookFactName );
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterString( GEC_Fact, listener, bookFactName );
			delete listener;
			listener = NULL;		
		}
	}

	function Activate()
	{
		bookFactName = "";
		EvaluateImpl();
		if ( !isFulfilled )
		{
			RegisterListener( true );
		}
	}
	
	function Deactivate()
	{
		if ( listener )
		{
			RegisterListener( false );
		}
	}
	
	function Evaluate() : bool
	{
		if ( !isFulfilled && !listener )
		{
			RegisterListener( true );
		}	
		return isFulfilled;
	}
	
	public function EvaluateImpl()
	{
		isFulfilled = false;
		if ( bookFactName == "" )
		{
			if(  IsNameValid( bookName ) )
			{
				bookFactName = GetBookReadFactName( bookName );
			}
			else
			{
				LogQuest( "W3QuestCond_BookHasBeenRead: invalid book bame <<" + bookName + ">>" );
			}
		}
		if ( bookFactName != "" )
		{		
			if( FactsDoesExist( bookFactName ) )
			{	
				isFulfilled = FactsQuerySum( bookFactName );
			}
		}
	}
}


class W3QuestCond_BookHasBeenReadExt extends CQuestScriptedCondition
{
	editable var bookName 	: SItemNameProperty;
	var bookFactName 		: string;	
	var isFulfilled			: bool;	
	var listener 			: W3QuestCond_BookHasBeenRead_Listener_Ext;

	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_BookHasBeenRead_Listener_Ext in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterString( GEC_Fact, listener, bookFactName );
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterString( GEC_Fact, listener, bookFactName );
			delete listener;
			listener = NULL;
		}
	}
	
	function Activate()
	{
		bookFactName = "";
		EvaluateImpl();
		if ( !isFulfilled )
		{
			RegisterListener( true );
		}
	}
	
	function Deactivate()
	{
		if ( listener )
		{
			RegisterListener( false );
		}
	}
	
	function Evaluate() : bool
	{
		if ( !isFulfilled && !listener )
		{
			RegisterListener( true );
		}	
		return isFulfilled;
	}
	
	public function EvaluateImpl()
	{
		isFulfilled = false;
		if ( bookFactName == "" )
		{
			if(  IsNameValid( bookName.itemName ) )
			{
				bookFactName = GetBookReadFactName( bookName.itemName );
			}
			else
			{
				LogQuest( "W3QuestCond_BookHasBeenRead: invalid book bame <<" + bookName.itemName + ">>" );
			}
		}
		if ( bookFactName != "" )
		{		
			if( FactsDoesExist( bookFactName ) )
			{	
				isFulfilled = FactsQuerySum( bookFactName );
			}
		}
	}
	
	
}
