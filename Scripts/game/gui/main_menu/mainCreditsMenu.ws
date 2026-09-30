/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct CreditsSection
{
	var sectionName : string;
	var positionNames : array< string >;
	var crewNames : array< string >;
	var displayTime : float;
	var positionX : int;
	var positionY : int;
	var delay : float;
};

enum CreditsIndex
{
	CreditsIndex_Wither3 = 0,
	CreditsIndex_Ep1 = 1,
	CreditsIndex_Ep2 = 2,
	CreditsIndex_Witcher3_NG = 3
}

class CR4MainCreditsMenu extends CR4MenuBase
{
	private var guiManager 			: CR4GuiManager;
	private var	m_fxSetSectionTextSFF : CScriptedFlashFunction;
	private var	m_fxSetScrollingSpeedSFF : CScriptedFlashFunction;
	private var	m_fxAddScrollingTextSFF : CScriptedFlashFunction;
	private var	m_fxStartScrollingTextSFF : CScriptedFlashFunction;
	private var	m_fxChangedConstraintedStateSFF : CScriptedFlashFunction;
	private var	m_fxSetThankYouText : CScriptedFlashFunction;
	
	private var legalTextOverride : bool; default legalTextOverride = false;
	public var shouldCloseOnMovieEnd: bool;
	private var creditsSections : array< CreditsSection >;
	private var currentSectionID : int;
	private var htmlNewline		: string;	default htmlNewline = "&#10;"; 
	private var playedSecondSection : bool; default playedSecondSection = false;
	
	private var SCROLLING_TEXT_LINE_COUNT	: int;		default SCROLLING_TEXT_LINE_COUNT	= 50;
	private var SCROLLING_SPEED				: int;		default SCROLLING_SPEED				= 100;

	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;

		super.OnConfigUI();

		guiManager = theGame.GetGuiManager();
	
		flashModule = GetMenuFlash();	
		m_fxSetSectionTextSFF		= flashModule.GetMemberFlashFunction( "setCreditsText" );
		m_fxSetScrollingSpeedSFF	= flashModule.GetMemberFlashFunction( "setScrollingSpeed" );
		m_fxAddScrollingTextSFF		= flashModule.GetMemberFlashFunction( "addScrollingText" );
		m_fxStartScrollingTextSFF	= flashModule.GetMemberFlashFunction( "startScrollingText" );
		m_fxChangedConstraintedStateSFF = flashModule.GetMemberFlashFunction( "changedConstraintedState" );
		m_fxSetThankYouText         = flashModule.GetMemberFlashFunction( "setThankYouText" );

		m_fxSetScrollingSpeedSFF.InvokeSelfOneArg( FlashArgNumber( SCROLLING_SPEED ) );

		BuildCreditsSections();
		
		if (GetCurrentTextLocCode() == "JP" || GetCurrentTextLocCode() == "KR" || GetCurrentTextLocCode() == "AR")
		{
			legalTextOverride = true;
		}

		MakeModal(true);
		theInput.StoreContext( 'EMPTY_CONTEXT' );

		guiManager.PlayFlashbackVideoAsync("gamestart/credits_6000bitrate.usm", true);

		theSound.EnterGameState( ESGS_MusicOnly );
		theSound.StopMusic();
		theSound.SoundEvent('play_music_main_menu');
		
		if ( theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Ep1 )
		{
			if ( theGame.IsActive() && FactsQuerySum( "q605_mirror_banished" ) > 0 )
			{
				theSound.SoundEvent( 'mus_q605_credits_usm' );
			}
			else
			{
				theSound.SoundEvent( 'mus_credits_usm_ep1' );
			}
		}
		else if ( theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Ep2 )
		{
			theSound.SoundEvent('play_music_toussaint' );
			theSound.SoundEvent( 'mus_credits_ep2_main' );
			m_fxSetThankYouText.InvokeSelfOneArg( FlashArgString( GetLocStringByKey("credits_thank_you_note") ) );
		}
		else if ( theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Wither3 )
		{
			theSound.SoundEvent( 'mus_credits_usm' );
		}
		else if( theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Witcher3_NG )
		{
			theSound.SoundEvent( 'mus_credits_usm' );
		}

