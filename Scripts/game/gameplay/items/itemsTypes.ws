/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EArmorType
{
	EAT_Undefined,
	EAT_Light,
	EAT_Medium,
	EAT_Heavy
}



enum EEquipmentSlots
{
	EES_InvalidSlot,
	EES_SilverSword,
	EES_SteelSword,
	EES_Armor,
	EES_Boots,
	EES_Pants,
	EES_Gloves,	
	EES_Petard1,
	EES_Petard2,
	EES_RangedWeapon,
	EES_Quickslot1,
	EES_Quickslot2,
EES_Unused,
	EES_Hair,
	EES_Potion1,
	EES_Potion2,
	EES_Mask,
	EES_Bolt,
	EES_PotionMutagen1,
	EES_PotionMutagen2,
	EES_PotionMutagen3,
	EES_PotionMutagen4,
	EES_SkillMutagen1,
	EES_SkillMutagen2,
	EES_SkillMutagen3,
	EES_SkillMutagen4,
	EES_HorseBlinders,
	EES_HorseSaddle,
	EES_HorseBag,
	EES_HorseTrophy,
	EES_Potion3,
	EES_Potion4
}

function IsSlotHorseSlot(slot : EEquipmentSlots) : bool
{
	if(slot == EES_HorseBlinders || slot == EES_HorseSaddle || slot == EES_HorseBag || slot == EES_HorseTrophy)
		return true;
		
	return false;
}

function SlotEnumToName(slot : EEquipmentSlots) : name
{
	if(slot == EES_InvalidSlot) return 'EES_InvalidSlot';
	else if(slot == EES_SilverSword) return 'EES_SilverSword';
	else if(slot == EES_SteelSword) return 'EES_SteelSword';
	else if(slot == EES_Armor) return 'EES_Armor';
	else if(slot == EES_Boots) return 'EES_Boots';
	else if(slot == EES_Pants) return 'EES_Pants';
	else if(slot == EES_Gloves) return 'EES_Gloves';
	else if(slot == EES_Petard1) return 'EES_Petard1';
	else if(slot == EES_Petard2) return 'EES_Petard2';
	else if(slot == EES_RangedWeapon) return 'EES_RangedWeapon';
	else if(slot == EES_Quickslot1) return 'EES_Quickslot1';
	else if(slot == EES_Quickslot2) return 'EES_Quickslot2';
	else if(slot == EES_Unused) return 'EES_Unused';
	else if(slot == EES_Hair) return 'EES_Hair';
	else if(slot == EES_Potion1) return 'EES_Potion1';
	else if(slot == EES_Potion2) return 'EES_Potion2';
	else if(slot == EES_Mask) return 'EES_Mask';
	else if(slot == EES_Bolt) return 'EES_Bolt';
	else if(slot == EES_PotionMutagen1) return 'EES_PotionMutagen1';
	else if(slot == EES_PotionMutagen2) return 'EES_PotionMutagen2';
	else if(slot == EES_PotionMutagen3) return 'EES_PotionMutagen3';
	else if(slot == EES_PotionMutagen4) return 'EES_PotionMutagen4';
	else if(slot == EES_SkillMutagen1) return 'EES_SkillMutagen1';
	else if(slot == EES_SkillMutagen2) return 'EES_SkillMutagen2';
	else if(slot == EES_SkillMutagen3) return 'EES_SkillMutagen3';
	else if(slot == EES_SkillMutagen4) return 'EES_SkillMutagen4';
	else if(slot == EES_HorseBlinders) return 'EES_HorseBlinders';
	else if(slot == EES_HorseSaddle) return 'EES_HorseSaddle';
	else if(slot == EES_HorseBag) return 'EES_HorseBag';
	else if(slot == EES_HorseTrophy) return 'EES_HorseTrophy';
	else if(slot == EES_Potion3) return 'EES_Potion3';
	else if(slot == EES_Potion4) return 'EES_Potion4';
	
	return '';
}

