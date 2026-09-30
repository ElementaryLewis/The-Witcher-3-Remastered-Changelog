/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Bird extends CGameplayEntity
{
	editable var flyingAppearanceName : name;
	editable var destroyDistance : float;
	editable var flyCurves : array<name>;
	
	private var manager : CBirdsManager;
	
		hint flyingAppearanceName = "(optional) Set the appearance name to switch to when flying";
		hint destroyDistance = "Distance from camera after which the bird is destroyed";
		hint flyCurves = "Array of names of fly curves - random is picked";
		
		default destroyDistance = 50;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		LogAssert(flyCurves.Size() > 0, "W3Bird.OnSpawned: bird must have at least one fly curve!");
		
		AddAnimEventCallback('ReadyToFly',	'OnAnimEvent_ReadyToFly');
	}
	
	public function SetBirdManager(m : CBirdsManager)
	{
		manager = m;
	}
	
	
	timer function DestructionTimer(dt : float, id : int)
	{
		var isVisible : bool;
		var x, y : float;
	
		isVisible = theCamera.WorldVectorToViewRatio(GetWorldPosition(), x, y);
		if(isVisible && (AbsF(x) > 1.1 && AbsF(y) > 1.1))
			isVisible = false;
	
		if(!isVisible && VecDistance(GetWorldPosition(), theCamera.GetCameraPosition()) > destroyDistance)
		{
			if(manager)
				manager.OnBirdDestroyed(this);
			Destroy();
		}
	}
	
	
	public function Fly() : bool 
	{
		var tryFly : bool;
		
		tryFly = RaiseEvent('Fly');
		AddTimer('DestructionTimer', 1, true);
		
		if(!tryFly || flyCurves.Size() == 0)
			return false;
		
		return true;
	}
	
	event OnAnimEvent_ReadyToFly( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if(IsNameValid(flyingAppearanceName))
			ApplyAppearance(flyingAppearanceName);
		
		PlayPropertyAnimation(flyCurves[RandRange(flyCurves.Size()-1, 0)], 1);
	}
	
	event OnPropertyAnimationFinished(propertyName : name, animationName : name)
	{
		if(manager)
			manager.OnBirdDestroyed(this);
		Destroy();
	}
}

class W3BirdQuest extends W3Bird
{
	public editable var m_focusSoundEffect : EFocusModeSoundEffectType;
	default m_focusSoundEffect = FMSET_None;
	
	hint m_focusSoundEffect = "Focus sound mode for this bird.";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		SetFocusModeSoundEffectType( m_focusSoundEffect );
	}	
	
}





class CBirdSpawnpoint extends CEntity {}




