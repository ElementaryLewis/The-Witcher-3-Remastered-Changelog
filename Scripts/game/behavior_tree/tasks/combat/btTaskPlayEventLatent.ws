/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskPlayEventLatent extends IBehTreeTask
{
	var nodeDeactivationName 	: name;
	var playEventName			: name;
	var eventIsForced			: bool;
	var setVariable				: bool;
	var variableName			: name;
	var variableValue			: float;
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();	
		var eventFired : bool;
		var eventCompleted : bool;
		
		eventFired = false;
		
		if( eventIsForced &&  npc.RaiseForceEvent( playEventName ) )
		{
			eventFired = true;
		}
		else if( npc.RaiseEvent( playEventName ) )
		{
			eventFired = true;
		}
		else if( setVariable && npc.SetBehaviorVariable(variableName, variableValue) )
		{
			eventFired = true;
		}
	
		if ( eventFired )
		{
			Sleep( 0.1f );
			eventCompleted = npc.WaitForBehaviorNodeDeactivation( nodeDeactivationName, 10.0f );
			if( eventCompleted )
			{
				npc.SetBehaviorVariable( variableName, 0.0f );
				return BTNS_Completed;
				
			}
			else
			{
				return BTNS_Failed;
			}
		}
		else
		{
			return BTNS_Failed;
		}
	}	
}
class CBTTaskPlayEventLatentDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPlayEventLatent';

	editable var nodeDeactivationName 	: name;
	editable var playEventName			: name;
	editable var eventIsForced			: bool;
	editable var setVariable			: bool;
	editable var variableName			: name;
	editable var variableValue			: float;
	
	default variableName = 'PerformAttack';
	default variableValue = 1.0;
	default nodeDeactivationName = 'AttackEnd';
	default playEventName = 'Attack';
	default eventIsForced = false;
	
	hint setVariable = "Additionally a variable will be set in the behavior graph. It will be reset after nodeDeactivationName occurs";
}