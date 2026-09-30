/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3CurveFish extends CGameplayEntity
{
	
	editable var destroyDistance : float;
	editable var swimCurves : array<name>;
	editable var speedUpChance : float;
	editable var baseSpeedVariance : float;	
	editable var maxSpeed : float;
	editable var randomizedAppearances : array<string>;	
	
	
	private var manager : W3CurveFishManager;
	private var baseSpeed : float;
	private var selectedSwimCurve : name;
	private var currentSpeed : float;
	private var accelerate : bool;
	
		hint destroyDistance = "Distance from camera after which the fish is destroyed";
		hint swimCurves = "Array of names of swim curves - random is picked";
		hint speedupChance = "Chance of fish speeding up while swimming";
		
		default destroyDistance = 50;
		default speedUpChance = 0.2;
		default baseSpeedVariance = 0.2;
		default maxSpeed = 3.0;		
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		selectedSwimCurve = swimCurves[RandRange(swimCurves.Size(), 0)];
		
		super.OnSpawned(spawnData);
		LogAssert(swimCurves.Size() > 0, "W3CurveFish.OnSpawned: fish must have at least one swim curve!");
		
		SetupFishBaseSpeed();
		
		if(randomizedAppearances.Size() > 1)
		{
			ApplyAppearance(randomizedAppearances[RandRange(randomizedAppearances.Size()-1,0)]);
		}
		
		PlayPropertyAnimation(selectedSwimCurve, 0, baseSpeed );
		
		AddTimer('SpeedHandler', 0.1, true);
		
	}
	
	public function SetFishManager(m : W3CurveFishManager)
	{
		manager = m;
	}
	
	function SetupFishBaseSpeed()
	{
		if(baseSpeedVariance < 0.0f) baseSpeedVariance = 0.0;
		baseSpeed = 1.0f + RandRangeF(baseSpeedVariance, baseSpeedVariance * -1.0);
		currentSpeed = baseSpeed;
	}
	
	function ModifyFishSpeed()
	{
		SetBehaviorVariable('Speed', currentSpeed * 0.5f );
		PlayPropertyAnimation(selectedSwimCurve, 0, currentSpeed);
	}

	
	timer function SpeedHandler(dt: float, id : int)
	{
		var rand : float;
		
		if( currentSpeed <= baseSpeed )
		{
			rand = RandRangeF(1.0, 0.0);
			
			if(rand >= speedUpChance)
			{
				accelerate = true;
				currentSpeed = currentSpeed + 0.1f;
				ModifyFishSpeed();
			}
			
		}
		else
		{
			if(accelerate)
			{
				currentSpeed = currentSpeed + 0.1f;
				ModifyFishSpeed();
				
				if( currentSpeed >= maxSpeed ) accelerate = false;
				
			}
			else
			{
				currentSpeed = currentSpeed - 0.1f;
				ModifyFishSpeed();
			}
		}
		
	}

	event OnDestroyed()
	{
		RemoveTimer('SpeedHandler');
	}

}




class W3CurveFishSpawnpoint extends CEntity {}




