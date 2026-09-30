/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EBookDirection
{
	BD_left,
	BD_right
}




storyscene function BooksMinigameInit( player: CStoryScenePlayer, minigameTag: name )
{
	var minigameManager: CBooksMinigameManager;
	
	minigameManager = (CBooksMinigameManager) theGame.GetNodeByTag( minigameTag );
	
	minigameManager.init();
}

storyscene function BooksMinigameSwitch( player: CStoryScenePlayer, minigameTag: name, slotNumber: int, direction: EBookDirection )
{
	var minigameManager: CBooksMinigameManager;
	
	minigameManager = (CBooksMinigameManager) theGame.GetNodeByTag( minigameTag );
	
	minigameManager.MoveBook( slotNumber, direction );
}





class CBooksMinigameManager extends CGameplayEntity
{
	editable var minigameWonFact: string;
	editable var bookSlotTags: array<name>;
	editable var bookTags: array<name>;
	
	var bookSlots: array<CBookMinigameSlot>;
	var books: array<CBookMinigameBook>;


	
	function init()
	{
		var i: int;
		var loopSlot: CBookMinigameSlot;
		var loopEntity: CBookMinigameBook;
		var slotPos: Vector;
		
		
		bookSlots.Clear();
		books.Clear();
		
		
		if( bookSlotTags.Size() > 0 )
		{
			for( i = 0; bookSlotTags.Size() > i; i += 1 )
			{
				loopSlot = (CBookMinigameSlot) theGame.GetNodeByTag( bookSlotTags[i] );
				loopSlot.init();
				
				bookSlots.PushBack( loopSlot );
				
			}
		}
		
		i = 0;
		
		
		if( bookTags.Size() > 0 )
		{
			for( i = 0; bookTags.Size() > i; i += 1 )
			{
				loopEntity = (CBookMinigameBook) theGame.GetNodeByTag( bookTags[i] );
				
				books.PushBack( loopEntity );
			}
		}
		
		i = 0;
		
		
		if( books.Size() > 0 )
		{
			for( i = 0; books.Size() > i; i += 1 )
			{
				
				books[i].TeleportWithRotation( bookSlots[i].GetWorldPosition(), bookSlots[i].GetWorldRotation() );
				bookSlots[i].FillSlot( books[i] );
			}
		}
		
		i = 0;
	}
	
	
	function MoveBook( bookSlotNumber: int, direction: EBookDirection )
	{
		var bookA, bookB: CBookMinigameBook; 
		var modifiedSlotNum, targetSlotNum: int;
		
		if( direction == BD_right )
		{
			modifiedSlotNum = (bookSlotNumber - 1);
			targetSlotNum = (modifiedSlotNum + 1);
		}
		
		else if( direction == BD_left )
		{
			modifiedSlotNum = (bookSlotNumber - 1);
			targetSlotNum = (modifiedSlotNum - 1);
		}
		
		bookA = bookSlots[modifiedSlotNum].currentBook;
		bookB = bookSlots[targetSlotNum].currentBook;
		
		bookA.TeleportWithRotation( bookSlots[targetSlotNum].GetWorldPosition(), bookSlots[targetSlotNum].GetWorldRotation() );
		bookSlots[targetSlotNum].FillSlot( bookA );
		
		bookB.TeleportWithRotation( bookSlots[modifiedSlotNum].GetWorldPosition(), bookSlots[modifiedSlotNum].GetWorldRotation() );
		bookSlots[modifiedSlotNum].FillSlot( bookB );
		
		CheckBooksOrder();
	}
	
	
	function CheckBooksOrder()
	{
		var i: int;
		
		i = 0;
		
		for( i = 0; bookSlots.Size() > i; i += 1 )
		{
			if( !bookSlots[i].CheckBook() )
			{
				return;
			}
		}
		
		FactsAdd( minigameWonFact, 1, -1);
	}
}

class CBookMinigameSlot extends CGameplayEntity
{
	editable var bookMinigameManagerTag: name;
	editable var correctBookId: int;
	
	var currentBook: CBookMinigameBook;
	var bookMinigameManager: CBooksMinigameManager;
	
	function init()
	{
		bookMinigameManager = (CBooksMinigameManager) theGame.GetNodeByTag( bookMinigameManagerTag );
	}
	
	function FillSlot( newBook: CBookMinigameBook )
	{
		currentBook = newBook;
	}
	
	function CheckBook(): bool
	{
		if( currentBook.bookId == correctBookId )
		{
			return true;
		}
		
		else
		{
			return false;
		}
	}
}

class CBookMinigameBook extends CGameplayEntity
{
	editable var bookId: int;
}

class CFactAdderOnCollisionWithTag extends CGameplayEntity
{
	public editable	var factName 			: string;	default factName			= "CollidedAlert";
	public editable	var tagToCollideWith	: name;		default tagToCollideWith	= 'PLAYER';
	
	event OnCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var ent : CEntity;
		var component : CComponent;
		
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		ent = component.GetEntity();
		if ( ent.HasTag( tagToCollideWith ) )
		{
			if( !FactsDoesExist( factName ) )
			{
				FactsAdd( factName );
			}
		}
	}
}