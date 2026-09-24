/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskArachasPull extends CBTTask3StateProjectileAttack
{
	var finishAttack 		: bool;
	
	private var m_projectilesShot		: int;	
	private var m_projectilesMissed 	: int;
	
	default finishAttack = false;
	
	latent function Loop() : int
	{
		var endTime : float;
		var target 	: CActor;
		target = GetCombatTarget();
		
		endTime = GetLocalTime() + loopTime;
		
		while(!finishAttack && GetLocalTime() <= endTime && VecDistance( target.GetWorldPosition(), GetNPC().GetWorldPosition() ) > 2.5f )
		{
			SleepOneFrame();
		}
		return 0;
	}

	function OnDeactivate()
	{
		finishAttack = false;
		m_projectilesMissed = 0;
		
		StopProjectilesEffect();
		
		super.OnDeactivate();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'ShootProjectile' )
		{
			m_projectilesShot = 1;
		}
		else if ( animEventName == 'Shoot3Projectiles' )
		{
			m_projectilesShot = 3;
		}
		else if ( animEventName == 'Shoot5Projectiles' )
		{
			m_projectilesShot = 5;
		}
		
		return super.OnAnimEvent(animEventName,animEventType, animInfo);
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{	
		if ( eventName == 'SlideFinish' )
		{
			finishAttack = true;
			StopProjectilesEffect();
			return true;
		}
		if ( eventName == 'ProjectileMissed' )
		{
			m_projectilesMissed += 1;
			if ( m_projectilesMissed == m_projectilesShot )
			{
				finishAttack = true;
			}
			return true;
		}
		
		return super.OnGameplayEvent(eventName);
	}	
	
	function StopProjectilesEffect():void
	{
		var i : int;
		var target : CActor;
		target = (CActor) GetCombatTarget();
		
		GetActor().StopEffect('spider_web');
		
		
		target.RemoveBuff( EET_Pull, true );
		
		projectiles.Clear();
	}
}

class CBTTaskArachasPullDef extends CBTTask3StateProjectileAttackDef
{
	default instanceClass = 'CBTTaskArachasPull';
}