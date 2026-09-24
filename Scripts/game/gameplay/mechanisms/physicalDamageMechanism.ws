/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EPhysicalDamagemechanismOperation
{
	EPDM_Activate,
	EPDM_Deactivate,
}

class W3PhysicalDamageMechanism extends CGameplayEntity
{
	editable var dmgValue			: float; default dmgValue = 1000;
	editable var hitReactionType	: EHitReactionType; default hitReactionType = EHRT_Light;
	editable var reactivationTimer	: float; default reactivationTimer = -1.f;
	editable var animName			: name; default animName = '';
	editable var shouldRewind		: bool; default shouldRewind = false;
	private  var isActive 			: bool;
	private  var isMoving 			: bool;
	
	
	public function Activate()
	{
		isActive = true;
		isMoving = true;
	}
	
	public function Deactivate()
	{
		isActive = false;
		isMoving = false;
		RemoveTimer ('ReactivateTimer');
	}
	
	public function IsActive() : bool
	{
		return isActive;
	}
	
	event OnSpawned ( spawnData : SEntitySpawnData )
	{
		if ( reactivationTimer > 0 )
		{
			Activate();
			AddTimer('ReactivateTimer',reactivationTimer, false );
		}
	}
	event OnManageMechanism( operations : array< EPhysicalDamagemechanismOperation > )
	{
		var i, size : int;
		
		
		size = operations.Size();
		for ( i = 0; i < size; i += 1 )
		{
			switch ( operations[ i ] )
			{
			case EPDM_Activate:
				Activate();
				break;
			case EPDM_Deactivate:
				Deactivate();
				break;
			}
		}
		
	}
	
	event OnActorCollision( object : CObject, physicalActorindex : int, shapeIndex : int   )
	{
		var action : W3DamageAction;
		var victim : CActor;
		var  ent : CEntity;
		var component : CComponent;
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( ent != this )
		{
			if ( !isActive || !isMoving )
				return true;
			
			victim = (CActor)component.GetEntity();
			
			if ( victim )
			{
				action = new W3DamageAction in theGame.damageMgr;
				action.Initialize(this,victim,component,this.GetName(),hitReactionType,CPS_AttackPower,true,false,false,true);
				action.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, dmgValue );
				theGame.damageMgr.ProcessAction( action );
				
				delete action;
				isActive = false;
				AddTimer('ActivateTimer',1.0, false );
				LogAssert( false, "physicalDamageMechanism: I should be doing damage" );
			}
			return true;
		}	
	}
	
	event OnPropertyAnimationFinished( propertyName : name, animationName : name )
	{
		isMoving = false;
		
		if ( shouldRewind )
		{
			PlayPropertyAnimation( animName, 1,, PCM_Backward);	
		}
		
		if ( reactivationTimer > 0 )
		{
			AddTimer('ReactivateTimer',reactivationTimer, false );
		}
	}
	
	protected timer function ActivateTimer ( dt : float , id : int)
	{
		isActive = true;
	}
	protected timer function ReactivateTimer ( dt : float , id : int)
	{
		TriggerMechanism();
	}
	
	private function TriggerMechanism ()
	{
		Activate();
		PlayPropertyAnimation( animName, 1);	
	}
}