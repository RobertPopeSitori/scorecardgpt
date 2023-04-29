@isTest 
public class Test_relatedcontactrole {
 @isTest 
    static void TestAccountContactRelation() {

        Account acct = new Account(Name='HelloWorld');
        insert acct;

        Contact con = new Contact(AccountId = acct.id,lastname = 'testdata' , firstname ='testdata1');
        insert con; 
 Account acct1 = new Account(Name='HelloWorld1');
        insert acct1;

        AccountContactRelation acctcr = new AccountContactRelation(AccountId = acct1.id, ContactId = con.id,Roles='TestROle',IsActive=true);
        insert acctcr;

        List<AccountContactRelation> all = [SELECT ID, AccountId, ContactId,Roles FROM AccountContactRelation];
       

       
        relatedcontactrole.getcontactrole(all[0].AccountId);
        /* check for AccountContactRelation record with Primary__c = false and also check for the error message */     

    }
}