/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3RisingTreeEntity extends CGameplayEntity
{
	private editable var maxHeightX : float;
	private editable var maxHeightY : float;
	private editable var maxHeightZ : float;
	private editable var maxDistance : float;
	private var isPlayerIn : bool;
	private var distance : float;
	private var disNormalized : float;
	private var heightToAddX : float;
	private var heightToAddY : float;
	private var heightToAddZ : float;
	var meshComponent : CStaticMeshComponent;
	private var newScale : Vector;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( activator.GetEntity() == thePlayer )
		{
			isPlayerIn = true;
			meshComponent = (CStaticMeshComponent)GetComponentByClassName( 'CStaticMeshComponent' );
			AddTimer('CalculateDistanceAndChangeHeight', 0.01f, true );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( activator.GetEntity() == thePlayer )
		{
			isPlayerIn = false;
		}
		newScale.X = 1.f;
		newScale.Y = 1.f;
		newScale.Z = 1.f;
		if ( meshComponent )
		{
			meshComponent.SetScale(newScale);
		}
		
	}
	
	timer function CalculateDistanceAndChangeHeight( td : float , id : int )
	{
		if( isPlayerIn )
		{
			distance = VecDistance( thePlayer.GetWorldPosition(), this.GetWorldPosition() );
			disNormalized = ( distance - 0.f ) / (maxDistance - 0.f );
			heightToAddX = LerpF( disNormalized, 1.f + maxHeightX, 1.f );
			heightToAddY = LerpF( disNormalized, 1.f + maxHeightY, 1.f );
			heightToAddZ = LerpF( disNormalized, 1.f + maxHeightZ, 1.f );
			if ( heightToAddX < 1.f )
				heightToAddX = 1.f;
			if ( heightToAddY < 1.f )
				heightToAddY = 1.f;
			if ( heightToAddZ < 1.f )
				heightToAddZ = 1.f;
			newScale.X = heightToAddX;
			newScale.Y = heightToAddY;
			newScale.Z = heightToAddZ;
			if ( meshComponent )
			{
				meshComponent.SetScale(newScale);
			}
		}
		else 
		{
			RemoveTimer('CalculateDistanceAndChangeHeight');
		}
		
	}
}