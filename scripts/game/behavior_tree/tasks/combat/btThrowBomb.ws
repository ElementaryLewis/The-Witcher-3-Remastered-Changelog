/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskThrowBomb extends CBTTaskAttack
{
	protected var thrownEntity 		: W3Petard;
	protected var inventory 		: CInventoryComponent;
	protected var bombs 			: array< SItemUniqueId >;
	protected var cachedTargetPos 	: Vector;
	
	public var dontUseDiwmeritium 	: bool;
	public var activationChance 	: float;
	
	
	function IsAvailable() : bool
	{
		if ( !InitializeBombs() )
			return false;
		
		if ( CheckIfFriendlyIsInAoe() )
			return false;
		
		return Roll(activationChance);
	}
	
	function InitializeBombs() : bool
	{
		var selectedBomb : SItemUniqueId;
		
		if ( !inventory )
		{
			inventory = GetActor().GetInventory();
			if ( !inventory )
				return false;
		}
			
		if ( bombs.Size() <= 0 )
		{
			bombs = inventory.GetItemsByCategory('petard');
			if ( bombs.Size() <= 0 )
				return false;
		}
		
		if ( !SelectProperBomb(selectedBomb) )
			return false;
		
		thrownEntity = (W3Petard)inventory.GetDeploymentItemEntity( selectedBomb );
		thrownEntity.Initialize( GetActor(), selectedBomb );
		
		return true;
	}
	
	function CheckIfFriendlyIsInAoe() : bool
	{
		var i 					: int;
		var radius 				: float;
		var owner 				: CActor;
		var potentialTargets 	: array<CActor>;
		
		owner = GetActor();
		radius = thrownEntity.GetImpactRange();
		
		potentialTargets = GetActorsInRange(GetCombatTarget(),radius,99,'',true);
		
		if ( potentialTargets.Contains(owner) )
			potentialTargets.Remove(owner);
		
		for ( i=0; i<potentialTargets.Size(); i+=1 )
		{
			if ( GetAttitudeBetween( owner, potentialTargets[i] ) == AIA_Friendly )
				return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var target : CNode;
		
		if ( useCombatTarget )
			target = GetCombatTarget();
		else
			target = GetActionTarget();
			
		if ( !thrownEntity )
			InitializeBombs();
		
		cachedTargetPos = target.GetWorldPosition();
		
		return super.OnActivate();
	}
	
	function SelectProperBomb(out bomb : SItemUniqueId) : bool
	{
		var i : int;
		var itemName : name;
		
		if ( !dontUseDiwmeritium )
		{
			bomb = bombs[0];
			return true;
		}
		
		for ( i = 0 ; i < bombs.Size() ; i+=1 )
		{
			itemName = inventory.GetItemName( bombs[i] );
			if ( itemName != 'Dwimeritium Bomb 1' && itemName != 'Dwimeritium Bomb 2' && itemName != 'Dwimeritium Bomb 3' )
			{
				bomb = bombs[i];
				return true;
			}
		}
		return false;
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
		
		bombs.Clear();
		
		if ( thrownEntity && !thrownEntity.WasThrown() )
			thrownEntity.Destroy();
		
		thrownEntity = NULL;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		var target : CNode;
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if ( animEventName == 'ProjectileAttach' )
		{
			thrownEntity.CreateAttachment(GetActor(),'l_weapon');
			return true;
		}
		else if ( animEventName == 'ProjectileThrow' )
		{
			if ( useCombatTarget )
				target = GetCombatTarget();
			else
				target = GetActionTarget();
			
			if ( target )
				cachedTargetPos = target.GetWorldPosition();
			
			cachedTargetPos.Z += 1;
			
			thrownEntity.ThrowProjectile(cachedTargetPos);
			((CActor)target).SignalGameplayEventParamInt('Time2DodgeBomb', (int)EDT_Bomb );
			return true;
		}
		
		return res;
	}

}

class CBTTaskThrowBombDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskThrowBomb';

	editable var dontUseDiwmeritium : bool;
	editable var activationChance : float;
	
	default dontUseDiwmeritium = true;
	default activationChance = 100;
}





class CBTTaskThrowDwimeritiumBomb extends CBTTaskThrowBomb
{
	function SelectProperBomb( out bomb : SItemUniqueId) : bool
	{
		var i : int;
		var itemName : name;
		
		for ( i = 0 ; i < bombs.Size() ; i+=1 )
		{
			itemName = inventory.GetItemName( bombs[i] );
			if ( itemName == 'Dwimeritium Bomb 1' || itemName == 'Dwimeritium Bomb 2' || itemName == 'Dwimeritium Bomb 3' )
			{
				bomb = bombs[i];
				return true;
			}
		}
		return false;
	}
}

class CBTTaskThrowDwimeritiumBombDef extends CBTTaskThrowBombDef
{
	default instanceClass = 'CBTTaskThrowDwimeritiumBomb';

	default dontUseDiwmeritium = false;
	default activationChance = 100;
	default useCombatTarget = false;
}