public class relatedcontactrole {
	@AuraEnabled
    public static List<AccountContactRelation> getcontactrole(String recordId){
     
       
        return [select id,Contactid,contactname__c,roles from AccountContactRelation where accountid=:recordId and roles NOT IN (null,'No longer at Org') ];
    }
}