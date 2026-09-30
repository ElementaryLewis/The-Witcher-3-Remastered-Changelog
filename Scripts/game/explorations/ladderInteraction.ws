/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3LadderInteraction extends CGameplayEntity
{
	public editable var associatedDoorTag : name;
	public editable var isRootLadder : bool;

	private var expComp : CExplorationComponent;

	default associatedDoorTag = '';
	default isRootLadder = false;
	var associatedDoor : W3NewDoor;

	var canJumpOnLadder : bool; 				default canJumpOnLadder = false;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var components : array< CComponent >;
		var ic : CInteractionComponent;
		var i, size : int;
		var expComponent : CExplorationComponent;

		
		
		
		
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

		expComp = ( CExplorationComponent )GetComponentByClassName( 'CExplorationComponent' );
	}

	public function GetExpComp() : CExplorationComponent
	{
		return expComp;
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

	event OnEnterTrigger( object : CObject, physicalActorindex : int, shapeIndex : int )
	{
		var player : CR4Player;
		player = (CR4Player)object.GetParent();
		
		if( player )
		{
			thePlayer.substateManager.m_SharedDataO.m_activeLadders.PushBack( this );
		}
	}	

	event OnExitTrigger( object : CObject, physicalActorindex : int, shapeIndex : int ) 
	{
		var player : CR4Player;
		player = (CR4Player)object.GetParent();
		
		if( player )
		{
			thePlayer.substateManager.m_SharedDataO.m_activeLadders.Remove(this);
		}
	}

}