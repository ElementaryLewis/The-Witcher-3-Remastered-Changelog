/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskUnderwaterSwimInRandomDirection extends CBTTaskVolumetricMove
{	
	
	
	
	public var stayInGuardArea				: bool;
	public var maxProximityToSurface		: float;
	public var minimumWaterDepth 			: float;
	public var randomizeDirectionDelay 		: SRangeF;
	
	private var m_destinationDistance		: float; default m_destinationDistance = 6;
	
	latent function Main() : EBTNodeStatus
	{
		var l_npc 					: CNewNPC;
		var l_npcPos				: Vector;
		var l_dest					: Vector;
		var l_direction				: Vector;
		var l_guardArea				: CAreaComponent;
		var l_lastRandomization		: float;
		var l_normalToDirection		: Vector;
		var l_delayToNextRand		: float;
		var l_waterLevel 			: float;
			
		var l_testsToProcess				: int;
			
		var l_correctionAngle		: float; 
		var l_testsPerPlane			: int;
		
		l_correctionAngle = 22.5f;
		l_testsPerPlane = RoundF( 360 / l_correctionAngle );
		
		l_npc = GetNPC();
			
		l_guardArea = l_npc.GetGuardArea();
		
		l_delayToNextRand = RandRangeF( randomizeDirectionDelay.max, randomizeDirectionDelay.min );
		
		while( true )
		{
			l_npcPos 	= l_npc.GetWorldPosition();			
			
			
			if( l_lastRandomization == 0 || GetLocalTime() - l_lastRandomization > l_delayToNextRand || !DirectionIsValid( l_npcPos, l_direction, l_guardArea ) )
			{
				l_direction 			= VecRand();
				l_normalToDirection 	= VecCross( l_direction, Vector( 0,0,1 ) );
				l_testsToProcess		= l_testsPerPlane * l_testsPerPlane;
						
				while( l_testsToProcess > 0 && !DirectionIsValid( l_npcPos, l_direction, l_guardArea ) )
				{					
					l_testsToProcess -=1 ;
					
					if( l_testsToProcess % l_testsPerPlane == 0 )
					{
						l_normalToDirection = VecRotateAxis( l_normalToDirection, l_direction, l_correctionAngle );
					}
					
					l_direction = VecRotateAxis( l_direction, l_normalToDirection , l_correctionAngle);					
					
					
					
					if( l_testsToProcess <= 0 )
					{
						
						l_direction 	= l_guardArea.GetWorldPosition() - l_npcPos;
						l_direction 	= VecNormalize( l_direction );
						LogChannel( 'AI_SwimInRandomDirection', l_npc.GetName() + " couldn't find a l_direction to swim to inside the guard area" );
					}					
				}
				
				l_lastRandomization = GetLocalTime();
					
				l_delayToNextRand = RandRangeF( randomizeDirectionDelay.max, randomizeDirectionDelay.min );
			}
			
			l_dest = l_npcPos + VecNormalize( l_direction ) * m_destinationDistance;
			
			
			
			CalculateBehaviorVariables( l_dest );			
			
			l_npc.GetVisualDebug().AddArrow('swimmingArrow', l_npcPos, l_dest, 0.9f, 1, 1, true, Color(255,0,0) );
			
			Sleep( 0.1f );
			
		}
		
		return BTNS_Active;
	}
	
	
	private final function DirectionIsValid( _Pos: Vector, _Direction : Vector, _GuardArea : CAreaComponent ) : bool
	{
		var l_destination	: Vector;
		var l_waterLevel 	: float;
		var l_waterDepth	: float;
		var l_collision		: Vector;
		var l_normal		: Vector;
		
		l_destination = _Pos + VecNormalize( _Direction ) * m_destinationDistance;		
		
		l_waterDepth = theGame.GetWorld().GetWaterDepth( l_destination );
		
		if( l_waterDepth > 1000 ) l_waterDepth = 0;
		
		if( l_waterDepth < minimumWaterDepth )
		{
			return false;
		}
		
		l_waterLevel = theGame.GetWorld().GetWaterLevel( l_destination );
		if( l_destination.Z >= l_waterLevel - maxProximityToSurface )
		{ 
			return false;
		}
		
		if( _GuardArea && stayInGuardArea && !_GuardArea.TestPointOverlap( l_destination )  )
		{
			return false;
		}		
		
		if( theGame.GetWorld().StaticTrace( _Pos, l_destination, l_collision, l_normal ) )
		{
			return false;
		}
		
		if( theGame.GetWorld().SweepTest( l_destination , l_destination + Vector(0,0, 1), 1.5, l_collision, l_normal ) )
		{
			return false;
		}	
		
		return true;
	}
	
	
}

class CBTTaskUnderwaterSwimInRandomDirectionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskUnderwaterSwimInRandomDirection';

	
	
	
	private editable var stayInGuardArea			: bool;
	private editable var maxProximityToSurface		: float;
	private editable var minimumWaterDepth 			: float;
	private editable var randomizeDirectionDelay 	: SRangeF;
	
	default maxProximityToSurface 	= 1;
	default minimumWaterDepth 		= 2;
	default stayInGuardArea 		= true;
};
