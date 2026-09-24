/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeCombatStyleManager extends IBehTreeTask
{
	protected var combatDataStorage : CHumanAICombatStorage;
	
	public var preferedCombatStyle : EBehaviorGraph;
	
	private var isRanged : bool;
	private var rangedWeaponType : name;
	
	default isRanged = false;
	
	function Evaluate() : int
	{
		InitializeCombatDataStorage();
		if ( combatDataStorage.GetIsAttacking() )
		{
			return 70;
		}
			
		return 50;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
	
		InitializeCombatDataStorage();
		
		if ( npc.HasTag('NoMapPin') && GetCombatTarget() == thePlayer )
			npc.RemoveTag('NoMapPin');
	
		if ( npc.GetPreferedCombatStyle() != EBG_None )
		{
			combatDataStorage.SetPreferedCombatStyle( npc.GetPreferedCombatStyle() );
		}
		else
		{
			combatDataStorage.SetPreferedCombatStyle( preferedCombatStyle );
		}
	
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CActor;
		var target : CActor;
		var freq : float = 0.1;
		var sqrDist : float;
		
		owner = GetActor();
		
		if ( combatDataStorage.GetPreferedCombatStyle() == EBG_Combat_Bow )
		{
			isRanged = true;
			rangedWeaponType = 'bow';
		}
		else if( combatDataStorage.GetPreferedCombatStyle() == EBG_Combat_Crossbow )
		{
			isRanged = true;
			rangedWeaponType = 'crossbow';
		}
		
		while( isRanged && ( !owner.HasAbility( 'StaticShooter' ) || !owner.HasAbility( 'PreventChangingCombatStyle' ) ) )
		{
			if ( combatDataStorage.GetActiveCombatStyle() != EBG_Combat_Undefined && !combatDataStorage.IsProcessingItems() && !combatDataStorage.GetIsAiming() )
			{
				target = GetCombatTarget();
				if ( target )
				{
					sqrDist = VecDistanceSquared( owner.GetWorldPosition(), target.GetWorldPosition() );
					if ( IsRangedCombatStyleActive() )
					{
						CheckIfShouldSwitchToMelee(sqrDist);
					}
					else
					{
						CheckIfShouldSwitchToRange(sqrDist);
					}
				}
			}
			Sleep(freq);
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		
	}
	
	function ProjectileFailSafe()
	{
		var prefferedCombatStyle : EBehaviorGraph;
		var proj : W3AdvancedProjectile;
		
		proj = combatDataStorage.GetProjectile();
		prefferedCombatStyle = combatDataStorage.GetPreferedCombatStyle();
		
		if ( proj && (prefferedCombatStyle != EBG_Combat_Bow && prefferedCombatStyle != EBG_Combat_Crossbow) )
			proj.Destroy();
	}
	
	function IsRangedCombatStyleActive() : bool
	{
		return combatDataStorage.GetActiveCombatStyle() == EBG_Combat_Bow || combatDataStorage.GetActiveCombatStyle() == EBG_Combat_Crossbow;
	}
	
	function CheckIfShouldSwitchToMelee( sqrDist : float )
	{
		if ( sqrDist <= 36 ) 
		{
			combatDataStorage.LeaveCurrentCombatStyle();
		}
		else
		{
			combatDataStorage.StopLeavingCurrentCombatStyle();
		}
	}
	
	function CheckIfShouldSwitchToRange( sqrDist : float )
	{
		if ( sqrDist > 100 ) 
		{
			if( rangedWeaponType == 'bow' )
				combatDataStorage.SetPreferedCombatStyle( EBG_Combat_Bow );
			else if( rangedWeaponType == 'crossbow' )
				combatDataStorage.SetPreferedCombatStyle( EBG_Combat_Crossbow );
			combatDataStorage.LeaveCurrentCombatStyle();
		}
		else
		{
			combatDataStorage.StopLeavingCurrentCombatStyle();
		}
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var newPreferedCombatStyle : int;
		
		InitializeCombatDataStorage();
		
		if ( eventName == 'ChangePreferedCombatStyle' )
		{
			newPreferedCombatStyle = GetEventParamInt(-1);
			if ( newPreferedCombatStyle >= 0 )
			{
				combatDataStorage.SetPreferedCombatStyle( newPreferedCombatStyle );
				GetNPC().SetPreferedCombatStyle(newPreferedCombatStyle);
				if( isActive && combatDataStorage.GetActiveCombatStyle() != newPreferedCombatStyle )
				{
					combatDataStorage.LeaveCurrentCombatStyle();
				}
			}
		}
		else if ( eventName == 'ResetPreferedCombatStyle' )
		{
			combatDataStorage.SetPreferedCombatStyle( preferedCombatStyle );
			if( isActive && combatDataStorage.GetActiveCombatStyle() != preferedCombatStyle )
			{
				combatDataStorage.LeaveCurrentCombatStyle();
			}
		}
		else if ( eventName == 'LeaveCurrentCombatStyle' )
		{
			combatDataStorage.LeaveCurrentCombatStyle();
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'ShouldSwitchToMelee' && IsRangedCombatStyleActive() )
		{
			if ( GetCombatTarget() )
			{
				CheckIfShouldSwitchToMelee(VecDistanceSquared(GetActor().GetWorldPosition(), GetCombatTarget().GetWorldPosition()));
			}
		}
		return false;
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class CBehTreeCombatStyleManagerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeCombatStyleManager';

	editable inlined var preferedCombatStyle : CBTEnumBehaviorGraph;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'ChangePreferedCombatStyle' );
		listenToGameplayEvents.PushBack( 'LeaveCurrentCombatStyle' );
	}
}
