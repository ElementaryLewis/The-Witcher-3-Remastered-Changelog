/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3StaringPortrait extends W3MonsterClue
{
	private var isPlayerIn : bool;
	private var vfxname : CName;
	private var entityname : CName;
	private var box : Box;
	private var playerPos : Vector;
	var meshComponent : CStaticMeshComponent;
	var meshComponent2 : CMeshComponent;
	private var direction : Vector;
	private var angles : float;
	private var index : float;
	
	
	private var newScale : Vector;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		vfxname = 'test';
		entityname = 'CStaticMeshComponent0';
		if ( activator.GetEntity() == thePlayer )
		{
			AddTimer('CalculateAreaChunk', 0.1f, true );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
	
		if ( activator.GetEntity() == thePlayer ) 
		{
			RemoveTimer('CalculateAreaChunk');
			SetEffectIntensity(vfxname,0.0f,entityname); 
		}
		
	}
	
	
	
	timer function CalculateAreaChunk( td : float , id : int ) 
	{
		var cols : float;
		var rows : float;
		var cell_w : float;
		var cell_h : float;
		
		var triggerArea : CTriggerAreaComponent;
		
		
		if(aimingPortrait())
		{
			index = 6;
		}
		
		else
		{
			triggerArea = (CTriggerAreaComponent)GetComponentByClassName('CTriggerAreaComponent');
			if(triggerArea)
			{ 
				playerPos = thePlayer.GetWorldPosition();
				box = triggerArea.GetBoundingBox();
				cell_w = (box.Max.X - box.Min.X) / 3; 
				cell_h = (box.Max.Y - box.Min.Y) / 2; 
			
				cols = FloorF((playerPos.X - box.Min.X) / cell_w);
				rows = FloorF((playerPos.Y - box.Min.Y) / cell_h); 
				index = FloorF(rows*3+cols);
			}
		}
		LogGalaxy("Swapping to index  " + index );
		SetEffectIntensity(vfxname,(int)index,entityname);
	}
	
	protected function aimingPortrait() : bool
	{
	
	
		var cachedCamDirection 	: Vector;
		var cachedCamPosition	: Vector;
		var cachedOwnerPosition	: Vector;

		var traceResultDists		: array<float>;
		var tracePosFromInitial		: Vector;
		var maxRangePos				: Vector;
		
		var traceManager 			: CScriptBatchQueryAccessor;
		
		var i, size					: int;
		var hasResult				: bool;
		var rayCastResult 			: SRaycastHitResult;
		var rayCastResults 			: array<SRaycastHitResult>;	
		var ent						: CEntity;	
		var entityTags				: array<name>;
		
		var searchedTag 			: name;
		
		searchedTag = 'q804_beholder_mural';
		
		
		if(thePlayer.rangedWeapon.GetCurrentStateName() == 'State_WeaponAim' || thePlayer.rangedWeapon.GetCurrentStateName() == 'State_WeaponShoot' ) 
		{
			traceManager = theGame.GetWorld().GetTraceManager();
		
			cachedCamDirection = theCamera.GetCameraDirection();
			cachedCamPosition = theCamera.GetCameraPosition();
			cachedOwnerPosition = thePlayer.GetWorldPosition();
			tracePosFromInitial = 0.5f * VecNormalize( cachedCamDirection ) + cachedCamPosition;
			maxRangePos = VecNormalize( cachedCamDirection ) * theGame.params.MAX_THROW_RANGE + tracePosFromInitial;

			if ( traceManager.RayCastSync( tracePosFromInitial, maxRangePos , rayCastResults ) )		
			{		
				size =  rayCastResults.Size();
				if ( size > 0 )
				{	
					
					for ( i = 0; i < rayCastResults.Size(); i += 1 )
					{
						ent = rayCastResults[i].component.GetEntity();
						
						if(ent)
						{
							if( ent.HasTag( searchedTag ) )
							{
							FactsAdd("beholder_aim");
								if (thePlayer.rangedWeapon.GetCurrentStateName() == 'State_WeaponShoot' && FactsQuerySum( "beholder_shot" ) < 1)
								{
								FactsAdd("beholder_shot", ,1);
								}
								return true;
							}
							
						}
						
					}
				}
			}
		}
		FactsRemove("beholder_aim");
		return false;
	}
}