/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCheckActorSpeed extends IBehTreeTask
{
	var checkedActor 	: EStatOwner;
	var moveType		: EMoveType;
	var operator 		: EOperator;
	var customSpeed		: bool;
	var moveSpeed		: float;
	var currentSpeed	: float;
	
	function IsAvailable() : bool
	{
		return CheckSpeed();
	}
	
	function CheckSpeed() : bool
	{
		var component : CAnimatedComponent;
		switch( checkedActor )
		{
			case SO_Target:
				component = ( CAnimatedComponent )GetCombatTarget().GetComponentByClassName( 'CAnimatedComponent' );
			break;
			case SO_ActionTarget:
				component = ( CAnimatedComponent ) ((CActor)GetActionTarget()).GetComponentByClassName( 'CAnimatedComponent' );
			break;
			default:
				component = ( CAnimatedComponent )GetActor().GetComponentByClassName( 'CAnimatedComponent' );
			break;
		}
		
		currentSpeed = component.GetMoveSpeedRel();
		
		if ( customSpeed )
		{
			switch ( operator )
			{
				case EO_Equal:			return currentSpeed == moveSpeed;
				case EO_NotEqual:		return currentSpeed != moveSpeed;
				case EO_Less:			return currentSpeed < moveSpeed;
				case EO_LessEqual:		return currentSpeed <= moveSpeed;
				case EO_Greater:		return currentSpeed > moveSpeed;
				case EO_GreaterEqual:	return currentSpeed >= moveSpeed;
				default : 				return false;
			}
		}
		else
		{
			switch ( moveType )
			{
				case MT_Walk:			if ( currentSpeed > 0 && currentSpeed < 1.4 ) return true;
				case MT_Run: 			return currentSpeed >= 1.6;
				default : 				return true;
			}
		}
		
		return false;
	}
};

class CBTTaskCheckActorSpeedDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCheckActorSpeed';

	editable var checkedActor 	: EStatOwner;
	editable var moveType		: EMoveType;
	editable var operator 		: EOperator;
	editable var customSpeed	: bool;
	editable var moveSpeed		: float;
	
	default moveType = MT_Run;
	default operator = EO_GreaterEqual;
	default moveSpeed = 1.0;
};
