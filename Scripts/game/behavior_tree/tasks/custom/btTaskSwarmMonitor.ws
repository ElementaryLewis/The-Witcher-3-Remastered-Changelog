/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSwarmMonitor extends IBehTreeTask
{
	public  var monitorShieldSwarm  		: bool;
	public  var respawnShieldBirds  		: bool;
	public  var respawnThreshold			: float;
	public  var respawnCooldown				: float;
	public  var disableBoidPOIComponents	: bool;
	private var lair 						: CFlyingSwarmMasterLair;
	private var boidPOIComponents			: array< CComponent >;
	
	hint respawnThreshold = "percentage value of current bird count to initial bird number";
	
	function OnActivate() : EBTNodeStatus
	{
		var entities 		: array<CGameplayEntity>;
		var lairEntities 	: array<CGameplayEntity>;
		var owner 			: CNewNPC = GetNPC();
		var i 				: int;
		var boidPOIChecked 	: bool;
		
		if ( disableBoidPOIComponents && !boidPOIChecked )
		{
			if ( boidPOIComponents.Size() == 0 )
			{
				boidPOIComponents = owner.GetComponentsByClassName( 'CBoidPointOfInterestComponent' );
			}
			
			if ( boidPOIComponents.Size() == 0 )
			{
				LogChannel( 'swarmDebug', owner.GetName()+" has no CBoidPointOfInterestComponent!!" );
			}
			
			if ( disableBoidPOIComponents )
			{
				for ( i=0 ; i < boidPOIComponents.Size() ; i+=1 )
				{
					((CBoidPointOfInterestComponent)(boidPOIComponents[i])).Disable( true );
				}
			}
			
			boidPOIChecked = true;
		}
		
		if ( !lair )
		{
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
			lair.SetBirdMaster( owner );
			respawnThreshold *= 0.01;
		}
		return BTNS_Active;
	}

	latent function Main() : EBTNodeStatus
	{
		var birdCount, spawnCount : int;
		var birdRatio : float;
		var owner : CNewNPC = GetNPC();
		
		if ( respawnShieldBirds )
		{
			spawnCount = lair.GetSpawnCount();
			
			while ( true )
			{
				birdCount = lair.GetShieldBirdCount();
				birdRatio = birdCount / spawnCount;
				if ( birdRatio < respawnThreshold )
				{
					lair.DisperseShield();
					lair.CompensateKilledShieldBirds( spawnCount - birdCount );
				}
				Sleep(1.0);
			}
		}
		return BTNS_Active;
	}
};

class CBTTaskSwarmMonitorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSwarmMonitor';

	editable var monitorShieldSwarm 		: bool;
	editable var respawnShieldBirds 		: bool;
	editable var disableBoidPOIComponents	: bool;
	editable var respawnThreshold 		: float;
	editable var respawnCooldown 		: float;
	
	default monitorShieldSwarm = true;
	default respawnShieldBirds = true;
	default respawnThreshold = 30;
	default respawnCooldown = 10;
	
	hint respawnThreshold = "percentage value of current bird count to initial bird number";
	hint disableBoidPOIComponents = "use for encounters with multiple enemies using swarms";
};
