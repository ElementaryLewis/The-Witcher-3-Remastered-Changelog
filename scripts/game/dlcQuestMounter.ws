/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4QuestDLCMounter extends IGameplayDLCMounter
{
	private function LoadQuestLevels( filePath: string ) : void
	{
		theGame.LoadQuestLevels( filePath );
	}
	
	private function UnloadQuestLevels( filePath: string ) : void
	{	
		theGame.UnloadQuestLevels( filePath );
	}
}