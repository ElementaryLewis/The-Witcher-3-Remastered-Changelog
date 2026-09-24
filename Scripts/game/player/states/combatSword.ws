/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state CombatSword in W3PlayerWitcher extends Combat 
{
	protected 	var bIsInPirouette 				: bool;
	protected	var swordId 					: SItemUniqueId;
	
	
	
	
	event OnEnterState( prevStateName : name )
	{
		var npcs 	: array<CActor>;
		var i		: int;
		
		theInput.SetContext(parent.GetCombatInputContext());
		super.OnEnterState(prevStateName);
		
		parent.AddAnimEventCallback('FinishSpecialHeavyAttack','OnAnimEvent_FinishSpecialHeavyAttack');
		
		InitSwordItem();
		
		this.CombatSwordInit();
		
		
		npcs = GetActorsInRange( thePlayer, 5, 20, '', true );
		for( i = 0; i < npcs.Size(); i += 1 )
		{
			if( GetAttitudeBetween( thePlayer, npcs[i] ) == AIA_Hostile )
			{
				npcs[i].SignalGameplayEvent( 'DrawSword' );
			}
		}	
	}
	
	public function GetSwordType() : name
	{ 
		return '';
	}
	
	
	protected function InitSwordItem()
	{
		var items : array< SItemUniqueId >;
		var category : name;
			
		category = GetSwordType();
		parent.inv.GetHeldWeaponsWithCategory( category, items );
		swordId = items[0];
		parent.inv.PlayItemEffect(swordId, 'rune_blast_loop');
	}
	
	
	event OnLeaveState( nextStateName : name )
	{
		
		super.OnLeaveState(nextStateName);
		 
		parent.RemoveAnimEventCallback('FinishSpecialHeavyAttack');
		
		parent.inv.StopItemEffect(swordId, 'rune_blast_loop');
		
		parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 0.f );
		parent.RemoveCustomOrientationTarget( 'SpecialAttackLight' );
		parent.RemoveTimer( 'UpdateSpecialAttackLightHeading' );
		parent.RemoveCustomOrientationTarget( 'SpecialAttackHeavy' );
	}
	
		
	protected function ProcessStartupAction( action : EInitialAction )
	{
		switch( action )
		{
			case IA_AttackLight:
				parent.SetPrevRawLeftJoyRot();
				parent.SetupCombatAction( EBAT_LightAttack, BS_Pressed );
				break;
			
			case IA_AttackHeavy:
				parent.SetPrevRawLeftJoyRot();
				parent.SetupCombatAction( EBAT_HeavyAttack, BS_Pressed );
				break;
			
			default:
				Log( "Enter CombatSword w/out attacking" );
		}		
	}
	
	
	entry function CombatSwordInit()
	{
		CombatSwordLoop();
	}
	
	
	latent function CombatSwordLoop()
	{
		while( true )
		{
			Sleep( 0.5 );
		}	
	}
	
	event OnCreateAttackAspects()
	{
		CreateAttackLightAspect();
		CreateAttackHeavyAspect();
		CreateAttackLightFarAspect();
		CreateAttackHeavyFarAspect();
		CreateAttackLightFlyingAspect();
		CreateAttackHeavyFlyingAspect();
		CreateAttackLightAspectSlopeUp();
		CreateAttackLightAspectSlopeDown();
		CreateAttackLightCapsuleShort();
		CreateAttackLightVsRiderAspect();
		CreateAttackHeavyVsRiderAspect();
		CreateAttackNeutral();
		CreateAttackNeutralUnconscious();
	}

	private final function CreateAttackLightAspect()
	{
	
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		

		aspect = comboDefinition.CreateComboAspect( 'AttackLight' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_4_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_6_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_rp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_3_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_rp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_rp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_rp_50ms', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_rp_50ms', AD_Right, ADIST_Large );			

			
			

			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_3_rp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_4_rp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_6_rp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', ADIST_Medium );			

			
			aspect.AddLink( 'man_geralt_sword_attack_close_combo_l_1', 'man_geralt_sword_attack_close_combo_r_2' );
			aspect.AddLink( 'man_geralt_sword_attack_close_combo_l_4', 'man_geralt_sword_attack_close_combo2_r_1' );
			aspect.AddLink( 'man_geralt_sword_attack_close_combo2_r_1', 'man_geralt_sword_attack_close_combo2_l_2' );
			aspect.AddLink( 'man_geralt_sword_attack_close_combo2_l_3', 'man_geralt_sword_attack_close_combo2_r_4' );
			aspect.AddLink( 'man_geralt_sword_attack_close_combo2_r_4', 'man_geralt_sword_attack_close_combo2_r_5' );
			aspect.AddLink( 'man_geralt_sword_attack_close_combo2_r_5', 'man_geralt_sword_attack_close_combo_r_2' );
			
			
			
			
		}
		{
			str = aspect.CreateComboString( true );

			
			

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_3_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_4_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_lp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_lp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_lp_50ms', AD_Back, ADIST_Large );			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_lp_50ms', AD_Left, ADIST_Large );			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_lp_50ms', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_lp_50ms', AD_Right, ADIST_Large );				

			
			

			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_3_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_4_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', ADIST_Medium );			

			
			aspect.AddLink( 'man_geralt_attack_close_30ms_r_1', 'man_geralt_sword_attack_close_combo_l_1' );
			aspect.AddLink( 'man_geralt_sword_attack_close_combo_r_2', 'man_geralt_sword_attack_close_combo_l_3' );
			aspect.AddLink( 'man_geralt_sword_attack_close_combo_l_3', 'man_geralt_sword_attack_close_combo_l_4' );
			aspect.AddLink( 'man_geralt_sword_attack_close_combo2_r_1', 'man_geralt_sword_attack_close_combo2_l_2' );
			aspect.AddLink( 'man_geralt_sword_attack_close_combo2_l_2', 'man_geralt_sword_attack_close_combo2_l_3' );
		}		
	}

	private final function CreateAttackHeavyAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		aspect = comboDefinition.CreateComboAspect( 'AttackHeavy' );
		
		{
			str = aspect.CreateComboString( false );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_1_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_2_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_3_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_4_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_5_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_6_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_7_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_8_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_9_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_10_rp_70ms', AD_Front, ADIST_Medium );			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_rp_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_rp_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_rp_70ms', AD_Right, ADIST_Medium );

			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_rp_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_back_1_rp_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_left_1_rp_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_right_1_rp_80ms', AD_Right, ADIST_Large );			
					
			str.AddAttack( 'man_geralt_sword_attack_strong_1_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_2_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_3_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_4_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_5_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_6_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_7_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_8_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_9_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_10_rp_70ms', ADIST_Medium );		
			}		

			
			{
			str = aspect.CreateComboString( true );

			str.AddDirAttack( 'man_geralt_sword_attack_strong_1_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_2_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_3_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_4_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_5_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_6_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_7_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_8_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_9_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_10_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_lp_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_lp_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_lp_70ms', AD_Right, ADIST_Medium );

			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_back_1_lp_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_left_1_lp_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_right_1_lp_80ms', AD_Right, ADIST_Large );			
					
			str.AddAttack( 'man_geralt_sword_attack_strong_1_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_2_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_3_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_4_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_5_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_6_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_7_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_8_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_9_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_10_lp_70ms', ADIST_Medium );			
		}	
	}	

	private final function CreateAttackLightFarAspect()
	{
	
		var aspect 		: CComboAspect;
		var str 		: CComboString;

		aspect = comboDefinition.CreateComboAspect( 'AttackLightFar' );
		
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'man_geralt_sword_approach_attack_1', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_approach_attack_1', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_approach_attack_1', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_approach_attack_1', AD_Right, ADIST_Large );

			str.AddAttack( 'man_geralt_sword_approach_attack_1', ADIST_Large );
		}
		{
			str = aspect.CreateComboString( true );
			str.AddDirAttack( 'man_geralt_sword_approach_attack_1', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_approach_attack_1', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_approach_attack_1', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_approach_attack_1', AD_Right, ADIST_Large );

			str.AddAttack( 'man_geralt_sword_approach_attack_1', ADIST_Large );
		}
	}
	
	private final function CreateAttackHeavyFarAspect()
	{
	
		var aspect 		: CComboAspect;
		var str 		: CComboString;

		aspect = comboDefinition.CreateComboAspect( 'AttackHeavyFar' );
		
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Right, ADIST_Large );

			str.AddAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', ADIST_Large );
		}
		{
			str = aspect.CreateComboString( true );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Right, ADIST_Large );

			str.AddAttack( 'man_geralt_sword_approach_attack_1', ADIST_Large );
		}
	}

	private final function CreateAttackLightFlyingAspect()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		

		aspect = comboDefinition.CreateComboAspect( 'AttackLightFlying' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_6_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_6_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_6_rp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Large );			
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_3_rp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_6_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_3_rp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_6_rp_40ms', ADIST_Medium );
		}
		{
			str = aspect.CreateComboString( true );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Large );

			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', ADIST_Medium );		
		}		
	}

	private final function CreateAttackHeavyFlyingAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		aspect = comboDefinition.CreateComboAspect( 'AttackHeavyFlying' );
		
		{
			str = aspect.CreateComboString( false );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_4_rp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_9_rp_70ms', AD_Front, ADIST_Medium );		
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_rp_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_rp_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_rp_70ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_4_rp_70ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_9_rp_70ms', AD_Front, ADIST_Large );		
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_rp_70ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_rp_70ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_rp_70ms', AD_Right, ADIST_Large );		
					
			str.AddAttack( 'man_geralt_sword_attack_strong_4_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_9_rp_70ms', ADIST_Medium );
		}		
		
		
		{
			str = aspect.CreateComboString( true );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_3_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_8_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_lp_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_lp_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_lp_70ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_3_lp_70ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_8_lp_70ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_lp_70ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_lp_70ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_lp_70ms', AD_Right, ADIST_Large );		
					
			str.AddAttack( 'man_geralt_sword_attack_strong_3_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_8_lp_70ms', ADIST_Medium );	
		}	
	}
	
	private final function CreateAttackLightVsRiderAspect()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		

		aspect = comboDefinition.CreateComboAspect( 'AttackLightVsRider' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Large );			
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', ADIST_Medium );
		}
		{
			str = aspect.CreateComboString( true );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Large );

			
			str.AddAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', ADIST_Medium );		
			str.AddAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', ADIST_Medium );		
			str.AddAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', ADIST_Medium );		
		}	
	}
	
	private final function CreateAttackHeavyVsRiderAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		aspect = comboDefinition.CreateComboAspect( 'AttackHeavyVsRider' );
		
		{
			str = aspect.CreateComboString( false );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_10_rp_70ms', AD_Front, ADIST_Medium );		
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_rp_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_rp_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_rp_70ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_10_rp_70ms', AD_Front, ADIST_Large );	
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_rp_70ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_rp_70ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_rp_70ms', AD_Right, ADIST_Large );		
					
			str.AddAttack( 'man_geralt_sword_attack_strong_10_rp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_4_rp_70ms', ADIST_Medium );
		}		
		
		
		{
			str = aspect.CreateComboString( true );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_9_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_10_lp_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_lp_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_lp_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_lp_70ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_9_lp_70ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_10_lp_70ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_back_1_lp_70ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_lp_70ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_lp_70ms', AD_Right, ADIST_Large );		
					
			str.AddAttack( 'man_geralt_sword_attack_strong_9_lp_70ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_strong_10_lp_70ms', ADIST_Medium );
		}	
	}
	
	private final function CreateAttackLightAspectSlopeUp()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		

		aspect = comboDefinition.CreateComboAspect( 'AttackLightSlopeUp' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Large );			
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', ADIST_Medium );
		}
		{
			str = aspect.CreateComboString( true );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Large );

			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', ADIST_Medium );		
		}	
	}	

	private final function CreateAttackLightAspectSlopeDown()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		

		aspect = comboDefinition.CreateComboAspect( 'AttackLightSlopeDown' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_8_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_8_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_rp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_3_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_rp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_rp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_rp_50ms', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_rp_50ms', AD_Right, ADIST_Large );			
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_8_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'man_geralt_sword_attack_fast_8_rp_40ms', ADIST_Medium  );
		}
		{
			str = aspect.CreateComboString( true );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_lp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_lp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_lp_50ms', AD_Back, ADIST_Large );			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_lp_50ms', AD_Left, ADIST_Large );			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_lp_50ms', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_lp_50ms', AD_Right, ADIST_Large );	

			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', ADIST_Medium );		
		}	
	}	


	private final function CreateAttackLightCapsuleShort()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		

		aspect = comboDefinition.CreateComboAspect( 'AttackLightCapsuleShort' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_8_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_8_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_rp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_3_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_rp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_rp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_rp_50ms', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_rp_50ms', AD_Right, ADIST_Large );	
				
			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_8_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'man_geralt_sword_attack_fast_8_rp_40ms', ADIST_Medium  );
		}
		{
			str = aspect.CreateComboString( true );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );

			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_lp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_lp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_lp_50ms', AD_Back, ADIST_Large );			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_lp_50ms', AD_Left, ADIST_Large );			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_lp_50ms', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_lp_50ms', AD_Right, ADIST_Large );		

			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', ADIST_Small );
			str.AddAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'man_geralt_sword_attack_fast_1_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_5_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_6_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_7_lp_40ms', ADIST_Medium );
			str.AddAttack( 'man_geralt_sword_attack_fast_9_lp_40ms', ADIST_Medium );		
		}	
	}

	private final function CreateAttackNeutral()
	{
	
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		

		aspect = comboDefinition.CreateComboAspect( 'AttackNeutral' );
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'combat_locomotion_sucker_punch_40ms_close', AD_Front, ADIST_Small );
			
			
			str.AddDirAttack( 'combat_locomotion_sucker_punch_70ms_far', AD_Front, ADIST_Medium );	

			
			str.AddAttack( 'combat_locomotion_sucker_punch_40ms_close', ADIST_Small );
			
			
			str.AddAttack( 'combat_locomotion_sucker_punch_70ms_far', ADIST_Medium );				
		}
		{
			str = aspect.CreateComboString( true );

			
			str.AddDirAttack( 'combat_locomotion_sucker_punch_40ms_close', AD_Front, ADIST_Small );

			
			str.AddDirAttack( 'combat_locomotion_sucker_punch_70ms_far', AD_Front, ADIST_Medium );	
			
			
			str.AddAttack( 'combat_locomotion_sucker_punch_40ms_close', ADIST_Small );
			
			
			str.AddAttack( 'combat_locomotion_sucker_punch_70ms_far', ADIST_Medium );		
		}		
	}

	private final function CreateAttackNeutralUnconscious()
	{
	
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		

		aspect = comboDefinition.CreateComboAspect( 'AttackNeutralUnconscious' );
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'combat_locomotion_kick_1', AD_Front, ADIST_Small );
			str.AddDirAttack( 'combat_locomotion_kick_2', AD_Front, ADIST_Small );
			str.AddDirAttack( 'combat_locomotion_kick_3', AD_Front, ADIST_Small );
		
			
			str.AddDirAttack( 'combat_locomotion_kick_1', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'combat_locomotion_kick_2', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'combat_locomotion_kick_3', AD_Front, ADIST_Medium );			

			
			str.AddAttack( 'combat_locomotion_kick_1', ADIST_Small );
			str.AddAttack( 'combat_locomotion_kick_2', ADIST_Small );
			str.AddAttack( 'combat_locomotion_kick_3', ADIST_Small );
			
			
			str.AddAttack( 'combat_locomotion_kick_1', ADIST_Medium );
			str.AddAttack( 'combat_locomotion_kick_2', ADIST_Medium );
			str.AddAttack( 'combat_locomotion_kick_3', ADIST_Medium );			
		}
		{
			str = aspect.CreateComboString( true );

			
			str.AddDirAttack( 'combat_locomotion_kick_1', AD_Front, ADIST_Small );
			str.AddDirAttack( 'combat_locomotion_kick_2', AD_Front, ADIST_Small );
			str.AddDirAttack( 'combat_locomotion_kick_3', AD_Front, ADIST_Small );
			
			
			str.AddDirAttack( 'combat_locomotion_kick_1', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'combat_locomotion_kick_2', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'combat_locomotion_kick_3', AD_Front, ADIST_Medium );			

			
			str.AddAttack( 'combat_locomotion_kick_1', ADIST_Small );
			str.AddAttack( 'combat_locomotion_kick_2', ADIST_Small );
			str.AddAttack( 'combat_locomotion_kick_3', ADIST_Small );
			
			
			str.AddAttack( 'combat_locomotion_kick_1', ADIST_Medium );
			str.AddAttack( 'combat_locomotion_kick_2', ADIST_Medium );
			str.AddAttack( 'combat_locomotion_kick_3', ADIST_Medium );		
		}		
	}					
		
	protected function PerformPirouette()
	{
		var vx : float;
		var vy : float;
		var mgt : float;
		var vec : Vector;
		var startPoint : Vector;
		var targetPoint : Vector;
		var distanceToTarget : float;
	
		startPoint = thePlayer.GetWorldPosition();
		targetPoint = thePlayer.GetTarget().GetWorldPosition();
		distanceToTarget = VecDistance(startPoint, targetPoint);
				
		vx = targetPoint.X - startPoint.X;
		vy = targetPoint.Y - startPoint.Y;
		
		mgt = SqrtF(vx*vx + vy*vy);
		vx /= mgt;
		vy /= mgt;		

		vec.X = startPoint.X + vx * (mgt + distanceToTarget );
		vec.Y = startPoint.Y + vy * (mgt + distanceToTarget );
		
		thePlayer.ActionMoveOnCurveToAsync( vec, distanceToTarget, true );		
	}

	event OnPerformSpecialAttack( isLightAttack : bool, enableAttack : bool )
	{
		var actor 					: CActor;
		var playerToTargetHeading, staminaCostPerSec	: float;
		var newTarget : CActor;
		var mutagen : W3Mutagen21_Effect;
	
		if ( !thePlayer.IsCombatMusicEnabled() && enableAttack && 
			( !isLightAttack && !thePlayer.CanAttackWhenNotInCombat( EBAT_SpecialAttack_Heavy, false, newTarget ) ) )
		{
			thePlayer.RemoveTimer( 'IsSpecialLightAttackInputHeld' );
			thePlayer.RemoveTimer( 'IsSpecialHeavyAttackInputHeld' );
			thePlayer.RemoveTimer( 'SpecialAttackLightSustainCost' );
			thePlayer.RemoveTimer( 'SpecialAttackHeavySustainCost' );
			thePlayer.RemoveTimer( 'UpdateSpecialAttackLightHeading' );
			
			if ( !isLightAttack )
			{
				parent.RaiseCombatActionFriendlyEvent();
				actor = (CActor)(parent.slideTarget);	
				playerToTargetHeading = VecHeading( actor.GetWorldPosition() - parent.GetWorldPosition() );
				parent.SetCustomRotation( 'Attack', playerToTargetHeading, 0.0f, 0.3f, false );
			}
		}
		else
		{
			if(enableAttack)
			{
				theGame.GetBehTreeReactionManager().CreateReactionEvent( parent, 'PlayerSpecialAttack', -1.0f, 20.0f, 0.25f, -1 );
				parent.BlockAction( EIAB_Crossbow, 'SpecialAttack' );
			}
			else
			{
				theGame.GetBehTreeReactionManager().RemoveReactionEvent( parent, 'PlayerSpecialAttack' );
				parent.UnblockAction( EIAB_Crossbow, 'SpecialAttack' );
			}
			
			if ( isLightAttack )
			{
				if(enableAttack)
				{
					parent.SetSlideTarget( NULL );
				}
				else
				{
					
					parent.RemoveTimer( 'IsSpecialLightAttackInputHeld' );
					parent.RemoveTimer( 'IsSpecialHeavyAttackInputHeld' );
					parent.RemoveTimer('SpecialAttackLightSustainCost');
					
					parent.ResumeStaminaRegen('WhirlSkill');
					
					if(thePlayer.HasBuff(EET_Mutagen21) && enableAttack)
					{
						mutagen = (W3Mutagen21_Effect)thePlayer.GetBuff(EET_Mutagen21);
						mutagen.Heal();
					}
				}
					
				PerformSpecialAttackLight( enableAttack );
			}
			else
			{
				if(enableAttack)
				{
					
					parent.specialHeavyStartEngineTime = theGame.GetEngineTime();
					
					
					if(parent.GetStatPercents(BCS_Stamina) > 0.99f)
					{
						staminaCostPerSec = parent.GetStaminaActionCost(ESAT_Ability, parent.GetSkillAbilityName(S_Sword_s02), 1.0f);
						parent.specialHeavyChargeDuration = parent.GetStatMax(BCS_Stamina) / staminaCostPerSec;
					}
					
					parent.AddTimer('SpecialAttackHeavySustainCost', 0.001, true);
					parent.DrainStamina(ESAT_Ability, 0, 0, parent.GetSkillAbilityName(S_Sword_s02));
				}
				else
				{
					parent.RemoveTimer('SpecialAttackHeavySustainCost');
					
					if(thePlayer.HasBuff(EET_Mutagen21))
					{
						mutagen = (W3Mutagen21_Effect)thePlayer.GetBuff(EET_Mutagen21);
						mutagen.Heal();
					}
				}
					
				PerformSpecialAttackHeavy( enableAttack );
			}
		}
	}
	
	entry function PerformSpecialAttackLight( enableAttack : bool )
	{	
		var temp : float;

		if ( parent.GetBehaviorVariable( 'isPerformingSpecialAttack' ) == 0.f )
		{
			if ( enableAttack )
			{
				parent.AddCustomOrientationTarget( OT_CustomHeading, 'SpecialAttackLight' );
				parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 1.f );
				temp = parent.GetBehaviorVariable( 'combatActionType' );
				
				
					if ( parent.RaiseForceEvent( 'CombatAction' ) )
					{
						parent.AddTimer('SpecialAttackLightSustainCost', 0.001, true);
						virtual_parent.OnCombatActionStart();
					}
				
				
				parent.SetBehaviorVariable( 'combatActionType', (int)CAT_SpecialAttack );
				parent.SetBehaviorVariable( 'playerAttackType', 0 );
				if ( parent.bLAxisReleased )
					parent.SetOrientationTargetCustomHeading( parent.GetHeading(), 'SpecialAttackLight' );
				else
					parent.SetOrientationTargetCustomHeading( parent.rawPlayerHeading, 'SpecialAttackLight' );
				
				parent.AddTimer( 'UpdateSpecialAttackLightHeading', 0.f, true );
			}
		}
		else
		{
			if ( !enableAttack
				
				&& parent.GetBehaviorVariable( 'combatActionType' ) == (int)CAT_SpecialAttack
				&& parent.GetBehaviorVariable( 'playerAttackType' ) == 0 )
			{
				parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 0.f );
				parent.RemoveCustomOrientationTarget( 'SpecialAttackLight' );
				parent.RemoveTimer( 'UpdateSpecialAttackLightHeading' );
			}
		}
	}
	
	timer function UpdateSpecialAttackLightHeading( time : float , id : int)
	{	
		
			if ( parent.bLAxisReleased )
				parent.SetOrientationTargetCustomHeading( parent.GetHeading(), 'SpecialAttackLight' );
			else
			{
				parent.SetOrientationTargetCustomHeading(  parent.rawPlayerHeading, 'SpecialAttackLight' );
			}
		
	}
	
	entry function PerformSpecialAttackHeavy( enableAttack : bool )
	{	
		var playerToTargetDist 			: float;
		var completeSpecialAttackTime	: float;
		
		if ( parent.GetBehaviorVariable( 'isPerformingSpecialAttack' ) == 0.f )
		{
			if ( enableAttack )
			{
				parent.AddCustomOrientationTarget( OT_Actor, 'SpecialAttackHeavy' );
				parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 1.f );
				parent.SetBehaviorVariable( 'playerAttackType', 1 );
				parent.SetBehaviorVariable( 'combatActionType', (int)CAT_SpecialAttack );
				
				if ( parent.RaiseForceEvent( 'CombatAction' ) )
					virtual_parent.OnCombatActionStart();
				
				parent.specialAttackCamera = true;
			}
		}
		else
		{
			if ( !enableAttack 
				&& parent.IsInCombatAction() 
				&& parent.GetBehaviorVariable( 'combatActionType' ) == (int)CAT_SpecialAttack
				&& parent.GetBehaviorVariable( 'playerAttackType' ) == 1 )
			{
				parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 0.f );
				parent.RemoveCustomOrientationTarget( 'SpecialAttackHeavy' );
			}
		}
	}
		
	event OnAnimEvent_FinishSpecialHeavyAttack( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var animation : SCameraAnimationDefinition;
		var specialHeavyAnimDuration : float;

		if ( animEventType == AET_DurationStart )
		{
			animation.animation = 'camera_shake_loop_lvl1_1';
			animation.priority = CAP_High;
			animation.blendIn = 0.1f;
			animation.blendOut = 0.1f;
			animation.weight = 2.f;
			animation.speed	= 1.0f;
			animation.loop = true;
			animation.additive = true;
			animation.reset = true;
			
			theGame.GetGameCamera().PlayAnimation( animation );
			
			
			specialHeavyAnimDuration = GetEventDurationFromEventAnimInfo( animInfo );									
			specialHeavyAnimDuration += EngineTimeToFloat(theGame.GetEngineTime() - parent.specialHeavyStartEngineTime);			
			
			
			parent.specialHeavyChargeDuration = MinF(parent.specialHeavyChargeDuration, specialHeavyAnimDuration);
		}
	}
	
	event OnSAHeavyStartComplete()
	{
		theGame.GetGameCamera().StopAnimation( 'camera_shake_loop_lvl1_1' );
		parent.UnblockAction( EIAB_Crossbow, 'SpecialAttack' );
		parent.RemoveTimer('SpecialAttackHeavySustainCost');
	}
}
