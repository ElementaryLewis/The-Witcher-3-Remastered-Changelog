/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTask3StateTaunt extends CBTTaskPlayAnimationEventDecorator
{
	var tauntType			: ETauntType;
	var raiseEventName		: name;
	var minDuration			: float;
	var maxDuration			: float;
	var res					: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		res = false;
		
		npc.SetBehaviorVariable( 'TauntEnd', 0.f, true );
		npc.SetBehaviorVariable( 'TauntType', (int)tauntType, true );
		
		if( IsNameValid( raiseEventName ) )
			npc.RaiseEvent( raiseEventName );
			
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor;
		var duration : float;
		
		target = npc.GetTarget();
		duration = RandRangeF( maxDuration, minDuration );
		
		Sleep( duration );
		npc.SetBehaviorVariable( 'TauntEnd', 1.f, true );
		npc.WaitForBehaviorNodeDeactivation( 'TauntEnd', 1.f );
		res = true;
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		if ( !res )
		{
			npc.SetBehaviorVariable( 'TauntEnd', 1, true );
		}
	}
}

class CBTTask3StateTauntDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTask3StateTaunt';

	editable var tauntType			: ETauntType;
	editable var raiseEventName		: name;
	editable var minDuration		: float;
	editable var maxDuration		: float;
}