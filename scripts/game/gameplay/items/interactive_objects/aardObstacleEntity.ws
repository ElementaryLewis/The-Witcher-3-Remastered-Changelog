/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3AardObstacle extends CInteractiveEntity
{		
	default autoState = 'NewWall';

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if ( !spawnData.restored )
		{
			GotoStateAuto();
		}
		
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		super.OnAardHit( sign );
	}
}

state NewWall in W3AardObstacle
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		parent.RaiseEvent( 'hit' );
		parent.PushState( 'WallStageOne' );
	}
}

state WallStageOne in W3AardObstacle
{
	event OnStateEnter( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		parent.RaiseEvent( 'hit' );
		parent.GetComponent( "AardObstacleStatic" ).SetEnabled( false );
		parent.PushState( 'WallStageTwo' );
	}
}

state WallStageTwo in W3AardObstacle
{
	event OnStateEnter( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		parent.RaiseEvent( 'hit' );
		parent.PushState( 'WallStageThree' );
	}
}

state WallStageThree in W3AardObstacle
{
	event OnStateEnter( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
	}
}