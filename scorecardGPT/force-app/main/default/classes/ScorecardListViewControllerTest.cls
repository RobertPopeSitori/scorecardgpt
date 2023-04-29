@IsTest
public class ScorecardListViewControllerTest  
{
	static testmethod void willgetScorecards()
	{
		Test.startTest();
		Id scoreId = ScorecardHelperTest.insertScorecard('My First Scorecard', null);
		Test.stopTest();
        
         Account acc=New Account(Name='Test Account');
        insert acc;
        
        Contact cont=New Contact(FirstName='Test1',LastName='Test',AccountId=acc.Id);
        insert cont;
        
        id profId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'].Id;
        
        User u = new User(ProfileId = profId,LastName = 'last11',Email = 'scorecard11@test.com',
                          Username = 'scorecard11@test.com',contactid=cont.id,Alias = 'alias',TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');
        insert u;
        
		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = u.id;
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scoreId;
		insert scUser;

		string result = ScorecardListViewController.getScorecards();
		System.assert(String.isNotBlank(result));
	}
}