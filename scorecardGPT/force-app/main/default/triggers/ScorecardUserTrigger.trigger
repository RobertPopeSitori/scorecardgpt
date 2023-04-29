trigger ScorecardUserTrigger on Scorecard_User__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  
{ 
 	TriggerManager.Invoke(Scorecard_User__c.getSObjectType().getDescribe().getName());
}