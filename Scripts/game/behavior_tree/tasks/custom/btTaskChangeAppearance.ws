/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskChangeAppearance extends IBehTreeTask
{
	var appearanceName		: name;
	var onActivate 			: bool;
	var onDectivate 		: bool;
	var onAnimEvent 		: name;
		
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			GetActor().SetAppearance(appearanceName);
			return BTNS_Active;
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDectivate )
		{
			GetActor().SetAppearance(appearanceName);
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( IsNameValid( onAnimEvent ) && animEventName == onAnimEvent )
		{
			GetActor().SetAppearance(appearanceName);
			return true;
		}
		
		return false;
	}
}

class CBTTaskChangeAppearanceDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskChangeAppearance';

	editable var appearanceName		: name;
	editable var onActivate 		: bool;
	editable var onDectivate 		: bool;
	editable var onAnimEvent 		: name;
}