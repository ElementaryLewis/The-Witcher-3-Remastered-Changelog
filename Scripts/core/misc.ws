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


import latent function SleepOneFrame();


import latent function KillThread();


import function DumpClassHierarchy( baseClass : name ) : bool;


import function EnumGetMax( type : name ) : int;


import function EnumGetMin( type : name ) : int;


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

function LogDMHits(str : string, optional action : W3DamageAction)
{
	if(action && action.IsDoTDamage())
		LogChannel('DamageMgrHitsDoT', str);
	else 
		LogChannel('DamageMgrHits', str);
}