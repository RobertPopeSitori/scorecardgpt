@IsTest
public class TempContactJobTest 
{
	public static testmethod void willUpdateContact()
    {
        Test.startTest();
        
        Account acct = new Account();
		acct.Name = 'My Own Account';
		acct.Is_Vendor__c = true;
		acct.Vendor_Type__c = 'Advertising';
        acct.Legacy_Account_ID__c = '0015500000Ye5F7AAz';
		insert acct;
        
        TempContact__c temp = new TempContact__c();
        temp.AccountId__c = '0015500000Ye5F7AAz';
        temp.MailingStreet__c = '123 E Forhan St';
        temp.MailingCity__c = 'Long Beach';
        temp.MailingCountry__c = 'United States';
        temp.MailingState__c = 'CA';
        temp.MailingPostalCode__c = '90805';
        temp.Phone__c = '5551234567';
        temp.OtherPhone__c = '5551234566';
        temp.OtherStreet__c = '456 E Forhan St';
        temp.OtherCity__c = 'Long Beach';
        temp.OtherState__c = 'California';
        temp.OtherCountry__c = 'US';
        temp.OtherPostalCode__c = '98989';
        temp.LegacyId__c = '0035500000WWFPYeee';
        temp.FirstName__c = 'Test';
        temp.LastName__c = 'Last';
        temp.Email__c = 'eml@email.com';
        insert temp;
        
        Contact con = new Contact();
        con.Email = 'test@email.com';
        con.FirstName = 'Test';
        con.LastName = 'Last';
        con.Legacy_Contact_Salesforce_ID__c = '0035500000WWFPYeee';
        con.Position_Type__c = 'Staff';
        insert con;
        
        Database.executeBatch(new TempContactJob());
        
        Test.stopTest();
        
    }
}