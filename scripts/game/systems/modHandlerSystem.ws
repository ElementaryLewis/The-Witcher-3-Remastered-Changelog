/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SModioModID
{
	import var modIDInt : Uint64;
}

import struct SModioUser {}

import struct SModTagInfo
{
	import var tagGroupName : string;
	import var tagGroupValues : array<string>;
	import var allowMultipleSelect : bool;
}

import struct SModReportParams
{
	import var paramType : EReportParamType;
	import var desc : string;
	import var optReporterName : string;
	import var optReporterEmail : string;
	import var modIDScr : SModioModID;
	import var user : SModioUser;
	import var notWorkingReason : EReportNotWorkingReason;
}

import struct SModProgressInfo
{
	import var id : SModioModID;	
	import var stage : EModProgressStage;
	import var progress : float;
}

import struct SModDependency
{
	import var id : SModioModID;
	import var displayName : string;
	import var dateAdded : string;
	import var dateUpdated : string;
	import var dependencyDepth : int;
	import var logoURL : string;
}

import struct SModFilterParams
{
	import var filterStrings : array<string>;
	import var allowedTags : array<string>;
	import var excludedTags : array<string>;
	import var author : SModioUser;
	import var sortDirection : EModFilterSortDirection;
	import var sortType : EModFilterSortType;
	import var isPaged : bool;
	import var elementCount : int;
	import var startIndex : int;
}

import struct SModioModData
{
	import var id : SModioModID;	
	import var displayname : string;
	import var desc : string;
	import var summary : string;
	import var downloadsTotal : string;
	import var subscribersTotal : string;
	import var upvotes : string;
	import var downvotes : string;
	import var filesize : string;
	import var ratingDisplayText : string;
	import var version : string;
	import var uploadDate : string;
	import var lastUpdateDate : string;
	import var uploaderUserName : string;
	import var uploaderUser : SModioUser;
	import var uploaderPlatformLinked : bool;
	import var numGalleryImgs : int;
	import var logoURL : string;
	import var uploaderAvatarURL : string;
	import var galleryImgsURLs : array<string>;	
	import var tags : array<string>;		
}

class IModEventScriptListener
{
	event OnModManagementChangedScriptEvent( modidScr : SModioModID, modState : EModState ) {}
	event OnModioNetworkErrorScriptEvent() {}
	event OnModioLocalModsUpdatedScriptEvent() {}
	event OnModioRemoteModsUpdatedScriptEvent() {}
	event OnCDPRAccountLoggedInScriptEvent() {}
}

