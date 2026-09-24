/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSignalReactionEvent extends IBehTreeTask
{
	var reactionEventName			: name;
	var lifeTime					: float;
	var distanceRange				: float;
	var broadcastInterval			: float;
	var recipientCount				: int;
	var skipInvoker					: bool;
	var setActionTargetOnBroadcast	: bool;
	var disableOnDeactivate			: bool;
	var onActivate					: bool;
	var onDeactivate				: bool;
	var onSuccess					: bool;
	var onFailure					: bool;
	var onAnimEvent					: bool;
	var eventName					: name;
	
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			TriggerEvent();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var actor : CActor = GetActor();
		
		if ( onDeactivate && !disableOnDeactivate )
		{
			TriggerEvent();
		}
		if ( disableOnDeactivate )
		{
			theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, reactionEventName );
		}
	}
	
	function OnCompletion( success : bool )
	{
		if( success && onSuccess )
		{
			TriggerEvent();
		}
		if ( !success && onFailure )
		{
			TriggerEvent();
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( onAnimEvent && animEventName == eventName && animEventType == AET_DurationStart )
		{
			TriggerEvent();
			return true;
		}
		return false;
	}
	
	function TriggerEvent()
	{
		var actor : CActor = GetActor();
		
		
		
		if ( recipientCount == 0 )
			recipientCount = -1;
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, reactionEventName, lifeTime, distanceRange, broadcastInterval, recipientCount, skipInvoker, setActionTargetOnBroadcast );
	}
};

class CBTTaskSignalReactionEventDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskSignalReactionEvent';

	editable var reactionEventName			: CBehTreeValCName;
	editable var lifeTime					: float;
	editable var distanceRange				: CBehTreeValFloat;
	editable var broadcastInterval			: float;
	editable var recipientCount				: CBehTreeValInt;
	editable var setActionTargetOnBroadcast	: bool;
	editable var skipInvoker				: bool;
	editable var disableOnDeactivate		: bool;
	editable var onActivate					: bool;
	editable var onDeactivate				: bool;
	editable var onSuccess					: bool;
	editable var onFailure					: bool;
	editable var onAnimEvent				: bool;
	editable var eventName					: name;
	
	default lifeTime = -1;
	default distanceRange = 10;
	default broadcastInterval = 2;
	default onActivate = true;
	default recipientCount = -1;
	
	hint skipInvoker		= "Signal invoker doesn't receive the event";
	
	public function Initialize()
	{
		SetValFloat(distanceRange, 10);
		SetValInt(recipientCount,-1);
		super.Initialize();
	}
};
