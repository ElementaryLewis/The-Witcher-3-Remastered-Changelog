/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CPhantomComponent extends CComponent
{
	
	import final function Activate();
	
	import final function Deactivate();
	
	import final function GetTriggeringCollisionGroupNames( out names : array< name > );
	
	import final function GetNumObjectsInside(): int;
}