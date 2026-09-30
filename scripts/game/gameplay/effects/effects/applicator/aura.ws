/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3Effect_Aura extends W3ApplicatorEffect
{
	private saved var isOneTimeOnly : bool;						
	protected saved var range : float;							
	private var flags : int;									
	
	
	event OnUpdate(deltaTime : float)
	{
		var ents : array<CGameplayEntity>;
		var i : int;
	
		super.OnUpdate(deltaTime);
	
		FindGameplayEntitiesInSphere(ents, target.GetWorldPosition(), range, 1000, '', flags);
		
		OnPreApplySpawns(ents);
			
		for(i=0; i<ents.Size(); i+=1)															
			ApplySpawnsOn(ents[i]);
			
		if(isOneTimeOnly)
			isActive = false;
	}
	
	event OnPreApplySpawns(out ents : array<CGameplayEntity>){}	
	
	public function CacheSettings()
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpAuraName, tmpName : name;
		var i : int;
		var tmpFloat : float;
		var tmpBool : bool;
		var type : EEffectType;
	
		super.CacheSettings();
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpAuraName);
			EffectNameToType(tmpAuraName, type, tmpName);
			if(effectType == type)
			{
				
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'isOneTimeOnly', tmpBool))
					isOneTimeOnly = tmpBool;
				if(dm.GetCustomNodeAttributeValueFloat(main.subNodes[i], 'range', tmpFloat))
				{
					range = tmpFloat;	
				}
				else
				{
					LogAssert(false, "W3Effect_Aura.CacheSettings: no range defined for aura applicator <<" + tmpAuraName + ">>, aborting!");
					return;
				}				
			}
		}
		
		
		if(!HasNeutralSpawn())
			flags = FLAG_OnlyAliveActors;		
		else
			flags = 0;
	}	
}