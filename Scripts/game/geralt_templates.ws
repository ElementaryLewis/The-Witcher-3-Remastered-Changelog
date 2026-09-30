/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
exec function fb2(level : int, optional path : name)
{	
	var iID : array<SItemUniqueId>;
	var lm : W3PlayerWitcher;
	var exp, prevLvl, currLvl : int;
	
	GetWitcherPlayer().Debug_ClearCharacterDevelopment();
	
	
	lm = GetWitcherPlayer();
	prevLvl = lm.GetLevel();
	currLvl = lm.GetLevel();
		
	while(currLvl < level)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false); 
		
		currLvl = lm.GetLevel();
		
		if(prevLvl == currLvl)
			break;				
		
		prevLvl = currLvl;
	}		
	
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen steel sword', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen silver sword', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen Pants', 1); GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen Gloves', 1); GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen Boots', 1); GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Autogen Armor', 1); GetWitcherPlayer().EquipItem(iID[0]);
	
}

exec function GetExpPoints(points : int)
{
	GetWitcherPlayer().AddPoints(EExperiencePoint, points, true );
}

exec function fb3 (optional level :int, optional path : name, optional clearInv : bool)
{
	fb3_internal( level, path, clearInv );
}

function fb3_internal(optional level :int, optional path : name, optional clearInv : bool)
{	
	var iID : array<SItemUniqueId>;
	var lm : W3PlayerWitcher;
	var exp, prevLvl, currLvl : int;
	
	GetWitcherPlayer().Debug_ClearCharacterDevelopment(true);

	if(clearInv)
	{
		GetWitcherPlayer().GetInventory().RemoveAllItems();
	}	
	
	if(!level)
	{
		level = 30;
	}	
	lm = GetWitcherPlayer();
	prevLvl = lm.GetLevel();
	currLvl = lm.GetLevel();
		
	while(currLvl < level)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false); 
		
		currLvl = lm.GetLevel();
		
		if(prevLvl == currLvl)
			break;				
		
		prevLvl = currLvl;
	}		
	iID.Clear();
	iID = lm.inv.AddAnItem('Autogen steel sword', 1); 	lm.EquipItem(iID[0]);
	iID = lm.inv.AddAnItem('Autogen silver sword', 1);	lm.EquipItem(iID[0]);
	iID = lm.inv.AddAnItem('Autogen Pants', 1); 		lm.EquipItem(iID[0]);
	iID = lm.inv.AddAnItem('Autogen Gloves', 1); 		lm.EquipItem(iID[0]);
	iID = lm.inv.AddAnItem('Autogen Boots', 1); 		lm.EquipItem(iID[0]);
	iID = lm.inv.AddAnItem('Autogen Armor', 1); 		lm.EquipItem(iID[0]);
	
	switch ( path )
	{
		default:		Ep1_sword(); break;
		case '':		Ep1_sword(); break;
		case 'sword': 	Ep1_sword(); break;
		case 'swords': 	Ep1_sword(); break;
		case 'sign': 	Ep1_signs(); break;
		case 'signs': 	Ep1_signs(); break;
		case 'alchemy': Ep1_alchemy(); break;
		case 'bombs': 	Ep1_alchemy(); break;
		case 'bomb': 	Ep1_alchemy(); break;
	}
	
	
	lm.inv.AddAnItem('Greater mutagen red', 14);
	lm.inv.AddAnItem('Greater mutagen green', 11);
	lm.inv.AddAnItem('Greater mutagen blue', 11);
	lm.AddPoints(ESkillPoint, 60, true);
}

