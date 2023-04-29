@isTest public class Test_ScorecardUserCreation {
    
    static testmethod void ScorecardUserCreation(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Scorecard_Template__c ScoreCardTemplate=new Scorecard_Template__c(Name='Template', Language__c='English');
        insert ScoreCardTemplate;
        
        Scorecard__c scorecard = new Scorecard__c(Title__c ='Scorecard',Organization__c =acc.id,Language__c='English',
                                                 Template__c =ScoreCardTemplate.id);
        insert scorecard;
        
        Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = '0051U000006c4sR';
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scorecard.id;
		insert scUser;
    }

}