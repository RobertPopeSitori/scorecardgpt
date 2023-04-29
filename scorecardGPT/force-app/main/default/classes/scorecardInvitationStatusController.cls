public without sharing class scorecardInvitationStatusController {
    
    @auraEnabled
    public static string getinvite(string idParamValue,string userId){
        Invitation__c inviteStatus = [SELECT Id,Scorecard__c,Role__c, Status__c FROM Invitation__c WHERE Id =: idParamValue];
        List<scorecard_user__c> Suser = [Select id,name from Scorecard_user__c where user__c =: userId AND Scorecard__c =: inviteStatus.Scorecard__c];
        if(Suser.size() == 0){
           string status = scorecardInvitationStatusController.inviteDetail(idParamValue);
           return status;
        }else{
            return 'User Available';
        }
        
       
    }
    public static string inviteDetail(string idParamValue){
        Invitation__c inviteStatus = [SELECT Id,Scorecard__c,Role__c, Status__c FROM Invitation__c WHERE Id =: idParamValue];
        if(inviteStatus.Status__c == 'Accepted' || inviteStatus.Status__c == 'Decline' || inviteStatus.Status__c == 'Cancel'){
           string scId = inviteStatus.Scorecard__c; 
            return 'Already Used';
        }else{
            return 'Not Used';
        }
    }
    @auraEnabled
    public static string getScorecardId(string idParamValue) {
    Invitation__c inviteStatus = [SELECT Id,Scorecard__c,Role__c, Status__c FROM Invitation__c WHERE Id =: idParamValue];
    string scId = inviteStatus.Scorecard__c; 
    return scId;
    }
}