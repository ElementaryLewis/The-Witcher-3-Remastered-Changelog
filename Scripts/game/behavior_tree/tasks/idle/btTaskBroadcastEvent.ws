/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskBroadcastEvent extends IBehTreeTask
{
	var owner 					: CNewNPC;
	var eventName				: name;
	var lifetime				: float;
	var distance				: float;
	var broadcastInterval		: float;
	var recipientCount			: int;
	var broadcastScene			: bool;
	var skipInvoker				: bool;
	
	latent function Main() : EBTNodeStatus
	{		
		owner = GetNPC();
		
		if( owner )
		{
			if( !broadcastScene )
				theGame.GetBehTreeReactionManager().CreateReactionEvent( owner, eventName, lifetime , distance, broadcastInterval, recipientCount, skipInvoker );
			else
				theGame.GetBehTreeReactionManager().InitReactionScene( owner, eventName, lifetime , distance, broadcastInterval, recipientCount );
			
			if( broadcastInterval < 50.0 )
				LogReactionSystem( "'" + eventName + "' was sent by " + owner.GetName() + " - single broadcast - distance: " + distance ); 
			else
				LogReactionSystem( "'" + eventName + "' was sent by " + owner.GetName() + " - repetitive broadcast - distance: " + distance );
			return BTNS_Active;	
		}
		
		return BTNS_Failed;
	}
}

class CBTTaskBroadcastEventDef extends IBehTreeTaskDefinition
{	
	default instanceClass = 'CBTTaskBroadcastEvent';


	editable var eventName				: name;
	editable var lifetime				: float;
	editable var distance				: float;
	editable var broadcastInterval		: float;
	editable var recipientCount			: int;
	editable var broadcastScene			: bool;
	editable var skipInvoker			: bool;
	
	default lifetime = 1.0;
	default distance = 10.0;
	default broadcastInterval = 2.0;
	default recipientCount = 1;
	default broadcastScene = false;
	default skipInvoker = false;
}

class CBTTaskRemoveReactionEvent extends IBehTreeTask
{
	var owner 		: CNewNPC;
	var eventName	: name;
	
	latent function Main() : EBTNodeStatus
	{		
		owner = GetNPC();
		
		if( owner )
		{
			theGame.GetBehTreeReactionManager().RemoveReactionEvent( owner, eventName );
			
			return BTNS_Active;
		}
		
		return BTNS_Failed;
	}
}

class CBTTaskRemoveReactionEventDef extends IBehTreeTaskDefinition
{	
	default instanceClass = 'CBTTaskRemoveReactionEvent';
	
	editable var eventName	: name;
}
