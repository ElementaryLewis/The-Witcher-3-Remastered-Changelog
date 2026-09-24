/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EUpdateEventType
{
	EUET_StartedTracking,
	EUET_TrackedQuest,
	EUET_TrackedQuestObjective,
	EUET_TrackedQuestObjectiveCounter,
	EUET_HighlightedQuestObjective,
}

struct SUpdateEvent
{
	var eventType	: EUpdateEventType;
	var delay		: int;
	var journalBase	: CJournalBase;
	var index		: int;
}

class CR4HudModuleQuests extends CR4HudModuleBase
{	
	private var m_systemQuest						: CJournalQuest;
	private var m_systemObjectives					: array< SJournalQuestObjectiveData >;
	private var m_userObjectives					: array< SJournalQuestObjectiveData >;

	private var m_updateEvents						: array< SUpdateEvent >;

	private var manager : CWitcherJournalManager;

	private var m_fxShowTrackedQuestSFF				: CScriptedFlashFunction;
	private var m_fxUpdateObjectiveCounterSFF		: CScriptedFlashFunction;
	private var m_fxUpdateObjectiveHighlightSFF		: CScriptedFlashFunction;
	private var m_fxUpdateObjectiveUnhighlightAllSFF: CScriptedFlashFunction;
	
	private var m_fxSetSystemQuestInfo				: CScriptedFlashFunction;
	
	private var m_guiManager 						: CR4GuiManager;
	private var m_hud 								: CR4ScriptedHud;
	
	

	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		
		
		var inGameConfigWrapper : CInGameConfigWrapper;
		
		m_anchorName = "mcAnchorQuest";
		
		super.OnConfigUI();
		m_guiManager = theGame.GetGuiManager();
		m_hud = (CR4ScriptedHud)theGame.GetHud(); 

		flashModule = GetModuleFlash();	
		m_fxShowTrackedQuestSFF				= flashModule.GetMemberFlashFunction( "ShowTrackedQuest" );
		m_fxUpdateObjectiveCounterSFF		= flashModule.GetMemberFlashFunction( "UpdateObjectiveCounter" );
		m_fxUpdateObjectiveHighlightSFF		= flashModule.GetMemberFlashFunction( "UpdateObjectiveHighlight" );
		m_fxUpdateObjectiveUnhighlightAllSFF= flashModule.GetMemberFlashFunction( "UpdateObjectiveUnhighlightAll" );
		m_fxSetSystemQuestInfo				= flashModule.GetMemberFlashFunction( "SetSystemQuestInfo" );
		
		manager = theGame.GetJournalManager();
		
		theInput.RegisterListener( this, 'OnHighlightNextObjective', 'HighlightObjective' );

		UpdateQuest();
		
