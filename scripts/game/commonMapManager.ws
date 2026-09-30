/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SAreaMapPinInfo
{
	import var areaName : name;
	import var position : Vector;
	import var worldPath : string;
	import var flashAreaName : string;
	import var requiredChunk : name;
	import var localisationName : name;
	import var localisationDescription : name;
	import var recommendedLevel : int;
	import var isVisible : bool;
	import var isEnabled : bool;
};

import struct SEntityMapPinInfo
{
	import var entityName							: name;
	import var entityTags							: TagList;
	import var entityPosition						: Vector;
	import var entityType							: name;
	import var fastTravelGroupName					: name;
	import var fastTravelTeleportWayPointTag		: name;
	import var fastTravelTeleportWayPointPosition	: Vector;
	import var fastTravelTeleportWayPointRotation	: EulerAngles;
	import var transportPairedEntityName			: name;
	import var pocketIdx							: int;
}

import struct SCommonMapPinInstance
{
	import var id : int;
	import var tag : name;
	import var customNameId : int;
	import var extraTag : name;
	import var type : name;
	import var visibleType : name;
	import var alternateVersion : int;
	import var position : Vector;
	import var radius : float;
	import var visibleRadius : float;
	import var guid : CGUID;
	import var isKnown : bool;
	import var isDiscovered : bool;
	import var isDisabled : bool;
	import var isHighlightable : bool;
	import var isHighlighted : bool;
	import var canBePointedByArrow : bool;
}

import struct SMapPathInstance
{
	import var id			: int;
	import var position		: Vector;
	import var splinePoints : array< Vector >;
	import var color		: int;
	import var lineWidth	: float;
}

import struct SCustomMapPinDefinition
{
	import var tag : name;
	import var type : name;
}

struct SAvailableFastTravelMapPin
{
	var tag	: name;
	var type : name;
	var area : name;
}

