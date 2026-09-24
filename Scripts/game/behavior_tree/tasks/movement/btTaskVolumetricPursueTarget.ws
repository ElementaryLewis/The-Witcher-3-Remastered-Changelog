/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskVolumetricPursueTarget extends CBTTaskVolumetricMove
{
	var distanceOffset : float;
	var heightOffset : float;
	var minDistance : float;
	var minHeight : float;
	
	var completeWithSucces : bool;
	var useAbsoluteHeightDifference : bool;
	var checkDistanceWithoutOffsets : bool;
	var skipHeightCheck : bool;
	
	var distanceDiff : float;
	var heightDiff : float;
	
	var isMinHeightNegative : bool;
	
	latent function Main() : EBTNodeStatus
	{
		npc = GetNPC();
		
		TargetSelection();
		IsMinHeightNegativeInit();
		
		while( true )
		{
			UpdatePositions();
			CalculateNpcToTargetVec();
			FlyPursueSetDest();
			CalculateDifferences();
			
			if ( ( minDistance || minHeight != 0.0 ) && distanceDiff <= minDistance )
			{
				if( skipHeightCheck || ( !isMinHeightNegative && heightDiff <= minHeight ) || ( isMinHeightNegative && heightDiff >= minHeight ) )
				{
					if ( completeWithSucces )
						return BTNS_Completed;
					else
						return BTNS_Failed;
				}
			}
			
			UsePathfinding( npcPos, dest, 2.0 );
			CalculateBehaviorVariables( dest );
			
			Sleep( 0.1f );
		}
		
		return BTNS_Active;
	}
	function IsMinHeightNegativeInit()
	{
		if( minHeight > 0.0 )
			isMinHeightNegative = false;
		else
			isMinHeightNegative = true;
	}
	
	function FlyPursueSetDest()
	{
		dest = targetPos + VecNormalize( npcToTargetVec ) * distanceOffset;
		dest.Z += heightOffset;
	}
	
	function CalculateDifferences()
	{
		if( checkDistanceWithoutOffsets )
		{
			distanceDiff = VecDistance2D( npcPos, targetPos );
			heightDiff = GetHeightDiff( npcPos, targetPos, useAbsoluteHeightDifference );
		}
		else
		{
			distanceDiff = VecDistance2D( npcPos, dest );
			heightDiff = GetHeightDiff( npcPos, dest, useAbsoluteHeightDifference );
		}
	}
	
	function GetHeightDiff( src : Vector, dest : Vector, absoluteDiff : bool ) : float
	{
		var heightDiff : float;
		
		heightDiff = src.Z - dest.Z;
		if( absoluteDiff )
			heightDiff = AbsF( heightDiff );
			
		return heightDiff;
	}
}

class CBTTaskVolumetricPursueTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskVolumetricPursueTarget';

	editable var distanceOffset : float;
	editable var heightOffset : float;
	editable var minDistance : float;
	editable var minHeight : float;
	
	editable var completeWithSucces : bool;
	editable var useAbsoluteHeightDifference : bool;
	editable var checkDistanceWithoutOffsets : bool;
	editable var skipHeightCheck : bool;
	editable var useCombatTarget : bool;
	
	default distanceOffset = 0.0;
	default heightOffset = 0.0;
	default minDistance = 10.0;
	default minHeight = 2.0;
	
	default completeWithSucces = true;
	default useAbsoluteHeightDifference = false;
	default checkDistanceWithoutOffsets = true;
	default skipHeightCheck = true;
	default useCombatTarget = true;
};



class CBTTaskVolumetricFlyAroundTarget extends CBTTaskVolumetricMove
{
	var distance : float;
	var height : float;
	var flightMaxDuration : float;
	
	var npcToDestDistance : float;
	var flightStartTime : float;
	var flightDuration : float;
	
	latent function Main() : EBTNodeStatus
	{
		npc = GetNPC();
		
		TargetSelection();
		UpdatePositions();
		UpdateTargetToNpcVec();
		FlyAroundSetInitialDest();
		StartFlightTimeCounting();
		
		while( true )
		{
			UpdatePositions();
			UpdateNpcToDestDistance();
			
			if( npcToDestDistance < 8.0 )
			{
				UpdateTargetToNpcVec();
				FlyAroundSetDest();
			}
			
			UsePathfinding( npcPos, dest, 2.0 );
			CalculateBehaviorVariables( dest );
			
			Sleep( 0.1f );
			
			if( CheckFlightTime() )
				return BTNS_Completed;
		}
		
		return BTNS_Active;
	}
	
	function UpdateTargetToNpcVec()
	{
		CalculateTargetToNpcVec();
		targetToNpcVec.Z = 0;
	}
	
	function FlyAroundSetInitialDest()
	{
		dest = targetPos + VecNormalize( targetToNpcVec ) * distance;
		dest.Z += height;
	}
	
	function FlyAroundSetDest()
	{
		dest = targetPos + VecNormalize( targetToNpcVec ) * distance + VecNormalize( npc.GetHeadingVector() ) * 10.0;
	
		if( dest.Z < height )
			dest.Z += height;
	}
	
	function StartFlightTimeCounting()
	{
		flightStartTime = this.GetLocalTime();
	}
	
	function CheckFlightTime() : bool
	{
		flightDuration = this.GetLocalTime();
		
		if( flightDuration > flightStartTime + flightMaxDuration && flightMaxDuration != -1.0 )
			return true;
		else
			return false;
	}
	
	function UpdateNpcToDestDistance()
	{
		npcToDestDistance = VecDistance( npcPos, dest );
	}
}

class CBTTaskVolumetricFlyAroundTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskVolumetricFlyAroundTarget';

	editable var distance : float;
	editable var height : float;
	editable var flightMaxDuration : float;
	editable var useCombatTarget : bool;
};