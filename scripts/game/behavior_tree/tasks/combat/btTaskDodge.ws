/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDodge extends CBTTaskPlayAnimationEventDecorator
{
	protected var dodgeChanceAttackLight	: int;
	protected var dodgeChanceAttackHeavy	: int;
	protected var dodgeChanceAard			: int;
	protected var dodgeChanceIgni			: int;
	protected var dodgeChanceBomb			: int;
	protected var dodgeChanceProjectile		: int;
	protected var dodgeChanceFear			: int;
	protected var counterChance 			: float;
	protected var counterMultiplier 		: float;
	protected var hitsToCounter 			: int;
	
	protected var Time2Dodge				: bool;
	protected var dodgeType					: EDodgeType;
	protected var dodgeDirection			: EDodgeDirection;
	private var dodgeTime 					: float;
	private var dodgeEventTime 				: float;
	private var nextDodgeTime 				: float;
	private var performDodgeDelay			: float;
	private var ownerPosition				: Vector;
	private var swingType 					: int;
	private var swingDir 					: int;
	
	public var navmeshCheckDist 					: float;
	public var minDelayBetweenDodges 				: float;
	public var maxDistanceFromTarget				: float;
	public var movementAdjustorSlideDistance		: float;
	public var disableIsDodgingFlagAfter 			: float;
	public var allowDodgeWhileAttacking				: bool;
	public var signalGameplayEventWhileInHitAnim	: bool;
	public var alwaysAvailableOnDodgeType			: EDodgeType;
	
	public var allowDodgeOverlap 					: bool;
	public var earlyDodgeActivation 				: bool;
	public var interruptTaskToExecuteCounter 		: bool;
	public var ignoreDodgeChanceStats 				: bool;
	public var delayDodgeHeavyAttack 				: float;
	
	default Time2Dodge = false;
	default nextDodgeTime = 0.0;
	
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();

		if ( !npc.IsCurrentlyDodging() && Time2Dodge && dodgeEventTime )
		{
			if ( dodgeEventTime + 0.1 < GetLocalTime() )
			{
				Time2Dodge = false;
			}
			if ( delayDodgeHeavyAttack > 0 && dodgeEventTime > GetLocalTime() )
			{
				return false;
			}
		}
		
		return Time2Dodge && super.IsAvailable();
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
		npc.SetIsCurrentlyDodging(true);
		npc.IncDefendCounter();
		if ( interruptTaskToExecuteCounter && CheckCounter() )
		{
			npc.DisableHitAnimFor(0.1);
			return BTNS_Completed;
		}
		
		
		
		
		
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		Sleep( disableIsDodgingFlagAfter );
		GetActor().SetIsCurrentlyDodging(false);
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		
		swingType = -1;
		swingDir = -1;
		nextDodgeTime = GetLocalTime() + minDelayBetweenDodges;
		performDodgeDelay = 0;
		GetActor().SetIsCurrentlyDodging(false);
		super.OnDeactivate();
	}
	
	function Dodge() : bool
	{
		if ( dodgeEventTime + 0.1 < GetLocalTime() )
		{
			return false;
		}
		
		if ( nextDodgeTime >= GetLocalTime() )
		{
			return false;
		}
		
		if ( !CheckDistance() )
		{
			return false;
		}
		InitializeCombatDataStorage();
		if ( combatDataStorage.GetIsAttacking() && !allowDodgeWhileAttacking && alwaysAvailableOnDodgeType != dodgeType )
		{
			return false;
		}
		
		if( !ChooseAndCheckDodge() )
		{
			return false;
		}
		
		if( !CheckNavMesh() )
		{
			return false;
		}
		
		return true;
	}
	
	function CheckDistance() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var dist : float;
		
		if ( target && maxDistanceFromTarget > 0 && dodgeType != EDT_Projectile && dodgeType != EDT_Bomb )
		{
			dist = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );
			
			if( dist > maxDistanceFromTarget )
			{
				return false;
			}
		}
		
		return true;
	}
	
	function GetDodgeStats()
	{
		var npc : CNewNPC = GetNPC();
		
		
		var multiplier : float;

		if( FactsQuerySum("NewGamePlus") > 0 )
			multiplier = 1.15;
		else
			multiplier = 1.0;
		
		
		dodgeChanceAttackLight	= (int)(ClampF(multiplier*100*CalculateAttributeValue(npc.GetAttributeValue('dodge_melee_light_chance')),0,100));	
		dodgeChanceAttackHeavy	= (int)(ClampF(multiplier*100*CalculateAttributeValue(npc.GetAttributeValue('dodge_melee_heavy_chance')),0,100));	
		dodgeChanceAard			= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_magic_chance')));
		dodgeChanceIgni			= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_magic_chance')));
		dodgeChanceBomb			= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_bomb_chance')));
		dodgeChanceProjectile	= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_projectile_chance')));
		dodgeChanceFear			= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_fear_chance')));
		counterChance 			= MaxF(0, ClampF(multiplier*100*CalculateAttributeValue(npc.GetAttributeValue('counter_chance')),0,100));			
		hitsToCounter 			= (int)MaxF(0, CalculateAttributeValue(npc.GetAttributeValue('hits_to_roll_counter')));
		counterMultiplier 		= (int)MaxF(0, 100*CalculateAttributeValue(npc.GetAttributeValue('counter_chance_per_hit')));
		counterChance 			+= Max( 0, npc.GetDefendCounter() ) * counterMultiplier;
		
		if ( hitsToCounter < 0 )
		{
			hitsToCounter = 65536;
		}
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
	
	function ChooseAndCheckDodge() : bool
	{
		var npc 							: CNewNPC = GetNPC();
		var dodgeChance 					: int;
		
		switch (dodgeType)
		{
			case EDT_Attack_Light 	: dodgeChance = dodgeChanceAttackLight; 	break;
			case EDT_Attack_Heavy	: dodgeChance = dodgeChanceAttackHeavy; 	break;
			case EDT_Aard			: dodgeChance = dodgeChanceAard; 			break;
			case EDT_Igni			: dodgeChance = dodgeChanceIgni; 			break;
			case EDT_Bomb			: dodgeChance = dodgeChanceBomb; 			break;
			case EDT_Projectile		: dodgeChance = dodgeChanceProjectile; 		break;
			case EDT_Fear			: dodgeChance = dodgeChanceFear; 			break;
			default : return false;
		}
		
		if ( ( RandRange(100) < dodgeChance ) || ignoreDodgeChanceStats )
		{
			if (dodgeType == EDT_Attack_Light || dodgeType == EDT_Attack_Heavy || dodgeType == EDT_Fear)
			{
				dodgeDirection = EDD_Back;
			}
			else if ( dodgeType == EDT_Projectile || dodgeType == EDT_Bomb )
			{
				dodgeDirection = EDD_Back;
			}
			
			npc.SetBehaviorVariable( 'DodgeDirection',(int)dodgeDirection );
			return true;
		}
		
		return false;
	}
	
	function CheckNavMesh() : bool
	{
		var ownerPosition 		: Vector;
		var targetVector 		: Vector;
		
		if ( dodgeDirection == EDD_Back && GetCombatTarget() )
		{
			ownerPosition = GetActor().GetWorldPosition();
			targetVector = VecNormalize2D(GetActor().GetWorldPosition() - GetCombatTarget().GetWorldPosition());
			
			return theGame.GetWorld().NavigationLineTest(ownerPosition,ownerPosition + navmeshCheckDist*targetVector,GetActor().GetRadius());
		}
		
		return true;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		
		if ( eventName == 'swingType' )
		{
			swingType = this.GetEventParamInt(-1);
		}
		if ( eventName == 'swingDir' )
		{
			swingDir = this.GetEventParamInt(-1);
		}
		
		if ( eventName == 'Time2DodgeProjectile' )
		{
			dodgeType = EDT_Projectile;
			ownerPosition = npc.GetWorldPosition();
			performDodgeDelay = this.GetEventParamFloat(-1);
			performDodgeDelay = ClampF( (performDodgeDelay -0.4), 0, 99 );
			npc.AddTimer( 'DelayDodgeProjectileEventTimer', performDodgeDelay );
			return true;
		}
		else if ( eventName == 'Time2DodgeBomb' )
		{
			dodgeType = EDT_Bomb;
			ownerPosition = npc.GetWorldPosition();
			performDodgeDelay = this.GetEventParamFloat(-1);
			performDodgeDelay = ClampF( (performDodgeDelay -0.4), 0, 99 );
			npc.AddTimer( 'DelayDodgeBombEventTimer', performDodgeDelay );
			return true;
		}
		else if ( ( eventName == 'Time2DodgeFast' && earlyDodgeActivation ) || eventName == 'Time2Dodge' || eventName == 'Time2DodgeProjectileDelayed' || eventName == 'Time2DodgeBombDelayed' )
		{
			GetDodgeStats();
			if ( interruptTaskToExecuteCounter && CheckCounter() && !npc.IsCountering() )
			{
				npc.DisableHitAnimFor(0.1);
				Complete(true);
				return false;
			}
			
			if ( eventName != 'Time2DodgeProjectileDelayed' && eventName != 'Time2DodgeBombDelayed')
			{
				dodgeType = this.GetEventParamInt(-1);
			}
			
			if ( delayDodgeHeavyAttack > 0 && dodgeType == EDT_Attack_Heavy )
			{
				dodgeEventTime = GetLocalTime() + delayDodgeHeavyAttack;
			}
			else
			{
				dodgeEventTime = GetLocalTime();
			}
			
			if ( Dodge() )
			{
				Time2Dodge = true;
				if ( npc.IsInHitAnim() && signalGameplayEventWhileInHitAnim )
					npc.SignalGameplayEvent('WantsToPerformDodge');
				else if ( dodgeType == EDT_Attack_Heavy )
					npc.SignalGameplayEvent('WantsToPerformDodgeAgainstHeavyAttack');
				if ( allowDodgeOverlap && npc.IsCurrentlyDodging() )
				{
					Complete(true);
				}
			}
			
			return true;
		}		
		
		return false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc 				: CNewNPC = GetNPC();
		var target				: CActor = GetCombatTarget();
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var minDistance			: float;
		
		if ( movementAdjustorSlideDistance > 0 && animEventName == 'SlideToTarget' 
			&& ( animEventType == AET_DurationStart || animEventType == AET_DurationStartInTheMiddle )
			&& dodgeType != EDT_Projectile && dodgeType != EDT_Bomb )
		{
			movementAdjustor = npc.GetMovingAgentComponent().GetMovementAdjustor();
			
			if ( movementAdjustor )
			{
				ticket = movementAdjustor.CreateNewRequest( 'SlideAwayDodge' );
				movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
				movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 1000000 );
				movementAdjustor.ScaleAnimation( ticket );
				movementAdjustor.SlideTowards( ticket, target, movementAdjustorSlideDistance );
			}
			return true;
		}
		
		return super.OnAnimEvent(animEventName, animEventType, animInfo);
	}
	
	
	
}

class CBTTaskDodgeDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskDodge';

	editable var navmeshCheckDist					: float;
	editable var minDelayBetweenDodges 				: float;
	editable var maxDistanceFromTarget 				: float;
	editable var movementAdjustorSlideDistance		: float;
	editable var disableIsDodgingFlagAfter 			: float;
	editable var allowDodgeWhileAttacking 			: bool;
	editable var signalGameplayEventWhileInHitAnim 	: bool;
	editable var alwaysAvailableOnDodgeType			: EDodgeType;
	
	editable var allowDodgeOverlap 					: bool;
	editable var earlyDodgeActivation 				: bool;
	editable var interruptTaskToExecuteCounter 		: bool;
	editable var ignoreDodgeChanceStats 			: bool;
	editable var delayDodgeHeavyAttack 				: float;
	
	hint disableIsDodgingFlagAfter 					= "cannot be longer then animation duration";
	hint useAsTerminalAndAllowDodgeOverlap 			= "use this if you want dodge interrupting ongoing dodge";
	hint earlyDodgeActivation 						= "activate on the beginning of light attack, not on preattack event";
	
	default navmeshCheckDist 						= 3.f;
	default movementAdjustorSlideDistance			= 3.f;
	default minDelayBetweenDodges 					= 0;
	default maxDistanceFromTarget					= 5;
	default disableIsDodgingFlagAfter 				= 0.4;
	default allowDodgeWhileAttacking				= false;
	default signalGameplayEventWhileInHitAnim		= false;
	default alwaysAvailableOnDodgeType				= EDT_Undefined;
	
	default xmlStaminaCostName 						= 'dodge_stamina_cost';
	default drainStaminaOnUse 						= true;
	default allowDodgeOverlap 						= true;
	default earlyDodgeActivation 					= true;
	
	default rotateOnRotateEvent 					= false;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'Time2Dodge' );
		listenToGameplayEvents.PushBack( 'Time2DodgeProjectile' );
		listenToGameplayEvents.PushBack( 'Time2DodgeBomb' );
		listenToGameplayEvents.PushBack( 'Time2DodgeProjectileDelayed' );
		listenToGameplayEvents.PushBack( 'Time2DodgeBombDelayed' );
		listenToGameplayEvents.PushBack( 'swingType' );
		listenToGameplayEvents.PushBack( 'swingDir' );
	}
}

