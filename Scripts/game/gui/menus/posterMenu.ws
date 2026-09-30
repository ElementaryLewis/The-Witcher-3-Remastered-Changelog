/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4PosterMenu extends CR4MenuBase
{
	private var	m_posterEntity : W3Poster;

	private var m_fxSetDescriptionSFF			: CScriptedFlashFunction;
	private var m_fxSetSubtitlesHackSFF			: CScriptedFlashFunction;
	private var m_fxSetFontScaleSFF				: CScriptedFlashFunction;

	
	private var subtitleScale : int;
	default subtitleScale = 0;

	event  OnConfigUI()
	{	
		var inGameConfigWrapper : CInGameConfigWrapper;
		var flashModule : CScriptedFlashSprite;
		var description : string;

		super.OnConfigUI();

		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		subtitleScale = StringToInt(inGameConfigWrapper.GetVarValue('Hud', 'SubtitleScale'));
		
		flashModule = GetMenuFlash();

		m_fxSetDescriptionSFF = flashModule.GetMemberFlashFunction( "SetDescription" );
		m_fxSetSubtitlesHackSFF = flashModule.GetMemberFlashFunction( "SetSubtitlesHack" );
		m_fxSetFontScaleSFF = flashModule.GetMemberFlashFunction( "SetFontScale" );

		m_posterEntity = ( W3Poster )GetMenuInitData();
		if ( m_posterEntity )
		{
			m_fxSetFontScaleSFF.InvokeSelfOneArg( FlashArgInt( subtitleScale ) );

			description = m_posterEntity.GetDescription();
			
			if( m_posterEntity.GetIsDescriptionGenerated() )
			{
				m_fxSetDescriptionSFF.InvokeSelfTwoArgs( FlashArgString( description ), FlashArgBool( m_posterEntity.IsTextAlignedToLeft() ) );
			}
			else
			{
				if ( StrLen( description ) > 0 )
				{
					description = GetLocStringByKeyExt( description );
				}
				
				m_fxSetDescriptionSFF.InvokeSelfTwoArgs( FlashArgString( description ), FlashArgBool( m_posterEntity.IsTextAlignedToLeft() ) );
			}
		}

		theInput.StoreContext( 'EMPTY_CONTEXT' );
	}
	
	event  OnClosingMenu()
	{
		super.OnClosingMenu();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		
		m_posterEntity.LeavePosterPreview();
		
		OnPlaySoundEvent( "gui_noticeboard_close" );
	}

	event  OnCloseMenu()
	{
		CloseMenu();
	}
	
	function PlayOpenSoundEvent()
	{
		OnPlaySoundEvent( "gui_noticeboard_enter" );
	}
	
	function CanPostAudioSystemEvents() : bool
	{
		return false;
	}
	
	public function AddSubtitle( speaker : string, text : string )
	{
		m_fxSetSubtitlesHackSFF.InvokeSelfTwoArgs( FlashArgString( speaker ), FlashArgString( text ) );
	}

	public function RemoveSubtitle()
	{
		m_fxSetSubtitlesHackSFF.InvokeSelfTwoArgs( FlashArgString( "" ), FlashArgString( "" ) );
	}
}

exec function postermenu()
{
	theGame.RequestMenu('PosterMenu');
}
