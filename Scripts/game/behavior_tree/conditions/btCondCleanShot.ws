/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondCleanShot extends IBehTreeTask
{	
	var doStaticTraceOnNavTestFailure : bool;
	var useCombatTarget : bool;
	var owner : CActor;
	var target : CNode;
	var ownerPos : Vector;
	var targetPos : Vector;
	var res : bool;
	
	function IsAvailable() : bool
	{
		res = NavTest();
		
		if( res )
			return true;
		else if( doStaticTraceOnNavTestFailure )
			return StaticTrace();
		else
			return false;
	}
	
	function FillOwnerAndTarget()
	{
		owner = GetActor();
		
		if ( useCombatTarget )
			target = GetCombatTarget();
		else
			target = GetActionTarget();
	}
	
	function NavTest() : bool
	{	
		FillOwnerAndTarget();
		
		ownerPos = owner.GetWorldPosition();
		targetPos = target.GetWorldPosition();
		
		return theGame.GetWorld().NavigationLineTest( ownerPos, targetPos, 1.5, false, true );
	}
	
	function StaticTrace() : bool 
	{
		var traceStartPos, traceEndPos, traceEffect, normal : Vector;
		var targetEntity : CGameplayEntity;
		var headBoneIdx : int;
		var entMat : Matrix;
		
		FillOwnerAndTarget();
		
		traceStartPos = ownerPos;
		traceStartPos.Z += ((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).GetCapsuleHeight() * 0.75;
		
		if ( (CActor)target )
		{
			headBoneIdx = ((CActor)target).GetHeadBoneIndex();
			if ( headBoneIdx >= 0 )
			{
				traceEndPos = MatrixGetTranslation( ((CActor)target).GetBoneWorldMatrixByIndex( headBoneIdx ) );
			}
			else
			{
				traceEndPos = targetPos;
				traceEndPos.Z += ((CMovingPhysicalAgentComponent)((CActor)target).GetMovingAgentComponent()).GetCapsuleHeight() * 0.75;
			}
		}
		else if ( (CGameplayEntity)target )
		{
			targetEntity = (CGameplayEntity)target;
			if ( !( targetEntity.aimVector.X == 0 && targetEntity.aimVector.Y == 0 && targetEntity.aimVector.Z == 0 ) )
			{
				entMat = targetEntity.GetLocalToWorld();
				targetPos = VecTransform( entMat, targetEntity.aimVector );
			}
		}
		else
		{
			traceEndPos = targetPos;
		}
		
		
		
		if( theGame.GetWorld().StaticTrace( traceStartPos, traceEndPos, traceEffect, normal ) )
		{
			return false;
		}
		else
			return true;
	}
};


class CBTCondCleanShotDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondCleanShot';

	editable var doStaticTraceOnNavTestFailure : bool;
	editable var useCombatTarget : bool;
	
	default doStaticTraceOnNavTestFailure = true;
	default useCombatTarget = true;
};
