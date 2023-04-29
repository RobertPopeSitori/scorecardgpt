@IsTest
public class ScorecardReviewViewModelTest  
{
	public static testmethod void willInitialize()
	{
		Test.startTest();

		Id scorecardId = ScorecardHelperTest.insertScorecard('Test Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);

		Test.stopTest();

		for(Id questionId : detail.Questions.keySet())
		{
			Scorecard_Review__c review = ScorecardHelper.getQuestionAnswer(questionId);
		
			Scorecard_Role__mdt permission = new Scorecard_Role__mdt();
			permission.Answer_Type__c = 'Answer';

			ScorecardReviewViewModel model = new ScorecardReviewViewModel(review, permission);
			review = model.toReviewObject();

			break;
		}

	}


}