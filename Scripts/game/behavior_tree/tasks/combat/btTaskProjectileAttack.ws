/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskProjectileAttack extends CBTTaskAttack
{
	var attackRange					: float;
	var resourceName	 			: name;
	var depotPathInsteadOfAlias		: bool;
	var depotPath					: string;
	var projEntity					: CEntityTemplate;
	var wasShot 					: bool;
	var collisionGroups 			: array<name>;
	var homingProjectile 			: bool;
	var dodgeable 					: bool;
	var shootOnGround 				: bool;
	var useLookatTarget 			: bool;
	var startPosFrontOffset 		: float;
	var playFXOnShootProjectile		: name;
	var shootOnEventName 			: name;
	var useCustomCollisionGroups	: bool;
	var collideWithRagdoll			: bool;
	var collideWithTerrain			: bool;
	var collideWithStatic			: bool;
	var collideWithWater			: bool;
	var useCustomTargetWithTag		: bool;
	var tagToFind					: name;
	
	var distance 					: float;
	
	private var couldntLoadResource : bool;
	
	protected var m_Projectiles	: array<W3AdvancedProjectile>;	
	protected var projectile 	: W3AdvancedProjectile;
	
	default distance = 8.f;
	default useCustomCollisionGroups = false;
	
	function IsAvailable() : bool
	{
		return !couldntLoadResource;
	}
	
	latent function Main() : EBTNodeStatus
	{
		if ( !projEntity )
		{
			if( depotPathInsteadOfAlias )
			{
				projEntity = (CEntityTemplate)LoadResourceAsync( depotPath, true );
			}
			else
			{
				projEntity = (CEntityTemplate)LoadResourceAsync( resourceName );
			}
		}
		
		if ( !projEntity )
		{
			couldntLoadResource = true;
			return BTNS_Failed;
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var i : int;
		var l_projectile : W3AdvancedProjectile;
		super.OnDeactivate();
		
		if( !wasShot )
		{
			for ( i = 0; i < m_Projectiles.Size(); i += 1 )
			{
				l_projectile = m_Projectiles[ i ];
				l_projectile.BreakAttachment();
				l_projectile.DestroyRequest();
			}
			
			if( projectile )
			{
				projectile.BreakAttachment();
				projectile.DestroyRequest();			
			}
		}
		
		m_Projectiles.Clear();
		
		projectile = NULL;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if ( animEventName == 'ShootProjectile' || animEventName == 'Throw' || ( IsNameValid( shootOnEventName ) && animEventName == shootOnEventName ) )
		{
			CreateAndShootProjectile();
			m_Projectiles.Clear();	
			return true;
		}
		else if ( animEventName == 'Shoot3Projectiles' )
		{
			CreateProjectile( 3 );
			CreateAndShootProjectile(0, 0);
			CreateAndShootProjectile(GetActor().GetHeading()+5, 1);
			CreateAndShootProjectile(GetActor().GetHeading()-5, 2);
			m_Projectiles.Clear();	
		}
		else if ( animEventName == 'Shoot3ProjectilesWide' )
		{		
			CreateProjectile( 3 );
			CreateAndShootProjectile(0, 0);
			CreateAndShootProjectile(GetActor().GetHeading()+15, 1);
			CreateAndShootProjectile(GetActor().GetHeading()-15, 2);
			m_Projectiles.Clear();	
		}
		else if ( animEventName == 'Shoot5Projectiles' )
		{		
			CreateProjectile( 5 );
			CreateAndShootProjectile(0, 0);
			CreateAndShootProjectile(GetActor().GetHeading()+5, 1);
			CreateAndShootProjectile(GetActor().GetHeading()-5, 2);
			CreateAndShootProjectile(GetActor().GetHeading()+10, 3);
			CreateAndShootProjectile(GetActor().GetHeading()-10, 4);
			m_Projectiles.Clear();	
		}
		else if ( animEventName == 'Shoot5ProjectilesWide' )
		{		
			CreateProjectile( 5 );
			CreateAndShootProjectile(0, 0);
			CreateAndShootProjectile(GetActor().GetHeading()+15, 1);
			CreateAndShootProjectile(GetActor().GetHeading()-15, 2);
			CreateAndShootProjectile(GetActor().GetHeading()+30, 3);
			CreateAndShootProjectile(GetActor().GetHeading()-30, 4);
			m_Projectiles.Clear();	
		}
		
		return res;
	}
	
	function CreateAndShootProjectile(optional customHeading : float, optional projectileIndex : int )
	{
		var npc 					: CNewNPC = GetNPC();
		var target 					: CActor = GetCombatTarget();
		var npcPos					: Vector;
		var targetPos				: Vector;
		var combatTargetPos 		: Vector;
		var range 					: float;
		var distToTarget 			: float;
		var i						: int;
		var l_projectile			: W3AdvancedProjectile;
		var l_heightFromTarget		: float;
		var l_3DdistanceToTarget	: float;
		var l_projectileFlightTime	: float;
		
		if ( m_Projectiles.Size() == 0 )
			CreateProjectile( 1 );
		
		if( useCombatTarget )
		{
			combatTargetPos = GetCombatTarget().GetWorldPosition();
		}
		else if ( useCustomTargetWithTag )
		{
			combatTargetPos = theGame.GetEntityByTag( tagToFind ).GetWorldPosition();
		}
		else
		{
			combatTargetPos = GetActionTarget().GetWorldPosition();
		}
		
		distToTarget = VecDistance2D( combatTargetPos, npc.GetWorldPosition() );
		range = attackRange;
		
		l_projectile = m_Projectiles[ projectileIndex ];
		
		if ( useLookatTarget )
		{
			targetPos = npc.GetBehaviorVectorVariable('lookAtTarget');
		}
		else if ( customHeading )
		{
			targetPos = l_projectile.GetWorldPosition() + VecFromHeading(customHeading)* distToTarget;
			targetPos.Z = combatTargetPos.Z;
		}
		else
		{
			targetPos = l_projectile.GetWorldPosition() +  npc.GetHeadingVector()* distToTarget;
			targetPos.Z = combatTargetPos.Z;
		}
		
		if ( !shootOnGround )
		{
			targetPos.Z = combatTargetPos.Z + 1.5;
		}
		
		Clamp( projectileIndex, 0, m_Projectiles.Size() - 1 );
		
		if ( homingProjectile )
		{
			if ( useCombatTarget )
			{
				l_projectile.ShootProjectileAtNode( l_projectile.projAngle, l_projectile.projSpeed, GetCombatTarget(), range, collisionGroups );
			}
			else
			{
				l_projectile.ShootProjectileAtNode( l_projectile.projAngle, l_projectile.projSpeed, GetActionTarget(), range, collisionGroups );
			}
		}
		else if( useCustomTargetWithTag )
		{
			l_projectile.ShootProjectileAtPosition( l_projectile.projAngle, l_projectile.projSpeed, combatTargetPos, range, collisionGroups );
		}
		else
		{
			l_projectile.ShootProjectileAtPosition( l_projectile.projAngle, l_projectile.projSpeed, targetPos, range, collisionGroups );
		}
		
		if ( IsNameValid( playFXOnShootProjectile ) && !l_projectile.IsEffectActive( playFXOnShootProjectile ) )
			l_projectile.PlayEffect( playFXOnShootProjectile );
		
		if ( dodgeable )
		{
			l_3DdistanceToTarget = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );		
			
			
			l_projectileFlightTime = l_3DdistanceToTarget / l_projectile.projSpeed;
			target.SignalGameplayEventParamFloat( 'Time2DodgeProjectile', l_projectileFlightTime );
		}
		
		wasShot = true;
	}
	
	function CreateProjectile( optional _Quantity : int )
	{
		var l_npc			: CNewNPC = GetNPC();
		var l_projRot		: EulerAngles;
		var l_projPos		: Vector;
		var l_projectile	: W3AdvancedProjectile;
		var i				: int;
		
		if( m_Projectiles.Size() > 0 ) return;
		
		for ( i = 0; i < _Quantity; i += 1 )
		{
			l_projPos 		= GetProjectileStartPosition();
			l_projRot 		= l_npc.GetWorldRotation();
			l_projectile 	= (W3AdvancedProjectile)theGame.CreateEntity( projEntity, l_projPos, l_projRot );
			l_projectile.Init( l_npc );
			
			m_Projectiles.PushBack( l_projectile );
		}
		
		if( _Quantity == 0 )
		{ 
			l_projPos 		= GetProjectileStartPosition();
			l_projRot 		= l_npc.GetWorldRotation();
			l_projectile 	= (W3AdvancedProjectile)theGame.CreateEntity( projEntity, l_projPos, l_projRot );
			l_projectile.Init( l_npc );
			
			projectile = l_projectile;			
		}
		
		wasShot = false;
	}
	
	function Initialize()
	{
		if( !useCustomCollisionGroups )
		{
			collisionGroups.PushBack('Ragdoll');
			collisionGroups.PushBack('Terrain');
			collisionGroups.PushBack('Static');
			collisionGroups.PushBack('Water');
		}
		else
		{
			if( collideWithRagdoll )
			{
				collisionGroups.PushBack('Ragdoll');
			}
			if( collideWithTerrain )
			{
				collisionGroups.PushBack('Terrain');
			}
			if( collideWithStatic )
			{
				collisionGroups.PushBack('Static');
			}
			if( collideWithWater )
			{
				collisionGroups.PushBack('Water');
			}
		}
	}	
	
	
	
	
	protected function GetProjectileStartPosition() : Vector
	{
		
		var slotWorldPos : Vector;
		var slotMatrix : Matrix;
		
		if ( GetNPC().CalcEntitySlotMatrix( 'projectile_origin', slotMatrix ))
		{
			slotWorldPos = MatrixGetTranslation( slotMatrix );
		}
		else
		{			
			slotWorldPos 	= GetNPC().GetWorldPosition();
			slotWorldPos.Z += 1.5f;
			
			if( startPosFrontOffset > 0.01 )
			{
				slotWorldPos += GetNPC().GetHeadingVector() * startPosFrontOffset;
			}
		}
		
		return slotWorldPos;
	}
}

class CBTTaskProjectileAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskProjectileAttack';
	
	editable var attackRange 				: CBehTreeValFloat;
	editable var resourceName	 			: name;
	editable var depotPathInsteadOfAlias	: bool;
	editable var depotPath					: string;
	editable var parametrizedResourceName	: CBehTreeValCName;
	editable var homingProjectile 			: bool;
	editable var dodgeable					: bool;
	editable var shootOnGround				: bool;
	editable var useLookatTarget			: bool;
	editable var startPosFrontOffset		: float;
	editable var playFXOnShootProjectile	: name;
	editable var shootOnEventName 			: name;
	editable var useCustomCollisionGroups	: bool;
	editable var collideWithRagdoll			: bool;
	editable var collideWithTerrain			: bool;
	editable var collideWithStatic			: bool;
	editable var collideWithWater			: bool;
	editable var useCustomTargetWithTag		: bool;
	editable var tagToFind					: name;
	
	var projEntity 							: CEntityTemplate;
	
	default depotPathInsteadOfAlias	= false;
	
	public function Initialize()
	{
		SetValFloat(attackRange,10.f);
	}
	
	function OnSpawn( task : IBehTreeTask )
	{
		var thisTask : CBTTaskProjectileAttack; 
		
		thisTask = (CBTTaskProjectileAttack)task;
		
		if( IsNameValid( GetValCName( parametrizedResourceName ) ) )
		{
			resourceName = GetValCName( parametrizedResourceName );
		}
		
		if ( projEntity )
			thisTask.projEntity = projEntity;
			
		super.OnSpawn( task );
	}
}

