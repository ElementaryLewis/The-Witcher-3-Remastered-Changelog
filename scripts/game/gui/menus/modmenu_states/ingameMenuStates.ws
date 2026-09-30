/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class CR4IngameMenuModStates extends CR4IngameMenu
{
	public var m_menuReference	: CR4IngameMenu;
	public var m_mods : array< SModioModID >;
	public var m_missing : bool; default m_missing = true;
	public var m_startup : bool; default m_startup = false;
	public var m_continue : bool; default m_continue = false;
	public var m_failed : bool; default m_failed = false;
	public var m_link : ETermsLinkType;
	protected var m_hasInternetConnection : bool; default m_hasInternetConnection = false;
	protected var m_isConnectionCheckActive : bool; default m_isConnectionCheckActive = false;
	
	default autoState = 'NullState';
	
	public function OnNullState()
	{
		GotoState('NullState');
	}
	
	public function SetRef(ref : CR4IngameMenu)
	{
		m_menuReference = ref;
	}
	
	public function GetMissingModList( mods : array< SModioModID >, continu : bool )
	{
		m_mods = mods;
		m_missing = true;
		m_startup = false;
		m_continue = continu;
		GotoState('GetModList');
	}
	
	public function GetVersionModList( mods : array< SModioModID >, continu : bool )
	{
		m_mods = mods;
		m_missing = false;
		m_startup = false;
		m_continue = continu;
		GotoState('GetModList');
	}
	
	public function GetStartupModList( mods : array< SModioModID > )
	{
		m_mods = mods;
		m_missing = false;
		m_startup = true;
		m_continue = false;
		GotoState('GetModList');
	}
	
	public function GetFailedModList( mods : array< SModioModID > )
	{
		m_mods = mods;
		m_missing = false;
		m_startup = true;
		m_continue = false;
		m_failed = true;
		GotoState('GetModList');
	}
	
	public function OnLaunchModMenu()
	{
		GotoState('LaunchModMenu');
	}
	
	public function OnModTermsAccepted()
	{
		GotoState('ModTermsAccepted');
	}
	
	public function OnOpenLink(link : ETermsLinkType)
	{
		m_link = link;
		GotoState('OpenLink');
	}
	
	public function TryRequestSubMenu( menuName : name, optional pData : W3PopupData) : void
	{
		var rootMenu : CR4Menu;
		var ingameMenu : CR4IngameMenu;
		rootMenu = theGame.GetGuiManager().GetRootMenu();
		if ( rootMenu )
		{
			ingameMenu = (CR4IngameMenu)rootMenu.GetSubMenu();
			if ( ingameMenu )
			{
				ingameMenu.OnRequestSubMenu( menuName, pData );
			}
		}
		else
		{
			theGame.RequestMenu( menuName, pData );
		}
	}

	public function OnNetworkConnectionEnsureFinished(hasConnection : bool)
	{
		
		m_hasInternetConnection = hasConnection; 

		
		m_isConnectionCheckActive = false;
	}

	public function StartInternetConnectionCheck()
	{
		m_isConnectionCheckActive = true; 
		theGame.EnsureInternetConnection();
	}
}

state GetModList in CR4IngameMenuModStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
		GetModList();
	}
	
	entry function GetModList():void
	{
		var l_modids : array< SModioModID >;
		var l_mods	: array < SModioModData >;
		var l_currentId : SModioModID;
		var l_currentMod : SModioModData;
		var i : int;
		var ugcAllowed : bool;
		var modioAvailable : bool;
		
		modioAvailable = theGame.GetModHandlerSystem().IsModioAvailableLatent();
		ugcAllowed = theGame.GetModHandlerSystem().CheckPlatformUGCAllowed( false );
		
		if(modioAvailable){
			l_modids = parent.m_mods;
			for(i = 0; i < l_modids.Size(); i+= 1)
			{
				l_currentId = l_modids[i];
				l_currentMod = theGame.GetModHandlerSystem().GetRemoteModDataByID(l_currentId);
				l_mods.PushBack(l_currentMod);
			}
		
			if ( parent.m_failed )
			{
				
				parent.m_menuReference.CreateModLoadFailedPopup(
					l_mods, 
					ugcAllowed);
			}
			
			else if ( parent.m_missing )
			{
				
				parent.m_menuReference.CreateModVerificationPopup(
					l_mods, 
					parent.m_missing, 
					parent.m_startup, 
					parent.m_continue, 
					ugcAllowed);
			}
		}
		else 
		{
			theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("error_modio_connection"));
		}
		
		parent.OnNullState();
	}
}

state NullState in CR4IngameMenuModStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
	}
}

state LaunchModMenu in CR4IngameMenuModStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
		RunFlow();
	}
	
	entry function RunFlow()
	{		
		var ugcAllowed : bool;
		var termsAcceptedValue : bool;
		var termsError : bool;
		var authenticateSuccess : bool;
		var hasInternetConnection : bool;
		var manager : CR4GuiManager;

		
		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			parent.StartInternetConnectionCheck();

			
			while( parent.m_isConnectionCheckActive )
			{
				Sleep(0.1f);
			}

			hasInternetConnection = parent.m_hasInternetConnection;
			if ( hasInternetConnection == false)
			{
				OnModioNetworkError();
				return;
			}
		}
		
		ugcAllowed = theGame.GetModHandlerSystem().CheckPlatformUGCAllowed( true );
		if(!ugcAllowed)
		{
			OnModioNetworkError();
			return;
		}

		if(theGame.GetModHandlerSystem().IsLoggedInCDPR())
		{
			authenticateSuccess = theGame.GetModHandlerSystem().AuthenticateUserCDPR(false, termsError);
			
			if(authenticateSuccess)
			{
				theGame.GetModHandlerSystem().SetModManagementEnabled(true);
				parent.TryRequestSubMenu('ModMenu');
			}
			else
			{
				if(termsError)
				{
					if(parent.m_menuReference)
						parent.m_menuReference.OpenModTermsPopup();
				}
				else
				{
					OnModioNetworkError();
					return;
				}
			}
		}
		else
		{
			parent.m_menuReference.ShowStartupLoginPage(true);
		}

		parent.OnNullState();
	}
	
	private function OnModioNetworkError()
	{
		
		
		parent.OnModioNetworkError();
		parent.OnNullState();
	}
}

state ModTermsAccepted in CR4IngameMenuModStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
		OnContinueProcess();
	}
	
	entry function OnContinueProcess():void
	{
		var termsAcceptedValue : bool;
		var termsError : bool;
		var authenticateSuccess : bool;
		
		authenticateSuccess = theGame.GetModHandlerSystem().AuthenticateUserCDPR(true, termsError);
			
		if(authenticateSuccess)
		{
			theGame.GetModHandlerSystem().SetModManagementEnabled(true);
			parent.TryRequestSubMenu('ModMenu');
		}
		else
		{
			if(termsError)
			{
				if(parent.m_menuReference)
					parent.m_menuReference.OpenModTermsPopup();
			}
			else
			{
				theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("ui_cloud_gog_generic_error"));
			}
		}
		
		parent.OnNullState();
	}
}

state OpenLink in CR4IngameMenuModStates
{
	event OnEnterState(prevStateName : name)
	{
		super.OnEnterState( prevStateName );
		OnTryOpenLink();
	}
	
	entry function OnTryOpenLink():void
	{
		theGame.GetModHandlerSystem().OpenLinkInBrowserLatent(parent.m_link);
		
		parent.OnNullState();
	}
}