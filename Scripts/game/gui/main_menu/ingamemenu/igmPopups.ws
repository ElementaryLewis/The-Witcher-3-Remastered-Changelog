/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ApplyLoadConfirmation extends ConfirmationPopupData
{
	public var menuRef : CR4IngameMenu;
	public var saveSlotRef : SSavegameInfo;
	protected var accepted : bool; default accepted = false;
	
	protected function OnUserAccept() : void
	{
		menuRef.LoadSaveRequested(saveSlotRef);
		accepted = true;
	}
		
	protected function OnUserDecline() : void
	{
		menuRef.disableAccountPicker = false;
		menuRef.SetIgnoreInput(false);
	}
	
	protected function ClosePopup():void
	{
		if (menuRef && !accepted)
		{
			menuRef.disableAccountPicker = false;
			menuRef.SetIgnoreInput(false);
		}
		super.ClosePopup();		
	}
}

class W3SaveGameConfirmation extends ConfirmationPopupData
{
	public var menuRef 	: CR4IngameMenu;
	public var type 	: ESaveGameType;
	public var slot		: int;
	
	protected function OnUserAccept() : void
	{
		if (menuRef)
		{
			menuRef.SetIgnoreInput(false);
		}
		menuRef.executeSave(type, slot);
	}
	
	protected function OnUserDecline() : void
	{
		if (menuRef)
		{
			menuRef.SetIgnoreInput(false);
		}
	}
	
	protected function ClosePopup():void
	{
		if (menuRef)
		{
			menuRef.SetIgnoreInput(false);
		}
		super.ClosePopup();		
	}
}

class W3NewGameConfirmation extends ConfirmationPopupData
{
	public var menuRef : CR4IngameMenu;
	
	protected function OnUserAccept() : void
	{
		menuRef.NewGameRequested();
	}
		
	protected function OnUserDecline() : void
	{
	}
	
	protected function ClosePopup():void
	{
		super.ClosePopup();		
	}
}

class W3DeleteSaveConf extends ConfirmationPopupData
{
	public var menuRef  : CR4IngameMenu;
	public var type 	: ESaveGameType;
	public var slot		: int;
	public var saveMode	: bool;
	
	protected function OnUserAccept() : void
	{
		if (menuRef)
		{
			menuRef.DeleteSave(type, slot, saveMode);
			menuRef.disableAccountPicker = false;
			menuRef.SetIgnoreInput(false);
		}
		
	}
		
	protected function OnUserDecline() : void
	{
		if (menuRef)
		{
			menuRef.disableAccountPicker = false;
			menuRef.SetIgnoreInput(false);
		}
	}
	
	protected function ClosePopup():void
	{
		if (menuRef)
		{
			menuRef.disableAccountPicker = false;
			menuRef.SetIgnoreInput(false);
		}
		super.ClosePopup();
	}
}

class W3ActionConfirmation extends ConfirmationPopupData
{
	public var menuRef : CR4IngameMenu;
	public var actionID	: int;
	
	protected function OnUserAccept() : void
	{
		menuRef.OnActionConfirmed(actionID);
	}
		
	protected function OnUserDecline() : void
	{
	}
	
	protected function ClosePopup():void
	{
		super.ClosePopup();		
	}
}

class W3DifficultyChangeConfirmation extends ConfirmationPopupData
{
	public var menuRef : CR4IngameMenu;
	public var targetDifficulty : int;
	
	protected function OnUserAccept() : void
	{
		theGame.SetDifficultyLevel(targetDifficulty);
		theGame.OnDifficultyChanged(targetDifficulty);
	}
		
	protected function OnUserDecline() : void
	{
		menuRef.CancelDifficultyChange();
	}
	
	protected function ClosePopup() : void
	{
		if (menuRef)
		{
			menuRef.CancelDifficultyChange();
		}
		super.ClosePopup();		
	}
}