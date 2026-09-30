/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskFlyAroundTarget extends CBTTaskVolumetricMove
{
	var distance					: float;
	var frontalHeadingOffset		: int;
	var randomFactor				: int;
	var height						: float;
	var randomHeightAmplitude		: float;
	
	
	private var collisionGroupsNames : array<name>;
	
	latent function Main() : EBTNodeStatus
	{
		var npc 						: CNewNPC;
		var npcPos						: Vector;	
		var anchorPointPos				: Vector;
		
		var anchorPointToDestDist		: float;
		var anchorPointToNpcVector		: Vector;
		var crossZ						: float;
		
		var random : float;
		var traceStartPos, traceEndPos, traceEffect, normal, heading : Vector;
		var world					: CWorld;
		var waterLevel 				: float;
		var groundLevel				: float;
		var groundLevelFound		: bool;
		var dest					: Vector;
		var threshold 				: float;
		
		var fallingBack				: bool;		
		var toDestVector			: Vector;
		var toDestHeading			: float;
		var myHeading				: float;
		
		npc = GetNPC();
		
		world = theGame.GetWorld();
		
		threshold = 0;
		
		while( true )
		{
			anchorPointPos = GetCombatTarget().GetWorldPosition();
			npcPos = npc.GetWorldPosition();
			waterLevel = world.GetWaterLevel(npcPos);
			
			anchorPointToNpcVector = npcPos - anchorPointPos;
			anchorPointToNpcVector.Z = 0;
			anchorPointToNpcVector = VecNormalize( anchorPointToNpcVector );
			heading = npc.GetHeadingVector();
			dest = anchorPointPos + anchorPointToNpcVector * distance;
			
			crossZ = ( anchorPointToNpcVector.X * heading.Y ) - (anchorPointToNpcVector.Y * heading.X );
			if ( ( crossZ >= 0.0 && !fallingBack ) || ( crossZ < 0.0 && fallingBack ) )
			{
				
				dest.X = dest.X - anchorPointToNpcVector.Y * frontalHeadingOffset;
				dest.Y = dest.Y + anchorPointToNpcVector.X * frontalHeadingOffset;
			}
			else
			{
				
				dest.X = dest.X + anchorPointToNpcVector.Y * frontalHeadingOffset;
				dest.Y = dest.Y - anchorPointToNpcVector.X * frontalHeadingOffset;
			}
			
			if( fallingBack )
			{
				
				toDestVector 	= dest - npcPos;				
				toDestHeading 	= VecHeading( toDestVector );
				
				if( AbsF( AngleDistance( toDestHeading, myHeading ) ) < 90 )
				{
					fallingBack = false;
				}
			}	
			
			
			random = RandRange( randomFactor ) - ( randomFactor / 2 );
			
			dest.X = dest.X + random;
			dest.Y = dest.Y + random;
			
			random = RandF()*randomHeightAmplitude - ( randomHeightAmplitude / 2 );
			
			dest.Z = dest.Z + height + random;
			
			
			anchorPointToDestDist = VecDistance( anchorPointPos, dest );
			if( anchorPointToDestDist < distance )
			{
				dest = dest + VecNormalize( dest - anchorPointPos ) * (distance - anchorPointToDestDist); 
			}
			
			
			traceStartPos = dest;
			traceEndPos = traceStartPos;
			
			traceEndPos.Z -= 20;
			
			if( world.StaticTrace( traceStartPos, traceEndPos, traceEffect, normal, collisionGroupsNames ) )
			{
				groundLevel = traceEffect.Z;
				groundLevelFound = true;
			}
			
			if ( groundLevel < waterLevel )
			{
				groundLevel = waterLevel;
				groundLevelFound = true;
			}
			
			if ( groundLevelFound  )
			{
				if( groundLevel > anchorPointPos.Z )
				{
					dest.Z += groundLevel - anchorPointPos.Z;
				}
				
				if ( dest.Z < groundLevel + threshold)
				{
					dest.Z = groundLevel + threshold;
				}
			}
				
			
			
			
			if( !UsePathfinding( npcPos, dest, 2.0 ) && !fallingBack )
			{
				fallingBack = true;
			}
			CalculateBehaviorVariables( dest );
			
			Sleep( 0.1f );
		}
		
		return BTNS_Active;
	}
	
	function Initialize()
	{
		collisionGroupsNames.PushBack('Terrain');
		collisionGroupsNames.PushBack('Foliage');
		collisionGroupsNames.PushBack('Static');
	}
	
}

class CBTTaskFlyAroundTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFlyAroundTarget';

	editable var distance				: CBehTreeValFloat;
	editable var frontalHeadingOffset	: CBehTreeValInt;
	editable var randomFactor			: CBehTreeValInt;
	editable var height					: CBehTreeValFloat;
	editable var randomHeightAmplitude	: CBehTreeValFloat;
};