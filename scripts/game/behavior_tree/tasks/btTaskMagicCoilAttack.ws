/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskMagicCoilAttack extends CBTTaskAttack
{
	public var fxNames 						: array<name>;
	public var playFxInterval 				: float;
	public var shootProjectileRange			: float;
	public var shootProjectileInterval 		: float;
	public var deactivateAfter 				: float;
	public var setBehVarOnDeactivation 		: name;
	public var setBehVarValueOnDeactivation : float;
	public var useActorHeading				: bool;
	public var activateOnAnimEvent			: name;
	public var projResourceName				: name;
	public var fxOnDamageInstigatedQuen 	: name;
	
	private var m_collisionGroups 			: array<name>;
	private var m_projectile				: W3AdvancedProjectile;
	private var m_projEntity				: CEntityTemplate;
	private var m_numberOfFxActivated		: int;
	private var m_activated					: bool;
	
	
	
	
	function Initialize()
	{
		m_collisionGroups.PushBack('Ragdoll');
		m_collisionGroups.PushBack('Terrain');
		m_collisionGroups.PushBack('Static');
		m_collisionGroups.PushBack('Water');
	}	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc						: CNewNPC = GetNPC();
		var projPos					: Vector;
		var targetPos 				: Vector;
		var timeStamp 				: float;
		var lastFxTime 				: float;
		var lastProjectileShotTime 	: float;
		var distToTarget 			: float;
		var numberOfFxToPlay 		: int;
		var i 						: int;
		
		npc.SetBehaviorVariable( setBehVarOnDeactivation, 0 );
		
		if ( !m_projEntity )
		{
			m_projEntity = (CEntityTemplate)LoadResourceAsync( projResourceName );
		}
		
		if ( !m_projEntity )
		{
			return BTNS_Failed;
		}
		
		super.Main();
		
		if ( IsNameValid( activateOnAnimEvent ) )
		{
			while ( !m_activated )
			{
				SleepOneFrame();
			}
		}
		
		targetPos = GetCombatTarget().GetWorldPosition();
		distToTarget = VecDistance2D( targetPos, npc.GetWorldPosition() );
		
		
		
		timeStamp = GetLocalTime();
		
		while( timeStamp + deactivateAfter > GetLocalTime() )
		{
			SleepOneFrame();
			
			if ( m_numberOfFxActivated < fxNames.Size() - numberOfFxToPlay && lastFxTime + playFxInterval < GetLocalTime() )
			{
				npc.PlayEffect( fxNames[m_numberOfFxActivated] );
				lastFxTime = GetLocalTime();
				m_numberOfFxActivated += 1;
			}
			
			if ( lastProjectileShotTime + shootProjectileInterval < GetLocalTime() )
			{
				projPos = npc.GetWorldPosition();
				projPos.Z += 1.5f;
				m_projectile = (W3AdvancedProjectile)theGame.CreateEntity( m_projEntity, projPos, npc.GetWorldRotation() );
				
				ShootProjectile();
				lastProjectileShotTime = GetLocalTime();
			}
		}
		
		while ( m_numberOfFxActivated > 0 )
		{
			SleepOneFrame();
			
			
			if ( lastFxTime + playFxInterval < GetLocalTime() )
			{
				npc.StopEffect( fxNames[ fxNames.Size() - m_numberOfFxActivated ] );
				lastFxTime = GetLocalTime();
				m_numberOfFxActivated -= 1;
			}
			
			if ( lastProjectileShotTime + shootProjectileInterval < GetLocalTime() )
			{
				projPos = npc.GetWorldPosition();
				projPos.Z += 1.5f;
				m_projectile = (W3AdvancedProjectile)theGame.CreateEntity( m_projEntity, projPos, npc.GetWorldRotation() );
				
				ShootProjectile();
				lastProjectileShotTime = GetLocalTime();
			}
		}
		
		npc.SetBehaviorVariable( setBehVarOnDeactivation, setBehVarValueOnDeactivation );
		
		return BTNS_Active;
	}
	
	
	
	function OnDeactivate()
	{
		var npc			: CNewNPC = GetNPC();
		var i 			: int;
		
		npc.SetBehaviorVariable( setBehVarOnDeactivation, setBehVarValueOnDeactivation );
		
		if ( m_numberOfFxActivated > 0 )
		{
			for ( i = 0 ; i < fxNames.Size() ; i += 1 )
			{
				npc.StopEffect( fxNames[i] );
			}
		}
		m_numberOfFxActivated = 0;
		m_activated = false;
		
		super.OnDeactivate();
	}
	
	
	
	function ShootProjectile()
	{
		var target 						: CActor = GetCombatTarget();
		var npc							: CNewNPC = GetNPC();
		var combatTargetPos 			: Vector;
		var targetPos					: Vector;
		var proj						: W3AdvancedProjectile;
		var distToTarget 				: float;
		var range						: float;
		var l_3DdistanceToTarget		: float;
		var l_projectileFlightTime		: float;
		var l_npcToTargetAngle			: float;
		
		
		combatTargetPos = target.GetWorldPosition();
		m_projectile.Init( npc );
		
		distToTarget = VecDistance2D( combatTargetPos, npc.GetWorldPosition() );
		
		if ( useActorHeading )
		{
			l_npcToTargetAngle = NodeToNodeAngleDistance( target, npc );
			targetPos = m_projectile.GetWorldPosition() + VecFromHeading( AngleNormalize180( npc.GetHeading() - l_npcToTargetAngle ) ) * distToTarget;
			targetPos.Z = combatTargetPos.Z;
		}
		else
		{
			targetPos = m_projectile.GetWorldPosition() + VecFromHeading( AngleNormalize180( npc.GetBehaviorVariable( 'requestedFacingDirection' ) ) ) * distToTarget;
			targetPos.Z = combatTargetPos.Z;
		}
		
		range = shootProjectileRange * ( m_numberOfFxActivated / ( fxNames.Size() + 1 ) );
		
		targetPos.Z = combatTargetPos.Z + 1.5;
		m_projectile.ShootProjectileAtPosition( m_projectile.projAngle, m_projectile.projSpeed, targetPos, range, m_collisionGroups );
		
		
		l_3DdistanceToTarget = VecDistance( npc.GetWorldPosition(), combatTargetPos );		
		l_projectileFlightTime = l_3DdistanceToTarget / m_projectile.projSpeed;
		target.SignalGameplayEventParamFloat( 'Time2DodgeProjectile', l_projectileFlightTime );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == activateOnAnimEvent )
		{
			m_activated = true;	
			return true;
		}
		
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 			: CNewNPC = GetNPC();
		var witcher 		: W3PlayerWitcher = GetWitcherPlayer();
		var attributeValue 	: SAbilityAttributeValue;
		
		if ( eventName == 'DamageInstigated' )
		{
			ApplyCriticalEffectOnTarget();
			
			if ( GetLocalTime() > fxTimeCooldown )
			{
				if ( witcher == GetCombatTarget() )
				{
					if ( IsNameValid( fxOnDamageInstigatedQuen ) && witcher.IsQuenActive( true ) || witcher.IsQuenActive( false ) )
					{
						fxTimeCooldown = GetLocalTime() + applyFXCooldown;
						npc.PlayEffect(fxOnDamageInstigatedQuen);
					}
					else if ( IsNameValid( fxOnDamageInstigated ) && !witcher.IsQuenActive( true ) && !witcher.IsQuenActive( false ) )
					{
						fxTimeCooldown = GetLocalTime() + applyFXCooldown;
						npc.PlayEffect(fxOnDamageInstigated);
					}
				}
			}
			if ( IsNameValid( fxOnDamageVictim ) && ( GetLocalTime() > fxTimeCooldown ))
			{
				fxTimeCooldown = GetLocalTime() + applyFXCooldown;
				GetCombatTarget().PlayEffect( fxOnDamageVictim );
			}
			if ( stopTaskAfterDealingDmg )
			{
				if ( setAttackEndVarOnStopTask )
					npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
				stopTask = true;
			}
			return true;
		}
		else if ( eventName == 'AxiiGuardMeAdded' )
		{
			GetNPC().RaiseEvent('AnimEndAUX');
			Complete(true);
			return true;
		}
		
		return super.OnGameplayEvent(eventName);
	}
}




class CBTTaskMagicCoilAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskMagicCoilAttack';

	editable var fxNames 						: array<name>;
	editable var playFxInterval 				: float;
	editable var shootProjectileRange			: float;
	editable var shootProjectileInterval		: float;
	editable var deactivateAfter 				: float;
	editable var setBehVarOnDeactivation 		: name;
	editable var setBehVarValueOnDeactivation 	: float;
	editable var useActorHeading 				: bool;
	editable var activateOnAnimEvent			: name;
	editable var projResourceName				: name;
	editable var fxOnDamageInstigatedQuen 		: name;
	
	default projResourceName 					= 'sand_coil_proj';
	default activateOnAnimEvent 				= 'activate';
	default fxOnDamageInstigatedQuen 			= 'sand_attack_onscreen';
}