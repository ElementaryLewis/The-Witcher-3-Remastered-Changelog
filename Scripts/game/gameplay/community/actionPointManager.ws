/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SActionPointId {};

import class CActionPointManager extends CObject
{
	
	import final function HasPreferredNextAPs( currApID : SActionPointId ) : bool;

	
	import final function GetSeqNextActionPoint( currApID : SActionPointId ) : SActionPointId;

	
	import final function GetJobTree( apID : SActionPointId ) : CJobTree;

	
	import final function ResetItems( apID : SActionPointId );
	
	
	import final function GetGoToPosition( apID : SActionPointId, out placePos : Vector, out placeRot : float ) : bool;

	
	import final function GetActionExecutionPosition( apID : SActionPointId, out placePos : Vector, out placeRot : float ) : bool;
	
	
	import final function GetFriendlyAPName( apID : SActionPointId ) : string;
	
	
	import final function IsBreakable( apID : SActionPointId ) : bool;
	
	
	import final function GetPlacementImportance( apID : SActionPointId ) : EWorkPlacementImportance;
	
	
	import final function IsFireSourceDependent( apID : SActionPointId ) : bool;
}


import function ClearAPID( out apID : SActionPointId );


import function IsAPValid( apID : SActionPointId ) : bool;