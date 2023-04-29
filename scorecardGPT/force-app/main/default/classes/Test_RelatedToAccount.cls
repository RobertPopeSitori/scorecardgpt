@isTest
public class Test_RelatedToAccount {

   @istest
    public static void testUnit(){
        Account acc=new Account();
        acc.name = 'test Account';
        insert acc;
        
        contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = acc.id;
        insert con;
        
        Task tas = new Task();
        tas.WhoId=con.id;
        tas.Type='Call';
        tas.Subject='Call';
        tas.Status='Completed';
        tas.Priority='Normal';
        tas.Related_to_Account__c =con.AccountId;
        insert tas;
        tas.Related_to_Account__c =con.AccountId;
        update tas;
    }
}