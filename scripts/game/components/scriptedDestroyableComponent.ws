/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EScriptedDetroyableComponentState
{
	DC_Idle,
	DC_PreDestroy,
	DC_Destroy,
	DC_PostDestroy
};


import abstract class CScriptedDestroyableComponent extends CRigidMeshComponent
{
	editable var distanceValue		  : float;
	editable var destroyTimeDuration  : float;
	editable var contactDestroyDelay  : float;
	editable var destroyAtTime		  : float;
	
	import final function GetDestroyWay() : EDestroyWay;
	
	
	
	
	function GetDistanceToTargetValue() : float
	{
		return distanceValue; 
	}
	
	function GetDestroyTimeDurationValue() : float
	{
		return destroyTimeDuration; 
	}
	
	function GetContactDestroyDelayValue() : float
	{
		return contactDestroyDelay; 
	}
	
	function GetDestroyAtTimeValue() : float
	{
		return destroyAtTime; 
	}
	
	
	
	import function GetDestroyAtTime() : float; 
	
	import function GetDestroyTimeDuration() : float; 
	
	function IdleTick(time : float);
	function PreDestroyTick(time : float);
	
	function DestroyTick(time : float);
	function PostDestroyTick(time : float);
	
	var						m_state : EScriptedDetroyableComponentState;
	default					m_state = DC_Idle;
	
	private				var entryTime	: float;
	private				var timerInterval	: float;
	
	default 			timerInterval = 0.100f;
	default 			entryTime = 0.0f;
}

class CFloePiece extends CScriptedDestroyableComponent
{
	var totalTime : float;
	var currPosition  : Vector;
	
	final function IdleTick(time : float)
	{
		totalTime = 0;
	}
	final function PreDestroyTick(time : float)
	{
		totalTime+=time;
		
		currPosition = GetLocalPosition();
		
		SetPosition(Vector(currPosition.X,currPosition.Y,SinF(10*totalTime)/20));
		
		if(totalTime>this.GetDestroyTimeDurationValue())
		{
			m_state = DC_Destroy;
			totalTime = 0;
		}
	}
	final function DestroyTick(time : float)
	{
		totalTime+=time;
		m_state = DC_PostDestroy;
	}
	final function PostDestroyTick(time : float)
	{
	}
}

class CBridgePiece extends CScriptedDestroyableComponent
{
	var entityPos : Vector;
	var compPos : Vector;
	var totalTime : float;
	var z : CEntity;
	
	final function IdleTick(time : float)
	{
		totalTime = 0;
	}
	final function PreDestroyTick(time : float)
	{
		totalTime+=time;
		
		entityPos = GetEntity().GetWorldPosition();
		compPos = ((CNode)this).GetWorldPosition() - entityPos;
		
		SetPosition(Vector(compPos.X,compPos.Y,SinF(totalTime*5)*0.1f));
		
		if(totalTime<GetContactDestroyDelayValue())
		{
			return;
		}
		
		if(totalTime>this.GetDestroyTimeDurationValue())
		{
			m_state = DC_Destroy;
			totalTime = 0;
		}
	}
	final function DestroyTick(time : float)
	{
		totalTime+=time;
		m_state = DC_PostDestroy;
	}
	final function PostDestroyTick(time : float)
	{
	}
}