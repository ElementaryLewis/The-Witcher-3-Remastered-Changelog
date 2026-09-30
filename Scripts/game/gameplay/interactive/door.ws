/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EDoorOperation
{
	DO_Open,
	DO_Close,
	DO_Toggle,
	DO_Lock,
	DO_Unlock,
	DO_ToggleLock,
}


class W3Door extends W3LockableEntity
{
	editable var rotDir : int;
	editable var initiallyOpened : bool;
	editable var factOnPlayerDoorOpen : name;
	private saved var isOpened : bool;	
	
	protected autobind openInteractionComponent : CInteractionComponent = "Open";
	protected autobind closeInteractionComponent : CInteractionComponent = "Close";
	
	hint rotDir = "Door rotation angle upon opening";
	hint initiallyOpened = "If true then doors will be opened on game start";
	hint factOnPlayerDoorOpen = "Name of the fact that will be added each time when player actively opens the door";

	event OnSpawned( spawnData : SEntitySpawnData ) 
	{		
		if( closeInteractionComponent )
		{
			closeInteractionComponent.SetEnabled( false ); 
		}
			
		if((!spawnData.restored && initiallyOpened) || (spawnData.restored && isOpened))
		{
			isOpened = false;
			Open();
		}
		else
		{
			isOpened = false;			
		}
		
		SetFocusModeVisibility( FMV_Interactive );		
		
		super.OnSpawned(spawnData);
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var processed : bool;
			
		if ( activator != thePlayer || isInteractionBlocked)
			return false;
			
		processed = super.OnInteraction(actionName, activator);
		if(processed)
			return true;		
			
		if(actionName == "Open")
		{			
			if(Open())
				FactsAdd(factOnPlayerDoorOpen,1, 3 );
		}
		else if(actionName == "Close")
		{
			Close();
		}
	}
	
	event OnManageDoor( operations : array< EDoorOperation >, force : bool )
	{
		var i, size : int;
		
		
		size = operations.Size();
		for ( i = 0; i < size; i += 1 )
		{
			switch ( operations[ i ] )
			{
			case DO_Open:
				if ( CanBeOpened( force ) )
				{
					Open();
				}
				break;
			case DO_Close:
				if ( CanBeClosed( force ) )
				{
					Close();
				}
				break;
			case DO_Toggle:
				Toggle( force );
				break;
			case DO_Lock:
				if ( !IsLocked() )
				{
					Lock( 'anykey' );
				}
				break;
			case DO_Unlock:
				if ( IsLocked() )
				{
					Unlock();
				}
				break;
			case DO_ToggleLock:
				ToggleLock();
				break;
			}
		}
	}

	public function Close()
	{
		var rot : EulerAngles;
		
		if(!isOpened)
			return;
	
		rot = GetWorldRotation();
		rot.Yaw = rot.Yaw - rotDir;
		
		TeleportWithRotation(GetWorldPosition(), rot);

		if( closeInteractionComponent ) 	closeInteractionComponent.SetEnabled(false);
		if( openInteractionComponent ) 		openInteractionComponent.SetEnabled(true);
		
		isOpened = false;
	}
	
	public function Toggle( force : bool )
	{
		if ( IsOpened() )
		{
			if ( CanBeClosed( force ) )
			{
				Close();
			}
		}
		else
		{
			if ( CanBeOpened( force ) )
			{
				Open();
			}
		}
	}
	
	public function CanBeOpened( force : bool ) : bool
	{
		return !IsOpened() && ( !IsLocked() || force );
	}
	
	public function CanBeClosed( force : bool ) : bool
	{
		return IsOpened() && ( !IsLocked() || force );
	}
	
	public function IsOpened() : bool
	{
		return isOpened;
	}

	public function Open() : bool
	{
		var rot : EulerAngles;
	
		if(isOpened)
			return false;
	
		rot = GetWorldRotation();
		rot.Yaw = rot.Yaw + rotDir;
		
		TeleportWithRotation(GetWorldPosition(), rot);
		
		if( openInteractionComponent )		openInteractionComponent.SetEnabled(false);
		if( closeInteractionComponent )		closeInteractionComponent.SetEnabled(true);
		
		isOpened = true;	
		
		if ( IsLocked() )
		{
			Unlock();
		}
		return true;
	}
	
	protected function OnLock()
	{
		Close();
	}
	
	event OnStateChange( newState : bool )
	{
		if( isOpened )
		{
			if( closeInteractionComponent )
			{
				closeInteractionComponent.SetEnabled( newState );
			}
		}
		else
		{
			if( openInteractionComponent )
			{
				openInteractionComponent.SetEnabled( newState );
			}
		}
		
		super.OnStateChange( newState );
	}
	
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		super.OnInteractionActivated(interactionComponentName, activator);
		if(activator == thePlayer)
			ShowInteractionComponent();
	}
}