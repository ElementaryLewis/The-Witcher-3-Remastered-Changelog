/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SBoatDestructionVolume
{
	import var volumeCorners : Vector;
    import var volumeLocalPosition : Vector;
    import var areaHealth : Float;
};

struct SBoatPartsConfig
{
	editable var destructionVolumeIndex : int;						
	editable saved var parts : array<SBoatDesctructionPart>;		
};

struct SBoatDesctructionPart
{
	editable var hpFalloffThreshold : float;		
	editable var componentName : string;				
	saved var isPartDropped : bool;					
};