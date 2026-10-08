/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4TutorialSystem extends IGameSystem
{
	import  saved var needsTickEvent : bool;								
	private 	  var currentlyShownTutorialIndex : int;					
	private saved var queuedTutorials : array<STutorialMessage>;			
	private 	  var m_tutorialHintDataObj:W3TutorialPopupData;			
	private 	  var delayedQueuedTutorialShowTime : float;				
	private 	  var hasDelayedTutorial : bool;							
	private		  var showNextHintInstantly : bool;							
	private 	  var enableMenuRestrictions : bool;						
	private 	  var allowedMenusList : array<name>;						
	public saved  var uiHandler : W3TutorialManagerUIHandler;				
	private saved var seenTutorials : array<name>;							
	private 	  var attackProcessed : bool;								
	private 	  var testData : W3TutorialPopupData;						
	private saved var hudMessage : name;									
	
	private saved var invisibleTutorialHint : name;							
	private saved var wereMessagesEnabled : bool;							
	
	private const var COMBAT_HINT_POS_X, COMBAT_HINT_POS_Y : float;			
	private const var DIALOG_HINT_POS_X, DIALOG_HINT_POS_Y : float;			
	private const var UI_HINT_POS_X, UI_HINT_POS_Y : float;					
	private const var HINT_SHOW_DELAY : float;								
	private const var HINT_DURATION_LONG, HINT_DURATION_SHORT : float;		
	
		default COMBAT_HINT_POS_X = 0;
		default COMBAT_HINT_POS_Y = 0;
		default DIALOG_HINT_POS_X = 0.f;
		default DIALOG_HINT_POS_Y = 0.55f;
		default UI_HINT_POS_X = 0.6;
		default UI_HINT_POS_Y = 0.7;
		default currentlyShownTutorialIndex = -1;		
		default HINT_SHOW_DELAY = 1;
		default needsTickEvent = true;
		default HINT_DURATION_SHORT = 7;
		default HINT_DURATION_LONG = 10;

	public var switchTutorialManager : SwitchTutorialManager;
	
	
	
	public function AreMessagesEnabled() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'HudTutorialEnabled') == "true";
	}
	
	
	
	public function IsRunning() : bool
	{
		return FactsQuerySum("tutorial_system_is_running");
	}

	public function GetActiveTutorialIndex() : int
	{
		return currentlyShownTutorialIndex;
	}

	public function HasActiveTutorial() : bool
	{
		return currentlyShownTutorialIndex >= 0;
	}
	
	public function IsOnTickOptimalizationEnabled() : bool
	{
		return !needsTickEvent;
	}
		
	public function IncreaseDodges()					{FactsAdd("tutorial_dodges_cnt");}
	public function IncreaseRolls()						{FactsAdd("tutorial_rolls_cnt");}
	public function IncreaseCounters()					{FactsAdd("tutorial_counters_cnt");}	
	public function IncreaseParries()					{FactsAdd("tutorial_parries_cnt");}
		
	event OnGameStart( restored : bool ) 
	{
		ClearNonSavedVars();
		
		
		if(!IsRunning())
			ClearSavedVars();
		
		if(restored)
		{
			
			if(!IsRunning() || FactsQuerySum("NewGamePlus") > 0)
				needsTickEvent = false;
				
			uiHandler.OnLoad();
		}
		
		switchTutorialManager = new SwitchTutorialManager in this;
		switchTutorialManager.tutorialSystem = this;
		switchTutorialManager.UpdateDualGripStyleFact();

		attackProcessed = false;
		
		
		
		ActivateJournalEntry('TutorialJournalSignCast');
		ActivateJournalEntry('TutorialJournalHeavyAttacks');
		ActivateJournalEntry('TutorialHorseSummon');
		ActivateJournalEntry('TutorialJournalLightAttacks');
		ActivateJournalEntry('TutorialJournalSpecialAttacks');		
		ActivateJournalEntry('TutorialAdrenaline');
		
		
		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			ActivateJournalEntry('TutorialJournalGyro');
			ActivateJournalEntry('TutorialJournalMouser');
			ActivateJournalEntry('TutorialJournalTouch');
			ActivateJournalEntry('TutorialJournalMotionPatternDetails');
			ActivateJournalEntry('TutorialJournalMotionPatternBombs');
			ActivateJournalEntry('TutorialJournalMotionPatternSignCast');
			ActivateJournalEntry('TutorialJournalMotionPatternHorseAcceleration');
			ActivateJournalEntry('TutorialJournalMotionPatternHorseStop');
			ActivateJournalEntry('TutorialJournalMotionPatternHorseSummon');
			ActivateJournalEntry('TutorialJournalMotionPatternPotion1');
			ActivateJournalEntry('TutorialJournalMotionPatternPotion2');
			ActivateJournalEntry('TutorialJournalMotionPatternCrossbow');
		}

		
		if ( theGame.IsNewGameInStandaloneDLCMode() && theGame.GetTutorialSystem().AreMessagesEnabled() )
		{
			TutorialScript('start', '');
			TutorialScript('alchemy', '');
			TutorialScript('inventory', '');
			TutorialScript('journal', '');
			TutorialScript('fast_travel', '');
			TutorialScript('meditationWait', '');
		}
	}
	
	public final function ClearSavedVars()
	{
		needsTickEvent = true;
		queuedTutorials.Clear();
		uiHandler = NULL;
		seenTutorials.Clear();
		invisibleTutorialHint = '';
		wereMessagesEnabled = false;
		hudMessage = '';
	}
	
	public final function ClearNonSavedVars()
	{
		currentlyShownTutorialIndex = -1;
		delayedQueuedTutorialShowTime = 0;
		hasDelayedTutorial = false;
		showNextHintInstantly = false;
		enableMenuRestrictions = false;
		allowedMenusList.Clear();
		attackProcessed = false;
		m_tutorialHintDataObj = NULL;
		testData = NULL;
	}
	
	
	public function TutorialRestart()	
	{
		if(IsRunning())
			return;
			
		ClearSavedVars();
		
		
		thePlayer.CreateTutorialInput();
		
		wereMessagesEnabled = AreMessagesEnabled();
		uiHandler = new W3TutorialManagerUIHandler in this;
		
		
		MarkMessageAsSeen('TutorialDialog');
		MarkMessageAsSeen('TutorialContainers');
		MarkMessageAsSeen('TutorialLootWindow');
		MarkMessageAsSeen('TutorialHorseStop');
		MarkMessageAsSeen('TutorialQuestBoard');
		MarkMessageAsSeen('TutorialCiriTaunt');
		MarkMessageAsSeen('TutorialWrongSwordSteel');
		MarkMessageAsSeen('TutorialWrongSwordSilver');
		MarkMessageAsSeen('TutorialCampfire');
		MarkMessageAsSeen('TutorialPotionAmmo');
		MarkMessageAsSeen('TutorialOilAmmo');
		
		FactsSet("tutorial_system_is_running", 1);	
	}
	
	
	public function TutorialStart(removeTestingSkillsAndItems : bool)
	{
		var dm : CDefinitionsManagerAccessor;
		var i : int;
		var skill : SSimpleSkill;
		var abs : array<name>;
		var witcher : W3PlayerWitcher;
		
		if(IsRunning())
			return;
			
		ClearSavedVars();
				
		wereMessagesEnabled = AreMessagesEnabled();
		uiHandler = new W3TutorialManagerUIHandler in this;
		
		thePlayer.CreateTutorialInput();		
		FactsAdd('tutorial_starting_level', GetWitcherPlayer().GetLevel());
		
		if(removeTestingSkillsAndItems)
		{
			
			dm = theGame.GetDefinitionsManager();
			dm.GetContainedAbilities('GeraltSkills_Testing', abs);
			
			
			witcher = GetWitcherPlayer();
			skill.level = 0;
			for(i=0; i<abs.Size(); i+=1)
			{
				skill.skillType = SkillNameToEnum(abs[i]);
				if(skill.skillType != S_SUndefined)
				{
					witcher.RemoveTemporarySkill(skill);
				}
			}						
			
			
			thePlayer.AddTimer('Debug_RemoveTestingItems', 0.0001, true);
		}
		
		
		MarkMessageAsSeen('TutorialDialog');
		MarkMessageAsSeen('TutorialContainers');
		MarkMessageAsSeen('TutorialLootWindow');
		MarkMessageAsSeen('TutorialHorseStop');
		MarkMessageAsSeen('TutorialQuestBoard');
		MarkMessageAsSeen('TutorialCiriTaunt');
		MarkMessageAsSeen('TutorialWrongSwordSteel');
		MarkMessageAsSeen('TutorialWrongSwordSilver');
		MarkMessageAsSeen('TutorialCampfire');
		MarkMessageAsSeen('TutorialPotionAmmo');
		MarkMessageAsSeen('TutorialOilAmmo');
		
		FactsSet("tutorial_system_is_running", 1);		
	}
	
	public function TutorialFinish()
	{
		thePlayer.CreateInput();
		FactsSet("tutorial_system_is_running", 0);
	}

	
	public function HasSeenTutorial(tutorialScriptTag : name) : bool
	{
		return seenTutorials.Contains(tutorialScriptTag);		
	}
	
	
	public function DisplayTutorial(tut : STutorialMessage)
	{
		var i : int;
		
		if(!IsRunning())
			return;
		
		
		for(i=0; i<queuedTutorials.Size(); i+=1)
		{
			if(queuedTutorials[i].tutorialScriptTag == tut.tutorialScriptTag)
			{
				return;
			}
		}
		
		
		if(!AreMessagesEnabled() && tut.type == ETMT_Message)
		{
			
			if(tut.markAsSeenOnShow)
				MarkMessageAsSeen(tut.tutorialScriptTag);
				
			return;
		}

		if(tut.tutorialScriptTag == 'PlaystyleDualGrip')
		{
			FactsAdd("switch_dual_grip_style", 0);
		}

		
		if(tut.forceToQueueFront && queuedTutorials.Size() > 0)
		{
			
			HideTutorialHint('', true, true);
			queuedTutorials.Insert(0, tut);
			
			if(CanShowTutorial(tut.canBeShownInDialogs, tut.canBeShownInMenus))
				SelectAndDisplayTutorial(tut);
		}
		else
		{
			
			queuedTutorials.PushBack(tut);
			
			
			if(queuedTutorials.Size() == 1 && CanShowTutorial(tut.canBeShownInDialogs, tut.canBeShownInMenus))
				SelectAndDisplayTutorial(tut);
		}
	}
	
	
	private function CanShowTutorial(canBeShownInDialogs : bool, canBeShownInMenus : bool) : bool
	{		
		if ( theGame.GetPhotomodeEnabled() )
			return false;

		if(!canBeShownInDialogs && theGame.IsDialogOrCutscenePlaying())
			return false;
			
		if(!canBeShownInMenus && theGame.GetGuiManager().IsAnyMenu())
			return false;
			
		if(!thePlayer.IsAlive())
			return false;
			
		if ( theGame.IsBlackscreen() || theGame.IsFading() )
		{
			return false;
		}
		
		if(FactsQuerySum("NewGamePlus") > 0 && FactsQuerySum("NewGamePlusForceTutorialsOn") <= 0)
			return false;
			
		return currentlyShownTutorialIndex < 0;
	}
	
	
	
	event OnTick( dt : float )
	{
		var dbg_launchedTutorial : bool;
		var i : int;
		var temp : STutorialMessage;
		
		
		ProcessHUDMessage();
		
		
		if(theGame.GetGuiManager().IsAnyMenu() && queuedTutorials.Size() > 0 && m_tutorialHintDataObj)
		{
			
			if(!queuedTutorials[0].canBeShownInMenus)
			{
				
				HideTutorialHint('', true, true);
			}
		}
	
		
		if(wereMessagesEnabled && !AreMessagesEnabled())
		{
			
			if(queuedTutorials[0].hintDurationType == ETHDT_Infinite)
				HideTutorialHint('', true, true);
			else
				HideTutorialHint('', true);
		}
		if(wereMessagesEnabled != AreMessagesEnabled())
		{
			wereMessagesEnabled = !wereMessagesEnabled;
		}
		
		if(hasDelayedTutorial)
		{
			if(delayedQueuedTutorialShowTime <= 0)
			{
				if(queuedTutorials.Size() > 0)	
				{
					if(CanShowTutorial(queuedTutorials[0].canBeShownInDialogs, queuedTutorials[0].canBeShownInMenus))
					{
						DelayedQueuedTutorialShow();
						dbg_launchedTutorial = true;
					}
				}
				hasDelayedTutorial = false;
			}
			else
			{
				delayedQueuedTutorialShowTime -= dt;
			}
		}
		else
		{
			
			for(i=0; i<queuedTutorials.Size(); i+=1)
			{
				if(CanShowTutorial(queuedTutorials[i].canBeShownInDialogs, queuedTutorials[i].canBeShownInMenus))
				{
					
					if(showNextHintInstantly)
						delayedQueuedTutorialShowTime = 0;
					else
						delayedQueuedTutorialShowTime = HINT_SHOW_DELAY;
						
					hasDelayedTutorial = true;

					
					if(i != 0)
					{
						temp = queuedTutorials[i];
						queuedTutorials.Insert(0, temp);
						queuedTutorials.Erase(i+1);
					}
					break;
				}
			}
		}

		if(queuedTutorials.Size() > 0 && wereMessagesEnabled && queuedTutorials[0].hintCloseOnFactExist != "")
		{
			if(FactsQueryLatestValue( queuedTutorials[0].hintCloseOnFactExist ) > 0)
			{	
				HideTutorialHint(queuedTutorials[0].tutorialScriptTag);
			}
		}

		
		if(theGame.GetPlatform() == Platform_Switch2_Ounce
		 	&& queuedTutorials.Size() > 0 
		 	&& wereMessagesEnabled )
		{
			if( queuedTutorials[0].tutorialScriptTag == 'TutorialCrossbowMotionControls' 
				||queuedTutorials[0].tutorialScriptTag == 'TutorialPotionEquippedPrimaryMotionControls'
				||queuedTutorials[0].tutorialScriptTag == 'TutorialPotionEquippedSecondaryMotionControls'
				||queuedTutorials[0].tutorialScriptTag == 'TutorialHorseSummonMotionControls'
				||queuedTutorials[0].tutorialScriptTag == 'TutorialHorseSpeed2MotionControls'
				||queuedTutorials[0].tutorialScriptTag == 'TutorialHorseStopMotionControls')
			{
				if(FactsQueryLatestValue( "switch_dual_grip_style" ) == 0)
				{
					HideTutorialHint(queuedTutorials[0].tutorialScriptTag);
					switchTutorialManager.inMotionPatternTutorial = false;
				}
			}
		}

		
		if(thePlayer.IsThreatened() && ShouldProcessTutorial('TutorialDodge'))
		{
			ProcessDodges();			
		}
		
		if(thePlayer.IsThreatened() && ShouldProcessTutorial('TutorialRoll'))
		{
			ProcessRolls();			
		}
	}
	
	public final function OnInputDeviceChanged()
	{
		if(queuedTutorials.Size() > 0 && currentlyShownTutorialIndex >= 0)
		{
			if(FactsQuerySum("nge_showing_alt_sign_casting_tut") == 0 )	
				ReloadMessageOnInputChange( theInput.LastUsedGamepad(), true );			
		}
	}
		
	private final function ProcessDodges()
	{
		var ves : CNewNPC;
		
		ves = theGame.GetNPCByTag('vesemir');
		if(!ves)
			return;
			
		if(ves.IsAttacking())
		{
			if(FactsQuerySum('tut_in_dodge'))
				attackProcessed = true;
		}
		else
		{
			if(attackProcessed && GameplayFactsQuerySum("tut_failed_dodge") < 1)
			{
				IncreaseDodges();
			}
			
			attackProcessed = false;
		}
	}
	
	private final function ProcessRolls()
	{
		var ves : CNewNPC;
		
		ves = theGame.GetNPCByTag('vesemir');
		if(!ves)
			return;
			
		if(ves.IsAttacking())
		{
			if(FactsQuerySum('tut_in_roll'))
				attackProcessed = true;
		}
		else
		{
			if(attackProcessed && GameplayFactsQuerySum("tut_failed_roll") < 1)
			{
				IncreaseRolls();
			}
			
			attackProcessed = false;
		}
	}
	
	
	private function DelayedQueuedTutorialShow()
	{		
		SelectAndDisplayTutorial(queuedTutorials[0]);
		delayedQueuedTutorialShowTime = 0;
		
		
	}
	
	
	event OnTutorialClosing(scriptName : name, closedByUIPanel : bool, optional willBeCloned : bool)
	{
		var i,j : int;
		var inQueue : bool;
		var factOnSeen : string;
	
		for(i=0; i<queuedTutorials.Size(); i+=1)
		{
			if(queuedTutorials[i].tutorialScriptTag == scriptName)
			{
				
				factOnSeen = queuedTutorials[i].factOnFinishedDisplay;
				
				
				if( !closedByUIPanel || willBeCloned )
				{					
					
					
					
					if(queuedTutorials[i].markAsSeenOnShow  && !willBeCloned)
						MarkMessageAsSeen(queuedTutorials[i].tutorialScriptTag);
						
					queuedTutorials.Erase(i);
				}
				
				if(i == 0)
				{
					currentlyShownTutorialIndex = -1;
					
				}
				
				LogTutorial("Closed tutorial <<" + scriptName + ">>, fromUI = " + closedByUIPanel );
				RemoveMenuRestrictions();
				
				
				if(factOnSeen != "" && !willBeCloned)
				{
					inQueue = false;
					for(j=0; j<queuedTutorials.Size(); j+=1)
					{
						if(queuedTutorials[j].tutorialScriptTag == scriptName)
						{
							inQueue = true;
							break;
						}
					}

					if(!inQueue)
						FactsAdd(factOnSeen);
				}

				break;
			}
		}
	}

	
	event OnTutorialClosed(scriptName : name, closedByUIPanel : bool, informUIHandler : bool)
	{
		if( informUIHandler )
		{
			uiHandler.OnTutorialClosed(scriptName, closedByUIPanel);
		}
	}
	
	
	private function SelectAndDisplayTutorial(tut : STutorialMessage)
	{
		if(tut.type == ETMT_Undefined)
		{
			LogTutorial("SelectAndDisplayTutorial: tutorial <<" + tut.tutorialScriptTag + ">> has no type set - not showing!");
			LogAssert(false, "SelectAndDisplayTutorial: tutorial <<" + tut.tutorialScriptTag + ">> has no type set - not showing!");
		}
		
		DisplayTutorialHint(tut);		
	}
	
	
	private function DisplayTutorialHint(tut : STutorialMessage)
	{
		var tutorialEntry : CJournalTutorial;
		var i : int;
		
		
		if( (!tut.force && HasSeenTutorial(tut.tutorialScriptTag)) || !AreMessagesEnabled())
		{
			if(!AreMessagesEnabled())
				FactsAdd(queuedTutorials[0].factOnFinishedDisplay);
				
			queuedTutorials.EraseFast(0);
			return;
		}
	
		
		
		
		tutorialEntry = GetMessageText(tut.tutorialScriptTag, JS_Inactive);	
		
		
		if(!tutorialEntry)
		{
			queuedTutorials.Erase(0);
			return;
		}
				
		if (m_tutorialHintDataObj)
		{
			
		}
		
		m_tutorialHintDataObj = new W3TutorialPopupData in this;
		m_tutorialHintDataObj.managerRef = this;
		m_tutorialHintDataObj.scriptTag = tut.tutorialScriptTag;
		m_tutorialHintDataObj.messageTitle = GetLocStringById(tutorialEntry.GetNameStringId());
		m_tutorialHintDataObj.messageText = GetTutorialLocalizedText(tutorialEntry.GetDescriptionStringId());
		m_tutorialHintDataObj.imagePath = tutorialEntry.GetImagePath();
		m_tutorialHintDataObj.extraInfo = tut.extraInfo;
		m_tutorialHintDataObj.enableGlossoryLink = false;		
		m_tutorialHintDataObj.autosize = !tut.disableHorizontalResize;
		m_tutorialHintDataObj.blockInput = tut.blockInput;
		m_tutorialHintDataObj.pauseGame = tut.pauseGame;
		m_tutorialHintDataObj.fullscreen = tut.fullscreen;
		m_tutorialHintDataObj.canBeShownInMenus = tut.canBeShownInMenus;
		
		
		if(tut.hintDurationType == ETHDT_Input && tut.type != ETMT_Message)
		{
			Log("DebugTutorial force enable button" );
			m_tutorialHintDataObj.enableAcceptButton = true;
			m_tutorialHintDataObj.blockInput = true;
		}
				
		if(tut.type == ETMT_Message)
		{	
			m_tutorialHintDataObj.fullscreen = true;
			m_tutorialHintDataObj.enableAcceptButton = true;
		}
		
		if(tut.isHUDTutorial)
		{
			DisplayHUDTutorialHighlight(tut.tutorialScriptTag,true);
		}
		else
		{
			for(i=0; i<tut.highlightAreas.Size(); i+=1) 
			{
				m_tutorialHintDataObj.AddHighlightedArea( tut.highlightAreas[i].x, tut.highlightAreas[i].y, tut.highlightAreas[i].width, tut.highlightAreas[i].height);
			}
		}
		
		switch(tut.hintPositionType)
		{
			case ETHPT_DefaultGlobal :
				m_tutorialHintDataObj.posX = 0;
				m_tutorialHintDataObj.posY = 0;
				break;
			case ETHPT_DefaultDialog :
				m_tutorialHintDataObj.posX = DIALOG_HINT_POS_X;
				m_tutorialHintDataObj.posY = DIALOG_HINT_POS_Y;
				break;			
			case ETHPT_DefaultCombat :
				m_tutorialHintDataObj.posX = COMBAT_HINT_POS_X;
				m_tutorialHintDataObj.posY = COMBAT_HINT_POS_Y;
				break;
			case ETHPT_DefaultUI :
				m_tutorialHintDataObj.posX = UI_HINT_POS_X;
				m_tutorialHintDataObj.posY = UI_HINT_POS_Y;
				break;
			case ETHPT_Custom :
				m_tutorialHintDataObj.posX = tut.hintPosX;
				m_tutorialHintDataObj.posY = tut.hintPosY;
				break;
			case ETHPT_DefaultRadialMenu :
				m_tutorialHintDataObj.posX = 0;
				m_tutorialHintDataObj.posY = 0.43;

		}

		if(tut.hintDurationType == ETHDT_Short)
		{
			m_tutorialHintDataObj.duration = HINT_DURATION_SHORT * 1000;
		}
		else if(tut.hintDurationType == ETHDT_Long)
		{
			m_tutorialHintDataObj.duration = HINT_DURATION_LONG * 1000;
		}
		else if(tut.hintDurationType == ETHDT_Infinite || tut.hintDurationType == ETHDT_Input)
		{
			m_tutorialHintDataObj.duration = -1;
		}
		else if(tut.hintDurationType == ETHDT_Custom && tut.hintDuration > 0)
		{
			m_tutorialHintDataObj.duration = tut.hintDuration * 1000;
		}
		else
		{
			m_tutorialHintDataObj.duration = tut.hintDuration;
		}
		
		ShowTutorialHint(m_tutorialHintDataObj);
		
		
		ActivateJournalEntry(tut.journalEntryName);
		
		
		if(tut.disabledPanelsExceptions.Size() > 0)
		{
			SetMenuRestrictions(tut.disabledPanelsExceptions);
		}
				
		
		showNextHintInstantly = false;
		currentlyShownTutorialIndex = 0;
		
		LogTutorial( "Now showing tutorial <<" + tut.tutorialScriptTag + ">>" );
	}
	
	private function DisplayHUDTutorialHighlight(tutorialName : name ,bShow : bool )
	{
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if(hud)
			hud.DisplayTutorialHighlight(tutorialName,bShow);
	}
	
	public function HintFeedback(tutorialScriptTag : name, optional negative : bool)
	{
		if(m_tutorialHintDataObj && m_tutorialHintDataObj.scriptTag == tutorialScriptTag)
			m_tutorialHintDataObj.PlayFeedbackAnim(!negative);
	}
	
	
	public function DEBUG_TestTutorialHint(optional x,y,w,h,d : float)
	{
		var testMenusList : array<name>;
		
		testData = new W3TutorialPopupData in this; 
		testData.managerRef = this;
		testData.enableGlossoryLink = true;
		testData.autosize = false;
		testData.posX = 0.99f;
		testData.posY = 0.99f;
		testData.canBeShownInMenus = true;
		
		testData.messageTitle = "Destruir Toda!";
		testData.messageText = "Test internetowa usługa tłumaczeń Google błyskawicznie tłumaczy tekst i strony internetowe.";
		
		if(x > 0 && y > 0 && w > 0 && h > 0)
			testData.AddHighlightedArea(x, y, w, h);
		else
			testData.AddHighlightedArea(.5, .8, .1, .2);
			
		testData.duration = d;
		ShowTutorialHint(testData);
		
		
		
		m_tutorialHintDataObj = testData;
	}
	
	public function DEBUG_TestTutFeedback(optional isCorrect:bool):void
	{
		if (testData)
		{
			testData.PlayFeedbackAnim(isCorrect);
		}
	}
	
	
	private function GetMessageText(scriptTag : string, status : EJournalStatus) : CJournalTutorial
	{
		var entryBase : CJournalBase;
		var resource : CJournalResource;
		var manager : CWitcherJournalManager;
		var tutorialEntry : CJournalTutorial;
		
		manager = theGame.GetJournalManager();
		
		
		entryBase = ((CJournalResource)LoadResource(scriptTag)).GetEntry();
		
		if(!entryBase)
		{
			LogTutorial( "Cannot load journal entry file for <<" + scriptTag + ">>" );		
			LogAssert(false, "W3TutorialManager.GetMessageText: cannot load resource <<" + scriptTag + ">>!");
			return NULL;
		}
		
		manager.ActivateEntry( entryBase, status);
		
		
		
		
		
		
		if(!resource)
		{
			resource = (CJournalResource)LoadResource(scriptTag + "_pad");
		}
		
		if(resource)
		{
			entryBase = resource.GetEntry();
			if(entryBase)
				manager.ActivateEntry( entryBase, status);
		}
			
		
		if(theInput.LastUsedGamepad())
		{
			
			
				
			if(!tutorialEntry)
				tutorialEntry = (CJournalTutorial)manager.GetEntryByString(scriptTag + "_pad");
		}
		
		
		if(!tutorialEntry)
			tutorialEntry = (CJournalTutorial)manager.GetEntryByString(scriptTag);
			
		return tutorialEntry;
	}

	public function HideFirstTutorial()
	{
		HideTutorialHint(queuedTutorials[0].tutorialScriptTag);
	}
	
	
	public function HideTutorialHint(scriptTag : name, optional forceCloseAny : bool, optional dontRemoveFromQueue : bool)
	{
		var i : int;
		var clone : STutorialMessage;
		
		
		if (m_tutorialHintDataObj && (forceCloseAny || m_tutorialHintDataObj.scriptTag == scriptTag))
		{
			if(forceCloseAny)
				scriptTag = queuedTutorials[i].tutorialScriptTag;
				
			
			if(dontRemoveFromQueue)
			{
				clone = queuedTutorials[0];						
			}						
			
			
			m_tutorialHintDataObj.CloseTutorialPopup(dontRemoveFromQueue);
			
			
			OnTutorialClosing(scriptTag, dontRemoveFromQueue, true);
			
			currentlyShownTutorialIndex = -1;	
				
			
			if(dontRemoveFromQueue)
			{
				queuedTutorials.Insert(0, clone);
			}
		}
		else
		{
			
			if(!dontRemoveFromQueue)
			{
				for(i=0; i<queuedTutorials.Size(); i+=1)
				{
					if(queuedTutorials[i].tutorialScriptTag == scriptTag)
					{						
						
						queuedTutorials.Erase(i);
						i -= 1;
					}
				}
			}
		}
	}
		
	public function HandleTutorialMessageHidden(scriptTag : name, forcedClose:bool)
	{
		OnTutorialClosing(scriptTag, forcedClose);
	}
	
	public function OnTutorialHintClosing(scriptTag : name, forcedClose:bool, optional closedByUser:bool, optional willBeCloned : bool)
	{
		OnTutorialClosing(scriptTag, forcedClose, willBeCloned);
	}
	
	public function OnTutorialHintClosed(scriptTag : name, forcedClose:bool, informUIHandler : bool )
	{
		OnTutorialClosed(scriptTag, forcedClose, informUIHandler);
		
		
			DisplayHUDTutorialHighlight(scriptTag,false);
		
	}
		
	
	public function HAX_DEBUG_ForceTutorialMessageAsSeen(tutorialScriptTag : name, showInJournal : bool)
	{
	}
		
	public function MarkMessageAsSeen(tutorialScriptTag : name)
	{
		if(!seenTutorials.Contains(tutorialScriptTag))
			seenTutorials.PushBack(tutorialScriptTag);
	}
	
	public function UnmarkMessageAsSeen(tutorialScriptTag : name)
	{
		if (seenTutorials.Contains(tutorialScriptTag))
			seenTutorials.Remove(tutorialScriptTag);
	}
	
	
	
	
	
	public function SetInteraction(component : CInteractionComponent)
	{
		var actionName : name;
		var container, talk, door, examine, repairSword, repairArmor, mountBoat, fastTravel, campfire, monsterNest, craftsman, stash : bool;
		var ent : CEntity;
		var repairObj : W3ItemRepairObject;
		
		
		if(component)
		{
			actionName = component.GetInputActionName();			
			ent = component.GetEntity();
			repairObj = (W3ItemRepairObject)ent;
			if(repairObj)
			{
				if(repairObj.RepairsSword())
					repairSword = true;
				if(repairObj.RepairsArmor())
					repairArmor = true;
			}
			else if( (W3FastTravelEntity)ent )
			{
				fastTravel = true;
			}
			else if( (CMonsterNestEntity)ent )
			{
				monsterNest = true;
			}
			else if(ent.GetComponentByClassName('W3MeditationComponent'))
			{
				campfire = true;
			}
			else if(ent.GetComponentByClassName('CBoatComponent') || (W3Boat)ent || ent.GetComponentByClassName('CBoatDestructionComponent'))	
			{
				mountBoat = true;
			}
			else if( (W3Stash)ent )
			{
				stash = true;
			}
			else if(actionName == 'Container')
			{
				container = true;
			}
			else if(actionName == 'Talk')
			{
				talk = true;
				
				if( ent.GetComponentByClassName('W3CraftsmanComponent') )
					craftsman = true;
			}
			else if(actionName == 'Examine')
			{
				examine = true;
			}
		}

		
		if(container)
			FactsAdd("tutorial_interaction_container");
		else
			FactsRemove("tutorial_interaction_container");
		
		if(talk)
			FactsAdd("tutorial_interaction_talk");
		else
			FactsRemove("tutorial_interaction_talk");

		if(examine)
			FactsAdd("tutorial_interaction_examine");
		else
			FactsRemove("tutorial_interaction_examine");
			
		if(repairArmor)
			FactsAdd("tutorial_interaction_repair_armor");
		else
			FactsRemove("tutorial_interaction_repair_armor");
			
		if(repairSword)
			FactsAdd("tutorial_interaction_repair_sword");
		else
			FactsRemove("tutorial_interaction_repair_sword");
			
		if(mountBoat)
			FactsAdd("tutorial_interaction_boat");
		else
			FactsRemove("tutorial_interaction_boat");
			
		if(fastTravel)
			FactsAdd("tutorial_interaction_fast_travel");
		else
			FactsRemove("tutorial_interaction_fast_travel");
			
		if(campfire)
			FactsAdd("tutorial_interaction_campfire");
		else
			FactsRemove("tutorial_interaction_campfire");
			
		if(monsterNest)
			FactsAdd("tutorial_interaction_mon_nest");
		else
			FactsRemove("tutorial_interaction_mon_nest");
		
		if(craftsman)
			FactsAdd("tutorial_interaction_craftsman");
		else
			FactsRemove("tutorial_interaction_craftsman");

		if(stash)
			FactsAdd("tutorial_interaction_stash");
		else
			FactsRemove("tutorial_interaction_stash");
	}
	
	
	public function ShowTutorialHint(hintData : W3TutorialPopupData):void
	{
		theGame.RequestPopup( 'TutorialPopup',  hintData );	
	}
	
	
	public function ActivateJournalEntry(entryName : name)
	{
		var entryBase : CJournalBase;
		var resource : CJournalResource;
		var manager : CWitcherJournalManager;

		if(!IsNameValid(entryName))
			return;
		
		manager = theGame.GetJournalManager();
		
		
		resource = (CJournalResource)LoadResource(entryName);
		if(resource)
		{
			entryBase = resource.GetEntry();
			if(entryBase)
				manager.ActivateEntry( entryBase, JS_Active);
		}
		
		
		resource = (CJournalResource)LoadResource(entryName + "_pad");
		if(resource)
		{
			entryBase = resource.GetEntry();
			if(entryBase)
				manager.ActivateEntry( entryBase, JS_Active);
		}
		
		
		resource = (CJournalResource)LoadResource(entryName + "_ps4");
		if(resource)
		{
			entryBase = resource.GetEntry();
			if(entryBase)
				manager.ActivateEntry( entryBase, JS_Active);
		}
	}
	
	
	public function GetCurrentlyShownTutorialScriptName() : name
	{
		if(queuedTutorials.Size() > 0 && m_tutorialHintDataObj && currentlyShownTutorialIndex >= 0)
		{
			return queuedTutorials[currentlyShownTutorialIndex].tutorialScriptTag;
		}
		
		return '';
	}
	
	public function IncreaseGeraltsLightAttacksCount(victimTags : array<name>)
	{
		var i : int;
		
		for(i=0; i<victimTags.Size(); i+=1)
		{
			FactsAdd("tut_light_attack_" + victimTags[i]);
		}
	}
	
	public function IncreaseGeraltsHeavyAttacksCount(victimTags : array<name>)
	{
		var i : int;
		
		for(i=0; i<victimTags.Size(); i+=1)
		{
			FactsAdd("tut_heavy_attack_" + victimTags[i]);
		}
	}
	
	
	public function OnCutsceneOrDialogChange(isNowOn : bool)
	{
		if(!isNowOn)
			return;
			
		
		if(queuedTutorials.Size() > 0 && m_tutorialHintDataObj)
		{
			
			if(!queuedTutorials[0].canBeShownInDialogs)
			{
				
				HideTutorialHint('', true, true);
			}
		}
	}
	
	
	public function OnGuardSwordWarning()
	{
		FactsAdd("tut_guard_warning", 1, 1);
		thePlayer.DisplayHudMessage( GetLocStringByKeyExt("guards_taunting_message") );
	}
	
	
	public function OnGuardGeneralWarning()
	{
		thePlayer.DisplayHudMessage( GetLocStringByKeyExt("guards_taunting_message") );
	}
	
	
	public function OnGuardLootingWarning()
	{
		thePlayer.DisplayHudMessage( GetLocStringByKeyExt("guards_stealing_message") );
		if(!HasSeenTutorial('TutorialStealing'))
			FactsAdd("tut_stealing");
	}
	
	
	public final function ReloadMessageOnInputChange(startedUsingPad : bool, optional forceShowImmediately : bool)
	{
		var resPad, resCommon : CJournalResource;
		var tutorialEntry : CJournalTutorial;
		var performReload : bool;
		var manager : CWitcherJournalManager;
		
		
		if(queuedTutorials.Size() == 0)
			return;
		
		performReload = false;
		
		
		
		
		
		
		
		
		
		
			resPad = (CJournalResource)LoadResource(queuedTutorials[0].tutorialScriptTag + "_pad");
		
		
		if(resPad)
		{
			
			performReload = true;
		}
		else
		{
			
			resCommon = (CJournalResource)LoadResource(queuedTutorials[0].tutorialScriptTag);
				
			
			manager = theGame.GetJournalManager();				
			tutorialEntry = (CJournalTutorial)manager.GetEntryByString(queuedTutorials[0].tutorialScriptTag);
			if(!tutorialEntry)
			{
				
				manager.ActivateEntry( resCommon.GetEntry(), JS_Inactive);
				tutorialEntry = (CJournalTutorial)manager.GetEntryByString(queuedTutorials[0].tutorialScriptTag);
			}

			
			if(!tutorialEntry || HasLolcalizationTags( GetLocStringById(tutorialEntry.GetDescriptionStringId()) ) )
				performReload = true;
		}

		if(performReload)
		{
			
			showNextHintInstantly = true;			
			HideTutorialHint('', true, true);

			
			if(forceShowImmediately)
			{
				DelayedQueuedTutorialShow();
			}
		}
	}

	
	private function GetTutorialLocalizedText(locId : int) : string
	{
		
		var s: string;
		var inGameConfigWrapper : CInGameConfigWrapper;
		var configValue: string;

		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();		
		configValue = inGameConfigWrapper.GetVarValue( 'Controls', 'AlternativeRadialMenuInputMode' );
		s = GetLocStringById(locId);

		if(configValue && m_tutorialHintDataObj.scriptTag=='TutorialSelectQuen')
		{	
			s = StrReplace(s, "GI_AxisLeft", "GI_AxisRight");
		}

		return ReplaceTagsToIcons(s);
	}

	
	private function SetMenuRestrictions(enabledMenuList:array<name>):void
	{
		var commonMenuRef  : CR4CommonMenu;

		enableMenuRestrictions = true;
		allowedMenusList = enabledMenuList;

   		commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
   		if (commonMenuRef)
   		{
			commonMenuRef.UpdateTutorialRestruction();
   		}
	}

	
	private function RemoveMenuRestrictions():void
	{
		enableMenuRestrictions = false;
		allowedMenusList.Clear();
	}

	
	public function IsMenuRestrictionsEnable() : bool
	{
		return enableMenuRestrictions;
	}

	
	public function GetAllowedMenuList() : array <name>
	{
		return allowedMenusList;
	}

	public final function Failsafe()
	{
		queuedTutorials.Clear();
		HideTutorialHint('', true);
		currentlyShownTutorialIndex = -1;
		delayedQueuedTutorialShowTime = 0;
		hasDelayedTutorial = false;
		showNextHintInstantly = false;
		enableMenuRestrictions = false;
		invisibleTutorialHint = '';
		allowedMenusList.Clear();
	}

	
	
	

	public final function SetHudMessage(tutorialMessageName : name, on : bool)
	{
		var hud : CR4ScriptedHud;
		var messageModule : CR4HudModuleMessage;

		if(on)
		{
			hudMessage = tutorialMessageName;
		}
		else
		{
			hudMessage = '';

			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				messageModule = (CR4HudModuleMessage)hud.GetHudModule("MessageModule");
				if( messageModule )
				{
					messageModule.OnMessageHidden();
				}
			}
		}
	}

	private final function ProcessHUDMessage()
	{
		var tutorialEntry : CJournalTutorial;
		var msgText : string;

		if(IsNameValid(hudMessage) && AreMessagesEnabled())
		{
			tutorialEntry = GetMessageText(hudMessage, JS_Inactive);
			msgText = GetTutorialLocalizedText(tutorialEntry.GetDescriptionStringId());
			thePlayer.DisplayHudMessage(msgText);
		}
	}	

	
	
	

	private timer function TutorialInvisibleHint(dt : float, id : int)
	{
		HideTutorialHint(invisibleTutorialHint);
	}

	public final function ForcedAlchemyCleanup()
	{
		
		uiHandler.LockCloseUIPanels(false);

		
		FactsRemove("tut_forced_preparation");

		
		uiHandler.LockLeaveMenu(false);

		
		thePlayer.BlockAllActions('tut_forced_preparation', false);

		
		uiHandler.UnregisterUIState('ForcedAlchemy');

		
		uiHandler.UnregisterUIState('Alchemy', "forced");

		
		uiHandler.UnregisterUIState('Potions', "forced");
	}
	
	public final function RemoveAllQueuedTutorials()
	{
		queuedTutorials.Clear();
		uiHandler.ClearAllListeners();
	}

	public final function IsTutorialQueued(tutorialScriptTag : name):bool
	{
		var i : int;

		for(i = 0; i < queuedTutorials.Size(); i+=1)
		{
			if(queuedTutorials[i].tutorialScriptTag == tutorialScriptTag)
				return true;
		}
		return false;
	}
	
	
	
	
	
	public final function OnOpeningMenuHandleNonMenuTutorial()
	{
		if(queuedTutorials.Size() > 0 && currentlyShownTutorialIndex >= 0)
		{
			
			if(!queuedTutorials[currentlyShownTutorialIndex].canBeShownInMenus)
				HideTutorialHint(queuedTutorials[currentlyShownTutorialIndex].tutorialScriptTag, ,true);
		}
	}
	
	
	
	
	
	public final function DEBUG_LogQueuedTutorials()
	{
		var i : int;
		
		LogTutorial("Printing tutorial queue:");
		for(i=0; i<queuedTutorials.Size(); i+=1)
		{
			LogTutorial(i + ") " + queuedTutorials[i].tutorialScriptTag);
		}
	}

	public function IsQueuedTutorials() :bool
	{
		return queuedTutorials.Size() > 0;
	}
}

