/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSwarmShield extends CBTTaskPlayAnimationEventDecorator
{
	private var lair				: CFlyingSwarmMasterLair;
	public var stabilizationTimer	: float;
	public var disperse				: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var entities 					: array<CGameplayEntity>;
		var npc 						: CNewNPC = GetNPC();
		var i, birdCount, spawnCount 	: int;
		var shieldGroupId 				: CFlyingGroupId;
		var lairEntities 				: array<CGameplayEntity>;
		
		if ( !lair )
		{
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
		}
		
		if ( lair )
		{
			lair.SetBirdMaster( npc );
			
			if ( disperse )
			{
				lair.DisperseShield();
			}
			else
			{
				shieldGroupId = lair.GetGroupId( 'shield' );
				
				lair.SignalArrivalAtNode( 'gotoBirdMaster', npc, 'shield', shieldGroupId );
			}
		}
		else
		{
			LogChannel( 'swarmDebug', "No lair to spawn from ! " );
		}
		
		return BTNS_Active;
	}
};

class CBTTaskSwarmShieldDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskSwarmShield';

	editable var stabilizationTimer : float;
	editable var disperse			: bool;
	
	default stabilizationTimer = 5.0;
};