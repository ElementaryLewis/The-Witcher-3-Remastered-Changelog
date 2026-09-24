/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class C2dArray extends CResource
{	
	
	import final function GetValueAt( column : int, row : int ) : string;
	
	
	import final function GetValue( header : string, row : int ) : string;
	
	
	import final function GetValueAtAsName( column : int, row : int ) : name;
	
	
	import final function GetValueAsName( header : string, row : int ) : name;
	
	
	import final function GetNumRows() : int;
	
	
	import final function GetRowIndexAt( column : int, value : string ) : int;
	
	
	import final function GetRowIndex( header : string, value : string ) : int;
}

import class CIndexed2dArray extends C2dArray
{
	
	import final function GetRowIndexByKey( key : name ) : int;
}

import function LoadCSV( filePath : string ) : C2dArray;
