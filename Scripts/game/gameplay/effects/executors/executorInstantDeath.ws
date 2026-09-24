/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Executor_InstantDeath extends IInstantEffectExecutor
{
	default executorName = 'InstantDeath';

	public function Execute( executor : CGameplayEntity, target : CActor, optional source : string ) : bool
	{
		if(target)
		{
			target.Kill( 'Combat Focus Mode', executor);
			return true;
		}
		return false;
	}	
}