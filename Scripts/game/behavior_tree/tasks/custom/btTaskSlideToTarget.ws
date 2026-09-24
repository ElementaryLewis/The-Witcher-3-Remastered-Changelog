/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSlideToTarget extends IBehTreeTask
{
	var minDistance			: float;
	var maxDistance			: float;
	var maxSpeed			: float; 
	var onAnimEvent			: name;
	var adjustVertically 	: bool;
	var useCombatTarget 	: bool;
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc 				: CNewNPC = GetNPC();
		var target 				: CNode;
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var slidePos			: Vector;
		var rotateToTarget		: bool;
		
		if ( animEventName == onAnimEvent && ( animEventType == AET_DurationStart || animEventType == AET_DurationStartInTheMiddle ) )
		{
			if ( useCombatTarget )
			{
				target = (CNode)GetCombatTarget();
			}
			else
			{
				target = GetActionTarget();
			}
			movementAdjustor = npc.GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SlideToTarget' );
			ticket = movementAdjustor.CreateNewRequest( 'SlideToTarget' );
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			movementAdjustor.MaxLocationAdjustmentSpeed( ticket, maxSpeed );
			movementAdjustor.ScaleAnimation( ticket );
			if ( adjustVertically )
			{
				movementAdjustor.AdjustLocationVertically( ticket, true );
			}
			if( rotateToTarget )
			{
				movementAdjustor.RotateTowards( ticket, GetCombatTarget() );
			}
			movementAdjustor.SlideTowards( ticket, target, minDistance, maxDistance );
			return true;
		}
		
		return false;
	}
};

class CBTTaskSlideToTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSlideToTarget';

	editable var minDistance		: float;
	editable var maxDistance		: float;
	editable var maxSpeed			: float;
	editable var onAnimEvent		: name;
	editable var adjustVertically	: bool;
	editable var rotateToTarget		: bool;
	editable var useCombatTarget 	: bool;
	
	default minDistance = 1.5;
	default maxDistance = 2;
	default maxSpeed = 5;
	default onAnimEvent = 'SlideToTarget';
	default adjustVertically = false;
	default rotateToTarget	 = false;
	default useCombatTarget  = true;
	
	hint onAnimEvent = "Must be specified. Won't work without an event.";
};



class CBTTaskShadowDash extends IBehTreeTask
{
	public var slideSpeed 					: float;
	public var slideBehindTarget 			: bool;
	public var distanceOffset 				: float;
	public var disableCollision 			: bool;
	public var dealDamageOnContact 			: bool;
	public var damageVal 					: float;
	public var maxDist 						: float;
	public var sideStepDist 				: float;
	public var sideStepHeadingOffset 		: float;
	public var minDuration 					: float;
	public var maxDuration 					: float;
	public var slideBlendInTime 			: float;
	public var disableGameplayVisibility 	: bool;
	
	private var isSliding 					: bool;
	private var hitEntities 				: array<CEntity>;
	private var collisionGroupsNames 		: array<name>;
	
	function OnActivate() : EBTNodeStatus
	{
		collisionGroupsNames.PushBack( 'Character' );
		collisionGroupsNames.PushBack( 'Ragdoll' );
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		SlideStop(); 
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var ticket 						: SMovementAdjustmentRequestTicket;
		var movementAdjustor			: CMovementAdjustor;
		var slidePos 					: Vector;
		var slideDuration				: float;
		
		if( animEventName == 'ShadowDash' && animEventType == AET_DurationStart )
		{
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'ShadowDash' );
			movementAdjustor.CancelByName( 'ShadowStepRight' );
			movementAdjustor.CancelByName( 'ShadowDashLeft' );
			
			ticket = movementAdjustor.CreateNewRequest( 'ShadowDash' );
			slidePos = CalculateSlidePos();
			slideDuration = CalculateSlideDuration( slidePos );
			if ( maxDuration > 0 )
			{
				slideDuration = ClampF( slideDuration, minDuration, maxDuration );
			}
			
			movementAdjustor.Continuous( ticket );
			movementAdjustor.AdjustmentDuration( ticket, slideDuration );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.BlendIn( ticket, slideBlendInTime );
			if ( maxDist > 0.0 )
			{
				movementAdjustor.MaxLocationAdjustmentDistance( ticket, false, maxDist );
			}
			movementAdjustor.SlideTo( ticket, slidePos );
			movementAdjustor.MaxRotationAdjustmentSpeed( ticket, 9999 );
			movementAdjustor.RotateTowards( ticket, GetCombatTarget() );
			
			SlideStart();
			
			return true;
		}
		else if( animEventName == 'ShadowDashFrontOverrideParams' && animEventType == AET_DurationStart )
		{
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'ShadowDash' );
			movementAdjustor.CancelByName( 'ShadowStepRight' );
			movementAdjustor.CancelByName( 'ShadowDashLeft' );
			
