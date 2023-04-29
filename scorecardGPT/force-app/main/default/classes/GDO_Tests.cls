@isTest
public class GDO_Tests {
    
    static testMethod void testGDO_Setup() {
        // Test the process of swapping out all GDO values for a new org
        
        // Create data for testing
        Id testSiteId = initData();
        
        // "Hit the button"
        GDO_SetupButton_Ctrl setupPage = new GDO_SetupButton_Ctrl();
        Test.startTest();
        setupPage.runReplace();
        Test.stopTest();
        
        // Determine what the new Profile Page value SHOULD be
        Domain masterDomain = [SELECT Id, Domain FROM Domain LIMIT 1];
        PagesApi__Site__c site = [SELECT Id, PagesApi__Profile_Page_URL__c FROM PagesApi__Site__c
                                  WHERE Id =: testSiteId LIMIT 1];
        String expectedURL = 'https://' + masterDomain.Domain + '/CPBase__profile?site=' + String.valueOf(site.Id);
        System.assertEquals(expectedURL, site.PagesApi__Profile_Page_URL__c);
    }
    
    // Initialize data, return the Site Id we are testing
    static Id initData() {
        // Setup a new Site
        PagesApi__Site__c newSite = new PagesApi__Site__c();
        insert newSite;
        
        // Create a new Directory
        DRCTS__Directories__c newDir = new DRCTS__Directories__c();
        newDir.Name = 'New Directory';
        insert newDir;
        
        Id legacySiteId = newSite.Id;
        
        // Create a new site, set the Profile page to use the old Site Id
        newSite = new PagesApi__Site__c();
        newSite.PagesApi__Profile_Page_URL__c = 'https://test.com/CPBase__profile?site=';
        newSite.PagesApi__Profile_Page_URL__c += String.ValueOf(legacySiteId);
        insert newSite;
        
        return newSite.Id;
    }
}