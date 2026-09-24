/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EStaticCameraAnimState
{
	SCAS_Default,
	SCAS_Collapsed,
	SCAS_Window,
	SCAS_ShakeTower,
}

enum EStaticCameraGuiEffect 
{
	SCGE_None = 0,
	SCGE_Hole,
}

import class CStaticCamera extends CCamera
{
	import var deactivationDuration 			: float;
	import var activationDuration 				: float;
	import var timeout							: float;
	import var fadeStartDuration				: float;
	import var fadeEndDuration					: float;
	import final function Run() 				: bool;
	import final function IsRunning() 			: bool;
	import final function AutoDeactivating()	: bool;
	import final function Stop();
	
	import final latent function RunAndWait( optional timeout : float ) : bool;
}





class CStaticCameraArea extends CEntity
{
    editable var cameraTag : name;
    editable var onlyForPlayer : bool;
	editable var activatorTag : name;
   
	default onlyForPlayer = true;
  
    event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
    {
		var camera : CStaticCamera;
		
		if ( !IsActivatorValid( activator ) )
		{
			return false;
		}
		
		camera = (CStaticCamera)theGame.GetNodeByTag( cameraTag );
		if ( camera )
		{
			camera.Run();
			GetWitcherPlayer().SetShowHud(false);
		}
		else
		{
			LogChannel( 'StaticCamera', "CStaticCameraArea::OnAreaEnter : Couldn't find static camera with tag " + cameraTag );
		}
    }
    
    event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
    {
        var camera : CStaticCamera;
		
		if ( !IsActivatorValid( activator ) )
		{
			return false;
		}
		
		camera = (CStaticCamera)theGame.GetNodeByTag( cameraTag );
		if ( camera )
		{
			if ( camera.IsRunning() )
			{
				theGame.GetGameCamera().Activate( camera.deactivationDuration );
				GetWitcherPlayer().SetShowHud(true);
			}
			else if ( !camera.AutoDeactivating() )
			{
				LogChannel( 'StaticCamera', "CStaticCameraArea::OnAreaExit : Static camera with tag " + cameraTag  + " is deactivating twice" );
			}
		}
		else
		{
			LogChannel( 'StaticCamera', "CStaticCameraArea::OnAreaExit : Couldn't find static camera with tag " + cameraTag );
		}
    }
    
    private final function IsActivatorValid( activator : CComponent ) : bool
    {
		if ( onlyForPlayer )
		{
			return (CPlayer)activator.GetEntity();
		}
		else if ( activatorTag )
		{
			return activator.GetEntity().HasTag( activatorTag );
		}
		else
		{
			return true;
		}
    }
}
