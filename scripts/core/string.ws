/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function StrLen( str : string ) : int;


import function StrCmp( str, with : string, optional length : int, optional noCase : bool ) : int;


import function StrFindFirst( str, match : string ) : int;


import function StrFindLast( str, match : string ) : int;


import function StrSplitFirst( str, divider : string, out left, right : string ) : bool;


import function StrSplitLast( str, divider : string, out left, right : string ) : bool;


import function StrReplace( str, match, with : string ) : string;


import function StrReplaceAll( str, match, with : string ) : string;


import function StrMid( str : string, first : int, optional length : int ) : string;


import function StrLeft( str : string, length : int ) : string;


import function StrRight( str : string, length : int ) : string;


import function StrBeforeFirst( str, match : string ) : string;


import function StrBeforeLast( str, match : string ) : string;


import function StrAfterFirst( str, match : string ) : string;


import function StrAfterLast( str, match : string ) : string;


import function StrBeginsWith( str, match  : string ) : bool;


import function StrEndsWith( str, match  : string ) : bool;


import function StrUpper( str  : string ) : string;


import function StrLower( str  : string ) : string;


import function StrChar( i : int ) : string;


import function NameToString( n : name ) : string;


import function FloatToString( value : float ) : string;


import function FloatToStringPrec( value : float, precision : int ) : string;


import function IntToString( value : int ) : string;


import function StringToInt( value : string, optional defValue : int) : int;


import function StringToFloat( value : string, optional defValue : float ) : float;


import function VectorToString( value : Vector ) : string;


import function EulerAnglesToString( value : EulerAngles ) : string;


import function StringToVector( value : string, optional defValue : Vector) : Vector;


import function StringToEulerAngles( value : string, optional defValue : EulerAngles) : EulerAngles;


import function StrUpperUTF( str : string ) : string;


import function StrLowerUTF( str : string ) : string;


function NameToInt(n : name) : int
{
	return StringToInt(NameToString(n));
}


function NameToFloat(n : name) : float
{
	return StringToFloat(NameToString(n));
}


function NoTrailZeros(f : float) : string
{
	var tmp : string;
	
	tmp = FloatToString(f);	
	if(StrFindFirst(tmp, ",") >= 0 || StrFindFirst(tmp, ".") >= 0)
		while(StrEndsWith(tmp, "0"))
			tmp = StrLeft(tmp, StrLen(tmp)-1);
	if(StrEndsWith(tmp, ",") || StrEndsWith(tmp, "."))
		tmp = StrLeft(tmp, StrLen(tmp)-1);
	
	return tmp;
}


function GetRandomName() : name
{
	switch(RandRange(20))
	{
		case 0 : return '0';
		case 1 : return '1';
		case 2 : return '2';
		case 3 : return '3';
		case 4 : return '4';
		case 5 : return '5';
		case 6 : return '6';
		case 7 : return '7';
		case 8 : return '8';
		case 9 : return '9';
		case 10 : return '10';
		case 11 : return '11';
		case 12 : return '12';
		case 13 : return '13';
		case 14 : return '14';
		case 15 : return '15';
		case 16 : return '16';
		case 17 : return '17';
		case 18 : return '18';
		case 19 : return '19';
		default : return '20';
	}
}

enum ESpaceFillMode
{
	ESFM_JustifyLeft,
	ESFM_JustifyRight
}



function SpaceFill(str : string, length : int, optional mode : ESpaceFillMode) : string
{
	var strLen, i : int;
	
	strLen = StrLen(str);
	if(strLen >= length)
		return str;
		
	if(mode == ESFM_JustifyLeft)
	{
		for(i=0; i<length - strLen; i+=1)
		{
			str += " ";
		}
	}
	else if(mode == ESFM_JustifyRight)
	{
		for(i=0; i<length - strLen; i+=1)
		{
			str = " " + str;
		}
	}
	
	return str;
}

function StrStartsWith(str : string, subStr : string) : bool
{
	return StrFindFirst(str, subStr) == 0;
}

function StrContains(str : string, subStr : string) : bool
{
	return StrFindFirst(str, subStr) >= 0;
}

function StrSplit(str : string, subStr : string) : array<string>
{
	var strLeft : string;
	var result : array<string>;

	strLeft = str;

	while (StrContains(strLeft, subStr))
	{
		result.PushBack(StrBeforeFirst(strLeft, subStr));
		strLeft = StrAfterFirst(strLeft, subStr);
	}

	result.PushBack(strLeft);
	return result;
}