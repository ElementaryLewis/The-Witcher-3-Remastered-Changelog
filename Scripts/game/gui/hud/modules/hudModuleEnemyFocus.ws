/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EFloatingValueType
{
	EFVT_None,
	EFVT_Critical,
	EFVT_Block,
	EFVT_InstantDeath,
	EFVT_DoT,
	EFVT_Heal,
	EFVT_Buff
}

class CR4HudModuleEnemyFocus extends CR4HudModuleBase
{	
	
	
	
	
	private	var m_fxSetEnemyName				: CScriptedFlashFunction;
	private	var m_fxSetEnemyLevel				: CScriptedFlashFunction;
	private	var m_fxSetAttitude					: CScriptedFlashFunction;
	private	var m_fxSetEnemyHealth				: CScriptedFlashFunction;
	private	var m_fxSetEnemyStamina				: CScriptedFlashFunction;
	private	var m_fxSetEssenceBarVisibility		: CScriptedFlashFunction;
	private	var m_fxSetStaminaVisibility		: CScriptedFlashFunction;
	private var m_fxSetNPCQuestIcon				: CScriptedFlashFunction;
	private	var m_fxSetDodgeFeedback			: CScriptedFlashFunction;
	private	var m_fxSetBossOrDead				: CScriptedFlashFunction;
	private	var m_fxSetShowHardLock				: CScriptedFlashFunction;
	private var m_fxSetDamageText				: CScriptedFlashFunction;
	private var m_fxHideDamageText				: CScriptedFlashFunction;
	private var m_fxSetGeneralVisibility		: CScriptedFlashFunction;
	private var m_fxSetMutationEightVisibility	: CScriptedFlashFunction;

	private	var m_mcNPCFocus				: CScriptedFlashSprite;
	
	private var m_lastTarget				: CGameplayEntity;
	private var m_lastTargetAttitude		: EAIAttitude;
	private var m_lastHealthPercentage		: int;
	private var m_wasAxiied					: bool;
	private var m_lastStaminaPercentage		: int;
	private var m_nameInterval				: float;
	private var m_lastEnemyDifferenceLevel	: string;
	private var m_lastEnemyLevelString		: string;
	private var m_lastDodgeFeedbackTarget	: CActor;
	private var m_lastEnemyName				: string;
	private var m_lastUseMutation8Icon		: bool;
	
	
	
	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "ScaleOnly";
		
		flashModule 			= GetModuleFlash();
		
		m_fxSetEnemyName				= flashModule.GetMemberFlashFunction( "setEnemyName" );
		m_fxSetEnemyLevel				= flashModule.GetMemberFlashFunction( "setEnemyLevel" );
		m_fxSetAttitude					= flashModule.GetMemberFlashFunction( "setAttitude" );
		m_fxSetEnemyHealth				= flashModule.GetMemberFlashFunction( "setEnemyHealth" );
		m_fxSetEnemyStamina				= flashModule.GetMemberFlashFunction( "setEnemyStamina" );
		m_fxSetEssenceBarVisibility		= flashModule.GetMemberFlashFunction( "setEssenceBarVisibility" );
		m_fxSetStaminaVisibility		= flashModule.GetMemberFlashFunction( "setStaminaVisibility" );		
		m_fxSetNPCQuestIcon				= flashModule.GetMemberFlashFunction( "setNPCQuestIcon" );
		m_fxSetDodgeFeedback			= flashModule.GetMemberFlashFunction( "setDodgeFeedback" );
		m_fxSetDamageText				= flashModule.GetMemberFlashFunction( "setDamageText" );
		m_fxHideDamageText				= flashModule.GetMemberFlashFunction( "hideDamageText" );
		m_fxSetBossOrDead				= flashModule.GetMemberFlashFunction( "SetBossOrDead" );		
		m_fxSetShowHardLock				= flashModule.GetMemberFlashFunction( "setShowHardLock" );
		m_fxSetGeneralVisibility		= flashModule.GetMemberFlashFunction( "SetGeneralVisibility" );
		m_fxSetMutationEightVisibility 	= flashModule.GetMemberFlashFunction( "displayMutationEight" );
		m_mcNPCFocus 					= flashModule.GetChildFlashSprite( "mcNPCFocus" );
		
