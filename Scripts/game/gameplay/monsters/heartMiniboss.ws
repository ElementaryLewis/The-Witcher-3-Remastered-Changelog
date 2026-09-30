/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class CHeartMiniboss extends CNewNPC
{
	var phasesCount : int;
	var currentPhase : int;
	var essenceChunks : int;
	var essenceChunkValue : float;
	var canHit : bool;
	var valuesInitialised : bool;
	editable var factSetAfterDeath : string;
	editable var factSetInOpenedPhase : string;
	editable var factSetInArmoredPhase : string;
	
	default phasesCount = 2;
	default currentPhase = 1;
	default canHit = false;
	default valuesInitialised = false;
	default autoState = 'Idle';
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		
		
		((CMovingPhysicalAgentComponent)GetMovingAgentComponent()).SetAnimatedMovement( true );
		EnableCollisions(false);
		EnablePhysicalMovement( false );
		
		essenceChunks = phasesCount * 2;
		SetAppearance( 'heart_dying_morph' );
		
		if( IsAlive() )
			GotoStateAuto();
		else
			GotoState( 'Dead' );
	}
	
	event OnTakeDamage( action : W3DamageAction )
	{
		
		
			
		if( action.attacker != thePlayer || !action.DealsAnyDamage() ) 
		{
			return false;
		}
		
		if( !canHit && action.GetSignSkill() != S_Magic_s02 )
			PlayEffect( 'wood_hit' );
		
		if( GetCurrentStateName() == 'FullyCovered' && canHit )
		{
			canHit = false;
			if(action.GetSignSkill() != S_Magic_s02)
				PlayEffect( 'wood_hit' );
			GotoState( 'FourRoots' );
		}
		else if( GetCurrentStateName() == 'FourRoots' && canHit )
		{
			canHit = false;
			if(action.GetSignSkill() != S_Magic_s02)
				PlayEffect( 'wood_hit' );
			GotoState( 'TwoRoots' );
		}
		else if( GetCurrentStateName() == 'TwoRoots' && canHit )
		{
			canHit = false;
			if(action.GetSignSkill() != S_Magic_s02)
				PlayEffect( 'wood_hit' );
			GotoState( 'NoRoots' );
			FactsAdd( factSetInOpenedPhase, 1 );
		}
		else if( GetCurrentStateName() == 'NoRoots' && canHit )
		{
			canHit = false;
			PlayEffect( 'heart_hit' );
			essenceChunkValue = this.GetStat( BCS_Essence ) / essenceChunks;
			GotoState( 'HeartHitOnce' );
		}
		else if( GetCurrentStateName() == 'HeartHitOnce' && canHit )
		{
			canHit = false;
			PlayEffect( 'heart_hit' );
			essenceChunkValue = this.GetStat( BCS_Essence ) / essenceChunks;
			DrainEssence( essenceChunkValue );
			essenceChunks -= 1;
			
			if( currentPhase == phasesCount || !this.IsAlive() || this.GetStat( BCS_Essence ) <= essenceChunkValue )
			{
				GotoState( 'Dead' );
				OnDeath( action );
			}
			else 
			{
				currentPhase += 1;
				SetBehaviorVariable( 'stage', 4.0 );
				GotoState( 'FullyCovered' );
				FactsAdd( factSetInArmoredPhase, 1 );	
			}
		}
	}
	
	event OnBehaviorNodeActivation()
	{
		canHit = true;
	}
	
	event OnDeathAnimFinished()
	{
		SetAlive( false );
	}
}

state Idle in CHeartMiniboss
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
	}
	
	entry function SleepIdle()
	{	
		parent.LockEntryFunction( true );
		Sleep( 0.5 );
		parent.LockEntryFunction( false );
		StartCombat();
	}
	
	entry function StartCombat()
	{
		parent.GotoState( 'FullyCovered' );
	}
}

state FullyCovered in CHeartMiniboss
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.SetBehaviorVariable( 'combatStart', 1.0 );
		parent.PlayEffect( 'heart_shield' );
		
		thePlayer.OnCanFindPath( parent );
		thePlayer.OnBecomeAwareAndCanAttack( parent );
		thePlayer.EnableSnapToNavMesh( 'TreeHeartFight', true );
	}
}

state FourRoots in CHeartMiniboss
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.SetBehaviorVariable( 'stage', 1.0 );
	}
}

state TwoRoots in CHeartMiniboss
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.SetBehaviorVariable( 'stage', 2.0 );
	}
}

state NoRoots in CHeartMiniboss
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.SetBehaviorVariable( 'stage', 3.0 );
		parent.StopEffect( 'heart_shield' );
	}
}

state HeartHitOnce in CHeartMiniboss
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.DrainEssence( parent.essenceChunkValue );
		parent.essenceChunks -= 1;
		parent.canHit = true;
	}	
}

state Dead in CHeartMiniboss
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.SetBehaviorVariable( 'dead', 1.0 );
		
		thePlayer.OnCannotFindPath( parent );
		thePlayer.OnBecomeUnawareOrCannotAttack( parent );
		thePlayer.EnableSnapToNavMesh( 'TreeHeartFight', false );
		
		parent.DrainEssence( 10000 );
		FactsAdd( parent.factSetAfterDeath, 1 );
	}
}
