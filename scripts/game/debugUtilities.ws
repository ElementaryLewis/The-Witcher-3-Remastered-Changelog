/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
exec function pos()
{
	var pos : Vector = thePlayer.GetWorldPosition();
	GetWitcherPlayer().DisplayHudMessage( (string)pos.X + ", " + (string)pos.Y + ", " + (string)pos.Z );
}







exec function funcEnablePolarSun()
{


		var l_world 			: CWorld;
		l_world 		= theGame.GetWorld();
		l_world.ResetAllCurves();

		
		l_world.SetSunHeightPoint(0.15,0.08);
		l_world.SetSunHeightPoint(0.5,0.08);
		l_world.SetSunHeightPoint(0.85,0.08);

		
		l_world.SetMoonHeightPoint(0.2,-0.8);
		l_world.SetMoonHeightPoint(0.5,-0.8);
		l_world.SetMoonHeightPoint(0.8,-0.8);

		
		l_world.SetLightHeightPoint(0.2,0.4);
		l_world.SetLightHeightPoint(0.5,0.4);
		l_world.SetLightHeightPoint(0.8,0.4);

		
		l_world.SetLightDirPoint(0.5,1.0);

		
		l_world.SetLightDayAmountPoint(0.15,0);
		l_world.SetLightDayAmountPoint(0.25,1);
		l_world.SetLightDayAmountPoint(0.75,1);
		l_world.SetLightDayAmountPoint(0.85,0);
}

exec function funcDisablePolarSun()
{
		var l_world 			: CWorld;
		l_world 		= theGame.GetWorld();
		l_world.ResetAllCurves();
		

		
		l_world.SetSunHeightPoint(0.15,-0.08);
		l_world.SetSunHeightPoint(0.19,0.08);
		l_world.SetSunHeightPoint(0.25,0.0115);
		l_world.SetSunHeightPoint(0.48,0.346);
		l_world.SetSunHeightPoint(0.67,0.27);
		l_world.SetSunHeightPoint(0.92,-0.06);

		
		l_world.SetMoonHeightPoint(0.24,-0.17);
		l_world.SetMoonHeightPoint(0.52,-0.35);
		l_world.SetMoonHeightPoint(0.74,-0.2);
		l_world.SetMoonHeightPoint(0.99,0.4);

		
		l_world.SetLightHeightPoint(0.133,0.19);
		l_world.SetLightHeightPoint(0.175,0.07);
		l_world.SetLightHeightPoint(0.294,0.47);
		l_world.SetLightHeightPoint(0.497,0.76);
		l_world.SetLightHeightPoint(0.75,0.5);
		l_world.SetLightHeightPoint(0.874,0.05);
		l_world.SetLightHeightPoint(0.887,0.22);
		l_world.SetLightHeightPoint(0.99,0.4);

		
		l_world.SetLightDirPoint(0.16,-0.05);
		l_world.SetLightDirPoint(0.162,1.0);
		l_world.SetLightDirPoint(0.88,1.0);
		l_world.SetLightDirPoint(0.89,-0.05);

		
		l_world.SetLightDayAmountPoint(0.15,0);
		l_world.SetLightDayAmountPoint(0.167,0.98);
		l_world.SetLightDayAmountPoint(0.25,1);
		l_world.SetLightDayAmountPoint(0.75,1);
		l_world.SetLightDayAmountPoint(0.85,0);
}



exec function passtime(requestedHours : int, timestep : float)
{
	thePlayer.changeClockSpeed(timestep, requestedHours);
}