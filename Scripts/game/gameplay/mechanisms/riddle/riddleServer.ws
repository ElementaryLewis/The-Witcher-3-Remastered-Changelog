/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3RiddleServer extends CGameplayEntity
{
	editable inlined var OnGoodCombinationEvents 	: array< W3SwitchEvent >;	
	
	saved var pairedNodes					: array <EntityHandle>;
	saved var riddleNodesNumber 			: int;
	saved var isDisabled 					: bool;
	
	var nodesAtValidPosNumber				: int;
	
	public function UpdatePairedRiddleNodes ()
	{
		var  i : int;
		var  k : int;
		var playEffect : bool;
		var changed : bool;
		
		var currentPairedRiddleNodesIds : array <int>;
		
		var currentNode			: W3RiddleNode;
		var pairedNode			: W3RiddleNode;
		var notPairedNode 		: CEntity;
		var notPairedNodeName	: string;

		changed = true;
		while( changed )
		{
			changed = false;
			for ( i = 0; i < pairedNodes.Size (); i+= 1 )
			{
				pairedNode = (W3RiddleNode)EntityHandleGet( pairedNodes[i] );
				
				if ( !pairedNode )
				{
					notPairedNode = EntityHandleGet( pairedNodes[i] );
					notPairedNodeName = notPairedNode.GetName();
					LogAssert( false, "Handled entity array" + notPairedNodeName + " contains an entity which is not a W3RiddleNode" );
					continue;
				}
				
				playEffect = false;
				for (  k = 0; k < pairedNode.positions[ pairedNode.currentPos].pairedRiddleNodes.Size (); k+= 1 )
				{
					currentNode = (W3RiddleNode)theGame.GetEntityByTag ( pairedNode.positions[ pairedNode.currentPos].pairedRiddleNodes[k].pairedRiddleNodeTag );
					
					if ( currentNode.isEffectOn && currentNode.currentPos == pairedNode.positions[ pairedNode.currentPos].pairedRiddleNodes[k].pairedRiddleNodeRequiredPos )
					{
						playEffect = true;
						currentPairedRiddleNodesIds.PushBack ( k );
						pairedNode.PlayExternalEffectOnpairedNodeByID( k );
						
					}
					else
					{
						pairedNode.StopExternalEffectOnpairedNodeByID( k );
					}
				}
				pairedNode.SetCurrentPairedRiddleNodesIds ( currentPairedRiddleNodesIds );
				
				if( playEffect && !pairedNode.isEffectOn )
				{
					pairedNode.PlayEffects ();
					changed = true;
				}
				else if ( !playEffect && pairedNode.isEffectOn )
				{
					pairedNode.StopEffects ();
					changed = true;
				}
			}
		}
		
	}
	public function AddPairedRiddleNode ( riddleNode : W3RiddleNode )
	{
		var riddleNodeHandle		: EntityHandle;
		
		EntityHandleSet(riddleNodeHandle, riddleNode);
		pairedNodes.PushBack ( riddleNodeHandle );
	}
	
	public function AddRiddleNode ()
	{
		riddleNodesNumber +=1;
	}
	
	public function AddValidPosition ()
	{
		nodesAtValidPosNumber	 +=1;
		CheckCombination ();
	}
	
	public function CheckCombination ()
	{
		var combinationNumber : int;
		
		if ( nodesAtValidPosNumber == riddleNodesNumber )
		{
			ActivateEvents ( OnGoodCombinationEvents );
			isDisabled = true;
		}
	}
	public function  RemoveValidPosition ()
	{
		nodesAtValidPosNumber	 -=1;
	}
	
	private function ActivateEvents( events : array< W3SwitchEvent > )
	{
		var i, size : int;
		
		if ( isDisabled )
		{
			return;
		}
		size = events.Size();
		for( i = 0; i < size; i += 1 )
		{
			if ( events[ i ] )
			{
				events[ i ].TriggerArgNode( this, thePlayer );
			}
		}
	}
}