function Ep1_sword()
{
	var lm 		: W3PlayerWitcher;
	var iID 	: array<SItemUniqueId>;
	var q, i 	: int;
	
	q = 22;	
	lm = GetWitcherPlayer();
	lm.AddPoints(ESkillPoint, 250, true);

	lm.AddMultipleSkills(S_Sword_s01 ,5 );
	lm.AddMultipleSkills(S_Sword_s02 ,5 );
	lm.AddMultipleSkills(S_Sword_s03 ,5 );
	lm.AddMultipleSkills(S_Sword_s04 ,5 );
	lm.AddMultipleSkills(S_Sword_s05 ,5 );
	lm.AddMultipleSkills(S_Sword_s06 ,5 );
	lm.AddMultipleSkills(S_Sword_s07 ,5 );
	lm.AddMultipleSkills(S_Sword_s08 ,5 );
	lm.AddMultipleSkills(S_Sword_s09 ,5 );
	lm.AddMultipleSkills(S_Sword_s10,5 );
	lm.AddMultipleSkills(S_Sword_s11,5 );
	lm.AddMultipleSkills(S_Sword_s12,5 );
	lm.AddMultipleSkills(S_Sword_s13,5 );
	lm.AddMultipleSkills(S_Sword_s15,5 );
	lm.AddMultipleSkills(S_Sword_s16,5 );
	lm.AddMultipleSkills(S_Sword_s17,5 );
	lm.AddMultipleSkills(S_Sword_s18,5 );
	lm.AddMultipleSkills(S_Sword_s19,5 );
	lm.AddMultipleSkills(S_Sword_s20,5 );
	lm.AddMultipleSkills(S_Sword_s21,5 );
	
	lm.AddMultipleSkills(S_Magic_s01 ,5 );
	lm.AddMultipleSkills(S_Magic_s02 ,5 );
	lm.AddMultipleSkills(S_Magic_s03 ,5 );
	lm.AddMultipleSkills(S_Magic_s04 ,5 );
	lm.AddMultipleSkills(S_Magic_s05 ,5 );
	lm.AddMultipleSkills(S_Magic_s06 ,5 );
	lm.AddMultipleSkills(S_Magic_s07 ,5 );
	lm.AddMultipleSkills(S_Magic_s08 ,5 );
	lm.AddMultipleSkills(S_Magic_s09 ,5 );
	lm.AddMultipleSkills(S_Magic_s10,5 );
	lm.AddMultipleSkills(S_Magic_s11,5 );
	lm.AddMultipleSkills(S_Magic_s12,5 );
	lm.AddMultipleSkills(S_Magic_s13,5 );
	lm.AddMultipleSkills(S_Magic_s14,5 );
	lm.AddMultipleSkills(S_Magic_s15,5 );
	lm.AddMultipleSkills(S_Magic_s16,5 );
	lm.AddMultipleSkills(S_Magic_s17,5 );
	lm.AddMultipleSkills(S_Magic_s18,5 );
	lm.AddMultipleSkills(S_Magic_s19,5 );
	lm.AddMultipleSkills(S_Magic_s20,5 );
	
	lm.AddMultipleSkills(S_Alchemy_s01,5 );
	lm.AddMultipleSkills(S_Alchemy_s02 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s03 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s04 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s05 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s06 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s07 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s08 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s09 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s10,5 );
	lm.AddMultipleSkills(S_Alchemy_s11,5 );
	lm.AddMultipleSkills(S_Alchemy_s12,5 );
	lm.AddMultipleSkills(S_Alchemy_s13,5 );
	lm.AddMultipleSkills(S_Alchemy_s14,5 );
	lm.AddMultipleSkills(S_Alchemy_s15,5 );
	lm.AddMultipleSkills(S_Alchemy_s16,5 );
	lm.AddMultipleSkills(S_Alchemy_s17,5 );
	lm.AddMultipleSkills(S_Alchemy_s18,5 );
	lm.AddMultipleSkills(S_Alchemy_s19,5 );
	lm.AddMultipleSkills(S_Alchemy_s20,5 );
	
	lm.AddSkill(S_Perk_01);
	lm.AddSkill(S_Perk_02);
	lm.AddSkill(S_Perk_03);
	lm.AddSkill(S_Perk_04);
	lm.AddSkill(S_Perk_05);
	lm.AddSkill(S_Perk_06);
	lm.AddSkill(S_Perk_07);
	lm.AddSkill(S_Perk_08);
	lm.AddSkill(S_Perk_09);
	lm.AddSkill(S_Perk_10);
	lm.AddSkill(S_Perk_11);
	lm.AddSkill(S_Perk_12);
	lm.AddSkill(S_Perk_13);
	lm.AddSkill(S_Perk_14);
	lm.AddSkill(S_Perk_15);
	lm.AddSkill(S_Perk_16);
	lm.AddSkill(S_Perk_17);
	lm.AddSkill(S_Perk_18);
	lm.AddSkill(S_Perk_19);
	lm.AddSkill(S_Perk_20);
	lm.AddSkill(S_Perk_21);
	lm.AddSkill(S_Perk_22);

	lm.EquipSkill(S_Sword_s08, 3);	
	lm.EquipSkill(S_Sword_s21, 1);
	lm.EquipSkill(S_Sword_s04, 4);
	lm.EquipSkill(S_Sword_s17, 2);
	lm.EquipSkill(S_Perk_09, 5);
	lm.EquipSkill(S_Sword_s11, 6);
	lm.EquipSkill(S_Sword_s20, 7);
	lm.EquipSkill(S_Sword_s18, 8);
	lm.EquipSkill(S_Sword_s05, 9);
	lm.EquipSkill(S_Sword_s06, 10);
	lm.EquipSkill(S_Sword_s03, 11);
	lm.EquipSkill(S_Sword_s16, 12);
	
	
	lm.inv.AddAnItem('White Honey 3', 1);
	lm.inv.AddAnItem('Blizzard 3', 1);
	lm.inv.AddAnItem('White Raffards Decoction 3', 1);
	lm.inv.AddAnItem('Full Moon 3', 1);
	lm.inv.AddAnItem('Golden Oriole 3', 1);
	lm.inv.AddAnItem('Petri Philtre 3', 1);
	iID = lm.inv.AddAnItem('Tawny Owl 3', 1);
	thePlayer.EquipItem(iID[0], EES_Potion2);
	lm.inv.AddAnItem('Cat 3', 1);
	iID = lm.inv.AddAnItem('Swallow 3', 1);
	thePlayer.EquipItem(iID[0], EES_Potion1);
	lm.inv.AddAnItem('Black Blood 3', 1);
	lm.inv.AddAnItem('Maribor Forest 3', 1);
	lm.inv.AddAnItem('Ogre Oil 3', 1);
	lm.inv.AddAnItem('Cursed Oil 3', 1);
	lm.inv.AddAnItem('Beast Oil 3', 1);
	lm.inv.AddAnItem('Insectoid Oil 3', 1);
	lm.inv.AddAnItem('Draconide Oil 3', 1);
	lm.inv.AddAnItem('Vampire Oil 3', 1);
	lm.inv.AddAnItem('Specter Oil 3', 1);
	lm.inv.AddAnItem('Hybrid Oil 3', 1);
	lm.inv.AddAnItem('Relic Oil 3', 1);
	lm.inv.AddAnItem('Magicals Oil 3', 1);
	lm.inv.AddAnItem('Necrophage Oil 3', 1);
	lm.inv.AddAnItem('Hanged Man Venom 3', 1);
	
	
	lm.inv.AddAnItem('Dwimeritium Bomb 3', 1);
	iID = lm.inv.AddAnItem('White Frost 3', 1);
	thePlayer.EquipItem(iID[0], EES_Petard2);
	lm.inv.AddAnItem('Samum 3', 1);
	lm.inv.GetItemsIds('Samum 3');
	iID = lm.inv.AddAnItem('Grapeshot 3', 1);
	thePlayer.EquipItem(iID[0], EES_Petard1);
	lm.SelectQuickslotItem(EES_Petard1);
	lm.inv.AddAnItem('Devils Puffball 3', 1);
	lm.inv.AddAnItem('Dancing Star 3', 1);
	lm.inv.AddAnItem('Dragons Dream 3', 1);
	lm.inv.AddAnItem('Silver Dust Bomb 3', 1);
	
	for(i=0;i<=3;i+=1)
	{
		iID = lm.inv.AddAnItem('Greater mutagen red');
		lm.EquipItem(iID[0], q);
		q+=1;
	}

}

