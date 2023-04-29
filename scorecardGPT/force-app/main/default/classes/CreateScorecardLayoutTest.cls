@isTest
public class CreateScorecardLayoutTest {
    @isTest
    public static void scorecardInvitationNavmethod(){
        
        Account acc=New Account(Name='Test Account');
        insert acc;
        
        Contact cont=New Contact(FirstName='Test',LastName='Test',AccountId=acc.Id);
        insert cont;
        
        id profId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'].Id;
        
        User u = new User(ProfileId = profId,LastName = 'last',Email = 'scorecard@test.com',
                          Username = 'scorecard@test.com',ContactId=cont.Id,Alias = 'alias',TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');
        insert u;
        
        Scorecard_Template__c temp = new Scorecard_Template__c(Name='Test Template',Language__c ='English');
        insert temp;
        
        CreateScorecardLayout.getTemplateName(u.id);
    }
}