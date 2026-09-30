/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CAnimal extends CNewNPC
{
	editable var animalType : EAnimalType;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		super.OnSpawned( spawnData );
		
		if( animalType == EAT_Peacock )
		{
			AddAnimEventCallback( 'SetNoTailAppearance', 'OnAnimEvent_SetNoTailAppearance' );
			AddAnimEventCallback( 'SetTailAppearance', 'OnAnimEvent_SetTailAppearance' );
		}
		else if( animalType == EAT_Pheasant )
		{
			
			
			
			SetBehaviorVariable( 'canJumpInRun', 1.0 );
		}
	}
	
	event OnAnimEvent_SetNoTailAppearance( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animalType == EAT_Peacock )
		{
			SetAppearance( 'peacock_01' );
		}
		
		return true;
	}
	
	event OnAnimEvent_SetTailAppearance( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animalType == EAT_Peacock )
		{
			SetAppearance( 'peacock_01_opened_tail' );
		}
		
		return true;
	}
	
	
	
	
}

enum EAnimalType
{
	EAT_NotSet,
	EAT_Peacock,
	EAT_Pheasant
}