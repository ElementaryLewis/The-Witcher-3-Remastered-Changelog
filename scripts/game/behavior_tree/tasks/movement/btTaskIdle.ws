/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskIdle extends IBehTreeTask
{
	var toleranceAngle : float;
	var checkRotation	: bool;
	
	var isMoving : bool;
	
	default isMoving = false;

	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var temp : bool;
		
		return !npc.IsRotatedTowards( target, toleranceAngle );
	}
	
	function Rotate() : bool
	{
		var npc : CNewNPC = GetNPC();
		var npcPos, vec : Vector;
		var curRot, rot : EulerAngles;
		var target : CActor = GetCombatTarget();
		var temp : float;
		
		npcPos = npc.GetWorldPosition();
				
		vec = target.GetWorldPosition() - npcPos;
		rot = VecToRotation( vec );
		
		curRot = npc.GetWorldRotation();
		
		if( AbsF( AngleDistance( curRot.Yaw, rot.Yaw )) > toleranceAngle/2 )
		{
			if ( !isMoving )
			{
				isMoving = true;
				temp = AngleDistance( curRot.Yaw, rot.Yaw );
				if ( temp >= 120 )
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 5 );
				}
				else if ( temp >= 60 )
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 4 );
				}
				else if ( temp >= 0 )
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 3 );
				}
				else if ( temp >= -60 )
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 2 );
				}
				else if ( temp >= -120 )
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 1 );
				}
				else
				{
					
					npc.SetBehaviorVariable( 'rotateAngle', 0 );
				}
			}
			
			if( npc.RaiseEvent( 'Rotate' ) )
			{
				return true;
			}
			return false;
		}
		
		isMoving = false;
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var npcPos, vec : Vector;
		var curRot, rot : EulerAngles;
		var target : CActor = GetCombatTarget();
		var temp : float;
		
		while(true)
		{
			if ( !npc.IsRotatedTowards( target, toleranceAngle ) )
			{
				return BTNS_Completed;
			}
			
			Sleep(0.5);
		}
		
		return BTNS_Failed;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		isMoving = false;
	}	
	
}

class CBTTaskIdleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskIdle';

	editable var toleranceAngle : float;
	editable var checkRotation	: bool;
	
	default toleranceAngle = 12;
	default checkRotation = true;
}