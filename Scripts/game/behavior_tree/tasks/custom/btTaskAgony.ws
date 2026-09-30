/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeTaskAgony extends IBehTreeTask
{
	var agonyTime : int;
	
	
	private var syncInstance	: CAnimationManualSlotSyncInstance;
	
	var disableAgony : bool;
	var chance : int;
	var forceAgony : bool;
	
	default disableAgony = false;

	function IsAvailable () : bool
	{
		if ( disableAgony )
		{
			return false;
		}
		
		if ( GetNPC().GetBehaviorGraphInstanceName() == 'Exploration' )
			return false;
		
		if ( !GetWitcherPlayer() )
			return false;
		
		if ( forceAgony )
			return true;
		
		if ( GetNPC().IsAgonyDisabled() )
		{
			return false;
		}
		
		if ( GetAttitudeBetween( GetActor(), thePlayer ) != AIA_Hostile )
			return false;
		
		return Roll();
	}
	
	function Roll() : bool
	{
		var moveTargets : array<CActor>;
		
		moveTargets = thePlayer.GetMoveTargets();
		if ( moveTargets.Contains(GetActor()) && thePlayer.GetNumberOfMoveTargets() <= 1)
		{
			return true;
		}
		
		return false;
	}
	
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		
		owner.SetBehaviorVariable('DeathType',(int)EDT_Agony);
		owner.SetBehaviorVariable('AgonyType',(int)AT_Knockdown);
		
		owner.EnterAgony();
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner 				: CNewNPC = GetNPC();
		var finisherComponent 	: CComponent;
		var timeStamp 			: float;
		
		timeStamp = GetLocalTime();
		
		if( !owner.RaiseForceEvent( 'Agony' ) )
		{
			return BTNS_Failed;
		}
		
		owner.WaitForBehaviorNodeDeactivation('AgonyStartEnd',1.0);
		owner.EnableCharacterCollisions( false );
		
		finisherComponent = owner.GetComponent( "Finish" );
		finisherComponent.SetEnabled( true );
		
		thePlayer.AddToFinishableEnemyList( owner, true );
		
		
		while( true )
		{
			if( syncInstance )
			{
				if( syncInstance.HasEnded() )
				{
					return BTNS_Completed;
				}
			}
			else if ( timeStamp + agonyTime <= GetLocalTime() )
			{
				Complete(true);
			}
			
			if ( finisherComponent.IsEnabled() && !thePlayer.IsDeadlySwordHeld() )
			{
				finisherComponent.SetEnabled( false );
			}
			else if ( !finisherComponent.IsEnabled() && thePlayer.IsDeadlySwordHeld() )
			{
				finisherComponent.SetEnabled( true );
			}
			
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CNewNPC = GetNPC();
		
		owner.EnableFinishComponent( false );
		thePlayer.AddToFinishableEnemyList( owner, false );
		owner.SoundEvent( "grunt_vo_death_stop", 'head' );
		owner.EndAgony();
	}
	
	function AgonySyncAnim()
	{
		theGame.GetSyncAnimManager().SetupSimpleSyncAnim('AgonyCrawl', thePlayer, GetActor() );		
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'RotateEventStart')
		{
			GetNPC().SetRotationAdjustmentRotateTo( GetCombatTarget() );
			return true;
		}
		else if ( animEventName == 'RotateAwayEventStart')
		{
			GetNPC().SetRotationAdjustmentRotateTo( GetCombatTarget(), 180.0 );
			return true;
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var owner : CNewNPC = GetNPC();
		
		if ( eventName == 'Finisher' )
		{
			if ( !CombatCheck() )
			{
				return false;
			}
			if (( owner.GetBehaviorVariable('AgonyType') == (int)AT_Knockdown || owner.GetBehaviorVariable('AgonyType') == (int)AT_ThroatCut ) && !owner.IsInFinisherAnim() )
			{
				owner.EnableFinishComponent( false );
				thePlayer.AddToFinishableEnemyList( owner, false );
				AgonySyncAnim();
				
				owner.FinisherAnimStart();
				
				
				return true;
			}
		}
		else if ( eventName == 'SetupSyncInstance' )
		{
			syncInstance = theGame.GetSyncAnimManager().GetSyncInstance( GetEventParamInt( -1 ) );
		}
		else if ( eventName == 'AbandonAgony' )
		{
			owner.DisableDeathAndAgony();
			owner.RaiseForceEvent( 'Death' );
			Complete(true);
		}
		else if (  eventName == 'ForceEndAgony' )
		{
			Complete(true);
		}
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'ForceAgony' )
		{
			forceAgony = true;
			return true;
		}
		else if ( eventName == 'ForceFinisher' )
		{
			GetNPC().DisableAgony();
			return true;
		}
		return false;
	}
	
	function CombatCheck() : bool
	{
		if ( thePlayer.IsWeaponHeld( 'steelsword' ) || thePlayer.IsWeaponHeld( 'silversword' ) )
		{
			return true;
		}		
		return false;
	}
};

class CBehTreeAgonyDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskAgony';

	editable var disableAgony : CBehTreeValBool;
	editable var agonyTime : int;
	editable var chance : int;
	
	default chance = 10;
	
	hint agonyTime = "Number of animation loops";
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'ForceAgony' );
		listenToGameplayEvents.PushBack( 'ForceFinisher' );
	}
}
