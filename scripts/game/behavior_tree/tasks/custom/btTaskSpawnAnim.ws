/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ESpawnCondition
{
	SC_Always,
	SC_PlayerInRange,
}

class CBTTaskSpawnAnim extends IBehTreeTask
{
	
	public var spawnCondition			: ESpawnCondition;
	public var delayMain				: float;
	public var time						: float;
	public var distToActors				: float;
	public var manageGravity 			: bool;	
	public var raiseEventName			: name;
	public var fxName			 		: name;
	public var initialAppearance		: name;
	public var setAppearanceTo 			: name;
	public var playFXOnAnimEvent		: bool;
	public var animEventNameActivator	: name;	
	public var monitorGroundContact		: bool;
	public var dealDamageOnAnimEvent	: name;
	public var becomeVisibleOnAnimEvent : name;
	public var tagToBeDamaged			: name;
	
	private var spawned 				: bool;
	private var canPlayHitAnim			: bool;
	private var animEventOccured		: bool;
	private var isVisible				: bool;
	
	default spawnCondition		= SC_PlayerInRange;
	default spawned 			= false;
	default manageGravity 		= false;
	default playFXOnAnimEvent	= false;
	default distToActors		= 30.f;
	default animEventOccured	= false;
	default tagToBeDamaged		= 'PLAYER';
	
