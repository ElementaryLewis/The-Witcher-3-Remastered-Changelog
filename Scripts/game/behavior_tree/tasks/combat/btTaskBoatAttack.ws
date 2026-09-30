/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskBoatAttack extends IBehTreeTask
{
	
	
	
	private var m_TargetBoat 			: CEntity;
	private var m_LockedSlot			: name;
	
	
	
	function OnDeactivate()
	{
		FreeGrabSlot();		
	}
	
	
	function OnGameplayEvent( _EventName : name ) : bool
	{	
		if( _EventName == 'BeingHit' )
		{
			GetNPC().Kill( 'Hit when on boat' );
		}
		
		return true;
	}
	
	
	function OnListenedGameplayEvent( _EventName : name ) : bool
	{	
		var l_slotFound			: bool;
		var l_destructionComp 	: CBoatDestructionComponent;
		var l_targetLocation	: Vector;
		var l_targetHeading		: float;
		
		if ( _EventName == 'LockSlot' )
		{
			m_LockedSlot = GetEventParamCName('');
		}
		
		return true;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{		
		if ( animEventName == 'Detach')
		{
			GetNPC().BreakAttachment();
			return true;
		}
		else if ( animEventName == 'BreakBoat')
		{
			DamageBoat( 35 );
			return true;
		}
		
		return true;
	}
	
	
	private final function GetBoat() : CEntity
	{
		if( !m_TargetBoat )
		{
			m_TargetBoat = thePlayer.GetUsedVehicle();
		}
		
		return m_TargetBoat;
	}
	
	
	private function FreeGrabSlot()
	{		
		var l_destructionComp 	: CBoatDestructionComponent;
		l_destructionComp 	= (CBoatDestructionComponent) GetBoat().GetComponentByClassName('CBoatDestructionComponent');			
		l_destructionComp.FreeGrabSlot( m_LockedSlot );
		l_destructionComp.DetachSiren( GetNPC() );
	}
	
	
	private function DamageBoat( _Amount : float )
	{
		var l_npc 				: CNewNPC = GetNPC();
		var l_destructionComp 	: CBoatDestructionComponent;
		
		l_destructionComp = (CBoatDestructionComponent) GetBoat().GetComponentByClassName('CBoatDestructionComponent');
		if ( l_destructionComp )
		{
			l_destructionComp.DealDmgToNearestVolume( _Amount ,l_npc.GetWorldPosition() );
			GCameraShake(1.5, true, thePlayer.GetWorldPosition(), 30.0f);
		}
	}
	
}


class CBTTaskBoatAttackDef extends IBehTreeTaskDefinition
{	
	default instanceClass = 'CBTTaskBoatAttack';
	
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'LockSlot' );
		listenToGameplayEvents.PushBack( 'BoatDestroyed' );
	}
}