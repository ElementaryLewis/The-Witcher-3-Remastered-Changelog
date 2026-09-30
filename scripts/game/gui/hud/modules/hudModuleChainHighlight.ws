/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SHudWeakspotReference
{
	var entity : CEntity;
	var activeStatus : EWeakspotStatus;
	var type : EWeakspotType;
	var boneIdx : int;
	var identifier : string;
	var gfxPushed : bool; default gfxPushed = false;
	var markedForDelete : bool; default markedForDelete = false;
}

enum EWeakspotStatus
{
	EWS_Active,
	EWS_Inactive,
	EWS_Invisible
}

enum EWeakspotType
{
	EWT_Normal,
	EWT_Deadly
}


class CR4HudModuleChainHighlight extends CR4HudModuleBase
{	
	var m_weakspots : array<SHudWeakspotReference>;
	
	private var m_flashValueStorage : CScriptedFlashValueStorage;
	private	var m_fxRemoveWeakspotData				: CScriptedFlashFunction;
	private	var m_fxUnremoveWeakspotData			: CScriptedFlashFunction;
	private	var m_fxSetTimeDelta				: CScriptedFlashFunction;
	
	private var m_minDistance : float; default m_minDistance = 1;
	private var m_maxDistance : float; default m_maxDistance = 5;
	private var m_minDistanceScale : float; default m_minDistanceScale = 1.1;
	private var m_maxDistanceScale : float; default m_maxDistanceScale = 0.5;
	private var m_transitionTime : float; default m_transitionTime = 0.3;

	private var m_debugEnabled : bool; default m_debugEnabled = false;
	private var m_lastDebugText : string;

	private var m_addedWeakspots : int; default m_addedWeakspots = 0;

	
	
	
	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "ScaleOnly";
		
		flashModule 			= GetModuleFlash();
		m_flashValueStorage 	= GetModuleFlashValueStorage();
		
		m_fxRemoveWeakspotData	= flashModule.GetMemberFlashFunction( "removeWeakspotData" );
		m_fxUnremoveWeakspotData	= flashModule.GetMemberFlashFunction( "unremoveWeakspotData" );
		m_fxSetTimeDelta = flashModule.GetMemberFlashFunction( "setTimeDelta" );
		
