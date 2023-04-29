public class GDO_Init {
    
    public static void setupOrg() {
        // Old/new value maps to pass to GDO_Helper
        Map<String, String> StringMap = new Map<String, String>();
        Map<Id, Id> IdMap = new Map<Id, Id>();
        Set<String> targetObjects = new Set<String>();
        
        targetObjects.add('PagesApi__Site__c');
        targetObjects.add('PagesApi__Menu_Item__c');
    
        // Identify new values for all 
        // Get community/domain values
        Network memberPortal = [SELECT Id,Name,selfregprofileid FROM Network WHERE Name='Member Portal' LIMIT 1];
        Domain masterDomain = [SELECT Id, Domain FROM Domain LIMIT 1];
        
        System.debug('>>>>>>>>memberPortal>>>'+memberPortal);
        System.debug('>>>>>>>>masterDomain>>>'+memberPortal);
        
        // Get new directory
        DRCTS__Directories__c  masterDir = [SELECT Id,Name FROM DRCTS__Directories__c LIMIT 1];
        
        // Get old Site values to sub out, iterate through all Sites
        PagesApi__Site__c[] sites = [SELECT Id, PagesApi__Profile_Page_URL__c, 
                                        PagesApi__Site_URL__c,
                                        PagesApi__Community_Network_ID__c, 
                                        PagesApi__Default_Community_New_User_Profile__c,
                                        PagesApi__User_Reset_Password_URL__c,
                                        PagesApi__User_Self_Registration_URL__c,
                                        PagesApi__User_Login_URL__c 
                                        FROM PagesApi__Site__c];
        
        
        System.debug('>>>>>>>>sites.size>>>'+sites.size());
        
        for (PagesApi__Site__c  site : sites) {
            
            if (String.isNotBlank(site.PagesApi__Profile_Page_URL__c) && 
                site.PagesApi__Profile_Page_URL__c.countMatches('/') > 2) {
                
                System.debug('>>>>>>>>here Iam inside loop>>>'+site);
                
                    List<String> parts = site.PagesApi__Profile_Page_URL__c.split('\\/');
                    
                    StringMap.put(parts[2], masterDomain.Domain);    // Add the domain value for substitution
                    parts[3] = parts[3].replace('CPBase__profile?site=', '');   // Isolate the Id only
                    parts[3] = parts[3].normalizeSpace();   // Accomodate for whitespace/newlines
                    
                    if (parts[3] != NULL && site.Id != NULL && parts[3] != site.Id) { 
                        IdMap.put(parts[3], site.Id); 
                    }
            }  // end if PagesApi__Profile_Page_URL__c
        }  // end for site
        
        // Iterate through Menu Items to find directories
        String searchText = '/s/searchdirectory?id=';   // Search field for directory URLs to replace
        Integer searchTextLength = searchText.length();
        for (PagesApi__Menu_Item__c menuItem : [SELECT Id, Name, PagesApi__Custom_URL__c FROM PagesApi__Menu_Item__c]) {
            if (menuItem.PagesApi__Custom_URL__c != NULL && menuItem.PagesApi__Custom_URL__c.length() > searchTextLength &&
                menuItem.PagesApi__Custom_URL__c.substring(0, searchTextLength) == searchText) {
                // Add directory Id to the IdMap
                String DirId = menuItem.PagesApi__Custom_URL__c.replace(searchText, '');
                DirId = DirId.normalizeSpace();
                if (DirId != NULL && masterDir.Id != NULL && DirId != masterDir.Id) { IdMap.put(DirId, masterDir.Id); }
                    System.debug('Added Directory ' + DirId + ' to IdMap (New value ' + masterDir.Id + ')');
            } 
        }   // end for menuItem

        /*  Debugging - CY
        for (Id key : IdMap.keySet() ) {
            System.debug ('+++ ' + key + ' = ' + IdMap.get(key));
        }
        */
        
        // Let's try running GDO_Helper replace
        GDO_Helper.replace(StringMap, IdMap, targetObjects, false);
        
    }  // end setupOrg
}