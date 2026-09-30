/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleCompanion extends CR4HudModuleBase 
{	
	private var m_fxSetNameSFF				: CScriptedFlashFunction;
	private var m_fxSetPortraitSFF			: CScriptedFlashFunction;
	private var m_fxSetVitalitySFF			: CScriptedFlashFunction;

	private var m_fxSetName2SFF				: CScriptedFlashFunction;
	private var m_fxSetPortrait2SFF			: CScriptedFlashFunction;
	private var m_fxSetVitality2SFF			: CScriptedFlashFunction;

	private var bShow						: bool;
	
	private	var	m_LastVitality				: float;
	private	var	m_LastMaxVitality			: float;

	private	var	m_LastVitality2				: float;
	private	var	m_LastMaxVitality2			: float;
	
	private var companionNPC				: CNewNPC;
	private var companionNPC2				: CNewNPC;
	
	private var companionName 				: string;
	private var companionName2 				: string;

	event  OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		var playerWitcher : W3PlayerWitcher;
		
		playerWitcher = GetWitcherPlayer();

		m_anchorName = "mcAnchorCompanion";
		super.OnConfigUI();
		
		flashModule = GetModuleFlash();	
		m_fxSetNameSFF = flashModule.GetMemberFlashFunction( "setName" );
		m_fxSetPortraitSFF = flashModule.GetMemberFlashFunction( "setPortrait" );
		m_fxSetVitalitySFF = flashModule.GetMemberFlashFunction( "setVitality" );
		
		m_fxSetName2SFF = flashModule.GetMemberFlashFunction( "setName2" );
		m_fxSetPortrait2SFF = flashModule.GetMemberFlashFunction( "setPortrait2" );
		m_fxSetVitality2SFF = flashModule.GetMemberFlashFunction( "setVitality2" );
		
		m_fxSetPortraitSFF.InvokeSelfOneArg(FlashArgString("icons/monsters/ICO_MonsterDefault.png"));
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('CompanionModule', true);
		}
		
		SetTickInterval( 0.5 );
	}

	function ShowCompanion( showModule : bool, npcTag : name, optional iconPath : string )
	{
		var playerWitcher : W3PlayerWitcher;
		
		playerWitcher = GetWitcherPlayer();
		if ( !playerWitcher )
		{
			return;
		}

		if( showModule )
		{
			playerWitcher.SetCompanionNPCTag( npcTag );
			playerWitcher.SetCompanionNPCIconPath( iconPath );

			companionNPC = theGame.GetNPCByTag( npcTag );
			if ( companionNPC )
			{
				bShow = showModule;
				ShowElement(showModule);

				if( iconPath == "" )
				{	
					m_fxSetPortraitSFF.InvokeSelfOneArg(FlashArgString("icons/monsters/ICO_MonsterDefault.png"));
				}
				else
				{
					m_fxSetPortraitSFF.InvokeSelfOneArg(FlashArgString(iconPath));
				}
			
				companionName = companionNPC.GetDisplayName();
				if ( companionName == "" )
				{
					playerWitcher.AddTimer( 'ResendCompanionDisplayName', 0.2f , true );
					m_fxSetNameSFF.InvokeSelfOneArg(FlashArgString(""));
				}
				else
				{
					m_fxSetNameSFF.InvokeSelfOneArg(FlashArgString(companionName));
					playerWitcher.RemoveCompanionDisplayNameTimer();
				}
			}
		}
		else
		{
			bShow = showModule;
			ShowElement(showModule);

			playerWitcher.SetCompanionNPCIconPath("");
			playerWitcher.SetCompanionNPCTag( '' );

			companionNPC = NULL;
			playerWitcher.RemoveCompanionDisplayNameTimer();
		}
		m_fxSetPortrait2SFF.InvokeSelfOneArg(FlashArgString(""));
	}
	
	function ShowCompanionSecond( npcTag : name, optional iconPath : string )
	{
		var playerWitcher : W3PlayerWitcher;
		
		playerWitcher = GetWitcherPlayer();
		if ( !playerWitcher )
		{
			return;
		}

		if( bShow )
		{
			playerWitcher.SetCompanionNPCTag2( npcTag );
			playerWitcher.SetCompanionNPCIconPath2(iconPath);
			
			companionNPC2 = theGame.GetNPCByTag( npcTag );
			if ( companionNPC2 )
			{
				if( iconPath == "" )
				{	
					m_fxSetPortrait2SFF.InvokeSelfOneArg(FlashArgString(""));
				}
				else
				{
					m_fxSetPortrait2SFF.InvokeSelfOneArg(FlashArgString(iconPath));
				}
			
				companionName2 = companionNPC2.GetDisplayName();
				if ( companionName2 == "" )
				{
					playerWitcher.AddTimer('ResendCompanionDisplayNameSecond', 0.2f , true);
					m_fxSetName2SFF.InvokeSelfOneArg(FlashArgString(""));
				}
				else
				{
					m_fxSetName2SFF.InvokeSelfOneArg(FlashArgString(companionName2));
					playerWitcher.RemoveCompanionDisplayNameTimerSecond();
				}
			}
		}
		else
		{
			playerWitcher.SetCompanionNPCIconPath2("");
			playerWitcher.SetCompanionNPCTag2( '' );

			companionNPC2 = NULL;
			playerWitcher.RemoveCompanionDisplayNameTimerSecond();
		}
	}

	event OnTick( timeDelta : float )
	{
		var playerWitcher : W3PlayerWitcher;
		
		playerWitcher = GetWitcherPlayer();
		if ( !playerWitcher )
		{
			return true;
		}

		if( bShow )
		{
			UpdateVitality();
			UpdateVitality2();
		}
		
		if ( !CanTick( timeDelta ) )
		{
			return true;
		}
		
		if ( !bShow )
		{
			if( playerWitcher.GetCompanionNPCTag() != '' && !companionNPC )
			{
				ShowCompanion( true, playerWitcher.GetCompanionNPCTag(), playerWitcher.GetCompanionNPCIconPath() );
			}
			if( playerWitcher.GetCompanionNPCTag2() != '' && !companionNPC2 )
			{
				ShowCompanionSecond( playerWitcher.GetCompanionNPCTag2(), playerWitcher.GetCompanionNPCIconPath2() );
			}
		}
	}
		
	function ResendDisplayName()
	{
		companionNPC = theGame.GetNPCByTag( GetWitcherPlayer().GetCompanionNPCTag() );
			 
		if( companionNPC )
		{
			companionName = companionNPC.GetDisplayName();
			if( companionName != "" )
			{
				GetWitcherPlayer().RemoveCompanionDisplayNameTimer();
				m_fxSetNameSFF.InvokeSelfOneArg(FlashArgString(companionName));
			}
		}
	}

	function ResendDisplayNameSecond()
	{	
		companionNPC2 = theGame.GetNPCByTag( GetWitcherPlayer().GetCompanionNPCTag2() );
		if( companionNPC2 )
		{
			companionName2 = companionNPC2.GetDisplayName();
			if( companionName2 != "" )
			{
				GetWitcherPlayer().RemoveCompanionDisplayNameTimerSecond();
				m_fxSetName2SFF.InvokeSelfOneArg(FlashArgString(companionName2));
			}
		}
	}
	
	public function UpdateVitality() : void
	{
		var l_currentVitality 		: float;
		var l_currentMaxVitality 	: float;
		
		if( companionNPC )
		{
			companionNPC.GetStats( BCS_Vitality, l_currentVitality, l_currentMaxVitality );
			
			if( l_currentVitality != m_LastVitality ||  l_currentMaxVitality != m_LastMaxVitality )
			{
				
				m_fxSetVitalitySFF.InvokeSelfOneArg( FlashArgNumber(  l_currentVitality / l_currentMaxVitality ) );
				m_LastVitality = l_currentVitality;
				m_LastMaxVitality = l_currentMaxVitality;
			}
		}
	}

	public function UpdateVitality2() : void
	{
		var l_currentVitality 		: float;
		var l_currentMaxVitality 	: float;
		
		if( companionNPC2 )
		{
			companionNPC2.GetStats( BCS_Vitality, l_currentVitality, l_currentMaxVitality );
			
			if( l_currentVitality != m_LastVitality2 ||  l_currentMaxVitality != m_LastMaxVitality2 )
			{
				
				m_fxSetVitality2SFF.InvokeSelfOneArg( FlashArgNumber(  l_currentVitality / l_currentMaxVitality ) );
				m_LastVitality2 = l_currentVitality;
				m_LastMaxVitality2 = l_currentMaxVitality;
			}
		}
	}
}