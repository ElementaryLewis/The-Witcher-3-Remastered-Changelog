/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function Log( text : string );


import function LogChannel( channel : name, text : string );


import function Uint64ToString( i : Uint64 ) : string;


import function Trace();


import function DebugBreak();


import latent function Sleep( time : float );

latent function SleepIgnoreTimeScale( time : float )
{
	Sleep( time * theGame.GetTimeScale() );
}


import latent function SleepOneFrame();


import latent function KillThread();


import function DumpClassHierarchy( baseClass : name ) : bool;


import function EnumGetMax( type : name ) : int;


import function EnumGetMin( type : name ) : int;


import function TabChar() : string;


import function NewlineChar() : string;


import function BackslashChar() : string;


function IsNameValid( n : name ) : bool
{
	return (n!='' && n!='None' );
}


function LogAssert( condition : bool, text : string )
{
	if ( !condition )
	{
		LogChannel('ASSERT', text );
	}
}

enum ECompareOp
{
	CO_Lesser,
	CO_LesserEq,	
	CO_Greater,
	CO_GreaterEq,
	CO_Equal,
	CO_NotEqual
}


function ProcessCompare( comparator : ECompareOp, valA : float, valB : float ) : bool
{
	switch( comparator )
	{
		case CO_Lesser:
			return valA < valB;
			
		case CO_LesserEq:
			return valA <= valB;
		
		case CO_Greater:
			return valA > valB;
		
		case CO_GreaterEq:
			return valA >= valB;
		
		case CO_Equal:
			return valA == valB;
		
		case CO_NotEqual:
			return valA != valB;		
	}
}

function LogAchievements(str : string)							{LogChannel('Achievements', str);}
function LogAlchemy(str : string)								{LogChannel('Alchemy', str);}
function LogAttackEvents(str : string)							{LogChannel('AttackEvents', str);}
function LogAttackRangesDebug(str : string)						{LogChannel('AR_Debug', str);}
function LogBgNPC(str : string)									{LogChannel('BackgroundNPCs', str);}
function LogBlockGameplayFunctionality(src, msg : string)		{LogChannel('QuestBlockGF', "<<" + src + ">> : " + msg);}
function LogCharacterStats(str : string)						{LogChannel('CharacterStats', str);}
function LogCrafting(str : string)								{LogChannel('Crafting', str);}
function LogCritical(str : string)								{LogChannel('CriticalStates', str);}
function LogCriticalPlayer(str : string)						{}	
function LogEffects(str : string)								{LogChannel('Buffs', str);}
function LogFacts(str : string)									{LogChannel('Facts', str);}
function LogGalaxy(str : string)								{LogChannel('Galaxy', str);}
function LogHaggle(str : string)								{LogChannel('Haggling', str);}
function LogInput(str : string)									{LogChannel('Input', str);}
function LogItems(str : string)									{LogChannel('Items', str);}
function LogLocalization(str : string)							{LogChannel('Localization', str);}
function LogLockable(str : string)								{LogChannel('Lockable', str);}
function LogMutation( str : string )							{ LogChannel( 'Mutations', str ); }
function LogOils(str : string)									{LogChannel('Oils', str);}
function LogPerks(str : string)									{LogChannel('Perks', str);}
function LogPotions(str : string)								{LogChannel('Potions', str);}
function LogPS4Light(str : string)								{LogChannel('PS4_Light', str);}
function LogQuest(str : string)									{LogChannel('Quest', str);}
function LogRandomLoot(str : string)							{LogChannel('RandomLoot', str);}
function LogReactionSystem(str : string)						{LogChannel('ReactionSystem', str);}
function LogSigns(str : string)									{LogChannel('Signs', str);}
function LogSkillColors(str : string)							{LogChannel('SkillColors', str);}
function LogSkills(str : string)								{LogChannel('Skills', str);}
function LogSound(str : string)									{LogChannel('Sound', str);}
function LogSpeed(str : string)									{LogChannel('Speed', str);}
function LogStamina(str : string)								{LogChannel('Stamina', str);}
function LogStates(str : string)								{LogChannel('States', str);}
function LogStats(str : string)									{LogChannel('Stats', str);}
function LogThrowable(str : string)								{LogChannel('Throwable', str);}
function LogTime(str : string)									{LogChannel('GameTime', str);}
function LogTutorial(str : string)								{LogChannel('Tutorial', str);}
function LogUnitAtt(str : string)								{}
function LogItemCollision(str : string)							{LogChannel('ItemCollision', str);}
function LogSpecialHeavy(str : string)							{LogChannel('SpecialAttackHeavy', str);}
function LogBoat(str : string)									{LogChannel('Boat', str);}
function LogCheats( str : string )								{LogChannel( 'Cheats', str );}
function LogBoatFatal( str : string )
{
	LogBoat( "" );
	LogBoat( "!!!!!!!!!!!!! FATAL !!!!!!!!!!!!!" );
	LogBoat( str );
	LogBoat( "!!!!!!!!!!!!! FATAL !!!!!!!!!!!!!" );
	LogBoat( "" );
}
function LogAutomationTest( str : string )						{LogChannel('Automation Test', str );}

function LogDMHits(str : string, optional action : W3DamageAction)
{
	if(action && action.IsDoTDamage())
		LogChannel('DamageMgrHitsDoT', str);
	else 
		LogChannel('DamageMgrHits', str);
}


function NewSkillEnumToName(skillId:ESkill) : name
{
	switch(skillId)
	{
		case S_Sword_s22 : return 'Muscle Memory';
		case S_Sword_s23 : return 'Strength Training';
		case S_Sword_s24 : return 'Precise Blow';
		case S_Sword_s25 : return 'Crushing Blow';
		case S_Sword_s26 : return 'Anatomical Knowledge';
		case S_Sword_s27 : return 'Crippling Shots';
		case S_Sword_s28 : return 'Sunder Armor';
		case S_Sword_s29 : return 'Crippling Strikes';
		case S_Sword_s30 : return 'Deadly Precision';
		case S_Sword_s31 : return 'Counter Attack';
		case S_Sword_s32 : return 'Lightning Reflexes';
		case S_Sword_s33 : return 'Arrow Deflection';
		case S_Sword_s34 : return 'Cold Blood';
		case S_Sword_s35 : return 'Whirl';
	}
}

function FormatNewCombatSkillMessageColor(skillId:ESkill, str : string, colorHex:string) : string
{
	return "<font color=\"" + colorHex + "\">" + NewSkillEnumToName(skillId) + ":</font> " + str;
}

function FormatNewCombatSkillMessage(skillId:ESkill, str : string) : string
{
	return NewSkillEnumToName(skillId) + ": " + str;
}

function LogNewCombatSkill(skillId:ESkill, str : string)
{
	if (theGame.GetPlatform() == Platform_PC)
	{
		LogChannel('NewCombatSkills', FormatNewCombatSkillMessage(skillId, str));
	}
}

function LogNewCombatSkill_InGame(skillId:ESkill, str : string)
{
	if (theGame.GetPlatform() == Platform_PC)
	{
		LogNewCombatSkill_InGameColor(skillId, str, "#b1302b");
	}
}

function LogNewCombatSkill_InGameColor(skillId:ESkill, str : string, colorHex:string)
{
	if (theGame.GetPlatform() == Platform_PC)
	{
		if(colorHex == "")
			theGame.witcherLog.AddMessage(FormatNewCombatSkillMessage(skillId, str));
		else 
			theGame.witcherLog.AddMessage(FormatNewCombatSkillMessageColor(skillId, str, colorHex));
	}
}