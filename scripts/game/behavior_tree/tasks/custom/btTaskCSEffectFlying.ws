/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeTaskCSEffectFlying extends CBehTreeTaskCSEffect
{
	var wasFlying 					: bool;
	var waitingForEndOfDisableHit	: bool;
	
	default wasFlying = false;	
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		var distToGround : float;
		
		owner.SetBehaviorVariable('ForceExitCSEffect', 0);
		
		if ( owner.GetCurrentStance() == NS_Fly )
		{
			owner.SetBehaviorVariable( 'GroundContact', 0.0 );
			distToGround = GetActor().GetDistanceFromGround( 20 );
			owner.SetBehaviorVariable( 'DistanceFromGround', distToGround );
			
			
			
			owner.SetBehaviorVariable( '5AnimCriticalState', 1.0 );
			owner.EnablePhysicalMovement( true ); 
			((CMovingPhysicalAgentComponent)owner.GetComponentByClassName('CMovingPhysicalAgentComponent')).SetAnimatedMovement( true );
			wasFlying = true;
				
			forceFinisherActivation = true;
		}
		else 
		{
			owner.SetBehaviorVariable( '5AnimCriticalState', 0.0 );
		}
	
		
		
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner 					: CNewNPC = GetNPC();
		var groundPos, normal		: Vector;
		
		while ( wasFlying )
		{
			if (  owner.IsOnGround() || theGame.GetWorld().StaticTrace ( owner.GetWorldPosition(), owner.GetWorldPosition() - Vector( 0,0,0.15f), groundPos, normal ) )
			{				
				OnGroundContact();
				
				if( ShouldEnableFinisher() )
				{
					EnableFinisher();
				}
				
				wasFlying = false;
			}
			
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CNewNPC = GetNPC();
		
		super.OnDeactivate();
		
		if ( wasFlying )
		{
			if ( owner.IsOnGround() )
			{
				OnGroundContact();
			}
			else 
			{
				((CMovingPhysicalAgentComponent)owner.GetComponentByClassName('CMovingPhysicalAgentComponent')).SetAnimatedMovement( true );
				owner.EnablePhysicalMovement( true ); 
				owner.SetBehaviorVariable('ForceExitCSEffect', 1); 
			}
		}
		
		if ( waitingForEndOfDisableHit )
			owner.SetCanPlayHitAnim( true );
		
		waitingForEndOfDisableHit = false;
		wasFlying = false;
		forceFinisherActivation = false;
	}
	
	function OnGroundContact()
	{
		var owner 	: CNewNPC = GetNPC();
		var mac 	: CMovingPhysicalAgentComponent;
		owner.SetBehaviorVariable( 'GroundContact', 1.0 );		
		
		mac = ((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent());
		owner.ChangeStance( NS_Wounded );
		mac.SetAnimatedMovement( false );
		owner.EnablePhysicalMovement( false );
		mac.SnapToNavigableSpace( true );

	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var owner : CNewNPC;
		var res : bool;
		var mac 	: CMovingPhysicalAgentComponent;
		
		res = super.OnAnimEvent(animEventName,animEventType,animInfo);
		
		if ( animEventName == 'DisableHitAnim'  )
		{
			owner = GetNPC();
			if( animEventType == AET_DurationEnd )
			{
				owner.SetCanPlayHitAnim( true );
				waitingForEndOfDisableHit = false;
			}
			else
			{			
				owner.SetCanPlayHitAnim( false );
				waitingForEndOfDisableHit = true;
			}
		}
		return res;
	}
}

class CBehTreeTaskCSEffectFlyingDef extends CBehTreeTaskCSEffectDef
{
	default instanceClass = 'CBehTreeTaskCSEffectFlying';
}