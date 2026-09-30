/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SEntitySpawnData
{
	import var restored : bool;
}




import class CEntity extends CNode
{	
	

	
	import final function AddTimer( timerName : name, period : float, optional repeats : bool , optional scatter : bool , optional group : ETickGroup , optional saveable : bool , optional overrideExisting : bool  ) : int;
	
	import final function AddGameTimeTimer( timerName : name, period : GameTime, optional repeats : bool , optional scatter : bool , optional group : ETickGroup , optional saveable : bool , optional overrideExisting : bool  ) : int;
	
	import final function RemoveTimer( timerName : name, optional group : ETickGroup );
	
	import final function RemoveTimerById( id : int, optional group : ETickGroup );
	
	import final function RemoveTimers();
	
	import final function HasTagInLayer( tag : name ) : bool;
	
	
	
	
	import final function Destroy();

	

	
	import final function Duplicate( optional placeOnLayer : CLayer ) : CEntity;
	
	
	
	
	import final function Teleport( position : Vector );

	
	import final function TeleportWithRotation(position : Vector, rotation : EulerAngles );
	
	
	import final function TeleportToNode( node : CNode, optional applyRotation : bool  ) : bool;
	
	
	
	
	import final function GetRootAnimatedComponent() : CAnimatedComponent;
	
	
	import final function RaiseEvent( eventName : name ) : bool;
	
	
	import final function RaiseForceEvent( eventName : name ) : bool;
	
	
	import final function RaiseEventWithoutTestCheck( eventName : name ) : bool;
	import final function RaiseForceEventWithoutTestCheck( eventName : name ) : bool;
	
	
	
	import final latent function WaitForEventProcessing( eventName : name, timeout : float ) : bool;

	
	import final latent function WaitForBehaviorNodeActivation( activationName : name, timeout : float ) : bool;
	
	
	import final latent function WaitForBehaviorNodeDeactivation( deactivationName : name, timeout : float ) : bool;
	
	
	import final latent function WaitForAnimationEvent( animEventName : name, timeout : float ) : bool;
	
	
	import final function BehaviorNodeDeactivationNotificationReceived( deactivationName : name ) : bool;
	
	
	import function I_GetDisplayName() : string;
	
	import function CalcBoundingBox( out box : Box );
	
	
	event OnBehaviorGraphNotification( notificationName : name, stateName : name ){}
	
	
	
	
	final function GetBoneWorldPosition( boneName : name ) : Vector
	{
		var boneIdx : int;
		var boneMatrix : Matrix;
		
		boneIdx = GetBoneIndex( boneName );
		
		if( boneIdx != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIdx );
			
			return MatrixGetTranslation( boneMatrix );
		}
		
		return Vector(0,0,0,1);
	}
	
	final function GetBoneWorldPositionByIndex( boneIndex : int ) : Vector
	{
		var boneMatrix : Matrix;
		
		if( boneIndex != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIndex );
			
			return MatrixGetTranslation( boneMatrix );
		}
		
		return Vector(0,0,0,1);
	}
	
	final function GetBoneWorldRotationByIndex( boneIndex : int ) : EulerAngles
	{
		var boneMatrix : Matrix;
		
		if( boneIndex != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIndex );
			
			return MatrixGetRotation( boneMatrix );
		}
		
		return EulerAngles(0,0,0);
	}
	
	final function GetBoneWorldPositionAndRotationByIndex(boneIndex : int, out position : Vector, out rotation : EulerAngles)
	{
		var boneMatrix : Matrix;
		
		if( boneIndex != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIndex );
			
			position = MatrixGetTranslation( boneMatrix );
			rotation =  MatrixGetRotation( boneMatrix );
		}
		else
		{
			position = Vector(0,0,0,1);
			rotation = EulerAngles(0,0,0);
		}
	}
	
	final function GetBoneWorldMatrix( boneName : name ) : Matrix
	{
		var boneIdx : int;
		var boneMatrix : Matrix;
		
		boneIdx = GetBoneIndex( boneName );
		
		if( boneIdx != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIdx );
		}
		
		return boneMatrix;
	}
	
	
	
	import final function CalcEntitySlotMatrix( slot : name, out slotMatrix : Matrix ) : bool;

	
	import final function GetBoneWorldMatrixByIndex( boneIndex : int ) : Matrix;

	
	import final function GetBoneReferenceMatrixMS( boneIndex : int ) : Matrix;

	
	import final function GetBoneIndex( bone : name ) : int;
	
	
	import final function GetMoveTarget() : Vector;
	
	
	import final function GetMoveHeading() : float;
	
	
	import final latent function PreloadBehaviorsToActivate( names : array< name > ) : bool;

	
	import final latent function ActivateBehaviors( names : array< name > ) : bool;
	
	import final function ActivateBehaviorsSync( names : array< name > ) : bool; 
	
	
	import final latent function ActivateAndSyncBehaviors( names : array< name >, optional timeout : float ) : bool;
	
	
	import final latent function ActivateAndSyncBehavior( names : name, optional timeout : float ) : bool;
	
	
	import final latent function AttachBehavior( instanceName : name ) : bool;
	
	
	import final function AttachBehaviorSync( instanceName : name ) : bool;
	
	
	import final function DetachBehavior( instanceName : name ) : bool;
	
	
	import final function GetBehaviorVariable( varName : name, optional defaultValue : float ) : float;
	
	
	import final function GetBehaviorVectorVariable( varName : name ) : Vector;
	
	
	import final function SetBehaviorVariable( varName : name, varValue : float, optional inAllInstances : bool ) : bool;
	
	
	import final function SetBehaviorVectorVariable( varName : name, varValue : Vector, optional inAllInstances : bool ) : bool;
	
	
	import final function GetBehaviorGraphInstanceName( optional index : int ) : name;

	
	
	
	
	import final function Fade( fadeIn : bool );
	
	
	import final function SetHideInGame( hide : bool );
	
	
	
	
	import function GetComponent( compName : string ) : CComponent;

	
	import function GetComponentByClassName( className : name ) : CComponent;
	
	
	import function GetComponentsByClassName( className : name ) : array< CComponent >;
	
	import function GetComponentByUsedBoneName( boneIndex : int ) : array< CComponent >;

	
	import function GetComponentsCountByClassName( className : name ) : int;

	import function GetAutoEffect() : name;
	import function SetAutoEffect( effectName : name ) : bool; 
	import function PlayEffect( effectName : name, optional target : CNode  ) : bool;	
	import function PlayEffectOnBone( effectName : name, boneName : name, optional target : CNode ) : bool;
	import function StopEffect( effectName : name ) : bool;
	import function DestroyEffect( effectName : name ) : bool;
	import function StopAllEffects();
	import function DestroyAllEffects();
	
	
	
	import function IsEffectActive( effectName : name, optional treatStoppingAsActive : bool ) : bool;
	
	import function SetEffectIntensity( effectName : name, intensity : float, optional specificComponentName : name, optional effectParameterName : name );
	import function HasEffect( effectName : name ) : bool;
	
	public function PlayEffectSingle( effectName : name, optional target : CNode  ) : bool
	{
		if(!IsEffectActive(effectName, false))
			return PlayEffect(effectName, target);
			
		return false;
	}
	
	public function StopEffectIfActive( effectName : name ) : bool
	{
		if( IsEffectActive(effectName, false) )
		{
			return StopEffect( effectName );
		}
		return false;
	}
	
	public function DestroyEffectIfActive( effectName : name ) : bool
	{
		if( IsEffectActive(effectName, true) )
		{
			return DestroyEffect( effectName );
		}
		return false;
	}
	
	
	import function SoundEvent( eventName : string, optional boneName : name, optional isSlot : bool );

	
	import function TimedSoundEvent(duration : float, optional startEvent : string, optional stopEvent : string, optional shouldUpdateTimeParameter : bool, optional boneName : name);
	
	
	import function SoundSwitch( swichGroupName : string, optional stateName : string, optional boneName : name, optional isSlot : bool );
	
	import function SoundParameter( parameterName : string, value : float, optional boneName : name, optional duration : float, optional isSlot : bool );
	import function SoundIsActiveAny() : bool;
	import function SoundIsActiveName( eventName : name ) : bool;
	import function SoundIsActive( boneName : name, optional isSlot : bool ) : bool;

	import function PreloadEffect( effectName : name ) : bool;
	import function PreloadEffectForAnimation( animName : name ) : bool;
	
	import function SetKinematic( enable : bool );
	import function SetStatic( );
	import function IsRagdolled() : bool;
	import function IsStatic() : bool;
	
	import function GetGuidHash() : int;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	import function CreateAttachment( parentEntity : CEntity, optional entityTemplateSlot : name, optional relativePosition : Vector, optional relativeRotation : EulerAngles ) : bool;
	import function BreakAttachment() : bool;
	import function HasAttachment() : bool;
	import function HasSlot( slotName : name, optional recursive : bool ) : bool;

	
	import function CreateAttachmentAtBoneWS( parentEntity : CEntity, bone : name, worldLocation : Vector, worldRotation : EulerAngles ) : bool;

	import function CreateChildAttachment( child : CNode, optional slot : name ) : bool;
	import function BreakChildAttachment( child : CNode, optional slot : name ) : bool;
	import function HasChildAttachment( child : CNode ) : bool;
	
	event OnCanCreateParentAttachment( parentEntity : CEntity ) { return true; }
	event OnCanBreakParentAttachment( parentEntity : CEntity ) 	{ return true; }
	
	event OnCanCreateChildAttachment( childEntity : CEntity ) 	{ return true; }
	event OnCanBreakChildAttachment( childEntity : CEntity ) 	{ return true; }
	
	event OnParentAttachmentCreated( parentEntity : CEntity ){}
	event OnParentAttachmentBroken( parentEntity : CEntity ){}
	
	event OnChildAttachmentCreated( childEntity : CEntity ){}
	event OnChildAttachmentBroken( childEntity : CEntity ){}
	
	
	function GetReadableName() : string
	{
		var s1,s2 : string;
	
		if( StrSplitLast( ToString(), "::", s1, s2 ) )
		{
			return s2;
		}
		else
		{
			return ToString();
		}
	}
	
	
	function ApplyAppearance( appearanceName : string )
	{
		var comp : CAppearanceComponent;
		comp = (CAppearanceComponent)GetComponentByClassName( 'CAppearanceComponent' );
		if ( comp )
		{
			comp.ApplyAppearance( appearanceName );
		}
	}
	
	function DestroyAfter( time : float )
	{
		AddTimer('DestroyTimer',time,false, , , true);
	}
	
	function StopAllEffectsAfter( time : float )
	{
		AddTimer('StopAllEffectsTimer',time,false, , , true);
	}
	
	private timer function DestroyTimer( delta : float , id : int)
	{
		Destroy();
	}
	
	private timer function StopAllEffectsTimer ( delta : float , id : int)
	{
		StopAllEffects();
	}
	
	public final function RemoveTag(tag : name)
	{
		var tags : array<name>;
		
		tags = GetTags();
		tags.Remove(tag);
		SetTags(tags);
	}
	
	
	
	
	
	
	
	
	protected function SnapComponentByName(componentName : name, maxHeightDown : float, maxHeightUp : float, collisionNames : array<name>, out newPos : Vector) : bool
	{
		var component : CComponent;
		var entityPos, componentPos, testUpPos, testDownPos, collisionNormal : Vector;
				
		component = GetComponent(componentName);		
		if(!component)
		{
			LogAssert(false, "CEntity.SnapComponentToTerrain: cannot snap component <<" + componentName + ">> - cannot find component with such name");
			newPos = Vector(0,0,0);
			return false;
		}
	
		entityPos      = GetWorldPosition();
		componentPos   = entityPos + component.GetLocalPosition();
		
		testUpPos      = componentPos;
		testUpPos.Z   += maxHeightUp;
		testDownPos    = componentPos;
		testDownPos.Z -= maxHeightDown;		

		
		if ( theGame.GetWorld().StaticTrace(componentPos, testDownPos, newPos, collisionNormal, collisionNames) )
		{
			component.SetPosition(newPos - entityPos);	
			return true;
		}
		else
		{
			
			if ( theGame.GetWorld().StaticTrace(componentPos, testUpPos, newPos, collisionNormal, collisionNames) )
			{
				component.SetPosition(newPos - entityPos);	
				return true;
			}
		}
		
		
		newPos = Vector(0,0,-1000);
		component.SetPosition(newPos);
		return false;
	}
	
	
	
	
	
	
	
	
	protected function SnapComponent(component : CComponent, maxHeightDown : float, maxHeightUp : float, collisionNames : array<name>, out newPos : Vector) : bool
	{
		var entityPos, componentPos, testUpPos, testDownPos, collisionNormal : Vector;
		
		if(!component)
		{			
			LogAssert(false, "CEntity.SnapComponentToTerrain: cannot snap component <<" + component + ">> - cannot find component!");
			newPos = Vector(0,0,0);
			return false;
		}
	
		entityPos      = GetWorldPosition();
		componentPos   = entityPos + component.GetLocalPosition();
		
		testUpPos      = componentPos;
		testUpPos.Z   += maxHeightUp;
		testDownPos    = componentPos;
		testDownPos.Z -= maxHeightDown;		

		
		if ( theGame.GetWorld().StaticTrace(componentPos, testDownPos, newPos, collisionNormal, collisionNames) )
		{
			component.SetPosition(newPos);
			return true;
		}
		else
		{
			
			if ( theGame.GetWorld().StaticTrace(componentPos, testUpPos, newPos, collisionNormal, collisionNames) )
			{
				component.SetPosition(newPos);
				return true;
			}
		}
		
		
		newPos = Vector(0,0,0);
		return false;
	}
}

import function EntityHandleGet( handle : EntityHandle ) : CEntity;
import function EntityHandleSet( handle : EntityHandle, entity : CEntity );

import function PreloadEffectForEntityTemplate( entityTemplate : CEntityTemplate, effectName : name ) : bool;
import function PreloadEffectForAnimationForEntityTemplate( entityTemplate : CEntityTemplate, animName : name ) : bool;