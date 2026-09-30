/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SItem
{
	editable var itemName : name;
	editable var quantity : int;
		default quantity = 1;
};

enum EQuestSword
{
	EQS_Any,
	EQS_Steel,
	EQS_Silver
}

struct SGlossaryImageOverride
{
	var uniqueTag : name;
	var imageFileName : string;
}