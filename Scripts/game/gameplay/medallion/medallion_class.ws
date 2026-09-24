/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MedallionFX extends CEntity
{
	var scaleVector			: Vector;
	var medallionScaleRate	: float;
	var effectDuration		: float;
	
	private autobind medallionComponent : CComponent = "CMeshComponent medalion";
	
	default effectDuration = 1.0f;
	default medallionScaleRate = 1.0f;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		AddTimer( 'ScaleMedallion', 0.01f, true );
		AddTimer( 'DestroyMedallionFX', effectDuration, false );
	}
	
	function TriggerMedallionFX()
	{
		var rot				: EulerAngles;
		var pos 			: Vector;
		var spawnedEntity	: CEntity;
		var entityTemplate	: CEntityTemplate;

		entityTemplate = (CEntityTemplate)LoadResource('medallion_fx');		
		pos = thePlayer.GetWorldPosition();
		
		spawnedEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		spawnedEntity.PlayEffect( 'medalion_fx' );
	}
	
	timer function DestroyMedallionFX( deltaTime : float , id : int)
	{
		RemoveTimer( 'ScaleMedallion' );
		Destroy();
	}
	
	timer function ScaleMedallion( deltaTime : float , id : int)
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		medallionScaleRate += 15.0f * deltaTime;
		scaleVector.X = medallionScaleRate;
		scaleVector.Y = medallionScaleRate;
		scaleVector.Z = medallionScaleRate;
		
		if( medallionComponent )
		{
			medallionComponent.SetScale( scaleVector );
		}
		
		witcher.HighlightObjects( medallionScaleRate );
	}
}