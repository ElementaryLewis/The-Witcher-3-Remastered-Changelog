/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSetWeakenedState extends IBehTreeTask
{
	var value : bool;
	var onActivate : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if( onActivate )
		{
			npc.SetWeakenedState( value );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		if( !onActivate )
		{
			npc.SetWeakenedState( value );
		}
	}
}

class BTTaskSetWeakenedStateDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetWeakenedState';
	
	editable var value : bool;
	editable var onActivate : bool;
	
	default value = true;
	default onActivate = true;
}

class BTTaskSetHitWindowOpened extends IBehTreeTask
{
	var value : bool;
	var onActivate : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if( onActivate )
		{
			npc.SetHitWindowOpened( value );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		if( !onActivate )
		{
			npc.SetHitWindowOpened( value );
		}
	}
}

class BTTaskSetHitWindowOpenedDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetHitWindowOpened';
	
	editable var value : bool;
	editable var onActivate : bool;
	
	default value = true;
	default onActivate = true;
}

class BTTaskActivateEthereal extends IBehTreeTask
{
	var onActivate : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if( onActivate )
		{
			npc.ActivateEthereal( true );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		if( !onActivate )
		{
			npc.ActivateEthereal( true );
		}
	}
}

class BTTaskActivateEtherealDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskActivateEthereal';
	
	editable var onActivate : bool;
	
	default onActivate = true;
}