exec function logtutorialqueue()
{
	theGame.GetTutorialSystem().DEBUG_LogQueuedTutorials();
}


class SwitchTutorialManager
{
	var tutorialSystem : CR4TutorialSystem;
	public var inMotionPatternTutorial : bool;
	public var forceEnableMultipleTutorial : bool;
	private var _currentPatternType : EMotionPatternTutorialType;

	
	public function UpdateMotionPatternTutorialState(patterntype : EMotionPatternTutorialType, patternstate : EMotionPatternTutorialState) : void
	{
		var tut : STutorialMessage;	
		var ounceStyle:  OunceGamepadStyle ;
		var enabledMP:  int ;

		ounceStyle = theInput.GetOunceGamepadStyle();
		enabledMP = theGame.GetMotionPatternsMode_DualGrip();

		if(theGame.GetPlatform() != Platform_Switch2_Ounce 	
			|| thePlayer.IsInCombat() 
			|| ounceStyle != OunceGamepadStyle_JoyDual
			|| !FactsDoesExist("q001_nightmare_ended")
			|| FactsQuerySum("q001_nightmare_ended") == 0 )
		{
			
			
			
			
			

			return;
		}
		
		

		switch(patterntype)
		{
			case MPTT_Crossbow:
			if(enabledMP == 0 || enabledMP == 2)
			{
				return;
			}
			break;

			case MPTT_PotionUsePrimary:
			if(enabledMP == 0 || enabledMP == 2)
			{
				return;
			}
			break;

			case MPTT_PotionUseSecondary:
			if(enabledMP == 0 || enabledMP == 2)
			{
				return;
			}
			break;

			case MPTT_HorseCall:
			if(enabledMP == 0)
			{
				return;
			}
			break;

			case MPTT_HorseAcceleration:
			if(enabledMP == 0)
			{
				return;
			}
			break;

			case MPTT_HorseStop:
			if(enabledMP == 0)
			{
				return;
			}
			break;
		}

		switch(patternstate)
		{
			case MPTS_Trigger:

			if(inMotionPatternTutorial)
			{				
				return;
			}
			if(!forceEnableMultipleTutorial && tutorialSystem.IsQueuedTutorials())
			{
				return;
			}

			if(NeedMotionPatternTutorial(patterntype,patternstate))
			{
				inMotionPatternTutorial = true;
				_currentPatternType = patterntype;

				tut.hintDurationType = ETHDT_Infinite;
				tut.hintCloseOnFactExist = MotionPatternFactToString(patterntype , MPTS_Done);
				tut.type = ETMT_Hint;
				tut.force = true;

				switch(patterntype)
				{
					case MPTT_Crossbow:
					tut.tutorialScriptTag ='TutorialCrossbowMotionControls';
					tutorialSystem.DisplayTutorial(tut);
					break;

					case MPTT_PotionUsePrimary:
					tut.tutorialScriptTag = 'TutorialPotionEquippedPrimaryMotionControls';
					tutorialSystem.DisplayTutorial(tut);

					thePlayer.GetInventory().SingletonItemsRefillAmmo();
					break;

					case MPTT_PotionUseSecondary:
					tut.tutorialScriptTag = 'TutorialPotionEquippedSecondaryMotionControls';
					tutorialSystem.DisplayTutorial(tut);

					thePlayer.GetInventory().SingletonItemsRefillAmmo();
					break;

					case MPTT_HorseCall:
					tut.tutorialScriptTag = 'TutorialHorseSummonMotionControls';
					tutorialSystem.DisplayTutorial(tut);
					break;

					case MPTT_HorseAcceleration:
					tut.tutorialScriptTag = 'TutorialHorseSpeed2MotionControls';
					tutorialSystem.DisplayTutorial(tut);
					break;

					case MPTT_HorseStop:
					tut.tutorialScriptTag =	'TutorialHorseStopMotionControls';
					tutorialSystem.DisplayTutorial(tut);
					break;
				}
			}

			AddMotionPatternTutorialFact(patterntype,patternstate);

			break;

			case MPTS_Done:
			if(inMotionPatternTutorial && _currentPatternType == patterntype)
			{
				inMotionPatternTutorial = false;
				AddMotionPatternTutorialFact(patterntype,patternstate);

				if(_currentPatternType == MPTT_PotionUsePrimary)
				{
					forceEnableMultipleTutorial = true;				
					UpdateMotionPatternTutorialState(MPTT_PotionUseSecondary,MPTS_Trigger);
					forceEnableMultipleTutorial=false;
				}
				else if (_currentPatternType == MPTT_HorseAcceleration)
				{
					forceEnableMultipleTutorial = true;
					UpdateMotionPatternTutorialState(MPTT_HorseStop,MPTS_Trigger);
					forceEnableMultipleTutorial = false;
				}
			}			
			break;
		}
	}

