/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct CriticalStateStruct
{
	var CSType			:	ECriticalStateType;
	var isActive		:	bool;
	var lastTimeActive	: 	float;
}


class CBaseAICombatStorage extends IScriptable
{
	
	private var isAttacking 		: 	bool;
	private var isCharging 			: 	bool;
	private var isTaunting			:	bool;
	private var isShooting			:	bool;
	private var isAiming			:	bool;
	private var isInImportantAnim 	:   bool; 		
	private var preCombatWarning	:	bool;		default preCombatWarning = true;
	
	
	protected var atackTimeStamp		: 	float;
	protected var tauntTimeStamp		: 	float;

	
	private var CSArray			: 	array<CriticalStateStruct>;
	
	
	function SetIsAttacking( value : bool, optional timeStamp : float ) 	
	{ 
		isAttacking = value; 
		if ( value && timeStamp )
			atackTimeStamp = timeStamp;
	}
	function GetIsAttacking() : bool 				{ return isAttacking; }
	
	function SetIsCharging( value : bool )			{ isCharging = value; }
	function GetIsCharging() : bool 				{ return isCharging; }
	
	function SetIsTaunting( value : bool, optional timeStamp : float )
	{ 
		isTaunting = value;
		if ( value && timeStamp )
			tauntTimeStamp = timeStamp;
	}
	function GetIsTaunting() : bool 				{ return isTaunting; }
	
	function GetTauntTimeStamp() : float			{ return tauntTimeStamp; }
	
	function SetIsShooting( value : bool ) 			{ isShooting = value; }
	function SetIsAiming( value : bool ) 			{ isAiming = value; }
	function SetIsInImportantAnim( value : bool ) 	{ isInImportantAnim = value; }
	function GetIsShooting() : bool 				{ return isShooting; }
	function GetIsAiming() : bool 					{ return isAiming; }
	function GetIsInImportantAnim() : bool 			{ return isInImportantAnim; }
	
	function SetPreCombatWarning( value : bool ) 	{ preCombatWarning = value; }
	function GetPreCombatWarning() : bool 			{ return preCombatWarning; }
	
	
	function SetCriticalState( cstate : ECriticalStateType, value : bool, timeOfChange : float )
	{
		var i : int;
		
		for( i = 0; i < CSArray.Size(); i += 1 )
		{
			if( CSArray[i].CSType == cstate )
			{
				CSArray[i].isActive = value;
				if( !value ) 
				{
					CSArray[i].lastTimeActive = timeOfChange;
				}
			}
		}
	}
	
	function GetCriticalState( cstate : ECriticalStateType ) : bool
	{
		var i : int;
		
		for( i = 0; i < CSArray.Size(); i += 1 )
		{
			if( CSArray[i].CSType == cstate )
			{
				return true;
			}
		}
		
		return false;
	}
	
	function GetTimeOfLastCSDeactivation( cstate : ECriticalStateType ) : float
	{
		var i : int;
		
		for( i = 0; i < CSArray.Size(); i += 1 )
		{
			if( CSArray[i].CSType == cstate )
			{
				return CSArray[i].lastTimeActive;
			}
		}
		
		return 0;
	}
	
	
	function Init()
	{
		var temp : CriticalStateStruct;
		
		temp.CSType = ECST_Immobilize;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_BurnCritical;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_Knockdown;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_HeavyKnockdown;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_Confusion;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_Paralyzed;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_Hypnotized;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_Stagger;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_LongStagger;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_CounterStrikeHit;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_Ragdoll;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_PoisonCritical;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_Frozen;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_Tornado;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
		
		temp.CSType = ECST_Trap;
		temp.isActive = false;
		temp.lastTimeActive = 0;
		CSArray.PushBack( temp );
	}
}


class CHumanAICombatStorage extends CBaseAICombatStorage
{
	private var parryCount		: 	int;
	
	
	private var activeStyle 			: EBehaviorGraph;
	private var preferedStyle 			: EBehaviorGraph;
	private var leaveCurrentStyle 		: bool;
	private var processingItems 		: bool;
	private var processingRequiresIdle 	: bool;
	private var mutlipleProjectiles 	: array<W3AdvancedProjectile>;
	private var currProjectile 			: W3AdvancedProjectile;
	private var protectedByQuen 		: bool;
	
	default processingItems = false;
	
	function IncParryCount()										{ parryCount += 1; }
	function GetParryCount() : int									{ return parryCount; }
	function ResetParryCount() 										{ parryCount = 0; }
	
	
	function SetPreferedCombatStyle ( newStyle : EBehaviorGraph )	{ preferedStyle = newStyle; }
	function GetPreferedCombatStyle() : EBehaviorGraph				{ return preferedStyle; } 
	
	
	function SetActiveCombatStyle( newStyle : EBehaviorGraph )
	{
		activeStyle = newStyle;
		leaveCurrentStyle = false;
	}
	