statemachine class CBirdsManager extends CGameplayEntity
{
	editable var birdsSpawnPointsTag : name;
	editable var birdType : EBirdType;
	editable var spawnRange : float;
	editable var customBirdTemplate : CEntityTemplate;
	editable var respawnDelay : float;
	editable var respawnMinDistance : float;
	editable var spawnOnlyInsideBirdsArea : bool; default spawnOnlyInsideBirdsArea = true;
	editable var disableSnapToCollisions : bool;
	
	private var birdSpawnpoints : array<SBirdSpawnpoint>;
	private var shouldBirdsFly : bool;
	private var despawnTime : float;				
	private var wasEverVisible : bool;				
	private var birdArea	   : CTriggerAreaComponent;
	var birdTemplate : CEntityTemplate;
	
		default spawnRange = 50.0;
		default respawnDelay = 15;
		default respawnMinDistance = 15;
		default birdType = Crow;		
		default autoState = 'Default';
		default wasEverVisible = false;
		
		hint respawnMinDistance = "Min distance between manager and camera to allow birds to respawn";
	
 	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		GotoStateAuto();
		super.OnSpawned(spawnData);
	}
	
	
	event OnDetaching()
	{
		var i : int;
		
		for(i = 0; i < birdSpawnpoints.Size(); i += 1)
		{
			if(birdSpawnpoints[i].bird)
				birdSpawnpoints[i].bird.Destroy();
		}
	}
	
	public function SetBirdArea ( area : CTriggerAreaComponent )
	{
		birdArea = area;
	}
	
	private function GetBirdAreaInRange ( range : float ) : CTriggerAreaComponent
	{
		var i : int;
		var birdsAreaEntity : CBirdsArea;
		var entitites : array <CGameplayEntity>;
		var area : CTriggerAreaComponent;
		
		FindGameplayEntitiesInRange ( entitites, this, range, 1000 );
		
		for ( i=0; i < entitites.Size(); i+=1 )
		{
			birdsAreaEntity = (CBirdsArea)entitites[i];
			
			if ( birdsAreaEntity )
			{
				area = (CTriggerAreaComponent)birdsAreaEntity.GetComponentByClassName ( 'CTriggerAreaComponent' );
				
				if ( area.TestEntityOverlap ( this ) )
				{
					return area;
				}
			}
			
		}
		return NULL;
	}
	
	public function OnBirdDestroyed(b : W3Bird)
	{
		var i : int;
		
		
		for(i=0; i<birdSpawnpoints.Size(); i+=1)
		{
			if(birdSpawnpoints[i].bird == b)
			{
				birdSpawnpoints[i].bird = NULL;
				birdSpawnpoints[i].entityId = 0;
				birdSpawnpoints[i].entitySpawnTimestamp = 0.0f;
				birdSpawnpoints[i].isFlying = false;
				break;
			}
		}
		
		for(i=0; i<birdSpawnpoints.Size(); i+=1)
			if(birdSpawnpoints[i].bird)
				return;
		
		despawnTime = theGame.GetEngineTimeAsSeconds();
	}
	
	
	public function FlyBirds()
	{	
		var i, notFlyingBirds : int;
			
		notFlyingBirds = 0;
		
		if ( birdSpawnpoints.Size() > 0 )
		{
			for(i=0; i<birdSpawnpoints.Size(); i+=1)
			{
				if(!birdSpawnpoints[i].isFlying  )
				{
					if ( spawnOnlyInsideBirdsArea && !birdArea.TestEntityOverlap ( birdSpawnpoints[i].bird ))
					{
						continue;
					}
					if(birdSpawnpoints[i].bird)
						birdSpawnpoints[i].isFlying = birdSpawnpoints[i].bird.Fly();
						
					if(!birdSpawnpoints[i].isFlying)
						notFlyingBirds += 1;
				}
			}
		}
		else 
			notFlyingBirds += 1;
		
		shouldBirdsFly = (notFlyingBirds > 0);
	}
	
	public function SpawnBirds(optional forced : bool)
	{
		var i, size : int;
		var x, y : float;
		var isVisible : bool;
		var bird : W3Bird;
		var spawnPos, normal : Vector;
		var traceResult : bool;
		var createEntityHelper : CCreateEntityHelper;
				
		if(!forced)
		{
			
			if(theGame.GetEngineTimeAsSeconds() < (respawnDelay + despawnTime))
				return;
				
			
			if(VecDistance(GetWorldPosition(), theCamera.GetCameraPosition()) < respawnMinDistance)
				return;
		}
		
		
		UpdateSpawnPointsList();
		size = birdSpawnpoints.Size();
		
		for(i = 0; i < size; i += 1)
		{
			if( !birdSpawnpoints[i].bird )
			{
				if( birdSpawnpoints[i].entityId == 0 )
				{
					if(!forced)
					{
						isVisible = theCamera.WorldVectorToViewRatio(birdSpawnpoints[i].position, x, y);
						if(isVisible && (AbsF(x) > 1.1 && AbsF(y) > 1.1))
							isVisible = false;
					}
					
					
					
					if( (!isVisible || forced ) && VecDistance( birdSpawnpoints[i].position, theCamera.GetCameraPosition()) < spawnRange)
					{
						if( disableSnapToCollisions )
						{
							spawnPos = birdSpawnpoints[i].position;
						}
						else
						{
							traceResult = theGame.GetWorld().StaticTrace( birdSpawnpoints[i].position, birdSpawnpoints[i].position - Vector(0,0,255), spawnPos, normal );
							
							
							if( traceResult == false )
							{
								spawnPos = birdSpawnpoints[i].position;		
							}
						}
						
						createEntityHelper = new CCreateEntityHelper;
						createEntityHelper.SetPostAttachedCallback( this, 'OnBirdEntityAttached' );
						birdSpawnpoints[i].entitySpawnTimestamp = theGame.GetEngineTimeAsSeconds();
						birdSpawnpoints[i].entityId = theGame.CreateEntityAsync( createEntityHelper, birdTemplate, spawnPos, birdSpawnpoints[i].rotation );
					}
				}
				else
				{
					
					if( theGame.GetEngineTimeAsSeconds() - birdSpawnpoints[i].entitySpawnTimestamp >= 10.0f )
					{
						birdSpawnpoints[i].entityId = 0;
						birdSpawnpoints[i].entitySpawnTimestamp = 0.0f;
					}
				}
			}
		}
	}
	
	function OnBirdEntityAttached( birdEntity : CEntity )
	{
		var bird 	: W3Bird;
		var i, size	: int;
		var success : bool;
		
		success = false;
		bird = (W3Bird) birdEntity;
		if( bird )
		{
			size = birdSpawnpoints.Size();
			for( i = 0; i < size; i += 1 )
			{
				if( birdSpawnpoints[i].entityId == bird.GetGuidHash() )
				{
					bird.SetBirdManager( this );
					birdSpawnpoints[i].bird = bird;
					birdSpawnpoints[i].isFlying = false;
					success = true;
					break;
				}
			}
		}
		
		
		
		
		if( !success )
		{
			birdEntity.Destroy();
		}
	}
	
	
	private function UpdateSpawnPointsList()
	{
		var spawnstruct : SBirdSpawnpoint;
		var nodes : array<CNode>;
		var spawnpoint : CBirdSpawnpoint;
		var collisionPos, testVec, normal : Vector;
		var world : CWorld;
		var i, j, lastExistingSpawnPoint : int;
		var exists : bool;
		var foundSpawnpoints : array<int>;
		var collisionGroups : array<name>;
		
		if (spawnOnlyInsideBirdsArea && !birdArea )
		{
			SetBirdArea ( GetBirdAreaInRange ( spawnRange ) );
		}
		lastExistingSpawnPoint = birdSpawnpoints.Size()-1;
		theGame.GetNodesByTag(birdsSpawnPointsTag, nodes);
		world = theGame.GetWorld();
		collisionGroups.PushBack('Terrain');
		collisionGroups.PushBack('Static');
		collisionGroups.PushBack('Debris');
		collisionGroups.PushBack('Ragdoll');
		collisionGroups.PushBack('Destructible');
		collisionGroups.PushBack('RigidBody');
		collisionGroups.PushBack('Foliage');
		collisionGroups.PushBack('Boat');
		collisionGroups.PushBack('BoatDocking');
		collisionGroups.PushBack('Door');
		collisionGroups.PushBack('Platforms');
		collisionGroups.PushBack('Corpse');
		collisionGroups.PushBack('Fence');
		
		for(i=0; i<nodes.Size(); i+=1)
		{
			spawnpoint = (CBirdSpawnpoint)nodes[i];
			
			if(spawnpoint)
			{
				if ( birdArea && !birdArea.TestEntityOverlap( spawnpoint ) )
				{
					continue;
				}
				
				if(	VecDistance( spawnpoint.GetWorldPosition() , this.GetWorldPosition() ) < spawnRange )
				{
					
					spawnstruct.position = spawnpoint.GetWorldPosition();				
					
					
					testVec = Vector(0, 0, 1);
					if ( world.StaticTrace(spawnstruct.position, spawnstruct.position - testVec, collisionPos, normal, collisionGroups) )
					{
						spawnstruct.position = collisionPos;
					}
					else
					{
						if ( world.StaticTrace(spawnstruct.position, spawnstruct.position + testVec, collisionPos, normal, collisionGroups) )
						{
							spawnstruct.position = collisionPos;
						}
					}
					
					
					exists = false;
					for(j=0; j<=lastExistingSpawnPoint; j+=1)
					{
						if(birdSpawnpoints[j].position == spawnstruct.position)
						{
							foundSpawnpoints.PushBack(j);
							exists = true;
							break;
						}
					}
					
					
					if(!exists)
					{
						spawnstruct.rotation = spawnpoint.GetWorldRotation();
						birdSpawnpoints.PushBack(spawnstruct);
					}
					
				}
			}
		}
		
		
		for(i=lastExistingSpawnPoint; i>=0; i-=1)
		{
			exists = false;
			for(j=0; j<foundSpawnpoints.Size(); j+=1)
			{
				if(i == foundSpawnpoints[j])
				{
					exists = true;
					foundSpawnpoints.Erase(j);	
					break;
				}
			}
			
			if(!exists)
				birdSpawnpoints.Erase(i);		
		}		
	}
	
	private function DespawnBirds()
	{
		var i : int;
			
		for(i = 0; i < birdSpawnpoints.Size(); i += 1)
		{
			if(birdSpawnpoints[i].bird)
				birdSpawnpoints[i].bird.Destroy();
			birdSpawnpoints[i].entityId = 0;
			birdSpawnpoints[i].entitySpawnTimestamp = 0.0f;
			birdSpawnpoints[i].isFlying = false;
		}
	}
	
	event OnDestroyed()
	{
		DespawnBirds();
		RemoveTimer('BirdsSpawnCheck');
	}
	
	protected function ShouldBirdsSpawnCheckBeActive() : bool
	{
		var dist2 : float;
		var pos : Vector;
		var camPos : Vector;
		var checkRange : float;
	
		pos = GetWorldPosition();
		camPos =  theCamera.GetCameraPosition();
		dist2 = VecDistanceSquared(pos,  camPos);
		checkRange = spawnRange * 3.0f;
		
		return dist2 <= ( checkRange * checkRange );
	}
	
	protected function StartBirdsSpawnCheck()
	{
		var timerUpdateDT : float;
		timerUpdateDT = RandRangeF( 0.7f, 0.3f );
		AddTimer( 'BirdsSpawnCheck', timerUpdateDT, true );
		RemoveTimer( 'BirdsSpawnPreCheck' );
	}
	
	protected function StartBirdsSpawnPreCheck()
	{
		var timerUpdateDT : float;
		timerUpdateDT = RandRangeF( 5.0f, 2.0f );
		AddTimer( 'BirdsSpawnPreCheck', timerUpdateDT, true );
		RemoveTimer( 'BirdsSpawnCheck' );
	}
	
	
	timer function BirdsSpawnCheck(td : float, id : int)
	{
		var x, y, dist2 : float;
		var i : int;
		var pos : Vector;
		var isVisible, areBirdsSpawned : bool;
		var bspSize : int;
	
		
		pos = GetWorldPosition();
		isVisible = theCamera.WorldVectorToViewRatio(pos, x, y);
		x = AbsF(x);
		y = AbsF(y);
		
		if(isVisible && (x >= 1.1 || y >= 1.1) )
			isVisible = false;
			
		if(isVisible)
			wasEverVisible = true;
			
		if(!isVisible)
		{
			dist2 = VecDistanceSquared(pos, theCamera.GetCameraPosition());
			
			areBirdsSpawned = false;
			bspSize = birdSpawnpoints.Size();
			for( i = 0; i < bspSize; i += 1 )
			{
				if(birdSpawnpoints[i].bird)
				{
					areBirdsSpawned = true;
					break;
				}
			}
			
			if(areBirdsSpawned)
			{
				if( wasEverVisible && ( dist2 > ( spawnRange * spawnRange ) ) )
				{
					DespawnBirds();
				}
			}
			else
			{
				if( (x < 1.3 || y < 1.3) && ( dist2 <= ( spawnRange * spawnRange ) ) )
				{
					SpawnBirds();
				}
			}
		}
	
		
		if( shouldBirdsFly )
		{
			FlyBirds();	
		}
		
		if( !areBirdsSpawned && !ShouldBirdsSpawnCheckBeActive() )
		{
			StartBirdsSpawnPreCheck();
		}
	}
	
	
	timer function BirdsSpawnPreCheck(td : float, id : int)
	{
		if( ShouldBirdsSpawnCheckBeActive() )
		{
			StartBirdsSpawnCheck();
		}
	}
}

