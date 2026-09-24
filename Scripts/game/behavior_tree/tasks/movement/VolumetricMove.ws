/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CBTTaskVolumetricMove extends IBehTreeTask
{
	var useCombatTarget : bool;
	
	var npc : CNewNPC;
	var target : CNode;
	var dest : Vector;
	
	var npcPos : Vector;
	var targetPos : Vector;
	
	var targetToNpcVec : Vector;
	var npcToTargetVec : Vector;
	
	var path : array<Vector>;	
	
	protected var m_collisionGroupsNames 	: array<name>;
	
	private var m_resetSweep			: bool; default m_resetSweep = true;
	private var m_sweepId				: SScriptSweepId;
	private var m_traceManager			: CScriptBatchQueryAccessor;
	private var m_lastSweepResult		: bool;
	
	function UsePathfinding( currentPosition : Vector, out targetPosition : Vector, optional predictionDist : float ) : bool
	{
		if( theGame.GetVolumePathManager().IsPathfindingNeeded( currentPosition, targetPosition ) )
		{
			path.Clear();
			if ( theGame.GetVolumePathManager().GetPath( currentPosition, targetPosition, path ) )
			{
				targetPosition = path[1];
				return true;
			}
			return false;
			
		}
		return true;
	}
	
	function CalculateBehaviorVariables( dest : Vector )
	{
		var flySpeed					: float;
		var flyPitch, flyYaw 			: float;
		var turnSpeedScale				: float;
		var npcToDestVector				: Vector;
		var npcToDestVector2			: Vector;
		var npcToDestDistance			: float;
		var npcToDestAngle				: float;
		var npcPos, npcHeadingVec		: Vector;
		var npc 						: CNewNPC;
		var normal, collision			: Vector;
		
		npc = GetNPC();
		npcPos = npc.GetWorldPosition();
		npcHeadingVec = npc.GetHeadingVector();
		
		npcToDestVector = dest - npcPos;		
		npcToDestVector2 = npcToDestVector;
		npcToDestVector2.Z = 0;
		npcToDestDistance = VecDistance( npcPos, dest );
		
		
		npcToDestAngle = AbsF( AngleDistance( VecHeading( dest - npcPos ), VecHeading( npcHeadingVec ) ) );
		
		if ( npcToDestAngle > 60 || npcToDestAngle < -60 )
		{
			flySpeed = 1.f;
		}
		else
		{
			flySpeed = 2.f;
		}

		turnSpeedScale = 2.75f;
	
		
		flyPitch = Rad2Deg( AcosF( VecDot( VecNormalize( npcToDestVector ), VecNormalize( npcToDestVector2 ) ) ) );
		if ( npcPos.X == dest.X && npcPos.Y == dest.Y )
		{
			flyPitch = 90;
		}
		
		flyPitch = flyPitch/90;
		flyPitch = flyPitch * PowF( turnSpeedScale, flyPitch );

		if ( flyPitch > 1 )
		{
			flyPitch = 1.f;
		}
		else if ( flyPitch < -1 )
		{
			flyPitch = -1.f;
		}
		
		if ( dest.Z < npcPos.Z )
		{
			flyPitch *= -1;
		}
		
		
		flyYaw = AngleDistance( VecHeading( npcToDestVector ), VecHeading( npcHeadingVec ) ) ;
		flyYaw = flyYaw / 180;
		flyYaw = flyYaw * PowF( turnSpeedScale , AbsF( flyYaw ) );
		
		if ( flyYaw > 1 )
		{
			flyYaw = 1.f;
		}
		else if ( flyYaw < -1 )
		{
			flyYaw = -1.f;
		}
		
		
		
		if( flyYaw > -0.5 && flyYaw < 0.5 && theGame.GetWorld().StaticTrace( npcPos, npcPos + npc.GetWorldForward(), collision, normal ) )
		{
			
			
			flyYaw = -1;
		}
		
		if( flyYaw < -0.5 && theGame.GetWorld().StaticTrace( npcPos, npcPos + npc.GetWorldRight(), collision, normal ) )
		{
			flyYaw  = 1;			
			
			
		}
		
		else if ( flyYaw > 0.5 && theGame.GetWorld().StaticTrace( npcPos, npcPos + ( npc.GetWorldRight() * -1 ) , collision, normal ) )
		{
			flyYaw  = -1;
			
			
		}	
		
		
		
		npc.SetBehaviorVariable( 'FlyYaw', flyYaw );
		npc.SetBehaviorVariable( 'FlyPitch', flyPitch );
		npc.SetBehaviorVariable( 'FlySpeed', flySpeed );
		
		DebugDisplayDestination( dest );
		
	}
	
	function DebugDisplayDestination( dest : Vector )
	{
		var npc  : CNewNPC = GetNPC();
		npc.GetVisualDebug().AddText( 'VolumetricDestinationText', "Volumetric move Dest", dest + Vector(0,0,0.4f), true, 0, Color( 255, 0, 0 ), true, 1 );
		npc.GetVisualDebug().AddSphere( 'VolumetricDestinationSphere', 0.3f, dest, true, Color( 255, 0, 0 ), 1 );
		npc.GetVisualDebug().AddArrow('ToVolumetricDestination', npc.GetWorldPosition(), dest, 0.8f, 0.5f, 0.6f, true, Color( 255, 0, 0 ), true, 1 );
	}
	
	function TargetSelection()
	{
		if ( useCombatTarget )
			target = GetCombatTarget();
		else
			target = GetActionTarget();
	}
	
	function UpdatePositions()
	{
		UpdateNpcPosition();
		UpdateTargetPosition();
	}
	
	function UpdateNpcPosition()
	{
		npcPos = npc.GetWorldPosition();
	}
	
	function UpdateTargetPosition()
	{
		targetPos = target.GetWorldPosition();
	}
	
	function CalculateTargetToNpcVec()
	{
		targetToNpcVec = npcPos - targetPos;
	}
	
	function CalculateNpcToTargetVec()
	{
		npcToTargetVec = targetPos - npcPos;
	}
	
	function HasVolumetricSpaceAround( _Pos : Vector, _SpaceNeeded : float, optional _CollisionGroupsNames : array<name> ) : bool
	{		
		var l_batchQueryState		: EBatchQueryState;
		var l_sweepResults			: array<SSweepHitResult>;
		
		if( !m_traceManager )
		{
			m_traceManager = theGame.GetWorld().GetTraceManager();
		}		
		
		if( m_resetSweep )
			m_sweepId 	= m_traceManager.SweepAsync( _Pos - Vector( 0, 0, _SpaceNeeded * 0.5 ), _Pos + Vector( 0, 0, _SpaceNeeded * 0.5 ), _SpaceNeeded * 0.5f, _CollisionGroupsNames, EQQF_IMPACT );		
		
		l_batchQueryState 	= m_traceManager.GetSweepState( m_sweepId, l_sweepResults );
		
		switch ( l_batchQueryState )
		{	
			case BQS_NotReady:
				return m_lastSweepResult;
			case BQS_Processed:
				
				if( l_sweepResults.Size() > 0 )
				{
					m_lastSweepResult 	= false;
					m_resetSweep  		= true;
					return false;
				}
			break;
			
		}
		
		m_lastSweepResult = true;
		return true;
	}
}