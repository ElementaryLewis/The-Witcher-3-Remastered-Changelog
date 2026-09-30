/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCaranthirMeteor extends CBTTaskProjectileAttack
{	
	var riftResourceName 					: name;
	var targetPos 							: Vector;
	
	
	protected function GetProjectileStartPosition() 	: Vector
	{
		var target 					: CActor = GetCombatTarget();
		var slotWorldPos 			: Vector;
		var npc						: CNewNPC = GetNPC();
		var npcToTargetVector		: Vector;
		var combatTargetPos 		: Vector;
		
		npcToTargetVector = combatTargetPos - npc.GetWorldPosition();
		combatTargetPos = combatTargetPos + 3*VecNormalize(npcToTargetVector);
		
		slotWorldPos = npc.GetWorldPosition();
		slotWorldPos.Z += 8;
		return slotWorldPos;
		
	}
	
	function CreateAndShootProjectile(optional customHeading : float, optional projectileIndex : int)
	{
		var npc 					: CNewNPC = GetNPC();
		var target 					: CActor = GetCombatTarget();
		var targetPos				: Vector;
		var combatTargetPos 		: Vector;
		var range 					: float;
		var distToTarget 			: float;
		var l_3DdistanceToTarget	: float;
		var l_projectileFlightTime	: float;
		var npcToTargetVector		: Vector;
		
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
		npcToTargetVector = npc.GetWorldPosition() - combatTargetPos;
		
		combatTargetPos = combatTargetPos + 3*VecNormalize(npcToTargetVector);
		
		((CActor)npc).GetVisualDebug().AddSphere( 'lineTestEnd', 0.15, npc.GetWorldPosition(), true, Color( 255, 0, 0 ), 1.0 );
		((CActor)npc).GetVisualDebug().AddArrow( 'lineTestLine', combatTargetPos, npc.GetWorldPosition(), 1, 0.3, 0.3, true, Color( 255, 0, 0 ), true, 1.0 );
		
		distToTarget = VecDistance( combatTargetPos, npc.GetWorldPosition() );
		range = attackRange;
		
		targetPos = combatTargetPos;
		
		projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, targetPos, range, collisionGroups );
		
		wasShot = true;
	}
	
	function Initialize()
	{
		super.Initialize();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if ( animEventName == 'ShootProjectile' || animEventName == 'Throw' )
		{
			CreateAndShootProjectile();
			return true;
		}
		
		return res;
	}
}

class CBTTaskCaranthirMeteorDef extends CBTTaskProjectileAttackDef
{
	default instanceClass = 'CBTTaskCaranthirMeteor';
}