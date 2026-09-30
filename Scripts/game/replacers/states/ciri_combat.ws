/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state CombatSword in W3ReplacerCiri extends Combat
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);	
		theInput.SetContext(parent.GetCombatInputContext());
		parent.OnEquipMeleeWeapon( PW_Steel, true );
		theGame.GetBehTreeReactionManager().CreateReactionEvent( thePlayer, 'DrawWeapon', 0.0f, 10.0f, 2.0f, -1 );
		
		if ( !ciriGhostFxTemplate )
			ciriGhostFxTemplate = (CEntityTemplate)LoadResource('ciri_ghost');
		if ( !ciriPhantomTemplate )
			ciriPhantomTemplate = (CEntityTemplate)LoadResource('ciri_phantom');
	}
	
	event OnLeaveState( nextStateName : name )
	{
		Interrupt();
		super.OnLeaveState(nextStateName);
		theInput.SetContext(parent.GetExplorationInputContext());
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

	event OnCreateAttackAspects()
	{
		CreateAttackLightAspect();
		
		CreateAttackLightFarAspect();
		
		CreateAttackLightFlyingAspect();
		
		CreateAttackLightAspectSlopeUp();
		CreateAttackLightAspectSlopeDown();
		CreateAttackLightCapsuleShort();
		CreateAttackNeutral();
		CreateAttackNeutralUnconscious();
		CreateAttackLightVsRiderAspect();		
	}

	private final function CreateAttackLightAspect()
	{
	
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		

		aspect = comboDefinition.CreateComboAspect( 'AttackLight' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );	
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_forward_1_rp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_back_1_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_left_1_rp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_right_1_rp_50ms', AD_Right, ADIST_Large );			
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_rp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', ADIST_Small );	
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_rp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', ADIST_Medium );
		}
		
		{
			str = aspect.CreateComboString( true );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_forward_1_lp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_back_1_lp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_left_1_lp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_right_1_lp_50ms', AD_Right, ADIST_Large );				
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_lp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_lp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', ADIST_Medium );		
			
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
	
	private final function CreateAttackLightFlyingAspect()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		
		aspect = comboDefinition.CreateComboAspect( 'AttackLightFlying' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_rp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Large );			
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_rp_40ms', ADIST_Medium );
		}
		{
			str = aspect.CreateComboString( true );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_lp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Large );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Medium );		
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_lp_40ms', ADIST_Medium );		
		}		
	}
	
	private final function CreateAttackLightAspectSlopeUp()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		
		aspect = comboDefinition.CreateComboAspect( 'AttackLightSlopeUp' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Large );			
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', ADIST_Medium );
		}
		{
			str = aspect.CreateComboString( true );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword _attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Large );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Medium );		
		}	
	}	

	private final function CreateAttackLightAspectSlopeDown()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		
		aspect = comboDefinition.CreateComboAspect( 'AttackLightSlopeDown' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_forward_1_rp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_back_1_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_left_1_rp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_right_1_rp_50ms', AD_Right, ADIST_Large );			
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', ADIST_Medium  );
		}
		{
			str = aspect.CreateComboString( true );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_forward_1_lp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_back_1_lp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_left_1_lp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_right_1_lp_50ms', AD_Right, ADIST_Large );	
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', ADIST_Medium );		
		}	
	}	

	private final function CreateAttackLightVsRiderAspect()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		
		aspect = comboDefinition.CreateComboAspect( 'AttackLightVsRider' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Large );			
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_rp_40ms', ADIST_Medium );
		}
		{
			str = aspect.CreateComboString( true );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword _attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Large );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Medium );		
		}	
	}	

	private final function CreateAttackLightCapsuleShort()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		
		aspect = comboDefinition.CreateComboAspect( 'AttackLightCapsuleShort' );
		
		{
			str = aspect.CreateComboString( false );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Small );		
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_rp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_rp_40ms', AD_Right, ADIST_Medium );			
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_forward_1_rp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_back_1_rp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_left_1_rp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_right_1_rp_50ms', AD_Right, ADIST_Large );					
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'woman_ciri_sword_attack_fast_3_rp_40ms', ADIST_Medium  );
			str.AddAttack( 'woman_ciri_sword_attack_fast_5_rp_40ms', ADIST_Medium  );
		}
		{
			str = aspect.CreateComboString( true );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', AD_Front, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_left_1_lp_40ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Medium );
			
			
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_forward_1_lp_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_back_1_lp_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_left_1_lp_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'woman_ciri_sword_attack_fast_far_right_1_lp_50ms', AD_Right, ADIST_Large );	
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Small );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', ADIST_Small );
			
			
			str.AddAttack( 'woman_ciri_sword_attack_fast_1_lp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_2_lp_40ms', ADIST_Medium );
			str.AddAttack( 'woman_ciri_sword_attack_fast_4_lp_40ms', ADIST_Medium );		
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
	
	
	
	
	
	
	
	
	
	
	event OnPerformSpecialAttack( startAttack : bool )
	{
	
		if ( !parent.IsAlive() || parent.IsCurrentlyDodging() )
			return false;
		
		if ( startAttack && ( !parent.HasAbility('CiriBlink') || !parent.HasStaminaForSpecialAction() ) )
		{
			if ( parent.HasAbility('CiriBlink') )
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_SpecialAttackLight, , , true);
			return false;
		}
		
		if(startAttack)
		{
			theGame.GetBehTreeReactionManager().CreateReactionEvent( parent, 'PlayerSpecialAttack', -1.0f, 20.0f, 0.25f, -1 );
		}
		else
		{
			theGame.GetBehTreeReactionManager().RemoveReactionEvent( parent, 'PlayerSpecialAttack' );
		}
		
		PerformSpecialAttack( startAttack );
		
		return true;
	}
	
	event OnPerformSpecialAttackHeavy( startAttack : bool )
	{
		if ( !parent.IsAlive() || parent.IsCurrentlyDodging() )
			return false;
			
		if ( startAttack && ( !parent.HasAbility('CiriCharge') || !parent.HasStaminaForSpecialAction() ) )
		{
			parent.SetCombatAction(EBAT_LightAttack);
			OnPerformAttack(theGame.params.ATTACK_NAME_LIGHT);
			return false;
		}
		else
			PerformSpecialAttackHeavy( startAttack );
		
		return true;
	}
	
	event OnPerformCounter()
	{
		if ( !parent.IsAlive() )
			return false;
			
		PerformCounter();
	}
	
	event OnPerformDodge()
	{
		if ( !parent.IsAlive() )
			return false;
		
		if ( thePlayer.IsTerrainTooSteepToRunUp() )
			return false;
		
		PerformDodge();
	}
	
	event OnPerformDash()
	{
		if ( !parent.IsAlive() )
			return false;
		
		if ( thePlayer.IsTerrainTooSteepToRunUp() )
			return false;
		
		PerformDodge(true);
	}
	
	event OnPerformDashAttack()
	{
		if ( !parent.IsAlive() )
			return false;
		
		if ( thePlayer.IsTerrainTooSteepToRunUp() )
			return false;
		
		PerformDodge(true,true);
	}
	
	event OnHitStart()
	{
		Interrupt();
		virtual_parent.OnHitStart();
	}
	
	event OnCombatActionEndComplete()
	{
		Interrupt();
		super.OnCombatActionEndComplete();
	}
	
	event OnDeath( damageAction : W3DamageAction  )
	{
		Interrupt();
		virtual_parent.OnDeath( damageAction );
	}
	
	timer function ReleaseButtonHack( dt : float, id : int )
	{
		parent.OnSpecialActionHeavyEnd();
	}
	
	
	
	
	
	private var specialAttackHeading 					: float;
	private var completeSpecialAttackDist				: float;
	private var specialAttackStartTimeStamp 			: float;
	private var isCompletingSpecialAttack 				: bool;
				
	private var specialAttackSphere 					: CMeshComponent;
	private var specialAttackSphereEnt 					: CEntity;
	
	private saved  var specialAttackEffectTemplate 		: CEntityTemplate;
	private saved  var ciriPhantomTemplate			 	: CEntityTemplate;
	private saved  var ciriGhostFxTemplate			 	: CEntityTemplate;
	
	private var buttonWasHeld 			: bool;		default buttonWasHeld		= false;
	private var specialAttackRadius 	: float;	default specialAttackRadius	= 0.f;
	private var specialAttackInterrupted : bool;	default specialAttackInterrupted = false;
	
	private const var HOLD_SPECIAL_ATTACK_BUTTON_TIME	: float;	default HOLD_SPECIAL_ATTACK_BUTTON_TIME = 0.2f;
	private const var ATTACK_RADIUS_INITIAL_VAL			: float;	default ATTACK_RADIUS_INITIAL_VAL 		= 1.5f;
	private const var ATTACK_RADIUS_MAXIMUM_VAL			: float;	default ATTACK_RADIUS_MAXIMUM_VAL 		= 12.0f;
	private const var ATTACK_RADIUS_INCREASE_SPEED		: float;	default ATTACK_RADIUS_INCREASE_SPEED 	= 8.0f;
	private const var SPECIAL_ATTACK_MAX_TARGETS		: int;		default SPECIAL_ATTACK_MAX_TARGETS 		= 5.0f;
	private const var DODGE_DISTANCE					: float;	default DODGE_DISTANCE	 				= 2.5f;
	private const var DASH_DISTANCE						: float;	default DASH_DISTANCE	 				= 7.0f;
	
	private const var SPECIAL_ATTACK_HEAVY_MAX_DIST		: float;	default SPECIAL_ATTACK_HEAVY_MAX_DIST	= 15.0f;
	
	
	
	
	
	entry function PerformSpecialAttack( startAttack : bool )
	{	
		var playerToTargetDist 			: float;
		var completeSpecialAttackTime	: float;
		
		if ( parent.GetBehaviorVariable( 'isPerformingSpecialAttack' ) == 0.f )
		{
			if ( startAttack )
			{
				if(ShouldProcessTutorial('TutorialCiriBlink'))
					FactsAdd('tut_ciri_blinking');
			
				parent.SetCanPlayHitAnim(true);
				
				SpecialAttackSphereCleanup();
				
				parent.AddCustomOrientationTarget( OT_Actor, 'CiriSpecialAttack');
				parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 1.f );
				parent.SetBehaviorVariable( 'isCompletingSpecialAttack', 0.f );
				parent.SetBehaviorVariable( 'specialAttackInPlace', 0.f );
				parent.SetBehaviorVariable( 'playerAttackType', 2.f );
				parent.SetBehaviorVariable( 'combatActionType', (int)CAT_SpecialAttack );
				if ( parent.RaiseForceEvent( 'CombatAction' ) )
					virtual_parent.OnCombatActionStart();
				
				isCompletingSpecialAttack = false;
				
				buttonWasHeld = false;
				
				specialAttackRadius = ATTACK_RADIUS_INITIAL_VAL;
				
				parent.specialAttackCamera = false;
				
				if ( !specialAttackEffectTemplate )
					specialAttackEffectTemplate = (CEntityTemplate)LoadResource('special_attack_ciri');
					
				specialAttackStartTimeStamp = theGame.GetEngineTimeAsSeconds();
				
				parent.AddTimer( 'SpecialAttackTimer', 0, true );
				
			}
		}
		else
		{
			if ( !startAttack && !isCompletingSpecialAttack )
			{
				parent.RemoveTimer( 'SpecialAttackTimer' );
				
				parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 0.f );
				isCompletingSpecialAttack = true;
				parent.specialAttackCamera = false;
				
				CompleteSpecialAttack();
				parent.RemoveCustomOrientationTarget('CiriSpecialAttack');
			}
		}
	}
	
	entry function PerformSpecialAttackHeavy( startAttack : bool )
	{
		parent.SetCleanupFunction( 'PerformSpecialAttackHeavyCleanup' );
		
		if ( parent.GetBehaviorVariable( 'isPerformingSpecialAttack' ) == 0.f )
		{
			if ( startAttack )
			{
				if(ShouldProcessTutorial('TutorialCiriCharge'))
					FactsAdd('tut_ciri_charging');
					
				parent.SetCanPlayHitAnim(true);
				
				parent.AddCustomOrientationTarget( OT_Actor, 'CiriSpecialAttack');
				parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 1.f );
				parent.SetBehaviorVariable( 'isCompletingSpecialAttack', 0.f );
				parent.SetBehaviorVariable( 'playerAttackType', 3.f );
				parent.SetBehaviorVariable( 'combatActionType', (int)CAT_SpecialAttack );
				if ( parent.RaiseForceEvent( 'CombatAction' ) )
					virtual_parent.OnCombatActionStart();
				
				isCompletingSpecialAttack = false;
				
				buttonWasHeld = false;
				
				
				parent.specialAttackCamera = true;
				
				specialAttackStartTimeStamp = theGame.GetEngineTimeAsSeconds() + 0.2;
				
			}
		}
		else 
		{
			if ( !startAttack && !isCompletingSpecialAttack )
			{
				isCompletingSpecialAttack = true;
				parent.specialAttackCamera = false;
				CompleteSpecialAttackHeavy();
				parent.RemoveCustomOrientationTarget('CiriSpecialAttack');
			}
		}
	}
	
	entry function PerformCounter()
	{
		
		parent.SetCanPlayHitAnim(false);
		
		parent.AddCustomOrientationTarget( OT_Actor, 'CiriSpecialAttack');
		parent.SetBehaviorVariable( 'specialAttackInPlace', 0.f );
		parent.SetBehaviorVariable( 'playerAttackType', 2.f );
		parent.SetBehaviorVariable( 'combatActionType', (int)CAT_SpecialAttack );
		if ( parent.RaiseForceEvent( 'CombatAction' ) )
			virtual_parent.OnCombatActionStart();
		parent.specialAttackCamera = false;
		buttonWasHeld = false;
		isCompletingSpecialAttack = true;
		CompleteSpecialAttack(true);
	}
	
	entry function PerformDodge(optional dash : bool, optional attackDash : bool )
	{
		var evadeDirection 		: EPlayerEvadeDirection;
		var angleDist 			: float;
		var cameraHeadingVec	: Vector;
		var newHeadingVec		: Vector;
		var targetPos			: Vector;
		var currentPos			: Vector;
		var correctedPos		: Vector;
		var tempPos				: Vector;
		var distance			: float;
		var angleToTarget		: float;
		var heading				: float;
		var slideDuration		: float;
		var collision			: array<CName>;
		var res					: bool;
		
		
		distance = VecDistance( parent.GetWorldPosition(), ((CActor)parent.slideTarget).PredictWorldPosition( 0.2f ) );
		if ( attackDash && ( !parent.slideTarget || distance < ((CActor)parent.slideTarget).GetRadius() + parent.GetRadius() + 2.5f ) )
		{
			OnPerformAttack(theGame.params.ATTACK_NAME_LIGHT);
			return;
		}
		
		parent.LockEntryFunction(true);
		
		parent.SetIsCurrentlyDodging(true,true);
		
		parent.EnableCharacterCollisions(false);
		
		SpecialAttackSphereCleanup();
		
		parent.SetBehaviorVariable( 'combatActionType', (int)CAT_CiriDodge );
		
		cameraHeadingVec = theCamera.GetCameraDirection();
		
		if ( parent.bLAxisReleased )
		{
			evadeDirection = PED_Back;
			heading = VecHeading(cameraHeadingVec*-1);
		}
		else
		{
			heading = parent.rawPlayerHeading;
			angleDist = AngleDistance( parent.GetHeading(), heading );
			
			if ( angleDist > 135 )
			{
				evadeDirection = PED_Back;
			}
			else if ( angleDist > 45 )
			{
				evadeDirection = PED_Right;
			}
			else if ( angleDist > -45 )
			{
				evadeDirection = PED_Forward;
			}
			else if ( angleDist > - 135 )
			{
				evadeDirection = PED_Left;
			}
			else
			{
				evadeDirection = PED_Back;
			}
		}
		
		parent.SetCombatActionHeading(heading);
		angleDist = AngleNormalize(heading + 180);
		
		parent.SetBehaviorVariable( 'playerEvadeDirection', (int)evadeDirection );
		
		parent.SetBehaviorVariable( 'requestedDodgeDirection', angleDist );
		
		parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 1.f );
		
		if ( parent.RaiseForceEvent( 'CombatAction' ) )
		{
			res = parent.WaitForBehaviorNodeActivation('CombatActionActivation',0.5);
			if (!res )
			{
				parent.SetIsCurrentlyDodging(false);
				parent.LockEntryFunction(false);
				return;
			}
			
			virtual_parent.OnCombatActionStart();
		}
		else
		{
			parent.SetIsCurrentlyDodging(false);
			parent.LockEntryFunction(false);
			return;
		}
		
		parent.RaiseEvent( 'ItemEndL' );
		
		parent.ResetUninterruptedHitsCount();		
		
		parent.WaitForBehaviorNodeDeactivation('SpecialAttackCiriStart',0.17);
		
		newHeadingVec = VecFromHeading(heading);
		
		currentPos = parent.GetWorldPosition();
		
		
		if ( dash && parent.HasStaminaForDash(false) )
		{
			angleToTarget = NodeToNodeAngleDistance( parent.slideTarget, parent );
			
			if ( parent.slideTarget && ( attackDash || ( !parent.bLAxisReleased && AbsF( AngleDistance( parent.GetHeading() - angleToTarget, heading ) ) < 50 ) ) )
			{
				if ( distance > 4.0f )
				{
					distance = ClampF( distance,DODGE_DISTANCE,distance - ((CActor)parent.slideTarget).GetRadius() - 1.8f );
				}
				else
				{
					distance = ClampF( distance,distance + parent.GetRadius() + ((CActor)parent.slideTarget).GetRadius(),DODGE_DISTANCE );
				}
				
				newHeadingVec = VecFromHeading( AngleNormalize180( parent.GetHeading() - angleToTarget ) );
				targetPos = currentPos + newHeadingVec*distance;
			}
			else
			{
				distance = DASH_DISTANCE;
				targetPos = currentPos + newHeadingVec*distance;
			}
			
			
		}
		else
		{
			distance = DODGE_DISTANCE;
			targetPos = currentPos + newHeadingVec*distance;
			
		}
		
		tempPos = currentPos;
		tempPos.Z += 1.f;
		correctedPos = targetPos;
		correctedPos.Z += 1.f;
		
		collision.PushBack('Static');
		collision.PushBack('Terrain');
		
		if ( theGame.GetWorld().SweepTest(tempPos,correctedPos,0.1,correctedPos,tempPos,collision) )
		{
			targetPos = correctedPos;
			targetPos.Z = currentPos.Z;
		}
		
		parent.StopEffect('Burning');
		
		slideDuration = distance*0.04;
		slideDuration = ClampF( slideDuration, 0.1, 0.2 );
		
		if ( dash && parent.slideTarget )
		{
			SlideToNewPosition(slideDuration, targetPos,newHeadingVec);
		}
		else
		{
			SlideToNewPosition(slideDuration, targetPos);
		}
		
		parent.StopEffect('Burning');
		
		
		{
			Appear();
			parent.RaiseEvent('ForceBlendOut');
			parent.SetIsCurrentlyDodging(false);
			parent.LockEntryFunction(false);
		}
		
		{
			if ( parent.moveTarget )
			{
				angleDist = AngleDistance( parent.GetHeading(), VecHeading(parent.moveTarget.GetWorldPosition() - parent.GetWorldPosition() ));
				
				if ( angleDist > 135 )
					evadeDirection = PED_Back;
				else if ( angleDist > 45 )
					evadeDirection = PED_Right;
				else if ( angleDist > -45 )
					evadeDirection = PED_Forward;
				else if ( angleDist > - 135 )
					evadeDirection = PED_Left;
				else
					evadeDirection = PED_Back;
			}
			else
				evadeDirection = PED_Forward;
			
			parent.SetBehaviorVariable( 'playerEvadeDirection', (int)evadeDirection );
			
			Appear();
			
			parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 0.f );
			
			parent.EnableCharacterCollisions(true);
			
			
			
			parent.SetIsCurrentlyDodging(false);
			
			if ( attackDash )
			{
				OnPerformAttack(theGame.params.ATTACK_NAME_LIGHT);
			}
		}
	}
	
	protected function UpdateCameraInterior( out moveData : SCameraMovementData, timeDelta : float )
	{
		var destYaw : float;
		var targetPos : Vector;
		var playerToTargetVector : Vector;
		var playerToTargetAngles : EulerAngles;
		var playerToTargetPitch : float;
		
		if ( parent.IsCameraLockedToTarget() && parent.IsInCombatAction() && parent.GetBehaviorVariable( 'combatActionType' ) == (int)CAT_CiriDodge )
		{
			super.SetInteriorCameraDesiredPositionMult(0.5);
			moveData.pivotPositionController.SetDesiredPosition( parent.GetWorldPosition(), 0.5 );
			
			playerToTargetVector = parent.GetDisplayTarget().GetWorldPosition() - parent.GetWorldPosition();
			
			moveData.pivotRotationController.SetDesiredHeading( VecHeading( playerToTargetVector ), 0.5f );
			
			if ( AbsF( playerToTargetVector.Z ) <= 1.f )
			{
				if ( parent.IsGuarded() )
					moveData.pivotRotationController.SetDesiredPitch( -25.f );
				else
					moveData.pivotRotationController.SetDesiredPitch( -15.f );
			}
			else
			{
				playerToTargetAngles = VecToRotation( playerToTargetVector );
				playerToTargetPitch = playerToTargetAngles.Pitch + 10;
				
				
				
				moveData.pivotRotationController.SetDesiredPitch( playerToTargetPitch * -1, 0.5f );
			}
		}
		else
			super.UpdateCameraInterior( moveData, timeDelta );
	}
	
	entry function Interrupt()
	{
		parent.GetMovingAgentComponent().GetMovementAdjustor().CancelAll();
		
		if ( !isCompletingSpecialAttack )
		{
			isCompletingSpecialAttack = true;
			SpecialAttackCleanup();
			parent.RemoveCustomOrientationTarget('CiriSpecialAttack');
		}
		else if( specialAttackInterrupted )
		{	
			specialAttackInterrupted = false;
			SpecialAttackCleanup();
			parent.RemoveCustomOrientationTarget('CiriSpecialAttack');
			parent.RemoveBuffImmunity_AllNegative( 'CiriSpecial' );
			parent.StopEffect( 'disappear' );
		}
		else if ( parent.IsCurrentlyDodging() )
		{
			parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 0.f );
		}
		Appear();
	}
	
	
	
	
	
	private const var teleportToLastPos : bool;
	private var lastTarget : CActor;
	
	
	default teleportToLastPos = false;
	
	private latent function CompleteSpecialAttack(optional jumpBehindTarget : bool)
	{
		var cachedPos : Vector;
		var cachedRot : EulerAngles;
		var cachedHeadingVec : Vector;
		var targets : array<CActor>;
		var phantom : W3CiriPhantom;
		var newHeadingVec : Vector;
		var newPosition : Vector;
		var targetPos : Vector;
		var distance : float;
		var correctedZ : float;
		
		
		cachedPos = parent.GetWorldPosition();
		cachedRot = parent.GetWorldRotation();
		cachedHeadingVec = parent.GetHeadingVector();
		
		SpecialAttackSphereCleanup();
		
		parent.AddBuffImmunity_AllNegative( 'CiriSpecial', true );
		parent.StopEffect('critical_poison');
		
		
		parent.MakeInvulnerable(true);
		
		
		if ( jumpBehindTarget )
		{
			lastTarget = (CActor)parent.slideTarget;
			
			if ( !lastTarget.GetGameplayVisibility() )
				lastTarget = NULL;
		}
		else if ( specialAttackStartTimeStamp + HOLD_SPECIAL_ATTACK_BUTTON_TIME < theGame.GetEngineTimeAsSeconds() )
			buttonWasHeld = true;
		else
		{
			while ( !parent.RaiseEvent('ForceBlendOut') )
			{
				SleepOneFrame();
			}
			return;
		}
		
		parent.SetBehaviorVariable( 'isCompletingSpecialAttack', 1.f );
		
		if ( buttonWasHeld )
		{
			FindSpecialAttackTargets(targets, SPECIAL_ATTACK_MAX_TARGETS);
		}
		
		if ( !isCompletingSpecialAttack )
			return;
		
		if ( buttonWasHeld )
		{
			parent.SetBehaviorVariable( 'specialAttackInPlace', 1.f );
			Disappear();
			specialAttackInterrupted = true;
			ExecuteSpecialAttack(targets);
		}
		
		specialAttackInterrupted = false;
		
		PhantomsCleanup();
		
		if ( lastTarget )
		{
			targetPos = lastTarget.GetWorldPosition();
			newHeadingVec = VecNormalize(cachedPos - targetPos);
			
			if ( !buttonWasHeld )
			{
				RotateToNewHeading(0,VecNormalize(targetPos - cachedPos));
				Disappear();
			}
			
			lastTarget.IsAttacked( true );
			
			if ( jumpBehindTarget )
				distance = lastTarget.GetRadius() + parent.GetRadius() + 0.01;
			else
				distance = lastTarget.GetRadius() + parent.GetRadius() + 1.8f;
			if ( distance < 1.5 )
				distance = 1.5;
			
			newPosition = targetPos - newHeadingVec*distance;
			
			if ( !theGame.GetWorld().NavigationComputeZ(newPosition,newPosition.Z - 1, newPosition.Z + 1, correctedZ ) )
			{
				SlideToNewPosition(GetSlideDuration(cachedPos), cachedPos, cachedHeadingVec, true );
			}
			else
			{
				SlideToNewPosition(GetSlideDuration(newPosition), newPosition, newHeadingVec );
			}
			
			lastTarget = NULL;
		}
		else
		{
			parent.SetBehaviorVariable( 'specialAttackInPlace', 1.f );
			
			if( targets.Size() > 0 )
			{
				parent.OnSlideToNewPositionStart(GetSlideDuration(newPosition),cachedPos,cachedHeadingVec);
				SlideToNewPosition(GetSlideDuration(cachedPos), cachedPos, cachedHeadingVec, true);
			}
			else
			{
				parent.OnSlideToNewPositionStart(0.4,cachedPos,cachedHeadingVec);
				SlideToNewPosition(0.4, cachedPos, cachedHeadingVec, true );
			}
		}
		
		Appear();
		parent.RemoveBuffImmunity_AllNegative( 'CiriSpecial' );
		
		
		parent.MakeInvulnerable(false);
		
	}
	
	
	private latent function CompleteSpecialAttackHeavy()
	{
		var buttonHeldTime		: float;
		var newHeadingVec		: Vector;
		var destinationPos		: Vector;
		var distance			: float;
		var angleToTarget		: float;
		var vecDistance			: float;
		var slideDuration		: float;
		var npc					: CNewNPC;
		
		buttonHeldTime = theGame.GetEngineTimeAsSeconds() - specialAttackStartTimeStamp;
		
		{
			parent.SetCombatIdleStance( 0.f );
		
			parent.DrainResourceForSpecialAttack();
			
			parent.SetBehaviorVariable( 'isCompletingSpecialAttack', 1.f );
			
			
			parent.MakeInvulnerable(true);
			
			
			
			if ( parent.slideTarget && GetAttitudeBetween( parent, parent.slideTarget ) == AIA_Hostile )
			{
				angleToTarget = NodeToNodeAngleDistance( parent.slideTarget, parent );
			}
			newHeadingVec = VecFromHeading( AngleNormalize180( parent.GetHeading() - angleToTarget ) );
			
			vecDistance = VecDistance(parent.GetWorldPosition(), parent.slideTarget.GetWorldPosition());
			distance = ClampF(buttonHeldTime,HOLD_SPECIAL_ATTACK_BUTTON_TIME,2.f);
			distance = SPECIAL_ATTACK_HEAVY_MAX_DIST * (distance*0.25);
			distance = ClampF(distance,vecDistance + distance,SPECIAL_ATTACK_HEAVY_MAX_DIST);
			
			destinationPos = parent.GetWorldPosition() + newHeadingVec*distance;
			
			slideDuration = distance/30; 
			slideDuration = ClampF(slideDuration,0.1,0.4);
			
			parent.EnableSpecialAttackHeavyCollsion(true);
			
			SlideToNewPosition(slideDuration, destinationPos, newHeadingVec);
			
			Sleep(0.05f);
			parent.EnableSpecialAttackHeavyCollsion(false);
			
			parent.MakeInvulnerable(false);
		}
		
		
		
		parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 0.f );
		isCompletingSpecialAttack = false;
	}
	
	private function PerformSpecialAttackHeavyCleanup()
	{
		parent.SetBehaviorVariable( 'isCompletingSpecialAttack', 1.f );
		parent.EnableSpecialAttackHeavyCollsion(false);
		parent.MakeInvulnerable(false);
		parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 0.f );
		isCompletingSpecialAttack = false;
	}
	
	private function EnergyBurst( radius : float )
	{
		var entities : array<CGameplayEntity>;
		var i : int;
		
		FindGameplayEntitiesInSphere(	entities,
										parent.GetWorldPosition(),
										radius,
										50,
										'',
										FLAG_ExcludeTarget + FLAG_OnlyAliveActors + FLAG_Attitude_Hostile + FLAG_TestLineOfSight,
										(CGameplayEntity)parent	);
		
		for ( i=0; i<entities.Size() ; i+=1 )
		{
			((CActor)entities[i]).AddEffectDefault(EET_Knockdown,(CGameplayEntity)parent, 'CiriEnergyBurst');
		}
	}
	
	
	
	
	
	private function SpecialAttackCleanup()
	{
		SpecialAttackSphereCleanup();
		PhantomsCleanup();
		
		parent.RemoveTimer( 'SpecialAttackTimer' );
		parent.SetBehaviorVariable( 'isCompletingSpecialAttack', 0.f );	
		parent.SetBehaviorVariable( 'isPerformingSpecialAttack', 0.f );
		isCompletingSpecialAttack = false;
		parent.MakeInvulnerable(false);
		
		parent.RemoveBuffImmunity_AllNegative( 'CiriSpecial' );
		
		parent.SetBehaviorVariable( 'specialAttackInPlace', 1.f );
		Appear();
	}
	
	private function SpecialAttackSphereCleanup()
	{
		parent.RemoveTimer('SpecialAttackTimer');
		if ( specialAttackSphereEnt )
		{
			specialAttackSphereEnt.PlayEffect('fade');
			specialAttackSphereEnt.DestroyAfter(0.6);
		}

		specialAttackSphereEnt = NULL;
		specialAttackSphere = NULL;
	}
	
	private function PhantomsCleanup()
	{
		((W3ReplacerCiri)parent).DestroyPhantoms();
	}
	
	
	
	
	
	private function SpawnSpecialAttackSphere()
	{
		specialAttackSphereEnt = theGame.CreateEntity( specialAttackEffectTemplate, parent.GetWorldPosition(), parent.GetWorldRotation() );
	}
	
	timer function SpecialAttackTimer( dt : float , id : int)
	{
		if ( !buttonWasHeld && specialAttackStartTimeStamp + HOLD_SPECIAL_ATTACK_BUTTON_TIME < theGame.GetEngineTimeAsSeconds() )
			buttonWasHeld = true;
			
		if ( buttonWasHeld )
		{
			if ( !specialAttackSphereEnt )
				SpawnSpecialAttackSphere();
			
			if ( parent.HasAbility('Ciri_Rage') )
				specialAttackRadius += dt*ATTACK_RADIUS_INCREASE_SPEED*2;
			else
				specialAttackRadius += dt*ATTACK_RADIUS_INCREASE_SPEED;
				
			if ( specialAttackRadius >= ATTACK_RADIUS_MAXIMUM_VAL )
			{
				specialAttackRadius = ATTACK_RADIUS_MAXIMUM_VAL;
				parent.RemoveTimer('SpecialAttackTimer');
			}
			if( !specialAttackSphere )
			{
				specialAttackSphere = (CMeshComponent)(specialAttackSphereEnt.GetComponentByClassName('CMeshComponent'));
			}
			
			if ( specialAttackSphere )
			{
				specialAttackSphere.SetScale(Vector(specialAttackRadius,specialAttackRadius,specialAttackRadius));
			}
		}
	}
	
	private function Appear()
	{
		parent.SetBehaviorVariable( 'isCompletingSpecialAttack', 0.f );
		parent.RaiseEvent( 'SACiriAppear' );
		parent.MakeInvulnerable(false);
		parent.ToggleRageEffect(true);
	}
	
	private latent function Disappear()
	{
		parent.ToggleRageEffect(false);
		parent.MakeInvulnerable(true);
		parent.WaitForBehaviorNodeDeactivation('DisappearEnd',2.0);
	}
	
	private latent function SlideToNewPosition ( duration : float, newPos : Vector, optional newHeading : Vector, optional alsoTeleport : bool  )
	{
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		
		
		
		
		movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelAll();
		ticket = movementAdjustor.CreateNewRequest( 'CiriSpecialAttackSlide' );
		movementAdjustor.MaxRotationAdjustmentSpeed(ticket, 1000000.f);
		movementAdjustor.AdjustmentDuration(ticket, duration);
		movementAdjustor.SlideTo(ticket, newPos);
		if ( newHeading != Vector(0,0,0) )
			movementAdjustor.RotateTo(ticket,VecHeading(newHeading));
			
		if ( duration > 0 )
			Sleep(duration);
		
		if ( alsoTeleport && VecDistanceSquared(newPos,parent.GetWorldPosition()) > 0.25f ) 
			parent.Teleport(newPos);
	}
	
	private latent function RotateToNewHeading ( duration : float, newHeading : Vector  )
	{
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		
		
		movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelAll();
		ticket = movementAdjustor.CreateNewRequest( 'CiriDodgeRotation' );
		movementAdjustor.MaxRotationAdjustmentSpeed(ticket, 1000000.f);
		movementAdjustor.AdjustmentDuration(ticket, duration);
		if ( newHeading != Vector(0,0,0) )
			movementAdjustor.RotateTo(ticket,VecHeading(newHeading));
		
		if ( duration > 0 )
			Sleep(duration);
	}
	
	private latent function SlideToNewNode ( duration : float, node : CNode )
	{
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		
		
		movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.CancelAll();
		ticket = movementAdjustor.CreateNewRequest( 'CiriSpecialAttackSlide' );
		movementAdjustor.MaxRotationAdjustmentSpeed(ticket, 1000000.f);
		movementAdjustor.AdjustmentDuration(ticket, duration);
		movementAdjustor.SlideTowards(ticket,node);
			
		Sleep(duration);
	}
	
	private var _distances 	: array<float>;
	private var _vectors 	: array<Vector>;
	
	private function GetProperHeadingForCamera( vec : Vector, optional use90 : bool ) : Vector
	{
		var vec90_left, vec90_right : Vector;
		var vec45_left, vec45_right, vec135_left, vec135_right : Vector;
		var cameraHeading : float;
		var distTo90_left, distTo90_right	: float;
		var distTo45_left, distTo135_left	: float;
		var distTo45_right, distTo135_right	: float;
		var chosenVector : Vector;
		var i : int;
		
		
		cameraHeading = VecHeading(theCamera.GetCameraDirection());
		
		if ( use90 )
		{
			vec90_left 		= VecRotByAngleXY(vec,-90);
			vec90_right 	= VecRotByAngleXY(vec,90);
			distTo90_left 	= AngleDistance(cameraHeading,VecHeading(vec90_left));
			distTo90_right 	= AngleDistance(cameraHeading,VecHeading(vec90_right));
			
			if ( AbsF(distTo90_left) < AbsF(distTo90_right) )
				return vec90_left;
			else
				return vec90_right;
		}
		else
		{
			_vectors.Clear();
			_distances.Clear();
			
			vec45_left 		= VecRotByAngleXY(vec,-45); 	_vectors.PushBack(vec45_left);
			vec135_left 	= VecRotByAngleXY(vec,-135);	_vectors.PushBack(vec135_left);
			vec45_right 	= VecRotByAngleXY(vec,45);		_vectors.PushBack(vec45_right);
			vec135_right 	= VecRotByAngleXY(vec,135);		_vectors.PushBack(vec135_right);
			
			distTo45_left 	= AngleDistance(cameraHeading,VecHeading(vec45_left));		_distances.PushBack(AbsF(distTo45_left));
			distTo135_left 	= AngleDistance(cameraHeading,VecHeading(vec135_left));		_distances.PushBack(AbsF(distTo135_left));
			distTo45_right 	= AngleDistance(cameraHeading,VecHeading(vec45_right));		_distances.PushBack(AbsF(distTo45_right));
			distTo135_right = AngleDistance(cameraHeading,VecHeading(vec135_right));	_distances.PushBack(AbsF(distTo135_right));
			
			return _vectors[ArrayFindMinF(_distances)];
		}
		
	}
	
	
	private function IsPositionSupaCool( pos : Vector ) : bool
	{
		return theGame.GetWorld().NavigationCircleTest(pos,parent.GetRadius());
	}
	
	private function GetBetterPosition( oldPosition : Vector, out newPosition : Vector) : bool
	{
		return theGame.GetWorld().NavigationFindSafeSpot(oldPosition, parent.GetRadius(), 3*parent.GetRadius(), newPosition);
	}
	
	private function FindSpecialAttackTargets( out targets : array<CActor>, maxEnemiesNo : int )
	{
		var i : int;
		
		targets = parent.GetNPCsAndPlayersInRange(specialAttackRadius, maxEnemiesNo, '', FLAG_Attitude_Hostile + FLAG_OnlyAliveActors + FLAG_ExcludeTarget);
		
		for ( i=targets.Size()-1 ; i >= 0 ; i-=1 )
		{
			if ( !parent.IsEnemyVisible(targets[i]) || !targets[i].GetGameplayVisibility() )
			{
				targets.Erase(i);
			}
		}
	}
	
	private latent function ExecuteSpecialAttack( targets : array<CActor> )
	{
		var i,j : int;
		var targetPos, playerPos, spawnPos : Vector;
		var spawnHeading : Vector;
		var spawnRot : EulerAngles;
		var dist : float;
		var slideDuration : float;
		var oneTarget : bool;
		
		playerPos = parent.GetWorldPosition();
		
		parent.DrainResourceForSpecialAttack();
		
		for ( i=0 ; i < targets.Size() ; i+= 1)
		{
			if ( i == targets.Size() - 1 && teleportToLastPos )
			{
				lastTarget = targets[i];
				break;
			}
			
			PhantomsCleanup();
			
			if ( targets.Size() == 1 )
			{
				oneTarget = true;
				for( j=0 ; j < 2 ; j+=1 )
				{
					dist = targets[i].GetRadius() + parent.GetRadius() + 1.8f;
					if ( j == 1 )
						GetSpawnPosAndRot(targets[i],-95,dist,spawnPos,spawnRot);
					else if ( j == 0 )
						GetSpawnPosAndRot(targets[i],95,dist,spawnPos,spawnRot);
						
					SpawnPhantomWithAnim(spawnPos, spawnRot, targets[i]);
					Sleep(0.2f);
				}
				lastTarget = targets[i];
			}
			else
			{
				dist = targets[i].GetRadius() + parent.GetRadius() + 1.8f;
				GetSpawnPosAndRot(targets[i],0,dist,spawnPos,spawnRot);
				SpawnPhantomWithAnim(spawnPos, spawnRot, targets[i]);
				Sleep(0.05f);
			}
			
			targets[i].IsAttacked( true );
			
			targetPos = targets[i].GetWorldPosition();
			slideDuration = GetSlideDuration(targetPos);
			
			parent.OnSlideToNewPositionStart(slideDuration,targetPos,GetProperHeadingForCamera(targets[i].GetHeadingVector(),oneTarget));
			SlideToNewNode(slideDuration,targets[i]);
		}
		
	}
	
	private function GetSlideDuration( destinationPos : Vector ) : float
	{
		var slideDistance, slideDuration : float;
		slideDistance = VecDistance(parent.GetWorldPosition(),destinationPos);
		slideDuration = slideDistance/10; 
		slideDuration = ClampF(slideDuration,0.1,0.4);
		return slideDuration;
	}
	
	private function GetSpawnPosAndRot( target : CNode, angleDiff : float, distOffset : float, out spawnPos : Vector, out spawnRot : EulerAngles )
	{
		var headingVec : Vector;
		headingVec = VecFromHeading(AngleNormalize180(target.GetHeading() + angleDiff));
		spawnRot = VecToRotation( headingVec );
		spawnPos = GetSpawnOffsetPosition( target.GetWorldPosition(), headingVec, distOffset );
	}
	
	private function GetSpawnOffsetPosition(targetPos : Vector, out headingVec : Vector, offset : float ) : Vector
	{
		var pos, newPos, normal : Vector;
		
		pos = targetPos - headingVec*offset;
		
		if ( theGame.GetWorld().NavigationFindSafeSpot(pos, parent.GetRadius(), 2.f, newPos) )
		{
			if ( theGame.GetWorld().StaticTrace( newPos + Vector(0,0,3), newPos - Vector(0,0,3), newPos, normal ) )
			{
				headingVec = targetPos - newPos;
				return newPos;
			}
		}
		
		return pos;
	}
	
	private latent function SpawnPhantomWithAnim( position : Vector, rotation : EulerAngles, optional target : CActor, optional animationName : name  )
	{
		var phantom : W3CiriPhantom;
		var animComp : CAnimatedComponent;
		var res : bool;
		phantom = (W3CiriPhantom)theGame.CreateEntity( ciriPhantomTemplate, position, rotation );
		
		if ( phantom )
		{
			if ( !IsNameValid(animationName) )
				 SelectRandomAnim(animationName);
			
			phantom.Init(parent,target);
				
			AddPhantom(phantom);
			animComp = (CAnimatedComponent)phantom.GetComponentByClassName('CAnimatedComponent');
			if ( animComp )
			{
				res = animComp.PlaySlotAnimationAsync(animationName,'GAMEPLAY_SLOT');
			}
		}
		res = false;
		
	}
	
	private latent function SpawnPhantomInFrozenFrame( position : Vector, rotation : EulerAngles, anim : float )
	{
		var phantom : W3CiriPhantom;
		var animComp : CAnimatedComponent;
		var res : bool;
		phantom = (W3CiriPhantom)theGame.CreateEntity( ciriGhostFxTemplate, position, rotation );
		
		if ( phantom )
		{
			phantom.Init(parent,NULL);
				
			AddPhantom(phantom);
			animComp = (CAnimatedComponent)phantom.GetComponentByClassName('CAnimatedComponent');
			if ( animComp )
			{
				animComp.SetBehaviorVariable('anim',anim);
				animComp.SetBehaviorVariable('combatIdleStance',parent.GetBehaviorVariable('combatIdleStance',0));
				
			}
			phantom.DestroyAfter(1.5f);
		}
		res = false;
	}
	
	private function AddPhantom( phantom : W3CiriPhantom )
	{
		((W3ReplacerCiri)parent).AddPhantom(phantom);
	}
	
	private saved var attackAnimsListLP : array<name>;
	private saved var attackAnimsListRP : array<name>;
	
	private function SelectRandomAnim( out animName : name )
	{
		var anim : name;
		var index : int;
		if ( attackAnimsListLP.Size() == 0 && attackAnimsListRP.Size() == 0 )
		{
			attackAnimsListLP.PushBack('woman_ciri_sword_attack_fast_1_lp_40ms');
			attackAnimsListLP.PushBack('woman_ciri_sword_attack_fast_2_lp_40ms');
			attackAnimsListLP.PushBack('woman_ciri_sword_attack_fast_3_lp_40ms');
			attackAnimsListLP.PushBack('woman_ciri_sword_attack_fast_4_lp_40ms');
			
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_1_rp_40ms');
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_2_rp_40ms');
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_3_rp_40ms');
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_4_rp_40ms');
			attackAnimsListRP.PushBack('woman_ciri_sword_attack_fast_5_rp_40ms');
		}
		
		if ( RandRange(100,0) > 50 )
		{
			index = RandRange(attackAnimsListLP.Size());
			anim = attackAnimsListLP[index];
		}
		else
		{
			index = RandRange(attackAnimsListRP.Size());
			anim = attackAnimsListRP[index];
		}
		animName = anim;
	}
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		super.OnGameCameraPostTick( moveData, dt );
		
		if ( !parent.IsCameraLockedToTarget() && parent.GetPlayerCombatStance() == PCS_AlertNear && !parent.GetCmbtCamera() ) 
		{
			moveData.pivotRotationController.SetDesiredHeading( VecHeading(theCamera.GetCameraDirection()) );
		}
	}
}