function SlotNameToEnum(slot : name) : EEquipmentSlots
{
	if(slot == 'EES_InvalidSlot') return EES_InvalidSlot;
	else if(slot == 'EES_SilverSword') return EES_SilverSword;
	else if(slot == 'EES_SteelSword') return EES_SteelSword;
	else if(slot == 'EES_Armor') return EES_Armor;
	else if(slot == 'EES_Boots') return EES_Boots;
	else if(slot == 'EES_Pants') return EES_Pants;
	else if(slot == 'EES_Gloves') return EES_Gloves;
	else if(slot == 'EES_Petard1') return EES_Petard1;
	else if(slot == 'EES_Petard2') return EES_Petard2;
	else if(slot == 'EES_RangedWeapon') return EES_RangedWeapon;
	else if(slot == 'EES_Quickslot1') return EES_Quickslot1;
	else if(slot == 'EES_Quickslot2') return EES_Quickslot2;
	else if(slot == 'EES_Unused') return EES_Unused;
	else if(slot == 'EES_Hair') return EES_Hair;
	else if(slot == 'EES_Potion1') return EES_Potion1;
	else if(slot == 'EES_Potion2') return EES_Potion2;
	else if(slot == 'EES_Mask') return EES_Mask;
	else if(slot == 'EES_Bolt') return EES_Bolt;
	else if(slot == 'EES_PotionMutagen1') return EES_PotionMutagen1;
	else if(slot == 'EES_PotionMutagen2') return EES_PotionMutagen2;
	else if(slot == 'EES_PotionMutagen3') return EES_PotionMutagen3;
	else if(slot == 'EES_PotionMutagen4') return EES_PotionMutagen4;
	else if(slot == 'EES_SkillMutagen1') return EES_SkillMutagen1;
	else if(slot == 'EES_SkillMutagen2') return EES_SkillMutagen2;
	else if(slot == 'EES_SkillMutagen3') return EES_SkillMutagen3;
	else if(slot == 'EES_SkillMutagen4') return EES_SkillMutagen4;
	else if(slot == 'EES_HorseBlinders') return EES_HorseBlinders;
	else if(slot == 'EES_HorseSaddle') return EES_HorseSaddle;
	else if(slot == 'EES_HorseBag') return EES_HorseBag;
	else if(slot == 'EES_HorseTrophy') return EES_HorseTrophy;
	else if(slot == 'EES_Potion3') return EES_Potion3;
	else if(slot == 'EES_Potion4') return EES_Potion4;
	
	return EES_InvalidSlot;
}

enum EItemGroup
{
	EIG_PLAYER,
	EIG_HORSE
}

function GetLocNameFromEquipSlot(slotType : EEquipmentSlots) : name
{
	switch (slotType)
	{
	case EES_InvalidSlot:
		return '';
	case EES_SilverSword:
		return 'panel_inventory_paperdoll_slotname_silver';
	case EES_SteelSword:
		return 'panel_inventory_paperdoll_slotname_steel';
	case EES_Armor:
		return 'panel_inventory_paperdoll_slotname_armor';
	case EES_Boots:
		return 'panel_inventory_paperdoll_slotname_boots';
	case EES_Pants:
		return 'panel_inventory_paperdoll_slotname_trousers';
	case EES_Gloves:
		return 'panel_inventory_paperdoll_slotname_gloves';
	case EES_Petard1:
	case EES_Petard2:
		return 'panel_inventory_paperdoll_slotname_petards';
	case EES_RangedWeapon:
		return 'panel_inventory_paperdoll_slotname_rangeweapon';
	case EES_Quickslot1:
		return 'panel_inventory_paperdoll_slotname_quickitems';	
	case EES_Quickslot2:
		return 'item_category_mask';	
	case EES_Unused:
	case EES_Hair:
		return '';
	case EES_Potion1:
	case EES_Potion2:
	case EES_Potion3:
	case EES_Potion4:
		return 'panel_inventory_paperdoll_slotname_potions';
	case EES_Mask:
		return '';
	case EES_Bolt:
		return 'panel_inventory_paperdoll_slotname_bolt';
	case EES_PotionMutagen1:
	case EES_PotionMutagen2:
	case EES_PotionMutagen3:
	case EES_PotionMutagen4:
		return 'panel_inventory_paperdoll_slotname_mutagen';
	case EES_SkillMutagen1:
	case EES_SkillMutagen2:
	case EES_SkillMutagen3:
	case EES_SkillMutagen4:
		return 'panel_inventory_paperdoll_slotname_mutagen';
	case EES_HorseBlinders:
		return 'panel_inventory_paperdoll_slotname_horseblinders';
	case EES_HorseSaddle:
		return 'panel_inventory_paperdoll_slotname_horsesaddle';
	case EES_HorseBag:
		return 'panel_inventory_paperdoll_slotname_horsebag';
	case EES_HorseTrophy:
		return 'panel_inventory_paperdoll_slotname_horsetrophy';
	}
	
	return '';
}


function IsMultipleSlot(slot : EEquipmentSlots) : bool
{
	return slot == EES_Petard1 || slot == EES_Petard2 || slot == EES_Quickslot1 || slot == EES_Quickslot2 || IsSlotPotionSlot(slot)
			|| slot == EES_PotionMutagen1 || slot == EES_PotionMutagen2 || slot == EES_PotionMutagen3 || slot == EES_PotionMutagen4
			|| slot == EES_SkillMutagen1 || slot == EES_SkillMutagen2 || slot == EES_SkillMutagen3 || slot == EES_SkillMutagen4;
}


