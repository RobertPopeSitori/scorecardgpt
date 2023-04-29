trigger ItemTrigger on OrderApi__Item__c(before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
     TriggerManager.Invoke(OrderApi__Item__c.getSObjectType().getDescribe().getName());
}