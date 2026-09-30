/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CBehTreeReactionManager extends CObject
{
	import final function CreateReactionEventIfPossible( invoker : CEntity, eventName : CName, lifetime : float, distanceRange : float, broadcastInterval : float, recipientCount : int, skipInvoker : bool, optional setActionTargetOnBroadcast : bool, optional customCenter : Vector );
	import final function CreateReactionEvent( invoker : CEntity, eventName : CName, lifetime : float, distanceRange : float, broadcastInterval : float, recipientCount : int, optional skipInvoker : bool, optional setActionTargetOnBroadcast : bool ) : bool;
	import final function CreateReactionEventCustomCenter( invoker : CEntity, eventName : CName, lifetime : float, distanceRange : float, broadcastInterval : float, recipientCount : int, skipInvoker : bool, setActionTargetOnBroadcast : bool, customCenter : Vector ) : bool;
	import final function RemoveReactionEvent( invoker : CEntity, eventName : CName) : bool;
	import final function InitReactionScene( invoker : CEntity, eventName : CName, lifetime : float, distanceRange : float, broadcastInterval : float, recipientCount : int  ) : bool;
	import final function AddReactionSceneGroup( voiceset : string, group : name );
	
	public final function RegisterReactionSceneGroups()
	{
		GlobalRegisterReactionSceneGroups();
	}
	
	import final function SuppressReactions( toggle : bool, areaTag : name );
};

import class CR4ReactionManager extends CBehTreeReactionManager
{
	import private var rainReactionsEnabled : bool;	
	
	public function SetRainReactionEnabled( enabled : bool )
	{
		rainReactionsEnabled = enabled;
	}
}

exec function CreateReactionEvent( tag : name, eventName : CName, lifetime : float, broadcastInterval : float )
{
	var invoker : CEntity;
	invoker = theGame.GetEntityByTag(tag);

	theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( invoker, eventName, lifetime, 20.0f, broadcastInterval, 1, false,);
}
