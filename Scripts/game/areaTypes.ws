/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EAreaName
{
	AN_Undefined,
	AN_NMLandNovigrad,
	AN_Skellige_ArdSkellig,
	AN_Kaer_Morhen,
	AN_Prologue_Village,
	AN_Wyzima,
	AN_Island_of_Myst,
	AN_Spiral,
	AN_Prologue_Village_Winter,
	AN_Velen,
	AN_CombatTestLevel,
	
}

enum EDlcAreaName
{
	
	AN_Dlc_Bob = 11, 
}

function AreaNameToType( lName : string ) : EAreaName
{
	var areaTypeInt : int;
	var areaType : EAreaName;
	switch(lName)
	{
		case "novigrad":
			return AN_NMLandNovigrad;
		case "skellige":
			return AN_Skellige_ArdSkellig;
		case "kaer_morhen":
			return AN_Kaer_Morhen;
		case "prolog_village":
			return AN_Prologue_Village;
		case "wyzima_castle":
			return AN_Wyzima;
		case "island_of_mist":
			return AN_Island_of_Myst;
		case "spiral":
			return AN_Spiral;
		case "no_mans_land":
			return AN_Velen;
		default:
		{
			areaTypeInt = theGame.GetWorldDLCExtender().AreaNameToType( lName );
			areaType = (EAreaName)areaTypeInt;
			return areaType;
		}
	}
}
	
function AreaTypeToName( type : EAreaName ) : string 
{
	switch(type)
	{
		case AN_NMLandNovigrad:
			return "novigrad";
		case AN_Skellige_ArdSkellig:
			return "skellige";
		case AN_Kaer_Morhen:
			return "kaer_morhen";
		case AN_Prologue_Village:
			return "prolog_village";
		case AN_Wyzima:
			return "wyzima_castle";
		case AN_Island_of_Myst:
			return "island_of_mist";
		case AN_Spiral:
			return "spiral";
		case AN_Velen:
			return "no_mans_land";
		default:
			return theGame.GetWorldDLCExtender().AreaTypeToName( (int)type );
	}
}