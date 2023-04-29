@IsTest
public class TestHelperAccount  
{
	public static Account insertAccount(string accountName)
	{
		Account acct = new Account();
		acct.Name = accountName;
		acct.Is_Vendor__c = true;
		acct.Vendor_Type__c = 'Advertising';
		insert acct;

		return acct;
	}
}