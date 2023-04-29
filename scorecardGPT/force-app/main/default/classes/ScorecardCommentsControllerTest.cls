@IsTest
public class ScorecardCommentsControllerTest  
{
	public static testmethod void willSaveComment()
	{
		Test.startTest();

		Id scorecardId = ScorecardHelperTest.insertScorecard('Test Scorecard', null);
		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.Role__c = 'Author';
		scUser.User__c = UserInfo.getUserId();
		scUser.Scorecard__c = scorecardId;
		scUser.Is_Active__c = true;
		insert scUser;

		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Id answerId;
		for(Id questionKey : detail.Questions.keySet())
		{
			Scorecard_Review__c answer = ScorecardHelper.setQuestionAnswer(questionKey);
			answer = ScorecardHelper.getQuestionAnswer(questionKey);
			System.assert(answer != null);

			string result = ScorecardCommentsController.saveComment(answer.Id, 'Answer', 'Test comment for the answer.');			
			answerId = answer.Id;
			break;
		}

		Test.stopTest();

		List<Scorecard_Comment__c> coms = ScorecardHelper.getReviewComments(answerId);
		System.assert(coms.size() > 0);
	}

	public static testmethod void willCoverMoreCode()
	{
		string result = ScorecardCommentsController.saveComment('', 'Answer', 'My Comment');
		result = ScorecardCommentsController.saveComment('MyFakeId', '', 'My Comment');
		result = ScorecardCommentsController.saveComment('MyFakeId', 'Answer', '');
	}
}