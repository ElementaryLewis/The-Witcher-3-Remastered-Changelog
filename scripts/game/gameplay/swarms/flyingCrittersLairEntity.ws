/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CSwarmLairEntity extends IBoidLairEntity
{
	import function Disable( disable : bool ); 
};
import class CFlyingCrittersLairEntity extends CSwarmLairEntity
{

};
import struct CFlyingGroupId
{
};
import function FlyingGroupId_Compare( groupIdA : CFlyingGroupId, groupIdB : CFlyingGroupId ) : bool;
import function FlyingGroupId_IsValid( groupId : CFlyingGroupId ) : bool;

import struct CFlyingSwarmGroup
{
	import const var 	groupId		 			: CFlyingGroupId;
	import const var 	groupCenter 			: Vector;
	import const var 	targetPosition 			: Vector;
	import const var 	currentGroupState 		: CName;
	import const var 	boidCount		 		: int;
	
	
	
	import var toSpawnCount		: int;
	import var spawnPoiType		: CName;
	
	
	
	import var toDespawnCount		: int;
	import var despawnPoiType		: CName;
	
	
	
	import var 			changeGroupState 		: CName;
};

class W3FlyingSwarmStateChangeRequest
{
	var groupId 	: CFlyingGroupId;
	var stateName 	: CName;
	
	function Init( id : CFlyingGroupId, newState : CName )
	{
		groupId = id;
		stateName = newState;
	}
}

class W3FlyingSwarmCreateGroupRequest
{
	var boidCount 	: int;
	var spawnPOI 	: name;
	function Init( inBoidCount 	: int, inSpawnPOI 	: name )
	{
		boidCount 	= inBoidCount;
		spawnPOI 	= inSpawnPOI;
	}
}

import class CFlyingSwarmScriptInput extends CObject
{
	import public var groupList : array< CFlyingSwarmGroup >;
	
	import final function CreateGroup( toSpawnCount : int, spawnPoiType : CName, groupState : CName, optional fromOtherGroup_Id : CFlyingGroupId );
	
	
	import final function RemoveGroup( groupId : CFlyingGroupId );
	import final function MoveBoidToGroup( groupIdA : CFlyingGroupId, count : int, groupIdB : CFlyingGroupId );
};

class GotoRequest
{
	
	public var 	groupId 				: CFlyingGroupId;
	public var  groupState				: CName;
	public var  groupStateSetOnArrival	: CName;
	public var  targetPoiComponent 		: CBoidPointOfInterestComponent;
	public var 	targetNode				: CNode;
	public var 	delay					: float;
	public var  delayTimer				: float;
	public var	factID					: string;
	public var	factValue				: int;
	
	
	public var 	groupCenterWhenStart 	: Vector;
	public var 	init					: bool;
};