class CBTTaskProjectileAttackWithPrepare extends CBTTaskProjectileAttack
{
	var boneName : name;
	var rawTarget : bool;
	var shootInFront : bool;
	var shootInFrontOffset : float;
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if ( animEventName == 'Prepare' )
		{
			CreateProjectile();
			if ( boneName )
				projectile.CreateAttachment( GetActor(), boneName );
			return true;
		}
		
		return res;
	}
	
	function CreateAndShootProjectile(optional customHeading : float, optional projectileIndex : int)
	{
		var npc 					: CNewNPC = GetNPC();
		var target 					: CActor = GetCombatTarget();
		var targetPos				: Vector;
		var combatTargetPos 		: Vector;
		var normal					: Vector;
		var range 					: float;
		var distToTarget 			: float;
		var l_3DdistanceToTarget	: float;
		var l_projectileFlightTime	: float;
		var l_boneIndex				: int;
		var l_position				: Vector;
		var l_rotation				: EulerAngles;
		var l_forwardRotation		: Vector;
			
		var useLookAtBone 			: bool;	
		var lookAtBone				: name = 'head';
		
		
		if ( !projectile )
			CreateProjectile();
			
		projectile.BreakAttachment();
		
		if( useCombatTarget )
		{
			combatTargetPos = GetCombatTarget().GetWorldPosition();
		}
		else
		{
			combatTargetPos = GetActionTarget().GetWorldPosition();
		}
		
		distToTarget = VecDistance( combatTargetPos, npc.GetWorldPosition() );
		range = attackRange;
		if( shootInFront )
		{
			targetPos = npc.GetWorldPosition() + npc.GetHeadingVector() * MaxF( 1.0, shootInFrontOffset );
		}
		else if( rawTarget )
			targetPos = combatTargetPos;
		else if ( useLookatTarget )
		{
			targetPos = npc.GetBehaviorVectorVariable('lookAtTarget');
		}
		else if ( customHeading )
		{
			targetPos = projectile.GetWorldPosition() + VecNormalize(VecFromHeading(customHeading))* distToTarget;
			targetPos.Z = combatTargetPos.Z;
		}
		else if ( useLookAtBone )
		{
			l_boneIndex = npc.GetBoneIndex( lookAtBone );
			npc.GetBoneWorldPositionAndRotationByIndex( l_boneIndex, l_position, l_rotation );
			l_forwardRotation = RotForward( l_rotation );
			targetPos =  l_position + l_forwardRotation * range;
			
		}
		else
		{
			targetPos = projectile.GetWorldPosition() +  VecNormalize(npc.GetHeadingVector())* distToTarget;
			targetPos.Z = combatTargetPos.Z;
		}
		
		
		if ( !shootOnGround )
			targetPos.Z = combatTargetPos.Z + 1.5;
		
		
		projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, targetPos, range, collisionGroups );
		
		if ( IsNameValid( playFXOnShootProjectile ) && !projectile.IsEffectActive( playFXOnShootProjectile ) )
			projectile.PlayEffect( playFXOnShootProjectile );
		
		if ( dodgeable )
		{
			l_3DdistanceToTarget = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );		
			
			
			l_projectileFlightTime = l_3DdistanceToTarget / projectile.projSpeed;
			target.SignalGameplayEventParamFloat( 'Time2DodgeProjectile', l_projectileFlightTime );
		}
		
		wasShot = true;
	}
}

class CBTTaskProjectileAttackWithPrepareDef extends CBTTaskProjectileAttackDef
{
	default instanceClass = 'CBTTaskProjectileAttackWithPrepare';

	editable var boneName 				: name;
	editable var shootInFront 			: bool;
	editable var shootInFrontOffset 	: float;
	editable var rawTarget 				: bool;
	editable var useLookAtBone 			: bool;	
	editable var lookAtBone				: name;
	
	hint boneName = "Name of the bone that projectile will be attached on 'Prepare' anim event";
	hint rawTarget = "if set to true it will take rawTarget position instead of calculating it from currentHeading + attackRange";
	hint shootInFront = "if set to true it will pick target in front of npc, multiplied by shootInFrontOffset value";
}
