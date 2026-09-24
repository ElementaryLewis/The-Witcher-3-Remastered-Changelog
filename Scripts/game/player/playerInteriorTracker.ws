/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CActionLockerByCounter
{
	private saved	var lockingNum	: int;					default	lockingNum	= 0;
	private			var action 		: EInputActionBlock;
	private			var lockName	: name;
	
	
	
	public function Init( blockingAction : EInputActionBlock, blockingName : name )
	{
		action		= blockingAction;
		lockName	= blockingName;
	}
	
	
	public function Reset()
	{
		lockingNum	= 0;
		if(thePlayer)
			thePlayer.UnblockAction( action, lockName );
	}
	
	
	public function Lock( lock : bool )
	{
		if( lock )
		{
			if( lockingNum == 0 )
			{
				thePlayer.BlockAction( action, lockName, false, false, true );
			}
			lockingNum	= Max( lockingNum + 1, 1 );
		}
		else
		{
			if( lockingNum == 1 )
			{
				thePlayer.UnblockAction( action, lockName );
			}
			lockingNum	= Max( lockingNum - 1, 0 );
		}
	}
}



class CPlayerInteriorTracker
{	
	private saved var sprintLocker	: CActionLockerByCounter;
	private saved var runLocker		: CActionLockerByCounter;
	
	private var currentInterior : CNode;
	
	
	public function Init( restored : bool )
	{
		if( !sprintLocker )
		{
			sprintLocker	= new CActionLockerByCounter in this;
		}
		if( !runLocker )
		{
			runLocker	= new CActionLockerByCounter in this;
		}
		sprintLocker.Init( EIAB_Sprint, 'InteriorBlocker' );
		runLocker.Init( EIAB_RunAndSprint, 'InteriorBlocker' );
		
		if( !restored )
		{
			sprintLocker.Reset();
			runLocker.Reset();
		}
	}
	
	
	public function LockSprint( lock : bool )
	{
		sprintLocker.Lock( lock );
	}
	
	
	public function LockRun( lock : bool )
	{
		runLocker.Lock( lock );
	}
	
	
	public function SetCurrentInterior( _interior : CNode )
	{
		currentInterior = _interior;
	}
	
	
	public function GetCurrentInterior() : CNode
	{
		return currentInterior;
	}
}