	public function UpdateDualGripStyleFact()
	{	
		var ounceStyle:  OunceGamepadStyle ;

		ounceStyle = theInput.GetOunceGamepadStyle();

		if( ounceStyle == OunceGamepadStyle_JoyDual)
		{
			FactsAdd("switch_dual_grip_style", 1);
		}
		else
		{
			FactsAdd("switch_dual_grip_style", 0);
		}
	}

	public function NeedMotionPatternTutorial(patterntype : EMotionPatternTutorialType, patternstate : EMotionPatternTutorialState) : bool
	{		
		if(FactsQuerySum(MotionPatternFactToString(patterntype , MPTS_Trigger)) > 0 || FactsQuerySum(MotionPatternFactToString(patterntype , MPTS_Done)) > 0 )
		{
			return false;
		}

		return true;
	}

	private function AddMotionPatternTutorialFact(patterntype : EMotionPatternTutorialType, patternstate : EMotionPatternTutorialState)
	{	
		var factName : string;
		FactsAdd(MotionPatternFactToString(patterntype , patternstate), 1);
	}

	private function MotionPatternFactToString(patterntype : EMotionPatternTutorialType , patternstate : EMotionPatternTutorialState) : String
	{
		var factName : string;
		factName = "motionpattern_";

		switch(patterntype)
		{
			case MPTT_Crossbow:
				factName += "crossbow";
				break;

			case MPTT_PotionUsePrimary:
				factName += "potionuseprimary";
				break;

			case MPTT_PotionUseSecondary:
				factName += "potionusesecondary";
				break;

			case MPTT_HorseCall:
				factName += "horsecall";
				break;

			case MPTT_HorseAcceleration:
				factName += "horseacceleration";
				break;

			case MPTT_HorseStop:
				factName += "horsestop";
				break;
		}

		switch(patternstate)
		{
			case MPTS_Trigger:
				factName += "_trigger";
				break;

			case MPTS_Done:
				factName += "_done";
				break;
		}

		return factName;
	}
}

