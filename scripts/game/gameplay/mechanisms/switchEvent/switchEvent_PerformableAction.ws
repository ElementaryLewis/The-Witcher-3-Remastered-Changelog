/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_PerformableAction extends W3SwitchEvent
{
	editable inlined var performableAction : IPerformableAction;
	
	public function Perform( parnt : CEntity )
	{
		if ( performableAction )
		{
			performableAction.Trigger( parnt );
		}
	}
	
	public function PerformArgNode( parnt : CEntity, node : CNode )
	{
		if ( performableAction )
		{
			performableAction.TriggerArgNode( parnt, node );
		}
	}

	public function PerformArgFloat( parnt : CEntity, value : float )
	{
		if ( performableAction )
		{
			performableAction.TriggerArgFloat( parnt, value );
		}
	}
}