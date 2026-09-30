/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EWhaleMovementPatern
{
	EWMP_bySpawnPoint,
	EWMP_towardsPlayer,
	EWMP_awayFromPlayer
	
}
class W3Whale extends CGameplayEntity
{
	var whaleArea : W3WhaleArea;
	
	var destroyTime : float;
	var alwaysSpawned : bool;
	var canBeDestroyed : bool;
	
	var spawnPosition : Vector;
	var spawnRotation : EulerAngles;
	
	
	default canBeDestroyed = false;
	default alwaysSpawned = false;
	
	public function SetDestroyTime(time : float)
	{
		destroyTime = time;
	}
	
	public function SetSpawnPosAndRot(position : Vector, rotation : EulerAngles)
	{
		spawnPosition = position;
		spawnRotation = rotation;
	}
	
	public function SetAlwaysSpawned(always : bool)
	{
		alwaysSpawned = always;
	}
	
	event OnAnimEvent_WhaleDespawn( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if(!alwaysSpawned)
		{
			canBeDestroyed = true;
		}
	}

	event OnAnimEvent_Destroy( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if (canBeDestroyed)
		{
			this.Destroy();
			return true;
		}

		RaiseForceEvent( 'SwimUpStart' );
		if (alwaysSpawned)
		{
			this.Teleport(spawnPosition);
		}
	}

	event OnAnimEvent_PlayEffect( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		PlayEffect( animEventName );
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		RaiseForceEvent( 'SwimUpStart' );

		AddAnimEventCallback( 'whale_despawn', 'OnAnimEvent_WhaleDespawn' );
		AddAnimEventCallback( 'destroy', 'OnAnimEvent_Destroy' );
		AddAnimEventCallback( 'appear', 'OnAnimEvent_PlayEffect' );
		AddAnimEventCallback( 'splash', 'OnAnimEvent_PlayEffect' );
		AddAnimEventCallback( 'tail', 'OnAnimEvent_PlayEffect' );
	}
	
	timer function EachTick( dt : float , id : int)
	{
		var pos : Vector;		
		pos = GetWorldPosition();				
		
		pos.Z = ( theGame.GetWorld().GetWaterLevel( Vector( pos.X, pos.Y, 50 ) ) - 32.f );
		Teleport( Vector( pos.X, pos.Y, pos.Z ) );
	}
	
}

