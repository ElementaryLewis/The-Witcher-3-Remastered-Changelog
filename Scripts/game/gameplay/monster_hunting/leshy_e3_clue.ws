/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ELogicalOperator
{
	AND,
	OR
}
enum EBoidClueState
{
	BCS_Default,
	BCS_Above
}

class W3ClueWaypoint
{
	editable var waypointTag						: name;
	editable var clueStateInWaypoint				: EBoidClueState;
	editable var conditionsLogicalOperator			: ELogicalOperator;
	editable inlined var waypointReachedConditions 	: array< W3ClueCondition >;
	
	public function WaypointReached() : bool
	{
		var waypointNode : CNode;
		var i, size : int;
		var checkResult : bool;
		var finalResult : bool;
			
		waypointNode = theGame.GetNodeByTag( waypointTag );
		
		if( conditionsLogicalOperator == AND )
		{
			finalResult = true;
		}
		else
		{
			finalResult = false;
		}
		
		if( waypointNode )
		{
			size = waypointReachedConditions.Size();
			
			for( i = 0; i < size; i += 1 )
			{
				checkResult = waypointReachedConditions[i].CheckCondition(waypointNode);
					
				if( conditionsLogicalOperator == AND )
				{
					if( checkResult == false )
					{
						return false;
					}
				}
				else if( conditionsLogicalOperator == OR )
				{
					if( checkResult == true )
					{
						return true;
					}
				}
			}
		}
		return finalResult;
	}
}

abstract class W3ClueCondition
{
	public function CheckCondition( waypoint : CNode ) : bool 
	{
		Log("CheckCondition");
		return false;
	}
}

class W3ClueConditionDistance extends W3ClueCondition
{
	editable var distance : float;
	
	default distance = 15.0f;
	
	public function CheckCondition( waypoint : CNode ) : bool
	{
		if( VecDistanceSquared( waypoint.GetWorldPosition(), thePlayer.GetWorldPosition() ) <= distance*distance )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}

class W3ClueConditionFact extends W3ClueCondition
{
	editable var fact : string;
	
	public function CheckCondition( waypoint : CNode ) : bool
	{
			return FactsQuerySum( fact ) > 0;
	}
}


class W3LessunClue extends CFlyingCrittersLairEntityScript
{
	editable inlined var pathWaypoints 	: array< W3ClueWaypoint >;
	editable var factTriggeredAtEnd 	: string;
	editable var loopFlying 			: bool;
	editable var swarmAttractorEntity	: CEntityTemplate;
	
	var isCurrentSoundClue				: bool;
	
	var swarmAttractor 					: CEntity;
	
	var pathIndex : int;
	var clueSeen : bool;
	
	var targetPosition : Vector;
	var destroyTriggered : bool;
	
	var groupPosition : Vector;
	
	var accuracy : float;
	var cameraDir : Vector;
	var camHeading : float;
	var toClueVec : Vector;
	var toClueHeading : float;
	
	var currentClueState : name;
	
	var groupEffectSpawnPointComponent : CComponent;
	
	function GetGroupPos() : Vector
	{
		return groupPosition;
	}
	
	function SetCurrentSoundClue( isCurrent : bool )
	{
		isCurrentSoundClue = isCurrent;
	}

