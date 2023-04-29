@IsTest
public class ItemTriggerHandlerTest  
{
	public static testmethod void willCoverCode()
	{
		Map<Id, SObject> oldItems = new Map<Id, SObject>();
		Map<Id, SObject> newItems = new Map<Id, SObject>();

		ItemTriggerHandler handler = new ItemTriggerHandler();
		handler.AfterDelete(oldItems);
		handler.AfterInsert(newItems);
		handler.AfterUndelete(oldItems);
		handler.AfterUpdate(newItems, oldItems);
		handler.BeforeDelete(oldItems);
		handler.BeforeInsert(newItems.values());
		handler.BeforeUpdate(newItems, oldItems);

	}

}