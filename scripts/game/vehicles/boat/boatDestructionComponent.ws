/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CBoatDestructionComponent extends CComponent
{
	import 						var destructionVolumes 			: array<SBoatDestructionVolume>;
	private 					var boatComponent 				: CBoatComponent;
	private editable 			var collisionForceThreshold 	: float;
	editable saved 				var partsConfig 				: array<SBoatPartsConfig>; 				
	private 					var attachedSirens				: array<CActor>;
	
	default collisionForceThreshold = 3;
	
	private var freeSirenGrabSlots		: array<name>;
	private var lockedSirenGrabSlots	: array<name>;
		
	
	event OnComponentAttached()
	{
		var ent : CEntity;
		
		ent = GetEntity();		
		boatComponent = (CBoatComponent)ent.GetComponentByClassName('CBoatComponent');
		
		lockedSirenGrabSlots.Clear();
		freeSirenGrabSlots.Clear();
		
		freeSirenGrabSlots.PushBack('siren_grab_01');
		freeSirenGrabSlots.PushBack('siren_grab_02');
		freeSirenGrabSlots.PushBack('siren_grab_03');
		freeSirenGrabSlots.PushBack('siren_grab_04');
		freeSirenGrabSlots.PushBack('siren_grab_05');
		freeSirenGrabSlots.PushBack('siren_grab_06');
	}
	
	event OnLoadGameDropDestructableParts( areaIndex : int )
	{
		var i, idxParts : int;
		var drop : CDropPhysicsComponent;
		var dropCompName : string;
		var comp : CComponent;
		var rigidMeshComp : CRigidMeshComponent;
	
		drop = (CDropPhysicsComponent)GetEntity().GetComponentByClassName('CDropPhysicsComponent');
		
		
		idxParts = -1;
		for(i=0; i<partsConfig.Size(); i+=1)
		{
			if(partsConfig[i].destructionVolumeIndex == areaIndex)
			{
				idxParts = i;
				break;
			}
		}
		
		if(idxParts >= 0)
		{
			for(i=0; i<partsConfig[idxParts].parts.Size(); i+=1)
			{
				if(destructionVolumes[areaIndex].areaHealth <= partsConfig[idxParts].parts[i].hpFalloffThreshold && !partsConfig[idxParts].parts[i].isPartDropped)
				{
					dropCompName = partsConfig[idxParts].parts[i].componentName;
					
					comp = GetEntity().GetComponent( dropCompName );
					rigidMeshComp = (CRigidMeshComponent)comp;
					rigidMeshComp.EnableBuoyancy( false );
					
					drop.DropMeshByName( dropCompName, VecFromHeading( GetEntity().GetHeading() ), PartNameToCurveName( dropCompName ) );
					partsConfig[idxParts].parts[i].isPartDropped = true;
					PlayEffectBasedOnDropCompName( dropCompName );
				}
			}
		}
	}
	
	
	
	public function GetClosestFreeGrabSlotInfo( _ActorPosition : Vector, _ActorHeading : float ,out _ClosestSlotName : name, out _Position : Vector, out _Heading : float ) : bool
	{
		var i					: int;
		var l_slotMatrix 		: Matrix;
		var l_slotPos			: Vector;
		var l_closestDistance	: float;
		var l_closestMatrix		: Matrix;
		var l_closestPos		: Vector;
		var l_distance			: float;
		var l_npcPos			: Vector;
		var l_slotRotation		: EulerAngles;
		var l_slotForward		: Vector;
		var l_slotName			: name;
		var l_angleDistance		: float;
		
		if( freeSirenGrabSlots.Size() == 0 ) return false;
		
		l_closestDistance = 999;
		
		for( i = 0; i < freeSirenGrabSlots.Size(); i += 1 )
		{
			l_slotName 	= freeSirenGrabSlots[i];
			GetEntity().CalcEntitySlotMatrix( l_slotName, l_slotMatrix );
			l_slotPos	= MatrixGetTranslation( l_slotMatrix );
			
			l_distance = VecDistance( _ActorPosition, l_slotPos );
			if( l_distance < l_closestDistance )
			{
				l_closestDistance = l_distance;
				l_closestPos		= l_slotPos;
				l_closestMatrix	= l_slotMatrix;
				_ClosestSlotName = l_slotName;
			}
		}
		
		l_slotRotation	= MatrixGetRotation( l_closestMatrix );
		l_slotForward	= RotForward( l_slotRotation ); 
		_Heading		= VecHeading( l_slotForward );
		_Position		= l_closestPos;
		
		l_angleDistance = AngleDistance( _ActorHeading, _Heading);
		
		if( AbsF( l_angleDistance ) > 85 )
		{
			_ClosestSlotName = '';
			return false;
		}
		
		return true;
	}
	
	
	public function LockGrabSlot( _SlotName : name )
	{
		if( !IsNameValid( _SlotName ) ) 
			return;
			
		freeSirenGrabSlots.Remove( _SlotName );
		if( !lockedSirenGrabSlots.Contains( _SlotName ) )
		{
			lockedSirenGrabSlots.PushBack( _SlotName );
		}	
	}
	
	
	public function AttachSiren( _SirenToAttach : CActor )
	{
		if( !attachedSirens.Contains( _SirenToAttach ) )
		{
			attachedSirens.PushBack( _SirenToAttach );
		}		
	}
	
	
	
	public function DetachSiren( _SirenTodetach : CActor )
	{
		attachedSirens.Remove( _SirenTodetach  );
	}
	
	
	public function FreeGrabSlot( _SlotName : name )
	{
		if( !IsNameValid( _SlotName ) ) 
			return;
			
		lockedSirenGrabSlots.Remove( _SlotName );
		if( !freeSirenGrabSlots.Contains( _SlotName ) )
		{
			freeSirenGrabSlots.PushBack( _SlotName );
		}	
	}
	
	
	event OnBoatDestructionVolumeHit( globalHitPos : Vector, healthTaken : float, areaVolumeIndex : int )
	{
		DealDamage( healthTaken * 30.0f, areaVolumeIndex, globalHitPos );
	}
	
	public function DealDamage(dmg : float, index : int, optional globalHitPos : Vector )
	{
		var i : int;
		var drop : CDropPhysicsComponent;
		var boat : W3Boat;
		
		
		
		if( !(boatComponent.user == thePlayer) || boatComponent.GetPassenger() )
			return;
		
		
		ProcessBoatHitAnimation( index );
		
		
		if(boatComponent.user == thePlayer || boatComponent.GetPassenger() == thePlayer)
			theGame.HapticStart( "classic_vibro_large_oneshot" );
		
		boat = (W3Boat)GetEntity();
		if( !boat.GetCanBeDestroyed() ) 
			return;
		
		
		if(index >= 0 && index < destructionVolumes.Size())
		{
			ReduceHealth(dmg, index, globalHitPos);
			return;
		}
	
		
		for(i=0; i<destructionVolumes.Size(); i+=1)
		{		
			ReduceHealth(dmg, i, globalHitPos);	
		}
	}
	
	private function ReduceHealth(dmg : float, index : int, globalHitPos : Vector)
	{
		var i, idxParts : int;
		var drop : CDropPhysicsComponent;
		var dropCompName : string;
		var comp : CComponent;
		var rigidMeshComp : CRigidMeshComponent;
		var sailing : CR4PlayerStateSailing;
		
		drop = (CDropPhysicsComponent)GetEntity().GetComponentByClassName('CDropPhysicsComponent');
		
		if(dmg > 0 && boatComponent.user == thePlayer && ShouldProcessTutorial('TutorialBoatDamage'))
			FactsAdd("tutorial_boat_damaged");
		
		
		destructionVolumes[index].areaHealth -= dmg;
		
		
		idxParts = -1;
		for(i=0; i<partsConfig.Size(); i+=1)
		{
			if(partsConfig[i].destructionVolumeIndex == index)
			{
				idxParts = i;
				break;
			}
		}
		
		if(idxParts >= 0)
		{
			for(i=0; i<partsConfig[idxParts].parts.Size(); i+=1)
			{
				if(destructionVolumes[index].areaHealth <= partsConfig[idxParts].parts[i].hpFalloffThreshold && !partsConfig[idxParts].parts[i].isPartDropped)
				{
					dropCompName = partsConfig[idxParts].parts[i].componentName;
					
					comp = GetEntity().GetComponent( dropCompName );
					rigidMeshComp = (CRigidMeshComponent)comp;
					rigidMeshComp.EnableBuoyancy( false );
					
					drop.DropMeshByName( dropCompName, VecFromHeading( GetEntity().GetHeading() ), PartNameToCurveName( dropCompName ) );
					partsConfig[idxParts].parts[i].isPartDropped = true;
					PlayEffectBasedOnDropCompName( dropCompName );
				}
			}
		}
		
		
		if( destructionVolumes[index].areaHealth <= 0.0f )
		{
			if( thePlayer.GetCurrentStateName() == 'Sailing' )
			{
					sailing = ( CR4PlayerStateSailing )thePlayer.GetCurrentState();
					sailing.TriggerDrowning();
					thePlayer.BlockAction( EIAB_Crossbow, 'DismountVehicle2' );
			}
			
			boatComponent.TriggerDrowning( globalHitPos );
			GetEntity().AddTimer( 'DrowningDismount', 2.0 );
			
			
			boatComponent.GetBoatEntity().SetHasDrowned( true );
			boatComponent.GetBoatEntity().SoundEvent( "boat_sinking" );
			
			for ( i = attachedSirens.Size() - 1 ; i >= 0 ; i-=1 )
			{
				attachedSirens[i].SignalGameplayEvent('BoatDestroyed');
				attachedSirens.EraseFast(i);
			}
		}
	}
	
	public function IsDestroyed() : bool 
	{
		var i : int;
	
		for(i=0; i<destructionVolumes.Size(); i+=1)
		{
			if(destructionVolumes[i].areaHealth <= 0)
				return true;
		}
		
		return false;
	}
	
	
	public function DealDmgToNearestVolume( dmgPrcnt : float, hitPos : Vector ) : bool
	{
		var index : int;
		
		index = GetNearestVolumeIndex(hitPos);
		
		if ( index == -1 )
			return false;
		
		ReduceHealth( dmgPrcnt, index, hitPos);
		
		
		ProcessBoatHitAnimation( index );
		
		return true;
	}
		
	private function GetNearestVolumeIndex( pos : Vector) : int
	{
		var i : int;
		var nearestDist, tempDist : float = 0.f;
		var boatPos : Vector;
		var index 	: int = -1;
		var worldPos : Vector;
		var boatEnt : CEntity;
		var l2w		: Matrix;
		
		boatEnt = GetEntity();
		l2w 	= boatEnt.GetLocalToWorld();		
		
		boatPos = GetEntity().GetWorldPosition();
		
		for ( i=0 ; i < destructionVolumes.Size() ; i+=1 )
		{
			worldPos = VecTransform( l2w, destructionVolumes[i].volumeLocalPosition);
			tempDist = VecDistance(pos, worldPos);
			
			if ( i == 0 || tempDist < nearestDist )
			{
				nearestDist = tempDist;
				index = i;
			}
		}
		return index;
	}
	
	public function PartNameToCurveName( partName : string ) : name
	{
		switch( partName )
		{
			case "dest_BL_01":
				return 'leftBack';
				
			case "dest_ML_01":
				return 'leftMiddle';
				
			case "dest_ML_02":
				return 'leftMiddle';
				
			case "dest_FL_01":
				return 'leftFront';
				
			case "dest_FL_02":
				return 'leftFront';
				
			case "dest_BR_01":
				return 'rightBack';	
				
			case "dest_MR_01":
				return 'rightMiddle';
				
			case "dest_MR_02":
				return 'rightMiddle';
				
			case "dest_FR_01":
				return 'rightFront';
				
			case "dest_FR_02":
				return 'rightFront';
				
			default:
				return 'None';	
		}
	}
	
	public function PlayEffectBasedOnDropCompName( partName : string )
	{
		var boatEnt : W3Boat;
		var fxName : name;
		
		boatEnt = (W3Boat)GetEntity();
		if( !boatEnt )
			return;
			
		switch( partName )
		{
			case "dest_BL_01":
				fxName = 'boat_hit00';
				break;
				
			case "dest_ML_01":
				fxName = 'boat_hit05';
				break;
				
			case "dest_ML_02":
				fxName = 'boat_hit08';
				break;
				
			case "dest_FL_01":
				fxName = 'boat_hit07';
				break;
				
			case "dest_FL_02":
				fxName = 'boat_hit06';
				break;
				
			case "dest_BR_01":
				fxName = 'boat_hit09';
				break;
				
			case "dest_MR_01":
				fxName = 'boat_hit02';
				break;
				
			case "dest_MR_02":
				fxName = 'boat_hit01';
				break;
				
			case "dest_FR_01":
				fxName = 'boat_hit04';
				break;
				
			case "dest_FR_02":
				fxName = 'boat_hit03';
				break;
				
			default:
				return;
		}
		
		boatEnt.PlayEffect( fxName );
	}
	
	private function ProcessBoatHitAnimation( volumeHit : int )
	{
		var boatHitDirection : int;
		
		
		switch( volumeHit )
		{
			case 2:
			case 5:
				boatHitDirection = 0; 
				break;
			case 0:
			case 3:
				boatHitDirection = 1; 
				break;
			case 4:
				boatHitDirection = 2; 
				break;
			case 1:
				boatHitDirection = 3; 
				break;
			
			default:
				boatHitDirection = 0;
				break;
		}
		
		if( boatComponent.user )
		{
			boatComponent.user.SetBehaviorVariable( 'boatHitDirection', boatHitDirection );
			boatComponent.user.RaiseEvent( 'BoatHit' );
		}
			
		if( boatComponent.GetPassenger() )
		{
			boatComponent.GetPassenger().SetBehaviorVariable( 'boatHitDirection', boatHitDirection );
			boatComponent.GetPassenger().RaiseEvent( 'BoatHit' );
		}	
	}
}