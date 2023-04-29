trigger ScorecardTrigger on Scorecard__c (before insert, after insert, before update, after update, before delete, after delete) 
{
	TriggerManager.Invoke(Scorecard__c.getSObjectType().getDescribe().getName());
}