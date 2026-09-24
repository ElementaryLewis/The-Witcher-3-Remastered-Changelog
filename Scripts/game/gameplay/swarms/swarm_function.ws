/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function FlyingSwarm_RequestGroupStateChange( lairTag : name, groupState : name, affectAllGroups : bool )
{
	var lair 			: CFlyingCrittersLairEntityScript;
	var stateName 		: name;
	var attackGroupID	: CFlyingGroupId;
	var i 				: int;
	
	lair = ( (CFlyingCrittersLairEntityScript)theGame.GetEntityByTag( lairTag ) );
	if ( lair )
	{
		lair.RequestGroupStateChange( groupState, affectAllGroups );
	}
	else
	{
		LogChannel( 'Swarms', "Flying Swarm lair with tag '" + lairTag + "' was not found" );
	}
}


function FlyingSwarm_RequestCreateGroup( lairTag : name, boidCount : int, spawnPOI : name )
{
	var lair 			: CFlyingCrittersLairEntityScript;
	var stateName 		: name;
	var attackGroupID	: CFlyingGroupId;
	var i 				: int;
	
	lair = ( (CFlyingCrittersLairEntityScript)theGame.GetEntityByTag( lairTag ) );
	if ( lair )
	{
		lair.RequestCreateGroup( boidCount, spawnPOI );
	}
	else
	{
		LogChannel( 'Swarms', "Flying Swarm lair with tag '" + lairTag + "' was not found" );
	}
}


function FlyingSwarm_RequestAllGroupsInstantDespawn( lairTag : name )
{
	var lair 			: CFlyingCrittersLairEntityScript;
	
	lair = ( (CFlyingCrittersLairEntityScript)theGame.GetEntityByTag( lairTag ) );
	if ( lair )
	{
		lair.RequestAllGroupsInstantDespawn( );
	}
	else
	{
		LogChannel( 'Swarms', "Flying Swarm lair with tag '" + lairTag + "' was not found" );
	}
}


function Swarm_DisablePOIs( poiTag : name, disable : bool )
{
	var poiEntities 		: array< CEntity >;
	var poiCpnt				: CBoidPointOfInterestComponent;
	var i					: int;
	
	theGame.GetEntitiesByTag( poiTag, poiEntities );
	if ( poiEntities.Size() == 0 )
	{
		LogChannel( 'Swarms', "Swarm POI with tag '" + poiTag + "' was not found" );
		return;
	}
	for ( i = 0; i < poiEntities.Size(); i+=1 )
	{
		poiCpnt = (CBoidPointOfInterestComponent)poiEntities[ i ].GetComponentByClassName( 'CBoidPointOfInterestComponent' );
		if ( poiCpnt )
		{
			poiCpnt.Disable( disable );
		}
		else
		{
			LogChannel( 'Swarms', poiEntities[ i ].GetName() + " is not a swarm poi. It was tagged with " + poiTag );
		}
	}
}


function Swarm_DisableLair( lairTag : name, disable : bool )
{
	var lairEntity 		: CSwarmLairEntity;
	var i				: int;
	
	lairEntity = (CSwarmLairEntity)theGame.GetEntityByTag( lairTag );
	if ( !lairEntity )
	{
		LogChannel( 'Swarms', "SwarmLair with tag '" + lairTag + "' was not found" );
		return;
	}
	lairEntity.Disable( disable );
}