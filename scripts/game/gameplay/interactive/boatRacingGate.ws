/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class CBoatRacingGateEntity extends CGameplayEntity
{
	public editable var nextGate : EntityHandle;
	public editable var factOnReaching : string;
	
	private var nextGateEntity : CBoatRacingGateEntity;
	private var isActive : bool;
	private var isReached : bool;
	
	default isActive = false;
	default isReached = false;
	default autoState = 'Inactive';
	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		GotoStateAuto();
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var boat : W3Boat;
		
		boat = (W3Boat)activator.GetEntity();
		
		if( area == (CTriggerAreaComponent)GetComponent( "trigger" ) && boat && boat.GetBoatComponent().user == thePlayer )
		{
			if( IsActive() && !IsReached() )
			{
				SetIsReached( true );
				GotoState( 'Inactive' );
				ActivateNextGate();
				AddFactOnReaching();
			}
		}
	}
	
	private function ActivateNextGate()
	{
		nextGateEntity = (CBoatRacingGateEntity)EntityHandleGet( nextGate );
		if( nextGateEntity )
		{
			nextGateEntity.GotoState( 'Active' );
		}
	}
	
	private function AddFactOnReaching()
	{
		if( factOnReaching != "" )
		{
			FactsAdd( factOnReaching, 1 );
		}
	}
	
	public function SetIsActive( val : bool )	{ isActive = val; }
	public function IsActive() : bool			{ return isActive; }
	
	public function SetIsReached( val : bool )	{ isReached = val; }
	public function IsReached() : bool			{ return isReached; }
	
	public function ActivateGate()
	{
		GotoState( 'Active' );
	}	
}

state Inactive in CBoatRacingGateEntity
{
}

state Active in CBoatRacingGateEntity
{
	event OnEnterState( prevStateName : name )
	{
		parent.PlayEffect( 'active' );
		parent.PlayEffect( 'active2' ); 
		
		EnableTrigger( true );
		EnableMappin( true );
		EnableHudMarker( true );
		
		parent.SetIsActive( true );
	}
	
	event OnLeaveState( prevStateName : name )
	{
		parent.StopAllEffects();
		
		EnableTrigger( false );
		EnableMappin( false );
		EnableHudMarker( false );
		
		parent.SetIsActive( false );
	}
	
	private function EnableTrigger( toggle : bool )
	{
		var triggerComp : CTriggerAreaComponent;
		
		triggerComp = (CTriggerAreaComponent)parent.GetComponent( "trigger" );
		if( triggerComp )
			triggerComp.SetEnabled( toggle );
	}
	
	private function EnableMappin( toggle : bool )
	{
		
	}
	
	private function EnableHudMarker( toggle : bool )
	{
		
	}
}