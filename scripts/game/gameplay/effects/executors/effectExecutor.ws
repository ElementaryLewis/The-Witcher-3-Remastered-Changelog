/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class IGameplayEffectExecutor extends CObject
{
	
	public function Execute( executor : CGameplayEntity, target : CActor, optional source : string ) : bool
	{
		
		return false;
	}
	
	public function GetEffectIconPath() : string {return "";}
	public function GetEffectNameLocalisationKey() : string {return "";}
	public function GetEffectDescriptionLocalisationKey() : string {return "";}
}


abstract class IInstantEffectExecutor extends IGameplayEffectExecutor
{
	protected editable var customIconPath : string;						
	protected editable var customNameLocalisationKey : string;			
	protected editable var customDescriptionLocalisationKey : string;	
	protected var executorName : name;									
		default executorName = '';
	
	hint customIconPath = "Will override XML default";
	hint customNameLocalisationKey = "Will override XML default";
	hint customDescriptionLocalisationKey = "Will override XML default";
		
	public function Execute( executor : CGameplayEntity, target : CActor, optional source : string ) : bool
	{
		
		return false;
	}
	
	public final function GetEffectIconPath() : string
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName, iconTypeName : name;
		var tmpString : string;
		var i : int;
		
		if(customIconPath != "")
			return customIconPath;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('CFM_instants');
		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName))
			{
				if(IsNameValid(tmpName) && tmpName == executorName)
				{
					if(dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'iconType_name', tmpString))
					{
						iconTypeName = tmpName;
						break;
					}
				}
			}
		}
		
		
		main = dm.GetCustomDefinition('CFM_instants_icons');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'iconType_name', tmpName))
			{
				if(IsNameValid(tmpName) && tmpName == iconTypeName)
				{
					dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'path', tmpString);
					return tmpString;
				}
			}
		}
		
		LogAssert(false, "IGameplayEffectExecutor.GetEffectIconPath: icon path undefined for executor <<" + executorName + ">>");
		return "";
	}
	
	public final function GetEffectNameLocalisationKey() : string
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName : name;
		var tmpString : string;
		var i : int;
		
		if(customNameLocalisationKey != "")
			return customNameLocalisationKey;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('CFM_instants');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName))
			{
				if(IsNameValid(tmpName) && tmpName == executorName)
				{
					dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'nameLocalisationKey', tmpString);
					return tmpString;
				}
			}
		}
		
		LogAssert(false, "IGameplayEffectExecutor.GetEffectNameLocalisationKey: name localisation key undefined for executor <<" + executorName + ">>");
		return "";
	}
	
	public final function GetEffectDescriptionLocalisationKey() : string
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName : name;
		var tmpString : string;
		var i : int;
		
		if(customDescriptionLocalisationKey != "")
			return customDescriptionLocalisationKey;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('CFM_instants');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName))
			{
				if(IsNameValid(tmpName) && tmpName == executorName)
				{
					dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'descriptionLocalisationKey', tmpString);
					return tmpString;
				}
			}
		}
		
		LogAssert(false, "IGameplayEffectExecutor.GetEffectDescriptionLocalisationKey: description localisation key undefined for executor <<" + executorName + ">>");
		return "";
	}
}




class CBuffEffectExecutor extends IGameplayEffectExecutor
{
	private editable var effectType			: EEffectType;				
	private editable var duration			: float;					
	private editable var customEffectValue	: SAbilityAttributeValue;	
	
	public function Execute( executor : CGameplayEntity, target : CActor, optional source : string ) : bool
	{
		var params : SCustomEffectParams;
		
		params.effectType = effectType;
		params.creator = executor;
		params.sourceName = source;
		params.duration = duration;
		params.effectValue = customEffectValue;
		
		target.AddEffectCustom(params);
		return true;
	}
	
	public function GetEffectNameLocalisationKey() : string
	{
		return theGame.effectMgr.GetEffectNameLocalisationKey( effectType );
	}
	
	public function GetEffectDescriptionLocalisationKey() : string
	{
		return theGame.effectMgr.GetEffectDescriptionLocalisationKey( effectType );
	}

	public function GetEffectIconPath() : string
	{
		return theGame.effectMgr.GetEffectIconPath( effectType );
	}
}