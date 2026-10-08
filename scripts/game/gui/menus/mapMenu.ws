/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4MapMenu extends CR4MenuBase
{
	private var m_shownArea   : name;
	private var m_currentArea : name;

	private var m_fxRemoveUserMapPin : CScriptedFlashFunction;
	private var m_fxSetMapZooms : CScriptedFlashFunction;
	private var m_fxSetMapVisibilityBoundaries : CScriptedFlashFunction;
	private var m_fxSetMapScrollingBoundaries : CScriptedFlashFunction;
	private var m_fxSetMapSettings : CScriptedFlashFunction;
	private var m_fxReinitializeMap : CScriptedFlashFunction;
	private var m_fxEnableDebugMode : CScriptedFlashFunction;
	private var m_fxEnableUnlimitedZoom : CScriptedFlashFunction;
	private var m_fxEnableManualLod : CScriptedFlashFunction;
	private var m_fxShowBorders : CScriptedFlashFunction;
	private var m_fxSetDefaultPosition : CScriptedFlashFunction;
	private var m_fxShowToussaint : CScriptedFlashFunction;
	private var m_fxSetHighlightedMapPin : CScriptedFlashFunction;

	private var m_userPinNames 		: array< name >;

	var currentTag			: name;

	private var m_hasGoneBackToUniverse : bool; default m_hasGoneBackToUniverse = false;
	private var m_lastSide : string; default m_lastSide = "";

	event  OnConfigUI()
	{
		var initData : W3MapInitData;
		var manager : CCommonMapManager;
		var waypointPinLimit, otherPinLimit : int;

		manager = theGame.GetCommonMapManager();
		if ( manager )
		{
			manager.GetUserPinNames( m_userPinNames );

			waypointPinLimit = 5;
			otherPinLimit    = 30;
			manager.GetUserMapPinLimits( waypointPinLimit, otherPinLimit );
		}

		m_menuState = 'GlobalMap';
		
		theGame.Pause("MapMenuNotTraveling");

		
		initData = (W3MapInitData)GetMenuInitData();
		if ( initData )
		{
			if(ShouldProcessTutorial('TutorialFastTravelHighlight'))
			{
				
				if(initData.GetTriggeredExitEntity() || initData.GetUsedFastTravelEntity() || thePlayer.IsOnBoat())
				{
					GameplayFactsAdd("tutorial_fast_travel_open", 1, 1);
				}
			}
		}

		super.OnConfigUI();

		
		UpdateRestrictDirectClosing(true);

		m_flashModule = GetMenuFlash();

		m_fxRemoveUserMapPin           = m_flashModule.GetMemberFlashFunction( "RemoveUserMapPin" );
		m_fxSetMapZooms                = m_flashModule.GetMemberFlashFunction( "SetMapZooms" );
		m_fxSetMapVisibilityBoundaries = m_flashModule.GetMemberFlashFunction( "SetMapVisibilityBoundaries" );
		m_fxSetMapScrollingBoundaries  = m_flashModule.GetMemberFlashFunction( "SetMapScrollingBoundaries" );
		m_fxSetMapSettings             = m_flashModule.GetMemberFlashFunction( "SetMapSettings" );
		m_fxReinitializeMap            = m_flashModule.GetMemberFlashFunction( "ReinitializeMap" );
		m_fxEnableDebugMode            = m_flashModule.GetMemberFlashFunction( "EnableDebugMode" );
		m_fxEnableUnlimitedZoom        = m_flashModule.GetMemberFlashFunction( "EnableUnlimitedZoom" );
		m_fxEnableManualLod            = m_flashModule.GetMemberFlashFunction( "EnableManualLod" );
		m_fxShowBorders                = m_flashModule.GetMemberFlashFunction( "ShowBorders" );
		m_fxSetDefaultPosition         = m_flashModule.GetMemberFlashFunction( "setDefaultMapPostion" );
		m_fxShowToussaint              = m_flashModule.GetMemberFlashFunction( "ShowToussaint" );
		m_fxSetHighlightedMapPin       = m_flashModule.GetMemberFlashFunction( "SetHighlightedMapPin" );

		Initialize();

		UpdateActiveAreas();
		SelectCurrentModule();

		UpdateCurrentQuestData( false );
		SendAllQuests();

		
		if (!((W3MenuInitData)GetMenuInitData()))
		{
			SetMenuState('GlobalMap');
		}

		
		
		
		
		
		
		
		

		m_fxShowToussaint.InvokeSelfOneArg( FlashArgBool( theGame.GetDLCManager().IsEP2Available() ) );
		UpdatePlayerLevel();


		
		if(!FactsDoesExist("nge_map_menu_filter"))
		{
			FactsSet("nge_map_menu_filter", 1, -1);
			GetMenuFlashValueStorage().SetFlashInt( "worldmap.global.set.index", 1 );
		}
		else
		{
			OnSetInitialFilters();
		}
		
	}

	
	event  OnSetInitialFilters()
	{
		GetMenuFlashValueStorage().SetFlashInt( "worldmap.global.set.index", FactsQuerySum("nge_map_menu_filter") );
	}

	event  OnFiltersChanged(id : int)
	{
		FactsSet("nge_map_menu_filter", id, -1);
	}
	


	protected function GetSavedDataMenuName() : name
	{
		return m_menuState;
	}

	function Initialize()
	{
		var manager: CCommonMapManager;
	    var worldPath : String;
	    var currentJournalArea : name;

		manager = theGame.GetCommonMapManager();
		worldPath = theGame.GetWorld().GetDepotPath();
		m_currentArea = manager.GetAreaFromWorldPath( worldPath );
		manager.GetCurrentJournalArea( currentJournalArea );

		GetMenuFlashValueStorage().SetFlashString( "worldmap.global.universe.area", NameToString( currentJournalArea ) );

		
		SwitchToHubMap( currentJournalArea, true );

		
        SetCustomHubs();

		
		SwitchToHubMap( currentJournalArea, false );
		GetMenuFlashValueStorage().SetFlashString("map.current.area.name", manager.GetMapName( currentJournalArea ) );
	}

	private function SetCustomHubs()
	{
		var l_flashArray : CScriptedFlashArray;
		var dlcPins : array< SAreaMapPinInfo >;
		var pin : SAreaMapPinInfo;
		var i: int;
		var currentArea : name;
		var isVisible : bool;

		currentArea = theGame.GetCommonMapManager().GetCurrentArea();
		l_flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();

		
		dlcPins = theGame.GetWorldDLCExtender().GetDlcWorldMapPins();
		for ( i = 0; i < dlcPins.Size(); i += 1 )
		{
			pin = dlcPins[ i ];

			
			if ( pin.areaName == 'AN_Bob' )
			{
				continue;
			}

			isVisible = pin.isVisible || FactsQuerySum("hubvisibility_" + pin.flashAreaName) > 0;
			if ( !isVisible )
			{
				continue;
			}

			l_flashArray.PushBackFlashObject( CreateCustomHubObject( pin, currentArea ) );
		}

		GetMenuFlashValueStorage().SetFlashArray("map.hubs.custom", l_flashArray);
	}

	private function CreateCustomHubObject( pin : SAreaMapPinInfo, currentArea: name ) : CScriptedFlashObject
    {
        var l_flashObject : CScriptedFlashObject;
        var isVisible, isEnabled, isQuest, isPlayer, isInArea : bool;

		isInArea = currentArea == pin.areaName;

        
        isVisible = pin.isVisible || FactsQuerySum("hubvisibility_" + pin.flashAreaName) > 0;

        
        isEnabled = pin.isEnabled || FactsQuerySum("hubenabled_" + pin.flashAreaName) > 0;

        
        if ( theGame.GetJournalManager().GetHighlightedObjective().GetWorld() == pin.areaName )
		{
            isQuest = true;
        }

        l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject("Hub_Custom");

        l_flashObject.SetMemberFlashNumber("recLevel", pin.recommendedLevel);
        l_flashObject.SetMemberFlashInt("x", (int)pin.position.X);
        l_flashObject.SetMemberFlashInt("y", (int)pin.position.Y);
        l_flashObject.SetMemberFlashString("worldName", pin.flashAreaName ); 
        l_flashObject.SetMemberFlashString("realName", pin.flashAreaName ); 

        l_flashObject.SetMemberFlashString("uiIcon", "img://icons/hub_" + pin.flashAreaName + ".png"); 

        l_flashObject.SetMemberFlashBool("visible", isVisible);
        l_flashObject.SetMemberFlashBool("enabled", isEnabled);
        l_flashObject.SetMemberFlashBool("isPlayer", isInArea);
        l_flashObject.SetMemberFlashBool("isQuest", isQuest);

        return l_flashObject;
    }

	private function UpdatePlayerLevel()
	{
		var playerLevel : int;
		playerLevel = thePlayer.GetLevel();

		m_flashValueStorage.SetFlashInt( "worldmap.global.universe.playerLevel", playerLevel );
	}
	private function UpdateQuestAreas()
	{
		var manager: CWitcherJournalManager = theGame.GetJournalManager();
	    var areasWithQuests : array< name >;
	    
	    var i : int;
		var flashObject	: CScriptedFlashObject;
		var flashArray 	: CScriptedFlashArray;

		areasWithQuests = manager.GetJournalAreasWithQuests();

		flashArray = m_flashValueStorage.CreateTempFlashArray();
		for ( i = 0; i < areasWithQuests.Size(); i += 1 )
		{
			
			flashObject = m_flashValueStorage.CreateTempFlashObject();
			flashObject.SetMemberFlashString( "area", ConvertAreaNameToWorldName( areasWithQuests[ i ] ) );
			flashArray.PushBackFlashObject( flashObject );
		}
		m_flashValueStorage.SetFlashArray( "worldmap.global.universe.questareas", flashArray );
	}

	private function ConvertAreaNameToWorldName(an : name):string
	{
		switch(an)
		{
			case 'AN_Skellige_ArdSkellig': return "skellige";
			case 'AN_Kaer_Morhen': return "kaer_morhen";
			case 'AN_Wyzima': return "wyzima_castle";
			case 'AN_Bob': return "bob";
			case 'AN_NMLandNovigrad': return "novigrad";
			case 'AN_Velen': return "no_mans_land";
			case 'AN_Prologue_Village': return "prolog_village";
			default: return "";
		}

		return "";
	}

	public  function SetMenuState(newState : name) : void
	{
		SaveStateData();
		super.SetMenuState(newState);
		LogChannel('MAP_STATE',"state "+newState);
		GetSavedData();
		currentTag = UISavedData.selectedTag;
		SelectCurrentModule();
		UpdateInputFeedback();
	}

	
	private function UpdateInputFeedback():void
	{
		m_defaultInputBindings.Clear();
		super.SetButtons();
	}

	protected function SetMapTitle(mapTitle:string):void
	{
		GetMenuFlashValueStorage().SetFlashString( "map.name.set", mapTitle );
	}

	protected function SetCurrentAreaId(areaId : name, onStartup : bool):void
	{
	    var manager : CCommonMapManager = theGame.GetCommonMapManager();

		GetMenuFlashValueStorage().SetFlashUInt( "map.current.area.id", NameToFlashUInt( areaId ) );
		if ( onStartup )
		{
			GetMenuFlashValueStorage().SetFlashString( "map.current.area.name", manager.GetMapName( areaId ) );
		}
	}

	event  OnDebugEvent( id : int )
	{
		LogChannel( 'MapTimer', "Flash " + id );
	}

	function UpdateData( optional ignoreSelectionChange : bool )
	{
		var l_flashArray		: CScriptedFlashArray;

		LogChannel( 'MapTimer', "UpdateData START" );

		UpdateDisabledMapPins();

		LogChannel( 'MapTimer', "UpdateData MIDDLE1" );

		l_flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();
		UpdateEntityPins( l_flashArray );
		if ( IsCurrentAreaShown() )
		{

				UpdatePlayerPin( l_flashArray );
		}
		
		UpdateUserMapPins( l_flashArray, -1 );

		LogChannel( 'MapTimer', "UpdateData MIDDLE2" );

		if (!ignoreSelectionChange)
		{
			GetMenuFlashValueStorage().SetFlashArray(  "worldmap.global.pins.static", l_flashArray );
		}
		else
		{
			GetMenuFlashValueStorage().SetFlashArray(  "worldmap.global.pins.static.update", l_flashArray );
		}

		SendAllQuests();
		UpdateQuestAreas();

		LogChannel( 'MapTimer', "UpdateData END" );
	}

	private function UpdateDisabledMapPins()
	{
		var l_flashArray		: CScriptedFlashArray;
		var l_flashObject		: CScriptedFlashObject;
		var commonMapManager	: CCommonMapManager = theGame.GetCommonMapManager();
		var i					: int;
		var disabledPins		: array< string >;

		disabledPins = commonMapManager.GetDisabledMapPins();

		l_flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();
		for ( i = 0; i < disabledPins.Size(); i += 1)
		{
			l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject();
			l_flashObject.SetMemberFlashString( "pinType", disabledPins[ i ] );
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		GetMenuFlashValueStorage().SetFlashArray(  "worldmap.global.pins.disabled", l_flashArray );
	}

	private function UpdateCurrentQuestData( onHighlight : bool ) : void
	{
		var flashMain				: CScriptedFlashObject;
		var flashQuest				: CScriptedFlashObject;
		var flashObjective			: CScriptedFlashObject;
		var flashArray 				: CScriptedFlashArray;

		var currentQuest			: CJournalQuest;
		var highlightedObjective	: CJournalQuestObjective;
		var objectives : array< SJournalQuestObjectiveData >;
		var i : int;

		flashMain = m_flashValueStorage.CreateTempFlashObject();
		currentQuest =  theGame.GetJournalManager().GetTrackedQuest();
		if ( currentQuest )
		{
			flashQuest = m_flashValueStorage.CreateTempFlashObject();
			flashQuest.SetMemberFlashString( "questName",   GetLocStringById( currentQuest.GetTitleStringId() ) );
			flashQuest.SetMemberFlashInt(    "questType",   (int)currentQuest.GetType() );
			flashQuest.SetMemberFlashInt(    "contentType", (int)currentQuest.GetContentType() );
			flashQuest.SetMemberFlashBool(   "onHighlight", onHighlight );
			m_flashValueStorage.SetFlashObject( "map.quest.name", flashQuest );
			flashMain.SetMemberFlashObject("quest", flashQuest);
		}

		theGame.GetJournalManager().GetTrackedQuestObjectivesData( objectives );
		highlightedObjective = theGame.GetJournalManager().GetHighlightedObjective();

		flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();
		
		for ( i = 0; i < objectives.Size(); i += 1 )
		{
			if ( objectives[ i ].status == JS_Active )
			{
				flashObjective = GetMenuFlashValueStorage().CreateTempFlashObject();
				flashObjective.SetMemberFlashString( "objectiveName", GetLocStringById( objectives[ i ].objectiveEntry.GetTitleStringId() ) + GetQuestObjectiveCounterText( objectives[ i ].objectiveEntry ) );
				flashObjective.SetMemberFlashInt(    "objectiveScriptName", NameToFlashUInt( objectives[ i ].objectiveEntry.GetUniqueScriptTag() ) );
				flashObjective.SetMemberFlashBool(   "highlighted", objectives[ i ].objectiveEntry == highlightedObjective );
				flashObjective.SetMemberFlashBool(   "isQuestTracked", true );
				flashArray.PushBackFlashObject( flashObjective );
			}
		}

		flashMain.SetMemberFlashArray("objectives", flashArray);


		
		
		
		m_flashValueStorage.SetFlashArray(  "map.objectives", flashArray );
		m_flashValueStorage.SetFlashObject( "map.quest.new.objective", flashMain );
		
		
	}

	function GetObjectives( tag : name ) : array<CJournalQuestObjective>
	{	
		var l_objectivesTotal				: int;
		
		var l_objective						: CJournalQuestObjective;
		var questEntry 						: CJournalQuest;
		var l_questPhase 					: CJournalQuestPhase;
		
		var l_objectiveStatus				: EJournalStatus;
		var i, j							: int;
		var highlightedObjective			: CJournalQuestObjective;
		var l_journalManager				: CWitcherJournalManager;
		var retArr							: array<CJournalQuestObjective>;
		
		l_journalManager = theGame.GetJournalManager();

		if (m_initialSelectionsToIgnore == 0)
		{
			m_initialSelectionsToIgnore = 1;
		}
		
		
		questEntry = (CJournalQuest)l_journalManager.GetEntryByTag(tag);
		
		if (!questEntry)
		{
			return retArr;
		}
		
		highlightedObjective = l_journalManager.GetHighlightedObjective();

		for( i = 0; i < questEntry.GetNumChildren(); i += 1 )
		{
			l_questPhase = (CJournalQuestPhase) questEntry.GetChild(i);
			if(l_questPhase)
			{				
				for( j = 0; j < l_questPhase.GetNumChildren(); j += 1 )
				{
					l_objective =( CJournalQuestObjective ) l_questPhase.GetChild(j);
					l_objectiveStatus 	= ( l_journalManager.GetEntryStatus( l_objective ) );
					if( l_objectiveStatus == JS_Active )
					{						
						retArr.PushBack(l_objective);
					}
				}
			}
		}

		return retArr;
	}

	event  OnUpdateNewQuestTrackerObjectives(tag:name):void
	{
		var flashMain				: CScriptedFlashObject;
		var flashQuest				: CScriptedFlashObject;
		var flashObjective			: CScriptedFlashObject;
		var flashArray 				: CScriptedFlashArray;

		var trackedQuest			: CJournalQuest;
		var currentQuest			: CJournalQuest;
		var highlightedObjective	: CJournalQuestObjective;
		var objectives : array< CJournalQuestObjective >;
		var l_objectiveStatus : EJournalStatus;
		var i : int;
		var isQuestTracked : bool = false;

		flashMain = m_flashValueStorage.CreateTempFlashObject();
		trackedQuest =  theGame.GetJournalManager().GetTrackedQuest();
		currentQuest =  (CJournalQuest)theGame.GetJournalManager().GetEntryByTag(tag);
		if ( currentQuest )
		{
			if(trackedQuest == currentQuest)
				isQuestTracked = true;
			flashQuest = m_flashValueStorage.CreateTempFlashObject();
			flashQuest.SetMemberFlashString( "questName",   GetLocStringById( currentQuest.GetTitleStringId() ) );
			flashQuest.SetMemberFlashInt(    "questType",   (int)currentQuest.GetType() );
			flashQuest.SetMemberFlashInt(    "contentType", (int)currentQuest.GetContentType() );
			flashQuest.SetMemberFlashBool(   "onHighlight", false );
			flashQuest.SetMemberFlashUInt(   "scriptName", NameToFlashUInt(currentQuest.GetUniqueScriptTag()) );
			flashMain.SetMemberFlashObject( "quest", flashQuest);
		}

		objectives = GetObjectives(tag);
		highlightedObjective = theGame.GetJournalManager().GetHighlightedObjective();

		flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();
		
		for ( i = 0; i < objectives.Size(); i += 1 )
		{
			flashObjective = GetMenuFlashValueStorage().CreateTempFlashObject();
			flashObjective.SetMemberFlashString( "objectiveName", GetLocStringById( objectives[ i ].GetTitleStringId() ) + GetQuestObjectiveCounterText( objectives[ i ] ) );
			flashObjective.SetMemberFlashInt(    "objectiveScriptName", NameToFlashUInt( objectives[ i ].GetUniqueScriptTag() ) );
			flashObjective.SetMemberFlashBool(   "highlighted", objectives[ i ] == highlightedObjective );
			flashObjective.SetMemberFlashBool(   "isQuestTracked", isQuestTracked );
			flashArray.PushBackFlashObject( flashObjective );
		}
		flashMain.SetMemberFlashArray("objectives", flashArray);
		m_flashValueStorage.SetFlashObject( "map.quest.new.objective", flashMain );
	}

	private function FillFallbackDataFromObjective(obj : CJournalQuestObjective, out fallbackFlashObject : CScriptedFlashObject)
	{
		var label : string;
		var description : string;
		var isTracked : bool;
		var journalManager:CWitcherJournalManager = theGame.GetJournalManager();
		var curQuest : CJournalQuest = obj.GetParentQuest();

		label = GetLocStringById( curQuest.GetTitleStringId() );
		description = GetLocStringById( obj.GetTitleStringId() ) + GetQuestObjectiveCounterText( obj );
		isTracked = journalManager.GetTrackedQuest().guid == curQuest.guid;


		fallbackFlashObject.SetMemberFlashBool( "tracked",      isTracked );
		fallbackFlashObject.SetMemberFlashString( "label", label );
		fallbackFlashObject.SetMemberFlashString( "description", description );
	}

	event  OnShowQuestOnMap(tag:name):void
	{
		var objectives : array< CJournalQuestObjective >;
		var l_objectiveMapPin : CJournalQuestMapPin;
		var i, j : int;
		var childCount : int;
		var fallback : bool = false;
		var flashObject 			: CScriptedFlashObject;
		var fallbackFlashObject 	: CScriptedFlashObject;
		var flashArray 				: CScriptedFlashArray;

		objectives = GetObjectives(tag);

		fallbackFlashObject = GetMenuFlashValueStorage().CreateTempFlashObject();
		flashObject = GetMenuFlashValueStorage().CreateTempFlashObject();
		flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();

		for(i = 0; i < objectives.Size(); i+=1)
		{
			if(objectives[i] && !fallback)
			{
				FillFallbackDataFromObjective(objectives[i], fallbackFlashObject);
				fallback = true;
			}
			childCount = objectives[i].GetNumChildren();
			for(j = 0; j < childCount; j+= 1)
			{
				l_objectiveMapPin = (CJournalQuestMapPin)objectives[i].GetChild(j);

				if(l_objectiveMapPin)
				{
					flashArray.PushBackFlashInt(NameToFlashUInt(l_objectiveMapPin.GetMapPinID()));
				}
			}
		}

		flashObject.SetMemberFlashArray("array", flashArray);
		if(fallback)
			flashObject.SetMemberFlashObject("fallbackData", fallbackFlashObject);

		m_flashValueStorage.SetFlashObject("map.show.pin.from.list", flashObject);
	}

	event  OnShowObjectiveOnMap(questTag:name, tag:name):void
	{
		var objectives : array< CJournalQuestObjective >;
		var l_objectiveMapPin : CJournalQuestMapPin;
		var i, j : int;
		var childCount : int;
		var fallback : bool = false;
		var flashObject 			: CScriptedFlashObject;
		var fallbackFlashObject 	: CScriptedFlashObject;
		var flashArray 				: CScriptedFlashArray;

		objectives = GetObjectives(questTag);

		fallbackFlashObject = GetMenuFlashValueStorage().CreateTempFlashObject();
		flashObject = GetMenuFlashValueStorage().CreateTempFlashObject();
		flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();

		for(i = 0; i < objectives.Size(); i+=1)
		{
			if(objectives[i].GetUniqueScriptTag() != tag)
				continue;

			if(objectives[i] && !fallback)
			{
				FillFallbackDataFromObjective(objectives[i], fallbackFlashObject);
				fallback = true;
			}

			childCount = objectives[i].GetNumChildren();
			for(j = 0; j < childCount; j+= 1)
			{
				l_objectiveMapPin = (CJournalQuestMapPin)objectives[i].GetChild(j);

				if(l_objectiveMapPin)
				{
					flashArray.PushBackFlashInt(NameToFlashUInt(l_objectiveMapPin.GetMapPinID()));
				}
			}
		}

		flashObject.SetMemberFlashArray("array", flashArray);
		if(fallback)
			flashObject.SetMemberFlashObject("fallbackData", fallbackFlashObject);

		m_flashValueStorage.SetFlashObject("map.show.pin.from.list", flashObject);

	}

	function GetQuests() : array<CJournalQuest>
	{
		var tempQuests					: array<CJournalBase>;
		var questTemp					: CJournalQuest;
		var i							: int;

		

		var mainArr, sideArr, monsterArr, treasureArr, ep1Arr, ep2Arr: array<CJournalQuest>;

		var l_questStatus			: EJournalStatus;
		var l_questType				: int;
		var allQuests : array<CJournalQuest>;
		

		var l_journalManager		: CWitcherJournalManager;	
		l_journalManager = theGame.GetJournalManager();

		l_journalManager.GetActivatedOfType( 'CJournalQuest', tempQuests );
		
		for( i = 0; i < tempQuests.Size(); i += 1 )
		{
			questTemp = (CJournalQuest)tempQuests[i];
			if( questTemp )
			{
				
				
					allQuests.PushBack(questTemp);
				
			}
		}
		
		
		
		if( allQuests.Size() > 0 )
		{
			
			for( i = 0; i < allQuests.Size(); i+= 1 )
			{
				l_questType	= allQuests[i].GetType();
				l_questStatus = l_journalManager.GetEntryStatus(allQuests[i]);

				if (l_questStatus == JS_Active)
				{
					switch (l_questType)
					{
					case 0: 
					case 1: 
						mainArr.PushBack(allQuests[i]);
						break;
					case 2: 
						sideArr.PushBack(allQuests[i]);
						break;
					case 3: 
						monsterArr.PushBack(allQuests[i]);
						break;
					case 4: 
						treasureArr.PushBack(allQuests[i]);
						break;

					
					case 6: 
						ep1Arr.PushBack(allQuests[i]);
						break;
					case 7: 
						ep2Arr.PushBack(allQuests[i]);
						break;
					}
				}
			}
			
			
			mainArr = SortArrayByWorld(mainArr);
			sideArr = SortArrayByWorld(sideArr);
			monsterArr = SortArrayByWorld(monsterArr);
			treasureArr = SortArrayByWorld(treasureArr);

			ep1Arr = SortArrayByWorld(ep1Arr);
			ep2Arr = SortArrayByWorld(ep2Arr);

			
			allQuests.Clear();
			for( i = 0; i < mainArr.Size(); i+= 1 )
			{
				allQuests.PushBack(mainArr[i]);
			}
			for( i = 0; i < sideArr.Size(); i+= 1 )
			{
				allQuests.PushBack(sideArr[i]);
			}
			for( i = 0; i < monsterArr.Size(); i+= 1 )
			{
				allQuests.PushBack(monsterArr[i]);
			}
			for( i = 0; i < treasureArr.Size(); i+= 1 )
			{
				allQuests.PushBack(treasureArr[i]);
			}

			for( i = 0; i < ep1Arr.Size(); i+= 1 )
			{
				allQuests.PushBack(ep1Arr[i]);
			}
			for( i = 0; i < ep2Arr.Size(); i+= 1 )
			{
				allQuests.PushBack(ep2Arr[i]);
			}
		}
		return allQuests;
	}

	private function SendAllQuests( ) : void
	{
		var flashQuest				: CScriptedFlashObject;
		var flashArray 				: CScriptedFlashArray;

		var currentQuest			: CJournalQuest;
		var objectives : array< SJournalQuestObjectiveData >;
		var i : int;
		var allQuests : array < CJournalQuest >;

		allQuests = GetQuests();

		currentQuest =  theGame.GetJournalManager().GetTrackedQuest();

		flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();
		for ( i = 0; i < allQuests.Size(); i += 1 )
		{
			flashQuest = GetMenuFlashValueStorage().CreateTempFlashObject();
			flashQuest.SetMemberFlashString( "questName", GetLocStringById( allQuests[i].GetTitleStringId() ) );
			flashQuest.SetMemberFlashInt(    "questScriptName", NameToFlashUInt( allQuests[i].GetUniqueScriptTag() ) );
			flashQuest.SetMemberFlashBool(   "highlighted",  allQuests[ i ] == currentQuest );
			flashQuest.SetMemberFlashInt(    "questType",   (int)allQuests[ i ].GetType() );
			flashQuest.SetMemberFlashInt(    "contentType", (int)allQuests[ i ].GetContentType() );
			flashArray.PushBackFlashObject( flashQuest );
		}

		m_flashValueStorage.SetFlashArray(  "map.quests.new", flashArray );
		
		
	}

	private function UpdateDataWithSingleUserMapPin( indexToUpdate : int )
	{
		var l_flashArray		: CScriptedFlashArray;

		if ( indexToUpdate < 0 )
		{
			return;
		}

		l_flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();

		UpdateUserMapPins( l_flashArray, indexToUpdate );

		GetMenuFlashValueStorage().SetFlashArray(  "worldmap.global.pins.dynamic", l_flashArray );
	}

	private function UpdatePlayerPin( out flashArray : CScriptedFlashArray ) : void
	{
		var l_flashObject		: CScriptedFlashObject;
		var position			: Vector;
		var playerRotation      : EulerAngles;
		var playerAngle         : float;
		var cameraAngle         : float;
		var commonMapManager	: CCommonMapManager = theGame.GetCommonMapManager();

		position = thePlayer.GetWorldPosition();
		cameraAngle = theCamera.GetCameraHeading();
		playerRotation = thePlayer.GetWorldRotation();
		playerAngle = -playerRotation.Yaw;

		if ( playerAngle < 0 )
		{
			playerAngle += 360.0;
		}

		l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject("red.game.witcher3.data.StaticMapPinData");

		l_flashObject.SetMemberFlashUInt(   "id",       NameToFlashUInt( 'Player' ) );
		l_flashObject.SetMemberFlashUInt(    "areaId",	NameToFlashUInt( m_shownArea ) );
		l_flashObject.SetMemberFlashUInt(    "journalAreaId", NameToFlashUInt( commonMapManager.GetJournalAreaByPosition( m_shownArea, position ) ) );
		l_flashObject.SetMemberFlashNumber( "posX",     position.X );
		l_flashObject.SetMemberFlashNumber( "posY",     position.Y );
		if ( (W3ReplacerCiri)thePlayer )
		{
			l_flashObject.SetMemberFlashString( "description", GetLocStringByKeyExt( "map_description_player_ciri"));
			l_flashObject.SetMemberFlashString( "label", 	   GetLocStringByKeyExt( "map_location_player_ciri"));
		}
		else
		{
			l_flashObject.SetMemberFlashString( "description", GetLocStringByKeyExt( "map_description_player"));
			l_flashObject.SetMemberFlashString( "label", 	   GetLocStringByKeyExt( "map_location_player"));
		}
		l_flashObject.SetMemberFlashString( "type",     NameToString( 'Player' ) );
		l_flashObject.SetMemberFlashString( "filteredType", NameToString( 'Player' ) );
		l_flashObject.SetMemberFlashNumber( "radius",	0 );
		l_flashObject.SetMemberFlashBool(   "isFastTravel",	false );
		l_flashObject.SetMemberFlashBool(   "isQuest",	false );
		l_flashObject.SetMemberFlashBool(   "isPlayer",	true );
		l_flashObject.SetMemberFlashBool(   "isUserPin",false );
		l_flashObject.SetMemberFlashNumber( "distance",	0 );
		l_flashObject.SetMemberFlashNumber( "rotation",	playerAngle );

		flashArray.PushBackFlashObject(l_flashObject);
	}

	private function UpdateUserMapPins( out flashArray : CScriptedFlashArray, indexToUpdate : int ) : void
	{
		var manager : CCommonMapManager;
		var i, pinCount			: int;

		if ( indexToUpdate > -1 )
		{
			UpdateUserMapPin( indexToUpdate, flashArray );
		}
		else
		{
			manager = theGame.GetCommonMapManager();
			pinCount = manager.GetUserMapPinCount();
			for ( i = 0; i < pinCount; i += 1 )
			{
				UpdateUserMapPin( i, flashArray );
			}
		}
	}

	private function UpdateUserMapPin( index : int, out flashArray : CScriptedFlashArray ) : void
	{
		var manager : CCommonMapManager = theGame.GetCommonMapManager();
		var l_flashObject		: CScriptedFlashObject;
		var id, type			: int;
		var area 				: name;
		var position			: Vector;
		var playerPosition		: Vector = thePlayer.GetWorldPosition();
		var distanceFromPlayer	: float = 0;

		if ( !manager.GetUserMapPinByIndex( index, id, area, position.X, position.Y, type ) )
		{
			return;
		}

		if ( area == 'AN_Prologue_Village_Winter' )
		{
			area = 'AN_Prologue_Village';
		}
		if ( area != m_shownArea )
		{
			return;
		}

		if ( IsCurrentAreaShown() )
		{
			distanceFromPlayer = VecDistanceSquared2D( playerPosition, position );
		}

		l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject("red.game.witcher3.data.StaticMapPinData");

		position.Z = 0;



		l_flashObject.SetMemberFlashUInt(   "id",       id );
		l_flashObject.SetMemberFlashNumber( "posX",     position.X );
		l_flashObject.SetMemberFlashNumber( "posY",     position.Y );
		l_flashObject.SetMemberFlashString( "description", GetLocStringByKeyExt( "map_description_user"));
		l_flashObject.SetMemberFlashString( "label", 	GetLocStringByKeyExt( "map_location_user"));
		l_flashObject.SetMemberFlashString( "type",     NameToString( GetUserMapPinTypeByType( type ) ) );
		l_flashObject.SetMemberFlashString( "filteredType", NameToString( GetUserMapPinTypeByType( type ) ) );
		l_flashObject.SetMemberFlashNumber( "radius",	0 );
		l_flashObject.SetMemberFlashBool(   "isFastTravel",	false );
		l_flashObject.SetMemberFlashBool(   "isQuest",	false );
		l_flashObject.SetMemberFlashBool(   "isPlayer",	false );
		l_flashObject.SetMemberFlashBool(   "isUserPin", true );
		l_flashObject.SetMemberFlashNumber( "distance",	distanceFromPlayer );
		l_flashObject.SetMemberFlashNumber( "rotation",	0 );

		flashArray.PushBackFlashObject(l_flashObject);
	}

	function GetUserMapPinTypeByType( type : int ) : name
	{
		if ( type < 0 || type >= m_userPinNames.Size() )
		{
			return '';
		}
		return m_userPinNames[ type ];
	}

	function ReinitializeMap()
	{
		m_fxReinitializeMap.InvokeSelf();
	}

	function UpdateActiveAreas() : void
	{
		var pinsList 	    : array< SAvailableFastTravelMapPin >;
		var curPin			: SAvailableFastTravelMapPin;
		var availableAreas  : array< name >;
		var i 				: int;
		var area			: name;
		var areaFlashName	: string;
		var flashStr		: string;
		var areaMapPins 	: array< SAreaMapPinInfo >;
		var areaMapPin 		: SAreaMapPinInfo;

		pinsList = theGame.GetCommonMapManager().GetFastTravelPoints(true, true);
		areaMapPins = theGame.GetCommonMapManager().GetAreaMapPins();

		
		for ( i = 0; i < pinsList.Size(); i += 1 )
		{
			curPin = pinsList[i];
			availableAreas.PushBack( curPin.area );
		}

		
		for ( i = 0; i < areaMapPins.Size(); i += 1 )
		{
			areaMapPin = areaMapPins[i];
			areaFlashName = areaMapPin.flashAreaName;

			if ( areaFlashName != "" )
			{
				area = areaMapPin.areaName;
				flashStr = "universearea." + areaFlashName + ".active";
				m_flashValueStorage.SetFlashBool(flashStr, availableAreas.Contains( area ) );
			}
		}
	}

	function UpdateEntityPins( out flashArray : CScriptedFlashArray ) : void
	{
		var worldPath				: string;
		var mapPinInstances 		: array< SCommonMapPinInstance >;
		var mapPinInstancesCount	: int;
		var pin						: SCommonMapPinInstance;
		var i						: int;
		var l_flashObject			: CScriptedFlashObject;
		var canShowKnownEntities	: bool;
		var canShowDisabledEntities : bool;
		var commonMapManager		: CCommonMapManager = theGame.GetCommonMapManager();
		var playerPosition			: Vector = thePlayer.GetWorldPosition();
		var distanceFromPlayer		: float = 0;
		
		var objGuid : CGUID;
		var objEntry : CJournalQuestObjective;
		var questEntry : CJournalQuest;
		var l_journalManager : CWitcherJournalManager;

		l_journalManager = theGame.GetJournalManager();

		worldPath = commonMapManager.GetWorldPathFromAreaType( m_shownArea );

		mapPinInstances			= commonMapManager.GetMapPinInstances( worldPath );
		mapPinInstancesCount	= mapPinInstances.Size();

		canShowKnownEntities = commonMapManager.CanShowKnownEntities();
		canShowDisabledEntities = commonMapManager.CanShowDisabledEntities();

		for ( i = 0; i < mapPinInstancesCount; i += 1 )
		{
			pin = mapPinInstances[ i ];

			if ( !pin.isDiscovered && !pin.isKnown )
			{
				continue;
			}

			if ( pin.type == 'NPC' ||
				 pin.type == 'Enemy' ||
				 pin.type == 'EnemyDead' ||
				 pin.type == 'GenericFocus' ||
				 pin.type == 'Rift'	||
				 pin.type == 'PointOfInterestMappin' ||
				 pin.type == 'Teleport' ||
				 pin.type == 'HorseRaceTarget' ||
				 pin.type == 'HorseRaceDummy' )
			{
				continue;
			}
			if ( commonMapManager.IsUserPinType( pin.type ) )
			{
				
				continue;
			}

			if ( thePlayer.IsSailing() )
			{
				if ( pin.type == 'RoadSign' )
				{
					continue;
				}
			}
			else
			{
				if ( pin.type == 'Harbor' )
				{
					continue;
				}
			}

			if ( pin.visibleType == 'NotDiscoveredPOI' && !canShowKnownEntities )
			{
				continue;
			}
			if ( pin.visibleType != 'PlaceOfPowerDisabled' && pin.isDisabled && !canShowDisabledEntities )
			{
				continue;
			}

			if ( m_shownArea == 'AN_Dlc_Bob' || m_shownArea == 'AN_Bob' )
			{
				
				if ( pin.position.X > 1200 &&
					 pin.position.Y > 800 &&
					 pin.type != 'User1' &&
					 pin.type != 'User2' &&
					 pin.type != 'User3' &&
					 pin.type != 'User4' &&
					 pin.type != 'User5' &&
					 pin.type != 'User6' &&
					 pin.type != 'User7' )

				{
					continue;
				}
				
				if ( pin.tag == 'mq7024_mutagen_dismantling_table' ||
					 pin.tag == 'mq7024_alchemy_table' ||
					 pin.tag == 'corvo_bianvo_bookshelf_poor' ||
					 pin.tag == 'witcherBed' ||
					 pin.tag == 'corvo_bianco_stables' ||
					 pin.tag == 'mq7024_whetstone' ||
					 pin.tag == 'mq7024_armor_table' )
				{
					continue;
				}
			}

			if ( IsCurrentAreaShown() )
			{
				distanceFromPlayer = VecDistanceSquared2D( playerPosition, pin.position );
			}



			if(commonMapManager.IsQuestPinType(pin.type))
			{
				pin.visibleType = GetStoryQuestVisibleType(pin);
			}

				l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject( "red.game.witcher3.data.StaticMapPinData" );
				l_flashObject.SetMemberFlashUInt(   "id",       NameToFlashUInt( pin.tag ) );
				l_flashObject.SetMemberFlashUInt(	"areaId",   NameToFlashUInt( m_shownArea) );
				l_flashObject.SetMemberFlashUInt(    "journalAreaId", NameToFlashUInt( commonMapManager.GetJournalAreaByPosition( m_shownArea, pin.position ) ) );
				l_flashObject.SetMemberFlashNumber( "posX",     pin.position.X );
				l_flashObject.SetMemberFlashNumber( "posY",     pin.position.Y );

				l_flashObject.SetMemberFlashString( "type",     NameToString( pin.visibleType ) + GetPinTypePostfix( pin ) );
				l_flashObject.SetMemberFlashString( "filteredType", NameToString( pin.visibleType ) );
				l_flashObject.SetMemberFlashNumber( "radius",	pin.visibleRadius );
				l_flashObject.SetMemberFlashBool(   "isFastTravel",	pin.type == 'RoadSign' || pin.type == 'Harbor' || pin.type == 'Transport' );
				l_flashObject.SetMemberFlashBool(   "isQuest",	commonMapManager.IsQuestPinType( pin.type ) );
				l_flashObject.SetMemberFlashBool(   "isPlayer",	false );
				l_flashObject.SetMemberFlashBool(   "isUserPin",false );
				l_flashObject.SetMemberFlashNumber( "distance",	distanceFromPlayer );

				if(commonMapManager.IsQuestPinType(pin.type))
				{
					objEntry = (CJournalQuestObjective)l_journalManager.GetEntryByGuid(pin.guid);

					if(objEntry)
					{
						questEntry = objEntry.GetParentQuest();

						if(questEntry)
						{
							l_flashObject.SetMemberFlashInt( "objScriptName", NameToFlashUInt( objEntry.GetUniqueScriptTag() ) );
							l_flashObject.SetMemberFlashInt( "questScriptName", NameToFlashUInt( questEntry.GetUniqueScriptTag() ) );
						}
					}
				}

				AddPinTypeData(l_flashObject, pin);
				flashArray.PushBackFlashObject(l_flashObject);
		}
	}

	private function GetStoryQuestVisibleType(pin : SCommonMapPinInstance):name
	{
		var objective : CJournalQuestObjective;
		var trackedObjective : CJournalQuestObjective;
		var trackedQuest : CJournalQuest;
		var l_journalManager		: CWitcherJournalManager;	
		var i, j : int;
		var questChildCount, phaseChildCount : int;
		var l_Phase : CJournalQuestPhase;
		var childObjective : CJournalQuestObjective;

		l_journalManager = theGame.GetJournalManager();
		objective = (CJournalQuestObjective)l_journalManager.GetEntryByGuid(pin.guid);
		trackedObjective = l_journalManager.GetHighlightedObjective();
		trackedQuest = l_journalManager.GetTrackedQuest();
		
		if(!objective)
			return '';

		if(trackedObjective && objective == trackedObjective)
			return pin.visibleType;

		if(trackedQuest)
		{
			if(objective && objective.GetParentQuest().guid == trackedQuest.guid)
				return 'QuestObjective';
		}

		return 'QuestObjectiveOther';
	} 

	private function GetPinTypePostfix( pin : SCommonMapPinInstance ) : string
	{
		if ( pin.alternateVersion > 0 && !pin.isDisabled )
		{
			return "_" + pin.alternateVersion;
		}
		return "";
	}

	private function AddPinTypeData(out dataObject : CScriptedFlashObject, targetPin: SCommonMapPinInstance) : void
	{
		var definitionManager : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var journalManager:CWitcherJournalManager;
		var questMappins:array<CJournalBase>;
		var questObjectives:array<CJournalBase>;
		var curQuestMappin:CJournalQuestMapPin;
		var curObjective:CJournalQuestObjective;
		var curQuest:CJournalQuest;

		var isTracked:bool;
		var label:string;
		var description:string;

		label = "";
		description = "";
		switch (targetPin.visibleType)
		{


			
			
			case 'StoryQuest':
			case 'ChapterQuest':
			case 'SideQuest':
			case 'MonsterQuest':
			case 'TreasureQuest':
			
			case 'QuestReturn':
			case 'HorseRace':
			case 'BoatRace':
			case 'QuestBelgard':
			case 'QuestCoronata':
			case 'QuestVermentino':
			case 'QuestObjective':
			case 'QuestObjectiveOther':
				journalManager = theGame.GetJournalManager();
				curObjective = (CJournalQuestObjective)journalManager.GetEntryByGuid( targetPin.guid );
				if ( curObjective )
				{
					curQuest = curObjective.GetParentQuest();

					label = GetLocStringById( curQuest.GetTitleStringId() );
					description = GetLocStringById( curObjective.GetTitleStringId() ) + GetQuestObjectiveCounterText( curObjective );
					isTracked = journalManager.GetTrackedQuest().guid == curQuest.guid;

					dataObject.SetMemberFlashBool( "tracked",      isTracked );
					dataObject.SetMemberFlashBool( "highlighted",  targetPin.isHighlighted );
					
				}
				break;

			case 'Horse':
			case 'Rift':
			case 'Teleport':
			case 'QuestAvailable':
			case 'QuestAvailableHoS':
			case 'QuestAvailableBaW':
			case 'QuestAvailableLy':
			case 'MagicLamp':
			case 'Whetstone':
			case 'Entrance':

			case 'NotDiscoveredPOI':
				label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.visibleType) );
				description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.visibleType) );
				break;


			case 'MonsterNest':
			case 'MonsterNestDisabled':
			case 'InfestedVineyard':
			case 'InfestedVineyardDisabled':
			case 'PlaceOfPower':
			case 'PlaceOfPowerDisabled':
			case 'TreasureHuntMappin':
			case 'TreasureHuntMappinDisabled':
			case 'SpoilsOfWar':
			case 'SpoilsOfWarDisabled':
			case 'BanditCamp':
			case 'BanditCampDisabled':
			case 'BanditCampfire':
			case 'BanditCampfireDisabled':
			case 'BossAndTreasure':
			case 'BossAndTreasureDisabled':
			case 'Contraband':
			case 'ContrabandDisabled':
			case 'ContrabandShip':
			case 'ContrabandShipDisabled':
			case 'RescuingTown':
			case 'RescuingTownDisabled':
			case 'DungeonCrawl':
			case 'DungeonCrawlDisabled':
			case 'Hideout':
			case 'HideoutDisabled':
			case 'Plegmund':
			case 'PlegmundDisabled':
			case 'KnightErrant':
			case 'KnightErrantDisabled':
			case 'WineContract':
			case 'WineContractDisabled':
			case 'SignalingStake':
			case 'SignalingStakeDisabled':




			case 'AlchemyTable':
			case 'MutagenDismantle':
			case 'Stables':
			case 'Bookshelf':
			case 'Bed':
				label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.type) );
				description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.type) );
				break;



			case 'PlayerStash':
			case 'PlayerStashDiscoverable':
				label = GetLocStringByKeyExt( "map_location_playerstash" );
				description = GetLocStringByKeyExt( "map_description_playerstash" );
				break;



			case 'Shopkeeper':
			case 'Blacksmith':
			case 'Armorer':
			
			case 'Hairdresser':
				label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.type) );
				description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.type) );
				break;
			case 'Alchemic':
				label = GetLocStringByKeyExt( StrLower("map_location_alchemic") );
				description = GetLocStringByKeyExt( StrLower("map_description_alchemic") );
				break;
			case 'Herbalist':
				label = GetLocStringByKeyExt( StrLower("herbalist") );
				description = GetLocStringByKeyExt( StrLower("map_description_alchemic") );
				break;
			case 'Innkeeper':
				label = GetLocStringById( 175619 );
				description = GetLocStringByKeyExt( StrLower("map_description_shopkeeper") );
				break;
			case 'Enchanter':
				label = GetLocStringByKeyExt( "panel_map_enchanter_pin_name" );
				description = GetLocStringByKeyExt( "panel_map_enchanter_pin_description" );
				break;



			case 'Torch':
				label       = GetLocStringByKeyExt( "map_location_torch" );
				description = GetLocStringByKeyExt( "map_description_torch" );
				break;



			case 'Prostitute':
				label       = GetLocStringByKeyExt( "novigrad_courtisan" );
				description = GetLocStringByKeyExt( "map_description_prostitute" );
				break;



			case 'ArmorRepairTable':
				label       = GetLocStringByKeyExt( "map_location_armor_repair_table" );
				description = GetLocStringByKeyExt( "map_description_armor_repair_table" );
				break;



			case 'Herb': 
				label       = GetLocStringByKeyExt( definitionManager.GetItemLocalisationKeyName( targetPin.tag ) );
				description = GetLocStringByKeyExt( definitionManager.GetItemLocalisationKeyDesc( targetPin.tag ) );
				break;



			case 'RoadSign':
			case 'Harbor': 
				label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.tag ) );
				description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.tag ) );
				break;



			case 'NoticeBoard':
			case 'NoticeBoardFull':
				label = GetLocStringByKeyExt( StrLower("map_location_noticeboard" ) );
				description = GetLocStringByKeyExt( StrLower("map_description_noticeboard" ) );
				break;



			case 'Boat':
				label = GetLocStringByKeyExt( StrLower("panel_hud_boat" ) );
				description = GetLocStringByKeyExt("map_description_player_boat");
				break;



			default:
				if ( targetPin.customNameId != 0 )
				{
					label = GetLocStringById( targetPin.customNameId );
					description = ""; 
				}
				else
				{
					label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.visibleType) );
					description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.visibleType) );
				}
				break;
		}

		dataObject.SetMemberFlashString( "label", label );
		dataObject.SetMemberFlashString( "description", description );
	}

	event OnToggleMinimap( previewMode : int )
	{
		var value : string;

		value = IntToString( previewMode );
		theGame.GetInGameConfigWrapper().SetVarValue('Hidden', 'WorldMapPreviewMode', value );
		theGame.SaveUserSettings();
	}

	event OnDisablePin( pinName : string, disable : bool )
	{
		theGame.GetCommonMapManager().DisableMapPin( pinName, disable );
	}

	event  OnPinch( value : float )
	{
		
		LogChannel( 'Gui', "CR4MapMenu::OnPinch " + value );
	}

	event  OnClosingMenu()
	{
		var initData : W3MapInitData;
		SaveStateData();
		theGame.GetGuiManager().SetLastOpenedCommonMenuName( GetMenuName() );
		theGame.Unpause("MapMenuNotTraveling");

		initData = (W3MapInitData)GetMenuInitData();
		if ( initData )
		{
			if ( initData && initData.GetTriggeredExitEntity() )
			{
				thePlayer.OnTeleportPlayerToPlayableArea( true );
			}
		}
		super.OnClosingMenu();
	}

	event  OnCloseMenu()
	{
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}

		CloseMenu();
	}

	function SaveStateData()
	{
		switch(m_menuState)
		{
			case 'Objectives':
			case 'FastTravel':
				m_guiManager.UpdateUISavedData( m_menuState, UISavedData.openedCategories, currentTag, UISavedData.selectedModule );
				break;
			case 'GlobalMap':
				return;
		}
	}

	event  OnSwitchToWorldMap()
	{
		var continentMapState : W3TutorialManagerUIHandlerStateContinentMap;

		LogChannel('WORLDMAP',"OnSwitchToWorldMap" );
		SetMapTitle(GetLocStringByKeyExt("panel_map_title_worldmap"));
		UpdateInputFeedback();

		if( ShouldProcessTutorial( 'TutorialMapBackToHub' ) )
		{
			continentMapState = ( W3TutorialManagerUIHandlerStateContinentMap ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if( continentMapState )
			{
				continentMapState.OnWentToContinentMap();
			}
		}
		m_hasGoneBackToUniverse = true;
	}

	event   OnSwitchToHubMap( flashName : string )
	{
		var areaName : name;
		areaName = theGame.GetCommonMapManager().GetAreaFromFlashName( flashName );
		SwitchToHubMap(areaName, false);
	}



	function GetAreaDefaultPosition( areaId : name, out x : float, out y : float ) : void
	{
		switch ( areaId )
		{
			case 'AN_NMLandNovigrad':
				x = -150;
				y = 450;
				break;
			case 'AN_Velen':
				x = -300;
				y = -100;
				break;

			default:
				x = -1;
				y = -1;
		}
	}

	event  OnHighlightNextObjective()
	{
		var highlightedObjective : CJournalQuestObjective;
		var objectives : array< SJournalQuestObjectiveData >;
		var i, newIndex : int;
		var journalManager : CWitcherJournalManager;

		journalManager = theGame.GetJournalManager();
		journalManager.GetTrackedQuestObjectivesData( objectives );
		highlightedObjective = journalManager.GetHighlightedObjective();

		for ( i = objectives.Size() - 1; i >= 0; i -= 1  )
		{
			if ( objectives[ i ].status != JS_Active )
			{
				objectives.Erase( i );
			}
		}
		if ( objectives.Size() < 2 )
		{
			return false;
		}
		for ( i = 0; i < objectives.Size(); i += 1 )
		{
			if ( objectives[ i ].objectiveEntry == highlightedObjective )
			{
				newIndex = ( i + 1 ) % objectives.Size();
				SetHighlightedObjective( objectives[ newIndex ].objectiveEntry );
				return true;
			}
		}
	}

	
	event OnHighlightObjective( tag : name )
	{
		var l_objective						: CJournalQuestObjective;
		var journalManager     				: CWitcherJournalManager;

		journalManager = theGame.GetJournalManager();
		l_objective = (CJournalQuestObjective)journalManager.GetEntryByTag( tag );
		if ( l_objective && journalManager.GetEntryStatus( l_objective ) == JS_Active )
		{
			SetHighlightedObjective( l_objective );
			UpdateData(true);
		}
	}

	event OnHighlightObjectiveWithQuestChange( questTag : name, objTag : name )
	{
		var l_objective						: CJournalQuestObjective;
		var journalManager     				: CWitcherJournalManager;

		OnTrackQuest(questTag);
		OnHighlightObjective(objTag);
		m_flashValueStorage.SetFlashString("map.quest.tracker.state", "normal");
	}

	event OnCycleObjectivesDefault()
	{
		var trackedQuest : CJournalQuest;
		var trackedObjective : CJournalQuestObjective;
		var trackedObjectiveFound : bool = false;
		var trackActionDone : bool = false;
		var fullyLoopedOnce : bool = false;
		var l_journalManager		: CWitcherJournalManager;	
		var i, j : int;
		var nextIndex : int;
		var questChildCount, phaseChildCount : int;
		var l_Phase : CJournalQuestPhase;
		var l_Objective : CJournalQuestObjective;
		var l_AvailableObjectives : array<CJournalQuestObjective>;

		l_journalManager = theGame.GetJournalManager();
		trackedQuest = l_journalManager.GetTrackedQuest();
		trackedObjective = l_journalManager.GetHighlightedObjective();

		if(trackedQuest)
		{
			questChildCount = trackedQuest.GetNumChildren();
			for(i = 0; i < questChildCount; i+= 1)
			{
				l_Phase = (CJournalQuestPhase)trackedQuest.GetChild(i);

				if(!l_Phase || l_journalManager.GetEntryStatus( l_Phase ) != JS_Active)
				{
					continue;
				}
				phaseChildCount = l_Phase.GetNumChildren();
				for(j = 0; j < phaseChildCount; j+= 1)
				{
					l_Objective = (CJournalQuestObjective)l_Phase.GetChild(j);

					if(l_Objective && l_journalManager.GetEntryStatus( l_Objective ) == JS_Active)
						l_AvailableObjectives.PushBack(l_Objective);
				}
			}
		}

		if(l_AvailableObjectives.Size() == 1)
		{
			l_Objective = l_AvailableObjectives[0];
			OnShowObjectiveOnMap(trackedQuest.GetUniqueScriptTag(), l_Objective.GetUniqueScriptTag() );
			return true;
		}
		else if (l_AvailableObjectives.Size() == 0)
		{
			return true;
		}

		for(i = 0; i < l_AvailableObjectives.Size();)
		{
			l_Objective = l_AvailableObjectives[i];

			if(l_Objective == trackedObjective)
				break;
			else {
				l_AvailableObjectives.Erase(i);
				l_AvailableObjectives.PushBack(l_Objective);
			}
		}

		l_Objective = l_AvailableObjectives[1];
		SetHighlightedObjective( l_Objective );
		OnShowObjectiveOnMap(trackedQuest.GetUniqueScriptTag(), l_Objective.GetUniqueScriptTag() );
		UpdateData(true);
		OnPlaySoundEvent("gui_journal_track_quest");
	}

	private function SetHighlightedObjective( objective : CJournalQuestObjective )
	{
		var highlightedMapPinTag : name;

		LogChannel('asdf', "H BEFORE " + theGame.GetCommonMapManager().GetHighlightedMapPinTag() );
		if ( theGame.GetJournalManager().SetHighlightedObjective( objective ) )
		{
			UpdateCurrentQuestData( true );

			highlightedMapPinTag = theGame.GetCommonMapManager().GetHighlightedMapPinTag();

			m_fxSetHighlightedMapPin.InvokeSelfOneArg( FlashArgUInt( NameToFlashUInt( highlightedMapPinTag ) ) );

		}
		LogChannel('asdf', "H AFTER  " + theGame.GetCommonMapManager().GetHighlightedMapPinTag() );
	}

	
	event OnTrackQuest( tag : name )
	{
		var journalManager : CWitcherJournalManager;
		var l_quest	: CJournalBase;

		journalManager = theGame.GetJournalManager();
		l_quest = journalManager.GetEntryByTag(tag);
		journalManager.SetTrackedQuest( l_quest );
		HighlightAnyObjective( l_quest );
		UpdateData(true);
		UpdateCurrentQuestData(false);
		OnPlaySoundEvent("gui_journal_track_quest");
		m_flashValueStorage.SetFlashString("map.quest.tracker.state", "normal");
	}

	event OnShowQuestInJournal( tag : name )
	{
		var commonMenuRef : CR4CommonMenu;
		commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
		if (commonMenuRef)
		{
			commonMenuRef.OpenQuestInJournal(tag);
		}
	}

	event OnTrackQuestFromMappin( questTag : name, objTag : name )
	{
		OnTrackQuest(questTag);
		OnHighlightObjective(objTag);
	}

	protected function HighlightAnyObjective( targetEntry:CJournalBase ):void
	{
		var l_objective						: CJournalQuestObjective;
		var l_questPhase 					: CJournalQuestPhase;
		var trackedQuest					: CJournalQuest;
		var i, j							: int;
		var l_objectiveStatus				: EJournalStatus;
		var l_journalManager 				: CWitcherJournalManager;
		l_journalManager = theGame.GetJournalManager();
		
		trackedQuest = (CJournalQuest)(targetEntry);
		
		if (trackedQuest)
		{
			if (l_journalManager.GetHighlightedObjective().GetParentQuest() != trackedQuest)
			{
				for( i = 0; i < trackedQuest.GetNumChildren(); i += 1 )
				{
					l_questPhase = (CJournalQuestPhase)trackedQuest.GetChild(i);
					if(l_questPhase)
					{				
						for( j = 0; j < l_questPhase.GetNumChildren(); j += 1 )
						{
							l_objective = ( CJournalQuestObjective )l_questPhase.GetChild(j);
							l_objectiveStatus = ( l_journalManager.GetEntryStatus( l_objective ) );
							
							if (l_objectiveStatus == JS_Active)
							{
								l_journalManager.SetHighlightedObjective(l_objective);
								
								return;
							}
						}
					}
				}
			}
		}
	}

	

	function SwitchToHubMap( area : name, onStartup : bool )
	{
		var manager : CCommonMapManager = theGame.GetCommonMapManager();
		var journalArea : name;
		var originArea : name;


		originArea = area;

		if ( area == 'AN_Undefined' || area == '' )
		{
			
			return;
		}

		
		
		

		
		if ( area == 'AN_Velen' || area == 'AN_NMLandNovigrad' )
		{
			
			if ( m_currentArea == 'AN_NMLandNovigrad' )
			{
				
				manager.GetCurrentJournalArea( journalArea );
			}
			else
			{
				
				journalArea = area;
			}

			
			area = 'AN_NMLandNovigrad';
		}

		else
		{
			
			journalArea = area;
		}

		SetMapTitle( GetLocStringByKeyExt( manager.GetLocalisationNameFromAreaType( journalArea ) ) );
		SetCurrentAreaId( originArea, onStartup );
		UpdateDefaultPosition( originArea );
		UpdateInputFeedback();




		if ( area == m_shownArea )

		{
			ReinitializeMap();
		}
		else
		{
			m_shownArea = area;
			UpdateTitle();
			UpdateMapSettings();
			UpdateData();
		}
	}

	event OnEntrySelected( tag : name ) 
	{
		LogChannel('WORLDMAP', "OnEntrySelected tag: "+tag+"  area: ");
		currentTag = tag;
	}

	event   OnSwitchToInterior( )
	{
		LogChannel('WORLDMAP', "OnSwitchToInterior" );
	}

	event  OnUserMapPinSet( posX : float, posY : float, type : int, fromSelectionPanel : bool, insideBounds : bool )
	{
		var manager	: CCommonMapManager = theGame.GetCommonMapManager();
		var worldPath : string;
		var realShownArea : name;
		var area : int;
		var position : Vector;
		var idToAdd, idToRemove, indexToAdd : int;
		var realType : int;

		idToAdd = 0;
		idToRemove = 0;

		if ( m_currentArea == m_shownArea )
		{
			worldPath = theGame.GetWorld().GetDepotPath();
			realShownArea = manager.GetAreaFromWorldPath( worldPath, true );
		}
		else
		{
			realShownArea = m_shownArea;
		}

		position.X = posX;
		position.Y = posY;
		position.Z = 0;

		realType = type;
		if ( fromSelectionPanel )
		{
			realType += 1;
		}
		if ( !manager.ToggleUserMapPin( realShownArea, position, realType, fromSelectionPanel, insideBounds, idToAdd, idToRemove ) )
		{
			showNotification( GetLocStringByKeyExt("panel_hud_message_actionnotallowed") );
		}

		
		if ( idToRemove != 0 )
		{
			m_fxRemoveUserMapPin.InvokeSelfOneArg( FlashArgUInt( idToRemove ) );
			theSound.SoundEvent("gui_hubmap_remove_pin");
		}
		if ( idToAdd != 0 )
		{
			indexToAdd = manager.GetUserMapPinIndexById( idToAdd );
			if ( indexToAdd >= 0 )
			{
				UpdateDataWithSingleUserMapPin( indexToAdd );
				theSound.SoundEvent("gui_hubmap_mark_pin");
			}
		}
	}

	
	function GetAreaNameFromInt( areaNameId : int ) : name
	{
		var areaId : name;
		var i : int;
		var areaMapPins : array< SAreaMapPinInfo >;

		areaMapPins = theGame.GetCommonMapManager().GetAreaMapPins();
		for ( i = 0; i < areaMapPins.Size(); i += 1 )
		{
			areaId = areaMapPins[ i ].areaName;

			if ( NameToFlashUInt( areaId ) == areaNameId )
			{
				break;
			}
		}

		return areaId;
	}

	event  OnStaticMapPinUsed( pinTag : name, areaNameId : int )
	{
		var initData : W3MapInitData;
		var manager	: CCommonMapManager = theGame.GetCommonMapManager();
		var fastTravelEntity : W3FastTravelEntity;
		var loadingInitData : W3MenuInitData;
		var contentTag : name;
		var progress : float;
		var rootMenu : CR4Menu;
		var areaId : name;

		if ( !manager )
		{
			return false;
		}

		areaId = GetAreaNameFromInt( areaNameId );

		if ( !manager.IsWorldAvailable( areaId ) )
		{
			contentTag = manager.GetWorldContentTag( areaId );
			progress = theGame.ProgressToContentAvailable(contentTag);
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowProgressDialog(0, "", "panel_map_cannot_travel_downloading_content", true, UDB_Ok, progress, UMPT_Content, contentTag);
			return false;
		}

		if( !thePlayer.IsActionAllowed( EIAB_FastTravel ) )
		{
			showNotification( GetLocStringByKeyExt("panel_hud_message_actionnotallowed") );
			OnPlaySoundEvent("gui_global_denied");
			return false;
		}

		if ( m_currentArea != areaId )
		{
			if ( !thePlayer.IsActionAllowed( EIAB_FastTravelGlobal ) )
			{
				theSound.SoundEvent("gui_global_denied");
				showNotification( GetLocStringByKeyExt("panel_hud_message_actionnotallowed") );
				return false;
			}
		}

		if ( manager.IsEntityMapPinDisabled( pinTag ) )
		{
			theSound.SoundEvent("gui_global_denied");
			showNotification( GetLocStringByKeyExt("panel_hud_message_actionnotallowed") );
			return false;
		}

		if ( !manager.DBG_IsAllowedFT() )
		{
			if ( thePlayer.IsSailing() )
			{
				
				initData = (W3MapInitData)GetMenuInitData();
				if ( initData && initData.GetTriggeredExitEntity() )
				{
					
					initData.SetTriggeredExitEntity( false );
				}
			}
			else
			{
				initData = (W3MapInitData)GetMenuInitData();
				if ( !initData )
				{
					showNotification( GetLocStringByKeyExt("panel_map_cannot_travel") );
					OnPlaySoundEvent("gui_global_denied");
					return false;
				}
				fastTravelEntity = (W3FastTravelEntity)initData.GetUsedFastTravelEntity();
				if (fastTravelEntity && fastTravelEntity.entityName == pinTag)
				{
					showNotification( GetLocStringByKeyExt("panel_map_cannot_travel_already_here") );
					OnPlaySoundEvent("gui_global_denied");
					return false;
				}
				if ( initData.GetTriggeredExitEntity() )
				{
					
					initData.SetTriggeredExitEntity( false );
				}
			}
		}

		manager.UseMapPin( pinTag, true );

		
		if (areaId == '' )
		{
			areaId == m_shownArea;
		}
		
		manager.SetDesiredFastTravelPoint(pinTag,areaId);

		if ( m_currentArea == areaId)
		{
			manager.PerformLocalFastTravelTeleport( pinTag );
			theGame.Unpause("menus");
			theGame.Unpause("MapMenuNotTraveling");
			if ( !theGame.IsGameTimePaused() )
			{
				theGame.SetGameTime( theGame.GetGameTime() + GameTimeCreate(0, RoundF( RandF() * 4 ), RoundF( RandF() * 60 ), RoundF( RandF() * 60 ) ), true);
			}
		}
		else
		{
			manager.PerformGlobalFastTravelTeleport( m_shownArea, pinTag );
			theGame.Unpause("menus");
			theGame.Unpause("MapMenuNotTraveling");
			if ( !theGame.IsGameTimePaused() )
			{
				theGame.SetGameTime( theGame.GetGameTime() + GameTimeCreate(0, RoundF( RandF() * 10 ), RoundF( RandF() * 60 ), RoundF( RandF() * 60 ) ), true);
			}
		}

		manager.OnFastTravelInitiated( pinTag, areaId );

		rootMenu = theGame.GetGuiManager().GetRootMenu();
		if ( rootMenu )
		{
			rootMenu.CloseMenu();
		}
		return true;
	}

	function UpdateTitle()
	{
		GetMenuFlashValueStorage().SetFlashString("worldmap.title.set", GetMapTitle(), -1 );
	}

	private function UpdateDefaultPosition( areaId : name )
	{
		var defX, defY : float;

		GetAreaDefaultPosition(areaId, defX, defY);
		m_fxSetDefaultPosition.InvokeSelfTwoArgs( FlashArgNumber(defX), FlashArgNumber(defY) );
	}

	private function UpdateMapSettings()
	{
		var mapSize : float;
		var tileCount : int;
		var textureSize : int;
		var imagePath : string;
		var minLod	: int;
		var maxLod	: int;
		var vminX, vmaxX, vminY, vmaxY : int;
		var sminX, smaxX, sminY, smaxY : int;
		var gradientScale : float;
		var previewAvailable : bool;
		var previewModeString : string;
		var previewMode : int;
		var minZoom, maxZoom : float;
		var zoom12, zoom23, zoom34 : float;

		mapSize		= theGame.GetMiniMapSize( m_shownArea );
		tileCount	= theGame.GetMiniMapTileCount( m_shownArea );
		textureSize	= theGame.GetMiniMapTextureSize( m_shownArea );
		minLod		= theGame.GetMiniMapMinLod( m_shownArea );
		maxLod		= theGame.GetMiniMapMaxLod( m_shownArea );

		vminX		= theGame.GetMiniMapVminX( m_shownArea );
		vmaxX		= theGame.GetMiniMapVmaxX( m_shownArea );
		vminY		= theGame.GetMiniMapVminY( m_shownArea );
		vmaxY		= theGame.GetMiniMapVmaxY( m_shownArea );

		sminX		= theGame.GetMiniMapSminX( m_shownArea );
		smaxX		= theGame.GetMiniMapSmaxX( m_shownArea );
		sminY		= theGame.GetMiniMapSminY( m_shownArea );
		smaxY		= theGame.GetMiniMapSmaxY( m_shownArea );

		minZoom		= theGame.GetMiniMapMinZoom( m_shownArea );
		maxZoom		= theGame.GetMiniMapMaxZoom( m_shownArea );
		zoom12		= theGame.GetMiniMapZoom12( m_shownArea );
		zoom23		= theGame.GetMiniMapZoom23( m_shownArea );
		zoom34		= theGame.GetMiniMapZoom34( m_shownArea );

		gradientScale = theGame.GetGradientScale( m_shownArea );

		previewAvailable = theGame.GetPreviewHeight( m_shownArea ) > 0;
		previewModeString = theGame.GetInGameConfigWrapper().GetVarValue('Hidden', 'WorldMapPreviewMode' );
		if ( StrLen( previewModeString ) > 0 )
		{
			previewMode = StringToInt( previewModeString );
		}
		if ( previewMode == 0)
		{
			previewMode = 1;
		}



		imagePath	= GetShownMapName();

		m_fxSetMapZooms.InvokeSelfFiveArgs( FlashArgNumber( minZoom ), FlashArgNumber( maxZoom ), FlashArgNumber( zoom12 ), FlashArgNumber( zoom23 ), FlashArgNumber( zoom34 ) );
		m_fxSetMapVisibilityBoundaries.InvokeSelfFiveArgs( FlashArgInt( vminX ), FlashArgInt( vmaxX ), FlashArgInt( vminY ), FlashArgInt( vmaxY ), FlashArgNumber( gradientScale ) );
		m_fxSetMapScrollingBoundaries.InvokeSelfFourArgs( FlashArgInt( sminX ), FlashArgInt( smaxX ), FlashArgInt( sminY ), FlashArgInt( smaxY ) );
		m_fxSetMapSettings.InvokeSelfEightArgs( FlashArgNumber( mapSize ), FlashArgInt( tileCount ), FlashArgInt( textureSize ), FlashArgInt( minLod ), FlashArgInt( maxLod ), FlashArgString( imagePath ), FlashArgBool( previewAvailable ), FlashArgInt( previewMode ) );
	}

	function GetShownMapName() : string
	{
	    var manager : CCommonMapManager = theGame.GetCommonMapManager();

		return manager.GetMapName( m_shownArea );
	}

	function GetMapTitle() : string
	{
	    var manager : CCommonMapManager = theGame.GetCommonMapManager();

		return manager.GetLocalisationNameFromAreaType( m_shownArea );
	}

	function GetShownMapType() : name
	{
		return m_shownArea;
	}

	function IsCurrentAreaShown() : bool
	{
		return m_currentArea == m_shownArea;
	}

	event  OnSkipPressed()
	{
		OnCloseMenu();
	}

	event OnCategoryOpened( categoryName : name, opened : bool )
	{
		var i : int;

		if( categoryName == 'None' )
		{
			return false;
		}
		if( opened )
		{
			if( UISavedData.openedCategories.FindFirst(categoryName) == -1 )
			{
				UISavedData.openedCategories.PushBack(categoryName);
			}
		}
		else
		{
			i = UISavedData.openedCategories.FindFirst(categoryName);
			if( i > -1 )
			{
				UISavedData.openedCategories.Erase(i);
			}
		}
	}

	public function EnableDebugMode( enable : bool )
	{
		m_fxEnableDebugMode.InvokeSelfOneArg( FlashArgBool( enable ) );
	}

	public function EnableUnlimitedZoom( enable : bool )
	{
		m_fxEnableUnlimitedZoom.InvokeSelfOneArg( FlashArgBool( enable ) );
	}

	public function EnableManualLod( enable : bool )
	{
		m_fxEnableManualLod.InvokeSelfOneArg( FlashArgBool( enable ) );
	}

	public function ShowBorders( show : bool )
	{
		m_fxShowBorders.InvokeSelfOneArg( FlashArgBool( show ) );
	}

	function PlayOpenSoundEvent()
	{
		
		
	}

	event  OnDebugTeleportToHighlightedMappin( posX : float , posY : float )
	{
		if( !theGame.IsFinalBuild() )
		{
			thePlayer.DebugTeleportToPin( posX , posY );
		}
	}



	event  OnRequestQuestTrackerState(newState : string)  : void
	{
		m_flashValueStorage.SetFlashString("map.quest.tracker.state", newState);
	}
}

