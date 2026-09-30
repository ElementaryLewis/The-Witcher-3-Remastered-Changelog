/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_playerKnowsRecipe_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_playerKnowsRecipe;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition )
		{
			condition.EvaluateImpl();
		}	
	}
}

class W3QuestCond_playerKnowsRecipe extends CQuestScriptedCondition
{
	editable var recipeName : name;
	var isFulfilled			: bool;
	var listener			: W3QuestCond_playerKnowsRecipe_Listener;
		
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_playerKnowsRecipe_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_AlchemyRecipe ), listener );
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListener( GetGlobalEventCategory( SEC_AlchemyRecipe ), listener );
			delete listener;
			listener = NULL;		
		}
	}

	function Activate()
	{
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
		
	function EvaluateImpl()
	{
		var alchemyRecipes		: array<name>;
		var i					: int;
		var	player				: W3PlayerWitcher;
		
		player = (W3PlayerWitcher)thePlayer;		
		if ( player )
		{
			alchemyRecipes = player.GetAlchemyRecipes();
			for ( i=0; i < alchemyRecipes.Size(); i+=1 )
			{
				if ( recipeName == alchemyRecipes[i] )
				{
					isFulfilled = true;
					return;
				}
			}
		}
		
		isFulfilled = false;
	}
}