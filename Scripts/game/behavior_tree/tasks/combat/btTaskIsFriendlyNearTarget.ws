/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskIsFriendlyNearTarget extends IBehTreeTask
{
	var useCombatTarget : bool;
	var considerOwnerAsFriendly : bool;
	var radius : float;
	
	function IsAvailable() : bool
	{
		return CheckIfFriendlyIsInAoe();
	}
	
	final function CheckIfFriendlyIsInAoe() : bool
	{
		var i 					: int;
		var owner 				: CActor;
		var potentialTargets 	: array<CActor>;
		var target				: CNode;
		
		if ( useCombatTarget )
			target = GetCombatTarget();
		else
			target = GetActionTarget();
		
		owner = GetActor();
		
		potentialTargets = GetActorsInRange(target,radius,99,'',true);
		
		if ( potentialTargets.Contains(owner) )
		{
			if ( considerOwnerAsFriendly )
				return true;
			else
				potentialTargets.Remove(owner);
		}
		
		for ( i=0; i<potentialTargets.Size(); i+=1 )
		{
			if ( GetAttitudeBetween( owner, potentialTargets[i] ) == AIA_Friendly )
				return true;
		}
		
		return false;
	}
}
class CBTTaskIsFriendlyNearTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTTaskIsFriendlyNearTarget';

	editable var useCombatTarget : bool;
	editable var considerOwnerAsFriendly : bool;
	editable var radius : float;
	
	default useCombatTarget = true;
	default considerOwnerAsFriendly = true;
	default radius = 4.f;
}




class CBTTaskIsHostileAndNoFriendlyNearTarget extends IBehTreeTask
{
	public var useCombatTarget 			: bool;
	public var radius 					: float;
	
	function IsAvailable() : bool
	{
		return CheckPotentialTargetsInAoe();
	}
	
	final function CheckPotentialTargetsInAoe() : bool
	{
		var i 					: int;
		var owner 				: CActor;
		var potentialTargets 	: array<CActor>;
		var target				: CNode;
		var res					: bool;
		var att					: EAIAttitude;
		
		if ( useCombatTarget )
			target = GetCombatTarget();
		else
			target = GetActionTarget();
		
		owner = GetActor();
		
		potentialTargets = GetActorsInRange(target,radius,99,'',true);
		
		if ( potentialTargets.Contains(owner) )
		{
			return false;
		}
		
		for ( i=0; i<potentialTargets.Size(); i+=1 )
		{
			att = GetAttitudeBetween( owner, potentialTargets[i] );
			if ( att == AIA_Friendly )
				return false;
			else if ( att == AIA_Hostile )
				res = true;
		}
		
		return res;
	}
}
class CBTTaskIsHostileAndNoFriendlyNearTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTTaskIsHostileAndNoFriendlyNearTarget';

	editable var useCombatTarget : bool;
	editable var radius : float;
	
	
	default useCombatTarget = true;
	default radius = 4.f;
}