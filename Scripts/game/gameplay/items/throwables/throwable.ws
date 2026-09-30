/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class CThrowable extends CProjectileTrajectory
{
	protected var ownerHandle : EntityHandle;
	protected var wasThrown : bool;					
	protected var itemId : SItemUniqueId;
	protected var isFromAimThrow : bool;			
	
	default wasThrown = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		GotoState( 'Waiting' );
	}
	
	public final function GetOwner() : CActor
	{
		return (CActor)EntityHandleGet(ownerHandle);
	}
	
	event OnProcessThrowEvent( animEventName : name )
	{
		var ownerPlayer : CR4Player;
		var thrownEntity		: CThrowable;
		
		ownerPlayer = (CR4Player)GetOwner();
		
		
		if ( animEventName == 'ProjectileAttach' )
		{		
			if ( !CreateAttachment( GetOwner(), 'l_weapon' ) )
			{
				LogThrowable("Cannot attach thrown item to actor!" );
				LogAssert(false, "CActor.OnAnimEvent(ProjectileAttach): Cannot attach thrown item to actor!");
			}
		}
		else if ( animEventName == 'ProjectileThrow' )
		{
			
			if( !GetOwner().GetInventory().IsIdValid( itemId ) )
			{
				if( (W3Petard)this )
					thePlayer.BombThrowAbort();
					
				return true;
			}
			
			
			if(ownerPlayer)
			{
				if( (W3Petard)this )
					ownerPlayer.OnBombProjectileReleased();
							
				ownerPlayer.playerAiming.RemoveAimingSloMo();
			}
			
			LogThrowable("Thrown <<" + GetOwner().GetInventory().GetItemName(itemId) + ">>, " + GetOwner().GetInventory().GetItemQuantity(itemId) + " more left." );
		}
	}

	public function Initialize( ownr : CActor, optional id : SItemUniqueId )
	{
		var ownerPlayer : CR4Player;
	
		EntityHandleSet(ownerHandle, ownr);
		itemId = id;
		Init( GetOwner() );
		
		ownerPlayer = (CR4Player)GetOwner();
		
		
		
		
		if ( ownerPlayer && ownerPlayer.playerAiming.GetCurrentStateName() == 'Aiming' )
			GotoState( 'Aiming' );		
	}
	
	public function StartAiming()
	{
		var ownerPlayer : CR4Player;
		
		ownerPlayer = (CR4Player)GetOwner();
		ownerPlayer.playerAiming.StartAiming( this );
		GotoState( 'Aiming' );
	}
	
	public function StopAiming( flag : bool )
	{
		var ownerPlayer : CR4Player;
		
		ownerPlayer = (CR4Player)GetOwner();
		ownerPlayer.playerAiming.StopAiming();	
		OnStopAiming( flag );
	}
	
	event OnStopAiming( flag : bool ){}
	
	public function ThrowProjectile( targetPos : Vector )
	{
		BreakAttachment();
		wasThrown = true;
	}
	
	public function WasThrown() : bool 			{return wasThrown;}
	
	protected function CanCollideWithVictim( actor : CActor ) : bool
	{
		var ownerPlayer : CPlayer;
		
		if ( !actor )
			return true;
	
		if ( actor == thePlayer.GetUsedVehicle() )
			return false;

		if ( !actor.IsAlive() )
			return false;
			
		if ( actor.IsKnockedUnconscious() )
			return false;
			
		ownerPlayer = (CPlayer)GetOwner();
		if ( ownerPlayer && ownerPlayer.GetAttitude( actor ) == AIA_Friendly )
			return false;
			
		return true;
	}
}

state Waiting in CThrowable
{
}

state Aiming in CThrowable
{
	var stopAiming : bool;
	
	event OnEnterState( prevStateName : name )
	{
		stopAiming = false;
		AimThrowable();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
	}
	
	var collisionGroupsNames 	: array<name>;			
	entry function AimThrowable()
	{	
		while( !stopAiming )
		{
			Sleep( 0.0001f );
		}
		
		parent.GotoState( 'Waiting' );
	}
	
	event OnStopAiming( flag : bool )
	{
		var ownerPlayer : CR4Player;
		
		ownerPlayer = (CR4Player)(parent.GetOwner());	
	
		stopAiming = true;
		if ( !flag )
			virtual_parent.ThrowProjectile( ownerPlayer.playerAiming.GetThrowPosition() );
	}

	event OnProcessThrowEvent( animEventName : name )
	{
		var ownerPlayer : CR4Player;	
	
		if( animEventName == 'ProjectileThrow' )
		{
			if ( (W3Petard)parent )
				parent.StopAiming( false );
			else 
			{
				ownerPlayer = (CR4Player)virtual_parent.GetOwner();
				ownerPlayer.playerAiming.RemoveAimingSloMo();
				virtual_parent.ThrowProjectile( ownerPlayer.playerAiming.GetThrowPosition() );
			}	
			parent.isFromAimThrow = true;
		}
		
		parent.OnProcessThrowEvent( animEventName );
	}
}