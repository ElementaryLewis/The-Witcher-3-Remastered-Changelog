/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SSoundInfoMapping
{
	import var soundTypeIdentification 	: name;
	import var soundSizeIdentification 	: name;
	import var boneIndexes 				: array< int >;
	import var isDefault				: bool;
}

import class CR4HumanoidCombatComponent extends CComponent
{
	import final function UpdateSoundInfo(  ) 																	: void;
	
	import final function GetSoundTypeIdentificationForBone( boneIndex : int  ) 								: name;
	
	import final function GetBoneClosestToEdge( a : Vector, b : Vector, optional preciseSearch : bool ) 		: int;
	
	import final function GetDefaultSoundInfoMapping( ) 														: SSoundInfoMapping;
}
