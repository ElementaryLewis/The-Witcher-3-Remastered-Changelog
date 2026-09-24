/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class CRiftEntity extends CInteractiveEntity
{
	editable var linkingMode : bool;
	editable var controlledEncounter : EntityHandle;
	editable var controlledEncounterTag : name;
	editable var activationDelay : float;
	editable var closeAfter	: float;
	editable var canBeDisabled : bool;
	editable var damageVal : SAbilityAttributeValue;
	editable var factSetAfterRiftWasDisabled : string;
	
	saved var isIntact : bool;
	saved var currState : name;
	
	var encounter : CEncounter;
	var coldArea : CTriggerAreaComponent;
	var entitiesInRange : array<CActor>;
	var isEncounterEnabled : bool;
	var buffParams : SCustomEffectParams;
	var spawnCounter : int;
	var encounterSpawnLimit : int;
	var collisionEntityTemplate : CEntityTemplate;
	var collisionEntity : CEntity;
	
	default linkingMode = true;
	default activationDelay = 1.5;
	default closeAfter = 5.0;
	default canBeDisabled = true;
	default isIntact = true;
	default autoState = 'Intact';
	default spawnCounter = 0;
	default encounterSpawnLimit = 0;
	
	hint linkingMode = "TRUE: Connect encounter through 'controlledEncounter' Entity Handle; FALSE: Connect encounter through 'controlledEncounterTag'";
	hint closeAfter = "-1 means it won't close by itself";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		PrepareCollisionEntity();
		
		if( linkingMode )
		{
			encounter = (CEncounter)EntityHandleGet( controlledEncounter );
		}
		else
		{
			encounter = (CEncounter)theGame.GetEntityByTag( controlledEncounterTag );
		}

		if( !encounter )
			LogChannel( 'Error', "Encounter not connected with " + this.GetName() );
		EnableEncounter( false );
		
		coldArea = (CTriggerAreaComponent)GetComponent( 'coldArea' );
		EnableColdArea( false );
		
		if( spawnData.restored )
		{
			GotoState( currState );
		}
		else
		{
			isIntact = true;
			GotoStateAuto();
		}
	}
	
	
	
	public function ActivateRift( optional dontActivateEncounter : bool)
	{
		if( isIntact )
		{
			if( dontActivateEncounter )
				((CRiftEntityStateOpened)GetState('Opened')).DontEnableEncounterOnStart();
			GotoState( 'Opened' );
			isIntact = false;
		}
		else if ( !isEncounterEnabled && !dontActivateEncounter )
			EnableEncounter( true );
	}
	
	public final function SetCanBeDisabled(b : bool)
	{
		canBeDisabled = b;
	}
	
	public function DeactivateRiftIfPossible()
	{
		if( canBeDisabled )
			GotoState( 'Closed' );
	}
	
	public function DeactivateRift()
	{
		GotoState( 'Closed' );
	}
	
	timer function DeactivateRiftAfter( td : float , id : int )
	{
		DeactivateRift();
	}
	
	public function IsRiftOpen() : bool
	{
		return OnOpenedRiftCheck();
	}
	
	event OnOpenedRiftCheck()
	{
		return false;
	}
	
	event OnYrdenHit( caster : CGameplayEntity )
	{
		PlayEffect( 'rift_dimeritium' );
		DeactivateRiftIfPossible();
	}
	
	
	
	public function EnableEncounter( flag : bool )
	{
		encounter.EnableEncounter( flag );
		isEncounterEnabled = flag;
	}
	
	timer function DisableEncounterAfter( td : float , id : int )
	{
		EnableEncounter( false );
	}
	
	public function SetSpawnLimit( spawnLimit : int )
	{	
		encounterSpawnLimit = spawnLimit;
	}
	
	public function IncrementSpawnCounter()
	{
		spawnCounter += 1;
		CheckSpawnLimit();
	}
	
	private function CheckSpawnLimit()
	{
		if( spawnCounter >= encounterSpawnLimit )
		{
			AddTimer( 'DisableEncounterAfter', 0.0 );
			AddTimer( 'DeactivateRiftAfter', 2.0, , , , true );
		}
	}
	
	
	
	public function EnableColdArea( flag : bool )
	{
		coldArea.SetEnabled( flag );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var victim : CActor;
		
		if( (W3YrdenEntity)activator.GetEntity() )
		{
			PlayEffect( 'rift_dimeritium' );
			DeactivateRiftIfPossible();
		}
		
		victim = (CActor)activator.GetEntity();
		
		if( victim && GetAttitudeBetween( victim, thePlayer ) == AIA_Hostile )
			return false;
		
		if( victim && !entitiesInRange.Contains( victim ) )
			entitiesInRange.PushBack( victim );
			
		if( entitiesInRange.Size() == 1 )
			AddTimer( 'ProcessArea', 0.1, true );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var victim : CActor;
		victim = (CActor)activator.GetEntity();
		
		if( victim && GetAttitudeBetween( victim, thePlayer ) == AIA_Hostile )
			return false;
		
		if( victim && entitiesInRange.Contains( victim ) )
		{
			entitiesInRange.Remove( victim );
			victim.StopEffect( 'breath' );
		}
		
		if( entitiesInRange.Size() == 0 )
			RemoveTimer( 'ProcessArea' );
	}
	
	timer function ProcessArea( deltaTime : float , id : int)
	{
		var i : int;

		buffParams.effectType = EET_Snowstorm;
		buffParams.duration = 0.5;
		buffParams.creator = this;
		buffParams.effectValue = damageVal;
		
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			entitiesInRange[i].AddEffectCustom( buffParams );
			entitiesInRange[i].PlayEffect( 'breath' );
		}
	}
	
	
	
	public function PrepareCollisionEntity()
	{
		collisionEntityTemplate = (CEntityTemplate)LoadResource( 'riftBombCollision' );
	}
	
	public function CreateCollisionEntity()
	{
		if( collisionEntityTemplate )
		{
			collisionEntity = theGame.CreateEntity( collisionEntityTemplate, GetWorldPosition(), GetWorldRotation() );
		}
	}
	
	public function DestroyCollisionEntity()
	{
		collisionEntity.Destroy();
	}
	
	
	
	function OnDiscovered( discovered : bool )
	{
		theGame.GetCommonMapManager().SetEntityMapPinDiscoveredScript( false, entityName, discovered );
	}
}

