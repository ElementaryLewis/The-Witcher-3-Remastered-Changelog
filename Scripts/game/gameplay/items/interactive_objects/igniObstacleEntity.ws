/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3IgniObstacleEntity extends CInteractiveEntity
{	
	var staticIgniObstacle 	: CComponent;
	var iceWallStage1 		: CDrawableComponent;
	var iceWallStage2 		: CDrawableComponent;
	var iceWallStage2Melted : CDrawableComponent;
	var iceWallStage3 		: CDrawableComponent;
	var iceWallStage3Melted : CDrawableComponent;
	
	default	autoState = 'CompleteWall';

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if ( !spawnData.restored )
		{
			GotoStateAuto();
		}
		Init();
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{			
	}
	
	function Init()
	{
		staticIgniObstacle = this.GetComponent( "StaticIgniObstacle" );
		iceWallStage1 = (CDrawableComponent)(this.GetComponent( "IceWallStage1" ));
		iceWallStage2 = (CDrawableComponent)(this.GetComponent( "IceWallStage2" ));
		iceWallStage2Melted = (CDrawableComponent)(this.GetComponent( "IceWallStage2Melted" ));
		iceWallStage3 = (CDrawableComponent)(this.GetComponent( "IceWallStage3" ));
		iceWallStage3Melted = (CDrawableComponent)(this.GetComponent( "IceWallStage3Melted" ));
	}
}

state CompleteWall in W3IgniObstacleEntity
{
	event OnStateEnter( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		parent.PlayEffect( 'fragment_melt_01' );
		parent.iceWallStage2.SetVisible( false );
		parent.iceWallStage2Melted.SetVisible( true );
		parent.PushState( 'FirstLevelDegradation' );
	}
}

state FirstLevelDegradation in W3IgniObstacleEntity
{
	event OnStateEnter( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}

	event OnIgniHit( sign : W3IgniProjectile )
	{
		parent.PlayEffect( 'fragment_melt_02' );
		parent.iceWallStage3.SetVisible( false );
		parent.iceWallStage3Melted.SetVisible( true );
		parent.PushState( 'SecondLevelDegradation' );
		parent.staticIgniObstacle.SetEnabled( false );
	}
}

state SecondLevelDegradation in W3IgniObstacleEntity
{	
	event OnStateEnter( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}

	event OnIgniHit( sign : W3IgniProjectile )
	{		
	}
}

