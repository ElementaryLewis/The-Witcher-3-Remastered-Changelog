/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskBreakQuen extends IBehTreeTask
{
	private var onActivate : bool;

	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			BreakQuen();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !onActivate )
		{
			BreakQuen();
		}
	}
	
	private function BreakQuen()
	{
		thePlayer.FinishQuen( false );
	}
}

class CBTTaskBreakQuenDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskBreakQuen';

	editable var onActivate : bool;

	default onActivate = true;
}