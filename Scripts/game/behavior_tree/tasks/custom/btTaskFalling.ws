/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskFalling extends IBehTreeTask
{
	var npc : CNewNPC;
	var drawableComp : CDrawableComponent;
	var fakeBroomHidden, attachedToGround, broomSpawned : bool; 
	
	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		
		fakeBroomHidden = false;
		attachedToGround = false;
		broomSpawned = false;
		
		return BTNS_Active;
	}

	latent function Main() : EBTNodeStatus
	{
		while( npc.GetDistanceFromGround( 30.0 ) > 0.5 )
		{
			SleepOneFrame();
		}
		
		HideFakeBroom();

		OnGroundContact();
		
		SpawnBroom();
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !fakeBroomHidden )
			HideFakeBroom();
		
		if( !attachedToGround )
			OnGroundContact();
		
		if( !broomSpawned )
			SpawnBroom();
	}
	
	private function HideFakeBroom()
	{
		var broom : SItemUniqueId;
		var broomEntity : CEntity;
		
		broom = npc.GetInventory().GetItemFromSlot( 'broom_slot' );
		broomEntity = npc.GetInventory().GetItemEntityUnsafe( broom );
		if( broomEntity )
		{
			drawableComp = (CDrawableComponent)broomEntity.GetComponentByClassName( 'CDrawableComponent' );
			if( drawableComp )
			{
				drawableComp.SetVisible( false );
				
				fakeBroomHidden = true;
			}
		}
	}
	
	private function OnGroundContact()
	{
		var mac : CMovingPhysicalAgentComponent;		
		
		mac = ((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent());
		
		mac.SnapToNavigableSpace( true );
		mac.SetAnimatedMovement( false );
		mac.SetGravity( true );
		
		npc.EnablePhysicalMovement( false );
		
		HitGround();
		
		attachedToGround = true;
	}
	
	private function HitGround()
	{
		npc.PlayEffect( 'hit_ground' );
		
		if( npc.GetStatPercents( BCS_Essence ) > 0.1 )
		{
			npc.DrainEssence( npc.GetStatMax( BCS_Essence ) * 0.05 );
		}
	}
	
	private function SpawnBroom()
	{
		var entityTemplate : CEntityTemplate;
		var entity : CEntity;
		var position : Vector;
		var rotation : EulerAngles;
		
		entityTemplate = (CEntityTemplate)LoadResource( 'broom' );
			
		if( entityTemplate )
		{
			position = npc.GetWorldPosition();
			rotation = npc.GetWorldRotation();
			entity = theGame.CreateEntity( entityTemplate, position, rotation );
			
			broomSpawned = true;
		}
	}
}

class CBTTaskFallingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFalling';
}