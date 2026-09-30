/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CVisualDebug extends CObject
{
	
	import final function AddText
	(
		dbgName : name,
		text : string,
		optional position : Vector,		
		optional absolutePos : bool,	
		optional line : byte,			
		optional color : Color,			
		optional background : bool,		
		optional timeout : float		
	);
	
	
	import final function AddSphere
	(
		dbgName : name,
		radius : float,
		optional position : Vector,		
		optional absolutePos : bool,	
		optional color : Color,			
		optional timeout : float		
	);
	
	
	import final function AddBox
	(
		dbgName : name,
		size : Vector,
		optional position : Vector,		
		optional rotation : EulerAngles,
		optional absolutePos : bool,	
		optional color : Color,			
		optional timeout : float		
	);
	
	
	import final function AddAxis
	(
		dbgName : name,
		optional scale : float,			
		optional position : Vector,		
		optional rotation : EulerAngles,
		optional absolutePos : bool,	
		optional timeout : float		
	);
	
	
	import final function AddLine
	(
		dbgName : name,
		optional startPosition, endPosition : Vector,		
		optional absolutePos : bool,						
		optional color : Color,								
		optional timeout : float							
	);
	
	import final function AddArrow
	( 
		dbgName : name, 
		optional start : Vector, optional end : Vector, 
		optional arrowPostionOnLine01 : float, optional arrowSizeX : float, optional arrowSizeY : float,
		optional absolutePos : bool, 
		optional color : Color, 
		optional overlay : bool, 
		optional timeout : float 
	);
	
	
	import final function AddBar( dbgName : name, x : int, y : int, width : int, height : int, progress : float, color : Color, optional text : string, optional timeout : float );
	import final function AddBarColorSmooth( dbgName : name, x : int, y : int, width : int, height : int, progress : float, color : Color, optional text : string, optional timeout : float );
	import final function AddBarColorAreas( dbgName : name, x : int, y : int, width : int, height : int, progress : float, optional text : string, optional timeout : float );
	
	
	import final function RemoveText( dbgName : name );
	
	
	import final function RemoveSphere( dbgName : name );
	
	
	import final function RemoveBox( dbgName : name );
	
	
	import final function RemoveAxis( dbgName : name );
	
	
	import final function RemoveLine( dbgName : name );
	
	
	import final function RemoveArrow( dbgName : name );
	
	
	import final function RemoveBar( dbgName : name );
};


import class CScriptedRenderFrame extends CObject
{
	
	import function DrawText( text : String, position : Vector, color : Color );
	
	
	import function DrawSphere( position : Vector, radius : float, color : Color );
	
	
	import function DrawLine( start : Vector, end : Vector, color : Color );

}