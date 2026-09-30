/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskBruxaSpawn extends IBehTreeTask
{
	public var useNodeWithTag				: bool;
	public var referenceNodeTag				: name;
	public var useTargetInsteadOfOwner		: bool;
	public var useCombatTarget				: bool;
	public var baseOffsetOnCasterRotation	: bool;
	public var rotateEntityToTarget 		: bool;
	public var resourceName 				: name;
	
	public var spawnAfter					: float;
	public var validateSpawnPosition 		: bool;
	public var spawnOnAnimEvent				: name;
	public var spawnOnGameplayEvent			: name;
	public var fxNameOnSpawnEntity			: name;
	public var fxNameOnSpawnOwner			: name;
	public var fxNameAfterSpawnOwner 		: name;
	public var fxNameAfterSpawnDelay 		: float;
	public var connectFxAfterSpawnWithEntity: bool;
	public var bruxaEntityTag				: name;
	public var inheritTagsFromOwner 		: bool;
	public var setBehVarOnSpawn 			: name;
	public var setBehVarValue 				: float;
	public var setAppearanceOnSpawn 		: name;
	public var setEntityAsActionTarget 		: bool;
	public var disableGameplayVisibility 	: bool;
	public var disableVisibility 			: bool;
	public var disableCollisionOnSpawn 		: bool;
	public var stopAllEffectsAfter			: float;
	public var activeDuration 				: float;
	public var teleportInterval 			: float;
	public var minTeleportDistFromTarget 	: float;
	public var maxTeleportDistFromTarget 	: float;
	public var entityTemplate				: CEntityTemplate;
	
	protected var entity 					: CEntity;
	protected var timeStamp 				: float;
	private   var spawned					: bool;
	private   var eventReceived 			: bool;
	
	
	function OnActivate() : EBTNodeStatus
	{
		spawned = false;
		eventReceived = false;
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var spawnPos 			: Vector;
		var spawnRot 			: EulerAngles;
		var teleportTimeStamp 	: float;
		
		
		if ( !entityTemplate )
		{
			entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		}
		
		if( entityTemplate && !IsNameValid( spawnOnGameplayEvent ) && !IsNameValid( spawnOnAnimEvent ) && spawnAfter <= 0 )
		{
			SpawnEntity();
		}
		
		if( spawnAfter > 0 )
		{
			Sleep( spawnAfter );
			if( entityTemplate && !spawned )
			{
				SpawnEntity();
			}
		}
		else
		{
			while ( !eventReceived )
			{
				SleepOneFrame();
			}
			SpawnEntity();
		}
		while ( GetLocalTime() < activeDuration + timeStamp )
		{
			if ( GetLocalTime() > teleportTimeStamp + teleportInterval )
			{
				spawnPos = FindTeleportPosition();
				while( !IsPositionValid( spawnPos ) )
				{
					SleepOneFrame();
					spawnPos = FindTeleportPosition();
				}
				if ( rotateEntityToTarget )
				{
					if ( useCombatTarget )
					{
						spawnRot = VecToRotation( GetCombatTarget().GetWorldPosition() - spawnPos );
					}
					else
					{
						spawnRot = VecToRotation( GetActionTarget().GetWorldPosition() - spawnPos );
					}
				}
				entity.TeleportWithRotation( spawnPos, spawnRot );
				teleportTimeStamp = GetLocalTime();
			}
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		((CActor)entity).EnableCharacterCollisions( true );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( IsNameValid( spawnOnAnimEvent ) && animEventName == spawnOnAnimEvent )
		{
			if( entityTemplate && !spawned )
			{
				eventReceived = true;
			}
			return true;
		}
		
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid( spawnOnGameplayEvent ) && eventName == spawnOnGameplayEvent )
		{
			if( entityTemplate && !spawned )
			{
				eventReceived = true;
			}
			return true;
		}
		
		return false;
	}
	
	final latent function SpawnEntity()
	{
		var spawnPos 	: Vector;
		var spawnRot 	: EulerAngles;
		var tags 		: array<name>;
		var i 			: int;
		
		
		EvaluateSpawnPos( spawnPos, spawnRot );
		if ( validateSpawnPosition )
		{
			while( !IsPositionValid( spawnPos ) )
			{
				SleepOneFrame();
				EvaluateSpawnPos( spawnPos, spawnRot );
			}
		}
		
		entity = theGame.CreateEntity( entityTemplate, spawnPos, spawnRot );
		
		if ( entity )
		{
			if( IsNameValid( bruxaEntityTag ))
			{
				((CGameplayEntity)entity).AddTag( bruxaEntityTag );
			}
			if( inheritTagsFromOwner )
			{
				tags = GetActor().GetTags();
				if ( tags.Size() > 0 )
				{
					for ( i = 0; i < tags.Size() ; i += 1 )
					{
						entity.AddTag( tags[i] );
					}
				}
			}
			if( IsNameValid( setBehVarOnSpawn ) )
			{
				entity.SetBehaviorVariable( setBehVarOnSpawn, setBehVarValue, true );
			}
			if( disableCollisionOnSpawn )
			{
				((CActor)entity).EnableCharacterCollisions( false );
			}
			if( stopAllEffectsAfter > 0 )
			{
				entity.StopAllEffectsAfter( stopAllEffectsAfter );
			}
			if( IsNameValid( setAppearanceOnSpawn ) )
			{
				((CActor)entity).SetAppearance( setAppearanceOnSpawn );
			}
			if( disableGameplayVisibility )
			{
				((CActor)entity).SetGameplayVisibility( false );
			}
			if( disableVisibility )
			{
				((CActor)entity).SetVisibility( false );
			}
			if( IsNameValid( fxNameOnSpawnEntity ) )
			{
				entity.PlayEffect( fxNameOnSpawnEntity );
			}
			if( IsNameValid( fxNameOnSpawnOwner ) )
			{
				GetActor().PlayEffect( fxNameOnSpawnOwner );
			}
			if( IsNameValid( fxNameAfterSpawnOwner ) )
			{
				if ( fxNameAfterSpawnDelay > 0 )
				{
					Sleep( fxNameAfterSpawnDelay );
				}
				if ( connectFxAfterSpawnWithEntity )
				{
					GetActor().PlayEffect( fxNameAfterSpawnOwner, entity );
				}
				else
				{
					GetActor().PlayEffect( fxNameAfterSpawnOwner );
				}
			}
			if( setEntityAsActionTarget )
			{
				SetActionTarget( entity );
			}
			
			( (CNewNPC)entity ).DeriveGuardArea( GetNPC() );
			
			timeStamp = GetLocalTime();
			spawned = true;
		}
	}
	
	final function EvaluateSpawnPos( out pos : Vector, out rot : EulerAngles )
	{
		var spawnPos	: Vector;
		var spawnRot	: EulerAngles;
		var actor		: CActor = GetActor();
		var target		: CActor = GetCombatTarget();
		var node 		: CNode; 
		var entMat		: Matrix;
		
		
		if( useNodeWithTag && referenceNodeTag != 'None' )
		{
			node = theGame.GetNodeByTag( referenceNodeTag );
			
			if( node )
			{
				spawnPos = node.GetWorldPosition();
				spawnRot = node.GetWorldRotation();
			}
		}
		else if( useTargetInsteadOfOwner )
		{
			if( useCombatTarget )
			{
				spawnPos = target.GetWorldPosition();
				spawnRot = target.GetWorldRotation();
			}
			else
			{
				spawnPos = GetActionTarget().GetWorldPosition();
				spawnRot = GetActionTarget().GetWorldRotation();
			}
		}
		else
		{
			spawnPos = actor.GetWorldPosition();
			spawnRot = actor.GetWorldRotation();
		}
		
		if ( baseOffsetOnCasterRotation )
		{
			spawnRot = actor.GetWorldRotation();
		}
		
		if ( rotateEntityToTarget )
		{
			if ( useCombatTarget )
			{
				spawnRot = VecToRotation( target.GetWorldPosition() - spawnPos );
			}
			else
			{
				spawnRot = VecToRotation( GetActionTarget().GetWorldPosition() - spawnPos );
			}
		}
		
		pos = spawnPos;
		rot = spawnRot;
		
		
	}
	
	final function FindTeleportPosition() : Vector
	{
		var randVec 	: Vector = Vector( 0.f, 0.f, 0.f );
		var targetPos 	: Vector;
		var outPos 		: Vector;
		
		targetPos = GetCombatTarget().GetWorldPosition();
		randVec = VecRingRand( minTeleportDistFromTarget, maxTeleportDistFromTarget );
		outPos = targetPos + randVec;
		
		return outPos;
	}
	
	final function IsPositionValid( out whereTo : Vector ) : bool
	{
		var newPos 	: Vector;
		var z 		: float;
		var i 		: int;
		
		
		if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, -1, 1, newPos ) )
		{
			if( theGame.GetWorld().NavigationComputeZ( whereTo, whereTo.Z - 5.0, whereTo.Z + 5.0, z ) )
			{
				whereTo.Z = z;
				if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, 0, 1, newPos ) )
					return false;
			}
			else
			{
				return false;
			}
		}
		
		whereTo = newPos;
		return true;
	}
};

class CBTTaskBruxaSpawnDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskBruxaSpawn';

	editable var useNodeWithTag					: bool;
	editable var referenceNodeTag				: name;
	editable var useTargetInsteadOfOwner		: bool;
	editable var useCombatTarget				: bool;
	editable var baseOffsetOnCasterRotation		: bool;
	editable var rotateEntityToTarget 			: bool;
	editable var resourceName 					: name;
	editable var spawnEntityOnDeathName			: CBehTreeValCName;
	editable var spawnAfter						: float;
	editable var validateSpawnPosition 			: bool;
	editable var spawnOnAnimEvent				: name;
	editable var spawnOnGameplayEvent			: name;
	editable var fxNameOnSpawnEntity			: name;
	editable var fxNameOnSpawnOwner				: name;
	editable var fxNameAfterSpawnOwner 			: name;
	editable var fxNameAfterSpawnDelay 			: float;
	editable var connectFxAfterSpawnWithEntity	: bool;
	editable var bruxaEntityTag					: name;
	editable var inheritTagsFromOwner 			: bool;
	editable var setBehVarOnSpawn 				: name;
	editable var setBehVarValue 				: float;
	editable var setAppearanceOnSpawn 			: name;
	editable var setEntityAsActionTarget 		: bool;
	editable var disableGameplayVisibility 		: bool;
	editable var disableVisibility 				: bool;
	editable var disableCollisionOnSpawn 		: bool;
	editable var stopAllEffectsAfter			: float;
	editable var activeDuration 				: float;
	editable var teleportInterval 				: float;
	editable var minTeleportDistFromTarget 		: float;
	editable var maxTeleportDistFromTarget 		: float;
	
	
	default useCombatTarget 					= true;
	default inheritTagsFromOwner 				= true;
	
	function OnSpawn( task : IBehTreeTask )
	{
		var thisTask : CBTTaskBruxaSpawn; 
		
		thisTask = ( CBTTaskBruxaSpawn )task;
		if ( IsNameValid( GetValCName( spawnEntityOnDeathName ) ) )
		{
			thisTask.resourceName = GetValCName( spawnEntityOnDeathName );
		}
		
	}
	
	
};