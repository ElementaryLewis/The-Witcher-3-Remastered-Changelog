/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleLootFeed extends CR4HudModuleBase
{	
	private var m_flashValueStorage : CScriptedFlashValueStorage;

	private var m_addQueue : array< SItemChangedData >;

	private	var m_fxSetMaxShowerCount				: CScriptedFlashFunction;
	private	var m_fxSetTimes						: CScriptedFlashFunction;
	private	var m_fxSetElemScale					: CScriptedFlashFunction;
	private	var m_fxSetYGap							: CScriptedFlashFunction;

	
	
	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorLootFeed";
		
		flashModule 			= GetModuleFlash();
		m_flashValueStorage 	= GetModuleFlashValueStorage();

		m_fxSetMaxShowerCount	= flashModule.GetMemberFlashFunction( "setMaxShowerCount" );
		m_fxSetTimes	= flashModule.GetMemberFlashFunction( "setTimes" );
		m_fxSetElemScale	= flashModule.GetMemberFlashFunction( "setElemScale" );
		m_fxSetYGap	= flashModule.GetMemberFlashFunction( "setYGap" );

		SetDefaultParams();
		
		super.OnConfigUI();
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('LootFeedModule', true);
		}
	}

	function SetDefaultParams():void
	{
		m_fxSetMaxShowerCount.InvokeSelfOneArg(FlashArgInt(5));
		
		m_fxSetTimes.InvokeSelfFiveArgs(FlashArgNumber(0.5), FlashArgNumber(2.5), FlashArgNumber(0.45), FlashArgNumber(0.45), FlashArgNumber(0.3));
		m_fxSetElemScale.InvokeSelfOneArg(FlashArgNumber(0.8));
		m_fxSetYGap.InvokeSelfOneArg(FlashArgNumber(0));
	}

	function CreateGFXElement(data:SItemChangedData, out gfxDataObj:CScriptedFlashObject)
	{
		var itemNameLocale : string;
		var itemPath : string;
		var itemQuantity : string;
		var dm : CDefinitionsManagerAccessor;

		dm = theGame.GetDefinitionsManager();

		itemNameLocale = "[[" + dm.GetItemLocalisationKeyName(data.itemName) + "]]";
		itemPath = dm.GetItemIconPath(data.itemName);
		itemQuantity = "x" + data.quantity;

		gfxDataObj = m_flashValueStorage.CreateTempFlashObject();

		gfxDataObj.SetMemberFlashString("name", itemNameLocale);
		gfxDataObj.SetMemberFlashString("iconPath", itemPath);
		gfxDataObj.SetMemberFlashString("quantityText", itemQuantity);
	}

	function ProcessQueue():void
	{
		var i : int;
		var gfxDataArray : CScriptedFlashArray;
		var gfxDataObj : CScriptedFlashObject;

		gfxDataArray = m_flashValueStorage.CreateTempFlashArray();

		for(i = 0; i < m_addQueue.Size(); i+= 1)
		{
			CreateGFXElement(m_addQueue[i], gfxDataObj);
			gfxDataArray.PushBackFlashObject(gfxDataObj);
		}

		m_addQueue.Clear();
		m_flashValueStorage.SetFlashArray("hud.lootfeed.add", gfxDataArray);
	}
		
	event OnTick( timeDelta : float )
	{
		if(m_addQueue.Size() > 0)
			ProcessQueue();
	}	

	public function AddItemToQueue(item : SItemChangedData)
	{
		var i : int;
		var id : SItemUniqueId;
		var inv : CInventoryComponent;

		inv = thePlayer.inv;
		m_addQueue.PushBack(item);

		for(i = 0; i < item.ids.Size(); i+= 1)
		{
			id = item.ids[i];
		}
	}
}

function GetLootFeedHUDElement() : CR4HudModuleLootFeed
{
	var hud : CR4ScriptedHud;
	var chainModule : CR4HudModuleLootFeed;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
					
	if (hud)
	{
		chainModule = (CR4HudModuleLootFeed)hud.GetHudModule("LootFeedModule");
	}
	
	return chainModule;
}