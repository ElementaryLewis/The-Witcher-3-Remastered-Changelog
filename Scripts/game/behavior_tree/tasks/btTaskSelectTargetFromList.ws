/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSelectTargetFromList extends IBehTreeTask
{
	public var targetList : array<name>;
	
	private var currentTargetIndex : int;
	
	private var currentTarget 	: CNode;
	private var targetToSelect 	: CNode;
	
	default currentTargetIndex = 0;
	
	function IsAvailable() : bool
	{
		if ( isActive ) 
			return true;
		
		return SelectTarget();
	}
	
	function SelectTarget() : bool
	{
		var target : CNode;
		
		if ( currentTarget && targetToSelect == currentTarget )
			return true;
		
		if ( targetList.Size() <= 0 )
			return false;
			
		if ( currentTargetIndex >= targetList.Size() )
			return false;
			
		targetToSelect = theGame.GetNodeByTag(targetList[currentTargetIndex]);
		
		if ( !targetToSelect )
			return false;
		
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !targetToSelect )
			SelectTarget();
		
		if ( !targetToSelect )
			return BTNS_Failed;
		
		this.SetActionTarget(targetToSelect);
		
		currentTarget = targetToSelect;
		
		currentTargetIndex += 1;
		
		GetNPC().SignalGameplayEventParamInt('CurrentTargetIndex',currentTargetIndex);
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		targetToSelect = NULL;
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		var tempIndex : int;
		var tempTag : name;
		
		if ( eventName == 'ChangeNextTeleportPoint' )
		{
			tempTag = GetEventParamCName('');
			if ( tempTag != '' )
				tempIndex = targetList.FindFirst(tempTag);
		}
		else
		{
			tempIndex = GetEventParamInt(-1);
		}
		
		if ( tempIndex >= 0 )
		{
			currentTargetIndex = tempIndex;
			return true;
		}
			
		return false;
	}
}

class CBTTaskSelectTargetFromListDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSelectTargetFromList';

	editable var targetList : array<name>;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CurrentTargetIndex' );
	}
}