/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class CProjectileTrajectory extends CGameplayEntity
{
	import var caster 					: CEntity;
	import var projectileName 			: name;
	import var radius 					: float;
	import var bounceOfVelocityPreserve : float;
	import var doWaterLevelTest			: bool;
	
	protected editable var alarmRadius	: float;
	
	public var victim	 				: CGameplayEntity;
	public var yrdenAlternate			: W3YrdenEntity;
	
	default alarmRadius = 15;
	
	
	import final function Init( caster : CEntity );
	
	
	import function ShootProjectileAtPosition( angle : float, velocity : float, target : Vector, optional range : float, optional collisionGroups : array<name> );
	
	
	import function ShootProjectileAtNode( angle : float, velocity : float, target : CNode, optional range : float, optional collisionGroups : array<name> );
	
	
	import function ShootProjectileAtBone( angle : float, velocity : float, target : CEntity, targetBone : name, optional range : float, optional collisionGroups : array<name> );
	
	
	import function ShootCakeProjectileAtPosition( cakeAngle : float, cakeHeight : float, shootAngle : float, velocity : float, target : Vector, range : float, optional collisionGroups : array<name> );
	
	
	import final function BounceOff( collisionNormal : Vector, colliisonPosition : Vector );
	
	
	import final function IsBehindWall( testComponent : CComponent, optional collisionGroupsNames : array<name> ) : bool;
	
	
	import final function StopProjectile();
	
	
	import final function IsStopped() : bool;
	
	
	import final function SphereOverlapTest( radius : float, optional collisionGroups : array<name> );
	
	
	
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var beehive 		: CBeehiveEntity;
		
		theGame.GetBehTreeReactionManager().CreateReactionEventCustomCenter( caster, 'Danger', 30, alarmRadius, 2, -1, true, true, pos );
		
		
		
		if(collidingComponent)
		{
			beehive = (CBeehiveEntity)(collidingComponent.GetEntity());
			if(beehive && ((CThrowable)this) )
				beehive.OnShotByProjectile();
			
			victim = (CGameplayEntity)collidingComponent.GetEntity();
			
			ProcessProjectileRepulsion( pos, normal );
		}
	}
	
	public function ProcessProjectileRepulsion( pos, normal : Vector ) : bool
	{
		
		if ( victim.HasAbility( 'RepulseProjectiles' ) )
		{
			this.Init( victim );
			bounceOfVelocityPreserve = 0.8;
			BounceOff( normal, pos );
			((CActor)victim).SignalGameplayEvent( 'RepulsedProjectile' );
			return true;
		}
		
		return false;
	}
	
	public function SetVictim( entity : CGameplayEntity )
	{
		victim = entity;
	}
	
	
	event OnRangeReached();
	
	public final function SetIsInYrdenAlternateRange(yrden : W3YrdenEntity)
	{
		yrdenAlternate = yrden;
	}
	
	event OnProjectileShot( targetCurrentPosition : Vector, optional target : CNode )
	{
		var s : W3YrdenEntityStateYrdenShock;
		
		if(yrdenAlternate)
		{
			s = (W3YrdenEntityStateYrdenShock)yrdenAlternate.GetCurrentState();
			if(s)
				s.ShootDownProjectile(this);
		}
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		var rigidMesh : CMeshComponent;
		
		super.OnAardHit(sign);
		
		if( IsStopped() )
		{
			return false;
		}
		
		StopProjectile();
		
		rigidMesh = (CMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
		
		if ( rigidMesh )
		{
			rigidMesh.SetEnabled( true );
		}
		else
		{
			this.bounceOfVelocityPreserve = 0.7;
			this.BounceOff(VecRand2D(),this.GetWorldPosition());
			this.Init(thePlayer);
		}
	}
}
