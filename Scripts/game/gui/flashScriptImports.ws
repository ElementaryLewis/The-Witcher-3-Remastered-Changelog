/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class CHud extends CGuiObject
{
	import final function GetHudFlash() : CScriptedFlashSprite;
	import final function GetHudFlashValueStorage() : CScriptedFlashValueStorage;
	
	import final function CreateHudModule( moduleName : string, optional userData : int  );
	import final function DiscardHudModule( moduleName : string, optional userData : int  );
	import final function GetHudModule( moduleName : string ) : CHudModule;
}

import abstract class CHudModule extends CGuiObject
{
	import final function GetModuleFlash() : CScriptedFlashSprite;
	import final function GetModuleFlashValueStorage() : CScriptedFlashValueStorage;
}


import abstract class CMenu extends CGuiObject
{
	import final function GetMenuFlash() : CScriptedFlashSprite;
	import final function GetMenuFlashValueStorage() : CScriptedFlashValueStorage;
	import final function GetMenuInitData() : IScriptable;
	import final function GetMenuName() : name;
	import final function RequestSubMenu( menuName: name, optional initData : IScriptable );
	import final function CloseMenu();
}

import abstract class CPopup extends CGuiObject
{
	import final function GetPopupFlash() : CScriptedFlashSprite;
	import final function GetPopupFlashValueStorage() : CScriptedFlashValueStorage;
	import final function GetPopupInitData() : IScriptable;
	import final function GetPopupName() : name;
	import final function ClosePopup();
}

import function NameToFlashUInt( value : name ) : int;
import function ItemToFlashUInt( value : SItemUniqueId ) : int;

import abstract class CScriptedFlashObject extends IScriptedFlash
{
	import final function CreateFlashObject( optional flashClassName : string  ) : CScriptedFlashObject;
	import final function CreateFlashArray() : CScriptedFlashArray;

	import final function GetMemberFlashObject( memberName : string ) : CScriptedFlashObject;
	import final function GetMemberFlashArray( memberName : string ) : CScriptedFlashArray;
	import final function GetMemberFlashFunction( memberName : string ) : CScriptedFlashFunction;
	import final function GetMemberFlashString( memberName : string ) : string;
	import final function GetMemberFlashBool( memberName : string ) : bool;
	import final function GetMemberFlashInt( memberName : string ) : int;
	import final function GetMemberFlashUInt( memberName : string ) : int;
	import final function GetMemberFlashNumber( memberName : string ) : float;

	import final function SetMemberFlashObject( memberName : string, value : CScriptedFlashObject );
	import final function SetMemberFlashArray( memberName : string, value : CScriptedFlashArray );
	import final function SetMemberFlashFunction( memberName : string, value : CScriptedFlashFunction );
	import final function SetMemberFlashString( memberName : string, value : string );
	import final function SetMemberFlashBool( memberName : string, value : bool );
	import final function SetMemberFlashInt( memberName : string, value : int );
	import final function SetMemberFlashUInt( memberName : string, value : int );
	import final function SetMemberFlashNumber( memberName : string, value : float );
}

import abstract class CScriptedFlashSprite extends CScriptedFlashObject
{
	import final function GetChildFlashSprite( memberName : string ) : CScriptedFlashSprite;
	import final function GetChildFlashTextField( memberName : string ) : CScriptedFlashTextField;
	import final function GotoAndPlayFrameNumber( frame : int );
	import final function GotoAndPlayFrameLabel( frame : string );
	import final function GotoAndStopFrameNumber( frame : int );
	import final function GotoAndStopFrameLabel( frame : string );
	import final function GetAlpha() : float;
	import final function GetRotation() : float;
	import final function GetVisible () : bool;
	import final function GetX() : float;
	import final function GetY() : float;
	import final function GetZ() : float;
	import final function GetXRotation() : float;
	import final function GetYRotation() : float;
	import final function GetXScale() : float;
	import final function GetYScale() : float;
	import final function GetZScale() : float;
	import final function SetAlpha( alpha : float );
	import final function SetRotation( degrees: float );
	import final function SetVisible( visible: bool );
	import final function SetPosition( x : float, y : float );
	import final function SetScale( xscale : float );
	import final function SetX( x : float );
	import final function SetY( y : float );
	import final function SetZ( z : float );
	import final function SetXRotation( degrees : float );
	import final function SetYRotation( degrees : float );
	import final function SetXScale( xscale : float );
	import final function SetYScale( yscale : float );
	import final function SetZScale( zscale : float );
}