		theGame.ResetFadeLock( "CR4MainCreditsMenu" );
		theGame.FadeInAsync(0.5);
		
		
		currentSectionID = -1;
		DisplayNextSection();
	}
	
	event OnVideoStopped() 
	{
		
	}
	
	protected function BuildCreditsSections() : void
	{
		var creditsCSV			: C2dArray;
		
		var i					: int;
		var rowsCount			: int;
		var readSectionIDString	: string;
		var readSectionID		: int;
		
		
		var creditsString 	: string;
		var tempString 		: string;
		var sectionID 		: int;
		var tempCreditsSection : CreditsSection;
		var emptyCreditsSection : CreditsSection;
		
		sectionID = -1;
		
		if (theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Wither3)
		{
			creditsCSV = LoadCSV("gameplay\globals\credits.csv");
		}
		else if (theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Ep1)
		{
			creditsCSV = LoadCSV("gameplay\globals\credits_ep1.csv");
		}
		else if (theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Ep2)
		{
			creditsCSV = LoadCSV("gameplay\globals\credits_ep2.csv");
		}
		else if (theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Witcher3_NG)
		{
			creditsCSV = LoadCSV("gameplay\globals\credits_ng.csv");
		}
		
		rowsCount = creditsCSV.GetNumRows();

		for( i = 0; i < rowsCount; i += 1 )
		{
			readSectionIDString = creditsCSV.GetValueAt( 0, i );
			readSectionID       = StringToInt( readSectionIDString );
			
			if ( sectionID != readSectionID )
			{
				
				if( sectionID > 0 )
				{
					creditsSections.PushBack( tempCreditsSection );
					tempCreditsSection = emptyCreditsSection;
				}
				sectionID = readSectionID;
				if( sectionID == 0 )
				{
					
					continue;
				}
				
				tempCreditsSection = emptyCreditsSection;
				tempString = creditsCSV.GetValueAt( 2, i );
				if( tempString != "" )
				{
					if( tempString == "SCROLLING" )
					{
						tempCreditsSection.sectionName = tempString;
						tempCreditsSection.displayTime = StringToFloat(creditsCSV.GetValueAt(5,i));
						continue;
					}
					else
					{
						tempCreditsSection.positionNames.PushBack(tempString);
						tempString = creditsCSV.GetValueAt(1,i);
						tempCreditsSection.crewNames.PushBack(tempString);
						tempCreditsSection.displayTime = StringToFloat(creditsCSV.GetValueAt(5,i));
						tempCreditsSection.delay = StringToFloat(creditsCSV.GetValueAt(6,i));
						tempCreditsSection.positionX = StringToInt(creditsCSV.GetValueAt(3,i));
						tempCreditsSection.positionY = StringToInt(creditsCSV.GetValueAt(4,i));
					}
				}
			}
			else
			{
				tempString = creditsCSV.GetValueAt(2,i);
				tempCreditsSection.positionNames.PushBack(tempString);
				tempString = creditsCSV.GetValueAt(1,i);
				tempCreditsSection.crewNames.PushBack(tempString);
			}
		}
		
		if( sectionID > 0 )
		{
			creditsSections.PushBack(tempCreditsSection);
		}
	}
	
	function DisplayNextSection() : void 
	{
		var tempString : string;
		var fontColor : string;
		var i : int;
		var currentScrollingTextLineCount : int;

		currentSectionID += 1;
		
		if ( currentSectionID >= creditsSections.Size() )
		{
			return;
		}
		
		if( creditsSections[currentSectionID].sectionName != "SCROLLING" )
		{
			fontColor = "<font face=\"$CreditsFont\" size=\"54\" color=\"#000000\">";
			if( creditsSections[currentSectionID].sectionName != "" )
			{
				tempString += StrUpperUTF( GetLocalizedPositionAndDepartment(creditsSections[currentSectionID].sectionName) ) + htmlNewline;
			}
			for( i = 0; i < creditsSections[currentSectionID].positionNames.Size(); i += 1 )
			{
				tempString += StrUpperUTF( GetLocalizedPositionAndDepartment(creditsSections[currentSectionID].positionNames[i]) ) + "   " + fontColor + creditsSections[currentSectionID].crewNames[i] + "</font>";
				if ( i < creditsSections[currentSectionID].positionNames.Size() - 1 )
				{
					tempString += htmlNewline;
				}
			}
			m_fxSetSectionTextSFF.InvokeSelfFiveArgs( FlashArgString( tempString ),FlashArgNumber( creditsSections[currentSectionID].displayTime ), FlashArgNumber( creditsSections[currentSectionID].delay ), FlashArgInt(creditsSections[currentSectionID].positionX), FlashArgInt(creditsSections[currentSectionID].positionY));
		}
		else
		{
			if (!playedSecondSection)
			{
				playedSecondSection = true;
				
				if ( theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Ep1 )
				{
					if ( theGame.IsActive() && FactsQuerySum( "q605_mirror_banished" ) > 0 )
					{
						theSound.SoundEvent( 'mus_q605_credits_secondary' );
					}
					else
					{
						theSound.SoundEvent( 'mus_credits_secondary_ep1' );
					}
				}
				else if ( theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Ep2 )
				{
					theSound.SoundEvent( 'mus_credits_ep2_secondary' );
				}
				else if ( theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Wither3 )
				{
					theSound.SoundEvent( 'mus_credits_secondary' );
				}
				else if ( theGame.GetGuiManager().GetLastRequestedCreditsIndex() == CreditsIndex_Witcher3_NG )
				{
					theSound.SoundEvent( 'mus_credits_secondary' );
				}
			}
			
			tempString = "";
			currentScrollingTextLineCount = 0;
			
			LogChannel( 'credits', "START" );
			for( i = 0; i < creditsSections[currentSectionID].positionNames.Size(); i += 1 )
			{
				
				if (legalTextOverride && creditsSections[currentSectionID].positionNames[i] == "credits_LEGAL_NOTICE")
				{
					tempString += "<font face=\"$CreditsFont\" color=\"#FFFFFF\">" + StrUpperUTF( GetLocalizedPositionAndDepartment(creditsSections[currentSectionID].positionNames[i]) ) + "</font> ";
				}
				else
				{
					tempString += StrUpperUTF( GetLocalizedPositionAndDepartment(creditsSections[currentSectionID].positionNames[i]) ) + " " + "<font face=\"$CreditsFont\" size=\"28\" color=\"#FFFFFF\">" + creditsSections[currentSectionID].crewNames[i] + "</font> ";
				}
				
				currentScrollingTextLineCount += 1;
				if ( currentScrollingTextLineCount < SCROLLING_TEXT_LINE_COUNT )
				{
					tempString += htmlNewline;
				}
				else
				{
					LogChannel( 'credits', "AddScrollingTextSFF" );
					m_fxAddScrollingTextSFF.InvokeSelfOneArg( FlashArgString( tempString ) );
					tempString = "";
					currentScrollingTextLineCount = 0;
				}
			}
			LogChannel( 'credits', "AddScrollingTextSFF LAST" );
			if ( tempString != "" )
			{
				m_fxAddScrollingTextSFF.InvokeSelfOneArg( FlashArgString( tempString ) );
			}
			LogChannel( 'credits', "StartScrollingTextSFF" );
			m_fxStartScrollingTextSFF.InvokeSelf();
			LogChannel( 'credits', "StartScrollingTextSFF" );
		}
	}
	
	function GetLocalizedPositionAndDepartment( inString : string ) : string
	{
		var tempStr : string;
		
		if ( StrLen( inString ) == 0 )
		{
			return "";
		}
		tempStr = GetLocStringByKeyExt( inString );
		
		
		if ( tempStr == "" )
		{
			
			return inString;
		}
		
		
		
		
		
		
		
		return tempStr;
	}
	
	function FixColorString( str: string ) : string
	{
		var tempStr : string;
		var tempStr2 : string;
		var tempStr3 : string;
		var charId : int;
		var sizeInt : int;
		var sizeInt2 : int;
		
		tempStr = str;
		while( StrFindFirst(tempStr,"color=#") != -1)
		{
			tempStr2 = StrMid(tempStr,StrFindFirst(tempStr,"color=#")+13);
			tempStr = StrLeft(tempStr,StrFindFirst(tempStr,"color=#")+13);
			tempStr = StrReplace(tempStr,"color=#","color="+"\"#");
			tempStr = tempStr+"\"";
			tempStr = tempStr + tempStr2;
		}	
		while( StrFindFirst(tempStr,"size=") != -1 && StrFindFirst(tempStr,"size=\"") != StrFindFirst(tempStr,"size=") )
		{
			sizeInt = 0;
			sizeInt2 = 0;
			tempStr2 = StrMid(tempStr,StrFindFirst(tempStr,"size=")+5);
			tempStr = StrLeft(tempStr,StrFindFirst(tempStr,"size=")+5);
			sizeInt = StringToInt( StrLeft(tempStr2,1) );
			sizeInt2 = StringToInt( StrLeft(tempStr2,2) );
			tempStr = StrReplace(tempStr,"size=","size="+"\"");
			if( sizeInt2 > sizeInt )
			{
				sizeInt = sizeInt2;
				tempStr2 = StrMid(tempStr2,1);
			}
			tempStr2 = StrMid(tempStr2,1);
			tempStr = tempStr+sizeInt+"\"";
			tempStr = tempStr + tempStr2;
		}	

		return tempStr;
	}
	
	event OnSectionHidden()	
	{
		DisplayNextSection();
	}

	event OnStopVideo()
	{
		LogChannel('Credits', "OnStopVideo");
		guiManager.CancelFlashbackVideo();
	}

	event OnCloseMenu()
	{
		var ingameMenu : CR4IngameMenu;
		var menuType : int;
		
		guiManager.CancelFlashbackVideo();

		theSound.LeaveGameState( ESGS_MusicOnly );

		if(m_parentMenu)
		{
			ingameMenu = (CR4IngameMenu)m_parentMenu;
			
			if (ingameMenu)
			{
				menuType = theGame.GetChosenMainMenuType();
				switch ( menuType )
				{
					case 1:
						theSound.SoundEvent('mus_main_menu_theme_ep1');
						break;
					case 2:
						theSound.SoundEvent('stop_music' );
						theSound.SoundEvent('play_music_toussaint' );
						theSound.SoundEvent('mus_main_menu_ep2');
						break;
					case 0:
					default:
						theSound.SoundEvent('mus_main_menu_theme');
						break;
				}
			}
			else
			{
				theSound.SoundEvent('play_music_kaer_morhen');
			}
			
			m_parentMenu.ChildRequestCloseMenu();
			CloseMenu();
			return true;
		}
		else
		{
			theGame.FadeOutAsync( 0 );

			theSound.SoundEvent('play_music_kaer_morhen');
			CloseMenu();
		}		
	}
		
	event /* C++ */ OnClosingMenu()
	{
		super.OnClosingMenu();
		//theGame.FadeOutAsync( 0 );
		guiManager.CancelFlashbackVideo();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
	}	
	
	event OnChangedConstrainedState( entered : bool )
	{
		m_fxChangedConstraintedStateSFF.InvokeSelfOneArg( FlashArgBool( entered ) );
	}

}

exec function crd()
{
	theGame.GetGuiManager().RequestCreditsMenu(CreditsIndex_Wither3);
}

exec function crd2()
{
	theGame.GetGuiManager().RequestCreditsMenu(CreditsIndex_Ep2);
}

exec function eu()
{
	var tempStr : string;
	tempStr = GetLocStringByKeyExt( "credits_EU_LOGO" );
	LogChannel('', "[" + tempStr + "]" );
}