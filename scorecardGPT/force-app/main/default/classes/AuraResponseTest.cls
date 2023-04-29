@IsTest
public class AuraResponseTest  
{
	static testmethod void willInitialize()
	{
		AuraResponse response = new AuraResponse();
		response.url = 'https://google.com';
	}
}