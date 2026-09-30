/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4WorldDLCExtender extends CObject
{	
	import public function GetMiniMapSize( areaType : name ) : float;
	import public function GetMiniMapTileCount( areaType : name ) : int;
	import public function GetMiniMapExteriorTextureSize( areaType : name ) : int;
	import public function GetMiniMapInteriorTextureSize( areaType : name ) : int;
	import public function GetMiniMapTextureSize( areaType : name ) : int;
	import public function GetMiniMapMinLod( areaType : name ) : int;
	import public function GetMiniMapMaxLod( areaType : name ) : int;
	import public function GetMiniMapExteriorTextureExtension( areaType : name ) : string;
	import public function GetMiniMapInteriorTextureExtension( areaType : name ) : string;
	import public function GetMiniMapVminX( areaType : name ) : int;
	import public function GetMiniMapVmaxX( areaType : name ) : int;
	import public function GetMiniMapVminY( areaType : name ) : int;
	import public function GetMiniMapVmaxY( areaType : name ) : int;
	import public function GetMiniMapSminX( areaType : name ) : int;
	import public function GetMiniMapSmaxX( areaType : name ) : int;
	import public function GetMiniMapSminY( areaType : name ) : int;
	import public function GetMiniMapSmaxY( areaType : name ) : int;
	import public function GetMiniMapMinZoom( areaType : name ) : float;
	import public function GetMiniMapMaxZoom( areaType : name ) : float;
	import public function GetMiniMapZoom12( areaType : name ) : float;
	import public function GetMiniMapZoom23( areaType : name ) : float;
	import public function GetMiniMapZoom34( areaType : name ) : float;
	import public function GetGradientScale( areaType : name ) : float;
	import public function GetPreviewHeight( areaType : name ) : float;

	import public function GetDlcWorlds(out worlds : array< CR4WorldDescriptionDLC >);
	import public function GetDlcWorldMapPins() : array< SAreaMapPinInfo >;
}