function Ep1_signs()
{
	var lm 		: W3PlayerWitcher;
	var iID 	: array<SItemUniqueId>;
	var i, q 	: int;
	
	q = 22;
	lm = GetWitcherPlayer();
	GetWitcherPlayer().AddPoints(ESkillPoint, 250, true);
	
	lm.AddMultipleSkills(S_Sword_s01 ,5 );
	lm.AddMultipleSkills(S_Sword_s02 ,5 );
	lm.AddMultipleSkills(S_Sword_s03 ,5 );
	lm.AddMultipleSkills(S_Sword_s04 ,5 );
	lm.AddMultipleSkills(S_Sword_s05 ,5 );
	lm.AddMultipleSkills(S_Sword_s06 ,5 );
	lm.AddMultipleSkills(S_Sword_s07 ,5 );
	lm.AddMultipleSkills(S_Sword_s08 ,5 );
	lm.AddMultipleSkills(S_Sword_s09 ,5 );
	lm.AddMultipleSkills(S_Sword_s10,5 );
	lm.AddMultipleSkills(S_Sword_s11,5 );
	lm.AddMultipleSkills(S_Sword_s12,5 );
	lm.AddMultipleSkills(S_Sword_s13,5 );
	lm.AddMultipleSkills(S_Sword_s15,5 );
	lm.AddMultipleSkills(S_Sword_s16,5 );
	lm.AddMultipleSkills(S_Sword_s17,5 );
	lm.AddMultipleSkills(S_Sword_s18,5 );
	lm.AddMultipleSkills(S_Sword_s19,5 );
	lm.AddMultipleSkills(S_Sword_s20,5 );
	lm.AddMultipleSkills(S_Sword_s21,5 );
	
	lm.AddMultipleSkills(S_Magic_s01 ,5 );
	lm.AddMultipleSkills(S_Magic_s02 ,5 );
	lm.AddMultipleSkills(S_Magic_s03 ,5 );
	lm.AddMultipleSkills(S_Magic_s04 ,5 );
	lm.AddMultipleSkills(S_Magic_s05 ,5 );
	lm.AddMultipleSkills(S_Magic_s06 ,5 );
	lm.AddMultipleSkills(S_Magic_s07 ,5 );
	lm.AddMultipleSkills(S_Magic_s08 ,5 );
	lm.AddMultipleSkills(S_Magic_s09 ,5 );
	lm.AddMultipleSkills(S_Magic_s10,5 );
	lm.AddMultipleSkills(S_Magic_s11,5 );
	lm.AddMultipleSkills(S_Magic_s12,5 );
	lm.AddMultipleSkills(S_Magic_s13,5 );
	lm.AddMultipleSkills(S_Magic_s14,5 );
	lm.AddMultipleSkills(S_Magic_s15,5 );
	lm.AddMultipleSkills(S_Magic_s16,5 );
	lm.AddMultipleSkills(S_Magic_s17,5 );
	lm.AddMultipleSkills(S_Magic_s18,5 );
	lm.AddMultipleSkills(S_Magic_s19,5 );
	lm.AddMultipleSkills(S_Magic_s20,5 );
	
	lm.AddMultipleSkills(S_Alchemy_s01,5 );
	lm.AddMultipleSkills(S_Alchemy_s02 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s03 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s04 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s05 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s06 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s07 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s08 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s09 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s10,5 );
	lm.AddMultipleSkills(S_Alchemy_s11,5 );
	lm.AddMultipleSkills(S_Alchemy_s12,5 );
	lm.AddMultipleSkills(S_Alchemy_s13,5 );
	lm.AddMultipleSkills(S_Alchemy_s14,5 );
	lm.AddMultipleSkills(S_Alchemy_s15,5 );
	lm.AddMultipleSkills(S_Alchemy_s16,5 );
	lm.AddMultipleSkills(S_Alchemy_s17,5 );
	lm.AddMultipleSkills(S_Alchemy_s18,5 );
	lm.AddMultipleSkills(S_Alchemy_s19,5 );
	lm.AddMultipleSkills(S_Alchemy_s20,5 );
	
	lm.AddSkill(S_Perk_01);
	lm.AddSkill(S_Perk_02);
	lm.AddSkill(S_Perk_03);
	lm.AddSkill(S_Perk_04);
	lm.AddSkill(S_Perk_05);
	lm.AddSkill(S_Perk_06);
	lm.AddSkill(S_Perk_07);
	lm.AddSkill(S_Perk_08);
	lm.AddSkill(S_Perk_09);
	lm.AddSkill(S_Perk_10);
	lm.AddSkill(S_Perk_11);
	lm.AddSkill(S_Perk_12);
	lm.AddSkill(S_Perk_13);
	lm.AddSkill(S_Perk_14);
	lm.AddSkill(S_Perk_15);
	lm.AddSkill(S_Perk_16);
	lm.AddSkill(S_Perk_17);
	lm.AddSkill(S_Perk_18);
	lm.AddSkill(S_Perk_19);
	lm.AddSkill(S_Perk_20);
	lm.AddSkill(S_Perk_21);
	lm.AddSkill(S_Perk_22);
	
	lm.EquipSkill(S_Magic_s08, 1);
	lm.EquipSkill(S_Magic_s10, 2);
	lm.EquipSkill(S_Magic_s02, 3);
	lm.EquipSkill(S_Magic_s03, 4);
	lm.EquipSkill(S_Magic_s05, 5);
	lm.EquipSkill(S_Magic_s09, 6);
	lm.EquipSkill(S_Magic_s07, 7);
	lm.EquipSkill(S_Magic_s07, 8);
	lm.EquipSkill(S_Magic_s16, 9);
	lm.EquipSkill(S_Magic_s15, 10);
	lm.EquipSkill(S_Magic_s18, 11);
	lm.EquipSkill(S_Magic_s06, 12);
	
	
	lm.inv.AddAnItem('White Honey 3', 1);
	lm.inv.AddAnItem('Blizzard 3', 1);
	lm.inv.AddAnItem('White Raffards Decoction 3', 1);
	lm.inv.AddAnItem('Full Moon 3', 1);
	lm.inv.AddAnItem('Golden Oriole 3', 1);
	lm.inv.AddAnItem('Petri Philtre 3', 1);
	iID = lm.inv.AddAnItem('Tawny Owl 3', 1);
	thePlayer.EquipItem(iID[0], EES_Potion2);
	lm.inv.AddAnItem('Cat 3', 1);
	iID = lm.inv.AddAnItem('Swallow 3', 1);
	thePlayer.EquipItem(iID[0], EES_Potion1);
	lm.inv.AddAnItem('Black Blood 3', 1);
	lm.inv.AddAnItem('Maribor Forest 3', 1);
	lm.inv.AddAnItem('Ogre Oil 3', 1);
	lm.inv.AddAnItem('Cursed Oil 3', 1);
	lm.inv.AddAnItem('Beast Oil 3', 1);
	lm.inv.AddAnItem('Insectoid Oil 3', 1);
	lm.inv.AddAnItem('Draconide Oil 3', 1);
	lm.inv.AddAnItem('Vampire Oil 3', 1);
	lm.inv.AddAnItem('Specter Oil 3', 1);
	lm.inv.AddAnItem('Hybrid Oil 3', 1);
	lm.inv.AddAnItem('Relic Oil 3', 1);
	lm.inv.AddAnItem('Magicals Oil 3', 1);
	lm.inv.AddAnItem('Necrophage Oil 3', 1);
	lm.inv.AddAnItem('Hanged Man Venom 3', 1);
	
	
	lm.inv.AddAnItem('Dwimeritium Bomb 3', 1);
	iID = lm.inv.AddAnItem('White Frost 3', 1);
	thePlayer.EquipItem(iID[0], EES_Petard2);
	lm.inv.AddAnItem('Samum 3', 1);
	lm.inv.GetItemsIds('Samum 3');
	iID = lm.inv.AddAnItem('Grapeshot 3', 1);
	thePlayer.EquipItem(iID[0], EES_Petard1);
	lm.SelectQuickslotItem(EES_Petard1);
	lm.inv.AddAnItem('Devils Puffball 3', 1);
	lm.inv.AddAnItem('Dancing Star 3', 1);
	lm.inv.AddAnItem('Dragons Dream 3', 1);
	lm.inv.AddAnItem('Silver Dust Bomb 3', 1);
	
	for(i=0;i<=3;i+=1)
	{
		iID = lm.inv.AddAnItem('Greater mutagen blue');
		lm.EquipItem(iID[0], q);
		q+=1;
	}
	
}

