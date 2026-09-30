/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSpawnFXEntity extends IBehTreeTask
{
	var attachToActor					: bool;
	var useNodeWithTag					: bool;
	var referenceNodeTag				: name;
	var useOnlyOneFXEntity				: bool;
	var useTargetInsteadOfOwner			: bool;
	var useCombatTarget					: bool;
	var baseOffsetOnCasterRotation		: bool;
	var receiveRotationFromGameplayEvent: bool;
	var rotateEntityToTarget 			: bool;
	var capRotationFromOwnerToTarget 	: float;
	var zeroPitchAndRoll 				: bool;
	var attachToSlotName				: name;
	var teleportToComponentName 		: name;
	var toComponentOnWeapon 			: bool;
	var teleportToBoneName 				: name;
	var continuousTeleport 				: bool;
	var snapToGround 					: bool;
	var resourceName					: name;
	var spawnAfter						: float;
	var spawnOnAnimEvent				: name;
	var spawnOnGameplayEvent			: name;
	var delayEntitySpawn 				: float;
	var fxNameOnSpawn					: name;
	var continuousPlayEffectInInterval 	: float;
	var fxEntityTag						: name;
	var destroyEntityAfter				: float;
	var destroyEntityOnAnimEvent		: name;
	var destroyEntityOnDeact			: bool;
	var stopAllEffectsOnDeact 			: bool;
	var stopAllEffectsAfter				: float;
	var zToleranceFromActorRoot 		: float;
	var offsetVector	 				: Vector;
	var additionalRotation				: EulerAngles;
	
	protected var attachedTo 			: CEntity;
	protected var entity 				: CEntity;
	protected var entityTemplate		: CEntityTemplate;
	protected var timeStamp 			: float;
	protected var fxRotation 			: float;
	private   var spawned				: bool;
	private   var eventReceived 		: bool;
	private   var receivedRotationEvent : bool;
	private   var stopped 				: bool;
	private   var boneIdx 				: int;
	
	function OnActivate() : EBTNodeStatus
	{
		spawned = false;
		eventReceived = false;
		stopped = false;
		receivedRotationEvent = false;
		
		if ( IsNameValid( teleportToBoneName ) )
		{
			boneIdx = GetActor().GetBoneIndex( teleportToBoneName );
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var spawnPos : Vector;
		var spawnRot : EulerAngles;
		
		
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		
		if( entityTemplate && !IsNameValid( spawnOnGameplayEvent ) && !IsNameValid( spawnOnAnimEvent ) && spawnAfter <= 0 )
		{
			timeStamp = GetLocalTime();
			while ( receiveRotationFromGameplayEvent && !receivedRotationEvent )
			{
				SleepOneFrame();
			}
			if ( delayEntitySpawn > 0 )
			{
				while ( GetLocalTime() < timeStamp + delayEntitySpawn )
				{
					SleepOneFrame();
				}
			}
			SpawnEntity();
		}
		
		if( spawnAfter > 0 )
		{
			Sleep( spawnAfter );
			timeStamp = GetLocalTime();
			while ( receiveRotationFromGameplayEvent && !receivedRotationEvent )
			{
				SleepOneFrame();
			}
			if( entityTemplate && !spawned )
			{
				if ( delayEntitySpawn > 0 )
				{
					while ( GetLocalTime() < timeStamp + delayEntitySpawn )
					{
						SleepOneFrame();
					}
				}
				SpawnEntity();
			}
		}
		else if ( IsNameValid( spawnOnAnimEvent ) || IsNameValid( spawnOnGameplayEvent ) )
		{
			while ( !eventReceived )
			{
				SleepOneFrame();
			}
			while ( receiveRotationFromGameplayEvent && !receivedRotationEvent )
			{
				SleepOneFrame();
			}
			if ( delayEntitySpawn > 0 )
			{
				while ( GetLocalTime() < timeStamp + delayEntitySpawn )
				{
					SleepOneFrame();
				}
			}
			SpawnEntity();
		}
		if ( IsNameValid( fxNameOnSpawn ) && ( continuousPlayEffectInInterval > 0 || continuousTeleport ) )
		{
			while ( !stopped )
			{
				if ( continuousPlayEffectInInterval > 0 && spawned && GetLocalTime() > timeStamp + continuousPlayEffectInInterval )
				{
					entity.PlayEffect( fxNameOnSpawn );
					timeStamp = GetLocalTime();
				}
				if ( continuousTeleport && entity )
				{
					EvaluatePos( spawnPos, spawnRot );
					entity.TeleportWithRotation( spawnPos, spawnRot );
				}
				SleepOneFrame();
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( stopAllEffectsOnDeact )
		{
			entity.StopAllEffects();
		}
		if( destroyEntityOnDeact && destroyEntityAfter <= 0.0 && entity )
		{
			entity.StopAllEffects();
			entity.DestroyAfter( 1.0 );
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( IsNameValid( spawnOnAnimEvent ) && animEventName == spawnOnAnimEvent )
		{
			if( entityTemplate )
			{
				if ( spawned && animEventType == AET_DurationEnd )
				{
					stopped = true;
				}
				else
				{
					eventReceived = true;
					timeStamp = GetLocalTime();
				}
			}
			return true;
		}
		
		if( IsNameValid( destroyEntityOnAnimEvent ) && animEventName == destroyEntityOnAnimEvent && destroyEntityAfter <= 0.0 && entity )
		{
			entity.StopAllEffects();
			entity.DestroyAfter( 1.0 );
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
				timeStamp = GetLocalTime();
			}
			return true;
		}
		if ( receiveRotationFromGameplayEvent && eventName == 'FxRotation' )
		{
			receivedRotationEvent = true;
			fxRotation = this.GetEventParamFloat(0);
		}
		
		return false;
	}
	
	final latent function SpawnEntity()
	{
		var spawnPos : Vector;
		var ownerPos : Vector;
		var spawnRot : EulerAngles;
		var z 		 : float;
		
		if ( useOnlyOneFXEntity && entity )
			return;
		
		EvaluatePos( spawnPos, spawnRot );
		ownerPos = GetActor().GetWorldPosition();
		z = AbsF( spawnPos.Z - ownerPos.Z );
		
		if ( zToleranceFromActorRoot > 0 && AbsF( spawnPos.Z - ownerPos.Z ) > zToleranceFromActorRoot )
		{
			return;
		}
		
		entity = theGame.CreateEntity( entityTemplate, spawnPos, spawnRot );
		
		if ( entity )
		{
			if ( IsNameValid( fxEntityTag ))
			{
				((CGameplayEntity)entity).AddTag( fxEntityTag );
			}
			
			if ( destroyEntityAfter > 0 )
			{
				entity.DestroyAfter( destroyEntityAfter );
			}
			
			if ( stopAllEffectsAfter > 0 && destroyEntityAfter > stopAllEffectsAfter )
			{
				entity.StopAllEffectsAfter( stopAllEffectsAfter );
			}
			
			if ( attachToActor || IsNameValid( attachToSlotName ) )
			{
				Attach( attachToSlotName );
			}
			
			if( IsNameValid( fxNameOnSpawn ) )
			{
				SleepOneFrame(); 
				entity.PlayEffect( fxNameOnSpawn );
			}
			
			timeStamp = GetLocalTime();
			spawned = true;
		}
	}
	
	final function EvaluatePos( out pos : Vector, out rot : EulerAngles )
	{
		var spawnPos	: Vector;
		var spawnRot	: EulerAngles;
		var actor		: CActor = GetActor();
		var target		: CActor = GetCombatTarget();
		var node 		: CNode; 
		var entMat		: Matrix;
		var normal 		: Vector;
		var angleDist 	: float;
		
		
		if( useNodeWithTag && referenceNodeTag != 'None' )
		{
			node = theGame.GetNodeByTag( referenceNodeTag );
			
			if( node )
			{
				spawnPos = node.GetWorldPosition();
				spawnRot = node.GetWorldRotation();
			}
		}
		else if ( IsNameValid( teleportToBoneName ) )
		{
			TeleportToBoneName( teleportToBoneName, spawnPos, spawnRot );
		}
		else if ( IsNameValid( teleportToComponentName ) && TeleportToComponentName( teleportToComponentName, spawnPos, spawnRot ) )
		{
			
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
		
		if ( !( offsetVector.X == 0 && offsetVector.Y == 0 && offsetVector.Z == 0 ) )
		{
			entMat = MatrixBuiltTRS( spawnPos, spawnRot );
			spawnPos = VecTransform( entMat, offsetVector );
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
		
		if ( receiveRotationFromGameplayEvent )
		{
			spawnRot.Yaw = fxRotation;
		}
		
		if ( snapToGround )
		{
			theGame.GetWorld().StaticTrace( spawnPos + Vector(0,0,1), spawnPos - Vector(0,0,10), spawnPos, normal );
		}
		
		
		
		if ( zeroPitchAndRoll )
		{
			spawnRot.Pitch = 0;
			spawnRot.Roll = 0;
		}
		
		if ( capRotationFromOwnerToTarget > 0 )
		{
			angleDist = AngleDistance( spawnRot.Yaw, actor.GetHeading() );
			if ( AbsF( angleDist ) > capRotationFromOwnerToTarget )
			{
				if ( angleDist > 0 )
				{
					spawnRot.Yaw = actor.GetHeading() + capRotationFromOwnerToTarget;
				}
				else
				{
					spawnRot.Yaw = actor.GetHeading() - capRotationFromOwnerToTarget;
				}
			}
		}
		
		spawnRot.Pitch += additionalRotation.Pitch;
		spawnRot.Yaw += additionalRotation.Yaw;
		spawnRot.Roll += additionalRotation.Roll;
		
		pos = spawnPos;
		rot = spawnRot;
		
		actor.GetVisualDebug().AddSphere( 'fxPos', 1.0, pos, true, Color( 0,0,255 ), 5 );
	}
	
	final function TeleportToBoneName( bone : name, out pos : Vector, out rot : EulerAngles )
	{
		var owner 	: CActor = GetActor();
		
		if ( boneIdx != -1 )
		{
			owner.GetBoneWorldPositionAndRotationByIndex( boneIdx, pos, rot );
			owner.GetVisualDebug().AddSphere( 'fxPos2', 1.0, pos, true, Color( 255,0,0 ), 5 );
		}
		else
		{
			pos = owner.GetWorldPosition();
			rot = owner.GetWorldRotation();
			if ( zeroPitchAndRoll )
			{
				rot.Pitch = 0;
				rot.Roll = 0;
			}
			
			rot.Pitch += additionalRotation.Pitch;
			rot.Yaw += additionalRotation.Yaw;
			rot.Roll += additionalRotation.Roll;
		}
	}
	
	final function Attach( slot : name )
	{
		var loc 	: Vector;
		var rot		: EulerAngles;	
		var owner 	: CActor = GetActor();
		var target  : CActor = GetCombatTarget();
		
		if ( IsNameValid( slot ) )
		{
			if ( useTargetInsteadOfOwner )
			{
				if ( target.HasSlot( slot, true ) )
				{
					entity.CreateAttachment( target, slot );
				}
				else
				{
					entity.CreateAttachment( target, slot );
				}
			}
			else
			{
				if ( owner.HasSlot( slot, true ) )
				{
					entity.CreateAttachment( owner, slot );
				}
				else
				{
					entity.CreateAttachment( owner, slot );
				}
			}
			attachedTo = NULL;
		}
		else
		{
			if ( useTargetInsteadOfOwner )
			{
				attachedTo = target;
			}
			else
			{
				attachedTo = owner;
			}
		}
		
		if ( attachedTo )
		{
			loc = attachedTo.GetWorldPosition();
			rot = attachedTo.GetWorldRotation();
			if ( zeroPitchAndRoll )
			{
				rot.Pitch = 0;
				rot.Roll = 0;
			}
			
			rot.Pitch += additionalRotation.Pitch;
			rot.Yaw += additionalRotation.Yaw;
			rot.Roll += additionalRotation.Roll;
			
			entity.TeleportWithRotation( loc, rot );
		}
	}
	
	final function TeleportToComponentName( componentName : name, out componentPos : Vector, out componentRot : EulerAngles ) : bool
	{
		var weaponId 		: SItemUniqueId;
		var weapon 			: CItemEntity;
		var actor 			: CActor = GetActor();
		var component 		: CComponent;
		
		if ( toComponentOnWeapon )
		{
			weaponId = actor.GetInventory().GetItemFromSlot( 'r_weapon' );
			weapon = actor.GetInventory().GetItemEntityUnsafe( weaponId );
			if ( !weapon )
			{
				weaponId = actor.GetInventory().GetItemFromSlot( 'l_weapon' );
				weapon = actor.GetInventory().GetItemEntityUnsafe( weaponId );
			}
			if ( !weapon )
			{
				return false;
			}
			
			component = weapon.GetComponent(componentName);
			if( !component )
			{
				return false;
			}
			
			componentPos   = weapon.GetWorldPosition() + component.GetLocalPosition();
			componentRot   = weapon.GetWorldRotation();
		}
		else
		{
			component = actor.GetComponent(componentName);		
			if( !component )
			{
				return false;
			}
			
			componentPos   = actor.GetWorldPosition() + component.GetLocalPosition();
			componentRot   = actor.GetWorldRotation();
		}
		
		return true;
	}
};

class CBTTaskSpawnFXEntityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSpawnFXEntity';

	editable var resourceName					: name;
	editable var attachToActor					: bool;
	editable var useNodeWithTag					: bool;
	editable var useOnlyOneFXEntity				: bool;
	editable var referenceNodeTag				: name;
	editable var useTargetInsteadOfOwner		: bool;
	editable var useCombatTarget				: bool;
	editable var attachToSlotName				: name;
	editable var teleportToBoneName 			: name;
	editable var teleportToComponentName 		: name;
	editable var toComponentOnWeapon 			: bool;
	editable var snapToGround 					: bool;
	editable var continuousTeleport 			: bool;
	editable var spawnAfter						: float;
	editable var spawnOnAnimEvent				: name;
	editable var spawnOnGameplayEvent			: name;
	editable var delayEntitySpawn 				: float;
	editable var fxNameOnSpawn					: name;
	editable var continuousPlayEffectInInterval : float;
	editable var fxEntityTag					: name;
	editable var destroyEntityAfter				: float;
	editable var destroyEntityOnAnimEvent		: name;
	editable var destroyEntityOnDeact			: bool;
	editable var stopAllEffectsOnDeact 			: bool;
	editable var stopAllEffectsAfter			: float;
	editable var zToleranceFromActorRoot 		: float;
	editable var offsetVector	 				: Vector;
	editable var additionalRotation				: EulerAngles;
	editable var baseOffsetOnCasterRotation		: bool;
	editable var rotateEntityToTarget 			: bool;
	editable var capRotationFromOwnerToTarget 	: float;
	editable var receiveRotationFromGameplayEvent: bool;
	editable var zeroPitchAndRoll 				: bool;
	
	default useCombatTarget = true;
	
	hint fxEntityTag = "fx entity has to be of CGameplayEntity class to add tag";
	hint useTargetInsteadOfOwner = "use target position for fx entity spawn";
	hint useOnlyOneFXEntity = "prevent duplicating fx entity, use in cojunction with TaskManageSpawnFXEntity";
};





class CBTTaskManageSpawnFXEntity extends CBTTaskSpawnFXEntity
{
	public var activateOnAnimEvent					: name;
	public var activateOnGameplayEvent				: name;
	public var activeDuration						: float;
	public var activationCooldown					: float;
	public var teleportFXEntityOnAnimEvent 			: name;
	public var teleportFXEntityOnGameplayEvent 		: name;
	public var teleportInRandomDirection			: bool;
	public var randomPositionPattern				: ESpawnPositionPattern;
	public var randomTeleportMinRange				: float;
	public var randomTeleportMaxRange				: float;
	public var randomTeleportInterval				: float;
	public var teleportZAxisOffsetMin				: float;
	public var teleportZAxisOffsetMax				: float;
	public var fxNameOnRandomTeleportOnNPC			: name;
	public var fxNameOnRandomTeleportOnFXEntity		: name;
	public var fxNameOnTeleportToTargetOnNPC		: name;
	public var fxNameOnTeleportToTargetOnFXEntity 	: name;
	public var connectFXWithTarget					: bool;
	public var destroyEntityOnCombatEnd				: bool;
	
	private var activated							: bool;
	private var lastActivation						: float;
	private var lastDeactivation					: float;
	

	latent function Main() : EBTNodeStatus
	{
		var A,B	: bool;
		
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		
		if( entityTemplate && !IsNameValid( spawnOnGameplayEvent ) && !IsNameValid( spawnOnAnimEvent ) && spawnAfter <= 0 )
		{
			SpawnEntity();
		}
		
		B = IsNameValid( activateOnAnimEvent );
		B = B && IsNameValid( activateOnGameplayEvent );
		
		if ( !B )
			activated = true;
		
		
		while ( true )
		{
			if ( activated && teleportInRandomDirection )
			{
				TeleportFXEntity( true );
				if ( IsNameValid( fxNameOnRandomTeleportOnNPC ) )
				{
					if ( connectFXWithTarget )
						GetNPC().PlayEffect( fxNameOnRandomTeleportOnNPC, entity );
					else
						GetNPC().PlayEffect( fxNameOnRandomTeleportOnNPC );
				}
				if ( IsNameValid( fxNameOnRandomTeleportOnFXEntity ) )
					entity.PlayEffect( fxNameOnRandomTeleportOnFXEntity );
				
				if ( randomTeleportInterval > 0 )
					Sleep( randomTeleportInterval );
			}
			
			if ( activated && ( lastActivation == 0 || !A ) )
			{
				lastActivation = GetLocalTime();
				A = true;
			}
			
			if ( activated && lastActivation + activeDuration < GetLocalTime() )
			{
				lastDeactivation = GetLocalTime();
				activated = false;
			}
			
			if ( lastActivation > 0 && !activated && lastDeactivation + activationCooldown < GetLocalTime() )
			{
				lastActivation = 0;
				activated = false;
			}
			
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( teleportFXEntityOnAnimEvent ) && animEventName == teleportFXEntityOnAnimEvent )
		{
			TeleportFXEntity();
			if ( entity )
			{
				if ( IsNameValid( fxNameOnTeleportToTargetOnNPC ) )
				{
					if ( connectFXWithTarget )
						GetNPC().PlayEffect( fxNameOnTeleportToTargetOnNPC, entity );
					else
						GetNPC().PlayEffect( fxNameOnTeleportToTargetOnNPC );
				}
				if ( IsNameValid( fxNameOnTeleportToTargetOnFXEntity ) )
					entity.PlayEffect( fxNameOnTeleportToTargetOnFXEntity );
			}
			
			return true;
		}
		
		if ( IsNameValid( activateOnAnimEvent ) && animEventName == activateOnAnimEvent )
		{
			activated = true;
			return true;
		}
		
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid( teleportFXEntityOnGameplayEvent ) && eventName == teleportFXEntityOnGameplayEvent )
		{
			TeleportFXEntity();
			if ( entity )
			{
				if ( IsNameValid( fxNameOnTeleportToTargetOnNPC ) )
				{
					if ( connectFXWithTarget )
						GetNPC().PlayEffect( fxNameOnTeleportToTargetOnNPC, entity );
					else
						GetNPC().PlayEffect( fxNameOnTeleportToTargetOnNPC );
				}
				if ( IsNameValid( fxNameOnTeleportToTargetOnFXEntity ) )
					entity.PlayEffect( fxNameOnTeleportToTargetOnFXEntity );
			}
			return true;
		}
		
		if ( IsNameValid( activateOnGameplayEvent ) && eventName == activateOnGameplayEvent )
		{
			activated = true;
			return true;
		}
		
		return false;
	}
	
	function OnListenedGameplayEvent( eventName: CName ) : bool
	{
		if ( destroyEntityOnCombatEnd && entity )
			entity.Destroy();
		return true;
	}
	
	function TeleportFXEntity( optional random : bool )
	{
		var spawnPos : Vector;
		var spawnRot : EulerAngles;
		
		if ( random )
			RandomPos( spawnPos, spawnRot );
		else
			EvaluatePos( spawnPos, spawnRot );
		
		if ( entity )
			entity.TeleportWithRotation( spawnPos, spawnRot );
	}
	
	function RandomPos( out pos : Vector, out rot : EulerAngles )
	{
		var randVec 	: Vector;
		var spawnPos 	: Vector;
		var zOffset		: float;
		
		randVec = VecRingRand( randomTeleportMinRange, randomTeleportMaxRange );
		
		if ( randomPositionPattern == ESPP_AroundTarget )
		{
			spawnPos = GetCombatTarget().GetWorldPosition() - randVec;
		}
		else if ( randomPositionPattern == ESPP_AroundSpawner )
		{
			spawnPos = GetActor().GetWorldPosition() - randVec;
		}
		else if ( randomPositionPattern == ESPP_AroundBoth )
		{
			if ( RandRange( 2 ) == 1 )
				spawnPos = GetCombatTarget().GetWorldPosition() - randVec;
			else
				spawnPos = GetActor().GetWorldPosition() - randVec;
		}
		
		zOffset = RandRangeF( teleportZAxisOffsetMax, teleportZAxisOffsetMin );
		spawnPos.Z += zOffset;
		pos = spawnPos;
	}
};

class CBTTaskManageSpawnFXEntityDef extends CBTTaskSpawnFXEntityDef
{
	editable var activateOnAnimEvent				: name;
	editable var activateOnGameplayEvent			: name;
	editable var activeDuration						: float;
	editable var activationCooldown					: float;
	editable var teleportFXEntityOnAnimEvent 		: name;
	editable var teleportFXEntityOnGameplayEvent 	: name;
	editable var teleportInRandomDirection			: bool;
	editable var randomPositionPattern				: ESpawnPositionPattern;
	editable var randomTeleportMinRange				: float;
	editable var randomTeleportMaxRange				: float;
	editable var randomTeleportInterval				: float;
	editable var teleportZAxisOffsetMin				: float;
	editable var teleportZAxisOffsetMax				: float;
	editable var fxNameOnRandomTeleportOnNPC		: name;
	editable var fxNameOnRandomTeleportOnFXEntity	: name;
	editable var fxNameOnTeleportToTargetOnNPC		: name;
	editable var fxNameOnTeleportToTargetOnFXEntity	: name;
	editable var connectFXWithTarget				: bool;
	editable var destroyEntityOnCombatEnd			: bool;
	
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'LeavingCombat' );
	}
	
	default instanceClass = 'CBTTaskManageSpawnFXEntity';
};