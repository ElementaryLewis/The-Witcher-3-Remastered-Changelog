/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MeditationTimeInitData extends W3MenuInitData
{
	public var m_fadeInTime : float;
}

class CR4MeditationClockMenu extends CR4MenuBase
{
	private var m_fxSetBlockMeditation		 	: CScriptedFlashFunction;
	private var m_fxSetCanMeditate			 	: CScriptedFlashFunction;
	private var m_fxSetBonusMeditationTime	 	: CScriptedFlashFunction;
	private var m_fxSetGeraltBackgroundVisible	: CScriptedFlashFunction;
	private var m_fxSet24HRFormat			 	: CScriptedFlashFunction;
	private var m_fxSetCurrentTime			 	: CScriptedFlashFunction;
	private var m_fxMeditationConfirmed		 	: CScriptedFlashFunction;
	private var m_fxFadeOutGeraltBackground		: CScriptedFlashFunction;
	private var m_fxFadeInEverything		 	: CScriptedFlashFunction;
	private var m_fxMovePanelXTo		 		: CScriptedFlashFunction;	
	
	private var canMeditateWait				 	: bool;
	private var isGameTimePaused			 	: bool;

	private var m_commonMenuRef					: CR4CommonMenu;
	
	private var BONUS_MEDITATION_TIME : int;
	default BONUS_MEDITATION_TIME = 1;

	private var m_sleepMode : bool; default m_sleepMode = false;
	private var GERALT_FADE_TIME : float; default GERALT_FADE_TIME = 0.3;
	private var PANEL_MOVE_TIME : float; default PANEL_MOVE_TIME = 0.6;

	event  OnConfigUI()
	{	
		var locCode : string;
		var initData : W3SingleMenuInitData;
		var timeInitData : W3MeditationTimeInitData;
		var witcherPlayer : W3PlayerWitcher;
		witcherPlayer = GetWitcherPlayer();
		
		super.OnConfigUI();

		m_commonMenuRef = (CR4CommonMenu)m_parentMenu;
		
		witcherPlayer.MeditationClockStart(this);
		m_fxSetBlockMeditation = m_flashModule.GetMemberFlashFunction( "SetBlockMeditation" );
		m_fxSet24HRFormat = m_flashModule.GetMemberFlashFunction( "Set24HRFormat" );
		m_fxSetGeraltBackgroundVisible = m_flashModule.GetMemberFlashFunction( "setGeraltBackgroundVisible" );
		m_fxSetBonusMeditationTime = m_flashModule.GetMemberFlashFunction( "setBonusMeditationTime" );
		m_fxSetCurrentTime  = m_flashModule.GetMemberFlashFunction( "setCurrentTime" );
		m_fxMeditationConfirmed = m_flashModule.GetMemberFlashFunction( "meditationConfirmed" );
		m_fxFadeOutGeraltBackground = m_flashModule.GetMemberFlashFunction( "fadeOutGeraltBackground" );
		m_fxFadeInEverything = m_flashModule.GetMemberFlashFunction( "fadeInEverything" );
		m_fxMovePanelXTo = m_flashModule.GetMemberFlashFunction( "movePanelXTo" );
		
		m_fxSetBonusMeditationTime.InvokeSelfOneArg( FlashArgInt( BONUS_MEDITATION_TIME ) );
		SendCurrentTimeToAS();
		
		
		
		theGame.Unpause("menus");		
		
		initData = (W3SingleMenuInitData)GetMenuInitData();

		if(initData)
			m_sleepMode = true;

		if(!initData)
		{
			timeInitData = (W3MeditationTimeInitData)GetMenuInitData();

			if(timeInitData)
			{
				m_fxFadeInEverything.InvokeSelfOneArg(FlashArgNumber(timeInitData.m_fadeInTime)); 
			}
		}
		
		if( initData && initData.isBonusMeditationAvailable )
		{
			SetMeditationBonuses();
		}
		
		UpdateMeditationAccess();
		
		if (canMeditateWait) 
		{
			if (m_commonMenuRef)
			{
				
				

				
				if(m_commonMenuRef.GetMeditationMode() && !m_sleepMode)
					MoveMeditationPanel(0);
			}
			
			m_fxSetGeraltBackgroundVisible.InvokeSelfOneArg(FlashArgBool(false)); 
		}
		
		m_fxSetBlockMeditation.InvokeSelfOneArg( FlashArgBool( !canMeditateWait ) );
		
		
		
		locCode = GetCurrentTextLocCode();
		m_fxSet24HRFormat.InvokeSelfOneArg(FlashArgBool(locCode != "EN"));
		
		
		if(GameplayFactsQuerySum("GamePausedNotByUI") > 0 && !thePlayer.IsInCombat())
		{
			witcherPlayer.MeditationRestoring(0);				
		}	
		
		
		
			
		

		witcherPlayer.SetMeditationAnimSpeedCauserId( thePlayer.SetAnimationSpeedMultiplier( 10.f, witcherPlayer.GetMeditationAnimSpeedCauserId() ) );
		theGame.SetTimeScale( 0.1f, theGame.GetTimescaleSource( ETS_Meditation ), theGame.GetTimescalePriority( ETS_Meditation ), false, true );
	}

