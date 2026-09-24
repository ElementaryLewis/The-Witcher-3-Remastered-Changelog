/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3CollectiblePlaces extends CGameplayEntity
{
	editable var xpPoints 	: int;
	saved var wasDiscovered : bool;
	var allTags : array< name >;
	
	default wasDiscovered = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( wasDiscovered || GetCollectibleInstanceTag() == "" )
		{
			GetComponent( "CollectibleInteraction" ).SetEnabled( false );
			GetComponent( "Medallion" ).SetEnabled( false );
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if( !FactsDoesExist( GetCollectibleInstanceTag() ) )
		{
			if( actionName == "Use" && activator == (CEntity)thePlayer )
			{
				PlayEffect( 'select_fx', this );
				GetWitcherPlayer().AddPoints( EExperiencePoint, xpPoints, true );
				FactsAdd( GetCollectibleInstanceTag(), 1 );
				FactsAdd( "collected_power_place", 1 );
				LogChannel( 'Collectible_debug', GetCollectibleInstanceTag()+" was added. Facts sum = "+FactsQuerySum( "collected_power_place" ) );
				GetComponent( "CollectibleInteraction" ).SetEnabled( false );
				GetComponent( "Medallion" ).SetEnabled( false );
				wasDiscovered = true;
			}
		}
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if( interactionComponentName == "Medallion" && activator == (CEntity)thePlayer )
		{
			GetWitcherPlayer().GetMedallion().Activate( true, 5.0f );
		}
	}
	
	function GetCollectibleInstanceTag() : string
	{
		var i : int;
		var factToAdd : string;
		
		allTags = this.GetTags();
		
		if( allTags.Size() == 0 || allTags.Size() > 1 )
		{
			return "";
		}
		else
		{
			for( i = 0; i < allTags.Size(); i += 1 )
			{
				factToAdd = NameToString( allTags[i] );
				return factToAdd;
			}
		}
	}
}
