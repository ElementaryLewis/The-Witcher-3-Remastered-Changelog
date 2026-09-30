/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GuiTransmogInventoryComponent extends W3GuiPlayerInventoryComponent
{
	public var merchantInv : CInventoryComponent;
	public var currentGridPosition : int;
	
	public  function SetInventoryFlashObjectForItem( item : SItemUniqueId , out flashObject : CScriptedFlashObject) : void
	{
		super.SetInventoryFlashObjectForItem( item, flashObject );

		flashObject.SetMemberFlashInt( "sectionId", 0 );

		
		flashObject.SetMemberFlashBool( "cantEquip", false );

		
		flashObject.SetMemberFlashBool( "needRepair", false );
		flashObject.SetMemberFlashInt( "socketsCount", 0 );
		flashObject.SetMemberFlashInt( "socketsUsedCount", 0 );
		flashObject.SetMemberFlashBool( "enchanted", false );
		flashObject.SetMemberFlashBool( "isOilApplied", false );
	}

	public function SetInventoryFlashObjectForAppear( item : SItemUniqueId, itemName : name, isPreviewItem : bool, out flashObject : CScriptedFlashObject) : void
	{
		var iconPath : string;
		var min, max : int;
	
		SetInventoryFlashObjectForItem( item, flashObject );

		flashObject.SetMemberFlashString( "itemName", itemName );

		if(!_inv.HasTransmogAppearance(item))
		{
			flashObject.SetMemberFlashBool( "transmog", _inv.GetItemName(item) == itemName );
		}
		else
		{
			flashObject.SetMemberFlashBool( "transmog", true );
			flashObject.SetMemberFlashBool( "reset", _inv.GetItemName(item) == itemName );
		}

		iconPath = _inv.GetItemIconPathByName(itemName);
		flashObject.SetMemberFlashString( "iconPath", iconPath );

		flashObject.SetMemberFlashInt( "realId", ItemToFlashUInt(item) );
		flashObject.SetMemberFlashInt( "id", NameToFlashUInt(itemName) );

		_inv.GetItemQualityFromName( itemName, min, max );
		flashObject.SetMemberFlashInt( "quality", isPreviewItem ? _inv.GetItemQuality(item) : min );
	}
	
	public function ClearGridPostion()
	{
		currentGridPosition = 0;
	}
}