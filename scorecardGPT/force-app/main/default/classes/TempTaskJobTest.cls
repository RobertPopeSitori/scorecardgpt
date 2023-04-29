@IsTest
public class TempTaskJobTest  
{
	public static testmethod void willUpdateTask()
	{
		Test.startTest();

		TempTask__c temp = new TempTask__c();
		temp.LegacyId__c = '00T5500000EFJJDAAZ';
		temp.ActivityDate__c = Date.today();
		insert temp;

		Task tsk = new Task();
		tsk.Subject = 'Call';
		//tsk.WhoId = UserInfo.getUserId();
		tsk.Priority = 'Normal';
		tsk.Status = 'Not Started';
		tsk.Legacy_Activity_Salesforce_ID__c = '00T5500000EFJJDAAZ';
		insert tsk;

		Database.executeBatch(new TempTaskJob());

		Test.stopTest();
	}
}