enum EInventoryFilterType
{
	IFT_None,
	IFT_Weapons,
	IFT_Armors,
	IFT_AlchemyItems,
	IFT_Ingredients,
	IFT_QuestItems,
	IFT_Default,
	IFT_HorseItems,
	IFT_Books,
	IFT_AllExceptHorseItem
}



enum EInventoryActionType
{
	IAT_None,
	IAT_Equip,
	IAT_UpgradeWeapon,
	IAT_UpgradeWeaponSteel,
	IAT_UpgradeWeaponSilver,
	IAT_UpgradeArmor,
	IAT_Consume,
	IAT_Read,
	IAT_Drop,
	IAT_Transfer,
	IAT_Sell,
	IAT_Buy,
	
	IAT_Repair,
	IAT_Divide,
	IAT_Socket
}



struct SItemDataStub
{
	var id : SItemUniqueId;
	var quantity : int;
	var iconPath : string;
	var gridPosition : int;
	var gridSize : int;
	var slotType : int;
	var isNew : bool;
	var actionType : int;
	var price : int;
	var userData : string; 
	var category : string;
	var equipped : int;
	var isReaded : bool;
}


function GetInvalidUniqueId() : SItemUniqueId
{
	var invalidUniqueId : SItemUniqueId;
	return invalidUniqueId;
}


enum ECompareType
{
	ECT_Incomparable,
	ECT_Compare
}





import struct SInventoryItem { };

import struct SItemUniqueId { };

import struct SInventoryItemUIData
{
	import var gridPosition : int;
	import var gridSize : int;
	import var isNew : bool;
}

import struct SItemParts
{
	import var itemName : name;
	import var quantity : int;
}




function GetFilterTypeName( filterType : EInventoryFilterType ) : name
{
	switch(filterType)
	{
		case IFT_Weapons:
			return 'panel_inventory_filter_type_weapons';
		case IFT_Armors:
			return 'panel_inventory_filter_type_armors';
		case IFT_AlchemyItems:
			return 'panel_inventory_filter_type_alchemy_items';			
		case IFT_Ingredients:
			return 'panel_inventory_filter_type_ingredients';
		case IFT_QuestItems:
			return 'panel_inventory_filter_type_quest_items';			
		case IFT_Default:
			return 'panel_inventory_filter_type_default';
		case IFT_HorseItems:
			return 'panel_inventory_filter_type_horse';
		case IFT_AllExceptHorseItem:
			return 'panel_inventory_filter_type_geralt';
		default:
			return '';
	}
}

function GetFilterTypeByName( filterName : name ) : EInventoryFilterType 
{
	switch(filterName)
	{
		case 'panel_inventory_filter_type_weapons':
			return IFT_Weapons;
		case 'panel_inventory_filter_type_armors':
			return IFT_Armors;
		case 'panel_inventory_filter_type_alchemy_items':
			return IFT_AlchemyItems;			
		case 'panel_inventory_filter_type_ingredients':
			return IFT_Ingredients;
		case 'panel_inventory_filter_type_quest_items':
			return IFT_QuestItems;			
		case 'panel_inventory_filter_type_default':
			return IFT_Default;
		case 'panel_inventory_filter_type_horse':
			return IFT_HorseItems;
		case 'panel_inventory_filter_type_geralt':
			return IFT_AllExceptHorseItem;
		default:
			return IFT_Default;
	}
}


function GetSlotForItem(category : name, tags : array<name>, isPlayer : bool) : EEquipmentSlots
{
	if (isPlayer && tags.Contains('PlayerUnwearable') ) return EES_InvalidSlot;
	else if(tags.Contains('PlayerSteelWeapon'))		return EES_SteelSword;
	else if(tags.Contains('PlayerSilverWeapon'))	return EES_SilverSword;
	else if(tags.Contains('Potion'))				return EES_Potion1;
	else if(tags.Contains('Petard'))				return EES_Petard1;
	else if(tags.Contains('QuickSlot'))				return EES_Quickslot1;
	else if(tags.Contains('Mutagen'))				return EES_PotionMutagen1;
	else if(tags.Contains('bolt'))					return EES_Bolt;
	else if(tags.Contains('Saddle'))				return EES_HorseSaddle;
	else if(tags.Contains('HorseBag'))				return EES_HorseBag;
	else if(tags.Contains('Trophy'))				return EES_HorseTrophy;
	else if(tags.Contains('Blinders'))				return EES_HorseBlinders;
	else if( tags.Contains('TypeAxe') || tags.Contains('TypeMace') || tags.Contains('TypeClub') )	return EES_SteelSword;
	else if(tags.Contains('Edibles') || tags.Contains('Drinks'))	return EES_Potion1;
	else
	{
		switch(category)
		{
			case 'armor' :				return EES_Armor;
			case 'boots' :				return EES_Boots;
			case 'gloves' :				return EES_Gloves;
			case 'trousers' :
			case 'pants' :				return EES_Pants;
			case 'mask' :				return EES_Mask;
			case 'hair'	: 				return EES_Hair; 
			case 'crossbow'	: 			return EES_RangedWeapon; 
			default :					return EES_InvalidSlot;
		}
	}
}

