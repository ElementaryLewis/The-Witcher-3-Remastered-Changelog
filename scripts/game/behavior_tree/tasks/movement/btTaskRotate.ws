/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskRotateToEnemy extends IBehTreeTask
{
	var toleranceAngle : float;
	var isMoving : bool;
	var rotateOnRotateEvent : bool;
	
	default isMoving = false;

	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		
		return !npc.IsRotatedTowards( target, toleranceAngle );
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var angleDist : float = NodeToNodeAngleDistance(target, npc);
		
		if( AbsF( angleDist ) > toleranceAngle/2 && !isMoving)
		{
			if ( angleDist > 0 )
			{
				if ( angleDist > 140 )
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 5 );
				}
				else if ( angleDist > 70 )
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 4 );
				}
				else
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 3 );
				}
			}
			else
			{
				if( angleDist < -140 )
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 0 );
				}
				else if( angleDist < -70 )
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 1 );
				}
				else
				{	
					
					npc.SetBehaviorVariable( 'rotateAngle', 2 );
				}
				
			}
			isMoving = true;
			return BTNS_Active;
			
		}
		isMoving = false;
		
		return BTNS_Failed;
	}
	
	
	function OnDeactivate()
	{
		GetNPC().RaiseEvent('RotateEnd');
		isMoving = false;
	}	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor;

		if ( rotateOnRotateEvent && eventName == 'RotateEventStart' )
		{
			target = npc.GetTarget();
			npc.SetRotationAdjustmentRotateTo( target );
			npc.slideTarget = target; 
			return true;
		}
		
		return false;
	}
	
}

class CBTTaskRotateToEnemyDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskRotateToEnemy';


	editable var toleranceAngle : float;
	editable var rotateOnRotateEvent : bool;
	
	default toleranceAngle = 20;
	default rotateOnRotateEvent = true;
}