	function GetActiveCombatStyle() : EBehaviorGraph				{ return activeStyle; }
	
	
	function LeaveCurrentCombatStyle() 								{ leaveCurrentStyle = true; }
	function StopLeavingCurrentCombatStyle() 						{ leaveCurrentStyle = false; }
	function IsLeavingStyle() : bool								{ return leaveCurrentStyle; }
	
	function CalculateCombatStylePriority( combatStyle : EBehaviorGraph ) : int
	{
		if ( combatStyle == activeStyle )
		{
			if ( leaveCurrentStyle )
				return 10;
			else
				return 100;
		}
		else if ( combatStyle == preferedStyle )
		{
			return 60;
		}
		else if ( combatStyle == EBG_Combat_Undefined )
		{
			return -1;
		}
		
		return 50;
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	}
	
	function ReturnWeaponSubTypeForActiveCombatStyle() : int
	{
		switch ( activeStyle )
		{
			case EBG_Combat_2Handed_Hammer 		: return (int)EWST2H_Hammer;
			case EBG_Combat_2Handed_Axe 		: return (int)EWST2H_Axe;
			case EBG_Combat_2Handed_Halberd 	: return (int)EWST2H_Halberd;
			case EBG_Combat_2Handed_Spear 		: return (int)EWST2H_Spear;
			case EBG_Combat_2Handed_Staff 		: return (int)EWST2H_Staff;
			
			case EBG_Combat_1Handed_Sword 		: return (int)EWST1H_Sword;
			case EBG_Combat_1Handed_Axe 		: return (int)EWST1H_Axe;
			case EBG_Combat_1Handed_Blunt 		: return (int)EWST1H_Blunt;
			
			case EBG_Combat_Bow 				: return (int)EWSTR_Bow;
			case EBG_Combat_Crossbow 			: return (int)EWSTR_Crossbow;
			
			default 							: return 0;
		}
		return 0;
	}
	
	function IsProcessingItems() : bool								{ return processingItems; }
	function SetProcessingItems(toggle : bool)						{ processingItems = toggle; }
	function DoesProcessingRequiresIdle() : bool					{ return processingRequiresIdle; }
	function SetProcessingRequiresIdle(toggle : bool)				{ processingRequiresIdle = toggle; }
	
	function SetProjectile( proj : W3AdvancedProjectile )			{ currProjectile = proj; }
	function GetProjectile() : W3AdvancedProjectile					{ return currProjectile; }
	
	function AddNewProjectile( proj : W3AdvancedProjectile )		{ mutlipleProjectiles.PushBack(proj); }
	function GetProjectiles() : array<W3AdvancedProjectile>			{ return mutlipleProjectiles; }
	
	function DetachAndDestroyProjectile()
	{
		if( currProjectile )
		{
			currProjectile.BreakAttachment();
			currProjectile.Destroy();
			currProjectile = NULL;
		}
	}
	 
	function SetProtectedByQuen(toggle : bool)				{ protectedByQuen = toggle; }
	function IsProtectedByQuen() : bool						{ return protectedByQuen;}
	
	
	
	
	
	private var followerAttackCooldown 			: float;		default followerAttackCooldown 			= 10.f;
	private var followerKeepDistanceToPlayer 	: bool;			default followerKeepDistanceToPlayer 	= true;
	
	
	private var isAFollower : bool;
	
	public function BecomeAFollower()
	{
		isAFollower = true;
	}
	
	public function NoLongerFollowing()
	{
		isAFollower = false;
	}
	
	public function IsAFollower() : bool
	{
		return isAFollower;
	}
	
	public function ShouldAttack( currentTime : float ) : bool
	{
		if ( !isAFollower )
			return true;
			
		if ( atackTimeStamp <= 0 || ( atackTimeStamp + followerAttackCooldown < currentTime ) )
			return true;
		
		return false;
	}
	
	public function ShouldKeepDistanceToPlayer() : bool
	{
		if ( !isAFollower )
			return false;
		
		return followerKeepDistanceToPlayer;
	}
};


class CBossAICombatStorage extends CHumanAICombatStorage
{
	private var isLightbringerAvailable : bool;
	private var isMeteoritesAvailable : bool;
	private var isIceSpikesAvailable : bool;
	private var isBlinkComboAvailable : bool;
	
	private var isSpecialAttackAvailable : bool;	
	private var isParryAvailable 	: bool;
	private var isSiphonAvailable 	: bool;
	private var isDodgeAvailable 	: bool;
	private var isStaminaRegenAvailable : bool;	
	private var isPhaseChangeAvailable : bool;	
	private var inInSpecialAttack : bool;