import abstract class CCommonMapManager extends IGameSystem
{
	private var m_destinationPinTag			: name;
	private var m_debugTeleportWaypointTag	: name;

	private var m_noSaveLock				: int;

	private var m_dbgShowKnownPins			: bool;
	private var m_dbgShowPins				: bool;
	private var m_dbgShowAllFT				: bool;
	private var m_dbgAllowFT				: bool;
	
	private var m_borderTeleportPosition : Vector;
	private var m_borderTeleportRotation : EulerAngles;
	
	private var m_lastGlobalFastTravelArea : name;
	private var m_lastGlobalFastTravelPosition : Vector;
	
	private var savedFastTravelPinTag		: name;
	private var savedFastTravelArea			: name;

	private var storeNextFastTravel			: bool;
	
	import final function InitializeMinimapManager( minimapModule : CR4HudModule );
	import final function SetHintWaypointParameters( maxRemovalDistance : float, minPlacingDistance : float, refreshInterval : float, pathfindingTolerance : float, maxCount : int );
	import final function OnChangedMinimapRadius( radius : float, zoom : float );
	import final function IsFastTravellingEnabled() : bool;
	import final function EnableFastTravelling( enable : bool );
	import final function IsEntityMapPinKnown( tag : name ) : bool;
	import final function SetEntityMapPinKnown( tag : name, optional enabled : bool );
	import final function IsEntityMapPinDiscovered( tag : name ) : bool;
	import final function SetEntityMapPinDiscovered( tag : name, optional enabled : bool );
	import final function IsEntityMapPinDisabled( tag : name ) : bool;
	import final function SetEntityMapPinDisabled( tag : name, optional enabled : bool );
	import final function IsQuestPinType( type : name ) : bool;
	import final function IsUserPinType( type : name ) : bool;
	import final function GetUserPinNames( out names : array< name > );
	import final function ShowKnownEntities( show : bool );
	import final function CanShowKnownEntities() : bool;
	import final function ShowDisabledEntities( show : bool );
	import final function CanShowDisabledEntities() : bool;
	import final function ShowFocusClues( optional show : bool );
	import final function ShowHintWaypoints( optional show : bool );
	import final function AddQuestLootContainer( container : CEntity );
	import final function DeleteQuestLootContainer( container : CEntity );
	import final function CacheMapPins();
	import final function GetMapPinInstances( worldPath : string ) : array< SCommonMapPinInstance >;
	import final function GetMapPinTypeByTag( mapPinTag : name ) : name;
	import final function GetHighlightedMapPinTag() : name;
	import final function TogglePathsInfo( optional toggle : bool );
	import final function ToggleQuestAgentsInfo( optional toggle : bool );
	import final function ToggleShopkeepersInfo( optional toggle : bool );
	import final function ToggleInteriorInfo( optional toggle : bool );
	import final function ToggleUserPinsInfo( optional toggle : bool );
	import final function TogglePinsInfo( optional flags : int );
	import final function ExportGlobalMapPins();
	import final function ExportEntityMapPins();
	import final function GetAreaMapPins() : array< SAreaMapPinInfo >;
	import final function GetEntityMapPins( worldPath : string ) : array< SEntityMapPinInfo >;
	import final function UseMapPin( pinTag : name, onStart : bool ) : bool;
	import final function UseInteriorsForQuestMapPins( use : bool );
	import final function EnableShopkeeper( tag : name, enable : bool );
	import final function EnableMapPath( tag : name, enable : bool, lineWidth : float, segmentLength : float, color : Color );
	import final function EnableDynamicMappin( tag : name, enable : bool, type : name, optional useAgents : bool, optional showAlways : bool );
	import final function InvalidateStaticMapPin( entityName : name );
	import final function ToggleUserMapPin( area : name, position : Vector, type : int, fromSelectionPanel : bool, out indexToAdd : int, out indexToRemove : int ) : int;
	import final function GetUserMapPinLimits( out waypointPinLimit : int, out otherPinLimit : int ) : int;
	import final function GetUserMapPinCount() : int;
	import final function GetUserMapPinByIndex( index : int, out id : int, out area : name, out mapPinX : float, out mapPinY : float, out type : int ) : bool;
	import final function GetUserMapPinIndexById( id : int ) : int;
	import final function GetIdOfFirstUser1MapPin( id : int ) : bool;
	import final function GetCurrentArea() : name;
	import final function NotifyPlayerEnteredBorder( interval : float, position : Vector, rotation : EulerAngles ) : int;
	import final function NotifyPlayerExitedBorder() : int;
	import final function IsWorldAvailable( area : name ) : bool;
	import final function GetWorldContentTag( area : name ) : name;
	import final function GetWorldPercentCompleted( area : int ) : int;
	import final function DisableMapPin( pinName : string, disable : bool ) : bool;
	import final function GetDisabledMapPins() : array< string >;

	
	event OnMapPinChanged()
	{
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnMapPinChanged );
	}

	public function SetEntityMapPinDiscoveredScript(isFastTravelPoint : bool, tag : name, optional enabled : bool )
	{
		var previouslyDiscovered : bool;
		var mapPinType : name;
		var m_guiManager 	  					: CR4GuiManager;
		
		if ( !IsNameValid( tag ) )
		{
			return;
		}

		previouslyDiscovered = IsEntityMapPinDiscovered( tag );

		SetEntityMapPinDiscovered(tag, enabled);
		
		
		if( !previouslyDiscovered && isFastTravelPoint && enabled)
		{
			CheckExplorerAchievement();
		}
		
		if ( !previouslyDiscovered && enabled  )
		{
			mapPinType = GetMappinType( tag );
			if ( mapPinType == 'NoticeBoard' || mapPinType == 'NoticeBoardFull' )
			{
				UpdateHud( 'noticeboard', mapPinType );
				m_guiManager = theGame.GetGuiManager();
				m_guiManager.RegisterNewMappinEntry('noticeboard','noticeboard');
			}
			else if (	mapPinType == 'MonsterNest' ||
						mapPinType == 'InfestedVineyard' ||
						mapPinType == 'PlaceOfPower' ||
						mapPinType == 'TreasureHuntMappin' ||
						mapPinType == 'SpoilsOfWar' ||
						mapPinType == 'BanditCamp' ||
						mapPinType == 'BanditCampfire' ||
						mapPinType == 'BossAndTreasure' ||
						mapPinType == 'Contraband' ||
						mapPinType == 'ContrabandShip' ||
						mapPinType == 'RescuingTown' ||
						mapPinType == 'DungeonCrawl' ||
						mapPinType == 'Hideout' ||
						mapPinType == 'Plegmund' ||
						mapPinType == 'KnightErrant' ||
						mapPinType == 'WineContract' ||
						mapPinType == 'SignalingStake' 

					)
			{
				UpdateHud( mapPinType, mapPinType );
				m_guiManager = theGame.GetGuiManager();
				m_guiManager.RegisterNewMappinEntry( mapPinType, mapPinType );
			}
			else if ( mapPinType == 'Entrance' )
			{
				UpdateHud( 'entrance', mapPinType );
				m_guiManager = theGame.GetGuiManager();
				m_guiManager.RegisterNewMappinEntry('entrance','entrance'); 
			}
			else
			{
				if( ShouldDisplayHudUpdateByType( mapPinType ))
				{
					UpdateHud( tag, mapPinType );
					m_guiManager = theGame.GetGuiManager();
					m_guiManager.RegisterNewMappinEntry(tag,mapPinType);
				}
			}
		}
		
		
		if(!ShouldProcessTutorial('TutorialPOIAppeared') && ShouldProcessTutorial('TutorialPOIUncovered'))
		{
			FactsAdd("tut_uncovered_POI");
		}
	}
	
	public function CheckExplorerAchievement()
	{
		var arr1 : array< SAvailableFastTravelMapPin >;	
		arr1 = GetFastTravelPoints(true, false, false, true, true);
		
		if( arr1.Size() >= 100 )
		{			
			theGame.GetGamerProfile().AddAchievement(EA_Explorer);
		}
		else
		{
			theGame.GetGamerProfile().NoticeAchievementProgress(EA_Explorer, arr1.Size());
		}
	}
	
	public function GetMappinType( tag : name ) : name 
	{
		var i : int;
		var mappinArray : array< SAvailableFastTravelMapPin >;			
		mappinArray = GetMappins(false, false);
		for( i = 0; i < mappinArray.Size(); i += 1 )
		{
			if( mappinArray[i].tag == tag )
			{
				return mappinArray[i].type;
			}
		}
		return '';
	}
	
		
	function GetMappins( onlyDiscovered : bool, onlyEnabled : bool ) : array< SAvailableFastTravelMapPin >  
	{
		var i, j : int;
		var areaMapPins : array< SAreaMapPinInfo >;
		var entityMapPins : array< SEntityMapPinInfo >;
		var pin : SAvailableFastTravelMapPin;
		var pins : array< SAvailableFastTravelMapPin >;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			entityMapPins = GetEntityMapPins( areaMapPins[ i ].worldPath );
			for ( j = 0; j < entityMapPins.Size(); j += 1 )
			{
				if ( onlyDiscovered )
				{
					if ( !IsEntityMapPinDiscovered( entityMapPins[ j ].entityName ) )
					{
						continue;
					}
				}
				if ( onlyEnabled )
				{
					if ( IsEntityMapPinDisabled( entityMapPins[ j ].entityName ) )
					{
						continue;
					}
				}
				pin.tag  = entityMapPins[ j ].entityName;
				pin.type = entityMapPins[ j ].entityType;
				pin.area = areaMapPins[ i ].areaName;
				pins.PushBack( pin );
			}
		}
		return pins;
	}
	
	public function UpdateHud( mappinTag : name, mapPinType : name )
	{
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		hud.OnMapPinUpdate( mappinTag, mapPinType );
	}
	
	function OnGameStarted()
	{
		if ( m_destinationPinTag != '' )
		{
			UseMapPin( m_destinationPinTag, false );
			m_destinationPinTag = '';
		}
		else if ( m_debugTeleportWaypointTag != '' )
		{
			DebugTeleport();
		}

		theGame.GetLootManager().OnAreaChanged( GetCurrentArea() );
		
		DBG_UpdateShownFT();
		DBG_UpdateShownKnownPins();
		DBG_UpdateShownPins();
	}

	function  GetCurrentJournalArea( out areaName : name )
	{
		areaName = GetCurrentJournalAreaByPosition( thePlayer.GetWorldPosition() );
	}

	function GetCurrentJournalAreaByPosition( position : Vector ) : name
	{
		return GetJournalAreaByPosition( GetCurrentArea(), position );
	}

	function GetJournalAreaByPosition( area : name, position : Vector ) : name
	{
		if ( area == 'AN_NMLandNovigrad'  )
		{
			
			
			
			if ( position.X > 970 || position.Y < 1600 )
			{
				return 'AN_Velen';
			}
		}
		else if ( area == 'AN_Prologue_Village_Winter'  )
		{
			return 'AN_Prologue_Village';
		}


		return area;
	}

	function  AddMapPathToMinimap( path : SMapPathInstance )
	{
		var minimapModule : CR4HudModuleMinimap2 = GetMinimap2Module();
		if ( minimapModule )
		{
			minimapModule.AddMapPath( path );
		}
	}

	function  DeleteMapPathsFromMinimap( ids : array< int > )
	{
		var minimapModule : CR4HudModuleMinimap2 = GetMinimap2Module();
		if ( minimapModule )
		{
			minimapModule.DeleteMapPaths( ids );
		}
	}
	
	function  NotifyPlayerEnteredInterior( areaPos : Vector, areaYaw : float, texture : string )
	{
		theGame.GetGuiManager().GetHudEventController().RunEvent_MinimapModule_NotifyPlayerEnteredInterior( areaPos, areaYaw, texture );
	}
	
	function  NotifyPlayerExitedInterior()
	{
		theGame.GetGuiManager().GetHudEventController().RunEvent_MinimapModule_NotifyPlayerExitedInterior();
	}
	
	function  NotifyPlayerMountedBoat()
	{
		theGame.GetGuiManager().GetHudEventController().RunEvent_MinimapModule_NotifyPlayerMountedBoat();
	}
	
	function  NotifyPlayerDismountedBoat()
	{
		theGame.GetGuiManager().GetHudEventController().RunEvent_MinimapModule_NotifyPlayerDismountedBoat();
	}
	
	function  GetCustomMapPinDefinition( out definitions : array< SCustomMapPinDefinition > )
	{
		var definition : SCustomMapPinDefinition;
		
		definitions.Clear();
	
		

		
		
		
		
		
		
		
	}

	function GetKnowableMapPinTypes( out types : array< name > )
	{
		types.Clear();
	
		types.PushBack( 'Entrance' );
		types.PushBack( 'MonsterNest' );
		types.PushBack( 'InfestedVineyard' );
		types.PushBack( 'PlaceOfPower' );
		types.PushBack( 'TreasureHuntMappin' );
		types.PushBack( 'SpoilsOfWar' );
		types.PushBack( 'BanditCamp' );
		types.PushBack( 'BanditCampfire' );
		types.PushBack( 'BossAndTreasure' );
		types.PushBack( 'Contraband' );
		types.PushBack( 'ContrabandShip' );
		types.PushBack( 'RescuingTown' );
		types.PushBack( 'DungeonCrawl' );
		types.PushBack( 'Hideout' );
		types.PushBack( 'Plegmund' );
		types.PushBack( 'KnightErrant' );
		types.PushBack( 'WineContract' );
		types.PushBack( 'SignalingStake' );

	}
	
	function GetDiscoverableMapPinTypes( out types : array< name > )
	{
		types.Clear();
		
		types.PushBack( 'RoadSign' );
		types.PushBack( 'Harbor' );
		types.PushBack( 'MonsterNest' );
		types.PushBack( 'InfestedVineyard' );
		types.PushBack( 'PlaceOfPower' );
		types.PushBack( 'MagicLamp' );
		types.PushBack( 'TreasureHuntMappin' );
		types.PushBack( 'PointOfInterestMappin' );
		
		
		types.PushBack( 'PlayerStashDiscoverable' );
		types.PushBack( 'Rift' );
		types.PushBack( 'Teleport' );
		types.PushBack( 'Whetstone' );
		types.PushBack( 'ArmorRepairTable' );
		types.PushBack( 'AlchemyTable' );
		types.PushBack( 'MutagenDismantle' );
		types.PushBack( 'Stables' );
		types.PushBack( 'Bookshelf' );
		types.PushBack( 'Bed' );
		types.PushBack( 'WitcherHouse' );
		types.PushBack( 'Entrance' );
		types.PushBack( 'SpoilsOfWar' );
		types.PushBack( 'BanditCamp' );
		types.PushBack( 'BanditCampfire' );
		types.PushBack( 'BossAndTreasure' );
		types.PushBack( 'Contraband' );
		types.PushBack( 'ContrabandShip' );
		types.PushBack( 'RescuingTown' );
		types.PushBack( 'DungeonCrawl' );
		types.PushBack( 'Hideout' );
		types.PushBack( 'Plegmund' );
		types.PushBack( 'KnightErrant' );
		types.PushBack( 'WineContract' );
		types.PushBack( 'SignalingStake' );

	}
	
	function GetDisableableMapPinTypes( out regularTypes : array< name >, out disabledTypes : array< name > )
	{
		regularTypes.Clear();
		disabledTypes.Clear();
		
		regularTypes.PushBack(  'MonsterNest' );
		disabledTypes.PushBack( 'MonsterNestDisabled' );
		regularTypes.PushBack(  'InfestedVineyard' );
		disabledTypes.PushBack( 'InfestedVineyardDisabled' );
		regularTypes.PushBack(  'PlaceOfPower' );
		disabledTypes.PushBack( 'PlaceOfPowerDisabled' );
		regularTypes.PushBack(  'TreasureHuntMappin' );
		disabledTypes.PushBack( 'TreasureHuntMappinDisabled' );
		regularTypes.PushBack(  'SpoilsOfWar' );
		disabledTypes.PushBack( 'SpoilsOfWarDisabled' );
		regularTypes.PushBack(  'BanditCamp' );
		disabledTypes.PushBack( 'BanditCampDisabled' );
		regularTypes.PushBack(  'BanditCampfire' );
		disabledTypes.PushBack( 'BanditCampfireDisabled' );
		regularTypes.PushBack(  'BossAndTreasure' );
		disabledTypes.PushBack( 'BossAndTreasureDisabled' );
		regularTypes.PushBack(  'Contraband' );
		disabledTypes.PushBack( 'ContrabandDisabled' );
		regularTypes.PushBack(  'ContrabandShip' );
		disabledTypes.PushBack( 'ContrabandShipDisabled' );
		regularTypes.PushBack(  'RescuingTown' );
		disabledTypes.PushBack( 'RescuingTownDisabled' );
		regularTypes.PushBack(  'DungeonCrawl' );
		disabledTypes.PushBack( 'DungeonCrawlDisabled' );
		regularTypes.PushBack(  'Hideout' );
		disabledTypes.PushBack( 'HideoutDisabled' );
		regularTypes.PushBack(  'Plegmund' );
		disabledTypes.PushBack( 'PlegmundDisabled' );
		regularTypes.PushBack(  'KnightErrant' );
		disabledTypes.PushBack( 'KnightErrantDisabled' );
		regularTypes.PushBack(  'WineContract' );
		disabledTypes.PushBack( 'WineContractDisabled' );
		regularTypes.PushBack(  'SignalingStake' );
		disabledTypes.PushBack( 'SignalingStakeDisabled' );

	}
	
	event OnStartTeleportingPlayerToPlayableArea( position : Vector, rotation : EulerAngles )
	{
		m_borderTeleportPosition = position;
		m_borderTeleportRotation = rotation;
		thePlayer.OnStartTeleportingPlayerToPlayableArea();
	}
	
	public function GetBorderTeleportPosition() : Vector
	{
		return m_borderTeleportPosition;
	}

	public function GetBorderTeleportRotation() : EulerAngles
	{
		return m_borderTeleportRotation;
	}
	
	function ShouldDisplayHudUpdateByType( type : name ) : bool
	{
		switch(type)
		{
			case 'MonsterNest' :
			case 'InfestedVineyard' :
			case 'PlaceOfPower' :
			case 'Rift' :
			case 'Teleport' :
			case 'Whetstone' :
			case 'ArmorRepairTable' :
			case 'AlchemyTable' :
			case 'MutagenDismantle' :
			case 'Stables' :
			case 'Bookshelf' :
			case 'Bed' :
			case 'WitcherHouse' :
			case 'MagicLamp' :
			case 'PlayerStashDiscoverable':
			case '':
				return false;
		}
		return true;
	}

	private function GetMinimap2Module() : CR4HudModuleMinimap2
	{
		var hud : CR4ScriptedHud;
		var minimapModule : CR4HudModuleMinimap2;

		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( !hud )
		{
			return NULL;
		}
		return (CR4HudModuleMinimap2)hud.GetHudModule( "Minimap2Module" );
	}

	
	function  GetAreaMappinsFileName( out filePath : string )
	{
		filePath = "game\world.w2am";
	}

	
	
	
	

	
	function  GetAreaMappinsData( out mappins : array< SAreaMapPinInfo > )
	{
		var i		: int;

		mappins.Clear();

		
		FillAreaMapPinInfo( mappins, 'AN_NMLandNovigrad',           185,  -190,  "levels\novigrad\novigrad.w2w",                    'content4',  'map_location_novigrad',       'map_description_novigrad' );
		FillAreaMapPinInfo( mappins, 'AN_Skellige_ArdSkellig',     -567,   665,  "levels\skellige\skellige.w2w",                    'content5',  'map_location_skellige',       'map_description_skellige' );
		FillAreaMapPinInfo( mappins, 'AN_Kaer_Morhen',              1720, -1098, "levels\kaer_morhen\kaer_morhen.w2w",              'content6',  'map_location_kaer_morhen',    'map_description_kaer_morhen' );
		FillAreaMapPinInfo( mappins, 'AN_Prologue_Village',         797,   250,  "levels\prolog_village\prolog_village.w2w",        'content2',  'map_location_prolog_village', 'map_description_prolog_village' );
		FillAreaMapPinInfo( mappins, 'AN_Wyzima',                   519,   252,  "levels\wyzima_castle\wyzima_castle.w2w",          'content3',  'map_location_wyzima_castle',  'map_description_wyzima_castle' );
		FillAreaMapPinInfo( mappins, 'AN_Island_of_Myst',          -9999, -9999, "levels\island_of_mist\island_of_mist.w2w",        'content7',  'map_location_island_of_myst', 'map_description_island_of_myst' );
		FillAreaMapPinInfo( mappins, 'AN_Spiral',                  -9999, -9999, "levels\the_spiral\spiral.w2w",   			      	'content10', 'map_location_spiral',         'map_description_spiral' );
		FillAreaMapPinInfo( mappins, 'AN_Prologue_Village_Winter',  797,   250,  "levels\prolog_village_winter\prolog_village.w2w", 'content12', 'map_location_prolog_village', 'map_description_prolog_village' );
		FillAreaMapPinInfo( mappins, 'AN_Velen',                    176,   91,   "levels\novigrad\novigrad.w2w",                    'content4',  'map_location_no_mans_land',   'map_description_no_mans_land' );
		
		
		
	}

	function  GetDeprecatedAreaName( area : int ) : name
	{
		switch(area)
		{
			case 0:
				return 'AN_Undefined';
			case 1:
				return 'AN_NMLandNovigrad';
			case 2:
				return 'AN_Skellige_ArdSkellig';
			case 3:
				return 'AN_Kaer_Morhen';
			case 4:
				return 'AN_Prologue_Village';
			case 5:
				return 'AN_Wyzima';
			case 6:
				return 'AN_Island_of_Myst';
			case 7:
				return 'AN_Spiral';
			case 8:
				return 'AN_Prologue_Village_Winter';
			case 9:
				return 'AN_Velen';
			case 10:
				return 'AN_CombatTestLevel';
			case 11:
				return 'AN_Bob';
			default:
			{
				return '';
			}
		}
	}
	
	private function FillAreaMapPinInfo( out mappins : array< SAreaMapPinInfo >, areaType : CName, areaPinX : int, areaPinY : int, worldPath : string, requiredChunk : name, localisationName : name, localisationDescription : name )
	{
		var info 	: SAreaMapPinInfo;

		info.areaName = areaType;
		info.position.X = areaPinX;
		info.position.Y = areaPinY;
		info.position.Z = 0;
		info.worldPath = worldPath;
		info.requiredChunk = requiredChunk;
		info.localisationName = localisationName;
		info.localisationDescription = localisationDescription;
		
		mappins.PushBack( info );
	}
	
	public function ForceSettingLoadingScreenVideoForWorld( worldName : string )
	{
		var area : name;
		var manager : CWitcherJournalManager = theGame.GetJournalManager();
		if ( manager )
		{
			if ( m_lastGlobalFastTravelArea != '' )
			{
				area = GetJournalAreaByPosition( m_lastGlobalFastTravelArea, m_lastGlobalFastTravelPosition );
				m_lastGlobalFastTravelArea = '';
			}
			else
			{
				area = GetAreaFromWorldPath( worldName );
			}
			manager.ForceSettingLoadingScreenVideoForWorld( area );
			manager.ForceSettingLoadingScreenContextNameForWorld( GetLocalisationNameFromAreaType( area ) );
		}
	}
	
	function PerformLocalFastTravelTeleport( destinationPinTag : name )
	{
		var position : Vector;
		var rotation : EulerAngles;
		var contextName : name;
		
		if ( GetLocalFastTravelPointPosition( destinationPinTag, !thePlayer.IsSailing(), position, rotation ) )
		{
			contextName = theGame.GetCommonMapManager().GetLocalisationNameFromAreaType( GetCurrentJournalAreaByPosition( position ) );
			theGame.SetSingleShotLoadingScreen( contextName );
			
			
			rotation.Roll = 0.f;
			rotation.Pitch = 0.f;
			thePlayer.TeleportWithRotation( position, rotation );
			UseMapPin( destinationPinTag, false ); 



			theGame.RequestAutoSave( "fast travel", true );
		}
	}
	
	function PerformGlobalFastTravelTeleport( destinationArea : name, destinationPinTag : name )
	{
		var worldPath : string;
		var position : Vector;
		var rotation : EulerAngles;

		
		m_destinationPinTag = destinationPinTag;

		worldPath = GetWorldPathFromAreaType( destinationArea );
		if ( StrLen( worldPath ) > 0 )
		{
			if ( GetFastTravelPointPosition( worldPath, destinationPinTag, !thePlayer.IsSailing(), position, rotation ) )
			{
				m_lastGlobalFastTravelArea = destinationArea;
				m_lastGlobalFastTravelPosition = position;
				theGame.ScheduleWorldChangeToPosition( worldPath, position, rotation );
			}
			else
			{
				
				theGame.ScheduleWorldChangeToMapPin( worldPath, destinationPinTag );
			}



			theGame.RequestAutoSave( "fast travel", true ); 
		}
	}

	public function SetDebugTeleportWaypoint( tag : name )
	{
		m_debugTeleportWaypointTag = tag;
	}

	private function DebugTeleport()
	{
		var entity : CEntity;
		
		if ( m_debugTeleportWaypointTag != '' )
		{
			entity = theGame.GetEntityByTag( m_debugTeleportWaypointTag );
			if ( entity )
			{
				thePlayer.TeleportWithRotation( entity.GetWorldPosition(), entity.GetWorldRotation() );
			}
			else
			{
				LogAssert( false, "Waypoint [" + m_debugTeleportWaypointTag + "] not found" );
			}
			m_debugTeleportWaypointTag = '';
		}
	}

	
	
	function GetAreaFromWorldPath( worldPath : string, optional noWinterPrologVillage : bool ) : name
	{
		var i : int;
		var areaMapPins : array< SAreaMapPinInfo >;
		var area : name;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			if ( areaMapPins[ i ].worldPath == worldPath )
			{
				area = areaMapPins[ i ].areaName;
				if ( !noWinterPrologVillage )
				{
					if ( area == 'AN_Prologue_Village_Winter' )
					{
						
						area = 'AN_Prologue_Village';
					}
				}
				return area;
			}
		}
		return '';
	}

	function GetAreaFromFlashName( flashName : string ) : name
	{
		var i : int;
		var areaMapPins : array< SAreaMapPinInfo >;
		var area : name;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			if ( areaMapPins[ i ].flashAreaName == flashName )
			{
				area = areaMapPins[ i ].areaName;
				return area;
			}
		}
		return '';
	}


	function GetMapName( areaType : name ) : string
	{
		var i : int;
		var areaMapPins : array< SAreaMapPinInfo >;
		var mapName : string;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			if ( areaMapPins[ i ].areaName == areaType )
			{
				mapName = StrAfterLast( areaMapPins[ i ].worldPath, StrChar( 92 ) ); 
				mapName = StrReplace( mapName, ".w2w", "" );
				return mapName;
			}
		}
		return "";
	}
	
	function GetWorldPathFromAreaType( areaType : name ) : string
	{
		var i : int;
		var areaMapPins : array< SAreaMapPinInfo >;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			if ( areaMapPins[ i ].areaName == areaType )
			{
				return areaMapPins[ i ].worldPath;
			}
		}
		return "";
	}
	
	function GetLocalisationNameFromAreaType( areaType : name ) : name
	{
		var i : int;
		var areaMapPins : array< SAreaMapPinInfo >;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			if ( areaMapPins[ i ].areaName == areaType )
			{
				return areaMapPins[ i ].localisationName;
			}
		}
		return '';
	}

	function GetLocalisationDescriptionFromAreaType( areaType : name ) : name
	{
		var i : int;
		var areaMapPins : array< SAreaMapPinInfo >;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			if ( areaMapPins[ i ].areaName == areaType )
			{
				return areaMapPins[ i ].localisationDescription;
			}
		}
		return '';
	}
	
	event OnManageFastTravelAreas( operation : EQuestManageFastTravelOperation, enable : bool, show : bool, affectedAreas : array< name > )
	{
		
	}

	event OnManageFastTravelPoints( operation : EQuestManageFastTravelOperation, enable : bool, show : bool, affectedFastTravelPoints : array< name > )
	{
		var i : int;
		for ( i = 0; i < affectedFastTravelPoints.Size(); i += 1 )
		{
			ManageFastTravelPoint( operation, enable, show, affectedFastTravelPoints[ i ] );
		}
	}
	
	function ManageFastTravelPoint( operation : EQuestManageFastTravelOperation, enable : bool, show : bool, tag : name )
	{
		if ( operation == QMFT_EnableAndShow || operation == QMFT_EnableOnly )
		{
			SetEntityMapPinDisabled( tag, !enable );
		}
		if ( operation == QMFT_EnableAndShow || operation == QMFT_ShowOnly )
		{
			SetEntityMapPinDiscoveredScript(true, tag, show );
		}
	}
	
	
	function GetFastTravelPoints( onlyDiscovered : bool, onlyEnabled : bool, optional ignoreLand : bool, optional ignoreWater : bool, optional ignoreVelenAndPrologueWinter : bool ) : array< SAvailableFastTravelMapPin >
	{
		var i, j : int;
		var areaMapPins : array< SAreaMapPinInfo >;
		var entityMapPins : array< SEntityMapPinInfo >;
		var pin : SAvailableFastTravelMapPin;
		var pins : array< SAvailableFastTravelMapPin >;
		var type : name;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			if(ignoreVelenAndPrologueWinter && (areaMapPins[i].areaName == 'AN_Velen' || areaMapPins[i].areaName == 'AN_Prologue_Village_Winter' ) )
				continue;
				
			entityMapPins = GetEntityMapPins( areaMapPins[ i ].worldPath );
			for ( j = 0; j < entityMapPins.Size(); j += 1 )
			{
				type = entityMapPins[ j ].entityType;
				if ( type != 'RoadSign' && type != 'Harbor' )
				{
					continue;
				}
				if ( ignoreLand && type == 'RoadSign' )
				{
					continue;
				}
				if ( ignoreWater && type == 'Harbor' )
				{
					continue;
				}

				if ( onlyDiscovered )
				{
					if ( !IsEntityMapPinDiscovered( entityMapPins[ j ].entityName ) )
					{
						continue;
					}
				}
				if ( onlyEnabled )
				{
					if ( IsEntityMapPinDisabled( entityMapPins[ j ].entityName ) )
					{
						continue;
					}
				}
				pin.tag  = entityMapPins[ j ].entityName;
				pin.type = entityMapPins[ j ].entityType;
				pin.area = areaMapPins[ i ].areaName;
				pins.PushBack( pin );
			}
		}
		return pins;
	}

	
	function HasFastTravelPoints( onlyDiscovered : bool, onlyEnabled : bool, optional ignoreLand : bool, optional ignoreWater : bool, optional ignoreVelenAndPrologueWinter : bool ) : bool
	{
		var i, j : int;
		var areaMapPins : array< SAreaMapPinInfo >;
		var entityMapPins : array< SEntityMapPinInfo >;
		var type : name;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			if(ignoreVelenAndPrologueWinter && (areaMapPins[i].areaName == 'AN_Velen' || areaMapPins[i].areaName == 'AN_Prologue_Village_Winter' ) )
				continue;
				
			entityMapPins = GetEntityMapPins( areaMapPins[ i ].worldPath );
			for ( j = 0; j < entityMapPins.Size(); j += 1 )
			{
				type = entityMapPins[ j ].entityType;
				if ( type != 'RoadSign' && type != 'Harbor' )
				{
					continue;
				}
				if ( ignoreLand && type == 'RoadSign' )
				{
					continue;
				}
				if ( ignoreWater && type == 'Harbor' )
				{
					continue;
				}

				if ( onlyDiscovered )
				{
					if ( !IsEntityMapPinDiscovered( entityMapPins[ j ].entityName ) )
					{
						continue;
					}
				}
				if ( onlyEnabled )
				{
					if ( IsEntityMapPinDisabled( entityMapPins[ j ].entityName ) )
					{
						continue;
					}
				}
				
				return true;
			}
		}
		return false;
	}	
	
	function GetKnownableEntityNames() : array< name >
	{
		var i, j : int;
		var areaMapPins : array< SAreaMapPinInfo >;
		var entityMapPins : array< SEntityMapPinInfo >;
		var names : array< name >;
		var type : name;
		var knowableMapPinTypes : array< name >;
	
		GetKnowableMapPinTypes( knowableMapPinTypes);
	
		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			entityMapPins = GetEntityMapPins( areaMapPins[ i ].worldPath );
			for ( j = 0; j < entityMapPins.Size(); j += 1 )
			{
				if ( knowableMapPinTypes.Contains( entityMapPins[ j ].entityType ) )
				{
					names.PushBack( entityMapPins[ j ].entityName );
				}
			}
		}
		return names;
	}
	
	function GetDiscoverableEntityNames() : array< name >
	{
		var i, j : int;
		var areaMapPins : array< SAreaMapPinInfo >;
		var entityMapPins : array< SEntityMapPinInfo >;
		var names : array< name >;
		var type : name;
		var discoverableMapPinTypes : array< name >;
	
		GetDiscoverableMapPinTypes( discoverableMapPinTypes );
	
		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			entityMapPins = GetEntityMapPins( areaMapPins[ i ].worldPath );
			for ( j = 0; j < entityMapPins.Size(); j += 1 )
			{
				if ( discoverableMapPinTypes.Contains( entityMapPins[ j ].entityType ) )
				{
					names.PushBack( entityMapPins[ j ].entityName );
				}
			}
		}
		return names;
	}
	
	function GetLocalFastTravelPointPosition( entityName : name, landOnly : bool, out position : Vector, out rotation : EulerAngles ) : bool
	{
		return GetFastTravelPointPosition( theGame.GetWorld().GetDepotPath(), entityName, landOnly, position, rotation );
	}
	
	function GetFastTravelPointPosition( worldPath : string, entityName : name, landOnly : bool, out position : Vector, out rotation : EulerAngles ) : bool
	{
		var i, j : int;
		var areaMapPins : array< SAreaMapPinInfo >;
		var entityMapPins : array< SEntityMapPinInfo >;
		var type : name;

		areaMapPins = GetAreaMapPins();
	    for ( i = 0; i < areaMapPins.Size(); i += 1 )
	    {
			if ( areaMapPins[ i ].worldPath == worldPath )
			{
				entityMapPins = GetEntityMapPins( areaMapPins[ i ].worldPath );
				for ( j = 0; j < entityMapPins.Size(); j += 1 )
				{
					if ( entityMapPins[ j ].entityName == entityName )
					{
						if ( landOnly && entityMapPins[ j ].entityType == 'RoadSign' )
						{
							position = entityMapPins[ j ].fastTravelTeleportWayPointPosition;
							rotation = entityMapPins[ j ].fastTravelTeleportWayPointRotation;
							return true;
						}
						else if ( !landOnly && entityMapPins[ j ].entityType == 'Harbor' )
						{
							position = entityMapPins[ j ].fastTravelTeleportWayPointPosition;
							rotation = entityMapPins[ j ].fastTravelTeleportWayPointRotation;
							return true;
						}
					}
				}
				break;
			}
		}
		return false;
	}
	
	function AllowSaving( allow : bool )
	{
		if ( allow )
		{
			theGame.ReleaseNoSaveLock( m_noSaveLock );
		}
		else
		{
			m_noSaveLock = 12345;
			theGame.CreateNoSaveLock( "EndOfTheWorld", m_noSaveLock, false, false );
		}
	}

	function DBG_ShowKnownPins( show : bool )
	{
		m_dbgShowKnownPins = show;
		DBG_UpdateShownKnownPins();
	}
	
	function DBG_UpdateShownKnownPins()
	{
		var i : int;
		var arr : array< name >;

		if ( m_dbgShowKnownPins )
		{
			arr = GetKnownableEntityNames();
			for ( i = 0; i < arr.Size(); i += 1 )
			{
				SetEntityMapPinKnown( arr[ i ], true );
			}
		}
	}
	
	function DBG_ShowPins( show : bool )
	{
		m_dbgShowKnownPins = show;
		DBG_UpdateShownKnownPins();
		
		m_dbgShowPins = show;
		DBG_UpdateShownPins();
	}
	
	function DBG_UpdateShownPins()
	{
		var i : int;
		var arr : array< name >;

		if ( m_dbgShowPins )
		{
			arr = GetDiscoverableEntityNames();

			for ( i = 0; i < arr.Size(); i += 1 )
			{
				SetEntityMapPinKnown( arr[ i ], true );
				SetEntityMapPinDiscovered( arr[ i ], true );
			}
		}
	}

	function DBG_ShowAllFT( show : bool )
	{
		m_dbgShowAllFT = show;
		DBG_UpdateShownFT();
	}
	
	function DBG_UpdateShownFT()
	{
		var i : int;
		var arr : array< SAvailableFastTravelMapPin >;

		if ( m_dbgShowAllFT )
		{
			arr = GetFastTravelPoints( false, false );
			for ( i = 0; i < arr.Size(); i += 1 )
			{
				SetEntityMapPinDiscovered( arr[ i ].tag, true );
			}
		}
	}
	
	function DBG_AllowFT( allow : bool )
	{
		m_dbgAllowFT = allow;
	}
	
	function DBG_IsAllowedFT() : bool
	{
		return m_dbgAllowFT;
	}

	function SetNextFastTravelStored( shouldStore : bool )
	{	
		storeNextFastTravel = shouldStore;
	}

	function OnFastTravelInitiated( pinTag: name, areaID : name )
	{
		if ( storeNextFastTravel )
		{
			SetDesiredFastTravelPoint(pinTag,areaID);
		}
	}
	
	public function SetDesiredFastTravelPoint (PinTag : name, areaID : name)
	{
		savedFastTravelPinTag = PinTag;
		savedFastTravelArea = areaID;
	}

	public function GetDesiredFastTravelPoint() : name
	{
		return savedFastTravelPinTag;
	}
	
	public function GetDesiredFastTravelAreaID() :name
	{
		return savedFastTravelArea;
	}
	

	
	public function IsFastTravelRestrictedToCurrentArea() : bool
	{

		return false;
	}
	

	
}

