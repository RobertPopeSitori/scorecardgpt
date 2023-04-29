@IsTest
public class AccountAddressHelperTest  
{
	public static testmethod void willUpdateAddress()
	{
		Test.startTest();

		Account acct = new Account();
		acct.Name = 'My Own Account';
		acct.Is_Vendor__c = true;
		acct.Vendor_Type__c = 'Advertising';
		acct.Legacy_Account_ID__c = '0015500000Ye4QSAAZ';
		insert acct;

		Old_Address__c addr = new Old_Address__c();
		addr.BillingStreet__c = '123 E Forhan St';
		addr.BillingCity__c = 'Long Beach';
		addr.BillingPostalCode__c = '90805';
		addr.BillingCountry__c = 'United States';
		addr.BillingState__c = 'California';
		addr.ShippingStreet__c = '123 E Forhan St';
		addr.ShippingCity__c = 'Long Beach';
		addr.ShippingPostalCode__c = '90805';
		addr.ShippingCountry__c = 'United States';
		addr.ShippingState__c = 'California';
		addr.LegacyId__c = '0015500000Ye4QSAAZ';
		insert addr;

		Test.stopTest();

		System.debug('***ACCT:' + acct);

		List<Old_Address__c> addrs = [ SELECT Id, LegacyId__c FROM Old_Address__c ];
		addrs.add(addr);

		AccountAddressHelper.moveAddresses(addrs);
	}
}