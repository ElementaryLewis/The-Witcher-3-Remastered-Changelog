/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3CriticalStateTrap extends CInteractiveEntity
{
	editable var effectOnSpawn				: name;
	editable var effectToPlayOnActivation	: name;
	editable var durationFrom				: int;
	editable var durationTo					: int;
	
	var areasActive						: bool;
	var movementAdjustorActive			: bool;
	var params 							: SCustomEffectParams;
	var movementAdjustor				: CMovementAdjustor;
	var ticket 							: SMovementAdjustmentRequestTicket;
	var ticketRot						: SMovementAdjustmentRequestTicket;
	var lifeTime						: int;
	var l_effectDuration				: int;
	var startTimestamp					: float;
	var enterTimestamp					: float;
	
	default areasActive = true;
	default movementAdjustorActive = false;
	default durationTo = 10;
	default durationFrom = 0;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		PlayEffect( effectOnSpawn );
		lifeTime = RandRange(durationTo,durationFrom);
		AddTimer('DestroyEntityAfter', lifeTime, false );
		startTimestamp = theGame.GetEngineTimeAsSeconds();
		super.Init();
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( area == (CTriggerAreaComponent)this.GetComponent( "TrapTrigger" ) && activator.GetEntity() == thePlayer && areasActive )
		{
			
			PlayEffect( effectToPlayOnActivation );
		}
		
		if( area == (CTriggerAreaComponent)this.GetComponent( "TrapMovementAdjust" ) && areasActive )
		{
			params.effectType = EET_Trap;
			enterTimestamp = theGame.GetEngineTimeAsSeconds();
			l_effectDuration = (int)(enterTimestamp - startTimestamp);
			params.duration = ( lifeTime - l_effectDuration )+1;
			PlayEffect( effectToPlayOnActivation );
			thePlayer.AddEffectCustom(params);
			
			movementAdjustor = thePlayer.GetMovingAgentComponent().GetMovementAdjustor();
			ticketRot = movementAdjustor.CreateNewRequest( 'CriticalTrapRotate' );
			movementAdjustor.RotateTowards( ticketRot, this );
			movementAdjustor.BindToEvent( ticketRot, 'RotateTowards');
			AddTimer( 'MovementAdjustTimer', 0.2, false );
		}
		
	}
	timer function MovementAdjustTimer( delta : float , id : int )
	{
		if( movementAdjustor && !movementAdjustor.IsRequestActive(ticket) )
		{
			ticket = movementAdjustor.CreateNewRequest( 'CriticalTrapSlide' );
			movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 4.f );
			movementAdjustor.SlideTowards( ticket, this );
			movementAdjustor.Continuous(ticket);
		}
	}
	
	timer function DestroyEntityAfter( dt : float , id: int )
	{
		areasActive = false;
		movementAdjustor.CancelByName('CriticalTrapSlide');
		movementAdjustor.CancelByName('CriticalTrapRotate');
		StopEffects();
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( area == (CTriggerAreaComponent)this.GetComponent( "TrapTrigger" ) && activator.GetEntity() == thePlayer )
		{
			StopEffect( effectToPlayOnActivation );
		}
		if( area == (CTriggerAreaComponent)this.GetComponent("TrapMovementAdjust") )
		{
			movementAdjustor.CancelByName('CriticalTrapSlide');
			movementAdjustor.CancelByName('CriticalTrapRotate');
			RemoveTimer( 'MovementAdjustTimer' );
		}
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		StopEffects();
	}
	
	private function StopEffects()
	{
		StopAllEffects();
		DestroyAfter( 2.0f );
	}
}

