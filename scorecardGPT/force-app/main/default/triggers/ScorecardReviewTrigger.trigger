trigger ScorecardReviewTrigger on Scorecard_Review__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  
{ 
	TriggerManager.Invoke(Scorecard_Review__c.getSObjectType().getDescribe().getName());
}