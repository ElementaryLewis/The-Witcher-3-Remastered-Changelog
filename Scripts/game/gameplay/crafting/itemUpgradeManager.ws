/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ItemUpgradeManager
{
	private var upgrades : array<SItemUpgradeListElement>;						
	
	public function Init()
	{
		LoadXMLData();
	}
	
	
	public function PurchaseUpgrade(item : SItemUniqueId, upgradeName : name) : EItemUpgradeException
	{
		var check : EItemUpgradeException;
		var i, idx : int;
	
		
		check = CanPurchaseUpgrade(item, upgradeName);
		if(check != EIUE_NoException)
			return check;
			
		idx = GetUpgradeIndex(item, upgradeName);
		
		
		thePlayer.RemoveMoney( upgrades[idx].upgrade.cost );
		
		
		for(i=0; i<upgrades[idx].upgrade.ingredients.Size(); i+=1)
		{
			thePlayer.inv.RemoveItemByName(upgrades[idx].upgrade.ingredients[i].itemName, upgrades[idx].upgrade.ingredients[i].quantity);
		}
		
		
		thePlayer.inv.AddItemCraftedAbility(item, upgrades[idx].upgrade.ability);
		
		return EIUE_NoException;
	}
	
	private function GetUpgradeIndex(item : SItemUniqueId, upgradeName : name) : int
	{
		var i : int;
		
		for(i=0; i<upgrades.Size(); i+=1)
		{
			if(upgrades[i].upgrade.upgradeName == upgradeName && upgrades[i].itemId == item)
				return i;
		}
		return -1;
	}
	
	
	public function CanPurchaseUpgrade(item : SItemUniqueId, upgradeName : name) : EItemUpgradeException
	{
		var i, j, idx, cnt : int;
		var upg : SItemUpgrade;
		var requiredName, requiredAbilityName : name;
	
		
		if(!thePlayer.inv.IsItemUpgradeable(item))
			return EIUE_ItemNotUpgradeable;
		
		
		idx = GetUpgradeIndex(item, upgradeName);
				
		if(idx < 0)
			return EIUE_NoSuchUpgradeForItem;
		
		upg = upgrades[idx].upgrade;
		
		
		if(thePlayer.GetMoney() < upg.cost)
			return EIUE_NotEnoughGold;
			
		
		for(i=0; i<upg.ingredients.Size(); i+=1)
		{
			cnt = thePlayer.inv.GetItemQuantityByName(upg.ingredients[i].itemName);
			if(cnt <= 0)
				return EIUE_MissingIngredient;
			else if(cnt < upg.ingredients[i].quantity)
				return EIUE_NotEnoughIngredient;
		}
		
		
		for(i=0; i<upg.requiredUpgrades.Size(); i+=1)
		{
			
			requiredName = upg.requiredUpgrades[i];
			
			
			requiredAbilityName = '';
			for(j=0; j<upgrades.Size(); j+=1)
			{
				if(upgrades[j].itemId == item && upgrades[j].upgrade.upgradeName == requiredName)
				{
					requiredAbilityName = upgrades[j].upgrade.ability;
					break;
				}
			}
			
			
			if(IsNameValid(requiredAbilityName))
			{
				if(!thePlayer.inv.ItemHasAbility(item, requiredAbilityName))
					return EIUE_MissingRequiredUpgrades;
			}
		}
		
		
		if(thePlayer.inv.ItemHasAbility(item, upg.ability))
			return EIUE_AlreadyPurchased;
			
		
		return EIUE_NoException;
	}

	private function LoadXMLData()
	{
		var items : array<SItemUniqueId>;
		var i,j,k,m,tmpInt : int;
		var tmpName, upgradesListName : name;
		var tmpString : string;
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients, requirements : SCustomNode;
		var upgradesDefs : array< SCustomNode >;
		var ing : SItemParts;
		var upgradeElement : SItemUpgradeListElement;		
		
		thePlayer.inv.GetAllItems(items);
		
		for(i=items.Size()-1; i>=0; i-=1)
		{
			if(!thePlayer.inv.IsItemUpgradeable(items[i]))
				items.Erase(i);
		}
		
		
		if(items.Size() <= 0)
			return;
			
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('upgrades_lists');
		
		for(j=0; j<items.Size(); j+=1)
		{
			upgradesListName = dm.GetItemUpgradeListName(thePlayer.inv.GetItemName(items[j]), true);
			
			if(!IsNameValid(upgradesListName))
			{
				LogAssert(false, "W3ItemUpgradeManager.LoadXMLData: item <<" + thePlayer.inv.GetItemName(items[j]) + ">> has non-valid upgrades list name <<" + upgradesListName + ">>");
				continue;
			}
			
			for(i=0; i<main.subNodes.Size(); i+=1)
			{
				dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
				if(tmpName != upgradesListName)
					continue;
				
				upgradesDefs = main.subNodes[i].subNodes;
				for(k=0; k<upgradesDefs.Size(); k+=1)
				{
					if(dm.GetCustomNodeAttributeValueName(upgradesDefs[k], 'name_name', tmpName))
						upgradeElement.upgrade.upgradeName = tmpName;
					if(dm.GetCustomNodeAttributeValueName(upgradesDefs[k], 'localizedName_name', tmpName))
						upgradeElement.upgrade.localizedName = tmpName;
					if(dm.GetCustomNodeAttributeValueName(upgradesDefs[k], 'localizedDescription_name', tmpName))
						upgradeElement.upgrade.localizedDescriptionName = tmpName;
					if(dm.GetCustomNodeAttributeValueInt(upgradesDefs[k], 'cost', tmpInt))
						upgradeElement.upgrade.cost = tmpInt;
					if(dm.GetCustomNodeAttributeValueString(upgradesDefs[k], 'icon', tmpString))
						upgradeElement.upgrade.iconPath = tmpString;
					if(dm.GetCustomNodeAttributeValueName(upgradesDefs[k], 'ability_name', tmpName))
						upgradeElement.upgrade.ability = tmpName;
					
					
					ingredients = dm.GetCustomDefinitionSubNode(upgradesDefs[k],'ingredients');					
					for(m=0; m<ingredients.subNodes.Size(); m+=1)
					{	
						if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[m], 'name_name', tmpName))
							ing.itemName = tmpName;
						if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[m], 'quantity', tmpInt))
							ing.quantity = tmpInt;
							
						upgradeElement.upgrade.ingredients.PushBack(ing);
						ing.itemName = '';
						ing.quantity = 0;
					}
					
					
					requirements = dm.GetCustomDefinitionSubNode(upgradesDefs[k],'required_upgrades');					
					for(m=0; m<requirements.values.Size(); m+=1)
					{
						if(IsNameValid(requirements.values[m]))
							upgradeElement.upgrade.requiredUpgrades.PushBack(requirements.values[m]);
						else
							LogAssert(false, "W3ItemUpgradeManager.LoadXMLData: found not valid (non-name) required upgrade <<" + requirements.values[m] + ">>!!");
					}
					
					upgradeElement.itemId = items[j];
					
					upgrades.PushBack(upgradeElement);
					
					upgradeElement.itemId = GetInvalidUniqueId();
					upgradeElement.upgrade.upgradeName = '';
					upgradeElement.upgrade.localizedName = '';
					upgradeElement.upgrade.localizedDescriptionName = '';
					upgradeElement.upgrade.cost = 0;
					upgradeElement.upgrade.iconPath = "";
					upgradeElement.upgrade.ability = '';
					upgradeElement.upgrade.ingredients.Clear();
					upgradeElement.upgrade.requiredUpgrades.Clear();
				}
			}
		}
	}
}