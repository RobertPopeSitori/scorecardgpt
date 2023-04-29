public without sharing class ScorecardPortalHeaderController 
{
    @AuraEnabled
    public static string getCommunitySettings()
    {
        CommunitySettings settings = new CommunitySettings();
        return JSON.serialize(settings);
    }
    
}