state Intact in CRiftEntity
{
	event OnEnterState( prevStateName : name )
	{	
		parent.currState = 'Intact';
	}
}

state Opened in CRiftEntity
{
	public var enableEncounterOnStart : bool;
	
	default enableEncounterOnStart = true;
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.currState = 'Opened';
		
		parent.PlayEffect( 'rift_activate' );
		parent.CreateCollisionEntity();
		OpenRift();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
		enableEncounterOnStart = true;
	}
	
	entry function OpenRift()
	{
		Sleep( parent.activationDelay );
		if( enableEncounterOnStart )
			parent.EnableEncounter( true );
		parent.EnableColdArea( true );
		if( parent.closeAfter != -1 )
			parent.AddTimer( 'DeactivateRiftAfter', parent.closeAfter, , , , true );
		parent.OnDiscovered( true );
	}
	
	event OnOpenedRiftCheck()
	{
		return true;
	}
	
	function DontEnableEncounterOnStart()
	{
		enableEncounterOnStart = false;
	}
}

state Closed in CRiftEntity
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.currState = 'Closed';
		
		parent.StopEffect( 'rift_activate' );
		parent.DestroyCollisionEntity();
		CloseRift();
	}
	
	entry function CloseRift()
	{
		parent.EnableEncounter( false );
		parent.EnableColdArea( false );
		parent.RemoveTimer( 'ProcessArea' );
		if( parent.factSetAfterRiftWasDisabled != "" )
			FactsAdd( parent.factSetAfterRiftWasDisabled, 1 );
		parent.OnDiscovered( false );
	}
}