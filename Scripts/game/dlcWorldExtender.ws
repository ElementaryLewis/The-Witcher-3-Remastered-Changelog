/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4WorldDLCExtender extends CObject
{
	import public function AreaTypeToName( areaType : int ) : string;
	import public function AreaNameToType( areaName : string ) : int;
	
	import public function GetMiniMapSize( areaType : int ) : float;
	import public function GetMiniMapTileCount( areaType : int ) : int;
	import public function GetMiniMapExteriorTextureSize( areaType : int ) : int;
	import public function GetMiniMapInteriorTextureSize( areaType : int ) : int;
	import public function GetMiniMapTextureSize( areaType : int ) : int;
	import public function GetMiniMapMinLod( areaType : int ) : int;
	import public function GetMiniMapMaxLod( areaType : int ) : int;
	import public function GetMiniMapExteriorTextureExtension( areaType : int ) : string;
	import public function GetMiniMapInteriorTextureExtension( areaType : int ) : string;
	import public function GetMiniMapVminX( areaType : int ) : int;
	import public function GetMiniMapVmaxX( areaType : int ) : int;
	import public function GetMiniMapVminY( areaType : int ) : int;
	import public function GetMiniMapVmaxY( areaType : int ) : int;
	import public function GetMiniMapSminX( areaType : int ) : int;
	import public function GetMiniMapSmaxX( areaType : int ) : int;
	import public function GetMiniMapSminY( areaType : int ) : int;
	import public function GetMiniMapSmaxY( areaType : int ) : int;
	import public function GetMiniMapMinZoom( areaType : int ) : float;
	import public function GetMiniMapMaxZoom( areaType : int ) : float;
	import public function GetMiniMapZoom12( areaType : int ) : float;
	import public function GetMiniMapZoom23( areaType : int ) : float;
	import public function GetMiniMapZoom34( areaType : int ) : float;
	import public function GetGradientScale( areaType : int ) : float;
	import public function GetPreviewHeight( areaType : int ) : float;
}
