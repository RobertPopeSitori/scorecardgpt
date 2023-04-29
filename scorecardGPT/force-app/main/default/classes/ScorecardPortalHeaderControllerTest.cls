@IsTest
public with sharing class ScorecardPortalHeaderControllerTest 
{
	static testmethod void willGetCommunitySettings()
	{
		string result = ScorecardPortalHeaderController.getCommunitySettings();
	}
}