/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SReactionEventData
{
	editable var eventName				: name;
	editable var lifetime				: float;
	editable var distance				: float;
	editable var broadcastInterval		: float;
	editable var recipientCount			: int;
	editable var cooldown				: float;
	editable var chanceOfSucceeding		: float;
	editable var lastBroadcastTime		: float;
};

class CBTTaskEventsBroadcaster extends IBehTreeTask
{
	var broadcastedEvents : array<SReactionEventData>;
	var rescanInterval : float;
	var minIntervalBetweenScenes : float;
	var owner : CNewNPC;
	var i : int;
	var eventsCount : int;
	var currentTime : float;
	var timeOfLastScene : float;
 
	function OnActivate() : EBTNodeStatus
	{
		owner = GetNPC();
		eventsCount = broadcastedEvents.Size();
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		while ( true )
		{
			currentTime = theGame.GetEngineTimeAsSeconds();
			
			if( currentTime > timeOfLastScene + minIntervalBetweenScenes )
			{
				for( i = 0; i < eventsCount; i += 1 )
				{
					if( currentTime > broadcastedEvents[i].lastBroadcastTime + broadcastedEvents[i].cooldown && 
						Roll( broadcastedEvents[i].chanceOfSucceeding ) &&
						VecDistance( thePlayer.GetWorldPosition(), owner.GetWorldPosition()	) < 25.0 )
					{
						broadcastedEvents[i].lastBroadcastTime = currentTime;
						timeOfLastScene = currentTime;
					
						theGame.GetBehTreeReactionManager().InitReactionScene(	owner,
																				broadcastedEvents[i].eventName,
																				broadcastedEvents[i].lifetime,
																				broadcastedEvents[i].distance,
																				broadcastedEvents[i].broadcastInterval,
																				broadcastedEvents[i].recipientCount );
					}
				}
			}
			Sleep( rescanInterval );
		}
		
		return BTNS_Active;
	}
	
	function Roll( chance : float ) : bool
	{
		if ( RandRange( 100 ) < chance )
		{
			return true;
		}
		
		return false;
	}
}

class CBTTaskEventsBroadcasterDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'TRALALA';

	editable inlined var broadcastedEvents : array<SReactionEventData>;
	editable var rescanInterval : float;
	editable var minIntervalBetweenScenes : float;
	
	default rescanInterval = 1.0;
	default minIntervalBetweenScenes = 10.0;
}