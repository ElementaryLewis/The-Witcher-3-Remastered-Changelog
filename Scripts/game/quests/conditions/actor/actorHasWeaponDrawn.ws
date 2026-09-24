/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_HasWeaponDrawn extends CQCActorScriptedCondition
{
	editable var treatFistsAsWeapon : bool;
	editable var ofSpecificCategory : name;
	editable var ofSpecificName : name;
	
	default treatFistsAsWeapon = true;
	
	hint ofSpecificCategory = "optional parameter";
	hint ofSpecificName = "optional parameter";
	
	function Evaluate(act : CActor ) : bool
	{	
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i : int;
		
		inv = act.GetInventory();
		
		if( IsNameValid( ofSpecificName ) )
		{
			ids = inv.GetHeldWeapons();
			
			if( ids.Size() )
			{
				for( i = 0; i < ids.Size(); i += 1 )
				{
					if( inv.GetItemName( ids[ i ] ) == ofSpecificName )
					{
						return true;
					}
				}
			}
			
			return false;
		}
		else if( IsNameValid( ofSpecificCategory ) )
		{
			inv.GetHeldWeaponsWithCategory( ofSpecificCategory, ids );
			return ids.Size();
		}
		else
		{
			return act.HasWeaponDrawn( treatFistsAsWeapon );
		}
	}
}