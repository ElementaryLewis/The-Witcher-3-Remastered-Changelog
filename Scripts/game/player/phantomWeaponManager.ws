/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CPhantomWeaponManager
{
	
	private var hitsToCharge : int;
	private var timeToDischarge : float;
	private var minVitalityPercToCharge : float;
	private var vitalityPercLostOnDischarge : float;
	
	
	private var hitCounter : int;
	private var isWeaponCharged : bool;
	private var itemId : SItemUniqueId;
	private var inv : CInventoryComponent;
	
	
	private var chargedLoopedFxName : name;
	private var chargedSingleFxName : name;
	
	default hitsToCharge = 3;
	default timeToDischarge = 5.0;
	default minVitalityPercToCharge = 15.0;
	default vitalityPercLostOnDischarge = 15.0;
	
	default chargedLoopedFxName = 'special_attack_charged';
	default chargedSingleFxName = 'special_attack_ready';
	
	
	public function Init( inventory : CInventoryComponent )
	{
		var itemIds : array< SItemUniqueId >;
		
		inv = inventory;
		itemIds = inv.GetItemsByTag( 'PhantomWeapon' );
		
		if( itemIds.Size() )
		{
			itemId = itemIds[0];
		}
	}
	
	
	public function IncrementHitCounter()
	{
		if( HasEnoughVitality() )
		{
			if( !IsWeaponCharged() )
			{
				hitCounter += 1;
				
				if( ShouldChargeWeapon() )
				{
					ChargeWeapon();
				}
			}
			
			thePlayer.AddTimer( 'DischargeWeaponAfter', timeToDischarge,,,,, true );
		}
	}
	
	
	private function ResetHitCounter()
	{
		hitCounter = 0;
	}
	
	
	private function ShouldChargeWeapon() : bool
	{
		if( hitCounter >= hitsToCharge )
		{
			return true;
		}

		return false;
	}
	
	
	private function ChargeWeapon()
	{
		SetIsWeaponCharged( true );
		inv.PlayItemEffect( itemId, chargedLoopedFxName );
		inv.PlayItemEffect( itemId, chargedSingleFxName );

		thePlayer.AddTimer( 'DischargeWeaponAfter', timeToDischarge,,,,, true );
		thePlayer.AddAbility( 'ForceDismemberment' );
	}
	
	
	public function DischargeWeapon( optional afterHit : bool )
	{
		SetIsWeaponCharged( false );
		ResetHitCounter();
		inv.StopItemEffect( itemId, chargedLoopedFxName );
		if( afterHit )
		{
			inv.PlayItemEffect( itemId, chargedSingleFxName );
			DrainVitality();
		}
		
		thePlayer.RemoveAbility( 'ForceDismemberment' );
	}
	
	
	private function HasEnoughVitality() : bool
	{
		if( thePlayer.GetStatPercents( BCS_Vitality ) * 100 > minVitalityPercToCharge )
			return true;
		else
			return false;
	}
	
	
	private function DrainVitality()
	{
		var vitalityCost : float;
		
		vitalityCost = thePlayer.GetStatMax( BCS_Vitality ) * vitalityPercLostOnDischarge * 0.01;
		
		if( thePlayer.GetStat( BCS_Vitality ) > vitalityCost )
		{
			thePlayer.DrainVitality( vitalityCost );
		}
		else
		{
			vitalityCost = thePlayer.GetStat( BCS_Vitality ) - 1.0;
			thePlayer.DrainVitality( vitalityCost );
		}
	}
	
	
	private function SetIsWeaponCharged( val : bool )
	{
		isWeaponCharged = val;
	}
	
	
	public function IsWeaponCharged() : bool
	{
		return isWeaponCharged;
	}
}