import class CFlyingCrittersLairEntityScript  extends CFlyingCrittersLairEntity
{
	
	editable var dynamicGroups 	: bool;
	editable var doCircling 	: bool;
	editable var isAgressive 	: bool;
	default dynamicGroups 	= true;
	default doCircling		= false;
	default isAgressive 	= false;
	
	
	private var initDynamicGroups, initDoCircling, initAgressive, initMain 	: bool;
	default initDynamicGroups 	= true;
	default initDoCircling 		= true;
	default initAgressive 		= true;
	default initMain			= true;
	
	
	import var spawnLimit 		: int;
	
	
	private var isActive : Bool;
	default isActive = false;
	
	
	private var firstActivation : bool;
	default firstActivation = false;
	
	
	protected var idleGroupIndexArray : array< int >;

	
	
	
	private var m_requestGroupStateArray 	: array< CName >;
	private var m_requestGroupIdStateArray 	: array< W3FlyingSwarmStateChangeRequest >;
	private var m_requestCreateGroupArray 	: array< W3FlyingSwarmCreateGroupRequest >;
	
	private var m_allGroupsStateRequest 		: CName;
	private var m_requestAllGroupsDespawn 		: bool;
	private var m_requestAllGroupChangeState 	: bool;
	public var m_birdMaster 					: CGameplayEntity;
	private var m_gotoRequestArray 				: array<GotoRequest>;
	
	
	private var m_requestCircle, m_requestSupernatural, m_requestAttack, m_requestDespawnTest, m_requestGroupMerge, m_requestGroupSplit, m_requestPopulateGroup : Bool;
	default m_requestCircle 		= false;
	default m_requestAttack 		= false;
	default m_requestGroupMerge		= false;
	default m_requestGroupSplit		= false;
	default m_requestPopulateGroup	= false;
	
	import function GetPoiCountByType( poiType : name ) : int;
	import function GetSpawnPointArray( out spawnPointArray : array<name> );
	
	
	public function RequestGroupStateChange( groupState : CName, optional affectAllGroups : bool )
	{
		if ( affectAllGroups == false )
		{
			m_requestGroupStateArray.PushBack( groupState );
		}
		else
		{
			m_allGroupsStateRequest 		= groupState;
			m_requestAllGroupChangeState 	= true;
		}
	}
	
	function RequestGroupStateChange_ByGroupId( groupId : CFlyingGroupId, groupState : CName )
	{
		var flyingSwarmStateChangeRequest : W3FlyingSwarmStateChangeRequest = new W3FlyingSwarmStateChangeRequest in this;
		
		flyingSwarmStateChangeRequest.Init( groupId, groupState );
		
		m_requestGroupIdStateArray.PushBack( flyingSwarmStateChangeRequest );
	
	}
	
	function RequestCreateGroup( boidCount : int, spawnPOI : name )
	{
		var flyingSwarmCreateGroupRequest : W3FlyingSwarmCreateGroupRequest = new W3FlyingSwarmCreateGroupRequest in this;
		
		flyingSwarmCreateGroupRequest.Init( boidCount, spawnPOI );
		m_requestCreateGroupArray.PushBack( flyingSwarmCreateGroupRequest );
	}
	
	public function RequestAllGroupsInstantDespawn( )
	{
		m_requestAllGroupsDespawn 		= true;
	}

	function SetBirdMaster( birdMaster : CGameplayEntity )
	{
		m_birdMaster = birdMaster;
	}
	
	function SignalArrivalAtNode( groupState : CName, targetNode : CNode, groupStateSetOnArrival : CName, groupID : CFlyingGroupId, optional delay : float, optional factID : string, optional factValue : int )
	{	
		var gotoRequest : GotoRequest		= new GotoRequest in this;
		
		gotoRequest.groupState 				= groupState;
		gotoRequest.groupId 				= groupID;
		gotoRequest.targetPoiComponent		= NULL;
		gotoRequest.targetNode				= targetNode;
		gotoRequest.delay					= delay;
		gotoRequest.delayTimer				= 0.0f;
		gotoRequest.factID					= factID;
		gotoRequest.factValue				= factValue;
		
		gotoRequest.groupStateSetOnArrival 	= groupStateSetOnArrival;
		
		gotoRequest.init					= false;
		
		m_gotoRequestArray.PushBack( gotoRequest );
	}
	
	
	function OnBoidPointOfInterestReached( boidCount : int, entity : CEntity, deltaTime : float  )
	{
		var action 				: W3DamageAction;
		var damageResistance 	: float;
		var damage			 	: float;
		var xmlDamageModifier	: float;
		
		
		if ( (CPlayer)entity || ( m_birdMaster && GetAttitudeBetween( m_birdMaster, entity ) == AIA_Hostile ))
		{
			LogChannel('swarmDebug', "swarm boidcount = " +  boidCount);
			
			xmlDamageModifier = CalculateAttributeValue( ((CActor)m_birdMaster).GetAttributeValue( 'swarm_attack_damage_vitality' ));
			damage = xmlDamageModifier * boidCount * deltaTime;
			
			if( damage > 0 )
			{
				action = new W3DamageAction in this;
				action.Initialize( this, (CGameplayEntity)entity, this, this.GetName()+"_"+"root_projectile", EHRT_None, CPS_AttackPower,false,false,false,true);
				
				
				action.SetIgnoreArmor( true );
				
				
				action.AddDamage(theGame.params.DAMAGE_NAME_RENDING, damage );
				
				
				
				LogCritical("About to apply new swarm effect");
				action.AddEffectInfo(EET_Swarm);
				
				theGame.damageMgr.ProcessAction( action );
				delete action;
				GCameraShake( 0.05, true, thePlayer.GetWorldPosition() );
			}
		}
	}
	
	function GroupIdToGroupIndex( scriptInput: CFlyingSwarmScriptInput, groupId : CFlyingGroupId ) : int
	{
		var i : int;
		for ( i = 0; i < scriptInput.groupList.Size(); i += 1 )
		{
			if ( FlyingGroupId_Compare( scriptInput.groupList[ i ].groupId, groupId ) == true )
			{
				return i;
			}
		}
		return -1;
	}
	function FirstActivation( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{
		var i, boidCountPerPOI 		: int;
		var localSpawnPointArray	: array<name>;
		var spawnPointArray 		: array<name>;
		GetSpawnPointArray( spawnPointArray );
		
		
		for ( i = 0; i < spawnPointArray.Size(); i += 1 )
		{
			if ( GetPoiCountByType( spawnPointArray[ i ] ) != 0 )
			{
				localSpawnPointArray.PushBack( spawnPointArray[ i ] );
			}
		}
		boidCountPerPOI 		= spawnLimit / localSpawnPointArray.Size();
		for ( i = 0; i < localSpawnPointArray.Size(); i += 1 )
		{
			scriptInput.CreateGroup( boidCountPerPOI, localSpawnPointArray[ i ], 'idle' );
		}
	}
	function OnActivated( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{
		if ( firstActivation == false )
		{
			firstActivation = true;
			FirstActivation( scriptInput, deltaTime );
		}
	}
	
	function OnDeactivated( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{
		
		initDynamicGroups 			= true;
		initDoCircling				= true;
		initAgressive				= true;
		initMain					= true;
	}
	
	function OnTick( scriptInput: CFlyingSwarmScriptInput, active : Bool, deltaTime: float )
	{	
		var poiPos, startPos, endPos : Vector;
		var birdMasterPos : Vector;
		var birdMasterHeading : Vector; 
		var dotProduct : Float 	= 0.0f;
		var i, groupIndex, tries : int;
		var gotoRequest : GotoRequest;
		var requestGroupState : CName;
		
		idleGroupIndexArray.Clear();
		
		if ( active == false )
		{
			if ( isActive != active )
			{
				OnDeactivated( scriptInput, deltaTime );
			}
			return; 
		}
		if ( isActive != active )
		{
			OnActivated( scriptInput, deltaTime );
		}
		isActive = active;
		
		
		if ( scriptInput.groupList.Size() == 0 )
		{
			return;
		}
		
		
		for ( i = 0; i < scriptInput.groupList.Size(); i += 1 )
		{
			if ( scriptInput.groupList[ i ].currentGroupState == 'idle' )
			{
				idleGroupIndexArray.PushBack( i );
			}
		}
		
		if ( initMain )
		{
			initMain = false;
			m_requestGroupStateArray.Clear();
			m_requestGroupIdStateArray.Clear();
			m_requestAllGroupChangeState 	= false;
			m_requestAllGroupsDespawn 		= false;
			
			
			for ( i = 0; i < m_gotoRequestArray.Size(); i += 1 )
			{
				groupIndex 	= GroupIdToGroupIndex( scriptInput, m_gotoRequestArray[ i ].groupId );
				if ( groupIndex != -1 )
				{
					scriptInput.groupList[ groupIndex ].changeGroupState = 'idle';
				}
			}
			m_gotoRequestArray.Clear();
		}
		
		if ( dynamicGroups )
		{
			UpdateDynamicGroups( scriptInput, deltaTime );
		}
		if ( doCircling )
		{
			UpdateCircling( scriptInput, deltaTime );
		}
		if ( isAgressive )
		{
			UpdateAgressive( scriptInput, deltaTime );
		}
		
		for ( i = 0; i < m_requestGroupStateArray.Size(); i+=1 )
		{
			requestGroupState = m_requestGroupStateArray[ i ];
			groupIndex = -1;
			
			groupIndex		= RandRange( idleGroupIndexArray.Size() );
			
			scriptInput.groupList[ groupIndex ].changeGroupState = requestGroupState;
		}
		m_requestGroupStateArray.Clear();
		
		for ( i = m_gotoRequestArray.Size() - 1; i >= 0 ; i-=1 )
		{
			gotoRequest 			= m_gotoRequestArray[ i ];
			gotoRequest.delayTimer 	+= deltaTime;
			
			if ( FlyingGroupId_IsValid( gotoRequest.groupId ) == false )
			{
				groupIndex 				= idleGroupIndexArray[ RandRange( idleGroupIndexArray.Size() ) ];
				gotoRequest.groupId 	= scriptInput.groupList[ groupIndex ].groupId;
			}

			groupIndex 	= GroupIdToGroupIndex( scriptInput, gotoRequest.groupId );
			if ( groupIndex != -1 )
			{
				if ( gotoRequest.init == false )
				{
					gotoRequest.init = true;
					scriptInput.groupList[ groupIndex ].changeGroupState = gotoRequest.groupState;
					gotoRequest.groupCenterWhenStart = scriptInput.groupList[ groupIndex ].groupCenter;
				}
				if ( gotoRequest.delay < gotoRequest.delayTimer )
				{
					poiPos 		= gotoRequest.targetNode.GetWorldPosition();
					
					startPos 	= m_gotoRequestArray[ i ].groupCenterWhenStart;
					startPos.Z	= 0.0f;
					poiPos.Z	= 0.0f;
					endPos		= scriptInput.groupList[ groupIndex ].groupCenter;
					endPos.Z	= 0.0f;
					dotProduct 	= VecDot( poiPos - startPos, poiPos - endPos );
					if ( dotProduct < 0.0f )
					{
						scriptInput.groupList[ groupIndex ].changeGroupState = 'idle';
						if ( gotoRequest.groupStateSetOnArrival )
						{
							scriptInput.groupList[ groupIndex ].changeGroupState = gotoRequest.groupStateSetOnArrival;
						}
						
						if ( m_birdMaster )
						{
							((CActor)m_birdMaster).SignalGameplayEventParamCName( 'BoidGoToRequestCompleted', gotoRequest.groupState );
							if ( gotoRequest.factID )
							{
								if ( gotoRequest.factValue )
								{
									FactsAdd( gotoRequest.factID, gotoRequest.factValue );
								}
								else
								{
									FactsAdd( gotoRequest.factID );
								}
							}
						}
						m_gotoRequestArray.Erase(i);
						break;
					}
				}
			}
			else
			{
				m_gotoRequestArray.Erase(i);
				break;
			}
		}
		
		for ( i = 0; i < m_requestGroupIdStateArray.Size(); i+=1 )
		{
			groupIndex = GroupIdToGroupIndex( scriptInput, m_requestGroupIdStateArray[i].groupId );
			
			if( groupIndex != -1 )
			{
				scriptInput.groupList[ groupIndex ].changeGroupState = m_requestGroupIdStateArray[i].stateName;
			}
		}
		
		m_requestGroupIdStateArray.Clear();
		
		if( m_requestAllGroupChangeState )
		{
			for( i = 0; i < scriptInput.groupList.Size(); i += 1 )
			{
				if( scriptInput.groupList[ i ].currentGroupState != m_allGroupsStateRequest )
				{
					scriptInput.groupList[ i ].changeGroupState = m_allGroupsStateRequest;
				}
			}
		}
		
		m_requestAllGroupChangeState = false;
		
		if( m_requestAllGroupsDespawn )
		{
			for( i = 0; i < scriptInput.groupList.Size(); i += 1 )
			{
				scriptInput.groupList[i].toDespawnCount = scriptInput.groupList[i].boidCount;
				scriptInput.groupList[i].despawnPoiType = 'None';
			}
		}
		m_requestAllGroupsDespawn = false;
	
		for ( i = 0; i < m_requestCreateGroupArray.Size(); i+=1 )
		{
			scriptInput.CreateGroup( m_requestCreateGroupArray[ i ].boidCount, m_requestCreateGroupArray[ i ].spawnPOI, 'idle' );
		}
		m_requestCreateGroupArray.Clear();	
	}
	
	function UpdateDynamicGroups( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{	
		var i, indexA, indexB, maxBoidCount, groupIndexToDepopulate, groupIndexToPopulate, minBoidCount : int;
		var hasMergedThisFrame 	: Bool  = false;
		var spawnPointArray 	: array<name>;
		
		if ( initDynamicGroups )
		{
			initDynamicGroups = false;	
			
			
			AddTimer('GroupMergeTimer', RandRangeF( 60.0, 30.0 ), false );
			AddTimer('GroupSplitTimer', RandRangeF( 60.0, 30.0 ), false );
			
			
			m_requestGroupMerge		= false;
			m_requestGroupSplit		= false;
			m_requestPopulateGroup	= false;
		}
		
		if ( m_requestGroupMerge )
		{	
			m_requestGroupMerge = false; 		
			hasMergedThisFrame	= true;

			if ( idleGroupIndexArray.Size() >= 2 )
			{
				maxBoidCount 	= 0;
				
				minBoidCount 	= 100000; 
				indexA			= -1;
				for ( i = 0; i < idleGroupIndexArray.Size(); i += 1 )
				{
					if ( scriptInput.groupList[ idleGroupIndexArray[ i ] ].boidCount < minBoidCount )
					{
						indexA 			= idleGroupIndexArray[ i ];
						minBoidCount 	= scriptInput.groupList[ indexA ].boidCount;
					}
				}
			
				indexB = idleGroupIndexArray[ RandDifferent( indexA, idleGroupIndexArray.Size() ) ];
				
				if ( indexA != -1 && indexB != indexA )
				{
					if ( indexA >= scriptInput.groupList.Size() )
					{
						indexA = 0;
					}
					
					scriptInput.MoveBoidToGroup( scriptInput.groupList[ indexA ].groupId, scriptInput.groupList[ indexA ].boidCount, scriptInput.groupList[ indexB ].groupId );
					scriptInput.RemoveGroup( scriptInput.groupList[ indexA ].groupId );
				}
			}
		}
	
		if ( m_requestGroupSplit )
		{
			m_requestGroupSplit = false;
			
			if ( scriptInput.groupList.Size() < 6 )
			{
				m_requestPopulateGroup  = false;
				maxBoidCount 			= 0;
				groupIndexToDepopulate 	= -1;
				
				if ( scriptInput.groupList.Size() >= 2 )
				{
					for ( i = 0; i < scriptInput.groupList.Size(); i += 1 )
					{
						if ( scriptInput.groupList[ i ].boidCount > maxBoidCount )
						{
							maxBoidCount 			= scriptInput.groupList[ i ].boidCount;
							groupIndexToDepopulate 	= i;
						}
					}
					if ( groupIndexToDepopulate != -1 )
					{
						GetSpawnPointArray( spawnPointArray );
						scriptInput.CreateGroup( scriptInput.groupList[ groupIndexToDepopulate ].boidCount / 2, spawnPointArray[ 0 ], 'idle', scriptInput.groupList[ groupIndexToDepopulate ].groupId);
					}
					
				}
			}
			else
			{
				m_requestGroupMerge = true;
			}
		}
	}
	
	function UpdateCircling( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{	
		var i : int;
		if ( initDoCircling )
		{
			initDoCircling = false;	
			
			
			m_requestCircle 		= false;
			
			RequestGroupStateChange( 'circle' );
		}
	}
	
	function UpdateAgressive( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{	
		if ( initAgressive )
		{
			initAgressive = false;	
			
			
			AddTimer('AttackTimer', RandRangeF( 30.0, 15.0 ), false );
			
			
			m_requestAttack 		= false;
		}
		
		if ( m_requestAttack )
		{
			m_requestAttack = false;
			SignalArrivalAtNode( 'attackPlayer', thePlayer, 'idle', CFlyingGroupId() );
		}
	}	
	
	private timer function AttackTimer( delta : float , id : int)
	{
		m_requestAttack = true;
		AddTimer('AttackTimer', RandRangeF( 30.0, 10.0 ), false );
	}
	private timer function GroupMergeTimer( delta : float , id : int)
	{
		m_requestGroupMerge = true;
		AddTimer('GroupMergeTimer',  RandRangeF( 60.0, 30.0 ), false );
	} 
	private timer function GroupSplitTimer( delta : float , id : int)
	{
		m_requestGroupSplit = true;
		AddTimer('GroupSplitTimer', RandRangeF( 60.0, 30.0 ), false );
	}
};

class CFlyingSwarmMasterLair extends CFlyingCrittersLairEntityScript
{
	var m_spawnFromBirdMasterRequest 		: int;
	var m_spawnFromShieldGroupRequest 		: int;
	var m_despawnFromBirdMasterRequest 		: int;
	var teleportGroupId						: CFlyingGroupId;
	var shieldGroupId 						: CFlyingGroupId;
	var passedInput 						: CFlyingSwarmScriptInput;
	var m_init 								: bool;
	var disperseShield 						: bool;
	var teleportGroupPosition 				: Vector;
	var shieldBirdCount 					: int;
	var teleportBirdCount 					: int;
	var spawnCount 							: int;
	var checkBeginAttackArray 				: array< CFlyingGroupId >;
	var shieldBirdState						: name;
	
	default m_spawnFromBirdMasterRequest = -1;
	default m_despawnFromBirdMasterRequest = -1;
	default m_init = false;

	function FirstActivation( scriptInput: CFlyingSwarmScriptInput, deltaTime: float )
	{
		var i : int;
		var spawnPointArray : array<name>;
		spawnCount		= CeilF ( spawnLimit * 0.4 );
		GetSpawnPointArray( spawnPointArray );
		
		scriptInput.CreateGroup( CeilF ( spawnCount * 0.25 ), spawnPointArray[ 0 ], 'idle' );  
		scriptInput.CreateGroup( CeilF ( spawnCount * 0.25 ), spawnPointArray[ 1 ], 'idle' );
		scriptInput.CreateGroup( spawnCount, spawnPointArray[ 2 ], 'idle' ); 
		scriptInput.CreateGroup( 0, spawnPointArray[ 3 ], 'idle' ); 
		
		dynamicGroups	 	= false;
		doCircling 			= false;
		isAgressive			= false;
	}

	function OnTick( scriptInput: CFlyingSwarmScriptInput, active : Bool, deltaTime: float )
	{	
		var group 				: CFlyingSwarmGroup;
		var teleportGroupIndex 	: int;
		var shieldGroupIndex 	: int;
		var i, groupIndex		: int;
		super.OnTick( scriptInput, active, deltaTime );
		if ( active == false )
		{
			return;
		}
		if ( m_init == false )
		{
			if ( scriptInput.groupList.Size() > 0 )
			{
				m_init = true;
				shieldGroupId 	= scriptInput.groupList[ scriptInput.groupList.Size()-2 ].groupId;
				teleportGroupId = scriptInput.groupList[ scriptInput.groupList.Size()-1 ].groupId;
			}
		}
		
		if ( m_init == true )
		{
			teleportGroupPosition = scriptInput.groupList[ GroupIdToGroupIndex( scriptInput, teleportGroupId ) ].groupCenter;
			teleportBirdCount = scriptInput.groupList[ GroupIdToGroupIndex( scriptInput, teleportGroupId ) ].boidCount;
			shieldBirdCount = scriptInput.groupList[ GroupIdToGroupIndex( scriptInput, shieldGroupId ) ].boidCount;
			shieldBirdState = scriptInput.groupList[ GroupIdToGroupIndex( scriptInput, shieldGroupId ) ].currentGroupState;
		}
		
		passedInput = scriptInput;
		
		if ( m_spawnFromBirdMasterRequest != -1 )
		{
			LogChannel( 'swarmDebug', "spawning " + m_spawnFromBirdMasterRequest );
			teleportGroupIndex = GroupIdToGroupIndex( scriptInput, teleportGroupId );			
			if ( teleportGroupIndex != -1 )
			{
				
				scriptInput.groupList[ teleportGroupIndex ].toSpawnCount 		= m_spawnFromBirdMasterRequest;
				scriptInput.groupList[ teleportGroupIndex ].spawnPoiType		= 'BirdMaster';
				
			}
			
			m_spawnFromBirdMasterRequest = -1;
		}
		if ( m_despawnFromBirdMasterRequest != -1 )
		{
			teleportGroupIndex = GroupIdToGroupIndex( scriptInput, teleportGroupId );
			if ( teleportGroupIndex != -1 )
			{
				group = scriptInput.groupList[ teleportGroupIndex ];
				if ( m_despawnFromBirdMasterRequest > teleportBirdCount )
				{
					m_despawnFromBirdMasterRequest = teleportBirdCount;
				}
				scriptInput.groupList[ teleportGroupIndex ].toDespawnCount 	= m_despawnFromBirdMasterRequest;
				scriptInput.groupList[ teleportGroupIndex ].despawnPoiType	= 'BirdMaster';
			}
			m_despawnFromBirdMasterRequest = -1;
		}
		if ( m_spawnFromShieldGroupRequest != -1 )
		{
			shieldGroupIndex = GroupIdToGroupIndex( scriptInput, shieldGroupId );
			if ( shieldGroupIndex != -1 )
			{
				scriptInput.groupList[ shieldGroupIndex ].toSpawnCount  = m_spawnFromShieldGroupRequest;
			}
				
			m_spawnFromShieldGroupRequest = -1;
		}
		
		if ( disperseShield )
		{
			shieldGroupIndex = GroupIdToGroupIndex( scriptInput, shieldGroupId );
			if ( shieldGroupIndex != -1 )
			{
				scriptInput.groupList[ shieldGroupIndex ].changeGroupState  = 'idle';
			}
			disperseShield = false;
		}
		
		if (  m_birdMaster && !m_birdMaster.IsAlive() )
		{
			shieldGroupIndex = GroupIdToGroupIndex( scriptInput, shieldGroupId );
			if ( shieldGroupIndex != -1 )
			{
				scriptInput.groupList[ shieldGroupIndex ].changeGroupState  = 'idle';
			}
			
			teleportGroupIndex = GroupIdToGroupIndex( scriptInput, teleportGroupId );
			if ( teleportGroupIndex != -1 )
			{
				scriptInput.groupList[ teleportGroupIndex ].changeGroupState  = 'idle';
				
				
			}
		}
		
		for ( i = checkBeginAttackArray.Size() - 1; i >= 0 ; i -= 1 )
		{
			groupIndex = GroupIdToGroupIndex( scriptInput, checkBeginAttackArray[ i ] );
			if ( groupIndex != -1)
			{
				if ( scriptInput.groupList[ groupIndex ].currentGroupState == 'attackPlayer' )
				{
					SignalArrivalAtNode(  'attackPlayer', thePlayer, 'idle', checkBeginAttackArray[ i ]  );
					checkBeginAttackArray.Erase( i );
				}
			}
			else
			{
				checkBeginAttackArray.Erase( i );
			}
		}
	}
	
	function SpawnFromBirdMaster( count : int ) 
	{
		m_spawnFromBirdMasterRequest = count;
	}
	
	function DespawnFromBirdMaster( count : int ) 
	{
		m_despawnFromBirdMasterRequest = count;
	}
	
	function GetTeleportGroupPosition() : Vector
	{
		return teleportGroupPosition;
	}
	
	function GetShieldBirdCount() : int
	{
		return shieldBirdCount;
	}
	
	function GetGroupId( groupIdStateName : name ) : CFlyingGroupId
	{
		switch ( groupIdStateName )
		{
			case 'shield'		: return shieldGroupId;
			case 'teleport' 	: return teleportGroupId;
		}
	}
	
	function CurrentShieldGroupState() : name
	{
		return shieldBirdState;
	}
	
	function GetTeleportBirdCount() : int
	{
		return teleportBirdCount;
	}
	
	function GetSpawnCount() : int
	{
		return spawnCount;
	}
	
	function CompensateKilledShieldBirds( count : int )
	{
		m_spawnFromShieldGroupRequest = count;
	}
	
	function DisperseShield() : bool
	{
		disperseShield = true;
		return disperseShield;
	}
	
	function IsBirdMasterAlive() : bool
	{
		if ( m_birdMaster )
		{
			return m_birdMaster.IsAlive();
		}
		return false;
	}
	
};


exec function HideLayer( layerName : string )
{
	theGame.GetWorld().HideLayerGroup( layerName );
}