enum EMotionPatternTutorialType
{
	MPTT_Crossbow,
	MPTT_PotionUsePrimary,
	MPTT_PotionUseSecondary,
	MPTT_HorseCall,
	MPTT_HorseAcceleration,
	MPTT_HorseStop
}

enum EMotionPatternTutorialState
{
	MPTS_Trigger,
	MPTS_Done
}

exec function showPatternTutorial()
{
	var tut : STutorialMessage;

	TutorialMessagesEnable(true);
	tut.hintDurationType = ETHDT_Infinite;
	tut.enableAcceptButton = true;
	tut.type = ETMT_Hint;
	tut.tutorialScriptTag ='TutorialCrossbowMotionControls';
	tut.force = true ;
	theGame.GetTutorialSystem().DisplayTutorial(tut);
}

exec function showPatternTutorialTag(tag : name)
{
	var tut : STutorialMessage;

	TutorialMessagesEnable(true);
	tut.hintDurationType = ETHDT_Infinite;
	tut.tutorialScriptTag = tag;
	tut.enableAcceptButton = true;
	tut.type = ETMT_Hint;
	tut.force = true;
	tut.forceToQueueFront = true;
	tut.blockInput = true;
	theGame.GetTutorialSystem().DisplayTutorial(tut);
}

exec function closeTutorialPopup()
{
	theGame.GetTutorialSystem().HideFirstTutorial();
}

exec function AddFactDualGripStyle()
{
	FactsAdd("switch_dual_grip_style", 1);
}