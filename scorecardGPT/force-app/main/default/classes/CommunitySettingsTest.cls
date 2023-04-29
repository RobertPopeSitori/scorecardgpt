@IsTest
public class CommunitySettingsTest  
{
	static testmethod void willInitialize()
	{
		CommunitySettings cs = new CommunitySettings('Scorecard Portal');
		cs = new CommunitySettings();
	}
}