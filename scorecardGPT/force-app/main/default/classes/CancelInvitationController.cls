public class CancelInvitationController {
    
    @AuraEnabled
    public static string cancelScoreCardUser(String invitId) {
        
        Invitation__c invitRecord = [select id,Status__c,Scorecard__c,Role__c from Invitation__c where Id=:invitId];
        invitRecord.Status__c='Cancel';  
        update invitRecord;
        return invitRecord.Scorecard__c;
    }
    
    @AuraEnabled
    public static string declineScoreCardUser(String invitId) {
        
        Invitation__c invitRecord = [select id,Status__c,Scorecard__c,Role__c from Invitation__c where Id=:invitId];
        invitRecord.Status__c='Decline';  
        update invitRecord;
        return invitRecord.Scorecard__c;
    }
}