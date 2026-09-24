/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3FrozenEffectCustomParams extends W3BuffCustomParams
{
	var freezeFadeInTime : float;		
}


class W3Effect_Frozen extends W3ImmobilizeEffect
{
	private saved var killOnHit : bool;
	private var bonusDamagePercents : float;
	private saved var targetWasFlying : bool;
	private var pushPriority : EInteractionPriority;
	private var wasKnockedDown : bool;

		default effectType = EET_Frozen;
		default resistStat = CDS_FrostRes;
		default criticalStateType = ECST_Frozen;
		default isDestroyedOnInterrupt = true;
		default killOnHit = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3FrozenEffectCustomParams;
		var	animatedComponent 	: CAnimatedComponent;
		var mpac				: CMovingPhysicalAgentComponent;
		var npc : CNewNPC;
		var isJumping : bool;
		
		super.OnEffectAdded(customParams);
		
		wasKnockedDown = false;	
		animatedComponent = ( CAnimatedComponent )target.GetComponentByClassName( 'CAnimatedComponent' );
		if( animatedComponent )
		{
			params = (W3FrozenEffectCustomParams)customParams;		
			isJumping = false;
						
			
			npc = (CNewNPC)target;
			if(npc)
			{
				mpac = (CMovingPhysicalAgentComponent)target.GetComponentByClassName('CMovingPhysicalAgentComponent');
				
				targetWasFlying = npc.IsFlying();
				if(targetWasFlying)
				{					
					if(mpac)
						mpac.SetAnimatedMovement( false );
				}
				
				
				if(npc.IsVisuallyOffGround() && !targetWasFlying)
				{
					isJumping = true;
				}
			}
			else
			{
				targetWasFlying = false;
			}
			
			if(!isJumping)
			{
				
				
				
				animatedComponent.FreezePose();
					
				
				pushPriority = target.GetInteractionPriority();
				target.SetInteractionPriority(IP_Max_Unpushable);
			}
			else
			{
				
				isActive = false;
				return true;
			}
		}
		
		if( target.HasBuff( EET_HeavyKnockdown ) || target.HasBuff( EET_Knockdown ) )
		{
			target.SetStatic();
			wasKnockedDown = true;
		}
		effectManager.PauseAllRegenEffects('FrozenEffect');

		if( target.HasTag( 'scolopendromorph' ) )
		{
			target.StopEffect( 'dirt_base' );
		}
	}
	
	event OnEffectAddedPost()
	{
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAddedPost();
		
		if( sourceName == "Mutation 6" )
		{
			
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup( target.GetWorldPosition(), 0.3f, duration, 2.f, 5.f, 0 );
		}
		
		
		target.FreezeCloth( true );
		
		
		dm = theGame.GetDefinitionsManager();		
		dm.GetAbilityAttributeValue(abilityName, 'hpPercDamageBonusPerHit', min, max);
		bonusDamagePercents = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		dm.GetAbilityAttributeValue(abilityName, 'killOnHit', min, max);
		killOnHit = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
	
	event OnEffectRemoved()
	{
		var	animatedComponent 	: CAnimatedComponent;
		var mpac				: CMovingPhysicalAgentComponent;
		
		super.OnEffectRemoved();
		
		animatedComponent = ( CAnimatedComponent )target.GetComponentByClassName( 'CAnimatedComponent' );
		if( animatedComponent )
		{
			animatedComponent.UnfreezePoseFadeOut( 1.0f );
			if(targetWasFlying)
			{
				mpac = (CMovingPhysicalAgentComponent)target.GetComponentByClassName('CMovingPhysicalAgentComponent');
				if(mpac)
				{
					mpac.SetAnimatedMovement(true);
				}
			}
		}
		target.SignalGameplayEventParamInt('ForceStopCriticalEffect',(int)criticalStateType);
		effectManager.ResumeAllRegenEffects('FrozenEffect');
		target.RequestCriticalAnimStop();
		
		
		target.SetInteractionPriority(pushPriority);
		if( wasKnockedDown )
		{
			target.SetKinematic( false );
		}
		
		
		target.FreezeCloth( false );
	}
	
	public function KillOnHit() : bool
	{
		return killOnHit;
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
		
		
		
		
		if(timeLeft <= 0)
		{
			LogCritical("Deactivating not animated CS <<" + criticalStateType + ">>");
			isActive = false;			
		}
	}
	
	
	public function GetAdditionalDamagePercents() : float
	{
		return bonusDamagePercents;
	}
}