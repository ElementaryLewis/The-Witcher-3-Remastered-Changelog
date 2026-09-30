/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskIrisTask extends IBehTreeTask
{}
class BTTaskIrisSpawn extends BTTaskIrisTask
{
	
	
	
	private var m_Painting : CEntity;
	
	
	function OnActivate() : EBTNodeStatus
	{
		var l_iris 		: 	W3NightWraithIris;
		
		l_iris = (W3NightWraithIris) GetNPC();
		
		m_Painting = (CEntity) l_iris.GetClosestPainting();
		
		
		
		
		
		return BTNS_Active;
	}
	
	
	private function OnDeactivate()
	{
		m_Painting.StopEffect('ghost_appear');
	}

}



class BTTaskIrisSpawnDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisSpawn';
}