exec function ShowPinsFTInfo()
{
	var commonMapManager : CCommonMapManager;
	
	commonMapManager = theGame.GetCommonMapManager();
	commonMapManager.TogglePinsInfo( 1 );
}

exec function ShowPathsInfo( show : bool )
{
	var commonMapManager : CCommonMapManager;
	
	commonMapManager = theGame.GetCommonMapManager();
	commonMapManager.TogglePathsInfo( show );
}

exec function ShowQuestAgents( show : bool )
{
	var commonMapManager : CCommonMapManager;
	
	commonMapManager = theGame.GetCommonMapManager();
	commonMapManager.ToggleQuestAgentsInfo( show );
}

exec function ShowShopkeepers( show : bool )
{
	var commonMapManager : CCommonMapManager;
	
	commonMapManager = theGame.GetCommonMapManager();
	commonMapManager.ToggleShopkeepersInfo( show );
}

exec function ii()
{
	theGame.GetCommonMapManager().ToggleInteriorInfo( true );
}

exec function upi()
{
	theGame.GetCommonMapManager().ToggleUserPinsInfo( true );
}

exec function ShowPinsInfo( value : int )
{
	var commonMapManager : CCommonMapManager;
	
	commonMapManager = theGame.GetCommonMapManager();
	commonMapManager.TogglePinsInfo( value );
}

