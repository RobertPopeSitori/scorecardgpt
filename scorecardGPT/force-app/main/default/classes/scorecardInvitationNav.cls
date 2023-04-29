public class scorecardInvitationNav {
    
    @AuraEnabled 
    public static List<Invitation__c> getInvitations(string scorecardId){
        List<Invitation__c> listOfInvitations = [SELECT Id,CreatedBy.Name,Status__c,Scorecard__c, First_Name__c,
                                                 Last_Name__c 
                                                 FROM Invitation__c 
                                                 WHERE Scorecard__c =:scorecardId //'a2y7d000000tuxkAAA' //:scorecardId
                                                 AND Status__c = 'Invited'];
        return listOfInvitations;//.size()>0 ? listOfInvitations : null;
    }
    
}