@IsTest
public class ScorecardQuestionTriggerHandlerTest  
{
	static testmethod void willInsertAnswers()
	{
		Test.startTest();
		Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Test.stopTest();

		List<Scorecard_Review__c> reviews = [SELECT Id FROM Scorecard_Review__c WHERE Scorecard_User__c = null];
		System.assertEquals(reviews.size(), detail.Questions.size(), 'There should be equal number of answers created.');

		List<Scorecard_Question__c> questions = new List<Scorecard_Question__c>();
		for(Id questionId : detail.Questions.keySet())
		{
			Scorecard_Question__c question = detail.Questions.get(questionId);
			questions.add(question);
		}

		update questions;
		delete questions;
		undelete questions;
	}
}