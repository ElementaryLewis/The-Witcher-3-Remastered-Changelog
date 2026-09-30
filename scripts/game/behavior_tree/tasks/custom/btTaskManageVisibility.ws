/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class TaskManageVisibility extends IBehTreeTask
{
	var visible						: bool;
	var changeMeshVisibility		: bool;	
	var changeGameplayVisibility	: bool;
	var onActivate 					: bool;
	var onDeactivate 				: bool;
	var onAnimEvent					: bool;
	var onAnimEventName				: name;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			if ( changeMeshVisibility )
			{
				GetNPC().SetVisibility( visible );
			}
			if( changeGameplayVisibility )
			{
				GetNPC().SetGameplayVisibility( visible );
			}
		}
			
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			if ( changeMeshVisibility )
			{
				GetNPC().SetVisibility( visible );
			}
			if( changeGameplayVisibility )
			{  
				GetNPC().SetGameplayVisibility( visible );
			}
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( onAnimEvent && IsNameValid( onAnimEventName ) && animEventName == onAnimEventName )
		{
			if ( changeMeshVisibility )
			{
				GetNPC().SetVisibility( visible );
			}
			if( changeGameplayVisibility )
			{
				GetNPC().SetGameplayVisibility( visible );
			}
			
			return true;
		}
		
		return false;
	}
}

class TaskManageVisibilityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'TaskManageVisibility';

	editable var visible					: bool;
	editable var changeMeshVisibility		: bool;
	editable var changeGameplayVisibility	: bool;
	editable var onActivate 				: bool;
	editable var onDeactivate 				: bool;
	editable var onAnimEvent				: bool;
	editable var onAnimEventName			: name;
	
	default changeMeshVisibility = true;
	
	hint changeGameplayVisibility = "Gameplay visibility: camera lock, hud display, targeting";
};