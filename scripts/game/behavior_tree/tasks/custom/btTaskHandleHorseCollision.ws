/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskHandleHorseCollision extends BTTaskGameplayEventListener
{	
	function IsAvailable() : bool
	{
		return super.IsAvailable();
	}
	
	function OnActivate() : EBTNodeStatus
	{	
		return super.OnActivate();
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( this.isActive )
			return false;
			
		if( GetNPC().IsHorse() && GetNPC().GetCanFlee() && GetNPC().GetHorseComponent().IsDismounted() )
		{
			SetCustomTarget( GetNPC().GetWorldPosition(), 0.0 );
			SetEventRetvalInt( 1 );
			return super.OnListenedGameplayEvent( eventName );
		}
		else
		{
			SetEventRetvalInt( 0 );
			return false;
		}
	}
}

class BTTaskHandleHorseCollisionDef extends BTTaskGameplayEventListenerDef
{
	default instanceClass = 'BTTaskHandleHorseCollision';
}