		super.OnConfigUI();
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('ChainHighlightModule', true);
		}
	}
		
	function GetWeakspotGFxData( weakspot : SHudWeakspotReference, out gfxDataObj : CScriptedFlashObject, initialSet : bool )
	{
		var screenPos : Vector; 
		var scale : float;
		gfxDataObj.SetMemberFlashString("identifier", weakspot.identifier);
		if(weakspot.activeStatus == EWS_Active)
			gfxDataObj.SetMemberFlashString("status", "active");
		else if(weakspot.activeStatus == EWS_Inactive)
			gfxDataObj.SetMemberFlashString("status", "inactive");
		else 
			gfxDataObj.SetMemberFlashString("status", "invisible");

		if(weakspot.type == EWT_Normal)
			gfxDataObj.SetMemberFlashString("type", "normal");
		else if(weakspot.type == EWT_Deadly)
			gfxDataObj.SetMemberFlashString("type", "deadly");

		AddDebugText("ID: " + weakspot.identifier + " Act: " + weakspot.activeStatus + " Type: " + weakspot.type);
		
		GetScreenPos(weakspot.entity, weakspot.boneIdx, screenPos);
		scale = GetWeakspotScale(weakspot.entity, weakspot.boneIdx);
		gfxDataObj.SetMemberFlashNumber("scaleX", scale);
		gfxDataObj.SetMemberFlashNumber("scaleY", scale);
		
		gfxDataObj.SetMemberFlashNumber("x", screenPos.X);
		gfxDataObj.SetMemberFlashNumber("y", screenPos.Y);
		
		gfxDataObj.SetMemberFlashNumber("transitionTime", m_transitionTime);
		
		gfxDataObj.SetMemberFlashBool("initialSet", initialSet);

		AddDebugText(" | ScreenPos: " + screenPos.X + " " + screenPos.Y);
	}
		
	event OnTick( timeDelta : float )
	{
		var i : int;
		var l_Ref : SHudWeakspotReference;
		var gfxAddNeeded : bool = false;
		var gfxDataArray : CScriptedFlashArray;
		var gfxDataObj	: CScriptedFlashObject;

		m_flashValueStorage.SetFlashString("weakspot.debug", m_lastDebugText);
		m_lastDebugText = "";
		
		gfxDataArray = m_flashValueStorage.CreateTempFlashArray();

		AddDebugText("DataArray created | ");
		
		m_fxSetTimeDelta.InvokeSelfOneArg( FlashArgNumber(timeDelta) );

		AddDebugText("TimeDelta: " + timeDelta + " | ");
		
		CheckVisibility();

		AddDebugText("Visibility checked: " + m_weakspots.Size() + " weakspots" + NewlineChar());

		AddDebugText("Checking if new weakspots need to be added" + NewlineChar());
		
		for(i = 0; i < m_weakspots.Size(); i+=1)
		{
			if(!m_weakspots[i].gfxPushed)
			{
				AddDebugText(NewlineChar() + "New character push: ");
				gfxAddNeeded = true;
				m_weakspots[i].gfxPushed = true;
				
			
				gfxDataObj = m_flashValueStorage.CreateTempFlashObject();	
				GetWeakspotGFxData(m_weakspots[i], gfxDataObj, true);
				gfxDataArray.PushBackFlashObject(gfxDataObj);
			}
		}
		
		if(gfxAddNeeded)
		{
			AddDebugText(NewlineChar() + "GFX Add Called");
			m_flashValueStorage.SetFlashArray("weakspot.add", gfxDataArray);
		}

		AddDebugText(NewlineChar() + "New weakspot phase over");
		
		AddDebugText(NewlineChar() + "Update start" + NewlineChar());

		gfxDataArray = m_flashValueStorage.CreateTempFlashArray();
		for(i = 0; i < m_weakspots.Size(); i+=1)
		{
			AddDebugText(NewlineChar() + "Update: ");
			l_Ref = m_weakspots[i];
			
			gfxDataObj = m_flashValueStorage.CreateTempFlashObject();	
			GetWeakspotGFxData(l_Ref, gfxDataObj, false);
			gfxDataArray.PushBackFlashObject(gfxDataObj);
		}

		AddDebugText(NewlineChar() + "Update end");
		
		m_flashValueStorage.SetFlashArray("weakspot.updateData", gfxDataArray);
		AddDebugText(NewlineChar() + NewlineChar() + "Script Finished In Order");
	}	
	
	function GetOppositeCameraScreenPos( worldPos : Vector, out x : float, out y : float )
	{
		var camera : CCustomCamera;
		var oppositeCamHeading : float;
		var playerToTargetHeading	: float;
		var angleDiff : float;
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		oppositeCamHeading = camera.GetHeading() + 180.f;
		playerToTargetHeading = VecHeading( worldPos - thePlayer.GetWorldPosition() );
		angleDiff = AngleDistance( oppositeCamHeading, playerToTargetHeading );
		x = -angleDiff/90;
		y = 1.f;
	}
	
	function WorldToScreen(worldPos : Vector, out screenPos : Vector)
	{
		if( !theCamera.WorldVectorToViewRatio( worldPos, screenPos.X, screenPos.Y ) )
		{
			GetOppositeCameraScreenPos( worldPos, screenPos.X, screenPos.Y );
		}
	}
	
	function GetScreenPos(entity : CEntity, boneIdx : int, out screenPos : Vector)
	{
		var worldPos : Vector;
		
		var hud : CR4ScriptedHud;
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		worldPos = entity.GetBoneWorldPositionByIndex(boneIdx);
		WorldToScreen(worldPos, screenPos);
		
		screenPos.X = ( screenPos.X + 1 ) / 2;
		screenPos.Y = ( screenPos.Y + 1 ) / 2;
		
		if(hud)
			screenPos = hud.GetScaleformPoint( screenPos.X, screenPos.Y );
	}
	
	public function GetIdentifier(entity : CEntity, boneIdx : int) : string
	{
		return m_addedWeakspots + "_" + boneIdx;
	}
	
	public function AddWeakspotReference(entity : CEntity, boneIdx : int, status : EWeakspotStatus, type : EWeakspotType):SHudWeakspotReference
	{
		var newRef : SHudWeakspotReference;
		var i : int;
		var l_Ref : SHudWeakspotReference;
		
		for(i = 0; i < m_weakspots.Size(); i+=1)
		{
			l_Ref = m_weakspots[i];
			if(l_Ref.entity == entity && l_Ref.boneIdx == boneIdx)
			{
				
				
				if(l_Ref.markedForDelete)
					UnremoveWeakspotReference(entity, boneIdx, status);
				return l_Ref;
			}
		}
		
		newRef.entity = entity;
		newRef.boneIdx = boneIdx;
		newRef.identifier = GetIdentifier(entity, boneIdx);
		newRef.activeStatus = status;
		newRef.type = type;
				
		m_weakspots.PushBack(newRef);
		m_addedWeakspots+=1;
		
		return newRef;
	}
	
	public function RemoveWeakspotReference(entity : CEntity, boneIdx : int):void
	{
		var i : int;
		var l_Ref : SHudWeakspotReference;
		
		for(i = 0; i < m_weakspots.Size(); i+=1)
		{
			l_Ref = m_weakspots[i];
			if(l_Ref.entity == entity && l_Ref.boneIdx == boneIdx)
			{
				m_weakspots[i].markedForDelete = true;
				m_fxRemoveWeakspotData.InvokeSelfOneArg( FlashArgString(l_Ref.identifier) );
				break;
			}
		}
	}
	
	public function UnremoveWeakspotReference(entity : CEntity, boneIdx : int, status : EWeakspotStatus):void
	{
		var i : int;
		var l_Ref : SHudWeakspotReference;
		
		for(i = 0; i < m_weakspots.Size(); i+=1)
		{
			l_Ref = m_weakspots[i];
			if(l_Ref.entity == entity && l_Ref.boneIdx == boneIdx && l_Ref.markedForDelete)
			{
				m_weakspots[i].markedForDelete = false;
				m_weakspots[i].activeStatus = status;
				m_fxUnremoveWeakspotData.InvokeSelfTwoArgs( FlashArgString(l_Ref.identifier), FlashArgString(l_Ref.activeStatus));
				break;
			}
		}
	}
	
	event  OnFinalizeRemoval(identifier : string):void
	{
		var i : int;
		var l_Ref : SHudWeakspotReference;
		
		for(i = 0; i < m_weakspots.Size(); i+=1)
		{
			l_Ref = m_weakspots[i];
			if(l_Ref.identifier == identifier)
			{
				m_weakspots.Erase(i);
				break;
			}
		}
	}
	
	public function UpdateWeakspotReferenceStatus(entity : CEntity, boneIdx : int, newStatus : EWeakspotStatus):void
	{
		var i : int;
		var l_Ref : SHudWeakspotReference;
		
		for(i = 0; i < m_weakspots.Size(); i+=1)
		{
			l_Ref = m_weakspots[i];
			if(l_Ref.entity == entity && l_Ref.boneIdx == boneIdx)
			{
				m_weakspots[i].activeStatus = newStatus;
				LogChannel('JIFIX', m_weakspots[i].identifier + " is set to " + newStatus);
			}
		}
	}
	
	function CalcDistanceFromCamera(point : Vector):float
	{
		var camera : CCustomCamera;
		var camPos : Vector;
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		camPos = camera.GetWorldPosition();
		
		return VecDistance(camPos, point);
	}
	
	function GetWeakspotScale(entity : CEntity, boneIdx : int):float
	{
		var distance : float;
		var worldPos : Vector;
		var progress : float;
		
		worldPos = entity.GetBoneWorldPositionByIndex(boneIdx);
		distance = CalcDistanceFromCamera(worldPos);
		
		if(distance <= m_minDistance)
			return m_minDistanceScale;
		else if (distance >= m_maxDistance)
			return m_maxDistanceScale;
		else
		{
			progress = (distance - m_minDistance) / (m_maxDistance - m_minDistance);
			
			return m_minDistanceScale + progress * (m_maxDistanceScale - m_minDistanceScale);
		}
	}
	
	function CheckVisibility():void
	{
		ShowElement(true);
		
	}
	
	public function GetMinDistance():float
	{
		return m_minDistance;
	}
	
	public function GetMaxDistance():float
	{
		return m_maxDistance;
	}
	
	public function GetMinDistanceScale():float
	{
		return m_minDistanceScale;
	}
	
	public function GetMaxDistanceScale():float
	{
		return m_maxDistanceScale;
	}
	
	public function SetMinDistance(value : float)
	{
		m_minDistance = value;
	}
	
	public function SetMaxDistance(value : float)
	{
		m_maxDistance = value;
	}
	
	public function SetMinDistanceScale(value : float)
	{
		m_minDistanceScale = value;
	}
	
	public function SetManDistanceScale(value : float)
	{
		m_maxDistanceScale = value;
	}
	
	public function SetAllStatus(status : EWeakspotStatus)
	{
		var i : int = 0;
		
		for(i = 0; i < m_weakspots.Size(); i+=1)
		{
			m_weakspots[i].activeStatus = status;
		}
	}

	public function AddDebugText(text : String)
	{
		if(m_debugEnabled)
			m_lastDebugText += text;
	}

	public function SetDebugEnabled(val : bool)
	{
		if(val != m_debugEnabled)
		{
			m_debugEnabled = val;
			m_flashValueStorage.SetFlashBool("weakspot.debug.enabled", m_debugEnabled);
		}
	}
}

function GetChainHUDElement() : CR4HudModuleChainHighlight
{
	var hud : CR4ScriptedHud;
	var chainModule : CR4HudModuleChainHighlight;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
					
	if (hud)
	{
		chainModule = (CR4HudModuleChainHighlight)hud.GetHudModule("ChainHighlightModule");
	}
	
	return chainModule;
}

exec function inv()
{
	GetChainHUDElement().SetAllStatus(EWS_Invisible);
}

exec function act()
{
	GetChainHUDElement().SetAllStatus(EWS_Active);
}

exec function inact()
{
	GetChainHUDElement().SetAllStatus(EWS_Inactive);
}