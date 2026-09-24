/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskFindActorsByTag extends IBehTreeTask
{
	var tag					: name;
	var actorsArray			: array<CActor>;
	var operator 			: EOperator;
	var numberOfActors		: int;
	var range     			: float;
	var oppNo 				: int;
	var onlyLiveActors		: bool;
	var npc					: CNewNPC;
	
	default range = 20.f;
	default onlyLiveActors = false;
	
	hint numberOfActors = "number of Actors the function should compare to";
	hint onlyLiveActors = "should only alive Actors be taken into consideration?";
	


	function IsAvailable() : bool
	{
		var i	: int;
		
		npc = GetNPC();
		
		if( tag == '' || !npc )
		return false;
			
			actorsArray = GetActorsInRange( npc, range, , tag, onlyLiveActors );
			
			oppNo = actorsArray.Size();
			
			
		switch ( operator )
		{
			case EO_Equal:			return oppNo == numberOfActors;
			case EO_NotEqual:		return oppNo != numberOfActors;
			case EO_Less:			return oppNo < 	numberOfActors;
			case EO_LessEqual:		return oppNo <= numberOfActors;
			case EO_Greater:		return oppNo > 	numberOfActors;
			case EO_GreaterEqual:	return oppNo >= numberOfActors;
			default : 				return false;
		}
		
	}
}

class CBTTaskFindActorsByTagDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTTaskFindActorsByTag';
	
	editable 	var tag					: name;
				var foundActorsArray 	: array<CActor>;
	editable 	var operator 			: EOperator;
	editable	var numberOfActors		: int;
	editable	var range     			: float;
	editable 	var onlyLiveActors		: bool;
				var oppNo 				: int;
				var npc					: CNewNPC;
};