import class CModHandlerSystem extends IGameSystem
{
	import function IsAuthenticated() : bool;
	import function GetModDataList( out DataList : array< SModioModData > );
	
	import function GetStartupModNames( out DataList : array< string > );
	
	import function GetStartupModioMods( out DataList : array< SModioModID > );
	import function GetRemoteModDataList( out DataList : array< SModioModData > );	
	import function GetCachedRemoteModDataByID( modidScr : SModioModID ) : SModioModData;
	import function GetCachedModRatingByID( modidScr : SModioModID )  : EModRatingType;
	import function GetCachedModDependenciesByID( modidScr : SModioModID, out outModDependencies : array< SModDependency >) : bool;
	import function GetModDataByID( modidScr : SModioModID ) : SModioModData;
	import latent function GetRemoteModDataByID( modidScr : SModioModID, optional timeout : float ) : SModioModData;	
	import latent function RefreshModsLatent( optional timeout : float );
	
	import function GetInstalledModList( filterParams : SModFilterParams, out output : array< SModioModData >, forceRefresh : bool );
	import function HasUninstalledMods() : bool;
	import function SubscribeMod( modidScr : SModioModID );
	import function UnsubscribeMod( modidScr : SModioModID );
	import function IsModSubscribed( modidScr : SModioModID ) : bool;
	import function ForceUninstallMod( modidScr : SModioModID );
	import latent function RequestModMediaLogo( modidScr : SModioModID, optional logosize : EModLogoSize, optional timeout : float ) : string;
	import latent function RequestModMediaAvatar( modidScr : SModioModID, optional avatarsize : EModAvatarSize, optional timeout : float ) : string;
	import latent function RequestModMediaGalleryImg( modidScr : SModioModID, galleryindex: int, optional gallerysize : EModGallerySize, optional timeout : float ) : string;	
	import latent function RequestModListLatent( filterParams : SModFilterParams, out output : array< SModioModData >, optional timeout : float );	
	import latent function RequestModDependencies( modidScr : SModioModID, out outModDependencies : array< SModDependency >, optional timeout : float ) : bool;
	import final function IsModdedSave( info : SSavegameInfo ) : bool;
	import final function GetModNamesInSave( info : SSavegameInfo, out modNames : array< string > );
	import final function CheckHasAllModsInSave( info : SSavegameInfo, out missingModNames : array< SModioModID > ) : bool;
	import final function CheckGameVersionModsInSave( info : SSavegameInfo, out oldVersionModNames : array< SModioModID > ) : bool;
	import final function IsModdedLatestSave( ) : bool;
	import final function CheckHasAllModsInLatestSave( out missingModNames : array< SModioModID > ) : bool;
	import final function CheckGameVersionModsInLatestSave( out oldVersionModNames : array< SModioModID > ) : bool;
	import function SetLocalModDisabled( modidScr : SModioModID, isDisabled : bool );
	import function IsLocalModDisabled( modidScr : SModioModID ) : bool;
	import function SaveLocalModConfig();	
	import function GetLoadOrder( out outLoadPrioOrder : array< Uint64 > );
	import function SetLoadOrder( newLoadPrioOrder : array< Uint64 > );
	import function IsModioUserValid( user : SModioUser ) : bool;
	import function IsModioActive(): bool;
	import function IsModioEnabled(): bool;
	import function SetModioEnabled( enabled: bool );
	import latent function IsModioAvailableLatent( optional timeout : float ) : bool;
	import latent function GetTermsTextLatent( optional timeout : float ): string;
	import latent function OpenLinkInBrowserLatent( linkType : ETermsLinkType, optional timeout : float ) : bool;
	import latent function AuthenticateUserCDPR( hasAcceptedTerms : bool, out isTermsError : bool, optional timeout : float ) : bool;
	import latent function LogoutUser( optional timeout : float ) : bool;
	import function LogoutUserDebug();
	import function SetModManagementEnabled( enabled: bool );
	import function IsModManagementBusy() : bool;
	import function UpvoteMod( modidScr : SModioModID );
	import function DownvoteMod( modidScr : SModioModID );
	import latent function DownvoteModLatent( modidScr : SModioModID, optional timeout : float ) : bool;	
	import function ClearvoteMod( modidScr : SModioModID );	
	import function QueryCurrentModProgress(): SModProgressInfo;
	import function MuteModioUser( modioUser : SModioUser );
	import function UnmuteModioUser( modioUser : SModioUser );
	import function MuteModioAuthorByModID( modidScr : SModioModID ) : bool;
	import function UnmuteModioAuthorByModID( modidScr : SModioModID ) : bool;
	import latent function MuteModioAuthorByModIDLatent( modidScr : SModioModID, optional timeout : float ) : bool;
	import latent function UnmuteModioAuthorByModIDLatent( modidScr : SModioModID, optional timeout : float ) : bool;
	import latent function RetrieveMutedModioUsers( out outMutedUsers : array< SModioUser >, optional timeout : float );
	import latent function RequestModTagInfos( out outModTagInfos : array< SModTagInfo >, optional timeout : float );
	import function GetLocalizedGroupNameFromTagInfo( modTagInfo : SModTagInfo ) : string;
	import function GetLocalizedTagNameFromTagInfo( modTagInfo : SModTagInfo, tagName : string ) : string;
	import function ConvertModIDToString( modidScr : SModioModID ) : string;
	import function CreateModIDFromString( modidStr : string ) : SModioModID;
	import function IsLoggedInCDPR() : bool;
	import function GetStorageInfo( used : bool, cache : bool ) : string;
	import latent function GetSubmittedModRating( modidScr : SModioModID, optional timeout : float ) : EModRatingType;
	import latent function SubmitModReport( modReportParams : SModReportParams, optional timeout : float ) : bool;
	import function HasOutdatedMods() : bool;
	import function HasFailedMods() : bool;
	import function GetOutdatedMods( out outOutdatedMods : array< SModioModID > ) : bool;
	import function GetFailedMods( out outOutdatedMods : array< SModioModID > ) : bool;
	import final function NotifyScriptedListeners( notify : bool );
	import final function GetCurrentUserName() : string;
	import final function GetLastFilteredPageCount() : int;
	import final function GetLastFilteredResultCount() : int;
	import function CheckPlatformUGCAllowed( showMsg : bool, optional timeout : float ) : bool;
	import final function SignalUGCSectionEnded();
	import final function ClearHiddenModsIds();
	import final function ClearMutedModioUsers();
	import final function RefreshMutedModioUsersList();
	import final function RefreshSubmittedModRatings();
	import final function DebugPrintMutedModioUsersList();

	
	
	
	var listeners : array< IModEventScriptListener >;

	function CheckNotifyNeeded()
	{
		if ( listeners.Size() == 1 )
		{
			NotifyScriptedListeners( true );
		}

		if ( listeners.Size() == 0 )
		{
			NotifyScriptedListeners( false );
		}
	}
	
	function AddListener( listener : IModEventScriptListener )
	{	
		if ( listeners.FindFirst( listener ) == -1 )
		{
			listeners.PushBack( listener );	
			CheckNotifyNeeded();
		}	
	}
	
	function RemoveListener( listener : IModEventScriptListener )
	{	
		if ( listeners.Remove( listener ) )
		{
			CheckNotifyNeeded();
		}
	}
	
	event OnModManagementChanged( modidScr : SModioModID, modState : EModState )
	{
		var i, size : int;
		var modidStr : string;
		var modStateStr : string;

		modidStr = theGame.GetModHandlerSystem().ConvertModIDToString(modidScr);

		switch(modState)
		{
			case MS_InstallStarted : 
				modStateStr = "MS_InstallStarted"; break;
			case MS_Installed : 
				modStateStr = "MS_Installed"; break;
			case MS_UpdateStarted : 
				modStateStr = "MS_UpdateStarted"; break;
			case MS_Updated : 
				modStateStr = "MS_Updated"; break;
			case MS_UninstallStarted : 
				modStateStr = "MS_UninstallStarted"; break;
			case MS_Uninstalled : 
				modStateStr = "MS_Uninstalled"; break;			
		}

		LogChannel('MODS', "OnModManagementChanged called in script -- " +  modidStr + "  :  " + modStateStr );
		
		size = listeners.Size();
		for (i=size-1; i>=0; i-=1 )	
		{
			listeners[i].OnModManagementChangedScriptEvent( modidScr, modState );
		}
		return true;
	}

	event OnModioNetworkError()
	{
		var i, size : int;
		
		size = listeners.Size();
		for (i=size-1; i>=0; i-=1 )	
		{
			listeners[i].OnModioNetworkErrorScriptEvent();
		}
		return true;
	}

	event OnModioLocalModsUpdated()
	{
		var i, size : int;

		LogChannel('MODS', "OnModioLocalModsUpdated called in script " );

		size = listeners.Size();
		for (i=size-1; i>=0; i-=1 )	
		{
			listeners[i].OnModioLocalModsUpdatedScriptEvent();
		}
		return true;
	}

	event OnModioRemoteModsUpdated()
	{
		var i, size : int;

		LogChannel('MODS', "OnModioRemoteModsUpdated called in script " );

		size = listeners.Size();
		for (i=size-1; i>=0; i-=1 )	
		{
			listeners[i].OnModioRemoteModsUpdatedScriptEvent();
		}
		return true;
	}

	event OnCDPRAccountLoggedIn()
	{
		var i, size : int;

		LogChannel('MODS', "OnCDPRAccountLoggedIn called in script" );

		size = listeners.Size();
		for (i=size-1; i>=0; i-=1 )	
		{
			listeners[i].OnCDPRAccountLoggedInScriptEvent();
		}
		return true;
	}
}