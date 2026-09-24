/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskActivateRift extends CBTTaskAttack
{
	public var resourceNameRift : name;
	public var resourceNameGround : name;
	public var entityRiftTemplate : CEntityTemplate;
	public var entityGroundTemplate : CEntityTemplate;
	
	private var targetPos : Vector;
	private var targetRot : EulerAngles;
	private var heightOffset : float;
	private var entityRift : CEntity;
	private var entityGround : CEntity;
	private var casterPos : Vector;
	private var riftPos	: Vector;
	private var rift : CRiftEntity;
	private var ground : CRiftEntity;
	private var npc : CNewNPC;
	
	default heightOffset = 1.5;
	
	private var couldntLoadResource : bool;
	
	function IsAvailable() : bool
	{
		if ( couldntLoadResource )
		{
			return false;
		}
		
		return super.IsAvailable();
	}
	
	latent function Main() : EBTNodeStatus
	{
		var res : EBTNodeStatus;
		
		entityRiftTemplate = (CEntityTemplate)LoadResourceAsync( resourceNameRift );
		entityGroundTemplate = (CEntityTemplate)LoadResourceAsync( resourceNameGround );
		
		if ( !entityRiftTemplate || !entityGroundTemplate )
		{
			couldntLoadResource = true;
			return BTNS_Failed;
		}
		
		res = super.Main();
		
		return res;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		npc = GetNPC();
		casterPos = npc.GetWorldPosition();
		
		if ( animEventName == 'OpenRift' )
		{
			riftPos = casterPos;
			riftPos.Z += 6;
			entityRift = theGame.CreateEntity( entityRiftTemplate, riftPos);
			entityGround = theGame.CreateEntity( entityGroundTemplate, casterPos);
			if( entityRift )
			{
				rift = (CRiftEntity)( entityRift );
				ground = (CRiftEntity)( entityGround );
				
				if( rift || ground )
				{
					rift.closeAfter = 3;
					ground.closeAfter = 3;
					ground.ActivateRift();
					rift.ActivateRift();
					return true;
				}
				return false;
			}
			return false;
		}
		return false;
	}
}

class CBTTaskActivateRiftDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskActivateRift';

	editable var resourceNameRift : name;
	editable var resourceNameGround : name;
	
	default resourceNameRift = 'projectile_rift';
}
