/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskLookat extends IBehTreeTask
{
	var lookatAtStart : bool;
	var useHeadBoneRotation : bool;
	var keepLooking : bool;
	var initKeeplooking : bool;
	var verticalLookAt : bool;
	var setAdditionalBehVar : bool;
	var keepLookingAngle : float;
	var additionalBehVarName : name;
	var headBoneName : name;
	var isCombatTask : bool;
	
	var lookAtTargetCheck : bool;
	
	default lookAtTargetCheck = true;
	
 	function OnActivate() : EBTNodeStatus
	{
		if( lookatAtStart )
		{
			GetNPC().SetBehaviorVariable( 'lookatOn', 1, true);
		}
		
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetBehaviorVariable( 'lookatOn', 0, true);
	}
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var lookatTarget : CEntity;
		
		var targetPos : Vector;
		
		var boneIndex : int;
		var targetBoneIndex : int;
		
		var npcDesiredHeadDir : Vector;
		
		var npcHeadPos : Vector;
		var npcHeadVec : Vector;
		
		var npcHeadDesiredRot : EulerAngles;
		
		var npcHeadToTargetAngle : float;
		var headMatrix : Matrix;
		
		var localHorAngle : float;
		var localVerAngle : float;
		
		var desiredHorAngle : float;
		var desiredVerAngle : float;
		var keepLookingAngleMain : float;

	
		npc = GetNPC();
		
		if( isCombatTask )
		{		
			lookatTarget = GetCombatTarget();
		}
		else
		{
			lookatTarget = (CEntity)GetActionTarget();
			
			if( !lookatTarget )
			{
				return BTNS_Active;
			}
		}

		keepLookingAngleMain = keepLookingAngle / 90;
		
		boneIndex = npc.GetBoneIndex(headBoneName);
		
		if ( lookatTarget )
		{
			targetBoneIndex = lookatTarget.GetBoneIndex(headBoneName);
		}
		else
		{
			return BTNS_Active;
		}
		
		while(true)
		{
			if( boneIndex != -1 )
			{
				headMatrix = npc.GetBoneWorldMatrixByIndex(boneIndex);
				npcHeadPos = MatrixGetTranslation(headMatrix);
				
			}
			else
			{
				npcHeadPos = npc.GetWorldPosition();
			}
			if ( targetBoneIndex != -1 )
			{
				targetPos = MatrixGetTranslation(lookatTarget.GetBoneWorldMatrixByIndex(boneIndex));
			}
			else
			{
				targetPos = lookatTarget.GetWorldPosition();
			}
			npcDesiredHeadDir = targetPos - npcHeadPos;
			
			
			if ( useHeadBoneRotation )
			{
				npcHeadVec = MatrixGetAxisX(headMatrix); 
				localHorAngle = -VecGetAngleDegAroundAxis(npcHeadVec, npcDesiredHeadDir, Vector(0,0,1));
				if ( verticalLookAt )
				{
					localVerAngle = -VecGetAngleDegAroundAxis(npcHeadVec, npcDesiredHeadDir, Vector(1,0,0));
				}
			}
			else
			{
				localHorAngle = -VecGetAngleDegAroundAxis(npc.GetHeadingVector(), npcDesiredHeadDir, Vector(0,0,1));
				if ( verticalLookAt )
				{
					npcHeadDesiredRot = VecToRotation(npcDesiredHeadDir);
					localVerAngle = -npcHeadDesiredRot.Pitch;
				}
			}
			
			
			
			
			
			npc.GetVisualDebug().AddArrow('lookatHeading',npc.GetWorldPosition(), targetPos , 1, 0.3, 0.3, true, Color(0,0,255),false,-1 );
			
			
			
			desiredHorAngle = (localHorAngle)/90;
			
			if( !keepLooking && ( desiredHorAngle <= -1 || desiredHorAngle >= 1 ) )
			{
				desiredHorAngle = 0;
			}
			else if ( keepLooking && desiredHorAngle >= keepLookingAngle || desiredHorAngle < -keepLookingAngle )
			{
				desiredHorAngle = 0;
			}
			
			desiredHorAngle = ClampF(desiredHorAngle,-1.f,1.f);
			npc.SetBehaviorVariable( 'lookatHor', desiredHorAngle, true );
			if ( additionalBehVarName != 'None' && setAdditionalBehVar )
			{
				npc.SetBehaviorVariable( additionalBehVarName, desiredHorAngle, true );
			}
			
			if ( verticalLookAt )
			{
				desiredVerAngle = (localVerAngle)/90;
				desiredVerAngle = ClampF(desiredVerAngle,-1.f,1.f);
				npc.SetBehaviorVariable( 'lookatVer', desiredVerAngle, true );
			}
			
			if ( lookAtTargetCheck ) 
				if ( !npc.SetBehaviorVectorVariable( 'lookAtTarget',targetPos, true ) )
					lookAtTargetCheck = false;
			
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		
		if ( eventName == 'LookatOff' )
		{
			GetNPC().SetBehaviorVariable( 'lookatOn', 0, true );
		}
		else if ( eventName == 'LookatOn' )
		{
			GetNPC().SetBehaviorVariable( 'lookatOn', 1, true );
		}
		else if ( eventName == 'KeepLooking')
		{
			keepLooking = true;
		}
		else if ( eventName == 'ResetKeepLooking')
		{
			keepLooking = initKeeplooking;
		}
		return false;
	}
	
}

class BTTaskLookatDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskLookat';

	editable var lookatAtStart : bool;
	editable var headBoneName : name;
	editable var useHeadBoneRotation : bool;
	editable var keepLooking : bool;
	editable var verticalLookAt : bool;
	editable var setAdditionalBehVar : bool;
	editable var additionalBehVarName : name;
	editable var keepLookingAngle : float;
	editable var isCombatTask : bool;

	hint keepLooking = "keeps looking even if the target is above -90,90 angle range";
	hint verticalLookAt = "down < 0 ; up > 0 ";
	
	default keepLooking = false;
	default useHeadBoneRotation = false;
	default keepLookingAngle = 135;
	default headBoneName = 'head';
	default isCombatTask = true;
}




class BTTaskUpdateLookatTarget extends IBehTreeTask
{
	protected var combatDataStorage 		: CHumanAICombatStorage;

	public var useCombatTarget 				: bool;
	public var useCustomTarget 				: bool;
	public var headBoneName					: name;
	public var usePrediction 				: bool;
	public var addZOffsetValue 				: bool;
	public var disableLookAtOnDeath 		: bool;
	public var disableLookAtOnDeactivate 	: bool;
	
	public var useAnimEvents				: bool;
	
	protected var lookatTarget				: CNode;
	protected var lookatActor				: CActor;
	protected var targetBoneIndex 			: int;
	protected var targetPos					: Vector;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( useCombatTarget )
			lookatTarget = GetCombatTarget();
		else
			lookatTarget = GetActionTarget();
		
		lookatActor = (CActor)lookatTarget;
		
		if ( lookatActor )
		{
			targetBoneIndex = lookatActor.GetBoneIndex('torso3');
			if ( targetBoneIndex == -1 )
				targetBoneIndex = lookatActor.GetBoneIndex('head');
		}
		else
			targetBoneIndex = -1;
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var heading			: float;
		var targetIsActor	: bool;
		var npc				: CActor;
		
		if ( !lookatTarget && !useCustomTarget  )
			return BTNS_Active;
		
		if ( (CActor)lookatTarget )
			targetIsActor = true;
		
		while ( true )
		{
			if ( !npc )
				npc = GetActor();
			
			
			if( useCustomTarget )
			{			
				GetCustomTarget( targetPos, heading );
				if ( addZOffsetValue )
					targetPos.Z += 1;
			}
			else if ( targetBoneIndex != -1 )
			{
				targetPos = MatrixGetTranslation(lookatActor.GetBoneWorldMatrixByIndex(targetBoneIndex));
			}
			else 
			{
				targetPos = lookatTarget.GetWorldPosition();
				if ( addZOffsetValue && targetIsActor )
					targetPos.Z += 1.5;
			}
			
			if ( usePrediction && lookatActor )
			{
				targetPos = PredictPosition( lookatActor, targetPos );
			}
			
			GetActor().UpdateLookAtVariables(1.0, targetPos);
			
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( disableLookAtOnDeactivate )
		{
			GetActor().UpdateLookAtVariables(0.0, targetPos);
		}
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( disableLookAtOnDeath && eventName == 'OnDeath' )
		{
			GetActor().UpdateLookAtVariables(0.0, targetPos);
			return true;
		}
		return false;
	}
	
