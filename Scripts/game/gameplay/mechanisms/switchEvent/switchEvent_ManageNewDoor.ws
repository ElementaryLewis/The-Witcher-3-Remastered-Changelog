/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_ManageNewDoor extends W3SwitchEvent
{
	editable var doorTag	: name;
	editable var operations	: array< ENewDoorOperation >;
	editable var force		: bool;
	
	hint doorTag	= "Tag of the door";
	hint operation	= "Operations to perform on door";
	hint force		= "Force operation even is door is locked (applicable only for openiong/closing)";
	
	public function Perform( parnt : CEntity )
	{
		var doorEntity	: W3NewDoor;
		var entities	: array<CEntity>;
		var i 			: int;
		
		theGame.GetEntitiesByTag( doorTag, entities );
		
		if ( entities.Size() == 0 )
		{
			LogAssert(false, "No entity found with tag <" + doorTag + ">" );
			return;
		}
		
		for ( i = 0; i < entities.Size(); i += 1 )
		{
			doorEntity = (W3NewDoor)entities[ i ];
			if ( !doorEntity )
			{
				LogAssert(false, "Entity with tag <" + doorTag + "> is not a W3NewDoor" );
				return;
			}
			doorEntity.OnManageNewDoor( operations, force );
		}
	}
}