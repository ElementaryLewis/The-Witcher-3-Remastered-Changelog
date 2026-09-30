/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MenuInitData extends CObject
{
	public var ignoreSaveSystem:bool;
	
	private var m_defaultState:name;
	
	public function getDefaultState():name
	{
		return m_defaultState;
	}
	public function setDefaultState(value:name):void
	{
		m_defaultState = value;
	}
}

class W3InventoryInitData extends W3MenuInitData
{
	public var containerNPC   : CGameplayEntity;
	public var filterTagsList : array<name>;
}

class W3MapInitData extends W3MenuInitData
{
	private var m_triggeredExitEntity			: bool;
	private var m_usedFastTravelEntity			: CEntity;
	private var m_isSailing						: bool;			default m_isSailing = false;
	
	function GetTriggeredExitEntity() : bool
	{
		return m_triggeredExitEntity;
	}
	
	function SetTriggeredExitEntity( triggeredExitEntity : bool )
	{
		m_triggeredExitEntity = triggeredExitEntity;
	}
	
	function GetUsedFastTravelEntity() : CEntity
	{
		return m_usedFastTravelEntity;
	}
	
	function SetUsedFastTravelEntity( entity : CEntity )
	{
		m_usedFastTravelEntity = entity;
	}
	
	function GetIsSailing() : bool
	{
		return m_isSailing;
	}
	
	function SetIsSailing( isSailing : bool )
	{
		m_isSailing = isSailing;
	}
}

class W3MainMenuInitData extends W3MenuInitData
{
	private var m_panelXOffset : int;
	
	public function GetPanelXOffset() : int
	{
		return m_panelXOffset;
	}
	
	public function SetPanelXOffset( value : int )
	{
		m_panelXOffset = value;
	}
}

class W3SingleMenuInitData extends W3MenuInitData
{
	public var fixedMenuName			   : name;
	public var ignoreMeditationCheck	   : bool;
	public var isBonusMeditationAvailable  : bool;
	public var unlockCraftingMenu		   : bool;
	
	private var m_blockOtherPanels		   : bool;
	
	public function GetBlockOtherPanels() : bool
	{
		return m_blockOtherPanels;
	}
	
	public function SetBlockOtherPanels( b : bool )
	{
		m_blockOtherPanels = b;
	}
}

class W3StandaloneDismantleInitData extends W3SingleMenuInitData
{
	public var m_ingredientsForMissingDecoctions		: array<name>;
}

class W3StartupMenuInitData extends W3MenuInitData
{
	public var requestPage : EStartupPageId;
	public var reopenMenu : bool;
	public var reopenMenuName : name;
	public var forceShow : bool; default forceShow = false;
}