import abstract class CScriptedFlashArray extends IScriptedFlash
{
	import final function ClearElements();

	import final function GetLength() : int;
	import final function SetLength( length : int );

	import final function GetElementFlashBool( index : int ) : bool;
	import final function GetElementFlashInt( index : int ) : int;
	import final function GetElementFlashUInt( index : int ) : int;
	import final function GetElementFlashNumber( index : int ) : float;
	import final function GetElementFlashString( index : int ) : string;
	import final function GetElementFlashObject( index : int ) : CScriptedFlashObject;
	import final function PopBack();

	import final function SetElementFlashObject( index : int, value : CScriptedFlashObject );
	import final function SetElementFlashString( index : int, value : string );
	import final function SetElementFlashBool( index : int, value : bool );
	import final function SetElementFlashInt( index : int, value : int );
	import final function SetElementFlashUInt( index : int, value : int );
	import final function SetElementFlashNumber( index : int, value : float );

	import final function PushBackFlashObject( value : CScriptedFlashObject );
	import final function PushBackFlashString( value : string );
	import final function PushBackFlashBool( value : bool );
	import final function PushBackFlashInt( value : int );
	import final function PushBackFlashUInt( value : int );
	import final function PushBackFlashNumber( value : float );

	import final function RemoveElement( index : int );
	import final function RemoveElements( index : int, optional count : int  );
}

function GetObjectFromArrayWithLabel(csArray:CScriptedFlashArray, variableName:string, labelName:string, out matchingObject:CScriptedFlashObject):bool
{
	var i			: int;
	var tempObject	: CScriptedFlashObject;
	
	for (i = 0; i < csArray.GetLength(); i += 1)
	{
		tempObject = csArray.GetElementFlashObject(i);
		
		if (tempObject && tempObject.GetMemberFlashString(variableName) == labelName)
		{
			matchingObject = tempObject;
			return true;
		}
	}
	
	return false;
}

import abstract class CScriptedFlashTextField extends IScriptedFlash
{
	import final function GetText() : string;
	import final function GetTextHtml() : string;
	import final function SetText( text : string );
	import final function SetTextHtml( htmlText : string );
}

import struct SFlashArg {};
import function FlashArgBool( value : bool ) : SFlashArg;
import function FlashArgInt( value : int ) : SFlashArg;
import function FlashArgUInt( value : int ) : SFlashArg;
import function FlashArgNumber( value : float ) : SFlashArg;
import function FlashArgString( value : string ) : SFlashArg;

import abstract class CScriptedFlashFunction extends IScriptedFlash
{
	import final function InvokeSelf();
	import final function InvokeSelfOneArg		( arg0 : SFlashArg );
	import final function InvokeSelfTwoArgs		( arg0, arg1 : SFlashArg );
	import final function InvokeSelfThreeArgs	( arg0, arg1, arg2 : SFlashArg );
	import final function InvokeSelfFourArgs	( arg0, arg1, arg2, arg3 : SFlashArg );
	import final function InvokeSelfFiveArgs	( arg0, arg1, arg2, arg3, arg4 : SFlashArg );
	import final function InvokeSelfSixArgs		( arg0, arg1, arg2, arg3, arg4, arg5 : SFlashArg );
	import final function InvokeSelfSevenArgs	( arg0, arg1, arg2, arg3, arg4, arg5, arg6 : SFlashArg );
	import final function InvokeSelfEightArgs	( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7 : SFlashArg );
	import final function InvokeSelfNineArgs	( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 : SFlashArg );
}

import abstract class CScriptedFlashValueStorage extends IScriptedFlash
{
	import final function SetFlashObject( key : string, value : CScriptedFlashObject, optional index : int  );
	import final function SetFlashArray( key : string, value : CScriptedFlashArray ); 
	import final function SetFlashString( key : string, value : string, optional index : int  );
	import final function SetFlashBool( key : string, value : bool, optional index : int  );
	import final function SetFlashInt( key : string, value : int, optional index : int  );
	import final function SetFlashUInt( key : string, value : int, optional index : int  );
	import final function SetFlashNumber( key : string, value : float, optional index : int  );
	import final function CreateTempFlashObject( optional flashClassName : string  ) : CScriptedFlashObject;
	import final function CreateTempFlashArray() : CScriptedFlashArray;
}
