/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CGameFastForwardSystem extends IGameSystem
{
	import function BeginFastForward( optional dontSpawnHostilesClose : bool , optional coverWithBlackscreen : bool  );
	import function AllowFastForwardSelfCompletion();
	import function RequestFastForwardShutdown( optional coverWithBlackscreen : bool );
	import function EndFastForward();
};