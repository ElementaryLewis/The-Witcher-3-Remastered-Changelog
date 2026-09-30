/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSorceressAttacksBoid extends CBTTaskMagicMeleeAttack
{
	var attackAngle : float;
	var attackDist	: float;
	
	function OnDeactivate()
	{
		super.OnDeactivate();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if ( animEventName == 'PerformMagicAttack' || animEventName == 'DealDamageToBoids' )
		{
			Boids_CastFireInCone( GetActor().GetWorldPosition(), GetActor().GetHeading(), attackAngle, attackDist );
			return true;
		}
		
		return res;
	}
	
	function GetEffectPositionAndRotation( out pos : Vector, out rot : EulerAngles )
	{
		var owner 	: CActor = GetActor();
		
		pos = owner.GetWorldPosition() + attackDist*owner.GetHeadingVector();
		pos.Z += 0.7;
		rot = owner.GetWorldRotation();
	}
}

class CBTTaskSorceressAttacksBoidDef extends CBTTaskMagicMeleeAttackDef
{
	default instanceClass = 'CBTTaskSorceressAttacksBoid';

	editable var attackAngle : CBehTreeValFloat;
	editable var attackDist	: CBehTreeValFloat;
}