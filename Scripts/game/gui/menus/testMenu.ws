/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4TestMenu extends CR4MenuBase
{
	private var entityTemplateIndex : int;			default entityTemplateIndex = 0;
	private var appearanceIndex : int;				default appearanceIndex = 0;
	private var environmentDefinitionIndex : int;	default environmentDefinitionIndex = 0;
	private var entityTemplates : array< string >;
	private var appearances : array< name >;
	private var environmentDefinitions : array< string >;
	
	private var sunRotation : EulerAngles;

	event  OnConfigUI()
	{
		super.OnConfigUI();
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		
		entityTemplates.PushBack( "characters\player_entities\geralt\geralt_player.w2ent" );
		entityTemplates.PushBack( "characters\player_entities\ciri\ciri_player.w2ent" );
		entityTemplates.PushBack( "characters\npc_entities\animals\horse\player_horse.w2ent");	

		appearances.PushBack( 'ciri_player' );
		appearances.PushBack( 'ciri_player_towel' );
		appearances.PushBack( 'ciri_player_naked' );
		appearances.PushBack( 'ciri_player_wounded' );

		environmentDefinitions.PushBack( "environment\definitions\gui_character_display\gui_character_environment.env" );
		
		theGame.GetGuiManager().SetBackgroundTexture( LoadResource( "inventory_background" ) );

		UpdateEntityTemplate();
		UpdateEnvironmentAndSunRotation();
		UpdateItems();
	}

	event  OnClosingMenu()
	{
		theInput.RestoreContext( 'EMPTY_CONTEXT', false );
	}
	
	event  OnCameraUpdate( lookAtX : float, lookAtY : float, lookAtZ : float, cameraYaw : float, cameraPitch : float, cameraDistance : float )
	{
		var lookAtPos : Vector;
		var cameraRotation : EulerAngles;
		var fov : float;
		
		fov = 35.0f;
		
		lookAtPos.X = lookAtX;
		lookAtPos.Y = lookAtY;
		lookAtPos.Z = lookAtZ;
		
		cameraRotation.Yaw = cameraYaw;
		cameraRotation.Pitch = cameraPitch;
		cameraRotation.Roll = 0;
		
		theGame.GetGuiManager().SetupSceneCamera( lookAtPos, cameraRotation, cameraDistance, fov );
	}
	
	event  OnSunUpdate( sunYaw : float, sunPitch : float )
	{
		sunRotation.Yaw = sunYaw;
		sunRotation.Pitch = sunPitch;
		UpdateEnvironmentAndSunRotation();
	}

	event  OnNextEntityTemplate()
	{
		entityTemplateIndex += 1;
		entityTemplateIndex = entityTemplateIndex % entityTemplates.Size();
		
		UpdateEntityTemplate();
		
		if( entityTemplateIndex == 0 )
		{
			UpdateItems();
		}
		
	}

	event  OnNextAppearance()
	{
		appearanceIndex += 1;
		appearanceIndex = appearanceIndex % appearances.Size();
		
		UpdateApperance();
	}

	event  OnNextEnvironmentDefinition()
	{
		environmentDefinitionIndex += 1;
		environmentDefinitionIndex = environmentDefinitionIndex % environmentDefinitions.Size();

		UpdateEnvironmentAndSunRotation();
	}

	event  OnCloseMenu()
	{
		CloseMenu();
	}
	
	event  OnCloseMenuTemp()
	{
		CloseMenu();
	}

	protected function UpdateEntityTemplate()
	{
		var template : CEntityTemplate;
		template = ( CEntityTemplate )LoadResource( entityTemplates[ entityTemplateIndex ], true );
		if ( template )
		{
			theGame.GetGuiManager().SetSceneEntityTemplate( template, 'locomotion_idle' );
			m_flashValueStorage.SetFlashString("test.entityTemplate", entityTemplates[ entityTemplateIndex ] );
		}
	}
	
	protected function UpdateApperance()
	{
		theGame.GetGuiManager().ApplyAppearanceToSceneEntity( appearances[ appearanceIndex ] );
	}
	
	protected function UpdateItems()
	{
		var inventory : CInventoryComponent;
		var enhancements : array< SGuiEnhancementInfo >;
		var info : SGuiEnhancementInfo;
		var enhancementNames : array< name >;
		var items : array< name >;
		var witcher : W3PlayerWitcher;
		var i, j : int;
		var itemsId : array< SItemUniqueId >;
		var itemId : SItemUniqueId;
		var itemName : name;

		inventory = thePlayer.GetInventory();
		if ( inventory )
		{
			inventory.GetHeldAndMountedItems( itemsId );
			
			witcher = (W3PlayerWitcher) thePlayer;
			if ( witcher )
			{
				witcher.GetMountableItems( itemsId );
			}
			
			for ( i = 0; i < itemsId.Size(); i += 1 )
			{
				itemId = itemsId[i];
				itemName = inventory.GetItemName( itemId );
				
				items.PushBack( itemName );
				
				inventory.GetItemEnhancementItems( itemId, enhancementNames );
				for ( j = 0; j < enhancementNames.Size(); j += 1 )
				{
					info.enhancedItem = itemName;
					info.enhancement = enhancementNames[j];
					enhancements.PushBack( info );
				}
			}
			
		}
	}

	protected function UpdateEnvironmentAndSunRotation()
	{
		var environment : CEnvironmentDefinition;
		environment = ( CEnvironmentDefinition )LoadResource( environmentDefinitions[ environmentDefinitionIndex ], true );
		if ( environment )
		{
			theGame.GetGuiManager().SetSceneEnvironmentAndSunPosition( environment, sunRotation );
			m_flashValueStorage.SetFlashString("test.environmentDefinition", environmentDefinitions[ environmentDefinitionIndex ] );
		}
	}

}

exec function testmenu()
{
	theGame.RequestMenu('TestMenu');
}

exec function testmenu_transform(x : float, y : float, z : float, scale : float)
{
	var position:Vector;
	var _scale:Vector;
	var rotation:EulerAngles;
	
	position.X = x;
	position.Y = y;
	position.Z = z;
	
	_scale.X = scale;
	_scale.Y = scale;
	_scale.Z = scale;
	
	theGame.GetGuiManager().SetEntityTransform(position, rotation, _scale);
}