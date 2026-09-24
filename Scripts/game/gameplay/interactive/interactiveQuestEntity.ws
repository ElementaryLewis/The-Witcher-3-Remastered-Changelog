/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3InteractiveQuestEntity extends CInteractiveEntity
{
	default bIsEnabled = false;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( bIsEnabled )
		{
			SetInteractions( bIsEnabled );
		}
		else
		{
			SetInteractions( bIsEnabled );
		}
		
	}
	
	event OnStreamIn()
	{
		SetInteractions( bIsEnabled );
	}
	
	public function SetInteractions( enable : bool )
	{
		bIsEnabled = enable;
		UpdateInteractions();
	}
	
	function UpdateInteractions()
	{
		var components : array<CComponent>;
		var component : CInteractionComponent;
		var i : int;
		
		components = this.GetComponentsByClassName( 'CInteractionComponent' );
		
		if( components.Size() == 0 ) return;
		
		for( i=0; i < components.Size(); i += 1 )
		{
			component = (CInteractionComponent) components[i];
			
			if( component )
			{
				component.SetEnabled( bIsEnabled );
			}
			
		}
		
	}

}