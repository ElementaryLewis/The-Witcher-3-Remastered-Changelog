/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CTeleportEntity extends CInteractiveEntity
{
	editable var keyItemName : name;
	editable var removeKeyOnUse : bool;
	editable var linkingMode : bool;
	editable var keepBlackscreen : bool;
	editable var pairedTeleport : EntityHandle;
	editable var pairedNodeTag : name;
	editable var oneWayTeleport : bool;
	editable var activationTime : float;
	editable var factOnActivate : string;
	editable var factOnTeleport : string;
	
	var factOnActivateValidFor : int;
	var factOnTeleportValidFor : int;
		
	saved var isActivated : bool;
	var destinationNode : CNode;
	
	var currentlyTeleporting : bool;
	
	default linkingMode = true;
	default oneWayTeleport = true;
	default removeKeyOnUse = true;
	default keepBlackscreen = false;
	default activationTime = 0.5;
	default factOnActivateValidFor = 10;
	default factOnTeleportValidFor = 2;
	default currentlyTeleporting = false;
	
	hint linkingMode = "TRUE: uses 'pairedTeleport' variable (EntityHandle). FALSE: uses 'pairedNodeTag' variable (tag to CNode object).";
	hint oneWayTeleport = "If set to FALSE, it will trigger activation on paired teleport, allowing player to go back.";
	hint activationTime = "Time between start of fx and enabling teleport trigger";
	hint keepBlackscreen = "If set to TRUE blackscreen won't be disabled after teleportation";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		EnableTeleport( bIsEnabled );
		EnableTeleportArea( false );
		
		if(!spawnData.restored)
			isActivated = false;
			
		if(isActivated)
			PlayEffect( 'teleport_fx' );
	}
	
	function EnableTeleport( flag : bool )
	{
		var activationComponent : CComponent;
		
		bIsEnabled = flag;
		
		
		activationComponent = GetComponent( "activationComponent" );
		if(activationComponent)
			activationComponent.SetEnabled( flag );
	}

	function EnableTeleportArea( flag : bool )
	{
		var teleportTriggerArea : CComponent;
		
		
		teleportTriggerArea = GetComponent( "teleportTriggerArea" );
		if(teleportTriggerArea)
			teleportTriggerArea.SetEnabled( flag );
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( activator != thePlayer )
			return false;
			
		if( !isActivated )
		{
			if( PlayerHasKey() )
			{
				if( removeKeyOnUse )
				{
					thePlayer.inv.RemoveItemByName( keyItemName, 1 );
				}
				ActivateTeleport( activationTime );
				
				return true;
			}
			else
			{
				GetWitcherPlayer().DisplayHudMessage( GetLocStringByKeyExt( "panel_hud_message_dont_have_required_key" ) );
				return false;
			}
		}

		return false;
	}
	
	function PlayerHasKey() : bool
	{
		if( !IsNameValid(keyItemName) )	
		{
			return true;
		}
		else if( thePlayer.inv.HasItem( keyItemName ) )
		{
			return true;
		}
		
		return false;
	}
	
	function ActivateTeleport( activationTime : float )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
		
		if(isActivated)
			return;
			
		AddFactOnActivation();
		
		if( oneWayTeleport )
		{
			
			
			EnableTeleport( false );
		}
		
		PlayEffect( 'teleport_fx' );
		AddTimer( 'ActivateTeleportAreaAfter', activationTime, , , , true );
	}
	
	timer function ActivateTeleportAreaAfter( td : float , id : int)
	{
		isActivated = true;
		EnableTeleportArea( true );
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if( interactionComponentName == "teleportTriggerArea" && isActivated )
		{	
			if( !currentlyTeleporting )
			{
				currentlyTeleporting = true;
				theGame.FadeOutAsync( 0.2 );
				theInput.StoreContext( 'EMPTY_CONTEXT' );
				AddTimer( 'SetupTeleportData', 0.25, , , , true );
			}
		}
		else
		{
			if( interactionComponentName == "interactionUpdateComponent" )
			{
				UpdateInteractions();
			}
		}
	}
	
	timer function SetupTeleportData( td : float , id : int )
	{
		var pairedTeleportEntity : CTeleportEntity;
		
		AddFactOnTeleport();
		
		if( linkingMode )
		{
			destinationNode = EntityHandleGet( pairedTeleport );
		}
		else
		{
			destinationNode = theGame.GetEntityByTag( pairedNodeTag );
		}
		
		if( !oneWayTeleport )
		{	
			ActivateTeleport(0.f);
			pairedTeleportEntity = ( CTeleportEntity )destinationNode;
			if( pairedTeleportEntity )
			{
				pairedTeleportEntity.ActivateTeleport( 1.0 );
			}
		}
		else
		{
			DeactivateTeleport();
		}
		
		if( keepBlackscreen )
		{
			AddTimer( 'TeleportMeWithBlackscreen', 0.1 );
		}
		else
		{
			AddTimer( 'TeleportMe', 0.6 );
		}
		
	}
	
	timer function TeleportMe( td : float , id : int )
	{	
		thePlayer.TeleportWithRotation( destinationNode.GetWorldPosition() + destinationNode.GetHeadingVector() * 1.5, destinationNode.GetWorldRotation() );
		if( thePlayer.GetCurrentStateName() == 'AimThrow' )
				thePlayer.OnRangedForceHolster( true );
		AddTimer( 'FadeInAfter', 0.5 );	
		theInput.RestoreContext( 'EMPTY_CONTEXT', false );
		currentlyTeleporting = false;
	}
	
	timer function TeleportMeWithBlackscreen( td : float , id : int )
	{	
		thePlayer.TeleportWithRotation( destinationNode.GetWorldPosition() + destinationNode.GetHeadingVector() * 1.5, destinationNode.GetWorldRotation() );
		theInput.RestoreContext( 'EMPTY_CONTEXT', false );
		currentlyTeleporting = false;
	}
	
	function DeactivateTeleport()
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		mapManager.SetEntityMapPinDiscoveredScript( false, entityName, false );
		
		if(!isActivated)
			return;
		
		StopAllEffects();
		isActivated = false;
		EnableTeleportArea( false );
		EnableTeleport( true );
	}
	
	timer function FadeInAfter( td : float , id : int)
	{
		theGame.FadeInAsync( 0.4 );
	}
	
	public function SetDestinationParameters( nodeTag : name, factOnTp : string )
	{
		linkingMode = false;
		pairedNodeTag = nodeTag;
		factOnTeleport = factOnTp;
		factOnTeleportValidFor = -1;
	}
	
	private function UpdateInteractions()
	{
		EnableTeleport( bIsEnabled );
		EnableTeleportArea ( isActivated );
	}
	
	private function AddFactOnActivation()
	{
		if ( factOnActivate != "" )
		{
			FactsAdd( factOnActivate, 1, factOnActivateValidFor );
		}
	}
	
	private function AddFactOnTeleport()
	{
		if( factOnTeleport != "" )
		{
			FactsAdd( factOnTeleport, 1, factOnTeleportValidFor );
		}
	}
}