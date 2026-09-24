/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCombatStorage extends IBehTreeTask
{
	protected var combatDataStorage : CBaseAICombatStorage;
	
	public var setIsShooting 	: bool;
	public var setIsAiming 		: bool;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		InitializeCombatDataStorage();
		if ( setIsShooting )
			combatDataStorage.SetIsShooting( true );
		if ( setIsAiming )
			combatDataStorage.SetIsAiming( true );
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( setIsShooting )
			combatDataStorage.SetIsShooting( false );
		if ( setIsAiming )
			combatDataStorage.SetIsAiming( false );
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
	
}

class CBTTaskCombatStorageDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCombatStorage';

	editable var setIsShooting 	: bool;
	editable var setIsAiming 	: bool;
}



class CBehTreeTaskCombatStorageCleanup extends IBehTreeTask
{
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function OnActivate() : EBTNodeStatus
	{
		
		GetNPC().DisableLookAt();
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		InitializeCombatDataStorage();
		
		combatDataStorage.SetActiveCombatStyle( EBG_Combat_Undefined );
		combatDataStorage.SetPreCombatWarning( true );
		combatDataStorage.SetProcessingItems( false );
		combatDataStorage.SetProcessingRequiresIdle( false );
		
		npc.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)GMM_Default );
		
		npc.OnAllowBehGraphChange();
		
		npc.LowerGuard();
		
		combatDataStorage.DetachAndDestroyProjectile();
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'ItemProcessing' && isActive )
		{
			InitializeCombatDataStorage();
			
			combatDataStorage.SetProcessingItems( GetEventParamInt( 0 ) != 0 );
			
			return true;
		}
		else if ( eventName == 'ItemProcessingRequiresIdle' && isActive )
		{
			InitializeCombatDataStorage();
			
			combatDataStorage.SetProcessingRequiresIdle( GetEventParamInt( 0 ) != 0 );
			
			return true;
		}
		return false;
	}

	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class CBehTreeTaskCombatStorageCleanupDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskCombatStorageCleanup';
	
	public function InitializeEvents()
	{
		super.InitializeEvents();
		
		listenToGameplayEvents.PushBack( 'ItemProcessing' );
		listenToGameplayEvents.PushBack( 'ItemProcessingRequiresIdle' );
	}
}



class CBTTaskPreCombatWarning extends IBehTreeTask
{
	protected var combatDataStorage : CBaseAICombatStorage;
	
	public var setFlagOnActivate 	: bool;
	public var setFlagOnDectivate 	: bool;
	
	public var flag : bool;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		InitializeCombatDataStorage();
		if ( setFlagOnActivate )
		{
			combatDataStorage.SetPreCombatWarning( flag );
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( setFlagOnDectivate )
		{
			combatDataStorage.SetPreCombatWarning( flag );
		}
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class CBTTaskPreCombatWarningDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPreCombatWarning';

	editable var setFlagOnActivate : bool;
	editable var setFlagOnDectivate : bool;
	
	editable var flag : bool;
}






class CBTTaskGetPreCombatWarning extends IBehTreeTask
{
	protected var combatDataStorage : CBaseAICombatStorage;
	
	public var setFlagOnActivate 	: bool;
	public var setFlagOnDectivate 	: bool;
	
	public var flag : bool;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		return combatDataStorage.GetPreCombatWarning();
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
	
}

class CBTTaskGetPreCombatWarningDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskGetPreCombatWarning';
}