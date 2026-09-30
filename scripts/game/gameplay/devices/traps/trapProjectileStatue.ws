/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TrapProjectileStatue extends W3Trap
{
	
	
	
	private editable 	var 	m_Projectile 				: CEntityTemplate;
	private editable 	var		m_IsStatic					: bool; 		default m_IsStatic					= false ; 	hint m_IsStatic = "true means launcher does not move";
	private editable 	var		m_RotationSpeed				: float; 		default m_RotationSpeed 			= 30 ; 		hint m_RotationSpeed = "-1 is instant";
	private editable	var		m_FirstShootDelay			: float;		
	private editable	var		m_FireRate					: float;		default m_FireRate 					= 1;
	private editable	var		m_MaxShots					: float;		default m_MaxShots					= -1;		hint m_MaxShots = "-1 is infinite";
	private editable 	var		m_MinAngleToStartShooting	: float;		default m_MinAngleToStartShooting 	= 45;
	private editable	var		m_MaxAimingPitchCorrection	: float;
	private editable	var		m_TargetPositionPrediction	: float;
	
	private editable 	var		m_ProjectileIsCocked		: Bool;															hint m_CockProjectile = "should the projectile be visible when not fired";
	
	private	editable 	var		m_ProjectileSpeed			: float;		default m_ProjectileSpeed 			= 20;
	private	editable 	var		m_ProjectileLifeSpan		: float;		default m_ProjectileLifeSpan 		= -1;		hint m_ProjectileLifeSpan = "-1 is infinite";
	private	editable 	var		m_ProjectileFollowTarget	: bool;	
	
	
	private				var		m_DelayUntilNextProjectile	: float;
	private saved		var		m_ShotsLeft					: float;
	private				var		m_CockedProjectile			: W3AdvancedProjectile;
	private				var		m_DelayToNextSorting		: float;
	
	default	m_TargetPositionPrediction = 0.5;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		
		super.OnSpawned(spawnData);
		m_ShotsLeft = m_MaxShots;
		
		if ( m_ProjectileIsCocked )
		{
			CockProjectile();
		}
	}
	
	
	
	
	private final timer function Update( _dT:float , id : int):void
	{	
		var i					: int;
		var l_target			: CNode;
		var l_shootPos			: Vector;
		var l_vectToTarget 		: Vector;
		var l_angleToTarget 	: float;
		var l_targetPosition	: Vector;
		var l_currentPos		: Vector;
		var l_actorTarget		: CActor;
		
		
		
		for	( i = m_Targets.Size() - 1; i >= 0; i -= 1 )
		{
			l_actorTarget = (CActor) m_Targets[i];
			if( !l_actorTarget && (CComponent) m_Targets[i] )
			{
				l_actorTarget = (CActor) ((CComponent) m_Targets[i]).GetEntity();		
			}
			if( l_actorTarget && !l_actorTarget.IsAlive() )
			{
				m_Targets.EraseFast( i );
			}
		}
		if( m_ShotsLeft == 0 || m_Targets.Size() == 0)
		{
			Deactivate();
			return;
		}		
		
		if( m_DelayToNextSorting <= 0 )
		{
			SortNodesByDistance( GetWorldPosition(), m_Targets );
			m_DelayToNextSorting = 2;
		}
		
		m_DelayToNextSorting -= _dT;
		
		l_target = m_Targets[0];		
		
		
		l_targetPosition 	= l_target.GetWorldPosition();
		l_currentPos 		= GetWorldPosition();
		l_targetPosition.Z 	= l_currentPos.Z;		
		l_vectToTarget 		= l_targetPosition - GetWorldPosition();		
		l_angleToTarget 	= VecGetAngleBetween( GetHeadingVector(), l_vectToTarget );
		
		
		if(!m_IsStatic)
		{			
			if ( l_angleToTarget > m_RotationSpeed * _dT )
			{
				RotateTowardsTarget( _dT );
			}
		}
		
		if ( l_angleToTarget <= m_MinAngleToStartShooting )
		{
			if ( m_ShotsLeft != 0 )
			{
				ShootProjectile( _dT );
			}
		}
		
		
		if ( m_ProjectileIsCocked && m_DelayUntilNextProjectile > 0 && m_DelayUntilNextProjectile < m_FireRate * 0.5f )
		{
			CockProjectile();
		}
		
		if( m_CockedProjectile ) 
		{
			m_CockedProjectile.TeleportWithRotation( GetShootingPosition(), GetWorldRotation() ) ;
		}
	}
	
	
	private function RotateTowardsTarget( _dT:float ):void
	{
		var l_currentPos		: Vector;
		var l_vectToTarget 		: Vector;
		var l_targetPosition	: Vector;
		var l_yawToTarget 		: float;
		var l_currentHeading	: Vector;
		var l_newHeading		: Vector;
		var l_headingAngle		: EulerAngles;
		var l_toTargetAngle		: EulerAngles;
		var l_headingYaw		: float;
		var l_toTargetYaw		: float;
		var l_newRotation		: EulerAngles;
		var l_targetEntity		: CEntity;
		var l_currentMatrix		: Matrix;
		var l_newMatrix			: Matrix;
		var l_rotationMatrix	: Matrix;
		
		l_targetEntity = ((CComponent) m_Targets[0]).GetEntity();
		
		
		if( m_TargetPositionPrediction > 0 && (CActor) l_targetEntity )
		{
			l_targetPosition 	= ((CActor) l_targetEntity).PredictWorldPosition( m_TargetPositionPrediction );
		}
		else
		{
			l_targetPosition 	= m_Targets[0].GetWorldPosition();
		}
		
		l_currentPos 		= GetWorldPosition();
		
		l_vectToTarget 		= l_targetPosition - GetWorldPosition();
		l_currentHeading	= GetHeadingVector();		
		
		l_headingAngle 		= VecToRotation( l_currentHeading   );
		l_toTargetAngle 	= VecToRotation( l_vectToTarget   );
		
		l_headingYaw		= l_headingAngle.Yaw;
		l_toTargetYaw		= l_toTargetAngle.Yaw;
		
		l_yawToTarget 		= AngleDistance( l_headingYaw, l_toTargetYaw );
		
		l_currentMatrix		= GetLocalToWorld();
		
		if( m_RotationSpeed < 0 || l_yawToTarget < m_RotationSpeed * _dT )
		{			
			l_rotationMatrix 	= MatrixBuiltRotation( EulerAngles( 0, - l_yawToTarget, 0 ) );
		}
		else
		{
			if( l_yawToTarget > 0 )
			{
				l_rotationMatrix 	= MatrixBuiltRotation( EulerAngles( 0, - m_RotationSpeed * _dT, 0 ) );
			}
			else
			{
				l_rotationMatrix 	= MatrixBuiltRotation( EulerAngles( 0, m_RotationSpeed * _dT , 0 ) );
			}
			
		}		
		
		l_newMatrix			= l_currentMatrix * l_rotationMatrix;		
		l_newRotation 		= MatrixGetRotation( l_newMatrix );
		
		if( l_yawToTarget != 0 )
		{
			TeleportWithRotation( l_currentPos, l_newRotation );
		}
		
	}
	
	
	public final function Activate( optional _Target: CNode ):void
	{
		super.Activate( _Target );
		
		if( m_FirstShootDelay > 0 )
		{
			m_DelayUntilNextProjectile = m_FirstShootDelay;
		}
	}
	
	
	private function GetShootingPosition() : Vector
	{
		

		var slotWorldPos : Vector;
		var slotMatrix : Matrix;
		
		if (CalcEntitySlotMatrix( 'projectile_origin', slotMatrix ))
		{
			slotWorldPos = MatrixGetTranslation( slotMatrix );
		}
		else
		{
			LogAssert(false, "Trap" + this + " has no projectile_origin slot. Setting projectiel to trap's local 0.0.0");
			slotWorldPos = Vector(0,0,0);
		}
		
		return slotWorldPos;
	}
	
	
	private function CockProjectile()
	{
		var l_shootPos			: Vector;
		
		if ( m_CockedProjectile ) return;
		
		l_shootPos = GetShootingPosition();
		m_CockedProjectile = (W3AdvancedProjectile) theGame.CreateEntity( m_Projectile, l_shootPos, GetWorldRotation() );
	}
	
	
	private function ShootProjectile( _dT:float ) : void
	{	
		var l_trapPos, l_targetEntityPos		: Vector;
		var l_targetPosition, l_chestPosition	: Vector;
		var l_movingAgent						: CMovingPhysicalAgentComponent;
		var l_targetHeight						: float;
		var l_toTarget, l_trapForward			: Vector;
		var l_trapRight							: Vector;
		var l_toTargetAngle, l_trapAngle		: EulerAngles;
		var l_toTargetPitch, l_trapForwardPitch	: float;
		var l_pitchToTarget						: float;
		var l_pitchedForward					: Vector;
		var l_targetEntity						: CEntity;
		var l_targetIsHigher					: bool;
		
		m_DelayUntilNextProjectile -= _dT;
		
		if( m_DelayUntilNextProjectile > 0 ) return;
		
		CockProjectile();
		m_CockedProjectile.Init(this);
		
		l_targetPosition = GetShootingPosition() + ( GetHeadingVector() * 20 );
		
		if( m_MaxAimingPitchCorrection > 0 )
		{
			l_targetEntity 		= ((CComponent) m_Targets[0]).GetEntity();
			l_trapPos		 	= GetWorldPosition();	
			
			l_movingAgent = (CMovingPhysicalAgentComponent) ((CActor) l_targetEntity).GetMovingAgentComponent();
			if( l_movingAgent )
			{
				l_targetHeight 	= l_movingAgent.GetCapsuleHeight();
			}				
			l_chestPosition 	= l_targetEntity.GetWorldPosition() + Vector( 0, 0, l_targetHeight * 0.7f ) ;
			l_targetEntityPos 	= l_chestPosition;
				
			l_toTarget 			= l_targetEntityPos - l_trapPos;
			l_trapForward 		= GetWorldForward();
				
			l_trapAngle 		= VecToRotation( l_trapForward );
			l_toTargetAngle 	= VecToRotation( l_toTarget   );
				
			l_trapForwardPitch 	= l_trapAngle.Pitch;
			l_toTargetPitch 	= l_toTargetAngle.Pitch;
			
			
			
			l_pitchToTarget = AngleDistance( l_trapForwardPitch, l_toTargetPitch );
			l_targetIsHigher = l_pitchToTarget > 0;
			
			
			if( AbsF( l_pitchToTarget ) >  m_MaxAimingPitchCorrection )
			{
				l_pitchToTarget = m_MaxAimingPitchCorrection;
			}
			
			l_trapRight 	 = GetWorldRight();
			if( l_targetIsHigher )
			{
				l_pitchedForward = VecRotateAxis( l_trapForward, l_trapRight , Deg2Rad( AbsF( l_pitchToTarget ) ) );
			}
			else
			{
				l_pitchedForward = VecRotateAxis( l_trapForward, l_trapRight , Deg2Rad( 360 - AbsF( l_pitchToTarget ) ) );
			}
			
			l_targetPosition = GetShootingPosition() + (l_pitchedForward * 20);
			
			
		}
		
		if( m_ProjectileFollowTarget )
		{
			m_CockedProjectile.ShootProjectileAtNode( 0, m_ProjectileSpeed, m_Targets[0] );
		}
		else
		{
			m_CockedProjectile.ShootProjectileAtPosition( 0, m_ProjectileSpeed, l_targetPosition );
		}
		if( m_ProjectileLifeSpan > 0 )
		{
			m_CockedProjectile.SetLifeSpan( m_ProjectileLifeSpan ) ;
		}
		
		m_CockedProjectile = NULL;
		
		m_DelayUntilNextProjectile = m_FireRate;
		if ( m_ShotsLeft > 0 )
		{
			m_ShotsLeft -= 1;
		}
		
	}
	
}