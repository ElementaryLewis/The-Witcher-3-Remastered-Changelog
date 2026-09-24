/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3LadderInteraction extends CGameplayEntity
{
	public editable var associatedDoorTag : name;
	default associatedDoorTag = '';
	var associatedDoor : W3NewDoor;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var components : array< CComponent >;
		var ic : CInteractionComponent;
		var i, size : int;
		
		
		
		
		
		if ( associatedDoorTag == '' && this.HasTag( 'q305_ladder_midgets_cellar' ) )
		{
			associatedDoorTag = 'q305_midgets_trapdoor';
		}

		
		if ( associatedDoorTag )
		{
			components = GetComponentsByClassName( 'CInteractionComponent' );
			size = components.Size();
			for ( i = 0; i < size; i+=1 )
			{
				ic = (CInteractionComponent)components[i];
				if ( ic )
				{
					ic.performScriptedTest = true;
				}
			}
		}
	}

	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( associatedDoorTag )
		{
			if ( !associatedDoor )
			{
				associatedDoor = (W3NewDoor)theGame.GetNodeByTag( associatedDoorTag );
			}
			if ( associatedDoor && !associatedDoor.IsOpen() )
			{
				return false;
			}
		}
		return true;
	}
	
	
	
	
	private function PlayerHasLadderExplorationReady() : bool
	{
		if( !thePlayer.substateManager.CanInteract() )
		{
			return false;
		}
		
		if( !thePlayer.substateManager.m_SharedDataO.HasValidLadderExploration() )
		{
			return false;
		}
		
		return true;
	}
}