	private function UpdateMeditationAccess():void
	{
		var initData : W3SingleMenuInitData;
		initData = (W3SingleMenuInitData)GetMenuInitData();

		if(GetWitcherPlayer().CanMeditate() && GetWitcherPlayer().CanMeditateWait(true) || ( initData && initData.ignoreMeditationCheck ) )
		{
			canMeditateWait = true;
			isGameTimePaused = false;			
		}
		else if(theGame.IsGameTimePaused())
		{
			canMeditateWait = false;
			isGameTimePaused = true;
		}
	}
	
	event  OnClosingMenu()
	{
		var medd : W3PlayerWitcherStateMeditation;
		var witcherPlayer : W3PlayerWitcher;
		witcherPlayer = GetWitcherPlayer();

		theGame.GetGuiManager().SendCustomUIEvent( 'ClosedMeditationClockMenu' );
		
		if (m_commonMenuRef)
		{
			m_commonMenuRef.SetSkipFadeOnClose( true );
			m_commonMenuRef.SetMeditationMode(false, 0.2);

			if ( !m_commonMenuRef.m_had_meditation )	
			{
				medd = (W3PlayerWitcherStateMeditation)thePlayer.GetCurrentState();
				if ( medd )
				{
					if ( !medd.IsSitting() )
						m_commonMenuRef.StopMeditation();
				}
				else
				{
					m_commonMenuRef.StopMeditation();
				}

				theGame.Pause("menus");
			}
			
			if( m_commonMenuRef.GetIsPlayerMeditatingInBed() )
			{
				witcherPlayer.ManageSleeping();
			}
		}
		
		witcherPlayer.MeditationClockStop();

		witcherPlayer.ResetMeditationAnimSpeed();
		theGame.RemoveTimeScale( theGame.GetTimescaleSource( ETS_Meditation ) );
	}
	
	event  OnCloseMenu()
	{
		if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			MeditatingEnd();
		}
		
