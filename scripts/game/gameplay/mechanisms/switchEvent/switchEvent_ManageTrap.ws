/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_ManageTrap extends W3SwitchEvent
{
	editable var trapHandle : array<EntityHandle>;
	editable var trapTag	: name;
	editable var operations	: array< ETrapOperation >;
	
	hint trapHandle = "Array of traps selected on the level";
	hint trapTag	= "Tag of the traps";
	hint operations	= "Operations to perform on all above traps";
	
	public function PerformArgNode( parnt : CEntity, node : CNode )
	{
		var trapEntity	: W3Trap;
		var entities	: array<CEntity>;
		var i 			: int;
		var activator 	: CActor;
		var notATrapEntity : CEntity;
		var notATrapEntityName : string;
		
		activator  = ( CActor )node;
		
		
		if (trapHandle.Size() > 0)
		{
			for( i = 0; i < trapHandle.Size(); i += 1 )
			{
				trapEntity = (W3Trap) EntityHandleGet( trapHandle[i] );
				if ( !trapEntity )
				{
					notATrapEntity = EntityHandleGet( trapHandle[i] );
					if (notATrapEntity)
					{
						notATrapEntityName = notATrapEntity.GetName();
						LogAssert( false, "Handled entity array" + notATrapEntityName + " contains an entity which is not a W3Trap" );
					}
					else
					{
						LogAssert( false, "Handled entity array links to an item which can't be found. Deleted?" );
					}
				}
				else
				{
					trapEntity.OnManageTrap( operations, activator );
				}
			}
		}
		
		
		if (trapTag)
		{
			theGame.GetEntitiesByTag( trapTag, entities );
			
			if ( entities.Size() == 0 )
			{
				LogAssert( false, "No entities found with tag <" + trapTag + ">" );
				return;
			}
			for ( i = 0; i < entities.Size(); i += 1 )
			{
				trapEntity = (W3Trap)entities[ i ]; 
				if ( !trapEntity )
				{
					LogAssert( false, "Entity with tag <" + trapTag + "> is not a W3Trap" );
				}
				else
				{
					trapEntity.OnManageTrap( operations, activator );
				}
			}
		}
	}
}