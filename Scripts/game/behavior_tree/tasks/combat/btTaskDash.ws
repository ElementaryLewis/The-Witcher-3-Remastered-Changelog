/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDash extends IBehTreeTask
{
	public var slideBehindTarget 				: bool;
	public var destinationOffset 				: float;
	public var disableCollision 				: bool;
	public var dealDamageOnContact 				: bool;
	public var damageVal 						: float;
	public var sideStepDist 					: float;
	public var sideStepHeadingOffset 			: float;
	public var disableGameplayVisibility 		: bool;
	public var sendRotationEventAboveDashDist 	: float;
	
	private var isSliding 						: bool;
	private var hitEntities 					: array<CEntity>;
	private var collisionGroupsNames 			: array<name>;
	
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
		var npc 						: CNewNPC = GetNPC();
		var ticket 						: SMovementAdjustmentRequestTicket;
		var movementAdjustor			: CMovementAdjustor;
		var slidePos 					: Vector;
		var npcPos 						: Vector;
		var heading						: float;
		
		if( animEventName == 'Dash' && animEventType == AET_DurationStart )
		{
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'Dash' );
			movementAdjustor.CancelByName( 'SideDashRight' );
			movementAdjustor.CancelByName( 'SideDashLeft' );
			
			ticket = movementAdjustor.CreateNewRequest( 'Dash' );
			slidePos = CalculateSlidePos();
			
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.SlideTo( ticket, slidePos );
			
			npcPos = npc.GetWorldPosition();
			heading = VecHeading( slidePos - npcPos );
			movementAdjustor.RotateTo( ticket, heading );
			
			if ( VecDistance( slidePos, npc.GetWorldPosition() ) > sendRotationEventAboveDashDist )
			{
				npc.SignalGameplayEventParamFloat( 'FxRotation', VecHeading( slidePos - npcPos ) );
				npc.SignalGameplayEvent( 'dash' );
			}
			
			
			SlideStart();
			
			return true;
		}
		else if( animEventName == 'SideDashRight' && animEventType == AET_DurationStart )
		{
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SideDashRight' );
			
			ticket = movementAdjustor.CreateNewRequest( 'SideDashRight' );
			slidePos = GetNPC().GetWorldPosition() + VecFromHeading( GetNPC().GetHeading() - sideStepHeadingOffset ) * sideStepDist;
			
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			movementAdjustor.ScaleAnimation( ticket );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.SlideTo( ticket, slidePos );
			movementAdjustor.RotateTowards( ticket, GetCombatTarget() );
			
			npcPos = npc.GetWorldPosition();
			if ( VecDistance( slidePos, npc.GetWorldPosition() ) > sendRotationEventAboveDashDist )
			{
				npc.SignalGameplayEventParamFloat( 'FxRotation', VecHeading( slidePos - npcPos ) );
				npc.SignalGameplayEvent( 'dashRight' );
			}
			SlideStart();
			
			return true;
		}
		else if( animEventName == 'SideDashLeft' && animEventType == AET_DurationStart )
		{
			movementAdjustor = GetNPC().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SideDashLeft' );
			
			ticket = movementAdjustor.CreateNewRequest( 'SideDashLeft' );
			slidePos = GetNPC().GetWorldPosition() + VecFromHeading( GetNPC().GetHeading() + sideStepHeadingOffset ) * sideStepDist;
			
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			movementAdjustor.ScaleAnimation( ticket );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.SlideTo( ticket, slidePos );
			movementAdjustor.RotateTowards( ticket, GetCombatTarget() );
			
			npcPos = npc.GetWorldPosition();
			if ( VecDistance( slidePos, npc.GetWorldPosition() ) > sendRotationEventAboveDashDist )
			{
				npc.SignalGameplayEventParamFloat( 'FxRotation', VecHeading( slidePos - npcPos ) );
				npc.SignalGameplayEvent( 'dashLeft' );
			}
			SlideStart();
			
			return true;
		}
		else if( ( animEventName == 'Dash' || animEventName == 'SideDashRight' || animEventName == 'SideDashLeft' ) && animEventType == AET_DurationEnd )
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
			slidePos = targetPos - target.GetHeadingVector() * destinationOffset;
		}	
		else
		{
			slidePos = targetPos + VecFromHeading( VecHeading( GetNPC().GetWorldPosition() - targetPos ) ) * destinationOffset;
		}
		
		return slidePos;
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

class CBTTaskDashDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDash';
	
	editable var slideBehindTarget 				: bool;
	editable var destinationOffset 				: float;
	editable var disableCollision 				: bool;
	editable var dealDamageOnContact 			: bool;
	editable var damageVal 						: float;
	editable var sideStepDist 					: float;
	editable var sideStepHeadingOffset 			: float;
	editable var disableGameplayVisibility 		: bool;
	editable var sendRotationEventAboveDashDist : float;
	
	default destinationOffset 					= 2.0;
	default damageVal 							= 200.0;
	default sideStepDist 						= 3.0;
	default sideStepHeadingOffset 				= 30.0;
	default disableGameplayVisibility 			= true;
	default sendRotationEventAboveDashDist 		= 3.5;
};
