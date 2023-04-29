@IsTest
public class ScorecardUserHelperTest 
{
	static testmethod void willGetScorecardUser()
	{
		Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
		
		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scorecardId;
		insert scUser;

		Scorecard_User__c sUser = ScorecardUserHelper.getScorecardUser(scorecardId);
		System.assertEquals(scUser.Id, sUser.Id, 'The same user should have been retrieved.');
	}

	static testmethod void willGetUserSctions()
	{
		Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
		
		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scorecardId;
		insert scUser;

		List<Scorecard_User_Section__c> sections = ScorecardUserHelper.getUserSections(scorecardId);
		System.assert(sections.size() > 0);

		Scorecard_Role__mdt permission = ScorecardUserHelper.getRolePermissions(scorecardId);
		System.assertEquals(permission.DeveloperName, scUser.Role__c, 'The permission should have matched the role.');

	}
}