		if (m_hud)
		{
			m_hud.UpdateHudConfig('QuestsModule', true);
		}
		
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		objectiveDuringFocusCombat = inGameConfigWrapper.GetVarValue('Hud', 'ObjectiveDuringFocusCombat');
		
	}
	
	public function OnLevelUp()
	{
		UpdateQuest();
	}

	
	private var isInCombat : bool;
	private var isInFocus : bool;
	private var dlgPlaying : bool;
	public function SetIsInDlg(dlg : bool)
	{
		if(!objectiveDuringFocusCombat)
			return;
	
		dlgPlaying = dlg;
		
		if(dlg)
		{			
			currentlyFading = false;
			isFading = false;
			SetEnabled(false);
		}
		else
		{
			currentlyFading = false;
			isFading = false;
		}
	}
	public function SetIsInCombat(combat : bool)
	{
		isInCombat = combat;
	}
	
	public function SetIsInFocus(focus : bool)
	{
		isInFocus = focus;
	}
	
	private var objectiveDuringFocusCombat : bool;
	public function GetObjectiveDuringFocusCombat() : bool
	{
		return objectiveDuringFocusCombat;
	}
	
	public function SetObjectiveDuringFocusCombat(enable : bool)
	{
		objectiveDuringFocusCombat = enable;
		if(!objectiveDuringFocusCombat)
		{
			if ( m_hud )
				m_hud.UpdateHudConfig('QuestsModule', true);	
		}
		else
		{
			fadeInTimer = 5.5;
		}
	}
	
	private var fadeInTimer : float;
	private var isFading, currentlyFading : bool;
	private var fadeOutTime : float;	default fadeOutTime = 0.3f;
	private var fadeTime : float;
	
	private function FadeObjectiveOut(dt : float)
	{		
		if(dlgPlaying)
			return;
	
		fadeInTimer -= dt;
		if(fadeInTimer > 0)
			return;
	
		currentlyFading = true;
		fadeTime -= dt;
		GetModuleFlash().SetAlpha( 100 * MaxF( 0, fadeTime / fadeOutTime ) );
		
		if(fadeTime <= 0)
		{
			SetEnabled(false);
			currentlyFading = false;
			isFading = false;
		}
	}
	
	private function ShowObjectiveOnUpdate()
	{
		if(objectiveDuringFocusCombat)
		{
			m_hud.UpdateHudConfig('QuestsModule', true);
			fadeInTimer = 8.0f;
			isFading = false;
		}
	}
	

	event  OnTick( timeDelta : float )
	{
		var i : int;
		var e : SUpdateEvent;
		var systemObjectives : array< SJournalQuestObjectiveData >;
		var sendSystemObjectives : bool = false;
		
		
		var horseRacing : bool;
		
		horseRacing = false;

		if(!dlgPlaying && objectiveDuringFocusCombat)
		{
			if(thePlayer.GetIsHorseRacing())
				horseRacing = true;
		
			if(currentlyFading || (isFading && !isInFocus && !isInCombat && !horseRacing))
			{
				FadeObjectiveOut(timeDelta);
				
			}		
		
			else if(!currentlyFading && (isInFocus || isInCombat || horseRacing))
			{
				if ( m_hud )
				{
					m_hud.UpdateHudConfig('QuestsModule', true);
					fadeInTimer = 5.5f;
					isFading = false;
				}
			}
			else if (!isFading && GetEnabled())
			{
				isFading = true;
				fadeTime = fadeOutTime;
				FadeObjectiveOut(timeDelta);
				
			}
		}
		

		if ( CheckIfUpdateIsAllowed() && m_updateEvents.Size() )
		{
			
			systemObjectives = m_systemObjectives;
			
			for ( i = 0; i < m_updateEvents.Size(); )
			{
				e = m_updateEvents[ i ];
				if ( e.delay == 0 )
				{
					switch ( e.eventType )
					{
					case EUET_StartedTracking:
						UpdateQuest();
						break;
					case EUET_TrackedQuest:
						
						break;
					case EUET_TrackedQuestObjective:						
						ShowObjectiveOnUpdate();	
						UpdateObjectives();
						sendSystemObjectives = true;
						break;
					case EUET_TrackedQuestObjectiveCounter:
						SendObjectiveCounter( ( CJournalQuestObjective )e.journalBase );
						break;
					case EUET_HighlightedQuestObjective:
						HighlightObjective( ( CJournalQuestObjective )e.journalBase );
						break;
					}
					m_updateEvents.Erase( i );
				}
				else
				{
					m_updateEvents[ i ].delay -= 1;
					i += 1;
				}
			}
					
			if ( sendSystemObjectives )
			{
				SendObjectives();
			}
			
		}
	}
	
	function CheckIfUpdateIsAllowed() : bool
	{
		switch( m_hud.currentInputContext )
		{
			case 'FastMenu' : 
			case 'TutorialPopup' :
			case 'RadialMenu' :
			case 'Scene' :
				return false;
				break;
			default :
				return true;
		}
		return true;
	}	

	event  OnHighlightNextObjective( action : SInputAction )
	{
		var journalModule 	 : CR4HudModuleJournalUpdate;
		var walkToggleAction : SInputAction;
		var inputHandled     : bool = false;
		
		if ( thePlayer.IsCameraLockedToTarget() && 
			( thePlayer.GetCurrentStateName() == 'Exploration' || thePlayer.GetCurrentStateName() == 'TraverseExploration' ) )
		{
			thePlayer.HardLockToTarget( false );
			inputHandled = true;
		}
		
		if( !inputHandled && m_hud )
		{
			journalModule = (CR4HudModuleJournalUpdate) m_hud.GetHudModule( "JournalUpdateModule");
			
			if ( journalModule )
			{
				inputHandled = journalModule.isBookInfoShown();
			}
		}
		
		if ( !inputHandled && thePlayer.IsActionAllowed( EIAB_HighlightObjective ) )
		{
			walkToggleAction = theInput.GetAction('WalkToggle');
			if ( IsReleased(action) && walkToggleAction.lastFrameValue < 0.7 && walkToggleAction.value < 0.7 )
			{
				if(ShouldProcessTutorial('TutorialObjectiveSwitching'))
				{
					FactsSet( "tut_switched_objective", 1 );
				}
				theGame.GetJournalManager().SetPrevNextHighlightedObjective( true );
				
				ShowObjectiveOnUpdate();	
			}
		}
	}
	
	
	

	public function OnQuestTrackingStarted( journalQuest : CJournalQuest )
	{
		
		
		
		var e : SUpdateEvent;
		e.eventType		= EUET_StartedTracking;
		e.delay			= 0;
		e.journalBase	= journalQuest;
		m_updateEvents.PushBack( e );
	}

	public function OnTrackedQuestUpdated( journalQuest : CJournalQuest )
	{
		
		
		var e : SUpdateEvent;
		e.eventType		= EUET_TrackedQuest;
		e.delay			= 1;
		e.journalBase	= journalQuest;
		m_updateEvents.PushBack( e );
	}
	
	public function OnTrackedQuestObjectivesUpdated( journalObjective : CJournalQuestObjective )
	{
		
		
		var e : SUpdateEvent;
		e.eventType		= EUET_TrackedQuestObjective;
		e.delay			= 1;
		e.journalBase	= journalObjective;
		m_updateEvents.PushBack( e );
	}
	
	public function OnTrackedQuestObjectiveCounterUpdated( journalObjective : CJournalQuestObjective )
	{
		
		var e : SUpdateEvent;
		e.eventType		= EUET_TrackedQuestObjectiveCounter;
		e.delay			= 1;
		e.journalBase	= journalObjective;
		m_updateEvents.PushBack( e );
	}

	public function OnTrackedQuestObjectiveHighlighted( journalObjective : CJournalQuestObjective, objectiveIndex : int )
	{
		
		var e : SUpdateEvent;
		e.eventType		= EUET_HighlightedQuestObjective;
		e.delay			= 2;
		e.journalBase	= journalObjective;
		m_updateEvents.PushBack( e );
	}

	private function Test()
	{
		var objectives1 : array< SJournalQuestObjectiveData >;
		var objectives2 : array< SJournalQuestObjectiveData >;
		
		theGame.GetJournalManager().GetTrackedQuestObjectivesData( objectives1 );
		HAXGetTrackedObjectives( objectives2 );
		
		if ( objectives1.Size() != objectives2.Size() )
		{
			LogChannel('QuestTrackerFail', "objectives1.Size() != objectives2.Size()" );
		}
	}

	
	

	private function UpdateQuest()
	{
		m_systemQuest = manager.GetTrackedQuest();
		
		if ( m_systemQuest )
		{
			UpdateObjectives();

			SendQuestName();
			SendObjectives();
			
			ShowQuestTracker( m_systemObjectives.Size() > 0 );
		}
		else
		{
			ShowQuestTracker( false );
		}
	}

	private function UpdateObjectives()
	{
		var l_objectives : array< SJournalQuestObjectiveData >;
		var i : int;
		
		
		
		theGame.GetJournalManager().GetTrackedQuestObjectivesData( l_objectives );
		
		
		
		
		
		
		
		
		
		m_systemObjectives.Clear();
			
		for ( i = 0; i < l_objectives.Size(); i += 1 )
		{
			if ( l_objectives[i].status == JS_Active )
			{
				m_systemObjectives.PushBack( l_objectives[ i ] );
				
			}
		}
	}
	
	function HAXGetTrackedObjectives( out l_objectives : array< SJournalQuestObjectiveData > )
	{
		var journalQuest : CJournalQuest;
		var l_questPhase : CJournalQuestPhase;
		var l_objective  : CJournalQuestObjective;
		var journalObjectiveData : SJournalQuestObjectiveData;
		var l_objectiveStatus : EJournalStatus;
		
		var i,j : int;
		
		journalQuest = manager.GetTrackedQuest();

		for( i = 0; i < journalQuest.GetNumChildren(); i += 1 )
		{
			l_questPhase = (CJournalQuestPhase) journalQuest.GetChild(i);
			if(l_questPhase)
			{				
				for( j = 0; j < l_questPhase.GetNumChildren(); j += 1 )
				{
					l_objective =( CJournalQuestObjective ) l_questPhase.GetChild(j);
					l_objectiveStatus 	= ( manager.GetEntryStatus( l_objective ) );
					if( l_objectiveStatus > JS_Inactive )
					{	
						journalObjectiveData.status = l_objectiveStatus;
						journalObjectiveData.objectiveEntry = l_objective;
						l_objectives.PushBack(journalObjectiveData);
					}
				}
			}
		}
	}
	
	private function SendQuestName()
	{
		var flashValueStorage : CScriptedFlashValueStorage = GetModuleFlashValueStorage();
		var questName : string;
		var searchQuestName : string;
		var questCount:int;
		var questLevel:int;
		var lvlDiff:int;
		var j:int;
		var questTooHard:bool;
		var questLevels : C2dArray;
		var questLevelsCount: int;
		var iterQuestLevels: int;

		questName = GetLocStringById( m_systemQuest.GetTitleStringId() );
		if ( questName == "" )
		{
			questName = "MISSING_QUEST_NAME: " + m_systemQuest.baseName;
		}
		
		questLevelsCount = theGame.questLevelsContainer.Size();
		for( iterQuestLevels = 0; iterQuestLevels < questLevelsCount; iterQuestLevels += 1 )
		{
			questLevels = theGame.questLevelsContainer[iterQuestLevels];
			questCount = questLevels.GetNumRows();
			for( j = 0; j < questCount; j += 1 )
			{
				searchQuestName  = questLevels.GetValueAtAsName(0,j);
				if ( searchQuestName == m_systemQuest.baseName )
				{
					questLevel  = NameToInt( questLevels.GetValueAtAsName(1,j) );
					
					if(FactsQuerySum("NewGamePlus") > 0)
					{
						questLevel += theGame.params.GetNewGamePlusLevel();					
						if ( questLevel > GetWitcherPlayer().GetMaxLevel() ) 
						{
							questLevel = GetWitcherPlayer().GetMaxLevel();
						}
					}
				}
			}
		}
		
		lvlDiff = questLevel - thePlayer.GetLevel();
		
		if ((W3ReplacerCiri)thePlayer)
		{
			questTooHard = false;
		}
		else
		{
			questTooHard = lvlDiff >= theGame.params.LEVEL_DIFF_HIGH;
		}
		
		m_fxSetSystemQuestInfo.InvokeSelfThreeArgs(FlashArgString(questName), FlashArgInt(GetColorByQuestType( m_systemQuest )), FlashArgBool(questTooHard));
	}

	private function SendObjectives()
	{
		var l_flashArray	: CScriptedFlashArray;
		var l_flashObject	: CScriptedFlashObject;
		var data : SJournalQuestObjectiveData;
		var i : int;
		var objectiveName : string;
		
		l_flashArray = GetModuleFlashValueStorage().CreateTempFlashArray();
		
		for ( i = 0; i < m_systemObjectives.Size(); i += 1 )
		{
			data = m_systemObjectives[ i ];

			l_flashObject = GetModuleFlashValueStorage().CreateTempFlashObject();

			objectiveName = GetLocStringById( data.objectiveEntry.GetTitleStringId() );
			if ( objectiveName == "" )
			{
				objectiveName = "MISSING_OBJECTIVE_NAME: " + data.objectiveEntry.baseName;
			}
			l_flashObject.SetMemberFlashString( "name",   objectiveName + GetQuestObjectiveCounterText( data.objectiveEntry ) );
			l_flashObject.SetMemberFlashBool(   "isHighlighted", ( data.objectiveEntry == _highlightedObjective ) );
			l_flashObject.SetMemberFlashBool(   "isMutuallyExclusive", data.objectiveEntry.IsMutuallyExclusive() );
			if( m_guiManager.FindDisplayedObjectiveGUID( data.objectiveEntry.guid ) )
			{
				l_flashObject.SetMemberFlashBool(   "isNew",  false );
			}
			else
			{
				l_flashObject.SetMemberFlashBool(   "isNew",  true );
				m_guiManager.SaveDisplayedObjectiveGUID( data.objectiveEntry.guid );
			}
			l_flashArray.PushBackFlashObject( l_flashObject );
		}

		GetModuleFlashValueStorage().SetFlashArray( "hud.quest.system.objectives", l_flashArray );
		
		ShowQuestTracker( m_systemObjectives.Size() > 0 );
	}

	public function SendObjectiveCounter( objective : CJournalQuestObjective )
	{
		var str : string;
		
		if ( objective.GetCount() <= 0 )
		{
			
			return;
		}
		
		str = GetLocStringById( objective.GetTitleStringId() ) + GetQuestObjectiveCounterText( objective );
		m_fxUpdateObjectiveCounterSFF.InvokeSelfTwoArgs( FlashArgInt( GetObjectiveIndex( objective ) ), FlashArgString( str ) );
	}
	
	var _highlightedObjective : CJournalQuestObjective;
	
	public function HighlightObjective( objective : CJournalQuestObjective )
	{
		_highlightedObjective = objective;

		
		m_fxUpdateObjectiveUnhighlightAllSFF.InvokeSelf();
		
		m_fxUpdateObjectiveHighlightSFF.InvokeSelfTwoArgs( FlashArgInt( GetObjectiveIndex( objective ) ), FlashArgBool( true ) );
	}

	private function ShowQuestTracker( show : bool )
	{
		m_fxShowTrackedQuestSFF.InvokeSelfOneArg( FlashArgBool( show ) );
	}

	
	

	private function GetObjectiveIndex( objective : CJournalQuestObjective ) : int
	{
		var i : int;
		
		for ( i = 0; i < m_systemObjectives.Size(); i += 1 )
		{
			if ( objective == m_systemObjectives[ i ].objectiveEntry )
			{
				return i;
			}
		}
		return -1;
	}

	protected function GetColorByQuestType( journalQuest : CJournalQuest ) : int
	{
		switch ( journalQuest.GetType() )
		{
		case Story:
			return 0xffcc00;
		case Chapter:
			return 0xbb8237;
		case Side:
		case MonsterHunt:
		case TreasureHunt:
			return 0xc0c0c0;
		}
		return 0xffffff;
	}
	
	function ShowElement( show : bool, optional bImmediately : bool )
	{
		m_fxShowElementSFF.InvokeSelfTwoArgs( FlashArgBool( show ), FlashArgBool( bImmediately ) );
	}	

	function SetEnabled( value : bool )
	{
		m_bEnabled = value;
		m_fxSetEnabledSFF.InvokeSelfOneArg( FlashArgBool( m_bEnabled ) );
	}
}

function GetQuestObjectiveCounterText( objectiveEntry :CJournalQuestObjective ) : string
{
	var audioLanguage : string;
	var language 	  : string;
	var manager		: CWitcherJournalManager = theGame.GetJournalManager();
			
	theGame.GetGameLanguageName(audioLanguage,language);
	
	if ( objectiveEntry.GetCount() > 0 )
	{
		if (language == "AR")
		{
			return manager.GetQuestObjectiveCount( objectiveEntry.guid ) + "/" + objectiveEntry.GetCount() + "&nbsp;";
		}
		else
			{
			return "&nbsp;" + manager.GetQuestObjectiveCount( objectiveEntry.guid ) + "/" + objectiveEntry.GetCount();
		}
	}
	return "";
}
