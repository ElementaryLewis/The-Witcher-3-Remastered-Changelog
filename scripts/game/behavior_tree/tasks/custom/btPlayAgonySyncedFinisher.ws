/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskPlayAgonySyncedFinisher extends CBTTaskPlaySyncedAnimation
{
	function IsAvailable() : bool
	{
		var owner : CNewNPC = GetNPC();
	
		
		return super.IsAvailable();
		return owner.IsInFinisherAnim();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return super.OnActivate();
		
	}
	
	function OnDeactivate()
	{
		var owner : CNewNPC = GetNPC();
		
		super.OnDeactivate();
		owner.FinisherAnimEnd();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		
		
		
		return false;
	}
}

class CBTTaskPlayAgonySyncedFinisherDef extends CBTTaskPlaySyncedAnimationDef
{
	default instanceClass = 'CBTTaskPlayAgonySyncedFinisher';
}