/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDettlaffDash extends CBTTaskAttack
{
	var OpenForAard 				: bool;
	var action 						: W3DamageAction;
	var shouldCheckVisibility 		: bool;
	var shouldSignalGameplayEvent 	: bool;
	var actor						: CActor;
	
	function IsAvailable() : bool
	{
		if ( shouldCheckVisibility && thePlayer.WasVisibleInScaledFrame( GetNPC(), 1.f, 1.f ))
		{
			return true;
		}
		else if( !shouldCheckVisibility )
		{
			return true;
		}
		else return false;
	}
	function OnActivate() : EBTNodeStatus
	{
		actor = GetActor();
		return super.OnActivate();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var target 				: CActor = GetCombatTarget();
			
		super.OnAnimEvent(animEventName, animEventType, animInfo);
		
		
		if( animEventName == 'OpenForAard' && animEventType == AET_DurationStart )
		{
			OpenForAard = true;
			actor.SetGuarded(false);
		}
		else if( animEventName == 'OpenForAard' && animEventType == AET_DurationEnd )
		{
			OpenForAard = false;
			actor.SetGuarded(true);
		}
		return super.OnAnimEvent(animEventName, animEventType, animInfo);
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var owner				: CActor;
		owner = GetNPC();
		if( OpenForAard && ( eventName == 'AardHitReceived' || eventName == 'BeingHit' || eventName == 'IgniHitReceived' || eventName == 'HitByBomb' || eventName == 'AttackCountered' ))
		{
			action = new W3DamageAction in this;
			action.Initialize(thePlayer,owner,NULL,"FallingFromTheSkies",EHRT_None,CPS_SpellPower,true,false,false,false);
			action.AddDamage(theGame.params.DAMAGE_NAME_BLUDGEONING, ( owner.GetMaxHealth()*0.05 ));
			theGame.damageMgr.ProcessAction( action );
			delete action;
			owner.StopEffect('attack_tell_light');
			if( shouldSignalGameplayEvent )
			{
				owner.SignalGameplayEvent('DashHit');
			}
			else
			{
				owner.RaiseEvent( 'Recovery' );
				owner.StopEffectIfActive('shadowdash');
			}
			return true;
		}
		else return super.OnGameplayEvent( eventName );
	}
}
class CBTTaskDettlaffDashDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskDettlaffDash';
	
	var OpenForAard 						: bool;
	editable var shouldCheckVisibility 		: bool;
	editable var shouldSignalGameplayEvent 	: bool;
	
	default shouldCheckVisibility = true;
	default shouldSignalGameplayEvent = false;
	
}