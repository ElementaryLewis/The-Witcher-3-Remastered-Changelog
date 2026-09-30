/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskPerformParry extends CBTTaskPlayAnimationEventDecorator
{
	public var activationTimeLimitBonusHeavy 	: float;
	public var activationTimeLimitBonusLight 	: float;
	public var checkParryChance 				: bool;
	public var interruptTaskToExecuteCounter 	: bool;
	public var allowParryOverlap 				: bool;
	
	private var activationTimeLimit 			: float;
	private var action 							: CName;
	private var runMain 						: bool;
	private var parryChance 					: float;
	private var counterChance 					: float;
	private var counterMultiplier 				: float;
	private var hitsToCounter 					: int;
	private var swingType 						: int;
	private var swingDir 						: int;
	
	default activationTimeLimit = 0.0;
	default action = '';
	default runMain = false;
	default allowParryOverlap = true;
	
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		if ( ((CHumanAICombatStorage)combatDataStorage).IsProtectedByQuen() )
		{
			GetNPC().SetParryEnabled(true);
			return false;
		}
		else if ( activationTimeLimit > 0.0 && ( isActive || !combatDataStorage.GetIsAttacking() ) )
		{
			if ( GetLocalTime() < activationTimeLimit )
			{
				return true;
			}
			activationTimeLimit = 0.0;
			return false;
		}
		else if ( GetNPC().HasShieldedAbility() && activationTimeLimit > 0.0 )
		{
			GetNPC().SetParryEnabled(true);
			return false;
		}
		else
			GetNPC().SetParryEnabled(false);
			
		return false;
		
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		
		if ( swingDir != -1 )
		{
			npc.SetBehaviorVariable( 'HitSwingDirection', swingDir );
		}
		if ( swingType != -1 )
		{
			npc.SetBehaviorVariable( 'HitSwingType', swingType );
		}
		
		InitializeCombatDataStorage();
		npc.SetParryEnabled(true);
		LogChannel( 'HitReaction', "TaskActivated. ParryEnabled" );
		
		if ( action == 'ParryPerform' )
		{
			if ( TryToParry() )
			{
				runMain = true;
				RunMain();
			}
			action = '';
		}
		
		if ( CheckCounter() && interruptTaskToExecuteCounter )
		{
			npc.DisableHitAnimFor(0.1);
			activationTimeLimit = 0.0;
			return BTNS_Completed;
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var resStart,resEnd : bool = false;
		while ( runMain )
		{
			resStart = GetNPC().WaitForBehaviorNodeDeactivation('ParryPerformEnd',2.f);
			resEnd = GetNPC().WaitForBehaviorNodeActivation('ParryPerformStart',0.0001f);
			if ( !resEnd )
			{
				activationTimeLimit = 0;
				runMain = false;
			}
			if ( resStart && resEnd )
			{
				SleepOneFrame();
			}
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetParryEnabled( false );
		runMain = false;
		activationTimeLimit = 0;
		action = '';
		swingType = -1;
		swingDir = -1;
		
		((CHumanAICombatStorage)combatDataStorage).ResetParryCount();
		
		super.OnDeactivate();
		
		LogChannel( 'HitReaction', "PerformParry Task Deactivated" );
	}
	
	private function CheckCounter() : bool
	{
		var npc : CNewNPC = GetNPC();
		var defendCounter : int;
		
		defendCounter = npc.GetDefendCounter();
		if ( defendCounter >= hitsToCounter )
		{
			if( Roll( counterChance ) )
			{
				npc.SignalGameplayEvent('CounterFromDefence');
				return true;
			}
		}
		
		return false;
	}
	
	private function GetStats()
	{
		var actor : CActor = GetActor();
		
		
		var multiplier : float;

		if( FactsQuerySum("NewGamePlus") > 0 )
			multiplier = 1.15;
		else
			multiplier = 1.0;
		
		
		parryChance = MaxF(0, ClampF(multiplier*100*CalculateAttributeValue(actor.GetAttributeValue('parry_chance')),0,100));	
		counterChance = MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('counter_chance')));
		counterMultiplier = (int)MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('counter_chance_per_hit')));
		hitsToCounter = (int)MaxF(0, CalculateAttributeValue(actor.GetAttributeValue('hits_to_roll_counter')));
		counterChance += Max( 0, actor.GetDefendCounter() ) * counterMultiplier;
		
		if ( hitsToCounter < 0 )
		{
			hitsToCounter = 65536;
		}
	}
	
	private function CanParry() : bool
	{
		if ( checkParryChance )
		{
			if ( RandRange(100) < parryChance )
			{
				return true;
			}
			
			return false;
		}
		
		return true;
	}
	
	private function TryToParry(optional counter : bool) : bool
	{
		var npc : CNewNPC = GetNPC();
		var mult : float;
		
		if ( isActive && npc.CanParryAttack() && allowParryOverlap )
		{
			LogChannel( 'HitReaction', "Parried" );
			
			npc.SignalGameplayEvent('SendBattleCry');
			
			mult = theGame.params.HEAVY_STRIKE_COST_MULTIPLIER;
			
			if ( npc.RaiseEvent('ParryPerform') )
			{
				if( counter )
				{
					npc.DrainStamina( ESAT_Counterattack, 0, 0, '', 0 );
					npc.SignalGameplayEvent('Counter');
				}
				else
					npc.DrainStamina( ESAT_Parry, 0, 0, '', 0, mult );
				
				((CHumanAICombatStorage)combatDataStorage).IncParryCount();
				npc.IncDefendCounter();
				activationTimeLimit = GetLocalTime() + 0.5;
			}
			else
			{
				Complete(false);
			}
			
			return true;
			
		}
		else if ( isActive )
		{
			Complete(false);
			activationTimeLimit = 0.0;
		}
		
		
		return false;
	}
	
	function AdditiveParry( optional force : bool) : bool
	{
		var npc : CNewNPC = GetNPC();

		if ( force || (!isActive && npc.CanParryAttack() && combatDataStorage.GetIsAttacking()) )
		{
			npc.RaiseEvent('PerformAdditiveParry');
			return true;
		}
		
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var res : bool;
		var isHeavy : bool;
		
		InitializeCombatDataStorage();
		
		if ( eventName == 'swingType' )
		{
			swingType = this.GetEventParamInt(-1);
		}
		if ( eventName == 'swingDir' )
		{
			swingDir = this.GetEventParamInt(-1);
		}
		
		
		if ( eventName == 'ParryStart' )
		{
			GetStats();
			
			if ( interruptTaskToExecuteCounter && CheckCounter() && !GetNPC().IsCountering() )
			{
				GetNPC().DisableHitAnimFor(0.1);
				activationTimeLimit = 0.0;
				Complete(true);
				return false;
			}
			
			if ( CanParry() )
			{
				isHeavy = GetEventParamInt(-1);
				
				if ( isHeavy )
					activationTimeLimit = GetLocalTime() + activationTimeLimitBonusHeavy;
				else
					activationTimeLimit = GetLocalTime() + activationTimeLimitBonusLight;
				
				if ( GetNPC().HasShieldedAbility() )
				{
					GetNPC().SetParryEnabled(true);
				}
			}
			return true;
		}
		
		else if ( eventName == 'ParryPerform' )
		{
			if( AdditiveParry() )
				return true;
			
			if( !isActive )
				return false;
			
			isHeavy = GetEventParamInt(-1);
			if( ShouldCounter(isHeavy) )
				res = TryToParry(true);
			else
				res = TryToParry();
			
			if( res )
			{
				runMain = true;
				RunMain();
			}		
			return true;
		}
		
		else if ( eventName == 'CounterParryPerform' )
		{
			if ( TryToParry(true) )
			{
				runMain = true;
				RunMain();
			}
			return true;
		}
		
		else if( eventName == 'ParryStagger' )
		{
			if( !isActive )
				return false;
				
			if( GetNPC().HasShieldedAbility() )
			{
				GetNPC().AddEffectDefault( EET_Stagger, GetCombatTarget(), "ParryStagger" );
				runMain = false;
				activationTimeLimit = 0.0;
			}
			else if ( TryToParry() )
			{
				GetNPC().LowerGuard();
				runMain = false;
			}
			return true;
		}
		
		else if ( eventName == 'ParryEnd' )
		{
			activationTimeLimit = 0.0;
			return true;
		}
		else if ( eventName == 'PerformAdditiveParry' )
		{
			AdditiveParry(true);
			return true;
		}
		else if ( eventName == 'WantsToPerformDodgeAgainstHeavyAttack' && GetActor().HasAbility('ablPrioritizeAvoidingHeavyAttacks') )
		{
			activationTimeLimit = 0.0;
			if ( isActive )
				Complete(true);
			return true;
		}
		
		return super.OnGameplayEvent ( eventName );
	}
	
	function ShouldCounter(isHeavy : bool) : bool
	{
		var playerTarget : W3PlayerWitcher;
		var temp, temp2		:int;
		
		if ( GetActor().HasAbility('DisableCounterAttack') )
			return false;
		
		playerTarget = (W3PlayerWitcher)GetCombatTarget();
		
		if ( playerTarget && playerTarget.IsInCombatAction_SpecialAttack() )
			return false;
		
		if ( isHeavy && !GetActor().HasAbility('ablCounterHeavyAttacks') )
			return false;
			
		temp = ((CHumanAICombatStorage)combatDataStorage).GetParryCount();
		temp2 = hitsToCounter;
		return ((CHumanAICombatStorage)combatDataStorage).GetParryCount() >= hitsToCounter && Roll(counterChance);
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class CBTTaskPerformParryDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskPerformParry';

	editable var activationTimeLimitBonusHeavy 		: CBehTreeValFloat;
	editable var activationTimeLimitBonusLight 		: CBehTreeValFloat;
	editable var checkParryChance 					: bool;
	editable var interruptTaskToExecuteCounter 		: bool;
	editable var allowParryOverlap 					: bool;

	default finishTaskOnAllowBlend = false;
	default allowParryOverlap = true;
	
	hint checkParryChance = "added 18.01.2016, previously npc's used only raise guard chance";
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'ParryStart' );
		listenToGameplayEvents.PushBack( 'ParryPerform' );
		listenToGameplayEvents.PushBack( 'CounterParryPerform' );
		listenToGameplayEvents.PushBack( 'ParryStagger' );
		listenToGameplayEvents.PushBack( 'ParryEnd' );
		listenToGameplayEvents.PushBack( 'PerformAdditiveParry' );
		listenToGameplayEvents.PushBack( 'WantsToPerformDodgeAgainstHeavyAttack' );
		listenToGameplayEvents.PushBack( 'IgniShieldUp' );
		listenToGameplayEvents.PushBack( 'IgniShieldDown' );
		listenToGameplayEvents.PushBack( 'swingType' );
		listenToGameplayEvents.PushBack( 'swingDir' );
	}
}

class CBTTaskCombatStylePerformParry extends CBTTaskPerformParry
{
	public var parentCombatStyle : EBehaviorGraph;
	
	function GetActiveCombatStyle() : EBehaviorGraph
	{
		InitializeCombatDataStorage();
		if ( combatDataStorage )
			return ((CHumanAICombatStorage)combatDataStorage).GetActiveCombatStyle();
		else
			return EBG_Combat_Undefined;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid(eventName) && parentCombatStyle != GetActiveCombatStyle() )
		{
			return false;
		}
		return super.OnListenedGameplayEvent(eventName);
	}
}

class CBTTaskCombatStylePerformParryDef extends CBTTaskPerformParryDef
{
	default instanceClass = 'CBTTaskCombatStylePerformParry';

	editable inlined var parentCombatStyle : CBTEnumBehaviorGraph;
}
