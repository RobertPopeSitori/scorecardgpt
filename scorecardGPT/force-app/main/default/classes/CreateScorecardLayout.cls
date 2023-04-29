public class CreateScorecardLayout {
    
    @AuraEnabled
    public static List<Scorecard_Template__c> getTemplateName(string uId){
        List<Scorecard_Template__c> returnTemplate = new List<Scorecard_Template__c>();
        User u = [Select id,ContactId from User where ID =: uId];
        contact con = [SELECT Id,Receives_Member_Benefits__c FROM Contact Where id =: u.ContactId];
        
        if(con.Receives_Member_Benefits__c == true){
            List<Scorecard_Template__c> templist = [SELECT Id,Name,Status__c FROM Scorecard_Template__c
                                                WHERE Status__c = 'Published'];
            returnTemplate.addall(templist);
        }else{
            List<Scorecard_Template__c> templist1 = [SELECT Id,Name,Status__c FROM Scorecard_Template__c
                                                WHERE Status__c = 'Published'
                                                   AND Availability__c = 'FREE'];
            returnTemplate.addall(templist1);
        }
        return returnTemplate;
        
    }
    
}