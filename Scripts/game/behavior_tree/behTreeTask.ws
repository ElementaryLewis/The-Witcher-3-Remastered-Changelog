/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class IBehTreeTask extends IScriptable
{
	import protected var isActive : bool;
	
	
	import final function GetActor() : CActor;
	
	
	import final function GetNPC() : CNewNPC;
	
	
	import final function GetLocalTime() : float;
	
	import final function GetActionTarget() : CNode;
	import final function SetActionTarget( node : CNode );
	
	import final function GetCombatTarget() : CActor;
	import final function SetCombatTarget( target : CActor );
	
	import final function SetCustomTarget( target : Vector, heading : float ) : bool;
	import final function GetCustomTarget( out target : Vector, out heading : float ) : bool;
	
	import final function SetNamedTarget( targetName : name, node : CNode );
	import final function GetNamedTarget( targetName : name ) : CNode;
	
	import final function RunMain();
	import final function Complete( success : bool );
	
	import final function GetEventParamCName( defaultVal : CName ) : CName;
	import final function GetEventParamFloat( defaultVal : float ) : float;
	import final function GetEventParamInt( defaultVal : int ) : int;
	import final function GetEventParamObject() : IScriptable;
	
	import final function UnregisterFromAnimEvent( eventId : CName );
	import final function UnregisterFromGameplayEvent( eventId : CName );
	
	import final function SetIsInCombat( inCombat : bool );
	
	
	import final function SetEventRetvalCName( val : CName ) : bool;
	import final function SetEventRetvalFloat( val : float ) : bool;
	import final function SetEventRetvalInt( val : int ) : bool;

	import final function GetEventParamBaseDamage() : CBaseDamage;
	
	import final function GetReactionEventInvoker() : CEntity;
	
	import final function RequestStorageItem( itemName : name, itemClass : name ) : IScriptable;
	import final function FindStorageItem( itemName : name, itemClass : name ) : IScriptable;
	
	public function InitializeCombatStorage() : IScriptable
	{
		var actor : CActor = GetActor();
		var className : name = 'CBaseAICombatStorage';
		
		
		if( actor.HasTag( 'eredin' ) )
		{
			className = 'CBossAICombatStorage';
		}
		else if( actor.HasTag( 'archespor' ) )
		{
			className = 'CArchesporeAICombatStorage';
		}
		else if( actor.IsHuman() || actor.GetMovingAgentComponent().GetName() == "wild_hunt_base" || actor.HasTag( 'dettlaff_vampire' ) || actor.HasTag( 'mq7017_knight' ) )
		{
			className = 'CHumanAICombatStorage';
		}
		else if( actor.HasTag( 'black_spider' ) )
		{
			className = 'CExtendedAICombatStorage';
		}
		
		return RequestStorageItem( 'CombatData', className );
	}
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
};

import abstract class IBehTreeObjectDefinition extends IScriptable
{
	import private var instanceClass : name;
	
	import protected final function GetValFloat( v : CBehTreeValFloat ) : float;
	import protected final function GetValInt( v : CBehTreeValInt ) : int;
	import protected final function GetValEnum( v : IBehTreeValueEnum) : int;
	import protected final function GetValString( v : CBehTreeValString ) : string;
	import protected final function GetValCName( v : CBehTreeValCName ) : CName;
	import protected final function GetValBool( v : CBehTreeValBool ) : bool;
	
	import protected final function GetObjectByVar( varName : name ) : IScriptable;
	import protected final function GetAIParametersByClassName( className : name ) : IAIParameters; 
	
	import protected final function SetValFloat( v : CBehTreeValFloat, n : float );
	import protected final function SetValInt( v : CBehTreeValInt, n : int );
	import protected final function SetValString( v : CBehTreeValString, n : string );
	import protected final function SetValCName( v : CBehTreeValCName, n : CName);
	import protected final function SetValBool( v : CBehTreeValBool, n : bool );
	
	
	
	
	
};




import abstract class IBehTreeTaskDefinition extends IBehTreeObjectDefinition
{
	import var listenToGameplayEvents : array< name >;
	import var listenToAnimEvents : array< name >;
	
	import protected final function ListenToAnimEvent( eventName : name );
	import protected final function ListenToGameplayEvent( eventName : name );

	
	public function Initialize()
	{
		InitializeEvents();
	}
	
	public function Refactor()
	{
		InitializeEvents();
	}
	
	public function InitializeEvents()
	{
		listenToGameplayEvents.Clear();
		listenToAnimEvents.Clear();
	}

	
	
};




import abstract class IBehTreeConditionalTaskDefinition extends IBehTreeTaskDefinition
{
}




abstract class IBehTreeHLTaskDefinition extends IBehTreeTaskDefinition
{
	
};



abstract class IBehTreeReactionTaskDefinition extends IBehTreeTaskDefinition
{
	
};



abstract class IBehTreeFollowerTaskDefinition extends IBehTreeTaskDefinition
{
	
};




import function DebugBehTreeStart( optional actor : CActor );
import function DebugBehTreeStopAll();
