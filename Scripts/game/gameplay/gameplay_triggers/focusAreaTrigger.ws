/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3FocusAreaTrigger extends CGameplayEntity
{

	private const var rumbleIntensityModifier : float;
	private var isDisabled : bool; default isDisabled = false;
	default rumbleIntensityModifier = 1.0;

	editable saved var intensity 	: float;
	saved var isActive				: bool;
	default isActive				= false;
	
	editable var linkedClues : array < EntityHandle >;
	editable var linkedCluesTags : array < name >;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		
	}

	event OnAreaActivated( area : CTriggerAreaComponent, activated : bool )
	{
		
	}
	
	public function Disable()
	{
		isDisabled = true;
		ChangeFocusAreaIntensity ( 0.0f );
		
	}
	
	public function Enable()
	{
		isDisabled = false;
	}
	
	
	public function ChangeFocusAreaIntensity ( newIntensity : float )
	{
		
	}	
	
	
	private function SetupClueConnections()
	{
		var i : int;
		var k : int;
		var count : int;
		var linkedClueSize : int = linkedClues.Size();
		var ent : CEntity;
		var clue : W3MonsterClue;
		var clueEntities : array<CEntity>;
		
		for ( i = 0; i < linkedClueSize; i += 1 )
		{
			ent = EntityHandleGet( linkedClues[i] );
			clue = (W3MonsterClue) ent;
			
			if( clue )
			{
				clue.linkedFocusArea = this;
				count += 1;
				LogQuest( "Focus Area: linked clue added correctly");	
			}
			
		}
		
		for ( i=0; i <linkedCluesTags.Size(); i+= 1 )
		{
			theGame.GetEntitiesByTag( linkedCluesTags[i], clueEntities );
			
			for ( k=0; k <clueEntities.Size(); k+= 1 )
			{
				clue = (W3MonsterClue)clueEntities[i];
				
				if( clue )
				{
					clue.linkedFocusArea = this;
					count += 1;
					LogQuest( "Focus Area: linked clue added correctly");	
				}
			}
		}
		LogQuest( "Focus Area: Connections processed: "+IntToString(i));
	}
	
	
	
	public function SmartFocusAreaCheck ()
	{
		var i : int;
		var k : int;
		var linkedClueSize : int = linkedClues.Size();
		var ent : CEntity;
		var clue : W3MonsterClue;
		var shouldBeActive : bool = false;
		var clueEntities : array<CEntity>;
		
		
		for ( i = 0; i < linkedClueSize; i += 1 )
		{
			ent = EntityHandleGet( linkedClues[i] );
			clue = (W3MonsterClue) ent;
			
			if( clue )
			{
				if( clue.wasDetected == false )
				{
					shouldBeActive =  true;
				}
				
			}
			
		}		
		
		for ( i=0; i <linkedCluesTags.Size(); i+= 1 )
		{
			theGame.GetEntitiesByTag( linkedCluesTags[i], clueEntities );
			
			for ( k=0; k <clueEntities.Size(); k+= 1 )
			{
				clue = (W3MonsterClue)clueEntities[i];
				
				if( clue )
				{
					if( clue.wasDetected == false )
					{
						shouldBeActive =  true;
					}	
				}
			}
		}
		
		if( shouldBeActive == true )
		{
			if( intensity > 1.0 )
			{
				this.ChangeFocusAreaIntensity( intensity - 1.0 );
				LogQuest( "Focus Area: Smart clue changed intensity to: "+FloatToString(intensity));	
			}
			else
			{
			LogQuest( "Focus Area: Intensity already at 1, no change due to smart clue" );
			}
		}
		else
		{
			this.ChangeFocusAreaIntensity( 0.0 );
			LogQuest( "Focus Area: Smart clue changed intensity to: "+FloatToString(intensity));	
		}
		
	}
	
}