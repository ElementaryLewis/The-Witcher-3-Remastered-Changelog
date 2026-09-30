/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskUnderwaterSwimAroundTarget extends CBTTaskVolumetricMove
{
	public var distance					: float;
	public var frontalHeadingOffset		: int;
	public var randomFactor				: int;
	public var randomHeightAmplitude	: float;	
	public var minimumWaterDepth 		: float;
	public var useActionTarget			: bool;
	public var maxProximityToSurface 	: float;
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_npc 						: CNewNPC;
		var l_npcPos					: Vector;	
		var l_anchorPointPos			: Vector;
		
		var l_anchorPointToDestDist		: float;
		var l_anchorPointToNpcVector	: Vector;
		var l_normalToAnchor			: Vector;
		var l_toDestVector				: Vector;
		var l_toDestHeading				: float;
		var l_myHeading					: float;
		
		var l_random 					: float;
		var l_traceStartPos, l_traceEndPos, l_traceEffect, l_normal : Vector;
		var l_world						: CWorld;
		var l_waterLevel 				: float;
		var l_groundLevel				: float;
		var l_groundLevelFound			: bool;
		var l_dest						: Vector;
		var l_distanceToDest			: float;
		var l_angleToDest				: float;
		
		var l_changeHeading				: bool;
		
		var l_waterDepthAtNextPos		: float;
		var l_currentMult				: int;
		
		l_npc = GetNPC();
		
		l_world = theGame.GetWorld();
		
		while( true )
		{
			if ( useActionTarget )
			{			
				l_anchorPointPos = GetActionTarget().GetWorldPosition();
			}
			else
			{
				l_anchorPointPos = GetCombatTarget().GetWorldPosition();				
			}
			l_npcPos = l_npc.GetWorldPosition();
			l_waterLevel = l_world.GetWaterLevel(l_npcPos);
			
			l_anchorPointToNpcVector = l_npcPos - l_anchorPointPos;
			l_anchorPointToNpcVector.Z = 0;
			
			l_normalToAnchor = VecCross( l_anchorPointToNpcVector, Vector( 0,0,1 ) );
			
			l_myHeading 		= GetNPC().GetHeading();
			
			
			if( l_changeHeading )
			{
				CalculateBehaviorVariables( l_dest );
				
				
				l_toDestVector 	= l_dest - l_npcPos;				
				l_toDestHeading = VecHeading( l_toDestVector );
				l_angleToDest 	= AbsF( AngleDistance( l_toDestHeading, l_myHeading ) );
				if( l_angleToDest < 90 )
				{
					l_changeHeading = false;
				}
				
				DebugDisplayDestination( l_dest );
				
				Sleep( 0.1f );
				continue;			
			}
			
			
			l_dest = l_anchorPointPos + VecNormalize( l_anchorPointToNpcVector ) * distance + VecNormalize( l_normalToAnchor ) * frontalHeadingOffset;
				
			
			l_currentMult		= 1;
			l_toDestVector 	= l_dest - l_npcPos;				
			l_toDestHeading 	= VecHeading( l_toDestVector );
			if( AbsF( AngleDistance( l_toDestHeading, l_myHeading ) ) > 90 )
			{
				l_dest = l_anchorPointPos + VecNormalize( l_anchorPointToNpcVector ) * distance + l_normalToAnchor * frontalHeadingOffset * -1;
				l_currentMult = -1;
			}
			
			
			l_random = RandRange( randomFactor ) - ( randomFactor / 2 );
			
			l_dest.X = l_dest.X + l_random;
			l_dest.Y = l_dest.Y + l_random;
			
			l_random = RandF()*randomHeightAmplitude - ( randomHeightAmplitude / 2 );
			
			l_dest.Z = l_anchorPointPos.Z + l_random;
			
			
			l_anchorPointToDestDist = VecDistance( l_anchorPointPos, l_dest );
			if( l_anchorPointToDestDist < distance )
			{
				l_dest = l_dest + VecNormalize( l_dest - l_anchorPointPos ) * (distance - l_anchorPointToDestDist); 
			}	
			
			
			
			l_traceStartPos = l_dest;
			
			l_traceEndPos = l_traceStartPos;
			l_traceEndPos.Z -= 10;
			
			if( theGame.GetWorld().StaticTrace( l_traceStartPos, l_traceEndPos, l_traceEffect, l_normal, m_collisionGroupsNames ) )
			{
				l_groundLevel = l_traceEffect.Z;
				l_groundLevelFound = true;
			}
			
			if ( l_groundLevelFound )
				l_dest.Z = ClampF(l_dest.Z,l_groundLevel + maxProximityToSurface,l_waterLevel - maxProximityToSurface);
			else
				l_dest.Z = ClampF(l_dest.Z, l_dest.Z, l_waterLevel - maxProximityToSurface);
			
			
			if( !UsePathfinding( l_npcPos, l_dest, 2.0 ) )
			{
				l_traceStartPos 	= l_npcPos;
				l_traceEndPos 	= l_dest;
				
				theGame.GetWorld().StaticTrace( l_traceStartPos, l_traceEndPos, l_dest, l_normal, m_collisionGroupsNames );
			}
			
			l_distanceToDest = VecDistance( l_npcPos, l_dest );
			
			
			l_waterDepthAtNextPos = l_world.GetWaterDepth( l_dest );
			if( l_waterDepthAtNextPos > 1000 ) l_waterDepthAtNextPos = 0;
			if(  l_waterDepthAtNextPos <  minimumWaterDepth || l_distanceToDest < 2 ) 
			{
				l_changeHeading = true;
				l_dest = l_anchorPointPos + VecNormalize( l_anchorPointToNpcVector ) * distance + l_normalToAnchor * frontalHeadingOffset * - 1 * l_currentMult;
				
				l_dest.Z = l_anchorPointPos.Z;
				
				if ( l_groundLevelFound )
					l_dest.Z = ClampF(l_dest.Z,l_groundLevel + maxProximityToSurface,l_waterLevel - maxProximityToSurface);
				else
					l_dest.Z = ClampF(l_dest.Z, l_npcPos.Z, l_waterLevel - maxProximityToSurface);
				
				continue;
			}
			
			DebugDisplayDestination( l_dest );
			
			CalculateBehaviorVariables( l_dest );
			
			Sleep( 0.1f );
		}
		
		return BTNS_Active;
	}	
	
	function Initialize()
	{
		m_collisionGroupsNames.PushBack('Terrain');
		m_collisionGroupsNames.PushBack('Foliage');
		m_collisionGroupsNames.PushBack('Static');
	}
	
}

class CBTTaskUnderwaterSwimAroundTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskUnderwaterSwimAroundTarget';

	editable var distance				: CBehTreeValFloat;
	editable var frontalHeadingOffset	: CBehTreeValInt;
	editable var randomFactor			: CBehTreeValInt;
	editable var randomHeightAmplitude	: CBehTreeValFloat;	
	editable var minimumWaterDepth 		: CBehTreeValFloat;
	editable var useActionTarget 		: CBehTreeValBool;
	editable var maxProximityToSurface	: float;
	
	default maxProximityToSurface = 2;
};
