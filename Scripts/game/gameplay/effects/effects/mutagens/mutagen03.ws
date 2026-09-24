/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutagen03_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen03;
	default dontAddAbilityOnTarget = true;
	
	event OnEffectAddedPost()
	{
		var i : int;
		var items : array<SItemUniqueId>;
		
		super.OnEffectAddedPost();
		
		thePlayer.inv.GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if(thePlayer.inv.IsItemBomb(items[i]) || (!thePlayer.inv.IsItemMutagenPotion(items[i]) && thePlayer.inv.IsItemPotion(items[i])) )
				thePlayer.inv.SingletonItemAddAmmo(items[i], 1);
		}
	}
	
	event OnEffectRemoved()
	{
		var i : int;
		var items : array<SItemUniqueId>;
		
		super.OnEffectRemoved();
		
		thePlayer.inv.GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if(thePlayer.inv.IsItemBomb(items[i]) || (!thePlayer.inv.IsItemMutagenPotion(items[i]) && thePlayer.inv.IsItemPotion(items[i])) )
				thePlayer.inv.SingletonItemRemoveAmmo(items[i], 1);
		}
	}
}