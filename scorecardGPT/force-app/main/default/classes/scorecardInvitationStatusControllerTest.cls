@isTest
public class scorecardInvitationStatusControllerTest {
    
    @IsTest
    public static void scorecardInvitationStatusControllermethod1(){
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
        
        Scorecard__c scorecard = new Scorecard__c(Title__c ='Test',Organization__c=acc.id,Language__c ='English',Template__c=temp.id);
        insert scorecard;
        
        Scorecard_User__c scUser1 = new Scorecard_User__c();
		scUser1.User__c = u.Id;
		scUser1.Role__c = 'Author';
		scUser1.Scorecard__c = scorecard.id;
        scUser1.Is_Active__c = true;
		insert scUser1;
        
        Invitation__c invite = new Invitation__c();
        invite.First_Name__c ='Test';
        invite.Last_Name__c = 'Invitation';
        invite.Email__c = 'testinvitation@mailinator.com';
        invite.Role__c ='Author';
        invite.Scorecard__c = scorecard.id;
        invite.Status__c = 'Accepted';
        insert invite;
        
        Invitation__c invite1 = new Invitation__c();
        invite1.First_Name__c ='Test';
        invite1.Last_Name__c = 'Invitation';
        invite1.Email__c = 'testinvitation@mailinator.com';
        invite1.Role__c ='Author';
        invite1.Scorecard__c = scorecard.id;
        insert invite1;
              
        scorecardInvitationStatusController.getinvite(invite.Id,UserInfo.getUserId());
       scorecardInvitationStatusController.getinvite(invite1.Id,UserInfo.getUserId());
       scorecardInvitationStatusController.getScorecardId(invite.Id);
        scorecardInvitationStatusController.inviteDetail(invite.Id);
    }
}