exec function map_debug( enable : bool )
{
	var manager : CR4GuiManager;
	var rootMenu : CR4Menu;
	var mapMenu : CR4MapMenu;

	manager = (CR4GuiManager)theGame.GetGuiManager();
	if ( manager )
	{
		rootMenu = manager.GetRootMenu();
		if ( rootMenu )
		{
			mapMenu = (CR4MapMenu)rootMenu.GetSubMenu();
			if ( mapMenu )
			{
				mapMenu.EnableDebugMode( enable );
			}
		}
	}
}

exec function map_unlimitedzoom( enable : bool )
{
	var manager : CR4GuiManager;
	var rootMenu : CR4Menu;
	var mapMenu : CR4MapMenu;

	manager = (CR4GuiManager)theGame.GetGuiManager();
	if ( manager )
	{
		rootMenu = manager.GetRootMenu();
		if ( rootMenu )
		{
			mapMenu = (CR4MapMenu)rootMenu.GetSubMenu();
			if ( mapMenu )
			{
				mapMenu.EnableUnlimitedZoom( enable );
			}
		}
	}
}

exec function map_manuallod( enable : bool )
{
	var manager : CR4GuiManager;
	var rootMenu : CR4Menu;
	var mapMenu : CR4MapMenu;

	manager = (CR4GuiManager)theGame.GetGuiManager();
	if ( manager )
	{
		rootMenu = manager.GetRootMenu();
		if ( rootMenu )
		{
			mapMenu = (CR4MapMenu)rootMenu.GetSubMenu();
			if ( mapMenu )
			{
				mapMenu.EnableManualLod( enable );
			}
		}
	}
}

exec function map_borders( show : bool )
{
	var manager : CR4GuiManager;
	var rootMenu : CR4Menu;
	var mapMenu : CR4MapMenu;

	manager = (CR4GuiManager)theGame.GetGuiManager();
	if ( manager )
	{
		rootMenu = manager.GetRootMenu();
		if ( rootMenu )
		{
			mapMenu = (CR4MapMenu)rootMenu.GetSubMenu();
			if ( mapMenu )
			{
				mapMenu.ShowBorders( show );
			}
		}
	}
}

exec function innkeep()
{
	var numbers : array< int >;
	var i : int;

	numbers.PushBack(175619);
	numbers.PushBack(475415);
	numbers.PushBack(538568);
	numbers.PushBack(1084890); 

	for ( i = 0; i < numbers.Size(); i += 1 )
	{
		LogChannel('asdf', numbers[ i ] + " [" + GetLocStringById( numbers[ i ] ) + "]");
	}
}

exec function poi()
{
	LogChannel( 'asd', "[" + GetLocStringByKey("option_miminapPoiQuestionMarks") + "]" );
	LogChannel( 'asd', "[" + GetLocStringByKey("option_MinimapPoiCompletedIcons") + "]" );
}