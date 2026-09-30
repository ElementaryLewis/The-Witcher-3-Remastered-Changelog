/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskMaintainSpeed extends IBehTreeTask
{
	var moveType 				: EMoveType;
	var moveSpeed				: float;
	var manageFlySpeed			: bool;
	var onActivate				: bool;
	var onDeactivate			: bool;
	var speedDecay				: bool;
	var speedDecayOnDeactivate 	: bool;
	var overrideForThisTask 	: bool;
	var decayAfter 				: float;
	
	var previousSpeed 			: float;

	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		switch ( moveType )
		{
			case MT_Walk 	: moveSpeed = 1.0;
			break;
			case MT_Run 	: moveSpeed = 2.0;
			break;
			case MT_FastRun : moveSpeed = 3.0;
			break;
			case MT_Sprint 	: moveSpeed = 4.0;
			break;
		}
		
		if ( onActivate || overrideForThisTask )
		{
			if ( overrideForThisTask )
			{
				previousSpeed = npc.GetBehaviorVariable( 'Editor_MovementSpeed' );
			}
			npc.SetBehaviorVariable( 'Editor_MovementSpeed', moveSpeed );
			if ( manageFlySpeed )
			{
				npc.SetBehaviorVariable( 'Editor_FlySpeed', moveSpeed );
			}
			if ( speedDecay )
			{
				npc.AddTimer( 'MaintainSpeedTimer', decayAfter, false );
				if ( manageFlySpeed )
				{
					npc.AddTimer( 'MaintainFlySpeedTimer', decayAfter, false );
				}
			}
		}		
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		var npc : CNewNPC = GetNPC();
		
		if ( speedDecayOnDeactivate )
		{
			npc.AddTimer( 'MaintainSpeedTimer', decayAfter, false );
		}
		else if ( overrideForThisTask )
		{
			npc.SetBehaviorVariable( 'Editor_MovementSpeed', previousSpeed );
			if ( manageFlySpeed )
			{
				npc.SetBehaviorVariable( 'Editor_FlySpeed', previousSpeed );
			}
		}
		else if ( onDeactivate )
		{
			npc.SetBehaviorVariable( 'Editor_MovementSpeed', moveSpeed );
			if ( manageFlySpeed )
			{
				npc.SetBehaviorVariable( 'Editor_FlySpeed', moveSpeed );
			}
			if ( speedDecay )
			{
				npc.AddTimer( 'MaintainSpeedTimer', 0.5, false );
				if ( manageFlySpeed )
				{
					npc.AddTimer( 'MaintainFlySpeedTimer', 0.5, false );
				}
			}
		}
	}
};

class CBTTaskMaintainSpeedDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskMaintainSpeed';
	
	editable var moveType 				: EMoveType;
	editable var manageFlySpeed			: bool;
	editable var onActivate				: bool;
	editable var onDeactivate			: bool;
	editable var speedDecay				: bool;
	editable var speedDecayOnDeactivate : bool;
	editable var overrideForThisTask 	: bool;
	editable var decayAfter 			: float;
	
	default moveType = MT_Run;
	default onDeactivate = true;
	default speedDecay = true;
	default decayAfter = 0.5;
};