	function PredictPosition( target : CActor, targetPos : Vector ) : Vector
	{
		var myPos, finalPos : Vector;
		var distanceToTarget : float;
		var targetMoveHeadingVect : Vector;
		var targetSpeed : float;
		var proj : W3AdvancedProjectile;
		var time : float;
		
		if ( !target )
			return targetPos;
		
		myPos = GetActor().GetWorldPosition();
		
		targetMoveHeadingVect = target.GetMovingAgentComponent().GetVelocity();
		targetSpeed = VecLength(targetMoveHeadingVect);
		
		if ( targetSpeed <= 0 )
		{
			return targetPos;
		}
		
		distanceToTarget = VecDistance(myPos,targetPos);
		
		proj = combatDataStorage.GetProjectile();
		
		if ( proj )
			time = distanceToTarget/proj.projSpeed;
		else
			time = distanceToTarget/40;
		
		finalPos = targetPos + VecNormalize(targetMoveHeadingVect)*(time*targetSpeed);
		
		return finalPos;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		
		if ( eventName == 'LookatOff' )
		{
			GetNPC().SetBehaviorVariable( 'lookatOn', 0, true );
		}
		else if ( eventName == 'LookatOn' )
		{
			GetNPC().SetBehaviorVariable( 'lookatOn', 1, true );
		}
		return false;
	}
	
	function Initialize()
	{
		if ( usePrediction )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class BTTaskUpdateLookatTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskUpdateLookatTarget';

	editable var useCombatTarget 			: bool;
	editable var headBoneName 				: name;
	editable var usePrediction 				: bool;
	editable var useCustomTarget 			: bool;
	editable var addZOffsetValue 			: bool;
	editable var disableLookAtOnDeath 		: bool;
	editable var disableLookAtOnDeactivate 	: bool;
	
	editable var useAnimEvents				: bool;
	
	default useCombatTarget 				= true;
	default headBoneName 					= 'head';
	default usePrediction 					= false;
	default addZOffsetValue 				= true;
	default disableLookAtOnDeath 			= true;
	
	default useAnimEvents 					= false;
	hint useAnimEvents = "Enabled allows anim events to turn on and off LookAts";
	hint addZOffsetValue = "works only if headBone was not found. +1.f for custom target; +1.5f otherwise.";
	hint usePrediction = "works only if target is CActor.";
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'OnDeath' );
	}
}



class BTTaskAimingUpdateLookatTarget extends BTTaskUpdateLookatTarget
{
	function PredictPosition( target : CActor, targetPos : Vector ) : Vector
	{
		var submergeDepth : float;
		
		if( target == thePlayer && thePlayer.OnCheckDiving() )
		{
			submergeDepth = ( (CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent() ).GetSubmergeDepth();
			if( submergeDepth < -5 )
			{
				targetPos.X += RandRangeF( 0.75, -0.75 );
				targetPos.Y += RandRangeF( 0.75, -0.75 );
				targetPos.Z += RandRangeF( 0.75, -0.75 );
			}
			
			return targetPos;
		}
		else
			return super.PredictPosition( target, targetPos );
	}
}

class BTTaskAimingUpdateLookatTargetDef extends BTTaskUpdateLookatTargetDef
{
	default instanceClass = 'BTTaskAimingUpdateLookatTarget';

	default usePrediction = true;
}




class BTTaskUpdateLookatTargetByTag extends BTTaskUpdateLookatTarget
{
	public var targetTag 	: name;
	
	function OnActivate() : EBTNodeStatus
	{
		lookatTarget = theGame.GetEntityByTag(targetTag);
		lookatActor = (CActor)lookatTarget;
		
		if ( lookatActor )
			targetBoneIndex = lookatActor.GetBoneIndex( headBoneName );
		else
			targetBoneIndex = -1;
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		lookatTarget = NULL;
		GetActor().SetBehaviorVariable( 'lookatOn', 0.f, true );
	}
	
}

class BTTaskUpdateLookatTargetByTagDef extends BTTaskUpdateLookatTargetDef
{
	default instanceClass = 'BTTaskUpdateLookatTargetByTag';

	editable var targetTag 		: CBehTreeValCName;
	
	default useCombatTarget = false;
	default useCustomTarget = false;
	default usePrediction = false;
}