/**
 * Created by Admin on 21-06-2019.
 */
public with sharing class FS_ValidateJoinProcess {
    public String messageforProfessionalMembers{get;set;}
    public Boolean flag{get;set;}
    public FS_ValidateJoinProcess(){
        flag = false;
    }
    public PageReference validateJoinProcess() {
        messageforProfessionalMembers = 'initialization';
        User u = [SELECT Id,ContactId from User WHERE Id =: UserInfo.getUserId()];
        List<OrderApi__Subscription__c> mmbrShipLst = [SELECT Id,OrderApi__Status__c,OrderApi__Item_Class__r.Name,OrderApi__Item_Class__c FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c = :u.contactId and OrderApi__Item_Class__r.Name = 'Individual Membership'and OrderApi__Status__c != 'Cancelled'];
        if(mmbrShipLst.size()>0){
            flag = true;
            messageforProfessionalMembers = System.Label.FS_MessageProfessionalMembers;
            return null;
        }
        else{
            PageReference p=new PageReference(System.Label.FS_QualifyingquestionsURL);
            return p;
        }
    }
}