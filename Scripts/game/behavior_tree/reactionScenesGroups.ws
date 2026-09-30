/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function GlobalRegisterReactionSceneGroups()
{

	var reactionManager : CBehTreeReactionManager;	
	reactionManager = theGame.GetBehTreeReactionManager();
	
	GlobalRegisterReactionSceneGroups_Novigrad( reactionManager );
	GlobalRegisterReactionSceneGroups_Nml( reactionManager );
	GlobalRegisterReactionSceneGroups_Skellige( reactionManager );
	GlobalRegisterReactionSceneGroups_Prologue( reactionManager );
	GlobalRegisterReactionSceneGroups_Bob( reactionManager );
}

function GlobalRegisterReactionSceneGroups_Prologue( reactionManager : CBehTreeReactionManager )
{
	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_imperial_01", 'nilfgaardImperial' );	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_imperial_02", 'nilfgaardImperial' );	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_imperial_03", 'nilfgaardImperial' );	
	
	
	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_prologue_01", 'solider' );	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_prologue_02", 'solider' );	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_prologue_03", 'solider' );	
	
	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_nobleman_01", 'nilfgaardNobleman' );	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_nobleman_02", 'nilfgaardNobleman' );	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_nobleman_03", 'nilfgaardNobleman' );	
	
	
	
	reactionManager.AddReactionSceneGroup( "vset_temerian_bandit_01", 'nilfgaardBandit' );	
	reactionManager.AddReactionSceneGroup( "vset_temerian_bandit_02", 'nilfgaardBandit' );	
	reactionManager.AddReactionSceneGroup( "vset_temerian_bandit_03", 'nilfgaardBandit' );	
	
	
	
	reactionManager.AddReactionSceneGroup( "vset_temerian_peasant_01", 'nilfgaardPeasant' );	
	reactionManager.AddReactionSceneGroup( "vset_temerian_peasant_02", 'nilfgaardPeasant' );	
	reactionManager.AddReactionSceneGroup( "vset_temerian_peasant_03", 'nilfgaardPeasant' );		

	reactionManager.AddReactionSceneGroup( "vset_temerian_woman_01", 'nilfgaardPeasant' );	
	reactionManager.AddReactionSceneGroup( "vset_temerian_woman_02", 'nilfgaardPeasant' );	
	reactionManager.AddReactionSceneGroup( "vset_temerian_woman_03", 'nilfgaardPeasant' );	
	
	reactionManager.AddReactionSceneGroup( "vset_temerian_merchant_01", 'nilfgaardPeasant' );		
}


