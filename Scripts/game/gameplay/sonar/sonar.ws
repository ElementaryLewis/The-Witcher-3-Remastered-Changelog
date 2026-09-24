/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SonarEnttity extends CEntity
{
	var scaleVector					 : Vector;
	var sonarScaleRate		 		 : float;
	editable var effectDuration		 : float;
	editable var speedModifier		 : float; default speedModifier = 15.0f;
	editable var stopHighlightAfter  : float;
	
	private autobind sonarComponent : CComponent = "sonar";
	
	default effectDuration = 2.0f;
	default sonarScaleRate = 1.0f;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		AddTimer( 'ScaleSonarFX', 0.01f, true );
		AddTimer( 'DestroySonarFX', effectDuration, false );
		PlayEffect( 'fx_sonar' );
	}
	
	function HighlightObjects( range : float, optional time : float )
	{
		var object 		: CGameplayEntity;
		var allObjects	: array< CNode >;
		var dist		: float;
		var i 			: int;
		var pos 		: Vector;

		theGame.GetNodesByTag( 'HighlightedBySonarFX', allObjects );
		if(time == 0)
			time = 5;
		
		pos = GetWorldPosition();
		for ( i=0; i<allObjects.Size(); i+=1 )
		{
			object = (CGameplayEntity) allObjects[i];
			if(!object)
				continue;
				
			dist = VecDistance( pos, object.GetWorldPosition() );
			if ( dist < range )
			{
				object.PlayEffectSingle( 'fx_sonar_detection' );
				object.AddTimer( 'SonarEffectOff', time, false );
			}
		}
	}
	
	timer function DestroySonarFX( deltaTime : float , id : int)
	{
		RemoveTimer( 'ScaleSonarFX' );
		Destroy();
	}
	
	timer function ScaleSonarFX( deltaTime : float , id : int)
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		sonarScaleRate += speedModifier * deltaTime;
		scaleVector.X = sonarScaleRate;
		scaleVector.Y = sonarScaleRate;
		scaleVector.Z = sonarScaleRate;
		
		if( sonarComponent )
		{
			sonarComponent.SetScale( scaleVector );
		}
		
		HighlightObjects( sonarScaleRate, stopHighlightAfter );
	}
}