class CBTTaskCombatStyleDodge extends CBTTaskDodge
{
	public var parentCombatStyle : EBehaviorGraph;
	
	private var humanCombatDataStorage : CHumanAICombatStorage;
	
	function GetActiveCombatStyle() : EBehaviorGraph
	{
		InitializeCombatDataStorage();
		if ( humanCombatDataStorage )
			return humanCombatDataStorage.GetActiveCombatStyle();
		else
			return EBG_Combat_Undefined;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'Time2Dodge' && parentCombatStyle != GetActiveCombatStyle() )
		{
			return false;
		}
		return super.OnListenedGameplayEvent(eventName);
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !humanCombatDataStorage )
		{
			super.InitializeCombatDataStorage();
			humanCombatDataStorage = (CHumanAICombatStorage)combatDataStorage;
		}
	}
}

class CBTTaskCombatStyleDodgeDef extends CBTTaskDodgeDef
{
	default instanceClass = 'CBTTaskCombatStyleDodge';

	editable inlined var parentCombatStyle : CBTEnumBehaviorGraph;
}




class CBTTaskCircularDodge extends CBTTaskDodge
{
	var angle : float;
	
	
	function ChooseAndCheckDodge() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var dodgeChance : int;
		
		
		
		switch (dodgeType)
		{
			case EDT_Attack_Light	: dodgeChance = dodgeChanceAttackLight; break;
			case EDT_Attack_Heavy	: dodgeChance = dodgeChanceAttackHeavy; break;
			case EDT_Aard			: dodgeChance = dodgeChanceAard; break;
			case EDT_Igni			: dodgeChance = dodgeChanceIgni; break;
			case EDT_Bomb			: dodgeChance = dodgeChanceBomb; break;
			case EDT_Projectile		: dodgeChance = dodgeChanceProjectile; break;
			case EDT_Fear			: dodgeChance = dodgeChanceFear; break;
			default : return false;
		}
		
