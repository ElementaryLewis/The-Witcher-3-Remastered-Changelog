/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GuiSelectItemComponent extends W3GuiPlayerInventoryComponent
{

	public  function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		super.SetInventoryFlashObjectForItem( item, flashObject );
		
		flashObject.SetMemberFlashString( "itemName", GetLocStringByKeyExt(_inv.GetItemLocalizedNameByUniqueID(item)) );
		flashObject.SetMemberFlashBool( "isNew", false ); 
	}
}