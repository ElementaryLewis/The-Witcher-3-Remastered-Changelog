/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_Blizzard extends CBaseGameplayEffect
{
	private saved var slowdownCauserIds : array<int>;		
	private var slowdownFactor : float;
	private var currentSlowMoDuration : float;
	private const var SLOW_MO_DURATION : float;
	
	
	private var isScreenFxActive : bool;

	default effectType = EET_Blizzard;
	default attributeName = 'slow_motion';
	default SLOW_MO_DURATION = 3.f;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded(customParams);	
		
		slowdownFactor = CalculateAttributeValue(effectValue);		
	}
	
	public final function IsSlowMoActive() : bool
	{
		return slowdownCauserIds.Size();
	}
	
	public function KilledEnemy()
	{
		
		
		
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		RemoveSlowMo();
	}
	
	public function OnTimeUpdated(dt : float)
	{
		
		var moveTargets : array< CActor >;
		var i : int;
			
		currentSlowMoDuration += dt / slowdownFactor;
		if( currentSlowMoDuration > 0.5f )
		{
			currentSlowMoDuration = 0.f;
			moveTargets = thePlayer.GetMoveTargets();
			if( thePlayer.IsInCombat() && slowdownCauserIds.Size() == 0 && !thePlayer.IsUsingHorse() && ( moveTargets.Size() > 0 || thePlayer.IsPlayerUnderAttack() ))
			{
				theGame.SetTimeScale( slowdownFactor, theGame.GetTimescaleSource(ETS_PotionBlizzard), theGame.GetTimescalePriority(ETS_PotionBlizzard) );
				slowdownCauserIds.PushBack(target.SetAnimationSpeedMultiplier( 1 / slowdownFactor ));
				
				
				if(!isScreenFxActive)
					EnableScreenFx(true);
				
			}
			
			if( slowdownCauserIds.Size() == 0 )
			{
				RemoveSlowMo();
			}
		}
		
		if(slowdownCauserIds.Size() > 0)
		{
			super.OnTimeUpdated(dt / slowdownFactor);
		}
		else
		{
			super.OnTimeUpdated(dt);
		}
		
		
		
		
	}
	
	event OnEffectRemoved()
	{
		RemoveSlowMo();
		
		super.OnEffectRemoved();
	}
	
	private final function RemoveSlowMo()
	{
		var i : int;
		
		for(i=0; i<slowdownCauserIds.Size(); i+=1)
		{
			target.ResetAnimationSpeedMultiplier(slowdownCauserIds[i]);
		}
		
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_PotionBlizzard) );
		
		slowdownCauserIds.Clear();
		
		
		EnableScreenFx(false);
	}
	
	
	private final function EnableScreenFx(enable : bool)
	{
		var buffs : array< CBaseGameplayEffect >;
		var i : int;
		var catBuff : W3Potion_Cat;
		var blizzardBuff : W3Potion_Blizzard;
		
		
		buffs = target.GetBuffs();
		for( i=0; i<buffs.Size(); i+=1 )
		{
			catBuff = (W3Potion_Cat) buffs[i];
			blizzardBuff = (W3Potion_Blizzard) buffs[i];
			if( catBuff && catBuff != this && catBuff.GetIsScreenFxActive() )
			{
				return;
			}
			if( blizzardBuff && blizzardBuff != this && blizzardBuff.isScreenFxActive )
			{
				return;
			}
		}	
		
		if(enable)
		{
			EnableCatViewFx( 1.0f );	
			SetTintColorsCatViewFx(Vector(0.15f,0.15f,0.2f,0.05f),Vector(0.15f,0.15f,0.2f,0.05f),0.5f);
			SetBrightnessCatViewFx(5.0f);
			SetViewRangeCatViewFx(500.0f);
			SetPositionCatViewFx( Vector(0,0,0,0) , true );	
			
			SetFogDensityCatViewFx( 1.0 );
			isScreenFxActive = true;
		}
		else
		{
			isScreenFxActive = false;
			DisableCatViewFx( 1.0f );
		}
	}	
	
}