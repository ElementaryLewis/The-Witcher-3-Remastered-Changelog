/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskToadYrden extends IBehTreeTask
{
	var npc				: CNewNPC;
	var leftYrden 		: bool;
	var leaveAfter 		: float;
	var enterTimestamp	: float;
	var l_effect		: bool;
	
	
	function OnActivate(): EBTNodeStatus
	{
		leftYrden = false;
		npc = GetNPC();
		
		if( !npc.IsEffectActive('yrden_lock') )
		{
			npc.PlayEffect( 'yrden_lock' );
		}
	
		enterTimestamp = theGame.GetEngineTimeAsSeconds();
		return BTNS_Active;
	}
	
	latent function Main(): EBTNodeStatus
	{
		while( true )
		{
			if ( leftYrden )
				break;
			else if (  npc.GetHitCounter() >= 3  )
			{
				break;
			}
			else if ( theGame.GetEngineTimeAsSeconds() > enterTimestamp + leaveAfter )
			{
				break;
			}
			
			SleepOneFrame();
		}
		
		return BTNS_Completed;
		
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'LeavesYrden' )
		{
			leftYrden = true;
			return true;
		}
		return true;
	}
	function OnDeactivate()
	{
		npc.StopEffect( 'yrden_lock' );
		npc.PlayEffect('yrden_break');
		npc.SignalGameplayEvent( 'StopYrden' );
	}
	
}
class CBTTaskToadYrdenDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskToadYrden';
	
	var npc				: CActor;
	var leftYrden 		: bool;
	editable var leaveAfter 		: float;
	var enterTimestamp	: float;
	var l_effect		: bool;

	
}