		npc.slideTarget = target;
		
		
		if (RandRange(100) < dodgeChance)
		{
			if (dodgeType == EDT_Attack_Light || dodgeType == EDT_Attack_Heavy || dodgeType == EDT_Fear)
			{
				dodgeDirection = EDD_Back;
			}
			else if ( RandRange(100) < 50 )
			{
				RotateToAngle( -angle );
				dodgeDirection = EDD_Left;
			}
			else
			{
				RotateToAngle( angle );
				dodgeDirection = EDD_Right;
			}
			npc.SetBehaviorVariable( 'DodgeDirection',(int)dodgeDirection);
			return true;
		}
		
		return false;
	}
	
	
	function RotateToAngle(angleDeg : float)
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		
		var angleRad : float;
		var fSin, fCos : float;
		
		var targetHeading : Vector;
		
		var heading : Vector = VecFromHeading(npc.GetHeading());
		angleRad = Deg2Rad(angleDeg);
		
		fSin = SinF(angleRad);
		fCos = CosF(angleRad);
		
		
		targetHeading.X = heading.X * fCos - heading.Y * fSin;
		targetHeading.Y = heading.X * fSin + heading.Y * fCos;
		targetHeading.Z = heading.Z;
		targetHeading.W = heading.W;
		
		
		
		
		npc.ActionSlideToWithHeadingAsync(npc.GetWorldPosition(), VecHeading(targetHeading) ,0.01);
		
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor;
		
		if ( eventName == 'RotateEventStart' )
		{
			target = npc.GetTarget();
			npc.SetRotationAdjustmentRotateTo( target );
			npc.slideTarget = target; 
			return true;
		}
		
		return super.OnGameplayEvent( eventName );
	}
}

class CBTTaskCircularDodgeDef extends CBTTaskDodgeDef
{
	default instanceClass = 'CBTTaskCircularDodge';

	editable var angle : float;
	
	hint angle = "0 to 180";
}