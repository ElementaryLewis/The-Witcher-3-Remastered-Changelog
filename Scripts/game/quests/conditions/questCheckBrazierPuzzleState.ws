/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_CheckBrazierPuzzleState extends CQuestScriptedCondition
{
	editable var lightList 		: array<name>;
	editable var lightsToTurnOn : array<int>;

	var componentList 	: array<CComponent>;
	var expectedState  	: array<bool>;

	var componentsFound : bool;
	var statesDefined	: bool;


	function Activate()
	{	
		componentsFound = false;
		statesDefined	= false;
		
		expectedState.Resize(lightList.Size());
	}

	
	function Evaluate() : bool
	{
		var entity 			: CEntity;
		var component 		: CComponent;
		var lightState  	: bool;
		var checksPassed 	: int = 0;

		var i : int;
		var j : int;
			

		
		if ( !componentsFound )
		{
			for (i = 0; i < lightList.Size(); i+=1)
			{
				entity = theGame.GetEntityByTag(lightList[i]);
				if ( !entity )
					return false;
				
				component = entity.GetComponentByClassName('CGameplayLightComponent');
				if ( !component )
					return false;

				componentList.PushBack( component );
			}
			
			
			componentsFound = true;
		}

		
		if ( !statesDefined )
		{
			for (i = 0; i < lightList.Size(); i+=1)
			{
				for (j = 0; j < lightsToTurnOn.Size(); j+=1)
				{
					if (i == lightsToTurnOn[j])
					{
						expectedState[i] = true;
						break;
					}
					else
						expectedState[i] = false;
				}
			}

			
			statesDefined = true;
		}

		
		for (i = 0; i < componentList.Size(); i+=1)
		{		
			lightState = ((CGameplayLightComponent)componentList[i]).IsLightOn();

			if (lightState == expectedState[i])
				checksPassed+=1;
		}

		if (checksPassed == lightList.Size())
			return true;

		return false;
	}
}