		super.OnConfigUI();
		
		m_fxSetEnemyName.InvokeSelfOneArg( FlashArgString( "" ) );
		m_fxSetEnemyStamina.InvokeSelfOneArg(FlashArgInt(0));
		
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('EnemyFocusModule', true);
		}
	}
	
	
	
	private function GetAttitudeOfTargetActor( target : CGameplayEntity ) : EAIAttitude
	{
		var targetActor : CActor;
		
		targetActor = ( CActor )target;
		if ( targetActor )
		{
			return targetActor.GetAttitude( thePlayer );
		}
		return AIA_Neutral;
	}
	
	
	public function SetDodgeFeedback( target : CActor ) :void 
	{
		m_fxSetDodgeFeedback.InvokeSelfOneArg( FlashArgBool( !( !target ) ) );
		m_lastDodgeFeedbackTarget = target;
	}
	
	
	public function DisplayMutationEight( value : bool ) :void
	{
		m_fxSetMutationEightVisibility.InvokeSelfOneArg( FlashArgBool ( value ) );
	}
	
	
	public function SetGeneralVisibility( showEnemyFocus : bool, showName : bool )
	{
		m_fxSetGeneralVisibility.InvokeSelfTwoArgs( FlashArgBool( showEnemyFocus ), FlashArgBool( showName ) );
	}
	
	
	
	public function ShowDamageType(valueType : EFloatingValueType, value : float, optional stringParam : string)
	{
		var label:string;
		var color:float;
		var hud:CR4ScriptedHud;
		
		
		if(valueType != EFVT_InstantDeath && valueType != EFVT_Buff && value == 0.f)
			return;

		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( !hud.AreEnabledEnemyHitEffects() )
		{
			return;
		}
	
		switch (valueType)
		{
			case EFVT_Critical:
				label = GetLocStringByKeyExt("attribute_name_critical_hit_damage");
				color = 0xFDFFC2;
				break;
			case EFVT_InstantDeath:
				label = GetLocStringByKeyExt("effect_instant_death");
				color = 0xFFC2C2;
				break;
			case EFVT_Block:
				label = GetLocStringByKeyExt("");
				color = 0xFC5B5B;
				break;
			case EFVT_DoT:
				label = GetLocStringByKeyExt("");
				color = 0xFF0000;
				break;
			case EFVT_Heal:
				label = GetLocStringByKeyExt("");
				color = 0x00FF00;
				break;
			case EFVT_Buff:
				label = GetLocStringByKeyExt(stringParam);
				color = 0xFFF0F0;
				break;
			default:
				label = GetLocStringByKeyExt("");
				color = 0xFFF0F0;
				break;
		}
		SetDamageText(label, CeilF(value), color);
	}
	
	
		
	private function SetDamageText(label:string, value:int, color:float) : void
	{		
		m_fxSetDamageText.InvokeSelfThreeArgs( FlashArgString(label), FlashArgNumber(value), FlashArgNumber(color) );
	}
	public function HideDamageText()
	{
		m_fxHideDamageText.InvokeSelf();
	}
	
	
	
	
	event OnTick( timeDelta : float )
	{
		var l_target 					: CNewNPC;
		var l_targetNonActor			: CGameplayEntity;
		var l_isHuman					: bool;
		var l_isDifferentTarget			: bool;
		var l_wasAxiied 				: bool;
		var l_currentHealthPercentage	: int;
		var l_currentStaminaPercentage	: int;
		var l_currentTargetAttitude		: EAIAttitude;
		var l_currentEnemyDifferenceLevel : string;
		var l_currentEnemyLevelString   : string;
		var l_targetScreenPos			: Vector;
		var l_dodgeFeedbackTarget		: CActor;
		var l_isBoss					: bool;
		var screenMargin : float = 0.085; 
		var marginLeftTop : Vector;
		var marginRightBottom : Vector;
		var hud : CR4ScriptedHud;
		var extraOffset					: int;
		var herbTag						: name;
		var herbEntity					: W3Herb;
		var definitionManager 			: CDefinitionsManagerAccessor;
		var useMutation8Icon			: bool;
		
		
		l_targetNonActor = thePlayer.GetDisplayTarget();
		l_target = (CNewNPC)l_targetNonActor;
		l_dodgeFeedbackTarget = thePlayer.GetDodgeFeedbackTarget();
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		
		
		
		
		
		
		
		
		
		
		
		
		if ( l_target )
		{
			if ( !l_target.IsUsingTooltip())
			{
				l_target = NULL;
			}
		}
		if ( l_target )
		{
			
			
			if ( l_target.HasTag( 'HideHealthBarModule' ) )
			{
				if ( l_target.HasTag( 'NotBoss' ) ) 
				{
					l_target = NULL;
				}
				else
					l_isBoss = true;				
			}
			else
			{
				
				if ( (CHeartMiniboss)l_target )
				{
					l_target = NULL;
				}
			}
		}
 
		if ( l_target )
		{
			
			l_isHuman = l_target.IsHuman();
			l_isDifferentTarget = ( l_target != m_lastTarget );
			l_wasAxiied = ( l_target.GetAttitudeGroup() == 'npc_charmed' );
			
			
			
			
			if(l_isDifferentTarget && l_target && !l_target.IsInCombat() && IsRequiredAttitudeBetween(thePlayer, l_target, true))
			{
				l_target.RecalcLevel();
			}
			
			
			if ( l_isDifferentTarget )
			{
				m_fxSetBossOrDead.InvokeSelfOneArg( FlashArgBool( l_isBoss || !l_target.IsAlive() ) );
				
				
				HideDamageText();
				
				
				m_fxSetStaminaVisibility.InvokeSelfOneArg( FlashArgBool( l_isHuman ) ); 
				m_fxSetEssenceBarVisibility.InvokeSelfOneArg( FlashArgBool( l_target.UsesEssence()) );
				UpdateQuestIcon( l_target );
				SetDodgeFeedback( NULL );
				
				ShowElement( true ); 
				
				m_lastTarget = l_target;
			}
			
			

			l_currentTargetAttitude = l_target.GetAttitude( thePlayer );
			if ( l_currentTargetAttitude != AIA_Hostile )
			{
				
				if ( l_target.IsVIP() )
				{
					l_currentTargetAttitude = 4;
				}
			}
				
			if ( l_isDifferentTarget || m_lastTargetAttitude != l_currentTargetAttitude || m_wasAxiied != l_wasAxiied )
			{
				m_lastTargetAttitude = l_currentTargetAttitude;
				m_wasAxiied = l_wasAxiied;
				if( m_wasAxiied )
				{
					m_fxSetAttitude.InvokeSelfOneArg( FlashArgInt( 3 ) ); 
				}
				else
				{
					m_fxSetAttitude.InvokeSelfOneArg( FlashArgInt( l_currentTargetAttitude ) );
				}
			}

			
			if ( m_lastDodgeFeedbackTarget != l_dodgeFeedbackTarget )
			{
				if ( l_currentTargetAttitude == AIA_Hostile )
				{
					SetDodgeFeedback( l_dodgeFeedbackTarget );
				}
				else
				{
					SetDodgeFeedback( NULL );
				}
				m_lastDodgeFeedbackTarget = l_dodgeFeedbackTarget;
			}
			
			
			
			
			
			
			m_nameInterval -= timeDelta;
			if ( l_isDifferentTarget || m_nameInterval < 0  )
			{
				m_nameInterval = 0.25; 
				
				UpdateName( l_target.GetDisplayName() );
			}

			
			l_currentHealthPercentage = CeilF( 100 * l_target.GetHealthPercents() );	
			if ( m_lastHealthPercentage != l_currentHealthPercentage )
			{
				m_lastHealthPercentage = l_currentHealthPercentage;	
				m_fxSetEnemyHealth.InvokeSelfOneArg( FlashArgInt( l_currentHealthPercentage ) );
				
			}			
			
			
			l_currentStaminaPercentage = CeilF( 100 * l_target.GetStaminaPercents() );
			if ( m_lastStaminaPercentage != l_currentStaminaPercentage )
			{
				m_lastStaminaPercentage = l_currentStaminaPercentage;
				m_fxSetEnemyStamina.InvokeSelfOneArg( FlashArgInt( l_currentStaminaPercentage ) );
			}			
			
			
			l_currentEnemyDifferenceLevel = l_target.GetExperienceDifferenceLevelName( l_currentEnemyLevelString );
			if ( l_isDifferentTarget || 
				 m_lastEnemyDifferenceLevel != l_currentEnemyDifferenceLevel ||
				 m_lastEnemyLevelString     != l_currentEnemyLevelString )
			{
				m_lastEnemyDifferenceLevel = l_currentEnemyDifferenceLevel;
				m_lastEnemyLevelString     = l_currentEnemyLevelString;
				m_fxSetEnemyLevel.InvokeSelfTwoArgs( FlashArgString( l_currentEnemyDifferenceLevel ), FlashArgString( l_currentEnemyLevelString ) );
			}
			
			
			useMutation8Icon = GetWitcherPlayer().IsMutationActive( EPMT_Mutation8 ) && !l_target.IsImmuneToMutation8Finisher();
			if ( m_lastUseMutation8Icon != useMutation8Icon )
			{
				m_lastUseMutation8Icon = useMutation8Icon;
				DisplayMutationEight( useMutation8Icon );
			}
			
			
			if ( GetBaseScreenPosition( l_targetScreenPos, l_target ) )
			{
				l_targetScreenPos.Y -= 45;
				
				marginLeftTop     = hud.GetScaleformPoint( screenMargin,     screenMargin );
				marginRightBottom = hud.GetScaleformPoint( 1 - screenMargin, 1 - screenMargin );

				if ( l_targetScreenPos.X < marginLeftTop.X )
				{
					l_targetScreenPos.X = marginLeftTop.X;
				}
				else if ( l_targetScreenPos.X > marginRightBottom.X )
				{
					l_targetScreenPos.X = marginRightBottom.X;
				}
				
				if ( l_targetScreenPos.Y < marginLeftTop.Y )
				{
					l_targetScreenPos.Y = marginLeftTop.Y;
				}
				else if ( l_targetScreenPos.Y > marginRightBottom.Y )
				{
					l_targetScreenPos.Y = marginRightBottom.Y;
				}

				m_mcNPCFocus.SetVisible( true );
				m_mcNPCFocus.SetPosition( l_targetScreenPos.X, l_targetScreenPos.Y );
			}			
			else
			{
				m_mcNPCFocus.SetVisible( false );
			}
		}
		else if ( l_targetNonActor )
		{
			
			l_isDifferentTarget = ( l_targetNonActor != m_lastTarget );

			
			if ( l_isDifferentTarget )
			{
				
				m_fxSetStaminaVisibility.InvokeSelfOneArg( FlashArgBool( false ) );
				m_fxSetEssenceBarVisibility.InvokeSelfOneArg( FlashArgBool( false ) );
				UpdateQuestIcon( (CNewNPC)l_targetNonActor );
				SetDodgeFeedback( NULL );
				
				ShowElement( true ); 
				
				m_fxSetAttitude.InvokeSelfOneArg( FlashArgInt( 0 ) );
				m_fxSetEnemyLevel.InvokeSelfTwoArgs( FlashArgString( "none" ), FlashArgString( "" ) );

				
				m_lastTarget				= l_targetNonActor;
				m_lastTargetAttitude		= GetAttitudeOfTargetActor( m_lastTarget );
				m_lastHealthPercentage		= -1;
				m_lastStaminaPercentage		= -1;
				m_lastEnemyDifferenceLevel	= "none";
				m_lastEnemyLevelString		= "";
			}		
		
			
			
			
			
			
			
			herbEntity = (W3Herb)l_targetNonActor;
			if ( herbEntity )
			{
				extraOffset = 140; 
				m_nameInterval -= timeDelta;
				if ( l_isDifferentTarget || m_nameInterval < 0  )
				{
					m_nameInterval = 0.25; 

					herbEntity.GetStaticMapPinTag( herbTag );
					if ( herbTag )
					{
						definitionManager = theGame.GetDefinitionsManager();
						if ( definitionManager )
						{
							UpdateName( GetLocStringByKeyExt( definitionManager.GetItemLocalisationKeyName( herbTag ) ) );
						}
					}
					else
					{
						UpdateName( "" );
					}
				}
			}
			else
			{
				if ( l_isDifferentTarget )
				{
					UpdateName( "" );
				}
			}

			
			useMutation8Icon = false;
			if ( m_lastUseMutation8Icon != useMutation8Icon )
			{
				DisplayMutationEight( useMutation8Icon );
				m_lastUseMutation8Icon = useMutation8Icon;
			}

			
			if ( GetBaseScreenPosition( l_targetScreenPos, l_targetNonActor ) )
			{
				l_targetScreenPos.Y -= 10;
				l_targetScreenPos.Y -= extraOffset;

				marginLeftTop     = hud.GetScaleformPoint( screenMargin,     screenMargin );
				marginRightBottom = hud.GetScaleformPoint( 1 - screenMargin, 1 - screenMargin );

				if ( l_targetScreenPos.X < marginLeftTop.X )
				{
					l_targetScreenPos.X = marginLeftTop.X;
				}
				else if ( l_targetScreenPos.X > marginRightBottom.X )
				{
					l_targetScreenPos.X = marginRightBottom.X;
				}
			
				if ( l_targetScreenPos.Y < marginLeftTop.Y )
				{
					l_targetScreenPos.Y = marginLeftTop.Y;
				}
				else if ( l_targetScreenPos.Y > marginRightBottom.Y )
				{
					l_targetScreenPos.Y = marginRightBottom.Y;
				}

				m_mcNPCFocus.SetVisible( true );
				m_mcNPCFocus.SetPosition( l_targetScreenPos.X, l_targetScreenPos.Y );	
			}
			else
			{
				m_mcNPCFocus.SetVisible( false );
			}
		}
		else if ( m_lastTarget )
		{
			m_lastTarget = NULL;
			m_mcNPCFocus.SetVisible( false );
			SetDodgeFeedback( NULL );
			ShowElement( false ); 
		}
		else
		{
			
			if ( m_mcNPCFocus.GetVisible() )
			{
				m_mcNPCFocus.SetVisible( false );
				ShowElement( false );
			}
		}
	}	
	
	public function UpdateName( enemyName : string )
	{
		if ( m_lastEnemyName != enemyName )
		{
			m_lastEnemyName = enemyName;
			m_fxSetEnemyName.InvokeSelfOneArg( FlashArgString( m_lastEnemyName ) );
		}
	}
	
	public function SetShowHardLock( set : bool )
	{
		m_fxSetShowHardLock.InvokeSelfOneArg( FlashArgBool( set ) );
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool 
	{
		return false;
	}
	
	private function UpdateQuestIcon( target : CNewNPC )
	{
		var mapPinInstances : array< SCommonMapPinInstance >;
		var commonMapManager : CCommonMapManager;
		var currentPin : SCommonMapPinInstance;
		var targetTags : array< name >;
		var i : int;
		var questIcon : string;
		var mapPinType : name;
		
		questIcon = "none";

		if ( target )
		{
			targetTags = target.GetTags();
			
			if (targetTags.Size() > 0)
			{
				commonMapManager = theGame.GetCommonMapManager();

				mapPinType = commonMapManager.GetMapPinTypeByTag( targetTags[0] );
				switch ( mapPinType )
				{
					case 'QuestReturn':
						questIcon = "QuestReturn";
						break;
					case 'QuestGiverStory':
						questIcon = "QuestGiverStory";
						break;
					case 'QuestGiverChapter':
						questIcon = "QuestGiverChapter";
						break;
					case 'QuestGiverSide':
					case 'QuestAvailable':
					case 'QuestAvailableHoS':
					case 'QuestAvailableBaW':
						questIcon = "QuestGiverSide";
						break;
					case 'MonsterQuest':
						questIcon = "MonsterQuest";
						break;
					case 'TreasureQuest':
						questIcon = "TreasureQuest";
						break;
				}
			}
		}

		
		m_fxSetNPCQuestIcon.InvokeSelfOneArg( FlashArgString( questIcon ) );
	}
}

exec function dodgeFeedback()
{
	var npc : CNewNPC;
	
	npc = (CNewNPC)thePlayer.GetDisplayTarget();
	if ( npc )
	{
		thePlayer.SetDodgeFeedbackTarget( npc );
	}
}

exec function hardlock( set : bool )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleEnemyFocus;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleEnemyFocus)hud.GetHudModule("EnemyFocusModule");
	module.SetShowHardLock( set );
}