statemachine class W3CurveFishManager extends CGameplayEntity
{
	editable var fishSpawnPointsTag : name;
	editable var fishTemplate : array<CEntityTemplate>;
	editable var randomFishRotation : bool;

	
	private var fishSpawnpoints : array<SFishSpawnpoint>;

	editable var m_spawnDistance : float;
	editable var m_despawnDistance : float;
	private var m_spawned : bool;
	
	private var m_firstTimeCollectSpawnpoints : bool;
	
	private var m_spawnedFish : array< W3CurveFish >;

	
	default autoState = 'Default';
	
	default m_spawnDistance = 150.0f;
	default m_despawnDistance = 300.0f;
	default m_spawned = false;
	default m_firstTimeCollectSpawnpoints = true;
		
	
	
	
	
 	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		GotoStateAuto();
		super.OnSpawned(spawnData);
	}
	
	event OnDetaching()
	{
		DespawnFish();
	}
	
	private function SelectFishTemplate () : CEntityTemplate
	{
		return fishTemplate[ RandRange( fishTemplate.Size(), 0 ) ];
	}
	
	public function SpawnFish()
	{
		var i : int;
		var size : int;
		var spawnRotation : EulerAngles;
		
		if( m_firstTimeCollectSpawnpoints )
		{
			UpdateSpawnPointsList();
			m_firstTimeCollectSpawnpoints = false;
		}
		
		size = fishSpawnpoints.Size();
		
		for(i = 0; i < size; i += 1)
		{
			if(randomFishRotation)
			{
				spawnRotation.Pitch = fishSpawnpoints[i].rotation.Pitch;
				spawnRotation.Roll = fishSpawnpoints[i].rotation.Roll;
				spawnRotation.Yaw = RandRangeF(359.0, 1.0);
			}
			else
			{
				spawnRotation = fishSpawnpoints[i].rotation;	
			}
			
			fishSpawnpoints[ i ].spawnHandler.SetPostAttachedCallback( this, 'OnFishSpawned' );
			theGame.CreateEntityAsync( fishSpawnpoints[ i ].spawnHandler, SelectFishTemplate(), fishSpawnpoints[i].position, spawnRotation );
		}
	}
	
	
	
	private function UpdateSpawnPointsList()
	{
		var spawnstruct : SFishSpawnpoint;
		var nodes : array<CNode>;
		var spawnpoint : W3CurveFishSpawnpoint;
		var collisionPos, testVec, normal : Vector;
		var i, j, fishSpawnpointsOldSize : int;
		var exists : bool;
		var collisionGroups : array<name>;
		
		
		
		fishSpawnpointsOldSize = fishSpawnpoints.Size()-1;
		theGame.GetNodesByTag(fishSpawnPointsTag, nodes);
		
		for( i = 0; i <= fishSpawnpointsOldSize; i += 1 )
		{
			fishSpawnpoints[ i ].shouldBeErased = true;
		}
		
		for(i=0; i<nodes.Size(); i+=1)
		{
			spawnpoint = (W3CurveFishSpawnpoint)nodes[i];
			if(spawnpoint)
			{
				
				spawnstruct.position = spawnpoint.GetWorldPosition();				
				
				
				exists = false;
				for(j=0; j<=fishSpawnpointsOldSize; j+=1)
				{
					if(fishSpawnpoints[j].position == spawnstruct.position)
					{
						fishSpawnpoints[ j ].shouldBeErased = false;
						exists = true;
						break;
					}
				}
				
				
				if(!exists)
				{
					spawnstruct.rotation = spawnpoint.GetWorldRotation();
					spawnstruct.shouldBeErased = false;
					spawnstruct.spawnHandler = new CCreateEntityHelper in this;		
					fishSpawnpoints.PushBack( spawnstruct );
				}
			}
		}
		
		
		for( i = 0; i < fishSpawnpoints.Size(); )
		{
			if( fishSpawnpoints[ i ].shouldBeErased )
			{
				fishSpawnpoints.EraseFast( i );
			}
			else
			{
				i += 1;
			}
		}	
	}
	
	private function DespawnFish()
	{
		var i : int;
			
		for( i = 0; i < m_spawnedFish.Size(); i += 1 )
		{
			m_spawnedFish[ i ].Destroy();
		}
		
		m_spawnedFish.Clear();
	}
	
	event OnDestroyed()
	{
		DespawnFish();
		RemoveTimer('FishSpawnCheck');
	}
	
	timer function FishSpawnCheck(td : float, id : int)
	{
		var pos : Vector;
		var dist : float;
		var i : int;
		
		pos = GetWorldPosition();
		dist = VecDistance( pos, theCamera.GetCameraPosition() );
		
		if( ( dist <= m_spawnDistance ) && !m_spawned )
		{
			SpawnFish();
			m_spawned = true;
		}
		else if( ( dist >= m_despawnDistance ) && m_spawned )
		{
			m_spawned = false;
		}
		
		if( !m_spawned )
		{
			DespawnFish();
		}
	}
	
	private function OnFishSpawned( fishEnt : CEntity )
	{
		var fish : W3CurveFish;
		
		fish = ( W3CurveFish )fishEnt;
		if( fish )
		{
			fish.SetFishManager( this );
			m_spawnedFish.PushBack( fish );
		}
	}
}

state Default in W3CurveFishManager
{
	event OnEnterState( prevStateName : name )
	{
		StateDefault();
	}
	
	entry function StateDefault()
	{
		parent.AddTimer('FishSpawnCheck', 1.0f, true);
	}
}