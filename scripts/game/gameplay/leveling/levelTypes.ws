/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ESpendablePointType
{
	ESkillPoint,
	EExperiencePoint
}

struct SSpendablePoints
{
	saved var free	: int;
	saved var used	: int;
};

struct SLevelDefinition
{
	var number : int;
	var requiredTotalExp : int;
	var addedSkillPoints : int;
	var requiredExp : int;
};