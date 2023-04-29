@IsTest
public class ScorecardTeamNavControllerTest  
{
	static testmethod void willGetTeamMembers()
	{
         Account acc=New Account(Name='Test Account');
        insert acc;
        
        Contact cont=New Contact(FirstName='Test',LastName='Test',AccountId=acc.Id);
        insert cont;
        
        id profId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'].Id;
        
        User u = new User(ProfileId = profId,LastName = 'last',Email = 'scorecard@test.com',
                          Username = 'scorecard@test.com',ContactId=cont.Id,Alias = 'alias',TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');
        insert u;
		Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
		
		Scorecard_User__c scUser = new Scorecard_User__c();
		//scUser.User__c = UserInfo.getUserId();
		scUser.User__c = u.id;
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scorecardId;
		insert scUser;
        List<Invitation__c> invList = new List<Invitation__c>();
        Invitation__c inv = new Invitation__c();
        inv.email__c = 'test@gmail.com';
        inv.First_Name__c = 'test';
        inv.Last_Name__c = 'test';
        invList.add(inv);
        insert invlist;
        List<String> SectionList = new List<string>();
        SectionList.add('a');
        
        
		string result = ScorecardTeamNavController.getTeamMembers('');
		result = ScorecardTeamNavController.getTeamMembers(scorecardId);
        ScorecardTeamNavController.deleteScorecardUser(scorecardId, U.id);
        ScorecardTeamNavController.returnUserRole(u.Id, scorecardId);
        ScorecardTeamNavController.getInvitations(scorecardId);
        ScorecardTeamNavController.getSectionList(scoreCardId);
        ScorecardTeamNavController.getTeamMembers(scorecardId);
        ScorecardTeamNavController.SaveandResendInvitation(invList, SectionList);
        ScorecardTeamNavController.ResendInvitation(invList[0].id);
        //ScorecardTeamNavController.getUserEmail(U.Id);
       // ScorecardTeamNavController.getUserEmail(U.Id);
       
	}
}