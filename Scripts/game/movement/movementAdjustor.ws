/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SMovementAdjustmentRequestTicket {};












import class CMovementAdjustor extends CObject
{
	
	import final function IsRequestActive( ticket : SMovementAdjustmentRequestTicket ) : bool;

	
	import final function HasAnyActiveRequest() : bool;
	import final function HasAnyActiveRotationRequests() : bool;
	import final function HasAnyActiveTranslationRequests() : bool;
	
	
	import final function Cancel( ticket : SMovementAdjustmentRequestTicket );
	
	import final function CancelByName( requestName : name );
	
	import final function CancelAll();
	
	
	import final function CreateNewRequest( optional requestName : name ) : SMovementAdjustmentRequestTicket;
	
	import final function GetRequest( requestName : name ) : SMovementAdjustmentRequestTicket;

	
	import final function AddOneFrameTranslationVelocity( translationVelocity : Vector );
	import final function AddOneFrameRotationVelocity( rotationVelocity : EulerAngles );
	
	
	
	
	import final function BlendIn( ticket : SMovementAdjustmentRequestTicket, blendInTime : float );

	
	import final function KeepActiveFor( ticket : SMovementAdjustmentRequestTicket, duration : float );
	
	import final function AdjustmentDuration( ticket : SMovementAdjustmentRequestTicket, duration : float );
	
	import final function Continuous( ticket : SMovementAdjustmentRequestTicket );
	
	import final function DontEnd( ticket : SMovementAdjustmentRequestTicket );

	
	import final function BaseOnNode( ticket : SMovementAdjustmentRequestTicket, onNode : CNode );
	
	
	import final function BindToEvent( ticket : SMovementAdjustmentRequestTicket, eventName : name, optional adjustDurationOnNextEvent : bool );
	
	import final function BindToEventAnimInfo( ticket : SMovementAdjustmentRequestTicket, animInfo : SAnimationEventAnimInfo, optional bindOnly : bool );

	
	import final function ScaleAnimation( ticket : SMovementAdjustmentRequestTicket, optional scaleAnimation : bool, optional scaleLocation : bool, optional scaleRotation : bool );
	
	import final function ScaleAnimationLocationVertically( ticket : SMovementAdjustmentRequestTicket, optional scaleAnimationLocationVertically : bool );

	
	import final function DontUseSourceAnimation( ticket : SMovementAdjustmentRequestTicket, optional dontUseSourceAnimation : bool );
	
	import final function UpdateSourceAnimation( ticket : SMovementAdjustmentRequestTicket, animInfo : SAnimationEventAnimInfo );
	
	import final function CancelIfSourceAnimationUpdateIsNotUpdated( ticket : SMovementAdjustmentRequestTicket, optional cancelIfSourceAnimationUpdateIsNotUpdated : bool );
	
	import final function SyncPointInAnimation( ticket : SMovementAdjustmentRequestTicket, optional syncPointTime : float );
	
	
	
	
	
	
	import final function UseBoneForAdjustment( ticket : SMovementAdjustmentRequestTicket, optional boneName : name, optional useContinuously : bool, optional useBoneForLocationAdjustmentWeight : float, optional useBoneForRotationAdjustmentWeight : float, optional useBoneToMatchTargetHeadingWeight : float );

	
	import final function MatchEntitySlot( ticket : SMovementAdjustmentRequestTicket, entity : CEntity, slotName : name );
	
	
	import final function KeepLocationAdjustmentActive( ticket : SMovementAdjustmentRequestTicket );
	
	import final function ReplaceTranslation( ticket : SMovementAdjustmentRequestTicket, optional replaceTranslation : bool );
	
	import final function ShouldStartAt( ticket : SMovementAdjustmentRequestTicket, atLocation : Vector );
	
	import final function SlideTo( ticket : SMovementAdjustmentRequestTicket, targetLocation : Vector );
	
	import final function SlideBy( ticket : SMovementAdjustmentRequestTicket, byVector : Vector );
	
	import final function SlideTowards( ticket : SMovementAdjustmentRequestTicket, node : CNode, optional minDistance : float, optional maxDistance : float );
	
	import final function SlideToEntity( ticket : SMovementAdjustmentRequestTicket, entity : CEntity, optional boneName : name, optional minDistance : float, optional maxDistance : float );
	
	import final function MaxLocationAdjustmentSpeed( ticket : SMovementAdjustmentRequestTicket, maxSpeed : float, optional maxSpeedZ : float );
	
	import final function MaxLocationAdjustmentDistance( ticket : SMovementAdjustmentRequestTicket, optional throughSpeed : bool, optional locationAdjustmentMaxDistanceXY : float, optional locationAdjustmentMaxDistanceZ : float );
	
	import final function AdjustLocationVertically( ticket : SMovementAdjustmentRequestTicket, optional adjustLocationVertically : bool );
	
	
	import final function KeepRotationAdjustmentActive( ticket : SMovementAdjustmentRequestTicket );
	
	import final function ReplaceRotation( ticket : SMovementAdjustmentRequestTicket, optional replaceRotation : bool );
	
	import final function ShouldStartFacing( ticket : SMovementAdjustmentRequestTicket, targetHeading : Float );
	
	import final function RotateTo( ticket : SMovementAdjustmentRequestTicket, targetHeading : Float );
	
	import final function RotateBy( ticket : SMovementAdjustmentRequestTicket, byHeading : Float );
	
	import final function RotateTowards( ticket : SMovementAdjustmentRequestTicket, node : CNode, optional offsetHeading : Float );
	
	import final function MatchMoveRotation( ticket : SMovementAdjustmentRequestTicket );
	
	import final function MaxRotationAdjustmentSpeed( ticket : SMovementAdjustmentRequestTicket, rotationAdjustmentMaxSpeed : Float );
	
	import final function SteeringMayOverrideMaxRotationAdjustmentSpeed( ticket : SMovementAdjustmentRequestTicket, optional steeringMayOverrideMaxRotationAdjustmentSpeed : Bool );
	
	
	import final function LockMovementInDirection( ticket : SMovementAdjustmentRequestTicket, heading : Float );
	
	import final function RotateExistingDeltaLocation( ticket : SMovementAdjustmentRequestTicket, optional rotateExistingDeltaLocation : Bool );
	
	
	import final function NotifyScript( ticket : SMovementAdjustmentRequestTicket, notifyObject : IScriptable, eventName : name, notify : EMovementAdjustmentNotify );
	
	import final function DontNotifyScript( ticket : SMovementAdjustmentRequestTicket, notifyObject : IScriptable, eventName : name, notify : EMovementAdjustmentNotify );

	
};