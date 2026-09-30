/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleControlsFeedback extends CR4HudModuleBase
{		
	private var	m_fxSetSwordTextSFF 	: CScriptedFlashFunction;
	private var m_flashValueStorage 	: CScriptedFlashValueStorage;
	private var m_currentInputContext	: name;
	private var m_previousInputContext 	: name;
	private var m_currentPlayerWeapon	: EPlayerWeapon;
	private var m_displaySprint 		: bool;
	private var m_displayJump 			: bool;
	private var m_displayCallHorse		: bool;
	private var m_displayDiveDown		: bool;
	private var m_displayGallop			: bool;
	private var m_displayCanter			: bool;

	private var m_displayFocus			: bool;

	private	var m_movementLockType 		: EPlayerMovementLockType;
	private var m_lastUsedPCInput		: bool;
	private var m_mouserControllerScheme : MouserControllerScheme;
	private var m_CurrentHorseComp		: W3HorseComponent;
	
	private var m_altSignCasting		: bool; 
	private var m_altSignCastingLast	: bool; 
	
	private const var KEY_CONTROLS_FEEDBACK_LIST : string; 		default KEY_CONTROLS_FEEDBACK_LIST 		= "hud.module.controlsfeedback";
	
	
	private var minimapModule : CR4HudModuleMinimap2;
	private var objectiveModule : CR4HudModuleQuests;
	

	event  OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorControlsFeedback"; 
		m_displaySprint = thePlayer.IsActionAllowed(EIAB_RunAndSprint);
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_flashValueStorage = GetModuleFlashValueStorage();
		m_fxSetSwordTextSFF = flashModule.GetMemberFlashFunction( "setSwordText" );
		
		SetTickInterval( 0.5 );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		UpdateInputContext(hud.currentInputContext);
		
		if (hud)
		{
			hud.UpdateHudConfig('ControlsFeedbackModule', true);
			
			
			minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
			objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
			
		}
	}
	
	private function GetMinimapModule()
	{
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if(hud)
			minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
	}
	
	private function GetObjectiveModule()
	{
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if(hud)
			objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
	}

	public function UpdateInputContext( inputContextName :name )
	{		
		m_currentInputContext = inputContextName;
		if( m_currentInputContext == 'JumpClimb' )
		{
			SendInputContextActions('Exploration');
			return;
		}
		SendInputContextActions(inputContextName);
	}
	
	event OnTick( timeDelta : float )
	{
		if ( !CanTick( timeDelta ) || !GetEnabled() )
		{
			return true;
		}
		
		
		if(!minimapModule)
			GetMinimapModule();
		if(!objectiveModule)
			GetObjectiveModule();
		
		
		if( m_currentPlayerWeapon != thePlayer.GetCurrentMeleeWeaponType() )
		{
			m_currentPlayerWeapon = thePlayer.GetCurrentMeleeWeaponType();
			UpdateSwordDisplay();
		}
		
		
		if(thePlayer.GetInputHandler().GetIsAltSignCastingPressed()) 
		{
			m_altSignCasting = true;
		}
		else
		{
			m_altSignCasting = false;
			
		}		
		if(m_altSignCastingLast != m_altSignCasting)
		{
			UpdateInputContextActions();
			m_altSignCastingLast = m_altSignCasting;
		}
		
		
		if( m_lastUsedPCInput != theInput.LastUsedPCInput() )
		{
			UpdateInputContextActions();
		}
		else if( m_mouserControllerScheme != theInput.GetMouserControllerScheme() )
		{
			UpdateInputContextActions();
		}
		else if( m_currentInputContext == thePlayer.GetExplorationInputContext() || m_currentInputContext == 'JumpClimb' )
		{
			if( m_displaySprint != thePlayer.IsActionAllowed(EIAB_RunAndSprint) || thePlayer.movementLockType != m_movementLockType || m_displayCallHorse != thePlayer.IsActionAllowed(EIAB_CallHorse) || m_displayJump	!= thePlayer.IsActionAllowed(EIAB_Jump) || m_displayFocus != thePlayer.IsActionAllowed(EIAB_ExplorationFocus) )
			{
				UpdateInputContextActions();
			}
		}
		else if( m_currentInputContext == 'Diving' || m_currentInputContext == 'Swimming' )
		{
			if ( m_displaySprint != thePlayer.IsActionAllowed(EIAB_RunAndSprint) || m_displayDiveDown != thePlayer.OnAllowedDiveDown() )
			{
				UpdateInputContextActions();
			}
		}
		else if( m_currentInputContext == 'Horse' )
		{
			m_CurrentHorseComp = thePlayer.GetUsedHorseComponent();
			if ( m_displayGallop != m_CurrentHorseComp.OnCanGallop() || m_displayCanter != m_CurrentHorseComp.OnCanCanter() )
			{
				UpdateInputContextActions();
			}
		}
	}
	
	function UpdateInputContextActions()
	{
		if( m_currentInputContext != thePlayer.GetCombatInputContext() )
		{
			if ( m_currentInputContext == 'JumpClimb' )
				SendInputContextActions('Exploration',true);
			else
				SendInputContextActions(m_currentInputContext,true);
		}
		
		else
		{
			if(m_altSignCasting)
				SendInputContextActions('',true);
			else
			{
				if(thePlayer.IsCiri())
					SendInputContextActions('Combat_Replacer_Ciri',true);
				else
					SendInputContextActions('Combat',true);
			}
		}
		
	}
	
	function ForceModuleUpdate()
	{
		SendInputContextActions(m_currentInputContext, true);
	}
	
	function SetEnabled( value : bool )
	{
		super.SetEnabled(value);
		SendInputContextActions(m_currentInputContext, true);
	}	
	
	private function UpdateSwordDisplay()
	{
		switch( m_currentPlayerWeapon )
		{
			case PW_Silver :
				m_fxSetSwordTextSFF.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_silver")));
				break;		
			case PW_Steel :
				m_fxSetSwordTextSFF.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_steel")));
				break;
			default :
				m_fxSetSwordTextSFF.InvokeSelfOneArg(FlashArgString(""));
				break;
		}
	}
	
	private function SendInputContextActions( inputContextName :name, optional isForced : bool )
	{
		var l_FlashArray			: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var bindingGFxData	 		: CScriptedFlashObject;
		var bindingGFxData2	 		: CScriptedFlashObject;
		var l_ActionsArray	 		: array <name>;
		var l_swimingSprint	 		: bool;
		var i	 					: int;
		var outKeys 				: array< EInputKey >;
		var outKeysPC 				: array< EInputKey >;
		var labelPrefix				: string;
		var curAction				: name;
		var bracketOpeningSymbol 	: string;
		var bracketClosingSymbol  	: string;
		var actionLabel			  	: string;
		
		var attackKeysPC 			: array< EInputKey >;
		var attackModKeysPC 	    : array< EInputKey >;
		var alterAttackKeysPC 	    : array< EInputKey >;
		var modifier				: EInputKey;
		
		
		var showCiriMinimap, showCiriObjective : bool;
		
		
		GetBracketSymbols(bracketOpeningSymbol, bracketClosingSymbol);
		
		l_FlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_ActionsArray.Clear();
		l_swimingSprint = false;
		
		if( GetEnabled() )
		{
			if( !isForced && ( m_previousInputContext == m_currentInputContext || ( m_previousInputContext == 'JumpClimb' && m_currentInputContext == 'Exploration' ) || ( m_previousInputContext == 'Exploration' && m_currentInputContext == 'JumpClimb' ) ) )
			{
				return;
			}
			
			m_movementLockType 	= thePlayer.movementLockType;
			m_displaySprint 	= thePlayer.IsActionAllowed(EIAB_RunAndSprint);
			m_displayCallHorse 	= thePlayer.IsActionAllowed(EIAB_CallHorse);
			m_lastUsedPCInput 	= theInput.LastUsedPCInput();
			m_mouserControllerScheme = theInput.GetMouserControllerScheme();
			m_displayDiveDown 	= thePlayer.OnAllowedDiveDown();
			m_displayJump		= thePlayer.IsActionAllowed(EIAB_Jump);
			m_displayFocus		= thePlayer.IsActionAllowed(EIAB_ExplorationFocus);
			
			m_CurrentHorseComp = thePlayer.GetUsedHorseComponent();
			m_displayGallop 	= m_CurrentHorseComp.OnCanGallop();
			m_displayCanter 	= m_CurrentHorseComp.OnCanCanter();
			
			
			showCiriMinimap = minimapModule.GetMinimapDuringFocusCombat();
			showCiriObjective = objectiveModule.GetObjectiveDuringFocusCombat();
			
			
			switch(inputContextName)
			{
				case 'JumpClimb' :
					return;
				case 'Exploration' :  					
					if( m_displaySprint && !theGame.IsFocusModeActive() )	
					{
						
						if(m_lastUsedPCInput || !thePlayer.GetLeftStickSprint())
							l_ActionsArray.PushBack('Sprint');	
						else
							l_ActionsArray.PushBack('SprintToggle');	
						
					}
					if( m_displayJump )
					{
						l_ActionsArray.PushBack('Jump');
					}
					if( !thePlayer.IsCiri() )
					{
						if( m_displayFocus )
							l_ActionsArray.PushBack('Focus');
						if( m_displayCallHorse )
						{
							l_ActionsArray.PushBack('SpawnHorse');
						}
					}
					break;
				case 'Exploration_Replacer_Ciri' :
					if( m_displaySprint && !theGame.IsFocusModeActive() )	
					{
						
						if(m_lastUsedPCInput || !thePlayer.GetLeftStickSprint())
							l_ActionsArray.PushBack('Sprint');	
						else
							l_ActionsArray.PushBack('SprintToggle');	
						
					}
					if( m_displayJump )
					{
						l_ActionsArray.PushBack('Jump');
					}
					
					if( showCiriMinimap || showCiriObjective )
						l_ActionsArray.PushBack('Focus');
					
					break;
				case 'Horse' : 
				case 'Horse_Replacer_Ciri' : 
					if ( m_displayGallop || thePlayer.IsCiri() )
					{
						l_ActionsArray.PushBack('Gallop');
					}
					if ( m_displayCanter || thePlayer.IsCiri() )
					{
						l_ActionsArray.PushBack('Canter');
					}
					l_ActionsArray.PushBack('HorseDismount');
					break;			
				case 'Boat' : 
					l_ActionsArray.PushBack('GI_Accelerate');
					l_ActionsArray.PushBack('GI_Decelerate');
					l_ActionsArray.PushBack('BoatDismount');
					break;
				case 'BoatPassenger' :
					l_ActionsArray.PushBack('BoatDismount');
					break;
				case 'Swimming' : 
					l_ActionsArray.PushBack('DiveDown');
					if( m_displaySprint )
					{
						
						if(m_lastUsedPCInput || !thePlayer.GetLeftStickSprint())
							l_ActionsArray.PushBack('Sprint');	
						else
							l_ActionsArray.PushBack('SprintToggle');	
						
					}
					l_swimingSprint = true;
					break;		
				case 'Diving' :
					if ( m_displayDiveDown )
					{
						l_ActionsArray.PushBack('DiveDown');
					}
					l_ActionsArray.PushBack('DiveUp');
					if( m_displaySprint )
					{
						
						if(m_lastUsedPCInput || !thePlayer.GetLeftStickSprint())
							l_ActionsArray.PushBack('Sprint');	
						else
							l_ActionsArray.PushBack('SprintToggle');	
						
					}
					l_swimingSprint = true;
					break;
				case 'FistFight' : 
				case 'CombatFists' : 
				case 'Combat' : 
				if( thePlayer.IsInCombatFist() )
					{
						l_ActionsArray.PushBack('AttackLight');
						l_ActionsArray.PushBack('AttackHeavy');
						l_ActionsArray.PushBack('LockAndGuard'); 
						l_ActionsArray.PushBack('Dodge');
					}
					else
					{
						l_ActionsArray.PushBack('AttackLight');
						l_ActionsArray.PushBack('AttackHeavy');
						l_ActionsArray.PushBack('Dodge');
						l_ActionsArray.PushBack('CastSign');
					}
					break;
				case 'Combat_Replacer_Ciri' :
					l_ActionsArray.PushBack('AttackLight');
					l_ActionsArray.PushBack('CiriDodge');
					if ( thePlayer.HasAbility('CiriCharge') )
						l_ActionsArray.PushBack('CiriSpecialAttackHeavy'); 
					if ( thePlayer.HasAbility('CiriBlink') )
						l_ActionsArray.PushBack('CiriSpecialAttack'); 
					break;
				default:
					break;
			}
			
			
			if(m_altSignCasting)
			{				
				l_ActionsArray.Clear();

				if (m_mouserControllerScheme == MouserControllerScheme_None) 
				{
					l_ActionsArray.PushBack('CbtRoll');
					l_ActionsArray.PushBack('AttackLight');
					l_ActionsArray.PushBack('Dodge');
					l_ActionsArray.PushBack('AttackHeavy');
					l_ActionsArray.PushBack('LockAndGuard');
				}
				else if (m_mouserControllerScheme == MouserControllerScheme_Comfort)
				{
					l_ActionsArray.PushBack('CbtRoll');
					l_ActionsArray.PushBack('ThrowItem');
					l_ActionsArray.PushBack('Dodge');
					l_ActionsArray.PushBack('LockAndGuard');
					l_ActionsArray.PushBack('AttackHeavy');
				}
				else if (m_mouserControllerScheme == MouserControllerScheme_Dynamic)
				{
					l_ActionsArray.PushBack('SilverSword');		
					l_ActionsArray.PushBack('DrinkPotion1');	
					l_ActionsArray.PushBack('DrinkPotion2');	
					l_ActionsArray.PushBack('SteelSword');		
					l_ActionsArray.PushBack('LockAndGuard');
				}
			}			
			
			
			for( i = 0; i < l_ActionsArray.Size(); i += 1 )
			{
				curAction = l_ActionsArray[i];
				outKeys.Clear();
				outKeysPC.Clear();
				theInput.GetPadKeysForAction(curAction, outKeys ); 
				
				
				
				if (m_lastUsedPCInput)
				{
					modifier = IK_None;
					
					attackModKeysPC.Clear();
					theInput.GetPCKeysForAction('PCAlternate', attackModKeysPC );
					
					switch (curAction)
					{
						
						
						
						
						
						case 'AttackLight' :
								
								attackKeysPC.Clear();
								theInput.GetPCKeysForAction('AttackWithAlternateLight', attackKeysPC );
								
								if (attackKeysPC.Size() > 0 && attackKeysPC[0] != IK_None)
								{
									outKeysPC.PushBack(attackKeysPC[0]);
								}
								else								
								{
									alterAttackKeysPC.Clear();
									theInput.GetPCKeysForAction('AttackWithAlternateHeavy', alterAttackKeysPC );
									
									if (attackModKeysPC.Size() > 0 && alterAttackKeysPC.Size() > 0 && attackModKeysPC[0] != IK_None && alterAttackKeysPC[0] != IK_None)
									{
										outKeysPC.PushBack(alterAttackKeysPC[0]);
										modifier = attackModKeysPC[0];
									}
								}
								
							break;
							
						case 'AttackHeavy' :
						case 'CiriSpecialAttackHeavy' :
								
								
								
								attackKeysPC.Clear();
								theInput.GetPCKeysForAction('AttackWithAlternateHeavy', attackKeysPC );
								
								if (attackKeysPC.Size() > 0 && attackKeysPC[0] != IK_None)
								{
									outKeysPC.PushBack(attackKeysPC[0]);
								}
								else								
								{
									alterAttackKeysPC.Clear();
									theInput.GetPCKeysForAction('AttackWithAlternateLight', alterAttackKeysPC );
									
									if (attackModKeysPC.Size() > 0 && alterAttackKeysPC.Size() > 0 && attackModKeysPC[0] != IK_None && alterAttackKeysPC[0] != IK_None)
									{
										outKeysPC.PushBack(alterAttackKeysPC[0]);
										modifier = attackModKeysPC[0];
									}
								}
								
							break;
						default:
							theInput.GetPCKeysForAction(curAction, outKeysPC );
							break;
					}
				}
				
				
				
				switch (curAction) 
				{
					case 'Sprint' :
						
						
						
						
						
						break;
					case 'HorseDismount':
						outKeys.PushBack(IK_Pad_B_CIRCLE);
						break;
						
					default:
						break;
				}
				
				
				if(m_altSignCasting)
				{
					if (m_mouserControllerScheme == MouserControllerScheme_None) 
					{
						if( curAction == 'CbtRoll')				outKeys.PushBack(IK_Pad_A_CROSS);
						else if ( curAction == 'AttackLight')	outKeys.PushBack(IK_Pad_X_SQUARE);
						else if ( curAction == 'Dodge')			outKeys.PushBack(IK_Pad_B_CIRCLE);
						else if ( curAction == 'AttackHeavy')	outKeys.PushBack(IK_Pad_Y_TRIANGLE);
						else if ( curAction == 'LockAndGuard')	outKeys.PushBack(IK_Pad_LeftTrigger);
					}
					else if (m_mouserControllerScheme == MouserControllerScheme_Comfort)
					{
						if( curAction == 'CbtRoll')				outKeys.PushBack(IK_Pad_A_CROSS);
						else if ( curAction == 'ThrowItem')		outKeys.PushBack(IK_Pad_X_SQUARE);
						else if ( curAction == 'Dodge')			outKeys.PushBack(IK_Pad_B_CIRCLE);
						else if ( curAction == 'LockAndGuard')	outKeys.PushBack(IK_Pad_Y_TRIANGLE);
						else if ( curAction == 'AttackHeavy')	outKeys.PushBack(IK_Pad_RightTrigger);
					}
					else if (m_mouserControllerScheme == MouserControllerScheme_Dynamic)
					{
						if( curAction == 'SilverSword')			outKeys.PushBack(IK_Pad_DigitRight);
						else if ( curAction == 'DrinkPotion1')	outKeys.PushBack(IK_Pad_DigitUp);
						else if ( curAction == 'DrinkPotion2')	outKeys.PushBack(IK_Pad_DigitDown);
						else if ( curAction == 'SteelSword')	outKeys.PushBack(IK_Pad_DigitLeft);
						else if ( curAction == 'LockAndGuard')	outKeys.PushBack(IK_Pad_LeftTrigger);
					}
				}
				
				
				l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				bindingGFxData = l_DataFlashObject.CreateFlashObject("red.game.witcher3.data.KeyBindingData");
				bindingGFxData.SetMemberFlashInt("gamepad_keyCode", outKeys[0] );
				
				if (outKeysPC.Size() > 0)
				{
					bindingGFxData.SetMemberFlashInt("keyboard_keyCode", outKeysPC[0] );
				}
				else
				{
					bindingGFxData.SetMemberFlashInt("keyboard_keyCode", 0 );
				}
				if (modifier != IK_None)
				{
					bindingGFxData.SetMemberFlashInt("altKeyCode", modifier );
				}
				
				if( (curAction == 'Sprint' || curAction == 'SprintToggle') && ( m_currentInputContext != 'Swimming' && m_currentInputContext != 'Diving') )	
				{
					if( m_movementLockType != PMLT_Free )
					{
						curAction = 'Run';
					}
				}
				
				switch (curAction)
				{
					case 'Gallop':
						labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_doubleTap") + bracketClosingSymbol + "</font>";
						break;
					case 'SpawnHorse':
						if ( !m_lastUsedPCInput )
							labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_doubleTap") + bracketClosingSymbol + "</font>";
						else
							labelPrefix = "";
						break;
					case 'Sprint':
						if ( !theInput.IsToggleSprintBound() )
							labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_hold") + bracketClosingSymbol + "</font>";						
						break;
					case 'SprintToggle':
						if ( !theInput.IsToggleSprintBound() )
							labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + StrReplace(GetLocStringByKeyExt("ControlLayout_press")," -","") + bracketClosingSymbol + "</font>";						
						break;
					case 'HorseDismount':
						labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_hold") + bracketClosingSymbol + "</font>";
						break;
					case 'Run':
						
						if(m_lastUsedPCInput || !thePlayer.GetLeftStickSprint())
							labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_hold") + bracketClosingSymbol + "</font>";
						else
							labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + StrReplace(GetLocStringByKeyExt("ControlLayout_press")," -","") + bracketClosingSymbol + "</font>";
						
						break;
					case 'GI_Accelerate':
					case 'GI_Decelerate':
					case 'Canter':
					case 'Focus':
					case 'Roll':
					case 'DiveUp':
					case 'DiveDown':
					case 'CiriSpecialAttackHeavy':
					case 'CiriSpecialAttack':
						labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_hold") + bracketClosingSymbol + "</font>";
						break;
					default:
						labelPrefix = "";
						break;
				}
				
				if( curAction == 'Jump' )
				{
					actionLabel = GetLocStringByKeyExt("panel_button_common_jump");
				}
				else if( (curAction == 'Sprint' || curAction == 'SprintToggle') && ( m_currentInputContext == 'Swimming' || m_currentInputContext == 'Diving') )	
				{
					actionLabel = GetLocStringByKeyExt("panel_input_action_fast_swiming");
				}
				else if( curAction == 'SpawnHorse' )
				{
					actionLabel = GetLocStringByKeyExt("ControlLayout_SummonHorse");					
				}
				else if (curAction == 'BoatDismount' && inputContextName == 'Boat')
				{
					actionLabel = GetLocStringByKeyExt("panel_button_common_disembark");
				}
				else if ( curAction == 'CiriDodge' )
				{
					actionLabel = GetLocStringByKeyExt("ControlLayout_Dodge");
				}
				else if ( curAction == 'CiriSpecialAttackHeavy' )
				{
					actionLabel = GetLocStringByKeyExt("ControlLayout_CiriCharge");
				}
				else if ( curAction == 'CiriSpecialAttack' )
				{
					actionLabel = GetLocStringByKeyExt("ControlLayout_CiriBlink");
				}
				
				else if ( curAction == 'SprintToggle' )
				{
					actionLabel = GetLocStringByKeyExt("panel_input_action_sprint");
				}
				
				else if ( curAction == 'Focus' && thePlayer.IsCiri() )
				{
					if(showCiriMinimap && showCiriObjective)
						actionLabel = GetLocStringByKeyExt("option_Minimap") + "/" + GetLocStringByKeyExt("panel_journal_quest_objectives");
					else if (showCiriMinimap)
						actionLabel = GetLocStringByKeyExt("option_Minimap");
					else if (showCiriObjective)
						actionLabel = GetLocStringByKeyExt("panel_journal_quest_objectives");
				}
				
				else if(m_altSignCasting)
				{
					if (m_mouserControllerScheme == MouserControllerScheme_None) 
					{
						if( curAction == 'CbtRoll')				
						{		
							actionLabel = GetLocStringById(1061945);
							
						}
						else if ( curAction == 'AttackLight')	
						{
							actionLabel = GetLocStringById(1066290);
							
						}
						else if ( curAction == 'Dodge') 		
						{
							actionLabel = GetLocStringById(1066292);
							
						}
						else if ( curAction == 'AttackHeavy') 	
						{
							actionLabel = GetLocStringById(1066293);
							
						}
						else if ( curAction == 'LockAndGuard')	
						{
							actionLabel = GetLocStringById(1066291);
							
						}
					}
					else if (m_mouserControllerScheme == MouserControllerScheme_Comfort)
					{
						if( curAction == 'CbtRoll')	
						{		
							actionLabel = GetLocStringById(1061945);
						}
						else if ( curAction == 'ThrowItem')	
						{
							actionLabel = GetLocStringById(1066290);
						}
						else if ( curAction == 'Dodge')	
						{
							actionLabel = GetLocStringById(1066292);
						}
						else if ( curAction == 'LockAndGuard')	
						{
							actionLabel = GetLocStringById(1066293);
						}
						else if ( curAction == 'AttackHeavy')	
						{
							actionLabel = GetLocStringById(1066291);
						}
					}
					else if (m_mouserControllerScheme == MouserControllerScheme_Dynamic)
					{
						if( curAction == 'SilverSword')	
						{		
							actionLabel = GetLocStringById(1061945);
						}
						else if ( curAction == 'DrinkPotion1')	
						{
							actionLabel = GetLocStringById(1066290);
						}
						else if ( curAction == 'DrinkPotion2')	
						{
							actionLabel = GetLocStringById(1066292);
						}
						else if ( curAction == 'SteelSword')	
						{
							actionLabel = GetLocStringById(1066293);
						}
						else if ( curAction == 'LockAndGuard')	
						{
							actionLabel = GetLocStringById(1066291);
						}
					}
				}
				else
				{					
					actionLabel = GetLocStringByKeyExt("panel_input_action_"+StrLower(curAction));
				}
				
				if(theGame.IsLanguageArabic())
					bindingGFxData.SetMemberFlashString("label", labelPrefix + " <font color=\"#FFFFFF\">" + actionLabel + "</font>" );
				else
					bindingGFxData.SetMemberFlashString("label", " <font color=\"#FFFFFF\">" + actionLabel + "</font> " + labelPrefix );
				
				l_FlashArray.PushBackFlashObject(bindingGFxData);
			}
		}
		
		
		
		
		
		{
			m_flashValueStorage.SetFlashArray( KEY_CONTROLS_FEEDBACK_LIST, l_FlashArray );
			
		}
		m_previousInputContext = m_currentInputContext;
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool
	{
		return super.UpdateScale(scale * 0.75,flashModule );
	}
	
	protected function UpdatePosition(anchorX:float, anchorY:float) : void
	{
		var l_flashModule 		: CScriptedFlashSprite;
		var tempX				: float;
		var tempY				: float;
		
		l_flashModule 	= GetModuleFlash();
		
		
		
		
		tempX = anchorX - (300.0 * (1.0 - theGame.GetUIHorizontalFrameScale()));
		tempY = anchorY - (200.0 * (1.0 - theGame.GetUIVerticalFrameScale())); 
		
		l_flashModule.SetX( tempX );
		l_flashModule.SetY( tempY );	
	}

	event OnInputHandled(NavCode:string, KeyCode:int, ActionId:int)
	{
	}
}