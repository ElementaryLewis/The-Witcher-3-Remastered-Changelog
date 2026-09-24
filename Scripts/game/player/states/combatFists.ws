/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EInitialAction
{
	IA_None,
	IA_AttackLight,
	IA_AttackHeavy,
	IA_CastSign,
	IA_ThrowItem,
	IA_CriticalState,
}


state CombatFists in W3PlayerWitcher extends Combat
{
	
	
	
	event OnEnterState( prevStateName : name )
	{
		theInput.SetContext(parent.GetCombatInputContext());
		super.OnEnterState(prevStateName);
		
		parent.OnEquipMeleeWeapon( PW_Fists, true );
	
		this.CombatFistsInit( prevStateName );	
	}
	
	
	event OnLeaveState( nextStateName : name )
	{
		startupAction = IA_None;
		
		
		this.CombatFistsDone( nextStateName );
		
		
		super.OnLeaveState(nextStateName);		
	}
	
	
	var action : SInputAction;
	
	entry function CombatFistsInit( prevStateName : name )
	{
		parent.SetBIsCombatActionAllowed( true );
		
		
		
		BuildComboPlayer();
		
		parent.LockEntryFunction( false );
		
		switch( startupAction )
		{
			case IA_AttackLight:
				parent.SetPrevRawLeftJoyRot();
				parent.SetupCombatAction( EBAT_LightAttack, BS_Pressed );
				break;
			
			case IA_AttackHeavy:
				parent.SetPrevRawLeftJoyRot();
				parent.SetupCombatAction( EBAT_HeavyAttack, BS_Pressed );
				break;
			
			case IA_CastSign:
				parent.SetupCombatAction( EBAT_CastSign, BS_Pressed );
				break;
			
			case IA_ThrowItem:
				if ( parent.CanSetupCombatAction_Throw() )
				{
					parent.SetupCombatAction( EBAT_ItemUse, BS_Pressed );					
				}
				break;
			case IA_CriticalState:
				parent.CriticalBuffInformBehavior( startupBuff );
				break;
			
			default:
				Log( "Enter CombatFists w/out attacking" );
		}		
		
		CombatFistsLoop();	
	}
	
	
	entry function CombatFistsDone( nextStateName : name )
	{
		
	}
	
	
	latent function CombatFistsLoop()
	{
		while( true )
		{
			Sleep( 0.5 );
		}		
	}

	
	event OnCombatActionStart()
	{
		parent.SetCombatIdleStance( 1.f );
		parent.OnCombatActionStart();
	}
	
	event OnCombatActionEnd()
	{
		parent.OnCombatActionEnd();	
	}

	event OnCombatActionEndComplete()
	{
		super.OnCombatActionEndComplete();	
	}
	
	event OnCreateAttackAspects()
	{
		CreateAttackLightNoTargetAspect();
		CreateAttackHeavyNoTargetAspect();
		CreateAttackLightAspect();
		CreateAttackHeavyAspect();
		CreateAttackLightFarAspect();
		CreateAttackHeavyFarAspect();
	}
	
	private final function CreateAttackLightNoTargetAspect()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;

		aspect = comboDefinition.CreateComboAspect( 'AttackLightNoTarget' );
		
		{
			str = aspect.CreateComboString( false );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_1_lh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_1_rh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_2_lh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_2_rh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_3_lh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_3_rh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_4_lh_40ms_short', AD_Front, ADIST_Medium );			
			str.AddDirAttack( 'man_fistfight_attack_fast_back_1_lh_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Medium );

			str.AddAttack( 'man_fistfight_attack_fast_1_lh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_1_rh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_2_lh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_2_rh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_3_lh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_3_rh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_4_lh_40ms_short', ADIST_Medium );
		}	
		{
			str = aspect.CreateComboString( true );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_1_lh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_1_rh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_2_lh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_2_rh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_3_lh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_3_rh_40ms_short', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_4_lh_40ms_short', AD_Front, ADIST_Medium );			
			str.AddDirAttack( 'man_fistfight_attack_fast_back_1_lh_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Medium );

			str.AddAttack( 'man_fistfight_attack_fast_1_lh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_1_rh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_2_lh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_2_rh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_3_lh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_3_rh_40ms_short', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_4_lh_40ms_short', ADIST_Medium );
		}		
	}	

	private final function CreateAttackHeavyNoTargetAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		aspect = comboDefinition.CreateComboAspect( 'AttackHeavyNoTarget' );
		
		{
			str = aspect.CreateComboString( false );
					
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_rh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_rh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_3_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Medium );			

			str.AddAttack( 'man_fistfight_attack_heavy_1_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_1_rh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_2_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_2_rh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_3_lh_70ms', ADIST_Medium );
		}		
		
		
		{
			str = aspect.CreateComboString( true );

			str.AddDirAttack( 'man_fistfight_attack_heavy_1_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_rh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_rh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_3_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Medium );			

			str.AddAttack( 'man_fistfight_attack_heavy_1_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_1_rh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_2_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_2_rh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_3_lh_70ms', ADIST_Medium );	
		}	
	}

	private final function CreateAttackLightAspect()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;

		aspect = comboDefinition.CreateComboAspect( 'AttackLight' );
		
		{
			str = aspect.CreateComboString( false );
			
			str.AddDirAttack( 'man_fistfight_close_combo_attack_1', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_back_1_lh_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_1_lh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_1_rh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_2_lh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_2_rh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_3_lh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_3_rh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_4_lh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_5_rl_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_back_1_lh_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_2_lh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_2_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_back_1_rh_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_left_1_rh_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_right_1_rh_50ms', AD_Right, ADIST_Large );	
			
			str.AddAttack( 'man_fistfight_close_combo_attack_1', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_2', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_3', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_4', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_5', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_6', ADIST_Small );

			str.AddAttack( 'man_fistfight_attack_fast_1_lh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_1_rh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_2_lh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_2_rh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_3_lh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_3_rh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_4_lh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_5_rl_40ms', ADIST_Medium );

			str.AddAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', ADIST_Large );
			str.AddAttack( 'man_fistfight_attack_fast_far_forward_2_lh_50ms', ADIST_Large );
			str.AddAttack( 'man_fistfight_attack_fast_far_forward_2_rh_50ms', ADIST_Large );			
			
			
			aspect.AddLink( 'man_fistfight_close_combo_attack_1', 'man_fistfight_close_combo_attack_2' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_2', 'man_fistfight_close_combo_attack_3' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_3', 'man_fistfight_close_combo_attack_4' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_4', 'man_fistfight_close_combo_attack_5' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_5', 'man_fistfight_close_combo_attack_6' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_6', 'man_fistfight_close_combo_attack_2' );
		}
		
		{
			str = aspect.CreateComboString( true );
			
			str.AddDirAttack( 'man_fistfight_close_combo_attack_1', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_back_1_lh_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_1_lh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_1_rh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_2_lh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_2_rh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_3_lh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_3_rh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_4_lh_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_5_rl_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_back_1_lh_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_2_lh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_2_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_back_1_rh_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_left_1_rh_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_right_1_rh_50ms', AD_Right, ADIST_Large );	
			
			str.AddAttack( 'man_fistfight_close_combo_attack_1', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_2', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_3', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_4', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_5', ADIST_Small );
			str.AddAttack( 'man_fistfight_close_combo_attack_6', ADIST_Small );

			str.AddAttack( 'man_fistfight_attack_fast_1_lh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_1_rh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_2_lh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_2_rh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_3_lh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_3_rh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_4_lh_40ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_fast_5_rl_40ms', ADIST_Medium );

			str.AddAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', ADIST_Large );
			str.AddAttack( 'man_fistfight_attack_fast_far_forward_2_lh_50ms', ADIST_Large );
			str.AddAttack( 'man_fistfight_attack_fast_far_forward_2_rh_50ms', ADIST_Large );				
			
			
			aspect.AddLink( 'man_fistfight_close_combo_attack_1', 'man_fistfight_close_combo_attack_2' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_2', 'man_fistfight_close_combo_attack_3' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_3', 'man_fistfight_close_combo_attack_4' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_4', 'man_fistfight_close_combo_attack_5' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_5', 'man_fistfight_close_combo_attack_6' );
			aspect.AddLink( 'man_fistfight_close_combo_attack_6', 'man_fistfight_close_combo_attack_2' );
		}
	}
	
	private final function CreateAttackHeavyAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		aspect = comboDefinition.CreateComboAspect( 'AttackHeavy' );
		
		{
			str = aspect.CreateComboString( false );
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_lh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_rh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_lh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_rh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_3_lh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_rh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_rh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_3_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_4_ll_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Medium );			

			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_rh_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_2_ll_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_back_1_rh_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_left_1_rh_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_right_1_rh_80ms', AD_Right, ADIST_Large );			
					
			str.AddAttack( 'man_fistfight_attack_heavy_1_lh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_1_rh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_2_lh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_2_rh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_3_lh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_4_ll_70ms', ADIST_Small );

			str.AddAttack( 'man_fistfight_attack_heavy_1_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_1_rh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_2_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_2_rh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_3_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_4_ll_70ms', ADIST_Medium );

			str.AddAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', ADIST_Large );
			str.AddAttack( 'man_fistfight_attack_heavy_far_1_rh_80ms', ADIST_Large );
			str.AddAttack( 'man_fistfight_attack_heavy_far_2_ll_80ms', ADIST_Large );		
		}		
		
		
		{
			str = aspect.CreateComboString( true );
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_lh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_rh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_lh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_rh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_3_lh_70ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_1_rh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_2_rh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_3_lh_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_4_ll_70ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Medium );			

			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_rh_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_2_ll_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_back_1_rh_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_left_1_rh_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_right_1_rh_80ms', AD_Right, ADIST_Large );			
					
			str.AddAttack( 'man_fistfight_attack_heavy_1_lh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_1_rh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_2_lh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_2_rh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_3_lh_70ms', ADIST_Small );
			str.AddAttack( 'man_fistfight_attack_heavy_4_ll_70ms', ADIST_Small );

			str.AddAttack( 'man_fistfight_attack_heavy_1_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_1_rh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_2_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_2_rh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_3_lh_70ms', ADIST_Medium );
			str.AddAttack( 'man_fistfight_attack_heavy_4_ll_70ms', ADIST_Medium );

			str.AddAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', ADIST_Large );
			str.AddAttack( 'man_fistfight_attack_heavy_far_1_rh_80ms', ADIST_Large );
			str.AddAttack( 'man_fistfight_attack_heavy_far_2_ll_80ms', ADIST_Large );			
		}	
	}
	
	private final function CreateAttackLightFarAspect()
	{
	
		var aspect 		: CComboAspect;
		var str 		: CComboString;

		aspect = comboDefinition.CreateComboAspect( 'AttackLightFar' );
		
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Right, ADIST_Large );

			str.AddAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', ADIST_Large );
		}
		{
			str = aspect.CreateComboString( true );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Right, ADIST_Large );

			str.AddAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', ADIST_Large );
		}
	}
	
	private final function CreateAttackHeavyFarAspect()
	{
	
		var aspect 		: CComboAspect;
		var str 		: CComboString;

		aspect = comboDefinition.CreateComboAspect( 'AttackHeavyFar' );
		
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Right, ADIST_Large );

			str.AddAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', ADIST_Large );
		}
		{
			str = aspect.CreateComboString( true );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', AD_Right, ADIST_Large );

			str.AddAttack( 'man_fistfight_attack_heavy_far_1_lh_80ms', ADIST_Large );
		}
	}		

	event OnGuardedReleased()
	{
	}
	
	event OnUnconsciousEnd()
	{
		parent.OnUnconsciousEnd();
	}
}
