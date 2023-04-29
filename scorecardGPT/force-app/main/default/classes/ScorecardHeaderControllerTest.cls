@IsTest
public class ScorecardHeaderControllerTest  
{
	static testmethod void willGetScorecardSummary()
	{
		Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
		string result = ScorecardHeaderController.getScorecardSummary(scorecardId);
		System.assert(String.isNotBlank(result));

		result = ScorecardHeaderController.getScorecardSummary(null);
	}
}