/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3WeakeningAura extends W3Effect_Aura
{
	private var usedVictim : CActor;
	private var timeSinceLastApply : float;
	private var hasSelectedVictim : bool;
	private var applicationDelay : float;
	private var targetCount : int;
	
	private const var BUFF_DURATION : float;
	
	default effectType = EET_WeakeningAura;
	default BUFF_DURATION = 3.f;
	
	event OnPreApplySpawns(out ents : array<CGameplayEntity>)
	{
		var creator : CGameplayEntity;
		var i : int;
		var expectedDt : float;
		var hasHuman : bool;
		
		
		if(hasSelectedVictim)
		{
			if(applicationDelay > 0.f)
			{
				
				ents.Clear();
				return true;
			}
			else
			{
				
				hasSelectedVictim = false;
				ents.Clear();
				ents.PushBack(usedVictim);
				return true;
			}
		}
		
		
		creator = GetCreator();
		for(i=ents.Size()-1; i>=0; i-=1)
		{
			if ( !IsRequiredAttitudeBetween(ents[i], creator, spawns[0].spawnFlagsHostile, spawns[0].spawnFlagsNeutral, spawns[0].spawnFlagsFriendly) )
			{
				ents.EraseFast(i);
				continue;
			}
				
			if(ents[i].HasAbility('MonsterMHBoss') || ents[i] == thePlayer || ents[i] == thePlayer.GetHorseWithInventory())
			{
				ents.EraseFast(i);
				continue;
			}
				
			if( ((CActor)ents[i]).IsHuman() )
				hasHuman = true;
		}
		
		
		if(ents.Size() == 0)
			return true;
			
		if(ents.Size() > 1)
			ents.Remove(usedVictim);
		
		
		expectedDt = theGame.params.DEVIL_HORSE_AURA_MIN_DELAY + (theGame.params.DEVIL_HORSE_AURA_MAX_DELAY - theGame.params.DEVIL_HORSE_AURA_MIN_DELAY) / targetCount; 
		if ( !hasHuman )
			expectedDt *= 1.5;
			
		if (timeSinceLastApply < (BUFF_DURATION + expectedDt))
			ents.Clear();
			
		
		if(ents.Size() > 0)
		{
			
			GetWitcherPlayer().GetHorseWithInventory().PlayEffect('demonic_cast');
			
			
			applicationDelay = 0.5f;			
			
			
			hasSelectedVictim = true;
			usedVictim = (CActor)ents[ RandRange(ents.Size()) ];
			
			
			targetCount = ents.Size();
			
			
			ents.Clear();			
		}
	}
	
	protected function ApplySpawnsOn(victimGE : CGameplayEntity)
	{
		var params : SCustomEffectParams;
		var effect : int;
		
		
		usedVictim = (CActor)victimGE;
		
		
		if (targetCount == 1)
			effect = RandRange(2, 0);
		else
			effect = RandRange(3, 0);
			
		if ( spawns[effect].spawnType == EET_Swarm && !usedVictim.IsHuman() )
			effect = 0;
		
		
		timeSinceLastApply = 0.f;
		
		
		params.effectType = spawns[effect].spawnType;
		params.creator = GetCreator();
		params.sourceName = spawns[effect].spawnSourceName;
		params.customAbilityName = spawns[effect].spawnAbilityName;
		params.duration = BUFF_DURATION;
		params.customFXName = 'demonic_possession';
		
		usedVictim.AddEffectCustom(params);
	}	
	
	event OnUpdate(dt : float)
	{
		timeSinceLastApply += dt;
		
		if(hasSelectedVictim)
			applicationDelay -= dt;		
		
		super.OnUpdate(dt);
	}
}