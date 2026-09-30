/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskJumpBack extends CBTTaskPlayAnimationEventDecorator
{
	var chance : int;
	var checkRotation : bool;
	var distance : float;
	
	function IsAvailable() : bool
	{
		if( theGame.GetWorld().NavigationLineTest(GetActor().GetWorldPosition(),GetActor().GetWorldPosition() - GetActor().GetHeadingVector()*distance,((CMovingPhysicalAgentComponent)GetActor().GetMovingAgentComponent()).GetCapsuleRadius()) )
		{
			return Roll(chance);
		}
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var victimHeading				: float;
		var attackerHeading				: float;
		var victimToAttackerAngle		: float;
		
		if ( checkRotation )
		{
			victimHeading = npc.GetHeading();
			attackerHeading = npc.GetTarget().GetHeading();
			victimToAttackerAngle = AngleDistance( attackerHeading, victimHeading );
			
			if( victimToAttackerAngle <= -30  ||  victimToAttackerAngle >= 30 )
			{
				npc.SetBehaviorVariable('DodgeDirection',(int)EDD_Back);
			}
			if( victimToAttackerAngle <= -60  ||  victimToAttackerAngle >= -30 )
			{
				npc.SetBehaviorVariable('DodgeDirection',(int)EDD_Right);
			}
			if( victimToAttackerAngle <= 60  ||  victimToAttackerAngle >= 30 )
			{
				npc.SetBehaviorVariable('DodgeDirection',(int)EDD_Left);
			}
		}
		return super.OnActivate();
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		return super.OnGameplayEvent( eventName );
	}
};

class CBTTaskJumpBackDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskJumpBack';

	editable var checkRotation : bool;
	editable var chance : int;
	editable var distance : float;
	
	default chance = 100;
	default distance = 2.f;
};