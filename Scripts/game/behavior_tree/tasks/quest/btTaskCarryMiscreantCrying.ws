/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskMiscreantCrying extends IBehTreeTask
{
	var miscreantName			: name;		default miscreantName	= 'Miscreant';
	var miscreant				: CActor;
	var isAvailable				: bool;		default isAvailable		= false;
	var cryStartEventName		: name;		default miscreantName	= 'StartCrying';
	var cryStopEventName		: name;		default miscreantName	= 'StopCrying';
	
	
	function IsAvailable(): bool
	{
		return	isAvailable;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		
		
		GrabMiscreant();
		
		
		SendBehGraphEvent( 'CryStart' );
		
		return BTNS_Active;
	}
	
	function Main() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		isAvailable	= false;
		SendBehGraphEvent( 'CryStop' );
	}

	function OnGameplayEvent( eventName : name ) : bool
	{
		if( eventName == cryStopEventName )
		{		
			
			isAvailable	= false;
			Complete( true );
			
			SetEventRetvalInt( 1 );
			
			return true;
		}
		
		return false;
	}
	
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( eventName == cryStartEventName )
		{			
			isAvailable	= true;
			SetEventRetvalInt( 1 );
			return true;
		}
		
		return false;
	}
	
	
	private function GrabMiscreant()
	{
		
		if( miscreant )
		{
			return;
		}
		
		miscreant	= ( CActor ) theGame.GetEntityByTag( miscreantName );
		
		if( !miscreant )
		{
			LogChannel( 'Miscreant',"Could not find miscreant entity with name " + miscreantName );
			return;
		}
	}
	
	private function SendBehGraphEvent( eventName : name )
	{
		var npc			: CNewNPC = GetNPC();
		
		npc.RaiseEvent( eventName );
		miscreant.RaiseEvent( eventName );
	}
};

class CBTTaskMiscreantCryingDef extends CBTTaskQuestDef
{
	default instanceClass = 'CBTTaskMiscreantCrying';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'StartCrying' );
	}
}


class CBTTaskCarryMiscreant extends IBehTreeTask
{
	var attachmentBone	: name;		default	attachmentBone	= 'r_weapon';
	var miscreantName	: name;		default	miscreantName	= 'Miscreant';
	var miscreant		: CActor;
	

	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		
		
		GrabMiscreant();
		
		
		DisableMiscreantCollision();
		
		
		miscreant.Teleport( npc.GetBoneWorldPosition( attachmentBone ) );
		
		
		if( !miscreant.CreateAttachmentAtBoneWS( ( CEntity ) npc , attachmentBone, Vector( 0, 0, 0 ), EulerAngles( 0, 0, 0 ) ) )
		{
			LogChannel( 'Miscreant',"Could not create attachment to bone " + attachmentBone );
			return BTNS_Failed;
		}
		
		return BTNS_Completed;
	}
	
	function OnDeactivate() 
	{
		var npc : CNewNPC = GetNPC();
		
		
		
	}
	
	
	private function GrabMiscreant()
	{
		
		if( miscreant )
		{
			return;
		}
		
		miscreant	= ( CActor ) theGame.GetEntityByTag( miscreantName );
		
		if( !miscreant )
		{
			LogChannel( 'Miscreant',"Could not find miscreant entity with name " + miscreantName );
			return;
		}
	}
	
	private function DisableMiscreantCollision()
	{		
		if( miscreant )
		{
			miscreant.EnableCharacterCollisions( false );
			
		}
	}
};

class CBTTaskCarryMiscreantDef extends CBTTaskQuestDef
{
	default instanceClass = 'CBTTaskCarryMiscreant';
}
