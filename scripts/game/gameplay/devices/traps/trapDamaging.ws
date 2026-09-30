/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3DamagingTrap extends W3Trap
{
    const var TRIGGER_AREA_COMP_NAME : string;
    default TRIGGER_AREA_COMP_NAME = "TriggerArea";

    private editable var startDisarmed : bool;
    private editable var damageValue : float;
	private editable var ignoreFlyingActors : bool;

    default damageValue = 1200.f;
    default interactionAnimTime				= 2.0f;
	default ignoreFlyingActors = true;

	private var ignoredActors : array<CActor>;
	private var ignoredActorsTimerActive: bool;

	hint 	ignoreFlyingActors			= "if true, flying actors wont trigger the trap unless they've been knocked out in the air";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
        if (!m_wasSprung || startDisarmed)
        {
            Arm(true);
            m_IsActive = true;
        }
        else
        {
            Arm(false);
            m_IsActive = false;
        }
		
		UpdateVisibility();
		StructFactsHack();
		UpdateInteraction();
	}

    function UpdateInteraction( optional comp : CComponent )
	{
		var areaComp : CComponent;
		var disarmComp : CComponent;
		
		disarmComp = GetComponent( DISARM_INTERACTION_COMPONENT_NAME );
        areaComp = GetComponent(TRIGGER_AREA_COMP_NAME);
		
		if ( this.GetWasDetected() && disarmComp && areaComp)
		{
			if ( m_isArmed )
			{
				disarmComp.SetEnabled( true );
                areaComp.SetEnabled( true );
				
			}
			else
			{
				disarmComp.SetEnabled( false );
                areaComp.SetEnabled( true );
				
			}
					
		}
	}

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var victim	: CActor;
		victim = (CActor) activator.GetEntity();
		
		if( victim && m_isArmed )
		{
			if (ignoreFlyingActors && victim.GetBehaviorVariable( 'npcStance' ) == (int)NS_Fly && !victim.HasBuff(EET_Knockdown))
			{
				AddActorToPeriodicCheck(victim);
				return false;
			}

            OnClueDetected();
			DealDamage(victim);
            Arm(false);
            m_wasSprung = true;
		}	
	}
	
	private function DealDamage( victim : CActor )
	{
		var action : W3DamageAction;
		
		action = new W3DamageAction in this;
		action.Initialize(this ,victim, this,this.GetName(),EHRT_Light,CPS_AttackPower,false,true,false,false);
		
		
		action.AddDamage( theGame.params.DAMAGE_NAME_PIERCING, damageValue ); 

		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;	
	}

	
	private function AddActorToPeriodicCheck(actor : CActor)
	{
		if (!ignoredActors.Contains(actor))
			ignoredActors.PushBack(actor);
		
		if (!ignoredActorsTimerActive)
		{
			ignoredActorsTimerActive = true;
			AddTimer('FlyingActorsCheck', 0.05f, true, , , true, true);
		}
	}

	private timer function FlyingActorsCheck( dt : float, optional id : int)
	{
		var i : int;
		var l_actor : CActor;

		if (ignoredActors.Size() == 0)
		{
			RemoveTimer('FlyingActorsCheck');
			ignoredActorsTimerActive = false;
			return;
		}

		for (i = 0; i < ignoredActors.Size(); i += 1)
		{
			l_actor = ignoredActors[i];

			if (!l_actor)
			{
				ignoredActors.Remove(l_actor);
				continue;
			}

			if (l_actor.GetBehaviorVariable( 'npcStance' ) != (int)NS_Fly || (l_actor.GetBehaviorVariable( 'npcStance' ) == (int)NS_Fly && l_actor.HasBuff(EET_Knockdown)))
			{
				ignoredActors.Clear();
				RemoveTimer('FlyingActorsCheck');
				ignoredActorsTimerActive = false;
				OnClueDetected();
				DealDamage(l_actor);
				Arm(false);
				m_wasSprung = true;
				return;
			}
		}
	}
}