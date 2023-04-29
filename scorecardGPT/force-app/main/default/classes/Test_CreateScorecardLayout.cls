@isTest
public class Test_CreateScorecardLayout {
    @isTest
    static void TestCreateScorecardLayout(){
        Scorecard_Template__c ScoreCardTemplate=new Scorecard_Template__c(Name='Template', Language__c='English');
        insert ScoreCardTemplate;
        
        Account acc = new account(Name='Test');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact', AccountID = acc.id);
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Login User'];
        User u = new User(Alias = 'standtad', email='olc@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testtting', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', username='olc@testorg.com',
                          ContactId=con.id);
        insert u;
        CreateScorecardLayout.getTemplateName(u.id);
    }
    static testmethod void willGetTeamMembers()
    {
        Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
        
        Scorecard_User__c scUser = new Scorecard_User__c();
        scUser.User__c = UserInfo.getUserId();
        scUser.Role__c = 'Author';
        scUser.Scorecard__c = scorecardId;
        insert scUser;
        
        string result = ScorecardTeamNavController.getTeamMembers('');
        result = ScorecardTeamNavController.getTeamMembers(scUser.Id);
    }
}