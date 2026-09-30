/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CInteractiveEntity extends CR4MapPinEntity
{	
	protected editable saved 	var bIsEnabled			: bool;
	protected					var bIsActive 			: bool;	
	
	default bIsEnabled = true;
	
	hint bIsEnabled = "Global switch of the entity to turn on/off all its components and effects at game start";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		Init();
	}
	
	function Init()
	{
		Activate( bIsEnabled );
	}

	function Activate( flag : bool )
	{
		
		bIsActive = flag;
	}
	
	
	function EnableEntity ( flag : bool )
	{
		bIsEnabled = flag;
		Init();
	}
};


class CUsableEntity extends CInteractiveEntity
{	
	protected editable 	var bCanBeUsed			: bool;

	default bCanBeUsed = true;
	
	hint bCanBeUsed = "Whether object can be context used on game start";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
	}

	function Init()
	{
		EnableInteraction( bCanBeUsed );
		super.Init();	
	}
	
	function Activate( flag : bool )
	{
		super.Activate( flag );
	}
	
	function EnableInteraction( flag : bool )
	{
		var interactionComponent	: CInteractionComponent;
		
		
		interactionComponent = (CInteractionComponent)this.GetComponentByClassName( 'CInteractionComponent' );
		if ( interactionComponent )
		{
			interactionComponent.SetEnabled( flag );
		}
	}	
};

class CScheduledUsableEntity extends CUsableEntity
{
	editable 	var bUseSwitchingSchedule	: bool;
	editable	var switchOnHour 			: int;
	editable 	var switchOffHour 			: int;
	
	hint bUseSwitchSchedule = "Enabling this flag will make the entity switch on or off according to switchOnHour and switchOffHour.";
	
	default bUseSwitchingSchedule = true;
	default switchOnHour = 18;
	default switchOffHour = 4;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( actionName ==  "Interact" )
		{
			if ( bIsActive )
			{
				Activate( false );
			}
			else
			{
				Activate( true );
			}
		}	
	}
		
	function Init()
	{
		if ( bIsEnabled )
		{
			if ( bUseSwitchingSchedule )
			{
				AddTimer( 'ProcessSwitchingSchedule', 10.0f, true, false );		
			}
			else
			{
				RemoveTimer( 'ProcessSwitchingSchedule' );		
			}
		}
		else
		{	
			
		}
		super.Init();
	}
	
	function Activate( flag : bool )
	{
		if( flag )
		{
			if ( bUseSwitchingSchedule )
			{
				AddTimer( 'ProcessSwitchingSchedule', 10.0f, true, false );		
			}
		}
		else
		{
			if ( bUseSwitchingSchedule )
			{
			
				
			}
		}
		super.Activate( flag );
	}
	
	timer function ProcessSwitchingSchedule( time : float , id : int)
	{
		var currentTime : int;
		
		currentTime =  GameTimeHours( GameTimeCreate() );
		
		if ( switchOnHour > switchOffHour )
		{
		
			if ( bIsActive )
			{
				if ( currentTime >= switchOffHour && currentTime < switchOnHour )
				{
					Activate( false );
				}
			}
			else
			{
				if ( currentTime >= switchOnHour || currentTime < switchOffHour )
				{
					Activate( true );
				}			
			}
		}
		else
		{
			if ( bIsActive )
			{
				if ( currentTime >= switchOffHour || currentTime < switchOnHour )
				{
					Activate( false );
				}
			}
			else
			{
				if ( currentTime >= switchOnHour && currentTime < switchOffHour )
				{
					Activate( true );
				}			
			}
		}
	}
}