/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskFairytaleWitchManager extends IBehTreeTask
{
	private var npc : CNewNPC;
	private var spawnedNpc, spawnedSecondNpc : CNewNPC;
	private var nodeTags : array< name >;
	private var resourceName : array< name >;


	
	private var initialSleepTime : float;
	private var firstNodeTag : name;
	private var secondNodeTag : name;
	private var thirdNodeTag : name;
	private var finalNodeTag : name;
	private var archesporResource : name;
	private var pantherResource : name;


	
	default initialSleepTime = 2.0;
	default firstNodeTag = 'q704_archespore_1';
	default secondNodeTag = 'q704_archespore_3';
	default thirdNodeTag = 'q704_archespore_2';
	default finalNodeTag = 'q704_archespore_4';
	default archesporResource = 'archespor_turret';
	default pantherResource = 'panther_fairytale_witch';




	function Initialize()
	{
		npc = GetNPC();
		
		nodeTags.PushBack( firstNodeTag );
		nodeTags.PushBack( secondNodeTag );
		nodeTags.PushBack( thirdNodeTag );
		nodeTags.PushBack( finalNodeTag );
		
		resourceName.PushBack( archesporResource );
		resourceName.PushBack( pantherResource );
	}




	latent function Main() : EBTNodeStatus
	{
		Sleep( initialSleepTime );
		
		if( npc.GetBehaviorVariable( 'monsterToSpawn' ) == 0.0 )
		{
			ShootProjectile( nodeTags[ 0 ] );
			Sleep( 2.5 );
			Spawn( nodeTags[ 0 ], resourceName[ 0 ], spawnedNpc );
			npc.SetBehaviorVariable( 'monsterToSpawn', 1.0 );
			
			while( spawnedNpc.IsAlive() )
				SleepOneFrame();
		}
		else if( npc.GetBehaviorVariable( 'monsterToSpawn' ) == 1.0 )
		{
			ShootProjectile( nodeTags[ 2 ] );
			Sleep( 2.5 );
			Spawn( nodeTags[ 2 ], resourceName[ 1 ], spawnedNpc );
			npc.SetBehaviorVariable( 'monsterToSpawn', 2.0 );
			
			while( spawnedNpc.IsAlive() )
				SleepOneFrame();
		}
		else if( npc.GetBehaviorVariable( 'monsterToSpawn' ) == 2.0 )
		{
			ShootProjectile( nodeTags[ 3 ] );
			ShootProjectile( nodeTags[ 1 ] );
			Sleep( 2.5 );
			Spawn( nodeTags[ 3 ], resourceName[ 0 ], spawnedNpc );
			Spawn( nodeTags[ 1 ], resourceName[ 1 ], spawnedSecondNpc );
			
			while( spawnedNpc.IsAlive() || spawnedSecondNpc.IsAlive() )
				SleepOneFrame();
		}

		spawnedNpc.StopAllEffects();	
		spawnedNpc = NULL;
		spawnedSecondNpc.StopAllEffects();	
		spawnedSecondNpc = NULL;
		
		
		npc.SetBehaviorVariable( 'shouldBreakFlightLoop', 1.0 );
		
		return BTNS_Active;
	}
	
	private function Spawn( nodeTag : name, spawnResourceName : name, out spawnedNpcEntity : CNewNPC )
	{
		var spawnNode : CNode;
		var entityTemplate : CEntityTemplate;
		var entity : CEntity;
		var position : Vector;
		var rotation : EulerAngles;
		
		spawnNode = theGame.GetNodeByTag( nodeTag );
		
		if( spawnNode )
		{
			entityTemplate = (CEntityTemplate)LoadResource( spawnResourceName );
			
			if( entityTemplate )
			{
				position = spawnNode.GetWorldPosition();
				rotation = spawnNode.GetWorldRotation();
				entity = theGame.CreateEntity( entityTemplate, position, rotation );
				
				spawnedNpcEntity = (CNewNPC)entity;
			}
		}
	}
	
	private function ShootProjectile( nodeTag : name )
	{
		var spawnNode : CNode;
		var entityTemplate : CEntityTemplate;
		var projectile : PoisonProjectile;
		var position : Vector;
		var rotation : EulerAngles;
		var collisionGroups : array<name>;
		
		collisionGroups.PushBack( 'Terrain' );
		collisionGroups.PushBack( 'Static' );
		collisionGroups.PushBack( 'Water' );
		
		spawnNode = theGame.GetNodeByTag( nodeTag );
		entityTemplate = (CEntityTemplate)LoadResource( 'witch_spawn_proj' );
		
		if( spawnNode && entityTemplate )
		{
			position = npc.GetWorldPosition();
			rotation = npc.GetWorldRotation();
			projectile = (PoisonProjectile)theGame.CreateEntity( entityTemplate, position, rotation );
			
			if( projectile )
			{
				position = spawnNode.GetWorldPosition();
				projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, position, 100.0, collisionGroups );
				projectile.PlayEffect( projectile.initFxName );
			}
		}		
	}
}




class BTTaskFairytaleWitchManagerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskFairytaleWitchManager';
}