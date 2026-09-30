/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4RyanAlchemyMenu extends CR4Menu
{	
	
	
	
	private const var KEY_RECIPE_LIST			:string; 		default KEY_RECIPE_LIST 		= "RecipeList";
	
	private var m_flashValueStorage : CScriptedFlashValueStorage;
	private var m_alchemyManager	: W3AlchemyManager;
	private var m_inventory			: CInventoryComponent;
	private var m_recipeList		: array< SAlchemyRecipe >;
	
	
	
	event  OnConfigUI()
	{	
		m_flashValueStorage = GetMenuFlashValueStorage();
		
		m_inventory 	 = thePlayer.inv;
		
		PopulateData();
	}
	
	
	event OnCloseMenu()
	{
		CloseMenu();
	}
	
	
	event OnBrew( _RecipeIndex : int )
	{
		var l_recipe			: SAlchemyRecipe;		
		l_recipe  = m_recipeList[ _RecipeIndex ];		
		
		if( m_alchemyManager.CanCookRecipe( l_recipe.recipeName ) == EAE_NoException )
		{
			m_alchemyManager.CookItem( l_recipe.recipeName );
		}
		
		PopulateData();
	}
	
	
	private function PopulateData() : void
	{
		var	i 						: int;
		
		var l_recipeFlashArray		: CScriptedFlashArray;
		var l_recipeDataFlashObject : CScriptedFlashObject;
		
		var l_recipeName			: string;
		var l_recipeCanBeBrewed		: bool;
		
		m_alchemyManager 	= new W3AlchemyManager in this;
		m_alchemyManager.Init();		
		m_recipeList 		= m_alchemyManager.GetRecipes(false);
		
		l_recipeFlashArray = m_flashValueStorage.CreateTempFlashArray();
		for( i = 0; i < m_recipeList.Size(); i += 1 )
		{
		
			l_recipeName			= m_recipeList[i].recipeName;
			l_recipeCanBeBrewed		= ( m_alchemyManager.CanCookRecipe(  m_recipeList[i].recipeName ) == EAE_NoException );
			
			l_recipeDataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			
			l_recipeDataFlashObject.SetMemberFlashString( "label", l_recipeName );
			l_recipeDataFlashObject.SetMemberFlashBool	( "canBeBrewed", l_recipeCanBeBrewed );
			
			l_recipeFlashArray.SetElementFlashObject( i, l_recipeDataFlashObject );
		}
		
		m_flashValueStorage.SetFlashArray( KEY_RECIPE_LIST, l_recipeFlashArray );
	}	
}