function GlobalRegisterReactionSceneGroups_Skellige( reactionManager : CBehTreeReactionManager )
{
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_armorer_01", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_armorer_02", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_armorer_03", 'skelligeCitizen' );	

	reactionManager.AddReactionSceneGroup( "vset_skellige_blacksmith_helper_01", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_blacksmith_helper_02", 'skelligeCitizen' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_blacksmith_helper_03", 'skelligeCitizen' );
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_boatbuilder_01", 'skelligeCitizen' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_boatbuilder_02", 'skelligeCitizen' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_boatbuilder_03", 'skelligeCitizen' );
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_butcher_01", 'skelligeCitizen' );	
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_bard_01", 'skelligeCitizen' );	

	reactionManager.AddReactionSceneGroup( "vset_skellige_fisherman_01", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_fisherman_02", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_fisherman_03", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_fisherman_04", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_fisherman_05", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_fisherman_06", 'skelligeCitizen' );	
		
	reactionManager.AddReactionSceneGroup( "vset_skellige_hunter_01", 'skelligeCitizen' );		
	reactionManager.AddReactionSceneGroup( "vset_skellige_hunter_02", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_hunter_03", 'skelligeCitizen' );	

	reactionManager.AddReactionSceneGroup( "vset_skellige_innkeeper_01", 'skelligeCitizen' );	
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_old_man_01", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_old_man_02", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_old_man_03", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_old_man_04", 'skelligeCitizen' );		

	reactionManager.AddReactionSceneGroup( "vset_skellige_old_woman_01", 'skelligeCitizen' );		
	reactionManager.AddReactionSceneGroup( "vset_skellige_old_woman_02", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_old_woman_03", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_old_woman_04", 'skelligeCitizen' );	
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_scribe_01", 'skelligeCitizen' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_scribe_02", 'skelligeCitizen' );
		

	reactionManager.AddReactionSceneGroup( "vset_skellige_villager_01", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_villager_02", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_villager_03", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_villager_04", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_villager_05", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_villager_06", 'skelligeCitizen' );	
		
	reactionManager.AddReactionSceneGroup( "vset_skellige_waitress_01", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_waitress_02", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_waitress_03", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_waitress_04", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_waitress_05", 'skelligeCitizen' );	
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_woman_01", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_woman_02", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_woman_03", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_woman_04", 'skelligeCitizen' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_woman_05", 'skelligeCitizen' );	
	

	
	reactionManager.AddReactionSceneGroup( "vset_skellige_guard_01", 'skelligeGuard' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_guard_02", 'skelligeGuard' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_guard_03", 'skelligeGuard' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_guard_04", 'skelligeGuard' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_guard_05", 'skelligeGuard' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_guard_06", 'skelligeGuard' );
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_warrior_01", 'skelligeGuard' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_warrior_02", 'skelligeGuard' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_warrior_03", 'skelligeGuard' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_warrior_04", 'skelligeGuard' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_warrior_05", 'skelligeGuard' );


	
	reactionManager.AddReactionSceneGroup( "vset_skellige_druid_01", 'druid' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_druid_02", 'druid' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_druid_03", 'druid' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_druid_04", 'druid' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_druid_05", 'druid' );		
		

	
	reactionManager.AddReactionSceneGroup( "vset_skellige_boy_01", 'skelligeChild' );		
	reactionManager.AddReactionSceneGroup( "vset_skellige_boy_02", 'skelligeChild' );		
	reactionManager.AddReactionSceneGroup( "vset_skellige_boy_03", 'skelligeChild' );		

	reactionManager.AddReactionSceneGroup( "vset_skellige_girl_01", 'skelligeChild' );		
	reactionManager.AddReactionSceneGroup( "vset_skellige_girl_02", 'skelligeChild' );		
	reactionManager.AddReactionSceneGroup( "vset_skellige_girl_03", 'skelligeChild' );		
	

	
	reactionManager.AddReactionSceneGroup( "vset_skellige_bandit_01", 'skelligeBandit' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_bandit_02", 'skelligeBandit' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_bandit_03", 'skelligeBandit' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_bandit_04", 'skelligeBandit' );
		
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_berserker_01", 'skelligeBerserker' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_berserker_02", 'skelligeBerserker' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_berserker_03", 'skelligeBerserker' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_berserker_04", 'skelligeBerserker' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_berserker_05", 'skelligeBerserker' );
	
	
	reactionManager.AddReactionSceneGroup( "vset_skellige_merchant_01", '_acceptAll' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_merchant_02", '_acceptAll' );
	reactionManager.AddReactionSceneGroup( "vset_skellige_merchant_03", '_acceptAll' );	

	
	reactionManager.AddReactionSceneGroup( "vset_skellige_priestess_01", 'skelligePriestess' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_priestess_02", 'skelligePriestess' );	
	reactionManager.AddReactionSceneGroup( "vset_skellige_priestess_03", 'skelligePriestess' );	
}

function GlobalRegisterReactionSceneGroups_Nml( reactionManager : CBehTreeReactionManager )
{	
	
	reactionManager.AddReactionSceneGroup( "vset_baron_bandit_strong_01", 'baronBandit' );
	reactionManager.AddReactionSceneGroup( "vset_baron_bandit_strong_02", 'baronBandit' );
	reactionManager.AddReactionSceneGroup( "vset_baron_bandit_strong_03", 'baronBandit' );
	
	reactionManager.AddReactionSceneGroup( "vset_baron_bandit_weak_01", 'baronBandit' );
	reactionManager.AddReactionSceneGroup( "vset_baron_bandit_weak_02", 'baronBandit' );
	reactionManager.AddReactionSceneGroup( "vset_baron_bandit_weak_03", 'baronBandit' );
		

	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_officer_01", 'officer' );
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_officer_02", 'officer' );
	
	
	
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_soldier_01", 'solider' );
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_soldier_02", 'solider' );
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_soldier_03", 'solider' );
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_soldier_04", 'solider' );
	reactionManager.AddReactionSceneGroup( "vset_nilfgaardian_soldier_05", 'solider' );
	
	
	
	reactionManager.AddReactionSceneGroup( "vset_temerian_guerillas_01", 'guerillas' );
	reactionManager.AddReactionSceneGroup( "vset_temerian_guerillas_02", 'guerillas' );
	reactionManager.AddReactionSceneGroup( "vset_temerian_guerillas_03", 'guerillas' );
	reactionManager.AddReactionSceneGroup( "vset_temerian_guerillas_04", 'guerillas' );
	reactionManager.AddReactionSceneGroup( "vset_temerian_guerillas_05", 'guerillas' );
	

	
	reactionManager.AddReactionSceneGroup( "vset_verden_old_man_01", 'verden' );
	reactionManager.AddReactionSceneGroup( "vset_verden_old_man_02", 'verden' );
	reactionManager.AddReactionSceneGroup( "vset_verden_old_man_03", 'verden' );
	
	reactionManager.AddReactionSceneGroup( "vset_verden_old_woman_01", 'verden' );
	reactionManager.AddReactionSceneGroup( "vset_verden_old_woman_02", 'verden' );
	reactionManager.AddReactionSceneGroup( "vset_verden_old_woman_03", 'verden' );
	
	reactionManager.AddReactionSceneGroup( "vset_verden_peasant_01", 'verden' );	
	reactionManager.AddReactionSceneGroup( "vset_verden_peasant_02", 'verden' );	
	reactionManager.AddReactionSceneGroup( "vset_verden_peasant_03", 'verden' );	
	reactionManager.AddReactionSceneGroup( "vset_verden_peasant_04", 'verden' );	
	reactionManager.AddReactionSceneGroup( "vset_verden_peasant_05", 'verden' );	

	reactionManager.AddReactionSceneGroup( "vset_verden_smith_01", 'verden' );	
	
	reactionManager.AddReactionSceneGroup( "vset_verden_woman_01", 'verden' );
	reactionManager.AddReactionSceneGroup( "vset_verden_woman_02", 'verden' );
	reactionManager.AddReactionSceneGroup( "vset_verden_woman_03", 'verden' );
	reactionManager.AddReactionSceneGroup( "vset_verden_woman_04", 'verden' );
	reactionManager.AddReactionSceneGroup( "vset_verden_woman_05", 'verden' );
	
	reactionManager.AddReactionSceneGroup( "vset_verden_vendor_01", '_acceptAll' );
	reactionManager.AddReactionSceneGroup( "vset_verden_vendor_02", '_acceptAll' );
	reactionManager.AddReactionSceneGroup( "vset_verden_vendor_03", '_acceptAll' );
	

	
	reactionManager.AddReactionSceneGroup( "vset_verden_boy_01", 'verdenChild' );
	reactionManager.AddReactionSceneGroup( "vset_verden_boy_01", 'verdenChild' );
	reactionManager.AddReactionSceneGroup( "vset_verden_boy_01", 'verdenChild' );
	
	reactionManager.AddReactionSceneGroup( "vset_verden_girl_01", 'verdenChild' );
	reactionManager.AddReactionSceneGroup( "vset_verden_girl_02", 'verdenChild' );
	reactionManager.AddReactionSceneGroup( "vset_verden_girl_03", 'verdenChild' );

	
	
	reactionManager.AddReactionSceneGroup( "vset_verden_scavenger_01", 'verdenScavenger' );
	reactionManager.AddReactionSceneGroup( "vset_verden_scavenger_02", 'verdenScavenger' );
	reactionManager.AddReactionSceneGroup( "vset_verden_scavenger_03", 'verdenScavenger' );
	
	reactionManager.AddReactionSceneGroup( "vset_scavenger_woman_01", 'verdenScavenger' );
	reactionManager.AddReactionSceneGroup( "vset_scavenger_woman_02", 'verdenScavenger' );	

	
	
	
}
	
function GlobalRegisterReactionSceneGroups_Novigrad( reactionManager : CBehTreeReactionManager )
{	
	
	reactionManager.AddReactionSceneGroup( "vset_dwarf_man_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_dwarf_man_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_dwarf_man_03", 'poor' );	
	
	reactionManager.AddReactionSceneGroup( "vset_elf_female_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_elf_female_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_elf_female_03", 'poor' );
	
	reactionManager.AddReactionSceneGroup( "vset_elf_man_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_elf_man_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_elf_man_03", 'poor' );
	
	reactionManager.AddReactionSceneGroup( "vset_halfling_man_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_halfling_man_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_halfling_man_03", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_halfling_man_04", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_halfling_man_05", 'poor' );

	reactionManager.AddReactionSceneGroup( "vset_novigrad_bard_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_bard_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_bard_03", 'poor' );

	reactionManager.AddReactionSceneGroup( "vset_novigrad_dockworker_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_dockworker_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_dockworker_03", 'poor' );

	reactionManager.AddReactionSceneGroup( "vset_novigrad_female_bard_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_female_bard_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_female_bard_03", 'poor' );
		
	reactionManager.AddReactionSceneGroup( "vset_novigrad_old_man_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_old_man_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_old_man_03", 'poor' );

	reactionManager.AddReactionSceneGroup( "vset_novigrad_old_woman_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_old_woman_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_old_woman_03", 'poor' );

	reactionManager.AddReactionSceneGroup( "vset_novigrad_poor_man_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_poor_man_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_poor_man_03", 'poor' );
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_poor_woman_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_poor_woman_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_poor_woman_03", 'poor' );
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_prostitute_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_prostitute_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_prostitute_03", 'poor' );
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_refugee_man_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_refugee_man_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_refugee_man_03", 'poor' );	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_refugee_man_04", 'poor' );

	reactionManager.AddReactionSceneGroup( "vset_novigrad_refugee_woman_01", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_refugee_woman_02", 'poor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_refugee_woman_03", 'poor' );

	
	
	reactionManager.AddReactionSceneGroup( "vset_eternal_fire_guard_01", 'guard' );
	reactionManager.AddReactionSceneGroup( "vset_eternal_fire_guard_02", 'guard' );
	reactionManager.AddReactionSceneGroup( "vset_eternal_fire_guard_03", 'guard' );

	
	
	reactionManager.AddReactionSceneGroup( "vset_mage_01", 'mage' );
	reactionManager.AddReactionSceneGroup( "vset_mage_02", 'mage' );
	reactionManager.AddReactionSceneGroup( "vset_mage_03", 'mage' );

	
	
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_citizen_man_01", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_citizen_man_02", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_citizen_man_03", 'nobleman' );
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_citizen_woman_01", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_citizen_woman_02", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_citizen_woman_03", 'nobleman' );
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_nobleman_01", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_nobleman_02", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_nobleman_03", 'nobleman' );
		
	reactionManager.AddReactionSceneGroup( "vset_novigrad_noblewoman_01", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_noblewoman_02", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_noblewoman_03", 'nobleman' );

	reactionManager.AddReactionSceneGroup( "vset_eternal_fire_priest_01", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_eternal_fire_priest_02", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_eternal_fire_priest_03", 'nobleman' );
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_rich_man_01", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_rich_man_02", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_rich_man_03", 'nobleman' );
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_rich_woman_01", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_rich_woman_02", 'nobleman' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_rich_woman_03", 'nobleman' );	

	reactionManager.AddReactionSceneGroup( "vset_novigrad_trader_01", '_acceptAll' );	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_trader_02", '_acceptAll' );	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_trader_03", '_acceptAll' );	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_trader_04", '_acceptAll' );	

	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_thug_strong_01", 'bandit' );		
	reactionManager.AddReactionSceneGroup( "vset_novigrad_thug_strong_02", 'bandit' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_thug_strong_03", 'bandit' );

	reactionManager.AddReactionSceneGroup( "vset_novigrad_thug_weak_01", 'bandit' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_thug_weak_02", 'bandit' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_thug_weak_03", 'bandit' );
	

	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_boy_01", 'child' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_boy_02", 'child' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_boy_03", 'child' );
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_girl_01", 'child' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_girl_02", 'child' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_girl_03", 'child' );
		

	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_peasant_01", 'peasant' );	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_peasant_02", 'peasant' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_peasant_03", 'peasant' );
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_peasant_woman_01", 'peasant' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_peasant_woman_02", 'peasant' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_peasant_woman_03", 'peasant' );
	

	
	reactionManager.AddReactionSceneGroup( "vset_scoiatael_dwarf_01", 'scoiateal' );
	
	reactionManager.AddReactionSceneGroup( "vset_scoiatael_elf_man_01", 'scoiateal' );
	reactionManager.AddReactionSceneGroup( "vset_scoiatael_elf_man_02", 'scoiateal' );
		
	reactionManager.AddReactionSceneGroup( "vset_scoiatael_elf_woman_01", 'scoiateal' );		
	
	
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_beggar_01", 'beggar' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_beggar_02", 'beggar' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_beggar_03", 'beggar' );

	
	
	reactionManager.AddReactionSceneGroup( "vset_novigrad_sailor_01", 'sailor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_sailor_02", 'sailor' );
	reactionManager.AddReactionSceneGroup( "vset_novigrad_sailor_03", 'sailor' );
}

function GlobalRegisterReactionSceneGroups_Bob( reactionManager : CBehTreeReactionManager )
{
	
	reactionManager.AddReactionSceneGroup( "vset_beauclair_citizen_man_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_beauclair_citizen_man_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_beauclair_citizen_man_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_beauclair_citizen_woman_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_beauclair_citizen_woman_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_beauclair_citizen_woman_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_man_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_man_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_man_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_man_04", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_man_05", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_man_06", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_woman_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_woman_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_woman_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_woman_04", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_woman_05", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bard_woman_06", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bonvivant_man_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bonvivant_man_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bonvivant_man_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bonvivant_man_04", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bonvivant_woman_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bonvivant_woman_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bonvivant_woman_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_bonvivant_woman_04", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_dockworker_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_dockworker_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_dockworker_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_man_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_man_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_man_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_man_04", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_man_05", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_woman_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_woman_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_woman_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_woman_04", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_old_woman_05", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_man_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_man_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_man_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_man_04", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_man_05", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_woman_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_woman_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_woman_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_woman_04", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_peasant_woman_05", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_poor_man_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_poor_man_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_poor_man_03", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_poor_woman_01", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_poor_woman_02", 'bob' );
	reactionManager.AddReactionSceneGroup( "vset_toussaint_poor_woman_03", 'bob' );
}