	hint initialAppearance 	= "ignore enemies in range check for availability test";
	hint initialAppearance 	= "won't affect entity settings if left empty";
	hint setAppearanceTo 	= "works only when anim event name is specified";
	hint playFXOnAnimEvent 	= "if false, will play FX on activate";
	hint tagToBeDamaged		= "tag by which entities that should receive damaged will be searched for" ;
	
	
	function IsAvailable() : bool
	{
		if ( GetNPC().WasInCutscene() )
		{
			return false;
		}
		if ( GetNPC().GetBehaviorVariable( 'Spawn' ) == 1 )
		{
			return false;
		}
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc 	: CNewNPC = GetNPC();
		canPlayHitAnim = npc.CanPlayHitAnim();
		
		if( IsNameValid( becomeVisibleOnAnimEvent ) )
		{
			npc.SetGameplayVisibility( false );
			isVisible = false;
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC 	= GetNPC();
		var success : bool;
		
		success = SelectSpawnAnim();
		
		if( !success )
		{
			return BTNS_Failed;
		}
		
		while ( ( npc.GetBehaviorVariable( 'ForcedSpawnAnim' ) > 0 || npc.GetBehaviorVariable( 'SpawnAnim' ) != 0.f ) && !spawned )
		{			
			if ( spawnCondition == SC_PlayerInRange )
			{
				if ( VecDistance2D( thePlayer.GetWorldPosition(), npc.GetWorldPosition() ) < distToActors )
				{
					ActivateSpawn();
				}
			}
			else
			{
				ActivateSpawn();
			}
			
			Sleep( 0.1 );
		}
		return BTNS_Completed;
	}
	
	
	private final latent function SelectSpawnAnim() : bool
	{
		var npc 					: CNewNPC = GetNPC();
		var pos						: Vector;
		var componentArray			: array<CComponent>;
		var waterLevel				: float;
		var waterDepth				: float;
		var navDataZ				: float;
		var distFromNavZ			: float;
		var security				: int;		
		
		npc.SetCanPlayHitAnim( false );
		
		if( initialAppearance )
		{
			npc.SetAppearance( initialAppearance );
		}
		
		pos = npc.GetWorldPosition();
		
		
		waterDepth = theGame.GetWorld().GetWaterDepth( pos );
		if( waterDepth > 1000 ) waterDepth = 0;
		
		
		
		while( !theGame.GetWorld().NavigationComputeZ( pos, pos.Z - 100, pos.Z + 3, navDataZ ) && waterDepth <= 0 && security < 120 )
		{			
			SleepOneFrame();
			security+=1;
		}		
		
		distFromNavZ = pos.Z - navDataZ;
		
		if( security >= 120 )
		{
			
		}
		
		
		
		
		waterLevel = theGame.GetWorld().GetWaterLevel( pos );
		if(  waterLevel > pos.Z + 2 )
		{
			npc.SetBehaviorVariable( 'SpawnAnim', 3 );
			npc.ChangeStance( NS_Swim );
			
			
		}		
		
		else if( distFromNavZ > 1 && npc.HasAbility('Flying') && !npc.IsAbilityBlocked('Flying') )
		{
			npc.SetBehaviorVariable( 'SpawnAnim', 2 );
			npc.ChangeStance( NS_Fly );
			
			
		}
		else
		{
			npc.SetBehaviorVariable( 'SpawnAnim', 1 );
			if( npc.IsAbilityBlocked('Flying') )
			{
				LogChannel('SpawnLogic', npc.GetName() + " - Flying ability is blocked ...");
			}
			
		}
		
		if( raiseEventName )
		{
			return npc.RaiseForceEvent( raiseEventName );
		}
		
		return true;
	}
	
	latent function ActivateSpawn()
	{
		var npc 			: CNewNPC 	= GetNPC();
		var InFlySwimSpawnAnim 	: bool;
		var waterLevel		: float;
		var submergeDepth	: float;
		var pos				: Vector;
		var navDataZ		: float;
		var distFromNavZ	: float;
		
		((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( false );
		submergeDepth = ((CMovingPhysicalAgentComponent) npc.GetMovingAgentComponent()).GetSubmergeDepth();
		
		time = GetLocalTime();
		
		pos = npc.GetWorldPosition();
		waterLevel = theGame.GetWorld().GetWaterLevel( pos );
		
		if ( manageGravity && npc.GetBehaviorVariable( 'SpawnAnim' ) == 1.f )
		{	
			if ( waterLevel > pos.Z + 2 ) 
			{
				npc.EnablePhysicalMovement( true );
				((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetSwimming( true );
				((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetDiving( true );
				((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetGravity( false );
				
			}
			else
			{
				npc.EnablePhysicalMovement( false );
				((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetGravity( true );
				
			}
		}
		
		while ( time + delayMain > GetLocalTime() )
		{
			Sleep( 0.01f );
		}
		
		npc.SetBehaviorVariable( 'Spawn', 1.f );		
		InFlySwimSpawnAnim = npc.GetBehaviorVariable( 'SpawnAnim' ) >= 2.f ;
		
		if ( InFlySwimSpawnAnim && manageGravity )
		{
			npc.EnablePhysicalMovement( true );
		
			if ( waterLevel > pos.Z + 2 ) 
			{
				((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetSwimming( true );
				((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetDiving( true );
			
				
			}
			else
			{
				
				((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( true );
			}
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetGravity( false );
		}
		
		while ( monitorGroundContact )
		{	
			pos = npc.GetWorldPosition();
			theGame.GetWorld().NavigationComputeZ( pos, pos.Z - 1, pos.Z + 1, navDataZ );
			distFromNavZ = pos.Z - navDataZ;
			
			if( distFromNavZ < 1  )
			{
				npc.SetBehaviorVariable( 'GroundContact', 1.0 );
				monitorGroundContact = false;
			}
			
			SleepOneFrame();
		}
		
		npc.WaitForBehaviorNodeDeactivation('SpawnEnd', 15 );
		
		
		theGame.GetWorld().NavigationComputeZ( pos, pos.Z - 1, pos.Z + 1, navDataZ );
		distFromNavZ = pos.Z - navDataZ;
		if(  waterLevel < pos.Z + 2 && manageGravity && distFromNavZ > 1 && npc.GetDistanceFromGround( 2 ) > 1 && npc.HasAbility('Flying') && !npc.IsAbilityBlocked('Flying') )
		{
			npc.EnablePhysicalMovement( true );
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( true );
			npc.ChangeStance( NS_Fly );
			
			
		}
		
		else if( waterLevel < pos.Z + 2 )
		{
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( false );
			npc.EnablePhysicalMovement( false );
			npc.ChangeStance( NS_Normal );
			
			
		}		

		spawned = true;		
	}
	
	function OnDeactivate()
	{
		var npc 	: CNewNPC = GetNPC();
		spawned 			= false;
		animEventOccured 	= false;
		npc.SetCanPlayHitAnim( canPlayHitAnim );
		
		if( IsNameValid( becomeVisibleOnAnimEvent ) && !isVisible )
		{
			npc.SetGameplayVisibility( true );
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( animEventName == animEventNameActivator )
		{
			animEventOccured = true;
			if( setAppearanceTo )
			{
				npc.SetAppearance( setAppearanceTo );
			}
			if( IsNameValid(fxName) && playFXOnAnimEvent )
			{
				npc.PlayEffect( fxName );
			}
			return true;
		}
		else if( IsNameValid( becomeVisibleOnAnimEvent ) && animEventName == becomeVisibleOnAnimEvent )
		{
			npc.SetGameplayVisibility( true );
			isVisible = true;
		}

		if( IsNameValid( dealDamageOnAnimEvent ) && animEventName == dealDamageOnAnimEvent )
		{
			DealDamage();
			return true;
		}
		
		return false;
	}
	
	private function DealDamage()
	{
		var action 				: W3DamageAction;
		var npc 				: CNewNPC = GetNPC();
		var victims 			: array<CActor>;
		var i					: int;
		var inv					: CInventoryComponent;
		var weapons				: array < SItemUniqueId >;
		var damageNames			: array < CName >;

		
		victims = GetActorsInRange( npc, 3.f, 5, tagToBeDamaged, true );
		action = new W3DamageAction in this;
		inv = action.attacker.GetInventory();		
		weapons = inv.GetWeapons();		
		inv.GetWeaponDTNames( weapons[0], damageNames );
		
		
		action.AddEffectInfo(EET_Knockdown);
		action.AddDamage(theGame.params.DAMAGE_NAME_BLUDGEONING, 25.f );
		action.SetCanPlayHitParticle(false);

		
		if ( victims.Size() > 0 )
		{
			for ( i = 0 ; i < victims.Size() ; i += 1 )
			{
				action.Initialize(npc,victims[i],this,npc.GetName(),EHRT_Heavy,CPS_AttackPower,false,true,false,false);
				theGame.damageMgr.ProcessAction( action );
			}
		}
		
		delete action;
	}
};

class CBTTaskSpawnAnimDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSpawnAnim';

	editable var useSwarms					: bool;
	editable var manageGravity 				: bool;
	editable var spawnCondition				: ESpawnCondition;
	editable var distToActors 				: float;
	editable var delayMain					: float;
	editable var raiseEventName				: name;
	editable var dealDamageOnAnimEvent		: CBehTreeValCName;
	editable var fxName 					: CBehTreeValCName;
	editable var initialAppearance 			: name;
	editable var setAppearanceTo			: name;
	editable var playFXOnAnimEvent 			: CBehTreeValBool;
	editable var animEventNameActivator 	: CBehTreeValCName;
	editable var monitorGroundContact		: CBehTreeValBool;
	editable var becomeVisibleOnAnimEvent 	: CBehTreeValCName;
	editable var tagToBeDamaged				: name;
	
	default spawnCondition			= SC_PlayerInRange;
	default manageGravity 			= false;
	default distToActors			= 30.f;
	
};