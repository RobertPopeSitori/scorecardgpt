public class ScorecardReviewTriggerHandler implements ITriggerHandler
{
    private static final ScorecardQuestionTriggerHandler handler = new ScorecardQuestionTriggerHandler();
    public static ScorecardQuestionTriggerHandler getInstance(){ return handler; }


    public void BeforeInsert(List<SObject> newItems) { }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

    public void BeforeDelete(Map<Id, SObject> oldItems) { }

    public void AfterInsert(Map<Id, SObject> newItems) 
    { 
		QueueStatusCheck(newItems);
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
	{ 
		QueueStatusCheck(newItems);
	}

    public void AfterDelete(Map<Id, SObject> oldItems) {}

    public void AfterUndelete(Map<Id, SObject> oldItems) {}

	public static void QueueStatusCheck(Map<Id, SObject> items)
	{
		List<Scorecard_Review__c> reviews = [	SELECT Id, Question__c, Question__r.Section__c, 
													Question__r.Section__r.Scorecard__c
												FROM Scorecard_Review__c
												WHERE Id IN :items.keySet() ];
		Set<Id> scorecardIds = new Set<Id>();
		Set<Id> sectionIds = new Set<Id>();
		Set<Id> questionIds = new Set<Id>();

		for(Scorecard_Review__c review : reviews)
		{
			scorecardIds.add(review.Question__r.Section__r.Scorecard__c);
			sectionIds.add(review.Question__r.Section__c);
			questionIds.add(review.Question__c);
		}

		ScorecardHelper.evaluateStatus(scorecardIds, sectionIds, questionIds);
	}
}