/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3Effect_ApplicatorOnHit extends W3ApplicatorEffect
{
	private saved var fromSilverSword : bool;		
	private saved var fromSteelSword : bool;		
	private saved var fromSign : bool;				
	private saved var fromAll : bool;				
	
	
	public function ProcessOnHit(victim : CActor, silverSword : bool, steelSword : bool, sign : bool)
	{
		if( fromAll || (silverSword && fromSilverSword) || (steelSword && fromSteelSword) || (sign && fromSign))
			ApplySpawnsOn(victim);
	}	
	
	public function CacheSettings()
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpApplicatorName, tmpName : name;
		var i : int;
		var tmpBool : bool;
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
				
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'fromSilverSword', tmpBool))
					fromSilverSword = tmpBool;
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'fromSteelSword', tmpBool))
					fromSteelSword = tmpBool;
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'fromSign', tmpBool))
					fromSign = tmpBool;
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'fromAll', tmpBool))
					fromAll = tmpBool;
			}
		}
	}	
}