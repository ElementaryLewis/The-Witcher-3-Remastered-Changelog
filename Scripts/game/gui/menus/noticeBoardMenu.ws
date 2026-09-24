/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4NoticeBoardMenu extends CR4MenuBase
{
	public var board : W3NoticeBoard;
	private var m_fxSetSelectedIndex   	 : CScriptedFlashFunction;
	private var m_fxSetTitle   			 : CScriptedFlashFunction;
	private var m_fxSetDescription   	 : CScriptedFlashFunction;

	event  OnConfigUI()
	{			
		super.OnConfigUI();
		
		m_flashModule = GetMenuFlash();
		m_fxSetSelectedIndex = m_flashModule.GetMemberFlashFunction( "setSelectedIndex" );
		m_fxSetTitle = m_flashModule.GetMemberFlashFunction( "setTitle" );
		m_fxSetDescription = m_flashModule.GetMemberFlashFunction( "setDescription" );
		board = (W3NoticeBoard)GetMenuInitData();
		if( board )
		{
			
			UpdateDescription();
		}
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		thePlayer.BlockAction(EIAB_Interactions, 'NoticeBoard' );		
		
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		if (theInput.LastUsedPCInput())
		{
			theGame.MoveMouseTo(0.3, 0.5);
		}
		
		theGame.ResetFadeLock( "NoticeboardStart" );
		theGame.FadeInAsync( 3.0 );
		
		
		
	}
	
	public function UpdateDescription()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var errands					: array< ErrandDetailsList >;
		var i						: int;
		var length					: int;
		var selected				: bool;
		
		errands = board.activeErrands;
		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		for( i = 0; i < errands.Size(); i += 1 )
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString("tag", errands[i].errandStringKey );
			if( !selected && errands[i].errandStringKey != "" )
			{
				selected = true;
				
				m_fxSetSelectedIndex.InvokeSelfOneArg(FlashArgInt(i));
				OnErrandSelected( errands[i].errandStringKey );
			}
			
			if( errands[i].newQuestFact == "flaw" || errands[i].displayAsFluff )
			{
				l_DataFlashObject.SetMemberFlashBool("isFluff", true );
			}
			else
			{
				l_DataFlashObject.SetMemberFlashBool("isFluff", false );
			}
			l_DataFlashObject.SetMemberFlashInt("posX", errands[i].posX );
			l_DataFlashObject.SetMemberFlashInt("posY", errands[i].posY );
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			length += 1;
			
			if( length >= board.MAX_DISPLAYED_ERRANDS )
			{
				break;
			}
		}
		
		m_flashValueStorage.SetFlashArray( "noticeboard.errands.list", l_DataFlashArray );
	}
	
	public function SetBoardNoteTitle(value : string) : void
	{
		m_fxSetTitle.InvokeSelfOneArg(FlashArgString(value));
	}
	
	public function SetBoardNoteDescription(value : string) : void
	{
		m_fxSetDescription.InvokeSelfOneArg(FlashArgString(value));
	}

	event  OnTakeQuest( tag : string )
	{	
		if(ShouldProcessTutorial('TutorialQuestBoard'))
		{
			FactsAdd("tut_noticeboard_taken");
		}
		OnPlaySoundEvent("gui_noticeboard_paper");
		if( board.AcceptNewQuest(tag) )
		{
			OnCloseMenu();
		}
	}
	
	event  OnErrandSelected( tag : string )
	{
		SetBoardNoteTitle(GetLocStringByKeyExt(tag));
		SetBoardNoteDescription(GetLocStringByKeyExt(tag+"_text"));
	}
	
	event  OnCloseMenu()
	{
		
		
		
		theGame.GetTutorialSystem().uiHandler.OnClosedMenu(GetMenuName());
		
		
		CloseMenu();
	}
	
		
	event  OnClosingMenu()
	{
		
		theGame.GetTutorialSystem().uiHandler.OnClosingMenu(GetMenuName());
		
		theGame.GetGuiManager().RequestMouseCursor(false);
		
		theInput.RestoreContext( 'EMPTY_CONTEXT', false );
		thePlayer.UnblockAction(EIAB_Interactions, 'NoticeBoard' );
		
		if(	!m_parentMenu)
			theSound.SoundEvent("system_resume");
		
		OnPlaySoundEvent( "gui_noticeboard_close" );
	}
	
	function PlayOpenSoundEvent()
	{
		OnPlaySoundEvent( "gui_noticeboard_enter" );
	}
}
