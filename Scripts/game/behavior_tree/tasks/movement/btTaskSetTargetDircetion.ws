/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSetTargetDirection extends IBehTreeTask
{
	var npcPos, vec 			: Vector;
	var curRot, rot 			: EulerAngles;
	var angleDistance 			: float;
	
	
	public var useCombatTarget 			: bool;
	public var setRotationOnActivate 	: bool;
	public var setOnAnimEvent			: bool;
	public var animationEventName		: name;
	public var useTargetsTarget			: bool;
	public var completeOnAllowBlend		: bool;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if( setRotationOnActivate )
		{
			SetTargetDirection();
		}
		
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == animationEventName && setOnAnimEvent )
		{
			SetTargetDirection();
			return true;
		}
		else if ( animEventName == 'AllowBlend' && completeOnAllowBlend )
		{
			Complete(true);
			return true;
		}
		return false;
	}
	
	function SetTargetDirection()
	{
		var npc : CNewNPC = GetNPC();
		var target : CNode;
		
		if ( useCombatTarget )
			target = GetCombatTarget();
		else
			target = GetActionTarget();
		
		if ( useTargetsTarget )
			target = ((CActor)target).GetTarget();
		
		angleDistance = NodeToNodeAngleDistance(target,npc);
		if ( angleDistance >= 160 )
		{
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_180, true );
		}
		else if ( angleDistance >= 110 )
		{ 
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_135, true );
		}
		else if ( angleDistance >= 65 )
		{
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_90, true );
		}
		else if ( angleDistance >= 20 )
		{
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_45, true );
		}
		else if ( angleDistance >= -20 )
		{
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_0, true );
		}
		else if ( angleDistance >= -65 )
		{
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_m45, true );
		}
		else if ( angleDistance >= -110 )
		{
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_m90, true );
		}
		else if ( angleDistance >= -160 )
		{
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_m135, true );
		}
		else if ( angleDistance >= -180 )
		{
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_m180, true );
		}
		else
		{
			
			npc.SetBehaviorVariable( 'targetDirection', (float)(int)ETD_Direction_0, true );
		}
	}
}

class CBTTaskSetTargetDirectionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetTargetDirection';

	editable var useCombatTarget		: bool;
	editable var setRotationOnActivate 	: bool;
	editable var setOnAnimEvent			: bool;
	editable var animationEventName		: name;
	editable var useTargetsTarget		: bool;
	editable var completeOnAllowBlend	: bool;
	
	default useCombatTarget = true;
	default setRotationOnActivate = true;
	default setOnAnimEvent = false;
	default animationEventName = 'TargetDir';
	default completeOnAllowBlend = true;
	
	hint setRotationOnActivate = "Task will set the target direction var when it's activated";
	hint setOnAnimEvent = "Task will set the target direction var on specified animation event";
	hint animationEventName = "The name of the animation event that will set the target direction var";
}