function Ep1_alchemy()
{
	var lm 		: W3PlayerWitcher;
	var iID 	: array<SItemUniqueId>;
	var i, q 	: int;
	
	q = 22;
	lm = GetWitcherPlayer();
	lm.AddPoints(ESkillPoint, 100, true);

	lm.AddMultipleSkills(S_Sword_s01 ,5 );
	lm.AddMultipleSkills(S_Sword_s02 ,5 );
	lm.AddMultipleSkills(S_Sword_s03 ,5 );
	lm.AddMultipleSkills(S_Sword_s04 ,5 );
	lm.AddMultipleSkills(S_Sword_s05 ,5 );
	lm.AddMultipleSkills(S_Sword_s06 ,5 );
	lm.AddMultipleSkills(S_Sword_s07 ,5 );
	lm.AddMultipleSkills(S_Sword_s08 ,5 );
	lm.AddMultipleSkills(S_Sword_s09 ,5 );
	lm.AddMultipleSkills(S_Sword_s10,5 );
	lm.AddMultipleSkills(S_Sword_s11,5 );
	lm.AddMultipleSkills(S_Sword_s12,5 );
	lm.AddMultipleSkills(S_Sword_s13,5 );
	lm.AddMultipleSkills(S_Sword_s15,5 );
	lm.AddMultipleSkills(S_Sword_s16,5 );
	lm.AddMultipleSkills(S_Sword_s17,5 );
	lm.AddMultipleSkills(S_Sword_s18,5 );
	lm.AddMultipleSkills(S_Sword_s19,5 );
	lm.AddMultipleSkills(S_Sword_s20,5 );
	lm.AddMultipleSkills(S_Sword_s21,5 );
	
	lm.AddMultipleSkills(S_Magic_s01 ,5 );
	lm.AddMultipleSkills(S_Magic_s02 ,5 );
	lm.AddMultipleSkills(S_Magic_s03 ,5 );
	lm.AddMultipleSkills(S_Magic_s04 ,5 );
	lm.AddMultipleSkills(S_Magic_s05 ,5 );
	lm.AddMultipleSkills(S_Magic_s06 ,5 );
	lm.AddMultipleSkills(S_Magic_s07 ,5 );
	lm.AddMultipleSkills(S_Magic_s08 ,5 );
	lm.AddMultipleSkills(S_Magic_s09 ,5 );
	lm.AddMultipleSkills(S_Magic_s10,5 );
	lm.AddMultipleSkills(S_Magic_s11,5 );
	lm.AddMultipleSkills(S_Magic_s12,5 );
	lm.AddMultipleSkills(S_Magic_s13,5 );
	lm.AddMultipleSkills(S_Magic_s14,5 );
	lm.AddMultipleSkills(S_Magic_s15,5 );
	lm.AddMultipleSkills(S_Magic_s16,5 );
	lm.AddMultipleSkills(S_Magic_s17,5 );
	lm.AddMultipleSkills(S_Magic_s18,5 );
	lm.AddMultipleSkills(S_Magic_s19,5 );
	lm.AddMultipleSkills(S_Magic_s20,5 );
	
	lm.AddMultipleSkills(S_Alchemy_s01,5 );
	lm.AddMultipleSkills(S_Alchemy_s02 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s03 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s04 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s05 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s06 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s07 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s08 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s09 ,5 );
	lm.AddMultipleSkills(S_Alchemy_s10,5 );
	lm.AddMultipleSkills(S_Alchemy_s11,5 );
	lm.AddMultipleSkills(S_Alchemy_s12,5 );
	lm.AddMultipleSkills(S_Alchemy_s13,5 );
	lm.AddMultipleSkills(S_Alchemy_s14,5 );
	lm.AddMultipleSkills(S_Alchemy_s15,5 );
	lm.AddMultipleSkills(S_Alchemy_s16,5 );
	lm.AddMultipleSkills(S_Alchemy_s17,5 );
	lm.AddMultipleSkills(S_Alchemy_s18,5 );
	lm.AddMultipleSkills(S_Alchemy_s19,5 );
	lm.AddMultipleSkills(S_Alchemy_s20,5 );
	
	lm.AddSkill(S_Perk_01);
	lm.AddSkill(S_Perk_02);
	lm.AddSkill(S_Perk_03);
	lm.AddSkill(S_Perk_04);
	lm.AddSkill(S_Perk_05);
	lm.AddSkill(S_Perk_06);
	lm.AddSkill(S_Perk_07);
	lm.AddSkill(S_Perk_08);
	lm.AddSkill(S_Perk_09);
	lm.AddSkill(S_Perk_10);
	lm.AddSkill(S_Perk_11);
	lm.AddSkill(S_Perk_12);
	lm.AddSkill(S_Perk_13);
	lm.AddSkill(S_Perk_14);
	lm.AddSkill(S_Perk_15);
	lm.AddSkill(S_Perk_16);
	lm.AddSkill(S_Perk_17);
	lm.AddSkill(S_Perk_18);
	lm.AddSkill(S_Perk_19);
	lm.AddSkill(S_Perk_20);
	lm.AddSkill(S_Perk_21);
	lm.AddSkill(S_Perk_22);
	
	lm.EquipSkill(S_Alchemy_s12, 1);
	lm.EquipSkill(S_Alchemy_s02, 2);
	lm.EquipSkill(S_Alchemy_s14, 3);
	lm.EquipSkill(S_Alchemy_s07, 4);
	lm.EquipSkill(S_Alchemy_s08, 5);
	lm.EquipSkill(S_Alchemy_s09, 6);
	lm.EquipSkill(S_Alchemy_s10, 7);
	lm.EquipSkill(S_Alchemy_s11, 8);
	lm.EquipSkill(S_Alchemy_s01, 9);
	lm.EquipSkill(S_Alchemy_s02, 10);
	
		
	lm.inv.AddAnItem('White Honey 3', 1);
	lm.inv.AddAnItem('Blizzard 3', 1);
	lm.inv.AddAnItem('White Raffards Decoction 3', 1);
	lm.inv.AddAnItem('Full Moon 3', 1);
	lm.inv.AddAnItem('Golden Oriole 3', 1);
	lm.inv.AddAnItem('Petri Philtre 3', 1);
	iID = lm.inv.AddAnItem('Tawny Owl 3', 1);
	thePlayer.EquipItem(iID[0], EES_Potion2);
	lm.inv.AddAnItem('Cat 3', 1);
	iID = lm.inv.AddAnItem('Swallow 3', 1);
	thePlayer.EquipItem(iID[0], EES_Potion1);
	lm.inv.AddAnItem('Black Blood 3', 1);
	lm.inv.AddAnItem('Maribor Forest 3', 1);
	lm.inv.AddAnItem('Ogre Oil 3', 1);
	lm.inv.AddAnItem('Cursed Oil 3', 1);
	lm.inv.AddAnItem('Beast Oil 3', 1);
	lm.inv.AddAnItem('Insectoid Oil 3', 1);
	lm.inv.AddAnItem('Draconide Oil 3', 1);
	lm.inv.AddAnItem('Vampire Oil 3', 1);
	lm.inv.AddAnItem('Specter Oil 3', 1);
	lm.inv.AddAnItem('Hybrid Oil 3', 1);
	lm.inv.AddAnItem('Relic Oil 3', 1);
	lm.inv.AddAnItem('Magicals Oil 3', 1);
	lm.inv.AddAnItem('Necrophage Oil 3', 1);
	lm.inv.AddAnItem('Hanged Man Venom 3', 1);
	
	
	
	lm.inv.AddAnItem('Dwimeritium Bomb 3', 1);
	iID = lm.inv.AddAnItem('White Frost 3', 1);
	thePlayer.EquipItem(iID[0], EES_Petard2);
	lm.inv.AddAnItem('Samum 3', 1);
	lm.inv.GetItemsIds('Samum 3');
	iID = lm.inv.AddAnItem('Grapeshot 3', 1);
	thePlayer.EquipItem(iID[0], EES_Petard1);
	lm.SelectQuickslotItem(EES_Petard1);
	lm.inv.AddAnItem('Devils Puffball 3', 1);
	lm.inv.AddAnItem('Dancing Star 3', 1);
	lm.inv.AddAnItem('Dragons Dream 3', 1);
	lm.inv.AddAnItem('Silver Dust Bomb 3', 1);
	
	for(i=0;i<=3;i+=1)
	{
		iID = lm.inv.AddAnItem('Greater mutagen green');
		lm.EquipItem(iID[0], q);
		q+=1;
	}

}
