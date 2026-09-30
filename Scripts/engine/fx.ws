/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function EnableDrunkFx( optional fadeIn : float );


import function DisableDrunkFx( optional fadeout: float );


import function ScaleDrunkFx( scale: float );


exec function Drunk( optional enabled : bool )
{
	if( enabled )
	{
		EnableDrunkFx( 1.0f );	
	}
	else
	{
		DisableDrunkFx( 1.0f );	
	}
}




import function EnableCatViewFx( optional fadeIn : float );


import function DisableCatViewFx( optional fadeout: float );





import function SetPositionCatViewFx( position: Vector, optional autoPositioning : bool );


import function SetTintColorsCatViewFx( tintNear: Vector, tintFar: Vector, optional desaturaion: float );


import function SetBrightnessCatViewFx( optional brightStrength: float );


import function SetViewRangeCatViewFx( optional viewRanger: float );





import function SetHightlightCatViewFx( color: Vector, optional hightlightInterior  : float, optional blurSize : float );



import function SetFogDensityCatViewFx( density : float, optional startOffset: float );


exec function Cat( optional enabled : bool )
{
	if( enabled )
	{
		EnableCatViewFx( 1.0f );	
		SetPositionCatViewFx( Vector(0,0,0,0) , true );	
	}
	else
	{
		DisableCatViewFx( 1.0f );	
	}
}