		GetWitcherPlayer().ResetMeditationAnimSpeed();
		theGame.RemoveAllTimeScales(); 

		
		CloseMenu();
		
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
	}
	
	private function SetMeditationBonuses():void
	{
		var defManager	: CDefinitionsManagerAccessor;
		var flashObject	: CScriptedFlashObject;
		var flashArray	: CScriptedFlashArray;
		var bedEntity	: W3WitcherBed;
		var bedLevel	: int;
		var min, max    : SAbilityAttributeValue;
		var arrStr		: array< string >;
		var abilityVal  : float;
		var durationStr : string;
		var bedLevelString	: string;
		
		defManager = theGame.GetDefinitionsManager();
		bedEntity = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
		flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		
		
		if( bedEntity )
		{
			flashObject = m_flashValueStorage.CreateTempFlashObject();
			
			bedLevel = bedEntity.GetBedLevel();
			
			if( bedLevel > 0 )
			{
				flashObject.SetMemberFlashBool( "available",  true );
			}
			else
			{
				flashObject.SetMemberFlashBool( "available",  false );
				bedLevel = 1;
			}
			
			bedLevelString = "bed_level_" + IntToString( bedLevel );
			
			arrStr.PushBack( IntToString( bedLevel ) );
			flashObject.SetMemberFlashString( "title", GetLocStringByKeyExtWithParams( "panel_title_buff_bed",,, arrStr ) + " " + GetLocStringByKeyExt( bedLevelString ) );
			arrStr.Clear();
			
			defManager.GetAbilityAttributeValue( 'WellRestedEffect', 'vitality', min, max);
			abilityVal = CalculateAttributeValue( min );
			if( bedLevel > 1 )
				abilityVal *= 2;
			arrStr.PushBack( FloatToStringPrec( abilityVal, 0 ) );
			flashObject.SetMemberFlashString( "description", GetLocStringByKeyExtWithParams( "panel_buff_bed_descr",,, arrStr ) );
			arrStr.Clear();
			
			defManager.GetAbilityAttributeValue( 'WellRestedEffect', 'duration', min, max);
			abilityVal = CalculateAttributeValue( min );
			if( bedLevel == 2 )
				abilityVal *= 2;
			arrStr.PushBack( FloatToString( abilityVal / 60 ) );
			durationStr = GetLocStringByKeyExtWithParams( "panel_buff_duration",,, arrStr );
			flashObject.SetMemberFlashString( "duration", durationStr );
			arrStr.Clear();
			
			flashObject.SetMemberFlashString( "type", "bed" );
			flashArray.PushBackFlashObject( flashObject );
		}
		
		
		
		flashObject = m_flashValueStorage.CreateTempFlashObject();
		
		defManager.GetAbilityAttributeValue( 'BookshelfBuffEffect', 'nonhuman_exp_bonus_when_fatal', min, max);
		abilityVal = CalculateAttributeValue( min );
		arrStr.PushBack( FloatToStringPrec( ( abilityVal * 100 ), 0 ) );
		flashObject.SetMemberFlashString( "description", GetLocStringByKeyExtWithParams( "panel_buff_bookshelf_descr",,, arrStr ) );
		arrStr.Clear();
		
		defManager.GetAbilityAttributeValue( 'BookshelfBuffEffect', 'duration', min, max);
		abilityVal = CalculateAttributeValue( min );
		arrStr.PushBack( FloatToString( abilityVal / 60 ) );
		durationStr = GetLocStringByKeyExtWithParams( "panel_buff_duration",,, arrStr );
		flashObject.SetMemberFlashString( "duration", durationStr );
		arrStr.Clear();
		
		flashObject.SetMemberFlashString( "title", GetLocStringByKeyExt( "panel_title_buff_bookshelf" ) );
		flashObject.SetMemberFlashString( "type", "bookshelf" );
		flashObject.SetMemberFlashBool( "available",  true );
		
		flashArray.PushBackFlashObject( flashObject );
		
		
		
		flashObject = m_flashValueStorage.CreateTempFlashObject();
		flashObject.SetMemberFlashString( "title", GetLocStringByKeyExt( "panel_title_buff_alchemy_table" ) );
		flashObject.SetMemberFlashString( "duration", "" );
		flashObject.SetMemberFlashString( "type", "alchemytable" );
		flashArray.PushBackFlashObject( flashObject );
		
		arrStr.PushBack( IntToString( theGame.params.QUANTITY_INCREASED_BY_ALCHEMY_TABLE ) );
		flashObject.SetMemberFlashString( "description", GetLocStringByKeyExtWithParams( "panel_buff_alchemy_table_descr",,, arrStr ) );
		arrStr.Clear();
		
		if( FactsDoesExist( "AlchemyTableExists" ) )
		{
			flashObject.SetMemberFlashBool( "available",  true );
		}
		else
		{
			flashObject.SetMemberFlashBool( "available",  false );
		}
		
		
		
		flashObject = m_flashValueStorage.CreateTempFlashObject();
		flashObject.SetMemberFlashString( "title", GetLocStringByKeyExt( "panel_title_buff_stables" ) );
		flashObject.SetMemberFlashString( "type", "stable" );
		
		defManager.GetAbilityAttributeValue( 'HorseStableBuff', 'stamina', min, max );
		abilityVal = CalculateAttributeValue( min );
		arrStr.PushBack( FloatToStringPrec( abilityVal, 0 ) );
		flashObject.SetMemberFlashString( "description", GetLocStringByKeyExtWithParams( "panel_buff_stables_descr",,,  arrStr ) );
		arrStr.Clear();
		
		defManager.GetAbilityAttributeValue( 'HorseStableBuffEffect', 'duration', min, max );
		abilityVal = CalculateAttributeValue( min );
		arrStr.PushBack( FloatToString( abilityVal / 60 ) );
		durationStr = GetLocStringByKeyExtWithParams( "panel_buff_duration",,, arrStr );
		flashObject.SetMemberFlashString( "duration", durationStr );
		arrStr.Clear();
		
		if( FactsDoesExist( "StablesExists" ) )
		{
			flashObject.SetMemberFlashBool( "available",  true );
		}
		else
		{
			flashObject.SetMemberFlashBool( "available",  false );
		}
		
		flashArray.PushBackFlashObject( flashObject );
		
		
		
		m_flashValueStorage.SetFlashArray( "meditation.bonus", flashArray );
	}

	public function MovePanelXTo(x:float, time:float)
	{
		m_fxMovePanelXTo.InvokeSelfTwoArgs(FlashArgNumber(x), FlashArgNumber(time));
	}

	public function MoveMeditationPanel(time : float)
	{
		MovePanelXTo(682 - 1920 / 6, time); 
	}
	
	function SetButtons()
	{
		AddInputBinding("panel_button_common_exit", "escape-gamepad_B", -1);
		super.SetButtons();
	}
	
	public function UpdateCurrentHours( ):void
	{
		var timeHours : int = GetCurrentDayTime( "hours" );
		var	timeMinutes : int = GetCurrentDayTime( "minutes" );
		m_flashValueStorage.SetFlashInt( "meditation.clock.hours.update", timeHours );
		m_flashValueStorage.SetFlashInt( "meditation.clock.minutes", timeMinutes );
	}
	
	public function SendCurrentTimeToAS():void
	{
		var  timeHours : int = GetCurrentDayTime( "hours" );
		var  timeMinutes : int = GetCurrentDayTime( "minutes" );
		
		
		m_fxSetCurrentTime.InvokeSelfTwoArgs( FlashArgInt(timeHours), FlashArgInt(timeMinutes) );
	}
	
	event  OnMeditate( dayTime : float )
	{
		var medd : W3PlayerWitcherStateMeditation;
		
		if(isGameTimePaused)
		{
			theGame.Unpause("MeditationLock");
			
			UpdateMeditationAccess();
			if(!canMeditateWait)
				theGame.Pause("MeditationLock");
		}

		if (!canMeditateWait)
		{
			ShowDisallowedNotification();			
		}
		else
		{	
			m_fxMeditationConfirmed.InvokeSelf();

			if (theGame.IsPaused())
			{
				theGame.Unpause("menus");
			}
			
			if( GetWitcherPlayer().Meditate() )
			{
				OnPlaySoundEvent( "gui_meditation_start" );
				
				LogChannel('CLOCK',"	** OnMeditate ** ");
				if(dayTime == GameTimeHours(theGame.GetGameTime()))
					return false;

				
				medd = (W3PlayerWitcherStateMeditation)thePlayer.GetCurrentState();
				medd.MeditationWait(CeilF(dayTime), m_commonMenuRef.m_had_meditation ? 0.f : 1.f);	
				
				
				StartWaiting();
				if(!m_sleepMode)
				{
					m_fxFadeOutGeraltBackground.InvokeSelfOneArg(FlashArgNumber(GERALT_FADE_TIME));
					MoveMeditationPanel(PANEL_MOVE_TIME);
				}
				m_commonMenuRef.SetMeditationMode(true, 1, m_sleepMode);
			}
		}
	} 
	
	event  OnStopMeditate()
	{
		var waitt : W3PlayerWitcherStateMeditationWaiting;
		var medd : W3PlayerWitcherStateMeditation;
		var currentStateName : name;
		currentStateName = thePlayer.GetCurrentStateName();
	
		if ( currentStateName == 'Meditation' )
		{
			medd = (W3PlayerWitcherStateMeditation)thePlayer.GetCurrentState();
			if ( medd )
				medd.StopRequested( true );
		}
		else if ( currentStateName == 'MeditationWaiting' )
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)thePlayer.GetCurrentState();
			if ( waitt )
				waitt.RequestWaitStop();
		}
		
		MeditatingEnd();
	}
	
	function GetCurrentDayTime( type : string ) : int 
	{
		var gameTime : GameTime = theGame.GetGameTime();
		var currentDays : int;
		var currentHours : int;
		var currentMinutes : int;
		var currentTime : int;
		
		switch( type )
		{
			case "days" :
			{
				currentTime = GameTimeDays( gameTime );
				break;
			}
			case "hours" :
			{
				currentDays = GameTimeDays( gameTime );
				currentHours = GameTimeHours( gameTime );
				currentTime = currentHours ;
				break;
			}
			case "minutes" :
			{
				currentDays = GameTimeDays( gameTime );
				currentHours = GameTimeHours( gameTime );
				currentMinutes = GameTimeMinutes( gameTime );
				currentTime = currentMinutes;
				break;
			}	
		}
		return currentTime;
	}
	
	
	
	
	public function StartWaiting():void
	{
		theGame.GetCityLightManager().SetUpdateEnabled( false );
		m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", true );
		m_flashValueStorage.SetFlashBool( "meditation.clock.block.easy", true );
		SetMenuNavigationEnabled(false);
	}
	
	public function StopWaiting():void
	{
		m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", false );
		SetMenuNavigationEnabled(true);
	}
	
	function MeditatingEnd()
	{
		theGame.GetCityLightManager().ForceUpdate();
		theGame.GetCityLightManager().SetUpdateEnabled( true );
		m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", false );
		SetMenuNavigationEnabled(true);
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}
	
	private final function ShowDisallowedNotification()
	{		
		if(thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
		}
		else
		{
			showNotification(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ));
		}
		
		OnPlaySoundEvent("gui_global_denied");
	}
}