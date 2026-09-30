/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ENewDoorOperation
{
	NDO_Open,
	NDO_Close,
	NDO_Toggle,
	NDO_Lock,
	NDO_Unlock,
	NDO_ToggleLock,
}

class W3NewDoor extends W3LockableEntity
{
	editable var openAngle 				: float;	default openAngle = 90;
	editable var initiallyOpened 		: bool;
	editable var factOnPlayerDoorOpen 	: name;
	editable var openedByHorse			: bool;

	private optional autobind doorsCmp 		: CDoorComponent = single;
	private optional autobind lockedCmp 	: CInteractionComponent = "Locked";
	private optional autobind unlockCmp 	: CInteractionComponent = "Unlock";
	private optional autobind lockedDA 		: CDeniedAreaComponent = "LockedDeniedArea";	
	
	private optional autobind rigidMeshCmp 	: CRigidMeshComponent = single;
	
	private var updateDuration				: float;
	private var updateTimeLeft				: float;
	private var playerInsideTrapdoorTrigger : bool;		default playerInsideTrapdoorTrigger = false;
	default updateDuration = 2;
	private var enableDeniedAreaInCombat	: bool; default enableDeniedAreaInCombat = true;

	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		super.OnSpawned( spawnData );
		SetFocusModeVisibility( FMV_Interactive );	
	}
	
	function GetOpeningAngle() : float
	{
		return openAngle;
	}
	
	function EnableDeniedAreaInCombat( enable : bool )
	{
		enableDeniedAreaInCombat = enable;
	}
	
	event OnPlayerOpenedDoors()
	{
		if( factOnPlayerDoorOpen )
		{
			FactsAdd( factOnPlayerDoorOpen, 1, 3 );
		}
	}	
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorPlayer 			: CPlayer;
		var activatorNPC 				: CNewNPC;
		var doorPos						: Vector;
		var activatorPos				: Vector;
		var horse 						: CGameplayEntity;
		var horseComp 					: W3HorseComponent;		
		
		if( !doorsCmp )
		{
			return true;
		}

		super.OnAreaEnter( area, activator );
		
		activatorPlayer = ( CPlayer ) activator.GetEntity();
		activatorNPC 	= ( CNewNPC ) activator.GetEntity();
		
		if( activatorNPC && isEnabled )
		{			
			doorsCmp.AddDoorUser( activatorNPC );							
			activatorNPC.SignalGameplayEventParamObject( 'AI_DoorTriggerEntered', this ); 	
			if( doorsCmp.IsInteractive() )
			{
				doorsCmp.Open( false, false );
			}
		}
		else if( activatorPlayer )
		{
			if( doorsCmp.IsTrapdoor() )
			{
				activatorPos = activatorPlayer.GetWorldPosition();
				doorPos = GetWorldPosition();
				
				if( activatorPos.Z < doorPos.Z - 0.1 )
				{
					doorsCmp.Open( false, false );
				}
				else
				{
					playerInsideTrapdoorTrigger = true;
				}
			}
			if( !doorsCmp.IsInteractive() )
			{
				doorsCmp.AddDoorUser( activatorPlayer );		
			}
		}
		
		if( openedByHorse )
		{
			if( activatorPlayer && activatorPlayer.IsUsingHorse() )
			{
				horse = activatorPlayer.GetUsedVehicle();
				horseComp = (W3HorseComponent)horse.GetComponentByClassName( 'W3HorseComponent' );
				horseComp.IncrementIgnoreTestsCounter();
			}
		}
	}
	
	public function IsOpen() : bool
	{
		if ( doorsCmp )
		{
			return doorsCmp.IsOpen();
		}
		return true;
	}
	
	public function Unlock( )
	{
		super.Unlock();		
		if( theGame.IsActive() )
		{
			lockedDA.SetEnabled( false );
		}
	}
	
	protected function OnLock()
	{
		super.OnLock();
		if( theGame.IsActive() )
		{
			lockedDA.SetEnabled( true );				
		}
	}
	
	
	event OnOpened()
	{		
		lockedDA.SetEnabled( false );		
	}	
	
	event OnCombatStarted()
	{
		if ( enableDeniedAreaInCombat )
		{
			lockedDA.SetEnabled( true );
		}
	}
	
	event OnCombatEnded()
	{
		if( !lockedByKey && isEnabled )
		{	
			lockedDA.SetEnabled( false );		
		}		
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorNPC 	: CNewNPC;
		var activatorPlayer : CPlayer;
		var horse 			: CGameplayEntity;
		var horseComp 		: W3HorseComponent;	
		super.OnAreaExit( area, activator );
		
		activatorNPC 	= ( CNewNPC ) activator.GetEntity();
		activatorPlayer = ( CPlayer ) activator.GetEntity();
		
		if( activatorNPC )
		{
			activatorNPC.SignalGameplayEventParamObject( 'AI_DoorTriggerExit', this ); 
		}
		
		if( activatorPlayer )
		{
			playerInsideTrapdoorTrigger = false;
		}
		
		if( doorsCmp )
		{
			doorsCmp.Unsuppress();
		}	
		
		if( openedByHorse )
		{
			if( activatorPlayer && activatorPlayer.IsUsingHorse() )
			{
				horse = activatorPlayer.GetUsedVehicle();
				horseComp = (W3HorseComponent)horse.GetComponentByClassName( 'W3HorseComponent' );
				horseComp.DecrementIgnoreTestsCounter();
			}
		}
	}
	
	event OnStateChange( newState : bool )
	{
		super.OnStateChange( newState );
		if( doorsCmp )
		{
			doorsCmp.EnebleDoors( newState );
		}
	}
	
	event OnActionNameChanged()
	{
		var hud : CR4ScriptedHud;
		
		hud= (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hud.ForceInteractionUpdate();
		}
	}
	
	public function Enable(e : bool, optional skipInteractionUpdate : bool, optional questForcedEnable : bool)
	{
		super.Enable( e, skipInteractionUpdate, questForcedEnable );
		if( doorsCmp )
		{
			doorsCmp.EnebleDoors( e );
			doorsCmp.SetEnabled( e );
		}
		
		if( theGame.IsActive() )
		{
			if( !e )
			{
				lockedDA.SetEnabled( true );
			}
			else if( ! lockedByKey )
			{
				lockedDA.SetEnabled( false );
			}
		}
	}
		
	
	event OnManageNewDoor ( operations : array< ENewDoorOperation >, force : bool )
	{
		var i, size : int;
		
		
		size = operations.Size();
		for ( i = 0; i < size; i += 1 )
		{
			switch ( operations[ i ] )
			{
			case NDO_Open:
				if( force )
				{
					doorsCmp.InstantOpen( true );
				}
				else
				{
					doorsCmp.Open( false, false );
				}
				break;
			case NDO_Close:
				if( force )
				{
					doorsCmp.InstantClose();
				}
				else
				{
					doorsCmp.Close( true );
				}				
				break;
			case NDO_Lock:
				if ( !IsLocked() )
				{
					Lock( 'anykey' );
				}
				break;
			case NDO_Unlock:
				if ( IsLocked() )
				{
					Unlock();
				}
				break;
			case NDO_ToggleLock:
				ToggleLock();
				break;
			}
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{		
		if( !playerInsideTrapdoorTrigger )
		{
			super.OnInteraction( actionName, activator );

			updateTimeLeft = updateDuration;
			AddTimer( 'UpdateIconOffset', 0.01f, true );
		}		
	}
	
	event OnDoorActivation()
	{
		if( doorsCmp )
		{			
			if( initiallyOpened && !lockedByKey )
			{
				doorsCmp.InstantOpen( true );
			}
		}		
	}
	
	event OnStreamIn()
	{
		super.OnStreamIn();
	}
	
	
	
	public final timer function UpdateIconOffset( delta : float, id : int )
	{
		var l_gameplayEnt 		: CGameplayEntity;
		var l_localToWorld		: Matrix;
		var l_worldToLocal		: Matrix;
		var l_slotMatrix		: Matrix;
		var l_slotWorldPos		: Vector;
		var l_offset			: Vector;
		var l_box				: Box;		
		
		if( CalcEntitySlotMatrix( 'handle', l_slotMatrix ) )
		{
			l_localToWorld 	= GetLocalToWorld();
			l_worldToLocal 	= doorsCmp.InvertMatrixForDoor( l_localToWorld );
			
			l_slotWorldPos 	= MatrixGetTranslation( l_slotMatrix );
			l_offset 		= VecTransform( l_worldToLocal , l_slotWorldPos );
			
			doorsCmp.SetIconOffset( l_offset );
			lockedCmp.SetIconOffset( l_offset );
			unlockCmp.SetIconOffset( l_offset );
		}
		
		updateTimeLeft -= delta;
		if( updateTimeLeft<= 0 )
			RemoveTimer( 'UpdateIconOffset' );
	}
}