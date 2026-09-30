/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CInteractionsManager extends IGameSystem
{	
	private var activeInteraction : CInteractionComponent;

	public function CanProcessGuiInteractions( activator : CEntity ) : bool
	{
		
		if ( !( (CPlayer)activator ) )
		{
			return false;
		}
		
		if ( thePlayer.IsInAir() || !thePlayer.substateManager.CanInteract() || thePlayer.GetCurrentStateName() == 'Meditation')
		{
			return false;
		}
		
		return true;
	}
	
	public function CanProcessInteractionInput( action : SInputAction ) : bool
	{
		var outSprintKeys		: array< EInputKey >;
		var outInteractionKeys	: array< EInputKey >;

		if ( !activeInteraction || !( (CR4ScriptedHud)theGame.GetHud() ).IsInteractionInCameraView( activeInteraction ) )
		{
			return false;
		}
		if ( theInput.LastUsedPCInput() )
			return IsPressed(action);
			
		if ( ( theInput.GetActionValue( 'GI_AxisLeftX' ) == 0.f && theInput.GetActionValue( 'GI_AxisLeftY' ) == 0.f ) || !thePlayer.IsActionAllowed(EIAB_RunAndSprint) )
		{
			return IsPressed( action );
		}
		else if ( thePlayer.GetHowLongSprintButtonWasPressed() > 0.12f )
		{
			theInput.GetPadKeysForAction('Sprint', outSprintKeys );
			theInput.GetPadKeysForAction(action.aName, outInteractionKeys );
			
			if (outSprintKeys.Size() > 0 && outInteractionKeys.Size() > 0 && outSprintKeys[0] == outInteractionKeys[0])
			{
				return false;
			}
			else
			{
				return IsPressed( action );
			}
		}
		else
		{
			return IsReleased( action );
		}
	}
	
	public function GetSelectionWeights( out selectionWeights : STargetSelectionWeights )
	{
		if ( thePlayer.IsThreatened() )
		{
			selectionWeights.angleWeight = 0.f;
			selectionWeights.distanceWeight = 1.f;
			selectionWeights.distanceRingWeight = 0.f;	
		}
		else 
		{
			selectionWeights.angleWeight = 0.4f;
			selectionWeights.distanceWeight = 0.6f;
			selectionWeights.distanceRingWeight = 0.f;								
		}
	}
	
	public function GetSelectionData( out selectionData : STargetSelectionData )
	{
		if ( thePlayer.lastAxisInputIsMovement )
		{
			selectionData.headingVector = thePlayer.GetHeadingVector();
		}
		else
		{
			selectionData.headingVector = theCamera.GetCameraDirection();
		}
		selectionData.headingVector.Z = 0.0f;
		selectionData.headingVector = VecNormalize2D( selectionData.headingVector );
		selectionData.softLockDistance = thePlayer.softLockDist;
	}
	
	public function GetBlockedActions( out blockedActions : array< string > )
	{
		if(!thePlayer.IsActionAllowed(EIAB_InteractionContainers))
		{
			blockedActions.PushBack( "Loot" );
			blockedActions.PushBack( "Container" );
			blockedActions.PushBack( "Take" );
			blockedActions.PushBack( "GatherHerbs" );
		}
		
		if ( (W3ReplacerCiri)thePlayer )
		{
			blockedActions.PushBack( "Ignite" );
			blockedActions.PushBack( "Extinguish" );
			blockedActions.PushBack( "FastTravel" );
		}
		
		if ( thePlayer.IsInCombatAction() )
		{
			blockedActions.PushBack( "MountHorse" );
		}
	}
	
	event OnGuiInteractionChanged( newInteraction : CInteractionComponent )
	{
		
		
		if ( ShouldProcessInteractionTutorials() )
		{
			theGame.GetTutorialSystem().SetInteraction( newInteraction );
		}	
		
		activeInteraction = newInteraction;
		
		return true;
	}
	
	public function GetActiveInteraction() : CInteractionComponent
	{
		return activeInteraction;
	}
}
