/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SCustomNodeAttribute
{
	import var attributeName	: name;	
}

import struct SCustomNode
{
	import var nodeName		: name; 
	import var attributes	: array< SCustomNodeAttribute >;
	import var values		: array< name >;
	import var subNodes		: array< SCustomNode >;
}

import class CDefinitionsManagerAccessor extends CObject
{
	
	
	

	
	
	import final function GetItemAbilitiesWithWeights( itemName : name, playerItem : bool, out abilities : array< name >, out weights : array< float >, out minAbilities : int, out maxAbilities : int );
	import final function GetItemHoldSlot( itemName : name, playerItem : bool ) : name ;
	import final function GetItemCategory( itemName : name ) : name ;
	import final function GetItemPrice( itemName : name ) : int ;
	import final function GetItemEnhancementSlotCount( itemName : name ) : int;
	import final function GetItemUpgradeListName( itemName : name, playerItem : bool  ) : name ;
	import final function GetItemLocalisationKeyName( itemName : name ) : string ;
	import final function GetItemLocalisationKeyDesc( itemName : name ) : string ;
	import final function GetItemIconPath( itemName : name ) : string ;
	import final function ItemHasTag( itemName : name, tag : name ) : bool ;
	import final function GetItemsWithTag( tag : name ) : array< name >;
	import final function GetItemEquipTemplate( itemName : name ) : string;
	import final function GetUsableItemType( itemName : name ) : EUsableItemType;

	import final function TestWitchcraft();
	import final function ValidateLootDefinitions( listAllItemDefs : bool );
	import final function ValidateRecyclingParts( listAllItemDefs : bool );
	import final function ValidateCraftingDefinitions( listAllItemDefs : bool );

	import final function AddAllItems( optional category : name , optional depot : string , optional invisibleItems : bool ) : void;

	
	public function GetItemAttributeValueNoRandom(itemName : name, playerItem : bool, attributeName : name, out min : SAbilityAttributeValue, out max : SAbilityAttributeValue)
	{
		var abs : array<name>;
		var temp : array<float>;
		var tempInt : int;
		
		GetItemAbilitiesWithWeights(itemName, playerItem, abs, temp, tempInt, tempInt);
		GetAbilitiesAttributeValue(abs, attributeName, min, max);		
	}
	
	public function IsItemBolt(item : name) : bool					{return GetItemCategory(item) == 'bolt';}	
	public function IsItemSingletonItem(itemName : name) : bool		{return ItemHasTag(itemName, theGame.params.TAG_ITEM_SINGLETON);}
	public function IsItemBomb(item : name) : bool					{return GetItemCategory(item) == 'petard';}
	public function IsItemPotion(item : name) : bool				{return ItemHasTag(item, 'Potion');}
	public function IsItemIngredient(item : name) : bool			{return ItemHasTag(item, 'AlchemyIngredient') || ItemHasTag(item, 'CraftingIngredient');}
	public function IsItemOil(item : name) : bool					{return ItemHasTag(item, 'SilverOil') || ItemHasTag(item, 'SteelOil');}
	public function IsItemWeapon(item : name) : bool				{return ItemHasTag(item, 'Weapon') || ItemHasTag(item, 'WeaponTab');}
	public function IsItemAnyArmor(item : name) : bool				{return ItemHasTag(item, theGame.params.TAG_ARMOR);}
	public function IsItemAlchemyItem(item : name) : bool			{return IsItemOil(item) || IsItemPotion(item) || IsItemBomb(item);}
	
	public function GetFilterTypeByItem( itemName : name ) : EInventoryFilterType
	{
		var filterType : EInventoryFilterType;
					
		if( ItemHasTag( itemName, 'Quest' ) )
		{
			return IFT_QuestItems;
		}				
		else if( IsItemIngredient( itemName ) )
		{
			return IFT_Ingredients;
		}				
		else if( IsItemAlchemyItem(itemName) ) 
		{
			return IFT_AlchemyItems;
		}				
		else if( IsItemAnyArmor(itemName) )
		{
			return IFT_Armors;
		}				
		else if( IsItemWeapon( itemName ) )
		{
			return IFT_Weapons;
		}				
		else
		{
			return IFT_Default;
		}
	}
	
	public final function ItemHasAttribute(itemName : name, playerItem : bool, attributeName : name) : bool
	{
		var min, max : int;
		var abs, atts : array<name>;
		var w : array<float>;
		
		GetItemAbilitiesWithWeights(itemName, playerItem, abs, w, min, max);
		atts = GetAbilitiesAttributes(abs);
		return atts.Contains(attributeName);
	}
	
	public final function IsRecipeForMutagenPotion(recipeName : name) : bool
	{
		var main : SCustomNode;
		var i : int;
		var checkedRecipeName, cookedItemName : name;
		
		main = GetCustomDefinition('alchemy_recipes');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', checkedRecipeName) && checkedRecipeName == recipeName)
			{
				
				if(GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', cookedItemName))
				{
					if(ItemHasTag(cookedItemName, 'Mutagen') && GetItemCategory(cookedItemName) == 'potion')
						return true;
				}
				return false;
			}
		}
		
		return false;
	}
	
	
	
	
	
	public final function GetDamagesFromAbility( abilityName : name) : array< SRawDamage >
	{
		var atts : array< name >;
		var i : int;
		var dmg : SRawDamage;
		var damages : array< SRawDamage >;
		var min, max : SAbilityAttributeValue;
		
		GetAbilityAttributes( abilityName, atts );
		for( i=0; i<atts.Size(); i+=1 )
		{
			if( IsDamageTypeNameValid( atts[i] ) )
			{
				GetAbilityAttributeValue( abilityName, atts[i], min, max );
				dmg.dmgType = atts[i];
				dmg.dmgVal = min.valueBase * min.valueMultiplicative + min.valueAdditive;
				damages.PushBack( dmg );
			}
		}
		
		return damages;
	}
	
	import final function GetAbilityAttributeValue( abilityName : name, attributeName : name, out valMin : SAbilityAttributeValue, out valMax : SAbilityAttributeValue );
	import final function GetAbilitiesAttributeValue( abilitiesNames : array<name>, attributeName : name, out valMin : SAbilityAttributeValue, out valMax : SAbilityAttributeValue, optional tags : array<name> );
	import final function GetAbilityTags( ability : name, out tags : array<name> );
	import final function GetAbilityAttributes( ability : name, out attrib : array<name>  );
	import final function IsAbilityDefined( abilityName : name ) : bool;
	import final function GetContainedAbilities( abilityName : name, out abilities : array<name> );
	import final function GetUniqueContainedAbilities( abilities : array<name>, out outAbilities : array<name> );
	
		
	import final function AbilityHasTag(ability : name, tag : name) : bool;
	
	public final function AbilityHasAttribute(ability : name, attribute : name) : bool
	{
		var atts : array<name>;
		
		GetAbilityAttributes(ability, atts);
		return atts.Contains(attribute);
	}
	
	
	public final function GetAbilitiesAttributes(abilities : array<name>) : array<name>
	{
		var i, k : int;
		var atts, temp : array<name>;
		
		for(i=0; i<abilities.Size(); i+=1)
		{
			GetAbilityAttributes(abilities[i], temp);
			
			for(k=0; k<temp.Size(); k+=1)			
			{
				if( !atts.Contains( temp[k] ) )
				{
					atts.PushBack(temp[k]);
				}
			}
		}
		
		return atts;
	}
		
	
	public function GetAbilityDamages(abilityName : name, out damages : array<SRawDamage>) : int
	{
		var i : int;
		var min, max : SAbilityAttributeValue;
		var atts : array<name>;
		var dmg : SRawDamage;
		
		damages.Clear();
		GetAbilityAttributes(abilityName, atts);
		for(i=0; i<atts.Size(); i+=1)
		{
			if(IsDamageTypeNameValid(atts[i]))
			{
				dmg.dmgType = atts[i];
				GetAbilityAttributeValue(abilityName, atts[i], min, max);
				dmg.dmgVal = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				damages.PushBack(dmg);
			}
		}
		
		return damages.Size();
	}
	
	public final function GetItemLevelFromName( itemName : name ) : int
	{
		var itemCategory : name;
		var itemAttributes : array<SAbilityAttributeValue>;
		var min, max : SAbilityAttributeValue;
		var isWitcherGear : bool;
		var isRelicGear : bool;
		var level, baseLevel : int;
		
		var quality : int; 
		
		isWitcherGear = false;
		isRelicGear = false;
		
		GetItemAttributeValueNoRandom(itemName, false, 'quality', min, max );
		
		if ( min.valueAdditive == 5) isWitcherGear = true;
		if ( min.valueAdditive == 4) isRelicGear = true;
		
		quality = RoundMath( min.valueAdditive ); 
		
		itemCategory = GetItemCategory(itemName);
		
		switch(itemCategory)
		{
			case 'armor' :
			case 'boots' : 
			case 'gloves' :
			case 'pants' :
				GetItemAttributeValueNoRandom(itemName, false, 'armor', min, max);
				itemAttributes.PushBack( max );
				break;
				
			case 'silversword' :
				GetItemAttributeValueNoRandom(itemName, false, 'SilverDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'BludgeoningDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'RendingDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'ElementalDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'FireDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'PiercingDamage', min, max);
				itemAttributes.PushBack( max );
				break;
				
			case 'steelsword' :
				GetItemAttributeValueNoRandom(itemName, false, 'SlashingDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'BludgeoningDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'RendingDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'ElementalDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'FireDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'SilverDamage', min, max);
				itemAttributes.PushBack( max );
				GetItemAttributeValueNoRandom(itemName, false, 'PiercingDamage', min, max);
				itemAttributes.PushBack( max );
				break;
				
			case 'crossbow' :
				 GetItemAttributeValueNoRandom(itemName, false, 'attack_power', min, max);
				itemAttributes.PushBack( max );
				 break;
				 
			
			case 'bolt' :
				GetItemAttributeValueNoRandom(itemName, false, 'SilverDamage', min, max);
				itemAttributes.PushBack( max );
				break;
			
				 
			default :
				break;
		}
		
		level = theGame.params.GetItemLevel(itemCategory, itemAttributes, itemName, baseLevel);
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			if ( baseLevel > GetWitcherPlayer().GetMaxLevel() ) 
			{
				level = baseLevel;
			}
		}
		
		
		if ( itemCategory == 'bolt' )
		{
			
			if ( level < thePlayer.GetLevel() )
			{
				level = thePlayer.GetLevel();
			}
		}
		
		else if ( isWitcherGear ) level = level - 2;
		else if ( isRelicGear ) level = level - 1;
		if ( level < 1 ) level = 1;
		if ( ItemHasTag(itemName, 'OlgierdSabre') ) level = level - 3;
		if ( ItemHasTag(itemName, 'EP1') )
		{
			if ( (isRelicGear || isWitcherGear) ) 
			{
				level = level - 1;
			}
		}
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			if ( level > GetWitcherPlayer().GetMaxLevel() ) 
			{
				level = GetWitcherPlayer().GetMaxLevel();
			}
		}
		
		return level;
	}
	
	public final function IsItemSetItem( itemName : name ) : bool
	{
		return
			ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BEAR) ||
			ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_GRYPHON) ||
			ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_LYNX) ||
			ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_WOLF) ||
			ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_RED_WOLF) ||
			ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_VAMPIRE ) ||
			ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_VIPER) ||
			ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_NETFLIX) ;
	}
	
	
	
	
	
	import final function GetCustomDefinition( definition : name ) : SCustomNode;
	
	
	import final function GetAttributeValueAsInt( out node : SCustomNodeAttribute, out val : int ) : bool;
	
	
	import final function GetAttributeValueAsFloat( out node : SCustomNodeAttribute, out val : float ) : bool;
	
	
	import final function GetAttributeValueAsBool( out node : SCustomNodeAttribute, out val : bool ) : bool;
	
	
	import final function GetAttributeValueAsString( out node : SCustomNodeAttribute ) : string;
	
	import final function GetAttributeName( out node : SCustomNodeAttribute ) : name;
	
	
	import final function GetAttributeValueAsCName( out node : SCustomNodeAttribute ) : name;
	
	
	import final function GetSubNodeByAttributeValueAsCName( out node : SCustomNode, rootNodeName : name, attributeName : name, attributeValue : name ) : bool;
	
	import final function GetCustomDefinitionSubNode( out node : SCustomNode, subnode : name) : SCustomNode;
	
	import final function FindAttributeIndex( out node : SCustomNode, attName : name) : int;
	
	import final function GetCustomNodeAttributeValueString( out node : SCustomNode, attName : name, out val : string) : bool;
	
	import final function GetCustomNodeAttributeValueName( out node : SCustomNode, attName : name, out val : name) : bool;
	
	import final function GetCustomNodeAttributeValueInt( out node : SCustomNode, attName : name, out val : int) : bool;
	
	import final function GetCustomNodeAttributeValueBool( out node : SCustomNode, attName : name, out val : bool) : bool;
	
	import final function GetCustomNodeAttributeValueFloat( out node : SCustomNode, attName : name, out val : float) : bool;
}

exec function AddAllItems( optional category : name , optional depot : string , optional invisibleItems : bool )
{
	var defMgr : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();

	switch (StrLower(depot))
	{
	case "w3":
	case "vanilla":
	case "vanila":
		depot = 'W3';
		break;
	case "ep2":
	case "baw":
	case "bob":
		depot = 'bob';
		break;
	case "ep1":
	case "hos":
		depot = 'ep1';
		break;
	default:
		break;
	}

	defMgr.AddAllItems( category , depot , invisibleItems );
}