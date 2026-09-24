/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSpawnMultipleProjectilesAttack extends CBTTaskSpawnMultipleEntitiesAttack
{
	
	
	
	var projectileAngle				: float;
	var projectileAngleRandomness	: float;
	var projectileSpeed				: float;
	var projectileSpeedRandomness	: float;
	var dodgeable					: bool;
	
	
	
	
	
	
	function CreateEntity( _SpawnPos : Vector, _Rotation : EulerAngles ) : CEntity
	{
		var l_target 				: CActor = GetCombatTarget();
		var l_projectile 			: W3AdvancedProjectile;
		var l_angle 				: float;
		var l_velocity 				: float;
		var l_distanceToTarget		: float;
		var l_projectileFlightTime 	: float;
		var l_targetPos 			: Vector;
		
		l_angle = 0;
		l_targetPos = GetCombatTarget().GetWorldPosition();
		
		l_velocity 	= projectileSpeed + RandRangeF( projectileSpeedRandomness ) ;
		l_angle 	= projectileAngle + RandRangeF( projectileAngleRandomness ) ;
		
		l_projectile = (W3AdvancedProjectile) super.CreateEntity( _SpawnPos, _Rotation);
		
		if ( l_projectile )
		{
			l_projectile.ShootProjectileAtPosition ( projectileAngle, l_velocity, l_targetPos );
		}
		
		if ( dodgeable )
		{
			l_distanceToTarget = VecDistance( GetNPC().GetWorldPosition(), l_target.GetWorldPosition() );		
			
			
			l_projectileFlightTime = l_distanceToTarget / l_velocity;
			l_target.SignalGameplayEventParamFloat('Time2DodgeProjectile', l_projectileFlightTime );
		}
		
		return l_projectile;
	}
}
class CBTTaskSpawnMultipleProjectilesAttackDef extends CBTTaskSpawnMultipleEntitiesAttackDef
{
	default instanceClass = 'CBTTaskSpawnMultipleProjectilesAttack';
	
	
	
	editable var projectileAngle				: float;
	editable var projectileAngleRandomness		: float;
	editable var projectileSpeed				: float;
	editable var projectileSpeedRandomness		: float;
	editable var dodgeable						: bool;
	
	default projectileSpeed = 1;
	
	hint projectileAngleRandomness = "Random value to add to projectiles angle";
	hint projectileSpeedRandomness = "Random value to add to projectiles speed";
}