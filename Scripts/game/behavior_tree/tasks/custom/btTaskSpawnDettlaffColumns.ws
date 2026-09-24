/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSpawnDettlaffColumns extends IBehTreeTask
{
	
	var owner 							: CNewNPC;
	var tempActor 						: CActor;
	var entity 							: CEntity;
	editable var amountToSpawn			: int;
	editable var minDistanceFromTarget	: float;
	editable var maxDistanceFromTarget	: float;
	editable var minDistFromEachOther	: float;
	editable var tagToFind				: name;
	var entityToFind					: CEntity;
	editable var entityTemplate			: CEntityTemplate;
	editable var shouldComplete			: bool;
	var summonerComponent				: W3SummonerComponent;
	var usedPos							: array<Vector>;
	
	latent function Main() : EBTNodeStatus
	{
		var i : int;
		var pos : Vector;
			
		entityToFind = theGame.GetEntityByTag( tagToFind );
		summonerComponent = (W3SummonerComponent) GetNPC().GetComponentByClassName('W3SummonerComponent');
		
		for( i=0; i<amountToSpawn; i+=1 )
		{
			pos = FindPosition();
			
			while( !IsPositionValid( pos ) )
			{
				SleepOneFrame();
				pos = FindPosition();
			}
			
			Spawn( pos );
			usedPos.PushBack( pos );
			if( i==0 )
			{
				entity.AddTag( 'arena_support_1' );
			}
			else if( i==1 )
			{
				entity.AddTag( 'arena_support_2' );
			}
			else if( i==2 )
			{
				entity.AddTag( 'arena_support_3' );
			}
		}
		
		if( shouldComplete )
		{
			return BTNS_Completed;
		}
		else
		{
			return BTNS_Active;
		}
	}
	
	private function IsPositionValid( testedPos : Vector ) : bool
	{
		var radius 	: float;
		var newPos 	: Vector;
		var i	 	: int;
		var z 		: float;
		
		radius = 1.f;
		
		if( !theGame.GetWorld().NavigationFindSafeSpot( testedPos, radius, radius*3, newPos ) )
		{
			if( theGame.GetWorld().NavigationComputeZ( testedPos, testedPos.Z - 5.0, testedPos.Z + 5.0, z ) )
			{
				testedPos.Z = z;
				if( !theGame.GetWorld().NavigationFindSafeSpot( testedPos, radius, radius*3, newPos ) )
					return false;
			}
			return false;
		}
		
		for( i = 0; i < usedPos.Size(); i += 1 )
		{
			if( VecDistance2D( newPos, usedPos[i] ) < minDistFromEachOther )
			return false;
		}
		
		testedPos = newPos;
		
		return true;
	}

	private function FindPosition() : Vector
	{
		var basePos : Vector;
		var outPos : Vector;
		var randVec : Vector = Vector( 0.f, 0.f, 0.f );
		
		basePos = entityToFind.GetWorldPosition();
		randVec = VecRingRand( minDistanceFromTarget, maxDistanceFromTarget );
		
		outPos = basePos + randVec;
		
		return outPos;
	}
	
	private function Spawn( position : Vector )
	{
		var rotation		: EulerAngles;
		var tempvec			: Vector;
		
		if( entityTemplate )
		{
			rotation.Pitch = 0;
			rotation.Roll = 0;
			rotation.Yaw = VecHeading( entityToFind.GetWorldPosition() - position );
			tempvec = entityToFind.GetWorldPosition();
			
			GetActor().GetVisualDebug().AddSphere( 'TeleportPosition', 5.5, tempvec, true, Color( 0,0,255 ), 5.0f );
			
			entity = theGame.CreateEntity( entityTemplate, position );
			tempActor = (CActor)entity;
			
			
			summonerComponent.AddEntity( entity );
		}
		
	}
	
	function RotateByMovementAdjustor()
	{
		var ticket 						: SMovementAdjustmentRequestTicket;
		var movementAdjustor			: CMovementAdjustor;
		
		movementAdjustor = tempActor.GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelAll();
		ticket = movementAdjustor.CreateNewRequest( 'ColumnRotation' );
		movementAdjustor.MaxRotationAdjustmentSpeed( ticket, 10000.f );
		movementAdjustor.RotateTowards( ticket, entityToFind );
	}
}
class CBTTaskSpawnDettlaffColumnsDef extends IBehTreeTaskDefinition
{
	default instanceClass ='CBTTaskSpawnDettlaffColumns';
	
	var owner 							: CNewNPC;
	var tempActor 						: CActor;
	var entity 							: CEntity;
	editable var amountToSpawn			: int;
	editable var minDistanceFromTarget	: float;
	editable var maxDistanceFromTarget	: float;
	editable var minDistFromEachOther	: float;
	editable var tagToFind				: name;
	var entityToFind					: CEntity;
	editable var entityTemplate			: CEntityTemplate;
	editable var shouldComplete			: bool;
	var summonerComponent				: W3SummonerComponent;
	var usedPos							: array<Vector>;
	
	default shouldComplete = true;
}