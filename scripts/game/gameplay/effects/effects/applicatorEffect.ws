/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3ApplicatorEffect extends CBaseGameplayEffect
{
	protected saved var spawns : array<SApplicatorSpawnEffect>;		
	
		default isPositive = true;
	
	
	protected function ApplySpawnsOn(victimGE : CGameplayEntity)
	{
		var i : int;
		var victim : CActor;
		var params : SCustomEffectParams;
	
		victim = (CActor)victimGE;
		if(!victim)
			return;
	
		for(i=0; i<spawns.Size(); i+=1)
		{
			
			if(victim == GetCreator() && theGame.effectMgr.IsBuffNegative(spawns[i].spawnType))
				continue;
					
			if( IsRequiredAttitudeBetween(victim, GetCreator(), spawns[i].spawnFlagsHostile, spawns[i].spawnFlagsNeutral, spawns[i].spawnFlagsFriendly) )
			{
				params.effectType = spawns[i].spawnType;
				params.creator = GetCreator();
				params.sourceName = spawns[i].spawnSourceName;
				params.customAbilityName = spawns[i].spawnAbilityName;
				
				victim.AddEffectCustom(params);
			}
		}
	}	

	
	protected function HasNeutralSpawn() : bool
	{
		var i : int;
		
		for(i=0; i<spawns.Size(); i+=1)
			if(spawns[i].spawnFlagsNeutral)
				return true;
		
		return false;
	}
	
	public function CacheSettings()
	{
		var appliedEffects : array<SCustomNode>;
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName, effectName, tmpApplicatorName : name;
		var i,j : int;
		var tmpFloat : float;
		var tmpBool : bool;
		var tmpSpawn : SApplicatorSpawnEffect;
		var type : EEffectType;
	
		super.CacheSettings();
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpApplicatorName);
			EffectNameToType(tmpApplicatorName, type, tmpName);
			if(effectType == type)
			{			
				
				appliedEffects = main.subNodes[i].subNodes;
				
				for(j=0; j<appliedEffects.Size(); j+=1)
				{
					if(dm.GetCustomNodeAttributeValueName(appliedEffects[j], 'name_name', effectName))
					{						
						EffectNameToType(effectName, type, effectName);
						tmpSpawn.spawnType = type;
						if(tmpSpawn.spawnType == EET_Undefined)
						{
							LogAssert(false, "W3ApplicatorEffect.CacheSettings: spawn effect <<" + tmpName +">> of applicator <<" + tmpApplicatorName + ">> is not defined! Skipping!");
							continue;
						}
					}
					
					if(dm.GetCustomNodeAttributeValueName(appliedEffects[j], 'customAbilityName_name', tmpName))
						tmpSpawn.spawnAbilityName = tmpName;
									
					if(dm.GetCustomNodeAttributeValueBool(appliedEffects[j], 'affectsHostile', tmpBool))
						tmpSpawn.spawnFlagsHostile = tmpBool;
					if(dm.GetCustomNodeAttributeValueBool(appliedEffects[j], 'affectsNeutral', tmpBool))
						tmpSpawn.spawnFlagsNeutral = tmpBool;
					if(dm.GetCustomNodeAttributeValueBool(appliedEffects[j], 'affectsFriendly', tmpBool))					
						tmpSpawn.spawnFlagsFriendly = tmpBool;
					
					if(!tmpSpawn.spawnFlagsHostile && !tmpSpawn.spawnFlagsNeutral && !tmpSpawn.spawnFlagsFriendly)
					{
						LogAssert(false, "W3ApplicatorEffect.CacheSettings: effect <<" + effectName +">> of applicator <<" + tmpApplicatorName + ">> has no hostility flags set! Aborting!");
						continue;
					}
					
					spawns.PushBack(tmpSpawn);
					
					
					tmpSpawn.spawnType = EET_Undefined;
					tmpSpawn.spawnAbilityName = '';
					tmpSpawn.spawnFlagsHostile = false;
					tmpSpawn.spawnFlagsNeutral = false;
					tmpSpawn.spawnFlagsFriendly = false;
					tmpSpawn.spawnSourceName = "";
				}
				break;
			}
		}
	}	
}