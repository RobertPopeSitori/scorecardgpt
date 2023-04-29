trigger ScorecardQuestionTrigger on Scorecard_Question__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  
{ 
 	TriggerManager.Invoke(Scorecard_Question__c.getSObjectType().getDescribe().getName());
}