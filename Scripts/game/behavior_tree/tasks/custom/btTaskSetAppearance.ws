/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSetAppearance extends IBehTreeTask
{
	var appearanceName		: name;
	var previousAppearance 	: name;
	var onActivate			: bool;
	var onDeactivate		: bool;
	var onSuccess 			: bool;
	var onAnimEvent			: bool;
	var overrideForTask		: bool;
	var eventName			: name;
	
	
	function OnActivate() : EBTNodeStatus
	{
		var actor : CActor = GetActor();
		
		if ( onActivate )
		{
			if ( overrideForTask )
			{
				previousAppearance = actor.GetAppearance();
			}
			actor.SetAppearance( appearanceName );
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var actor : CActor = GetActor();
		
		if ( onDeactivate && !overrideForTask )
		{
			actor.SetAppearance( appearanceName );
		}
		if ( overrideForTask )
		{
			actor.SetAppearance( previousAppearance );
		}
	}
	
	function OnCompletion( success : bool )
	{
		var actor : CActor = GetActor();
		
		if ( onSuccess && success )
			actor.SetAppearance( appearanceName );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var actor : CActor = GetActor();
		
		if ( onAnimEvent && animEventName == eventName )
		{
			if ( overrideForTask )
			{
				previousAppearance = actor.GetAppearance();
			}
			actor.SetAppearance( appearanceName );
			return true;
		}
		return false;
	}
};

class CBTTaskSetAppearanceDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetAppearance';

	editable var appearanceName		: name;
	editable var onActivate			: bool;
	editable var onDeactivate		: bool;
	editable var onSuccess 			: bool;
	editable var onAnimEvent		: bool;
	editable var overrideForTask	: bool;
	editable var eventName			: name;

	default onDeactivate = true;
};