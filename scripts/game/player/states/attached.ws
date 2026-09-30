/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Attached in CPlayer extends Base
{
	var attachedTo : CEntity;
	var slot : name;

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		parent.EnableCharacterCollisions( false );
		parent.SetBIsInputAllowed( false, 'AttachedStateEnter' );
		parent.CreateAttachment(attachedTo, slot);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		parent.BreakAttachment();
		parent.EnableCharacterCollisions( true );
		parent.SetBIsInputAllowed( true, 'StateAttachedLeave' );
		super.OnLeaveState(nextStateName);		
	}
	
	
	
	public function SetupState( entity : CEntity, optional toSlot : name )
	{
		attachedTo = entity;
		slot = toSlot;
	}
}