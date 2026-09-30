/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeHLTaskWander extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		GetActor().ActivateAndSyncBehavior('Exploration');
		
		return BTNS_Active;
	}
};


class CBehTreeHLTaskWanderDef extends IBehTreeHLTaskDefinition
{
	default instanceClass = 'CBehTreeHLTaskWander';
}