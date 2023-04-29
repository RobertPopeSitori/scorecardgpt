public class ItemTriggerHandler implements ITriggerHandler
{
     public void BeforeInsert(List<SObject> newItems) { }

     public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

     public void BeforeDelete(Map<Id, SObject> oldItems) { }

     public void AfterInsert(Map<Id, SObject> newItems)
     {
          ItemHelper.syncItemProducts(newItems.keySet());
     }

     public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
     {
          ItemHelper.syncItemProducts(newItems.keySet());
     }

     public void AfterDelete(Map<Id, SObject> oldItems) { }

     public void AfterUndelete(Map<Id, SObject> oldItems) { }
}