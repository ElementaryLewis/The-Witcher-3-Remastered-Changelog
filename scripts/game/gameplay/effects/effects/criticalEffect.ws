/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3CriticalEffect extends CBaseGameplayEffect
{
	protected var criticalStateType 		: ECriticalStateType;				
	protected saved var allowedHits 		: array<bool>;						
	protected var timeEndedHandled 			: bool;
	private var isDestroyedOnInterrupt 		: bool;								
	private var canPlayAnimation 			: bool;								
	protected var blockedActions 			: array<EInputActionBlock>;			
	protected var postponeHandling 			: ECriticalHandling;				
	protected var airHandling 				: ECriticalHandling;				
	protected var attachedHandling 			: ECriticalHandling;				
	protected var onHorseHandling 			: ECriticalHandling;				
	public var explorationStateHandling 	: ECriticalHandling;				
	private var usesFullBodyAnim			: bool;
	
		default criticalStateType 			= ECST_None;						
		default isNegative 					= true;
		default timeEndedHandled 			= false;
		default isDestroyedOnInterrupt 		= false;
		default canPlayAnimation 			= true;
		default postponeHandling 			= ECH_Postpone;
		default airHandling 				= ECH_Postpone;
		default attachedHandling			= ECH_HandleNow;
		default onHorseHandling				= ECH_HandleNow;
		default	explorationStateHandling	= ECH_Postpone;
		default usesFullBodyAnim			= false;
		
	public function CacheSettings()
	{
		var i :int;
		
		super.CacheSettings();
		
		allowedHits.Grow( EnumGetMax('EHitReactionType')+1 );
		for(i=0; i<allowedHits.Size(); i+=1)
			allowedHits[i] = true;
			
		
		blockedActions.PushBack(EIAB_ExplorationFocus);
		blockedActions.PushBack(EIAB_Dive);
		blockedActions.PushBack(EIAB_Interactions);
		blockedActions.PushBack(EIAB_FastTravel);
	}
	
	
	
	public function OnTimeUpdated(deltaTime : float)
	{
		if ( isActive )
		{
			timeActive += deltaTime;
		}
		
		if(pauseCounters.Size() == 0)
		{							
			if( duration != -1 )
				timeLeft -= deltaTime;				
			OnUpdate(deltaTime);	
		}
		
		
		
		
		if(timeLeft <= 0 && !timeEndedHandled)
		{
			target.SignalGameplayEvent('DisableFinisher');
			timeEndedHandled = true;
		
			
			if(isActive && this == target.GetCurrentlyAnimatedCS())
			{		
				
				target.RequestCriticalAnimStop();
			}
			else
			{
				LogCritical("Deactivating not animated CS <<" + criticalStateType + ">>");
				isActive = false;			
			}
		}
	}
	
	public function GetCriticalStateType() : ECriticalStateType			{return criticalStateType;}	
	public function IsHitAllowed(hit : EHitReactionType) : bool			{return allowedHits[hit];}
	public function IsDestroyedOnInterrupt() : bool						{return isDestroyedOnInterrupt;}
	public function CanPlayAnimation() : bool							{return canPlayAnimation;}
	public function DisallowPlayAnimation()								{canPlayAnimation = false;}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var i : int;
		var animHandling : ECriticalHandling;
		var veh : CGameplayEntity;
		var horseComp : W3HorseComponent;
		var boatComp : CBoatComponent;
		
		super.OnEffectAdded(customParams);
			
		
		if(isOnPlayer)
		{
			for(i=0; i<blockedActions.Size(); i+=1)
			{
				thePlayer.BlockAction( blockedActions[i], EffectTypeToName( effectType ) );
			}
		}
		
		
		if(!isOnPlayer)
			target.PauseStaminaRegen('in_critical_state');

		
		if(target.IsCriticalTypeHigherThanAllCurrent(criticalStateType))
		{
			if(target.IsInAir())
			{
				animHandling = airHandling;
			}			
			else
			{
				if(isOnPlayer)
				{
					thePlayer.OnRangedForceHolster( true, false, false );
					
					if( !thePlayer.CanReactToCriticalState() )
					{
						animHandling = explorationStateHandling;
					}
					else
					{
						veh = thePlayer.GetUsedVehicle();
						if((W3Boat)veh)
						{
							
							
							animHandling = attachedHandling;
						}
						else if(veh)
						{
							
							horseComp = ((CNewNPC)veh).GetHorseComponent();
							horseComp.OnCriticalEffectAdded( criticalStateType );
							animHandling = onHorseHandling;
						}		
						else
						{
							
							animHandling = ECH_HandleNow;
						}
					}
				}
				else
				{
					
					animHandling = ECH_HandleNow;
				}
			}
		}
		else
		{
			
			animHandling = postponeHandling;
		}
		
		
		if(animHandling == ECH_HandleNow)
		{
			target.StartCSAnim(this);
		}
		else if(animHandling == ECH_Abort)
		{
			LogCritical("Cancelling CS <<" + criticalStateType + ">> as it cannot play anim right now and its handling wishes to abort in such case");
			isActive = false;
		}
		
		
		if(isOnPlayer)
			theGame.HapticStart( "classic_vibro_large_oneshot" );
	}
	
	event OnEffectAddedPost()
	{
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
		
		super.OnEffectAddedPost();
	}
	
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
	}
	
	event OnEffectRemoved()
	{
		var i : int;
	
		super.OnEffectRemoved();
	
		
		if(isOnPlayer)
		{
			for(i=0; i<blockedActions.Size(); i+=1)
			{
				thePlayer.UnblockAction( blockedActions[i], EffectTypeToName( effectType ) );
			}
		}
		
		
		target.ResumeStaminaRegen('in_critical_state');
		
		if(isOnPlayer)
		{
			LogCriticalPlayer("Critical.OnEffectRemoved() | " + this);
			LogCriticalPlayer("");
		}
		
		if(this == target.GetCurrentlyAnimatedCS())
			target.RequestCriticalAnimStop();
	}
	
	public final function UsesFullBodyAnim() : bool
	{
		return usesFullBodyAnim;
	}
}