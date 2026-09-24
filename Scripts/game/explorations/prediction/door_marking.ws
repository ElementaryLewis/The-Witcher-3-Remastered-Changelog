/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EDoorMarkingState
{
	EDMCT_Nothing		,
	EDMCT_Considered	,
	EDMCT_Selected		,
}



class CDoorMarking extends CScriptedComponent
{	
	private editable	var	changeCamera	: bool;				default	changeCamera	= true;
	private editable	var doCalculations	: bool;				default doCalculations  = true; 
	
	private				var	calculated		: bool;
	private				var	pointA			: Vector;
	private				var	pointB			: Vector;
	private				var middlePoint		: Vector;
	private				var	normal			: Vector;
	private				var	checkState		: EDoorMarkingState;
	private				var	initialized		: bool;
	
	
	
	event OnComponentAttached()
	{
		initialized	= false;
		
		PreInit();
	}
	
	
	public function PreInit()
	{
		var entity			: CEntity;
		var gameplayEntity	: CGameplayEntity;
		
		
		calculated	= false;
		
		
		entity	= GetEntity();
		if( entity )
		{
			gameplayEntity	= ( CGameplayEntity ) entity;
			
			if( gameplayEntity )
			{
				gameplayEntity.EnableVisualDebug( SHOW_Exploration, true );
			}
			
			SetProperTags();
			
			initialized		= true;
		}
	}
	
	
	private function SetProperTags()
	{
		var tag		: name = 'navigation_correction';
		var tags	: array<name>;
		var i		: int;
		var entity	: CEntity;
		
		
		entity	= GetEntity();
		if( entity )
		{
			
			if( !entity.HasTag( tag ) )
			{
				tags	= entity.GetTags();
				tags.PushBack( tag );
				entity.SetTags( tags );
			}	
		}	
	}
	
	
	public function GetClosestPointAndNormal( out outPoint : Vector, out outNormal : Vector )
	{
		
		if(!doCalculations)
		{
			outPoint = Vector(0,0,-9000);
			outNormal = Vector(0,0,0);
			return;
		}
		
	
		
		if( !calculated )
		{
			CalculateData();
		}
		
		outPoint	= middlePoint;
		outNormal	= normal;	
	}
	
	
	private function CalculateData()
	{
		var aux	: float;
		
		
		
		if( !initialized )
		{
			PreInit();
		}
		
		
		CalculatePoints();
		
		
		
		middlePoint	= ( pointB + pointA ) * 0.5f;
		
		
		
		normal		= pointB - pointA;
		
		aux			= normal.X;
		normal.X	= -normal.Y;
		normal.Y	= aux;
		normal.Z	= 0.0f;
		
		normal		= VecNormalize( normal );
		
		
		calculated	= true;
	}
	
	
	private function CalculatePoints()
	{
		var slotMatrix	: Matrix;
		
		
		GetEntity().CalcEntitySlotMatrix( 'point_a', slotMatrix );
		pointA		= MatrixGetTranslation( slotMatrix );
		
		GetEntity().CalcEntitySlotMatrix( 'point_b', slotMatrix );
		pointB		= MatrixGetTranslation( slotMatrix );	
	}
	
	
	public function SetCheckState( check : EDoorMarkingState )
	{
		checkState	= check;
	}
	
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags )
	{
		var offsetVec	: Vector;
		var color		: Color;
		
		switch( checkState )
		{
			case EDMCT_Nothing:
				color	= Color( 230, 140, 140 );
				break;
			case EDMCT_Considered:
				color	= Color( 0, 0, 255 );
				break;
			case EDMCT_Selected:
				color	= Color( 0, 255, 0 );
				break;
		}
		checkState	= EDMCT_Nothing;
		
		offsetVec	= Vector( 0, 0, 0.1f );
		
		CalculateData();
		
		frame.DrawText( "doorway", GetWorldPosition() + offsetVec * 5.0f, color );
		frame.DrawSphere( pointA, 0.1f, color );
		frame.DrawSphere( pointB, 0.1f, color );
		frame.DrawLine( pointA, pointB, color );
		frame.DrawLine( pointA + offsetVec, pointB + offsetVec, color );
		frame.DrawSphere( middlePoint, 0.05f, color );
		frame.DrawLine( middlePoint + offsetVec - normal * 0.5f, middlePoint + normal * 0.5f + offsetVec, color );
		
		return true;
	}	
	
	
	public function IsChangingCamera() : bool
	{
		return changeCamera;
	}
}
	
	



class CDoorMarkingTester extends CGameplayEntity
{
	private var door	: CDoorMarking;
	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		Spawned( spawnData );
	}
	
	
	event OnSpawnedEditor( spawnData : SEntitySpawnData )
	{
		Spawned( spawnData );
	}
	
	
	private function Spawned( spawnData : SEntitySpawnData )
	{
		if( !door )
		{
			door	= ( CDoorMarking ) GetComponentByClassName( 'CDoorMarking' );
		}		
		door.PreInit();
		
		EnableVisualDebug( SHOW_Exploration, true );
		
		super.OnSpawned( spawnData );
	}
	
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags )
	{
		door.OnVisualDebug( frame, flag );
	}
}