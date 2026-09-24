/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskKill extends IBehTreeTask
{
	var actor, owner	: CActor;
	
	var fact					: string;
	var value					: int;
	var validFor				: int;
	var signalGameplayEvent 	: name;
	var playEffectOnKill 		: name;
	var self 					: bool;
	var target					: bool;
	var player					: bool;
	var onlyBelowHealthPercent 	: float;
	var onDamageTaken			: bool;
	var onAardHit				: bool;
	var onIgniHit				: bool;
	var onAxiiHit				: bool;
	var onHeadshot 				: bool;
	var onCustomHit 			: bool;
	var onActivate 				: bool;
	var onDeactivate 			: bool;
	var onListenToGameplayEvents: bool;
	var setBehVarOnKill 		: name;
	var behVarValue 			: float;
	
	
	function OnActivate() : EBTNodeStatus
	{	
		if ( onActivate )
		{
			Execute();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			Execute();
		}
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( !onListenToGameplayEvents )
		{
			if ( onAardHit && eventName == 'AardHitReceived' )
			{
				Execute();
				return true;
			}
			
			if ( onIgniHit && eventName == 'IgniHitReceived' )
			{
				Execute();
				return true;
			}
			
			if ( onIgniHit && eventName == 'AxiiHitReceived' )
			{
				Execute();
				return true;
			}
			
			if ( onDamageTaken && eventName == 'DamageTaken' )
			{
				Execute();
				return true;
			}
			
			if ( onHeadshot && eventName == 'Headshot' || eventName == 'CollisionWithProjectileCustom' )
			{
				Execute();
				return true;
			}
		}
		
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( onListenToGameplayEvents )
		{
			if ( onAardHit && eventName == 'AardHitReceived' )
			{
				Execute();
				return true;
			}
			
			if ( onIgniHit && eventName == 'IgniHitReceived' )
			{
				Execute();
				return true;
			}
			
			if ( onIgniHit && eventName == 'AxiiHitReceived' )
			{
				Execute();
				return true;
			}
			
			if ( onDamageTaken && eventName == 'DamageTaken' )
			{
				Execute();
				return true;
			}
			
			if ( onHeadshot && eventName == 'Headshot' || eventName == 'CollisionWithProjectileCustom' )
			{
				Execute();
				return true;
			}
			
			if ( onCustomHit && eventName == 'CustomHit' )
			{
				Execute();
				return true;
			}
		}
		
		return false;
	}
	
	function Execute()
	{
		actor = GetCombatTarget();
		owner = GetActor();
		
		
		owner.RaiseEvent('InterruptOverlay');
		owner.SetBehaviorVariable( 'disableOverride', 1.0, true );
		if ( target && actor.IsAlive() )
		{
			if ( actor.GetHealthPercents() <= onlyBelowHealthPercent )
			{
				if ( IsNameValid( setBehVarOnKill ) )
				{
					actor.SetBehaviorVariable( setBehVarOnKill, behVarValue, true );
				}
				actor.Kill( 'AI Task Kill' );
				if ( fact != "None" && fact != "" )
				{
					FactsAdd( fact, value, validFor ); 
				}
				if ( IsNameValid( signalGameplayEvent ) )
				{
					actor.SignalGameplayEvent( signalGameplayEvent );
				}
				if ( IsNameValid( playEffectOnKill ) )
				{
					actor.PlayEffect( playEffectOnKill );
				}
			}
		}
		if ( player && thePlayer.IsAlive() )
		{
			if ( thePlayer.GetHealthPercents() <= onlyBelowHealthPercent )
			{
				if ( IsNameValid( setBehVarOnKill ) )
				{
					thePlayer.SetBehaviorVariable( setBehVarOnKill, behVarValue, true );
				}
				thePlayer.Kill( 'AI Task Kill' );
				if ( fact != "None" && fact != "" )
				{
					FactsAdd( fact, value, validFor ); 
				}
				if ( IsNameValid( signalGameplayEvent ) )
				{
					thePlayer.SignalGameplayEvent( signalGameplayEvent );
				}
				if ( IsNameValid( playEffectOnKill ) )
				{
					thePlayer.PlayEffect( playEffectOnKill );
				}
			}
		}
		if ( self && owner.IsAlive() )
		{
			if ( owner.GetHealthPercents() <= onlyBelowHealthPercent )
			{
				if ( IsNameValid( setBehVarOnKill ) )
				{
					owner.SetBehaviorVariable( setBehVarOnKill, behVarValue, true );
				}
				owner.Kill( 'AI Task Kill' );
				if ( fact != "None" && fact != "" )
				{
					FactsAdd( fact, value, validFor ); 
				}
				if ( IsNameValid( signalGameplayEvent ) )
				{
					owner.SignalGameplayEvent( signalGameplayEvent );
				}
				if ( IsNameValid( playEffectOnKill ) )
				{
					owner.PlayEffect( playEffectOnKill );
				}
			}
		}
	}
}

class CBTTaskKillDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskKill';
	
	editable var fact						: string;
	editable var value						: int;
	editable var validFor					: int;
	editable var signalGameplayEvent 		: name;
	editable var playEffectOnKill 			: name;
	editable var onActivate 				: bool;
	editable var onDeactivate 				: bool;
	editable var target						: bool;
	editable var player						: bool;
	editable var self						: bool;
	editable var onlyBelowHealthPercent  	: float;
	editable var onAardHit					: bool;
	editable var onIgniHit					: bool;
	editable var onAxiiHit					: bool;
	editable var onCustomHit				: bool;
	editable var onHeadshot 				: bool;
	editable var onDamageTaken				: bool;
	editable var onListenToGameplayEvents 	: bool;
	editable var setBehVarOnKill 			: name;
	editable var behVarValue 				: float;
	
	
	default onlyBelowHealthPercent = 1.0;
	
	hint target = "Kills the current target.";
	hint player = "Kills the current player character.";
	hint self = "Kills the owner of the AI Tree.";
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'AardHitReceived' );
		listenToGameplayEvents.PushBack( 'IgniHitReceived' );
		listenToGameplayEvents.PushBack( 'AxiiHitReceived' );
		listenToGameplayEvents.PushBack( 'DamageTaken' );
		listenToGameplayEvents.PushBack( 'Headshot' );
		listenToGameplayEvents.PushBack( 'CustomHit' );
		listenToGameplayEvents.PushBack( 'CollisionWithProjectileCustom' );
	}
}