exec function exportglobalmappins()
{
	var commonMapManager : CCommonMapManager;
	
	commonMapManager = theGame.GetCommonMapManager();
	commonMapManager.ExportGlobalMapPins();
}

exec function exportentitymappins()
{
	var commonMapManager : CCommonMapManager;
	
	commonMapManager = theGame.GetCommonMapManager();
	commonMapManager.ExportEntityMapPins();
}

exec function useinteriors( use : bool )
{
	var commonMapManager : CCommonMapManager;
	
	commonMapManager = theGame.GetCommonMapManager();
	commonMapManager.UseInteriorsForQuestMapPins( use );
}

exec function testFT()
{
	var commonMapManager : CCommonMapManager;
	var pins : array< SAvailableFastTravelMapPin >;
	var i : int;

	commonMapManager = theGame.GetCommonMapManager();
	pins = commonMapManager.GetFastTravelPoints( false, false );
	
	LogChannel( 'OOOOOO', "--------- AVAILABLE FAST TRAVEL MAP PINS: " + pins.Size() );
	for ( i = 0; i < pins.Size(); i += 1 )
	{
		LogChannel( 'OOOOOO', ">>> " + pins[ i ].area + " " + pins[ i ].type + " " + pins[ i ].tag );
	}
	
	pins = commonMapManager.GetFastTravelPoints( true, true );
	
	LogChannel( 'OOOOOO', "--------- AVAILABLE FAST TRAVEL MAP PINS: " + pins.Size() );
	for ( i = 0; i < pins.Size(); i += 1 )
	{
		LogChannel( 'OOOOOO', ">>> " + pins[ i ].area + " " + pins[ i ].type + " " + pins[ i ].tag );
	}
	LogChannel( 'OOOOOO', "-----------------------------------------" );

}

