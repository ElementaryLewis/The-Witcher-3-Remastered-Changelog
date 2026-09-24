/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_WasMeditating_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_WasMeditating;
	
	event OnGlobalEventString( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : string )
	{
		if ( condition && condition.factsNames.FindFirst( eventParam ) != -1 )
		{
			condition.EvaluateImpl();		
		}	
	}	
}

class W3QuestCond_WasMeditating extends CQuestScriptedCondition
{
	editable var hours : int;
	editable var comparator : ECompareOp;
	editable var dayPart : EDayPart;
	editable var meditateToHour : bool;
	editable var immediateTest : bool;
	
		hint meditateToHour="If set then waits until hour X rather than for X hours";
		hint dayPart="Waits till given day part instead of hour";
		hint comparator = "Used ONLY when meditating for X hours";
		hint immediateTest = "If set then pause triggers imediately instead of after panel close";
		
		default comparator = CO_Equal;

	saved var isFulfilled	: bool;
	var listener			: W3QuestCond_WasMeditating_Listener;
	
	var factsNames			: array< string >;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_WasMeditating_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterStringArray( GEC_Fact, listener, factsNames );
			EvaluateImpl();
		}
		else
		{		
			theGame.GetGlobalEventsManager().RemoveListenerFilterStringArray( GEC_Fact, listener, factsNames );
			delete listener;
			listener = NULL;		
		}
	}
	
	function Activate()
	{
		factsNames.Clear();
		factsNames.PushBack( "MeditationWaitFinished" );
		factsNames.PushBack( "MeditationWaitStartDay" );
		factsNames.PushBack( "MeditationWaitStartHour" );
		factsNames.PushBack( "MeditationStarted" );

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
		var startDay, startHour, currentDay, currentHour, targetDay, targetHour, waitHours : int;
		var currentTime : GameTime;
		var meditateTo : bool;
		
		if ( isFulfilled )
		{
			return;
		}
		
		
		if(immediateTest)
		{
			if(FactsQuerySum( "MeditationStarted" ) <= 0)
				return;
		}
		else
		{
			if(FactsQuerySum( "MeditationWaitFinished" ) <= 0)
				return;
		}
	
		startDay = FactsQuerySum( "MeditationWaitStartDay" );
		startHour = FactsQuerySum( "MeditationWaitStartHour" );		
		currentTime = theGame.GetGameTime();
		currentHour = GameTimeHours(currentTime);
		currentDay = GameTimeDays(currentTime);
			
		if(!meditateToHour || dayPart != EDP_Undefined)
		{
			if(dayPart != EDP_Undefined)
				waitHours = GetHourForDayPart(dayPart);
			else
				waitHours = hours;
			
			targetDay = startDay;
			if(startHour + waitHours > 23)
				targetDay += 1;
				
			targetHour = (startHour + waitHours ) % 24;
			
			meditateTo = false;
		}
		else			
		{
			targetDay = startDay;
			targetHour = hours;
			
			if(hours <= startHour)
				targetDay += 1;
				
			meditateTo = true;
		}
		
		if(meditateTo)
		{
			if (currentDay == targetDay && currentHour == targetHour)
				isFulfilled = true;
		}
		else
		{
			if(comparator == CO_Equal)
			{
				isFulfilled = (currentDay == targetDay && currentHour == targetHour);
			}
			else if(comparator == CO_Lesser)
			{
				isFulfilled = ((currentDay == targetDay && currentHour < targetHour) || currentDay < targetDay);
			}
			else if(comparator == CO_LesserEq)
			{
				isFulfilled = ((currentDay == targetDay && currentHour <= targetHour) || currentDay < targetDay);
			}
			else if(comparator == CO_Greater)
			{
				isFulfilled = ((currentDay == targetDay && currentHour > targetHour) || currentDay > targetDay);
			}
			else if(comparator == CO_GreaterEq)
			{
				isFulfilled = ((currentDay == targetDay && currentHour >= targetHour) || currentDay > targetDay);
			}			
		}
	}
}