	function FirstActivation( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{
		if( pathIndex < pathWaypoints.Size() )
		{
			SetCurrentState(pathWaypoints[pathIndex].clueStateInWaypoint);
		}
		else
		{
			SetCurrentState(BCS_Default);
		}
		scriptInput.CreateGroup( spawnLimit, 'ClueTarget', currentClueState );
		
		groupEffectSpawnPointComponent = GetComponent( "CSpriteComponent0" );
		SetFocusModeSoundEffectType( FMSET_Gray );
	}

	function OnDeactivated( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{
		SetCurrentSoundClue(false);
		super.OnDeactivated( scriptInput, deltaTime );
	}

	function OnActivated( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{	
		var firstWaypoint : W3ClueWaypoint;
		var node : CNode;
		var pos : Vector;
		var rot : EulerAngles;
		
		targetPosition = GetWorldPosition();
		
		pos = targetPosition;
		rot = GetWorldRotation();
		
		RequestGroupStateChange( 'clue', true );
		
		pathIndex = 0;
		clueSeen = false;
		
		firstWaypoint = pathWaypoints[0];
		
		if( firstWaypoint )
		{
			node = theGame.GetNodeByTag( firstWaypoint.waypointTag );
			if( node )
			{
				pos = node.GetWorldPosition();
				rot = node.GetWorldRotation();
			}
		}
		
		swarmAttractor = theGame.CreateEntity( swarmAttractorEntity, pos, rot );
		
		super.OnActivated( scriptInput, deltaTime );
		
	}
	
	function SetCurrentState( clueState : EBoidClueState )
	{
		switch (clueState)
		{
			case BCS_Default : currentClueState = 'clue'; break;
			case BCS_Above : currentClueState = 'clueAbove'; break;
			default : currentClueState = 'clue';
		}
	}
	
	function OnTick( scriptInput: CFlyingSwarmScriptInput, active : Bool, deltaTime: float )
	{
		var effectNewPosition : Vector;
	
		if( pathIndex < pathWaypoints.Size() )
		{
			if ( pathWaypoints[pathIndex].WaypointReached() )
			{
				MoveClueAway();
			}
		}
		
		if( scriptInput.groupList.Size() > 0)
		{
			groupPosition = scriptInput.groupList[ 0 ].groupCenter;
		}
		
		if( isCurrentSoundClue )
		{
			CalculateSoundAimParameter();
		}
		
		effectNewPosition = groupPosition;
		Teleport( effectNewPosition );
		
		super.OnTick( scriptInput, active, deltaTime );
	}
	
	function CalculateSoundAimParameter()
	{
		var playerCamera : CCustomCamera;
		
		playerCamera = theGame.GetGameCamera();
		
		if( playerCamera )
		{
			cameraDir = theCamera.GetCameraDirection();
			
			cameraDir.Z = 0;
			
			camHeading = VecHeading( cameraDir );
			
			toClueVec =  groupPosition - playerCamera.GetWorldPosition();
			
			toClueVec.Z = 0;
			
			toClueHeading = VecHeading( toClueVec );
			
			if ( toClueHeading < 0.0f ) 
			{
				toClueHeading += 360;
			}
		 
			if ( camHeading < 0.0f )
			{
				camHeading += 360;
			}
				 
			accuracy = camHeading - toClueHeading;
					
			if ( accuracy > 180 )
			{
				accuracy = - ( 360 - accuracy );
			}
		 
			if ( accuracy < - 180 )
			{
				accuracy = 360 + accuracy;
			}
			
			
			
			theSound.SoundGlobalParameter("focus_boid_aim", accuracy);
		}
	}
		
	function MoveClueAway()
	{
		var playerPosition : Vector;
		var currentPosition : Vector;
		var targetNode : CNode;
		var lastWaypoint : bool;
		
		playerPosition = thePlayer.GetWorldPosition();
		currentPosition = GetWorldPosition();
	
		
	
		if ( pathWaypoints.Size() == 0 )
		{
			lastWaypoint = true;
		}
		else
		{
			pathIndex = pathIndex + 1;
			if ( pathIndex >= pathWaypoints.Size() )
			{
				lastWaypoint = true;
				if(loopFlying)
				{
					pathIndex = 0;
				}
				else
				{
					pathIndex = pathWaypoints.Size() - 1;
				}
			}
			
			SetCurrentState(pathWaypoints[pathIndex].clueStateInWaypoint);
			
			targetNode = theGame.GetNodeByTag( pathWaypoints[ pathIndex ].waypointTag );
			
			if( targetNode )
			{
				targetPosition = targetNode.GetWorldPosition();
			}
		}
		if( lastWaypoint )
		{
			if( factTriggeredAtEnd != "" && factTriggeredAtEnd != "None" )
			{
				FactsAdd( factTriggeredAtEnd, 1 );
			}
		}
		
		clueSeen = true;
		
		if( !lastWaypoint || ( lastWaypoint && loopFlying ) )
		{
			RequestGroupStateChange( 'clueFly', true );
			swarmAttractor.Teleport( targetPosition );
			AddTimer( 'ResetClue', 8.0f, false, , , true );
		}
		
		if( lastWaypoint && !loopFlying && !destroyTriggered)
		{
			RequestGroupStateChange( 'clueSpread', true );
			destroyTriggered = true;
			AddTimer( 'TimerDestroyClue', 6.0, false );
		}
	
	}
	
	timer function TimerDestroyClue( timeDelta : float , id : int)
	{
		RequestAllGroupsInstantDespawn( );
	}
	
	timer function ResetClue( timeDelta : float , id : int)
	{
		RequestGroupStateChange( currentClueState, true );
		clueSeen = false;
	}
}