state Default in CBirdsManager
{
	event OnEnterState( prevStateName : name )
	{
		StateDefault();
	}
	
	entry function StateDefault()
	{
		var resource : string;
		
		if(parent.customBirdTemplate)
		{
			parent.birdTemplate = parent.customBirdTemplate;
		}
		else
		{
			switch(parent.birdType)
			{
				case Crow :
					resource = "crow";
					break;
				case Pigeon :
					resource = "pigeon";
					break;
				case Seagull : 
					resource = "seagull";
					break;
				case Sparrow :
					resource = "sparrow";
			}
		
			parent.birdTemplate = (CEntityTemplate)LoadResourceAsync(resource);
		}
		
		
		Sleep( 0 );
		
		parent.SpawnBirds(true);
		parent.StartBirdsSpawnCheck();
	}
}




class CBirdsArea extends CGameplayEntity
{
	editable var birdsManagerTag : name;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor 		: CActor;
		var activatorProjectile : CThrowable;
		var i 					: int;
		var birdsManager 		: CBirdsManager;
		var birdManagers 		: array<CNode>;
		
		activatorActor = (CActor) activator.GetEntity();
		activatorProjectile = (CThrowable) activator.GetEntity();
		
		if(activatorActor || activatorProjectile)
		{
			theGame.GetNodesByTag(birdsManagerTag,birdManagers);
			
			for(i = 0; i < birdManagers.Size(); i += 1)
			{
				birdsManager = (CBirdsManager)birdManagers[i];
				if( birdsManager && area.TestEntityOverlap ( birdsManager ) )
					birdsManager.FlyBirds();
			}
		}
	}
}