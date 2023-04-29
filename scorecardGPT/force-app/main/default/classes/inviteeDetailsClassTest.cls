@IsTest
public class inviteeDetailsClassTest {
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
        inv.Role__c = 'Co-Author';
        
        invList.add(inv);
        insert invlist;
        List<String> SectionList = new List<string>();
        SectionList.add('a');
        inviteeDetailsClass.DeclineInvitee(invlist[0].id);
        inviteeDetailsClass.getinvite(invlist[0].id);
        inviteeDetailsClass.inviteeStatusChange(invlist[0].id);
        inviteeDetailsClass.testing();
        createInvitationController.getSectionList(scoreCardId);
        createInvitationController.returnUserRole(u.Id, scorecardId);
        createInvitationController.updateScoreCard(invlist[0].Id, scorecardId, 'co-author');
        createInvitationController.insertinvite(scorecardId, 'fname', 'lname', 'email@email.com', 'Co-Author', SectionList);
		CancelInvitationController.cancelScoreCardUser(invlist[0].Id);
        CancelInvitationController.declineScoreCardUser(invlist[0].Id);
       
	}
}