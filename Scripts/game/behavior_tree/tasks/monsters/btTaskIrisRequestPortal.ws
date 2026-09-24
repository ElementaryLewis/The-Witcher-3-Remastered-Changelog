/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskIrisRequestPortal extends IBehTreeTask
{
	
	
	
	public 	var onDeactivate 	: bool;	
	public 	var onAnimEvent 	: CName;
	
	private var m_Npc 			: W3NightWraithIris;
	
	
	function OnActivate() : EBTNodeStatus
	{
		if( !onDeactivate && !IsNameValid( onAnimEvent ) )
			Request();
		
		return BTNS_Active;
	}
	
	
	private function OnDeactivate()
	{
		if( onDeactivate )
			Request();
			
	}
	
	
	private function Request()
	{
		m_Npc = (W3NightWraithIris) GetNPC();		
		m_Npc.RequestPortal();	
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{		
		if ( animEventName == onAnimEvent )
		{
			Request();
			return true;
		}
		return true;
	}
}



class BTTaskIrisRequestPortalDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisRequestPortal';
	
	private editable var onDeactivate : bool;
	private editable var onAnimEvent  : CName;
}