statemachine class W3WhaleArea extends CEntity
{	
	
	editable var whaleSpawnPointTag 		 : name;
	editable var whaleSpawnOffsetY 			 : float;
	editable var minSpawnDistance 			 : float;
	editable var maxSpawnDistance 			 : float;
	editable var spawnFrequencyMin			 : float;
	editable var spawnFrequencyMax			 : float;
	editable var movementPatern				 : EWhaleMovementPatern;
	
	default minSpawnDistance = 35.f;
	default maxSpawnDistance = 60.f;
	default spawnFrequencyMin = 35.f;
	default spawnFrequencyMax = 55.f;
	default whaleSpawnOffsetY = 120.f; 
	default movementPatern = EWMP_awayFromPlayer;
	
	
	
	
	
	
	var whaleTemplate : CEntityTemplate;
	
	default autoState = 'WhaleDefault';
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		GotoStateAuto();
		super.OnSpawned( spawnData );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( activator.GetEntity() == thePlayer )
		{
			SpawnWhale();
			AddTimer( 'CheckWhaleSpawn', RandomSpawnInterval(), true );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( activator.GetEntity() == thePlayer )
		{
			RemoveTimer( 'CheckWhaleSpawn' );
		}
	}

	function RandomSpawnInterval() : float
	{
		var f : float;
		
		f = RandRangeF( spawnFrequencyMax, spawnFrequencyMin );
		
		return f;
	}

	timer function CheckWhaleSpawn( deltaTime : float , id : int)
	{
		var visibleWhale : W3Whale;
		var areaComponent : CAreaComponent;
		var playerInArea : bool;
		
		visibleWhale = (W3Whale)theGame.GetNodeByTag( 'whale' );
		
		areaComponent = ( CAreaComponent )GetComponentByClassName( 'CTriggerAreaComponent' );
		playerInArea = areaComponent.TestEntityOverlap( ( CEntity )thePlayer );
		
		if( !visibleWhale && playerInArea )
		{
			SpawnWhale();
		}
	}
	
	function SpawnWhale()
	{ 
		var wPos : Vector;
		var dir : Vector;
		var wRot : EulerAngles;
        var offset : Vector;
        var plyerPos	: Vector;
        var offsetY : float;
        var spawnP : CNode;
        var spawnsP : array<CNode>;
        var spawnedWhale : W3Whale;
		var timeToDespawn : float;
		var currDistance  : float;
		var i			  : int;
		
		if( whaleSpawnPointTag == '' )
		{
			if ( whaleSpawnOffsetY < 120.f )
			{
				offsetY = 120.f;
			}
			else
			{
				offsetY = whaleSpawnOffsetY;
			}
			
			offset = Vector( -40.f, offsetY, -8.f );
			WhaleSpawnPosition( offset, wPos, wRot );
			
			plyerPos = thePlayer.GetWorldPosition();
			currDistance = VecDistance2D( plyerPos, wPos );
			
			if ( currDistance > minSpawnDistance && currDistance < maxSpawnDistance )
			{
			
				timeToDespawn = RandRangeF( 8.f, 5.f );
				
				spawnedWhale = (W3Whale)theGame.CreateEntity( whaleTemplate, wPos, wRot );
				spawnedWhale.AddTimer( 'EachTick', 0.01f, true );
				spawnedWhale.SetSpawnPosAndRot(wPos, wRot);
				spawnedWhale.ApplyAppearance("whale_01");
				
				
			}
		}
		
		else
		{
			theGame.GetNodesByTag( whaleSpawnPointTag, spawnsP );
			
			for ( i=0; i < spawnsP.Size(); i+= 1)
			{
				spawnP = spawnsP[i];
				
				wPos = spawnP.GetWorldPosition();
				plyerPos = thePlayer.GetWorldPosition();
				wPos.Z = -8.f;
				
				if ( movementPatern == EWMP_awayFromPlayer )
				{
					dir = wPos - plyerPos;
					wRot.Pitch = 0.f;
					wRot.Roll = 0.f;
					wRot.Yaw = VecHeading ( dir );
					
					
				}
				else if ( movementPatern == EWMP_towardsPlayer )
				{
					dir = plyerPos - wPos;
					wRot.Pitch = 0.f;
					wRot.Roll = 0.f;
					wRot.Yaw = VecHeading ( dir );
					
					
				}
				else 
				{				
					wRot = spawnP.GetWorldRotation();
				}
				
				
				currDistance = VecDistance2D( plyerPos, wPos );
				
				if  ( currDistance > minSpawnDistance && currDistance < maxSpawnDistance )
				{
					spawnedWhale = (W3Whale)theGame.CreateEntity( whaleTemplate, wPos, wRot );
					spawnedWhale.AddTimer( 'EachTick', 0.01f, true );
					spawnedWhale.SetSpawnPosAndRot(wPos, wRot);
					spawnedWhale.ApplyAppearance("whale_01");
					return;
				}
			}
		}
	}
	
	function WhaleSpawnPosition( offset : Vector, out positionWS : Vector, out rotationWS : EulerAngles )
	{
		var local2world : Matrix;
        var positionWSInv, dir : Vector;
        var offsetInv : Vector;
        
        offsetInv = offset;
        offsetInv.X = -offset.X;

        local2world = thePlayer.GetLocalToWorld();
        positionWS = VecTransform( local2world, offset );
        positionWSInv = VecTransform( local2world, offsetInv );

        dir = positionWSInv - positionWS;

        rotationWS.Pitch = 0.f;
        rotationWS.Roll = 0.f;
        rotationWS.Yaw = VecHeading( dir );
	}
}

state WhaleDefault in W3WhaleArea
{	
	event OnEnterState( prevStateName : name )
	{
		StateDefault();
		super.OnEnterState( prevStateName );
	}
	
	entry function StateDefault()
	{
		parent.whaleTemplate = (CEntityTemplate)LoadResourceAsync("whale", false);
		Sleep(0.1);
	}
}