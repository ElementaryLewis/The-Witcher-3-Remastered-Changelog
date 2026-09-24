/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TargetingManagementComponent extends CSelfUpdatingComponent
{
	
	
	
	private editable var aimVector 					: Vector;
	private editable var iconOffset 				: Vector;
	
	private editable var aimVectorSlot				: name;
	private editable var iconOffsetSlot				: name;
	
	private editable var updatePosition				: bool;
	private editable var updateDelay				: float;
	
	private var m_LastUpdate			: float;
	
	default updatePosition = true;
	
	
	event OnComponentAttached()
	{
		UpdateVectors();
		
		if( updatePosition )
		{
			StartTicking();
		}
	}
	
	
	private final function UpdateVectors()
	{
		var l_gameplayEnt 		: CGameplayEntity;
		var l_entityMatrix		: Matrix;
		var l_slotMatrix		: Matrix;
		var l_npc				: CNewNPC;
		
		l_gameplayEnt = (CGameplayEntity) GetEntity();
		
		l_entityMatrix = GetEntity().GetLocalToWorld();
		
		if( IsNameValid( aimVectorSlot ) )
		{
			GetEntity().CalcEntitySlotMatrix( aimVectorSlot, l_slotMatrix );
			aimVector = MatrixGetTranslation( l_slotMatrix );
			aimVector = VecTransform( MatrixGetInverted( l_entityMatrix ), aimVector );	
		}
		
		if( IsNameValid( iconOffsetSlot ) )
		{
			GetEntity().CalcEntitySlotMatrix( iconOffsetSlot, l_slotMatrix );
			iconOffset = MatrixGetTranslation( l_slotMatrix );
			iconOffset = VecTransform( MatrixGetInverted( l_entityMatrix ), iconOffset );	
		}
		
		if( l_gameplayEnt )
		{			
			if( aimVector != Vector( 0,0,0 ) )	l_gameplayEnt.aimVector = aimVector;
			if( iconOffset != Vector( 0,0,0 ) ) l_gameplayEnt.iconOffset = iconOffset;
		}
	}
	
	
	event OnComponentTick( _Dt : float )
	{		
		var l_distanceFromPlayer 	: float;
		var l_playerMeterPerSecond 	: float;
		
		if ( thePlayer.GetDisplayTarget() != GetEntity() )
		{
			return false;
		}
		
		if( theGame.GetEngineTimeAsSeconds() - m_LastUpdate >= updateDelay )
		{
			UpdateVectors();
			m_LastUpdate = theGame.GetEngineTimeAsSeconds();
		}
	}
	
	
}


class W3ForceAttackArea extends CEntity
{
	private editable var forceAttackEvenWithDisplayTarget : bool;
	default forceAttackEvenWithDisplayTarget = true;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
    {
		var player : CR4Player = thePlayer;
    
		if ( activator.GetEntity() == player )
		{
			if ( forceAttackEvenWithDisplayTarget )
				player.SetForceCanAttackWhenNotInCombat( 2 );
			else
				player.SetForceCanAttackWhenNotInCombat( 1 );
		}
    }
    
   	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
    {
		var player : CR4Player = thePlayer;
    
		if ( activator.GetEntity() == player )
		{
			player.SetForceCanAttackWhenNotInCombat( 0 );
		}
    } 
}