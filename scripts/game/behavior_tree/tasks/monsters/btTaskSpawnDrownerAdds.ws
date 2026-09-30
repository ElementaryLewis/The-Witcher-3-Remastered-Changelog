/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSpawnDrownerAdds extends IBehTreeTask
{
	var entityTemplate : CEntityTemplate;

	var hpThreshold : float;
	var spawnCount : int;

	var spawnDistance : float;
	var sideSpacing : float;

	private var alreadySpawned : bool;


	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var hp : float;
		var i : int;

		npc = GetNPC();

		if( !npc )
			return BTNS_Failed;

		
		if( alreadySpawned )
			return BTNS_Failed;


		hp = npc.GetStatPercents( BCS_Essence );

		if( hp > hpThreshold )
			return BTNS_Failed;

		alreadySpawned = true;


		for( i = 0; i < spawnCount; i += 1 )
		{
			SpawnDrownerBehindBoss( npc, i );
		}


		return BTNS_Completed;
	}


	private function SpawnDrownerBehindBoss(owner : CNewNPC, index : int)
	{
		var bossPos : Vector;
		var playerPos : Vector;
		var awayDir : Vector;
		var sideDir : Vector;
		var candidatePos : Vector;
		var spawnPos : Vector;
		var spawnDir : Vector;
		var spawnRot : EulerAngles;
		var ent : CEntity;
		var add : CNewNPC;

		if( !entityTemplate )
			return;

		if( !thePlayer )
			return;

		bossPos = owner.GetWorldPosition();
		playerPos = thePlayer.GetWorldPosition();

		awayDir.X = playerPos.X - bossPos.X;
		awayDir.Y = playerPos.Y - bossPos.Y;
		awayDir.Z = 0.0;
	
		awayDir = VecNormalize2D( awayDir );

		sideDir.X = -awayDir.Y;
		sideDir.Y =  awayDir.X;
		sideDir.Z = 0.0;

		if( index == 0 )
		{
			candidatePos = playerPos + awayDir * ( spawnDistance * 0.5 ) - sideDir * sideSpacing;
		}
		else if( index == 1 )
		{
			candidatePos = playerPos + awayDir * spawnDistance;
		}
		else
		{
			candidatePos = playerPos + awayDir * ( spawnDistance * 0.5 ) + sideDir * sideSpacing;
		}

		candidatePos.Z = playerPos.Z;

		if(
			!theGame.GetWorld().NavigationFindSafeSpot(
				candidatePos,
				-1,
				1,
				spawnPos
			)
		)
		{
			return;
		}

		spawnDir = playerPos - spawnPos;
		spawnDir.Z = 0.0;

		spawnRot = VecToRotation( spawnDir );
		spawnRot.Pitch = 0.0;
		spawnRot.Roll = 0.0;

		ent = theGame.CreateEntity(
			entityTemplate,
			spawnPos,
			spawnRot
		);

		if( !ent )
			return;

		add = (CNewNPC)ent;

		if( !add )
			return;

		add.AddTag( 'kelpie_summon' );

		add.DeriveGuardArea( owner );

		add.SetAttitude( thePlayer, AIA_Hostile );
		add.NoticeActor( thePlayer );
		add.ForceAIUpdate();
	}
}

class CBTTaskSpawnDrownerAddsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSpawnDrownerAdds';


	editable var entityTemplate : CEntityTemplate;

	editable var hpThreshold : float;
	editable var spawnCount : int;

	editable var spawnDistance : float;
	editable var sideSpacing : float;


	default hpThreshold = 0.50;

	default spawnCount = 3;

	default spawnDistance = 5.0;
	default sideSpacing = 2.0;
}