	default isLightbringerAvailable = true;
	default isMeteoritesAvailable = true;
	default isIceSpikesAvailable = true;
	default isBlinkComboAvailable = true;
	default isSpecialAttackAvailable = true;
	default isParryAvailable = false;
	default isSiphonAvailable = false;
	default isDodgeAvailable = false;
	default isStaminaRegenAvailable = true;
	default isPhaseChangeAvailable = false;
	default inInSpecialAttack = false;

	
	function SetIsParryAvailable( value : bool )	{ isParryAvailable = value; }
	function GetIsParryAvailable() : bool 			{ return isParryAvailable; }
	
	function SetIsSiphonAvailable( value : bool )	{ isSiphonAvailable = value; }
	function GetIsSiphonAvailable() : bool 			{ return isSiphonAvailable; }
	
	function SetIsDodgeAvailable( value : bool )	{ isDodgeAvailable = value; }
	function GetIsDodgeAvailable() : bool 			{ return isDodgeAvailable; }
	
	function SetIsStaminaRegenAvailable( value : bool )			{ isStaminaRegenAvailable = value; }
	function GetIsStaminaRegenAvailable() : bool 				{ return isStaminaRegenAvailable; }
	
	function SetIsPhaseChangeAvailable( value : bool )			{ isPhaseChangeAvailable = value; }
	function GetIsPhaseChangeAvailable() : bool 				{ return isPhaseChangeAvailable; }
	
	function SetIsInSpecialAttack( value : bool )			{ inInSpecialAttack = value; }
	function GetIsInSpecialAttack() : bool 					{ return inInSpecialAttack; }

	function SetIsAttackAvailable( attack : EBossSpecialAttacks, val : bool )
	{ 
		switch( attack )
		{
			case EBSA_Lightbringer:
			{
				isLightbringerAvailable = val;
				
				break;
			}
			
			case EBSA_Meteorites:
			{
				isMeteoritesAvailable = val;
				
				break;
			}
			
			case EBSA_IceSpikes:
			{
				isIceSpikesAvailable = val;
				
				break;
			}
			
			case EBSA_BlinkCombo:
			{
				isBlinkComboAvailable = val;
				
				break;
			}
			
			case EBSA_SpecialAttacks:
			{
				isSpecialAttackAvailable = val;
				
				break;
			}
			
			default:
			{
				break;
			}
		}
	}
	
	function IsAttackAvailable( attack : EBossSpecialAttacks ) : bool
	{ 
		switch( attack )
		{
			case EBSA_Lightbringer:
			{
				return isLightbringerAvailable;
			}
			
			case EBSA_Meteorites:
			{
				return isMeteoritesAvailable;
			}
			
			case EBSA_IceSpikes:
			{
				return isIceSpikesAvailable;
			}
			
			case EBSA_BlinkCombo:
			{
				return isBlinkComboAvailable;
			}
			
			case EBSA_SpecialAttacks:
			{
				return isSpecialAttackAvailable;
			}
			
			default:
			{
				return false;
			}
		}
	}	
};


class CExtendedAICombatStorage extends CBaseAICombatStorage
{
	private var attackInfos	: array<AttackInfo>;
	
	function IncrementAttackCount( attackName : name )	
	{ 
		var i : int;
		var attackInfo : AttackInfo;

		if ( IsAttackInAttackInfos( attackName, i ) )
		{
			attackInfos[i].attackCount += 1;
		}
		else
		{
			attackInfo.attackName = attackName;
			attackInfo.attackCount = 1;
			attackInfos.PushBack( attackInfo );
		}
	}
	
	function IsAttackInAttackInfos( attackName : name, out i : int ) : bool
	{	
		for ( i = 0; i < attackInfos.Size(); i += 1 )
		{
			if ( attackInfos[i].attackName == attackName )
			{
				return true;
			}
		}

		return false;
	}
	
	function ClearAttackCount( attackName : name )	
	{ 
		var i : int;
		
		if ( IsAttackInAttackInfos( attackName, i ) )
			attackInfos.Erase(i);
	}
	
	function GetAttackCount( attackName : name ) : int	
	{ 
		var i : int;
	
		if ( IsAttackInAttackInfos( attackName, i ) )
			return attackInfos[i].attackCount;
		else 
			return 0;
	}
};

class CArchesporeAICombatStorage extends IScriptable
{
	public var myBaseEntities : array<CGameplayEntity>;
	public var noBulbAreas : array<CAreaComponent>;
	public var currentlyUsedBase : CGameplayEntity;
	public var wasInitialized : bool;
	public var manualBulbCleanup : bool;
};

struct AttackInfo
{
	var attackName		:	name;
	var attackCount		:	int;
}