exec function ShowKnownPins( show : bool )
{
	theGame.GetCommonMapManager().DBG_ShowKnownPins( show );
}

exec function ShowPins( show : bool )
{
	theGame.GetCommonMapManager().DBG_ShowPins( show );
}

exec function ShowAllFT( show : bool )
{
	theGame.GetCommonMapManager().DBG_ShowAllFT( show );
}

exec function AllowFT( allow : bool )
{
	theGame.GetCommonMapManager().DBG_AllowFT( allow );
}

exec function gotoWyzima()
{
	theGame.ScheduleWorldChangeToMapPin( "levels\wyzima_castle\wyzima_castle.w2w", '' );
	theGame.RequestAutoSave( "fast travel", true );
}

exec function gotoNovigrad()
{
	theGame.ScheduleWorldChangeToMapPin( "levels\novigrad\novigrad.w2w", '' );
	theGame.RequestAutoSave( "fast travel", true );
}
exec function gotoSkellige()
{
	theGame.ScheduleWorldChangeToMapPin( "levels\skellige\skellige.w2w", '' );
	theGame.RequestAutoSave( "fast travel", true );
}
exec function gotoKaerMorhen()
{
	theGame.ScheduleWorldChangeToMapPin( "levels\kaer_morhen\kaer_morhen.w2w", '' );
	theGame.RequestAutoSave( "fast travel", true );
}
exec function gotoProlog()
{
	theGame.ScheduleWorldChangeToMapPin( "levels\prolog_village\prolog_village.w2w", '' );
	theGame.RequestAutoSave( "fast travel", true );
}

exec function gotoPrologWinter()
{
	theGame.ScheduleWorldChangeToMapPin( "levels\prolog_village_winter\prolog_village.w2w", '' );
	theGame.RequestAutoSave( "fast travel", true );
}

exec function gotoBob()
{
	theGame.ScheduleWorldChangeToMapPin( "dlc\bob\data\levels\bob\bob.w2w", '' );
	theGame.RequestAutoSave( "fast travel", true );
}



exec function knowMapPin( tag : name )
{
	if ( tag != '' )
	{
		theGame.GetCommonMapManager().SetEntityMapPinKnown( tag, true );
	}
}

exec function discoverMapPin( tag : name )
{
	if ( tag != '' )
	{
		theGame.GetCommonMapManager().SetEntityMapPinDiscovered( tag, true );
	}
}

exec function disableMapPin( tag : name )
{
	if ( tag != '' )
	{
		theGame.GetCommonMapManager().SetEntityMapPinDisabled( tag, true );
	}
}