			ticket = movementAdjustor.CreateNewRequest( 'ShadowDash' );
			
			slideBehindTarget = false;
			
			slidePos = CalculateSlidePos();
			slideDuration = CalculateSlideDuration( slidePos );
			if ( maxDuration > 0 )
			{
				slideDuration = ClampF( slideDuration, minDuration, maxDuration );
			}
			
			movementAdjustor.Continuous( ticket );
			movementAdjustor.AdjustmentDuration( ticket, slideDuration );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.BlendIn( ticket, slideBlendInTime );
			movementAdjustor.SlideTo( ticket, slidePos );
			movementAdjustor.RotateTowards( ticket, GetCombatTarget() );
			
			SlideStart();
			
			return true;
		}
		else if( animEventName == 'ShadowStepRight' && animEventType == AET_DurationStart )
		{
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'ShadowStepRight' );
			
			ticket = movementAdjustor.CreateNewRequest( 'ShadowStepRight' );
			slidePos = GetNPC().GetWorldPosition() + VecFromHeading( GetNPC().GetHeading() - sideStepHeadingOffset ) * sideStepDist;
			slideDuration = CalculateSlideDuration( slidePos );
			if ( maxDuration > 0 )
			{
				slideDuration = ClampF( slideDuration, minDuration, maxDuration );
			}
			
			movementAdjustor.Continuous( ticket );
			movementAdjustor.AdjustmentDuration( ticket, slideDuration );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.BlendIn( ticket, slideBlendInTime );
			movementAdjustor.SlideTo( ticket, slidePos );
			movementAdjustor.RotateTowards( ticket, GetCombatTarget() );
			
			SlideStart();
			
			return true;
		}
		else if( animEventName == 'ShadowStepLeft' && animEventType == AET_DurationStart )
		{
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'ShadowStepLeft' );
			
			ticket = movementAdjustor.CreateNewRequest( 'ShadowStepLeft' );
			slidePos = GetNPC().GetWorldPosition() + VecFromHeading( GetNPC().GetHeading() + sideStepHeadingOffset ) * sideStepDist;
			slideDuration = CalculateSlideDuration( slidePos );
			if ( maxDuration > 0 )
			{
				slideDuration = ClampF( slideDuration, minDuration, maxDuration );
			}
			
			movementAdjustor.Continuous( ticket );
			movementAdjustor.AdjustmentDuration( ticket, slideDuration );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.BlendIn( ticket, slideBlendInTime );
			movementAdjustor.SlideTo( ticket, slidePos );
			movementAdjustor.RotateTowards( ticket, GetCombatTarget() );
			
			SlideStart();
			
			return true;
		}
		else if( animEventName == 'ShadowDashLeft' && animEventType == AET_DurationStart )
		{
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'ShadowDashLeft' );
			
			ticket = movementAdjustor.CreateNewRequest( 'ShadowDashLeft' );
			slidePos = GetNPC().GetWorldPosition() + VecFromHeading( GetNPC().GetHeading() + 90.0 ) * sideStepDist;
			slideDuration = CalculateSlideDuration( slidePos );
			if ( maxDuration > 0 )
			{
				slideDuration = ClampF( slideDuration, minDuration, maxDuration );
			}
			
			movementAdjustor.Continuous( ticket );
			movementAdjustor.AdjustmentDuration( ticket, slideDuration );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.BlendIn( ticket, slideBlendInTime );
			movementAdjustor.SlideTo( ticket, slidePos );
			movementAdjustor.RotateTowards( ticket, GetCombatTarget() );
			
			SlideStart();
			
			return true;
		}
		else if( ( animEventName == 'ShadowDash' || animEventName == 'ShadowDashFrontOverrideParams' || animEventName == 'ShadowStepRight' || 
			animEventName == 'ShadowStepLeft' || animEventName == 'ShadowDashLeft' ) && animEventType == AET_DurationEnd )
		{
			SlideStop();
			
			return true;
		}
		
		return false;
	}
	
	private function SlideStart()
	{
		if( disableCollision )
		{
			GetActor().EnableCharacterCollisions( false );
		}
		if ( disableGameplayVisibility )
		{
			GetNPC().SetGameplayVisibility( false );
		}
		if( dealDamageOnContact )
		{
			RunMain();
		}
		
		SetIsSliding( true );
	}
	
	private function SlideStop()
	{
		if( disableCollision )
		{
			GetActor().EnableCharacterCollisions( true );
			
		}
		if ( disableGameplayVisibility )
		{
			GetNPC().SetGameplayVisibility( true );
		}
		
		SetIsSliding( false );
	}
	
	latent function Main() : EBTNodeStatus
	{
		while( IsSliding() )
		{
			if( PerformOverlapTest() )
			{
				DealDamage();
				break;
			}
			
			SleepOneFrame();
		}
		return BTNS_Active;
	}

	private function PerformOverlapTest() : bool
	{
		var pos : Vector;
		var npc : CNewNPC = GetNPC();
		
		hitEntities.Clear();
		
		pos = npc.GetWorldPosition() + npc.GetHeadingVector() * 1.0;
		pos.Z += 1.0;
		
		if( theGame.GetWorld().SphereOverlapTest( hitEntities, pos, 0.4, collisionGroupsNames ) )
		{
			if( hitEntities.Contains( thePlayer ) )
			{
				return true;
			}
		}
		
		return false;
	}
	
	private function DealDamage()
	{
		var damageAction : W3DamageAction;
		
		damageAction = new W3DamageAction in this;
		damageAction.Initialize( GetNPC(), thePlayer, this, "ShadowDash", EHRT_Heavy, CPS_Undefined, true, false, false, false );
		damageAction.AddDamage( theGame.params.DAMAGE_NAME_PHYSICAL, damageVal );
		theGame.damageMgr.ProcessAction( damageAction );
		delete damageAction;
	}
	
	private function CalculateSlidePos() : Vector
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var targetPos, slidePos	: Vector;
		
		targetPos = target.GetWorldPosition();
		
		if( slideBehindTarget )
		{
			slidePos = targetPos - target.GetHeadingVector() * distanceOffset;
		}	
		else
		{
			slidePos = targetPos + target.GetHeadingVector() * distanceOffset;
		}
		
		
		return slidePos;
	}
	
	private function CalculateSlideDuration( slidePos : Vector ) : float
	{
		var slideDistance : float;
		
		slideDistance = VecDistance2D( GetNPC().GetWorldPosition(), slidePos );
		
		return slideDistance / slideSpeed;
	}
	
	private function IsSliding() : bool 
	{ 
		return isSliding; 
	}
	
	private function SetIsSliding( val : bool ) 
	{ 
		isSliding = val; 
	}
};

class CBTTaskShadowDashDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskShadowDash';
	
	editable var slideSpeed 				: float;
	editable var slideBehindTarget 			: bool;
	editable var distanceOffset 			: float;
	editable var disableCollision 			: bool;
	editable var dealDamageOnContact 		: bool;
	editable var damageVal 					: float;
	editable var maxDist 					: float;
	editable var sideStepDist 				: float;
	editable var sideStepHeadingOffset 		: float;
	editable var minDuration 				: float;
	editable var maxDuration 				: float;
	editable var slideBlendInTime 			: float;
	editable var disableGameplayVisibility 	: bool;
	
	default slideSpeed 						= 25.0;
	default distanceOffset 					= 4.0;
	default damageVal 						= 200.0;
	default maxDuration 					= -1;
	default sideStepDist 					= 3.0;
	default sideStepHeadingOffset 			= 30.0;
	default disableGameplayVisibility 		= true;
	default slideBlendInTime 				= 0.25;
};