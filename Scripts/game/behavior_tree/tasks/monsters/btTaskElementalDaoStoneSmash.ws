/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskElementalDaoStoneSmash extends CBTTaskAttack
{
	var stoneEntityTemplate : CEntityTemplate;
	
	var Stone1,Stone2 : CEntity;
	
	var execute : bool;
	
	var spawnDist : float;
	
	var dodgeable : bool;
	
	default spawnDist = 3.f;
	
	default execute = false;
	
	var targetPos : Vector;
	
	latent function Main() : EBTNodeStatus
	{
		var stonePos1, stonePos2 : Vector;
		var shootPos, tempHeading : Vector;
		var distanceToTarget, projectileFlightTime : float;
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		
		SleepOneFrame();
		stonePos1 = Stone1.GetWorldPosition();
		stonePos2 = Stone2.GetWorldPosition();
		stonePos1.Z += 1.5;
		stonePos2.Z += 1.5;
		Stone1.Teleport(stonePos1);
		Stone2.Teleport(stonePos2);
		while ( !execute )
		{
			SleepOneFrame();
		}
		
		
		shootPos = GetCombatTarget().GetWorldPosition();
		shootPos.Z += 1.5;
		tempHeading = GetNPC().GetWorldPosition() - shootPos;
		((CProjectileTrajectory)Stone1).ShootProjectileAtPosition(0,20, shootPos + VecFromHeading( VecHeading(tempHeading) - 90 ),30 );
		((CProjectileTrajectory)Stone2).ShootProjectileAtPosition(0,20, shootPos + VecFromHeading( VecHeading(tempHeading) + 90 ),30 );
		
		if ( dodgeable )
		{
			distanceToTarget = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );		
			
			
			projectileFlightTime = distanceToTarget / 20;
			target.SignalGameplayEventParamFloat('Time2DodgeProjectile', projectileFlightTime );
		}
		
		Stone1.DestroyAfter(6.f);
		Stone2.DestroyAfter(6.f);
		
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var target : CActor;
		var npc : CNewNPC;
		
		var stonePos1, stonePos2, tempHeading : Vector;
		
		if ( animEventName == 'Prepare' )
		{
			target = GetCombatTarget();
			npc = GetNPC();
			
			tempHeading = npc.GetWorldPosition() - target.GetWorldPosition();
			
			targetPos = npc.GetWorldPosition();
			stonePos1 = targetPos + spawnDist*VecFromHeading( VecHeading(tempHeading) - 90 );
			stonePos2 = targetPos + spawnDist*VecFromHeading( VecHeading(tempHeading) + 90 );
			stonePos1.Z += 1.5;
			stonePos2.Z += 1.5;
			
			
			Stone1 = theGame.CreateEntity( stoneEntityTemplate, stonePos1, EulerAngles(0,0,0) );
			Stone2 = theGame.CreateEntity( stoneEntityTemplate, stonePos2, EulerAngles(0,0,0) );
			
			((CProjectileTrajectory)Stone1).Init(npc);
			((CProjectileTrajectory)Stone2).Init(npc);
			
			Stone1.PlayEffect('appear');
			Stone2.PlayEffect('appear');
			
			RunMain();
			
			return true;
		}
		else if ( animEventName == 'Execute' || animEventName == 'Throw' )
		{
			execute = true;
			return true;
		}
		
		return false;
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
		execute = false;
	}
	
}

class CBTTaskElementalDaoStoneSmashDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskElementalDaoStoneSmash';

	editable var stoneEntityTemplate 	: CEntityTemplate;
	editable var dodgeable				: bool;
}

class CBTTaskElementalThrowFire extends CBTTaskAttack
{
	var projectileEntity : CEntityTemplate;
	
	var projectile : CProjectileTrajectory;
	
	var dodgeable : bool;
	
	var projectileShot : bool;
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var target : CActor;
		var npc : CNewNPC;
		var distanceToTarget : float;
		var projectileFlightTime : float;
		
		var spawnPos, targetPos : Vector;
		
		if ( animEventName == 'Prepare' )
		{
			projectileShot = false;
			npc = GetNPC();
			
			
			
			projectile = (CProjectileTrajectory)theGame.CreateEntity( projectileEntity, spawnPos, EulerAngles(0,0,0) );
			projectile.Init(npc);
			
			projectile.CreateAttachment(npc,'r_weapon');
			
			
			
			return true;
		}
		else if ( animEventName == 'Execute' || animEventName == 'Throw' )
		{
			targetPos = GetCombatTarget().GetWorldPosition();
			targetPos.Z += 0.2;
			projectile.BreakAttachment();
			projectile.ShootProjectileAtPosition(0,15,targetPos,40);
			projectileShot = true;
			
			if ( dodgeable )
			{
				npc = GetNPC();
				target = GetCombatTarget();
				distanceToTarget = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );		
				
				
				projectileFlightTime = distanceToTarget / 15;
				target.SignalGameplayEventParamFloat('Time2DodgeProjectile', projectileFlightTime );
			}
			
			return true;
		}
		
		return false;
	}
	
	function OnDeactivate()
	{
		if ( !projectileShot )
		{
			projectile.StopAllEffects();
			projectile.DestroyAfter(2.0);
		}
		super.OnDeactivate();
	}
	
}

class CBTTaskElementalThrowFireDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskElementalThrowFire';

	editable var projectileEntity : CEntityTemplate;
	editable var dodgeable : bool;
}