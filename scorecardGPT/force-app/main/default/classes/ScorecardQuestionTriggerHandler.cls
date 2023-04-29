public class ScorecardQuestionTriggerHandler  implements ITriggerHandler
{
    public static Boolean TriggerDisabled = false;
    private static final ScorecardQuestionTriggerHandler handler = new ScorecardQuestionTriggerHandler();
    public static ScorecardQuestionTriggerHandler getInstance(){ return handler; }


    public void BeforeInsert(List<SObject> newItems) { }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

    public void BeforeDelete(Map<Id, SObject> oldItems) { }

    public void AfterInsert(Map<Id, SObject> newItems) 
    { 
		List<Scorecard_Review__c> listAnswers = new List<Scorecard_Review__c>();
		for(Id questionId : newItems.keySet())
		{
			Scorecard_Review__c review = new Scorecard_Review__c();
			review.Question__c = questionId;
			review.Status__c = 'In Progress';
			review.Type__c = 'Answer';
			listAnswers.add(review);
		}
        
		if(listAnswers.size() > 0) insert listAnswers;
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

    public void AfterDelete(Map<Id, SObject> oldItems) {}

    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}