function GetSlotForItemByCategory(category : name) : EEquipmentSlots
{
	switch(category)
	{
		case 'steelsword' :			return EES_SteelSword;
		case 'silversword' :		return EES_SilverSword;
		case 'armor' :				return EES_Armor;
		case 'boots' :				return EES_Boots;
		case 'gloves' :				return EES_Gloves;
		case 'trousers' :
		case 'pants' :				return EES_Pants;
		case 'mask' :				return EES_Mask;
		case 'hair'	: 				return EES_Hair;
		case 'crossbow'	: 			return EES_RangedWeapon;
		case 'petard'	: 			return EES_Petard1;
		case 'potion'	: 			return EES_Potion1;
		
		case 'bolt'	: 				return EES_Bolt;
		case 'trophy' : 			return EES_HorseTrophy;
		case 'horse_bag' : 			return EES_HorseBag;
		case 'horse_blinder' :	 	return EES_HorseBlinders;
		case 'horse_saddle'	: 		return EES_HorseSaddle;
		
		default :					return EES_InvalidSlot;
	}
}

function IsSlotSkillMutagen(slot : EEquipmentSlots) : bool
{
	return slot == EES_SkillMutagen1 || slot == EES_SkillMutagen2 || slot == EES_SkillMutagen3 || slot == EES_SkillMutagen4;
}

function IsSlotPotionMutagen(slot : EEquipmentSlots) : bool
{
	return slot == EES_PotionMutagen1 || slot == EES_PotionMutagen2 || slot == EES_PotionMutagen3 || slot == EES_PotionMutagen4;
}


function IsSlotQuickslot(slot : EEquipmentSlots) : bool
{
	return slot == EES_Quickslot1 || slot == EES_Quickslot2;
}


function IsSlotMutagen(slot : EEquipmentSlots) : bool
{
	return slot == EES_PotionMutagen1 || slot == EES_PotionMutagen2 || slot == EES_PotionMutagen3 || slot == EES_PotionMutagen4;
}


function IsSlotPotionSlot(slot : EEquipmentSlots) : bool
{
	return slot == EES_Potion1 || slot == EES_Potion2 || slot == EES_Potion3 || slot == EES_Potion4;
}


function IsSlotPetardslot(slot : EEquipmentSlots) : bool
{
	return slot == EES_Petard1 || slot == EES_Petard2;
}

function GetItemActionFriendlyName( itemAction : EInventoryActionType, optional isEquipped : bool ) : string
{
	switch(itemAction)
	{
			
		case IAT_Equip :
			if( isEquipped )
			{
				return "panel_button_inventory_unequip";
			}
			return "panel_button_inventory_equip";		
		case IAT_Consume :
			return "panel_button_inventory_consume";	
		case IAT_Read :
			return "panel_button_inventory_read";	
		
		case IAT_Drop :
			return "panel_button_common_drop";	
		case IAT_Transfer :
			return "panel_button_inventory_transfer";	
		case IAT_Buy :
			return "panel_button_inventory_buy";
		case IAT_Sell :
			return "panel_button_inventory_sell";
		case IAT_Divide :
			return "panel_button_inventory_divide";		
		case IAT_Repair :
			return "panel_button_inventory_repair";
		default :
			return "ERROR_ItemActionFriendlyName";
	}
	
	
}

function IsBookTextureTag( tag : string ) : bool
{
	switch(tag)
	{
		case "tresure_map_waterfall" :
		case "tresure_map_tower" :
		case "q301_drawing_oven" :
		case "q301_drawing_crib" :
			return true;
	}
	return false;
}





struct SAreaItemDefinition
{
	saved var itemName : name;		
	saved var maxCount : int;			
};

struct SAreaLootParams
{
	saved var remainingItemDrops : array<SAreaItemDefinition>;			
	saved var areaType : EAreaName;										
};
