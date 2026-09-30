/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskElementalThrow extends IBehTreeTask
{
	var physicalComponent : CMeshComponent;
	var objectEntity : CEntityTemplate;
	var object : CEntity;
	
	function OnActivate() : EBTNodeStatus
	{
		GetActor().PlayEffect('fire_hand');
		
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		var resultForce : Vector;
		var spawnPos, targetPos : Vector;
		
		var owner : CActor = GetActor();
		var objectRot : EulerAngles;
		var objectPos : Vector;
		
		if ( physicalComponent && ( animEventName == 'Throw' ) && object )
		{
			
			
			
			spawnPos = physicalComponent.GetWorldPosition();
			targetPos = GetCombatTarget().GetWorldPosition();
			
			
			object.PlayEffect('fire_fx');
			GetActor().StopEffect('fire_hand');
			
			if ( GetCombatTarget() == thePlayer )
			{
				if ( !thePlayer.IsInCombatAction() )
				{
					
					
					
					if(theInput.GetActionValue( 'GI_AxisLeftX' ) != 0 || theInput.GetActionValue( 'GI_AxisLeftY' ) != 0)
						targetPos += 1.5*VecNormalize(VecFromHeading(thePlayer.rawPlayerHeading));
				}
			}
			
			
			
			
			resultForce = targetPos - spawnPos;
			resultForce = VecNormalize( resultForce );
			
			resultForce *= 20;
			
			
			
			
			
			physicalComponent.SetPhysicalObjectLinearVelocity( resultForce );
			physicalComponent.SetPhysicalObjectAngularVelocity( resultForce );
			
			((W3MonsterElementalArm)object).SetIsActive(true);
			
			return true;
		}
		else if ( animEventName == 'Prepare' )
		{
			
			objectPos = owner.GetWorldPosition() + owner.GetHeadingVector();
			objectRot = owner.GetWorldRotation();
			objectPos.Z += 5.5;
			object = theGame.CreateEntity( objectEntity, objectPos, objectRot );
			
			physicalComponent = (CMeshComponent)(object.GetComponentByClassName('CRigidMeshComponent'));
			
			if( physicalComponent )
			{
				physicalComponent.SetVisible(false);
			}
			
			
			
			((W3MonsterElementalArm)object).SetOwner( owner );
			
		}
		
		return false;
	}
	
}

class CBTTaskElementalThrowDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskElementalThrow';

	editable var objectEntity : CEntityTemplate;
}
