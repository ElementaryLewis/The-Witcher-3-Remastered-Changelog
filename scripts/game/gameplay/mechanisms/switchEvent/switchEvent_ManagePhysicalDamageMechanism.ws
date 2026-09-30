/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_ManagePchysicalDamageMechanism extends W3SwitchEvent
{
	editable var mechanismHandle : array<EntityHandle>;
	editable var mechanismTag	: name;
	editable var operations	: array< EPhysicalDamagemechanismOperation >;
	
	hint mechanismHandle = "Array of mechanisms selected on the level";
	hint trapTag	= "Tag of the mechanism";
	hint operations	= "Operations to perform on all above traps";
	
	public function PerformArgNode( parnt : CEntity, node : CNode )
	{
		var mechanismEntity	: W3PhysicalDamageMechanism;
		var entities				: array<CEntity>;
		var i 						: int;
		var activator 				: CActor;
		var notAMechanismEntity 	: CEntity;
		var notAMechanismEntityName : string;
		
		activator  = ( CActor )node;
		
		
		if (mechanismHandle.Size() > 0)
		{
			for( i = 0; i < mechanismHandle.Size(); i += 1 )
			{
				mechanismEntity = (W3PhysicalDamageMechanism) EntityHandleGet( mechanismHandle[i] );
				if ( !mechanismEntity )
				{
					notAMechanismEntity = EntityHandleGet( mechanismHandle[i] );
					if (notAMechanismEntity)
					{
						notAMechanismEntityName = notAMechanismEntity.GetName();
						LogAssert( false, "Handled entity array" + notAMechanismEntityName + " contains an entity which is not a W3Trap" );
					}
					else
					{
						LogAssert( false, "Handled entity array links to an item which can't be found. Deleted?" );
					}
				}
				else
				{
					mechanismEntity.OnManageMechanism( operations );
				}
			}
		}
		
		
		if (mechanismTag)
		{
			theGame.GetEntitiesByTag( mechanismTag, entities );
			
			if ( entities.Size() == 0 )
			{
				LogAssert( false, "No entities found with tag <" + mechanismTag + ">" );
				return;
			}
			for ( i = 0; i < entities.Size(); i += 1 )
			{
				mechanismEntity = (W3PhysicalDamageMechanism)entities[ i ]; 
				if ( !mechanismEntity )
				{
					LogAssert( false, "Entity with tag <" + mechanismTag + "> is not a W3PhysicalDamageMechanism" );
				}
				else
				{
					mechanismEntity.OnManageMechanism( operations );
				}
			}
		}
	}
}