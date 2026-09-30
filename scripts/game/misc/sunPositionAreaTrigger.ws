/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SunPositionAreaTriggers extends CGameplayEntity
{
	private editable var ExitHours : int;
	default ExitHours = 22;
	private editable var ExitMinutes : int;
	hint EntranceHours = "Time that you see from the Exit";
	private editable var EntranceHours : int;
	default EntranceHours = 11;
	hint EntranceHours = "Time that you see from the entrance";
	private editable var EntranceMinutes : int;	
	private var isPlayerIn : bool;
	private var crossedStartEntrance : bool;
	private var crossedEntrance : bool;
	default crossedEntrance = false;
	private var crossedExit : bool;
	default crossedExit = false;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		
		GameTimeCreate(1, ExitHours, ExitMinutes, 0 );
	
		if ( activator.GetEntity() == thePlayer )
		{
			
			isPlayerIn = true;
			
			AddTimer('CalculateDistanceAndChangeHeight', 0.01f, true );
			
			
			switch(area.GetName())
			{
				case "StartEntrance":
					theGame.SetGameTime(GameTimeCreate(1, EntranceHours, EntranceMinutes, 0 ), false);
					LogGalaxy( " I enter " );
					if(crossedExit)
					{
						LogGalaxy( " ResetValues " );
						Reset();
					}
					
				break;
				case "FinishEntrance":
					if(!crossedExit)
					{
						LogGalaxy( " I enter through entrance 2. " );
						
						theGame.SetGameTime(GameTimeCreate(1, ExitHours, ExitMinutes, 0 ), false);
						crossedEntrance = true;
					}
				break;
				
				case "ExitEntrance":
					LogGalaxy( " Start Exit " );
					if(!crossedEntrance)
					{
						LogGalaxy( " Exit 1 " );
						theGame.SetGameTime(GameTimeCreate(1, EntranceHours, EntranceMinutes, 0 ), false);
						crossedExit = true;
					}
				break;
				
				case "ExitExit":
					LogGalaxy( " I exit " );
					theGame.SetGameTime(GameTimeCreate(1, ExitHours, ExitMinutes, 0 ), false);
					if(crossedEntrance)
					{
						LogGalaxy( " ResetValues " );
						Reset();
					}
				break;
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( activator.GetEntity() == thePlayer )
		{
			switch(area.GetName())
			{
				case "StartEntrance":
					if(crossedExit)
					{
						Reset();
					}
				break;
				case "FinishEntrance":
					
					
				break;
				
				case "StartExit":
					
					
				break;
				
				case "StartEntrance":
					
					
				break;
			}
		}
		
	}
	

	
	function Reset()
	{
		
		crossedExit = false;
		crossedEntrance = false;
	}
}