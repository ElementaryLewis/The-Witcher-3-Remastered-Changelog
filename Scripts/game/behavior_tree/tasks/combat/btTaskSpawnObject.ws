/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSpawnObject extends IBehTreeTask
{
	
	var useThisTask				: bool;
	var objectTemplate 			: CEntityTemplate;
	var useAnimEvent			: bool;
	var spawnAnimEventName		: name;
	var useCombatTarget			: bool;
	var spawnNodeTag 			: name;
	var spawnAtBonePosition 	: bool;
	var boneName 				: name;
	var spawnOnGround 			: bool;
	var groundZCheck			: float;
	var spawnPositionOffset		: Vector;
	var offsetInLocalSpace 		: bool;
	var randomizeOffset 		: bool;
	
	
	var spawnNodes				: array<CNode>;
	var i, size 				: int;
	var npc						: CNewNPC;

	
	function InitSpawnObject()
	{
		var spawnNode : CNode;
		
		npc = GetNPC();
		
		if( npc )
		{
			if( useCombatTarget )
			{
				spawnNode = GetCombatTarget();
			}
			else
			{
				spawnNode = npc;
			}
			
			if( spawnNode )
			{
				
				
				spawnNodes.Clear();
				spawnNodes.PushBack( spawnNode );
			}
		}
	}

	function IsAvailable() : bool
	{
		var spawnEntity		: CEntity;
		var boneIndex 		: int;
		var isAvailable 	: bool;
		
		
		
		isAvailable = useThisTask;
		
		
		if( !objectTemplate )
		{
			LogChannel( 'AITasks', "EEROR in NPC tree: " + GetNPC() + " missing editable variable definitions in TaskSpawnObject" );
			isAvailable = false;
		}
	
		return isAvailable;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var spawnEntity		: CEntity;
		var boneIndex 		: int;
		var isAvailable 	: bool;
		
		
		InitSpawnObject();
		
		
		if( spawnNodes.Size() == 0 )
		{
			LogChannel( 'AITasks', "WARNING in NPC tree TaskSpawnObject, spawnNodes array is empty, NPC: " + npc );
			isAvailable = false;
		}
		
		
		if( spawnAtBonePosition )
		{
			size = spawnNodes.Size();
			
			for( i = 0; i < size; i += 1)
			{
				spawnEntity = (CEntity)spawnNodes[i];
				
				
				if( !spawnEntity )
				{
					LogChannel( 'AITasks', "ERROR in NPC tree: " + GetNPC() + " spawnNode with specified spawnNodeTag: " + spawnNodeTag + " in TaskSpawnObject is not an Entity and spawnAtBonePosition property is set to true" );
					isAvailable = false;
				}
				else
				{
					boneIndex = spawnEntity.GetBoneIndex( boneName );
					
					
					if( boneIndex == -1 )
					{
						LogChannel( 'AITasks', "ERROR in NPC tree: " + GetNPC() + " spawnNode with specified spawnNodeTag: " + spawnNodeTag + " in TaskSpawnObject has no bones with specified boneName: " + boneName );
						isAvailable = false;
					}
				}
			}
			
		}
		
		if( !useAnimEvent )
		{
			SpawnObject();
		}
		
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == spawnAnimEventName && useAnimEvent )
		{
			SpawnObject();
			return true;
		}
		return false;
	}
	
	function OnDeactivate()
	{
	}
	function FindPositionOnGround( out position : Vector )
	{

		var minZPosition, maxZPosition, groundPosition, normal : Vector;
		
		groundPosition = position;
		
		minZPosition = position;
		minZPosition.Z -= groundZCheck;
		
		maxZPosition = position;
		maxZPosition.Z += groundZCheck;
		
		if( theGame.GetWorld().StaticTrace( minZPosition, maxZPosition, groundPosition, normal ) )
		{
			position = groundPosition;
		}
	}
	function SpawnObject()
	{
		var spawnEntity 		: CEntity;
		var spawnPosition 		: Vector;
		var boneIndex 			: int;
		var willSpawn			: bool;
		var localToWorldMatrix	: Matrix;
		var spawnOffset			: Vector;
		
		willSpawn = true;
		
		size = spawnNodes.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			if( spawnAtBonePosition )
			{
				spawnEntity = (CEntity)spawnNodes[i];
				boneIndex = spawnEntity.GetBoneIndex( boneName );
				
				if( boneIndex != -1 )
				{
					spawnPosition = spawnEntity.GetBoneWorldPosition( boneName );
				}
				else
				{
					willSpawn = false;
					LogChannel( 'AITasks', "ERROR in NPC tree: " + GetNPC() + " spawnNodein TaskSpawnObject has no bones with specified boneName: " + boneName );
				}
			}
			else
			{
				spawnPosition = spawnNodes[i].GetWorldPosition();
			}
			
			if( offsetInLocalSpace )
			{
				localToWorldMatrix = spawnNodes[i].GetLocalToWorld();
				spawnOffset = spawnPosition - VecTransform( localToWorldMatrix, spawnPositionOffset );
				spawnPosition = spawnPosition + spawnOffset;
			}
			else
			{
				spawnPosition += spawnPositionOffset;
			}
			
			if( spawnOnGround )
			{
				FindPositionOnGround( spawnPosition );
			}
			
			if( willSpawn )
			{
				theGame.CreateEntity( objectTemplate, spawnPosition, spawnNodes[i].GetWorldRotation() );
			}
		}
	}
}

class CBTTaskSpawnObjectDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSpawnObject';

	editable var useThisTask			: bool;
	editable var objectTemplate 		: CEntityTemplate;
	editable var useAnimEvent			: bool;
	editable var spawnAnimEventName		: name;
	
	editable var spawnAtBonePosition 	: bool;
	editable var boneName 				: name;
	editable var spawnOnGround 			: bool;
	editable var groundZCheck			: float;
	editable var spawnPositionOffset 	: Vector;
	editable var offsetInLocalSpace 	: bool;
	editable var randomizeOffset 		: bool;
	
	default useThisTask 				= true;
	default groundZCheck				= 1.5f;
	
	hint useThisTask = "Turn this flag off if you want to disable the task";
	hint objectTemplate = "Choose the spawned object entity template";
	hint useAnimEvent = "Waits for specified anim event to spawn the object";
	hint spawnAnimEventName = "Used when useAnimEvent is true - set the name of the anim event for spawning the object";
	hint spawnNodeTag = "Specify in game object tag - the spawned object will be created at spawnNode position";
	hint spawnAtBonePosition = "Object will be spawned at specified bone of the spawnNode object";
	hint boneName = "The bone name, used only when spawnAtBonePosition is set to true";
	hint spawnOnGround = "Additional test will be performed to ensure that the object will be spawned at ground";
	hint groundZCheck = "+/- distance for checking the ground position";
	hint spawnPositionOffset = "Object will be spawned with specified offset in world coordinates";
	hint offsetInLocalSpace = "Turns the offset to local space of the spawnNode object";
	hint randomizeOffset = "Randomizes each axis of the offset from 0 to spawnPositionOffset range";
}


