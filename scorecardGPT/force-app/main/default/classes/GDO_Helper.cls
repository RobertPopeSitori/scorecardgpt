public class GDO_Helper {

    // Method to call replace method without specifying testOnly flag
    public static void replace(Map<String, String> StringMap, Map<Id, Id> IdMap, Set<String> targetObjs) {
        GDO_Helper.replace(StringMap, IdMap, targetObjs, false);
    }
    
    /* Replace all occurrencies of the specified keys in StringMap or IdMap with the corresponding
    *  values in the sObjects specified in the targetObjs set. Id values will also be used to check Lookup
    *  references
    */
    public static void replace(Map<String, String> StringMap, Map<Id, Id> IdMap, Set<String> targetObjs, Boolean testOnly) {
        Framework.Log.push(GDO_Helper.class.getName(),'replace');

        List<sObject> toUpdate = new List<sObject>();
        
        // Add the IdMap to StringMap for replacements if needed (to replace ids inside URLs, as an example)
        if (IdMap.size() > 0) {
            if (StringMap == NULL) { StringMap = new Map<String, String>(); }
            for (Id idKey : IdMap.keySet() ) {
                StringMap.put(idKey, IdMap.get(idKey));
                // Also put the 15-character Id
                StringMap.put(String.valueOf(idKey).substring(0, 15), IdMap.get(idKey));
            }  // end for idKey
        } 
        
        // Safety check for StringMap, delete any values that are the same
        for (String key : StringMap.keySet() ) {
            if (key == StringMap.get(key)) { StringMap.remove(key); }
        }
        
        // Fetch schema for targetSobjs
        List<String> objNameList = new List<String>(); // Convert to a list
        objNameList.addAll(targetObjs);
        List<Schema.DescribeSobjectResult> schemaLookup = Schema.describeSObjects(objNameList);
        for (Schema.DescribeSobjectResult sch : schemaLookup) {
            List<String> fieldsToRetrieve = new List<String>();
            fieldsToRetrieve.add('Id');
            
            // Find all writeable String and Lookup fields for this object
            Map<String, Schema.SObjectField> fieldMap = sch.fields.getMap();
            for (String key : fieldMap.keySet() ) {
                Schema.DescribeFieldResult dfr = fieldMap.get(key).getDescribe();
                Schema.DisplayType fieldType = dfr.getType();
                // if (testOnly) { System.debug('*** ' + key + ' is of type ' + dfr.getType()); }
                if ((fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.ID ||
                     fieldType == Schema.DisplayType.URL || fieldType == Schema.DisplayType.REFERENCE ||
                     fieldType == Schema.DisplayType.TEXTAREA) && dfr.isUpdateable() ) {
                   fieldsToRetrieve.add(dfr.getName());
                }
            }  // end for key/fieldmap
            
            // Fetch records for the specific object
            String objQuery = 'SELECT ' + String.join(fieldsToRetrieve, ',') + ' FROM ' + sch.getName();
            for (sObject s : Database.query(objQuery)) {
                Boolean updated = false;
                // Re-iterate through all fields, make substitutions as needed
                for (String key : fieldsToRetrieve ) {
                    if (key == 'Id') { continue; }
                    else if (s.get(key) == NULL) { continue; }  // Skip to next if nothing to match
                    Schema.DescribeFieldResult dfr = fieldMap.get(key).getDescribe();
                    if ((dfr.getType() == Schema.DisplayType.REFERENCE || dfr.getType() == Schema.DisplayType.ID)
                        && IdMap.get((Id)s.get(key)) != NULL) {
                        s.put(key, IdMap.get((Id)s.get(key))); updated = true;
                        if (testOnly) { 
                            System.debug('Writing value ' + s.get(key) + ' to field ' + key + 
                                         ' [Object: ' + s.Id + ' (' + sch.getName() + ') ]');
                        }  // end if testOnly
                    }   // end check for Id
                    else if (dfr.getType() == Schema.DisplayType.STRING || dfr.getType() == Schema.DisplayType.URL ||
                             dfr.getType() == Schema.DisplayType.TEXTAREA) {
                        String currVal = (String)s.get(key);
                        // Iterate through all keys in the StringMap to see if it's contained
                        for (String oldVal : StringMap.keySet() ) {
                            if (currVal.contains(oldVal)) {
                                currVal = currVal.replace(oldVal, StringMap.get(oldVal));
                                s.put(key, currVal);
                                updated = true;
                                if (testOnly) {
                                    System.debug('Replacing value ' + oldVal + ' with ' + StringMap.get(oldVal) + 
                                                 ' in field ' + key + ' [Object: ' + s.Id + ' (' + sch.getName() + ') ]');
                                    System.debug('+++ Substitute value: ' + currVal);
                                }  // end if testOnly
                            }   // end if contains oldval
                        }  // end for oldVal
                    }   // end check for String
                }   // end for field keys
                
                if (updated) { toUpdate.add(s); }
            }  // end for sobject s
        }   // end for sch

        for (sObject s : toUpdate) { 
            System.debug('>>>>>>>>ULAS AND DAS>>>>>'+s); 
        }
        
        
        //UPDATES THE SITE RECORD
        if (testOnly == false 
            && toUpdate.size() > 0) { 
            update toUpdate; 
        }
        
        
        //DUMMY DML ON PAGES, IT WILL REFRESH THE LINKS FROM SITE RECORD
        PagesApi__Page__c[] pages = [SELECT Id, PagesApi__Page_URL__c FROM PagesApi__Page__c];
        for (PagesApi__Page__c p : pages) {
            p.PagesApi__Page_URL__c = '';
        }
        update pages;
        
        //UPDATING THE MENU ITEMS
        PagesApi__Menu_Item__c[] menuItems = [SELECT Id FROM PagesApi__Menu_Item__c];
        update menuItems;
        
        
        //UPDATING THE CUSTOM SETTING WITH THE SITE URL
        GDO_Settings__c cs = [SELECT Id, Member_Portal_Base_URL__c FROM GDO_Settings__c LIMIT 1];
        cs.Member_Portal_Base_URL__c = [SELECT PagesApi__Site_URL__c FROM PagesApi__Site__c LIMIT 1].PagesApi__Site_URL__c;
        update cs;
        
        
       

        // UPDATE BASE URL FOR COMMUNITY SITE MENU ITEMS
        LTE__Menu_Item__c[] comSiteMenuItems = [SELECT Id, LTE__URL__c FROM LTE__Menu_Item__c];
        for (LTE__Menu_Item__c m : comSiteMenuItems) {
            System.debug('####'+ m.LTE__URL__c);
            if (m.LTE__URL__c != null)
                m.LTE__URL__c = m.LTE__URL__c.replaceAll('https://us-tdm-tso-15eb63ff4c6-1626e3c741a.force.com',cs.Member_Portal_Base_URL__c);
            System.debug('>>>>'+ m.LTE__URL__c);
        }
        update comSiteMenuItems;

        LTE__Site__c ltSite =  [SELECT LTE__Site_URL__c FROM LTE__Site__c LIMIT 1];
        ltSite.LTE__Site_URL__c = cs.Member_Portal_Base_URL__c;
        update ltSite;


       


        // NAV BAR EDUCATION
        // Updates the ITEM and FORM Ids on the Directory and ProgramApi
        //updateEducationLinks();

        // NAV BAR JOB BOARD
        // Updates the ITEM and FORM Ids on the Directory and JoinApi
        //updateJobBoardLinks();
    }

    @future
    private static void updateEducationLinks() {
        Framework.Log.push(GDO_Helper.class.getName(),'updateEducationLinks');
        try {
            OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c
            WHERE Name =: 'Certification Application Fee'
            LIMIT 1];

            DRCTS__Directories__c course = [SELECT Id FROM DRCTS__Directories__c
            WHERE Name ='Course Catalog' LIMIT 1];

            DRCTS__Directories__c exam = [SELECT Id FROM DRCTS__Directories__c
            WHERE Name ='Exam Schedule' LIMIT 1];

            PagesApi__Form__c creditForm = [SELECT Id FROM PagesApi__Form__c
            WHERE Name=: 'Submit External Credits' LIMIT 1] ;



            //ITEM - Pay Certification Fee
            ProgramApi__Requirement__c r = [SELECT Id, ProgramApi__Navigation_URL__c, ProgramApi__Requirement_Name__c
                                            FROM ProgramApi__Requirement__c
                                            WHERE ProgramApi__Requirement_Name__c =: 'Pay Certification Fee' LIMIT 1];


            ProgramApi__Goals__c g = [SELECT Id, ProgramApi__Requirement__c, ProgramApi__Navigation_URL__c
                                        FROM ProgramApi__Goals__c
                                        WHERE ProgramApi__Requirement_Title__c =: 'Pay Certification Fee'
                                        AND ProgramApi__Profile_Contact__c ='Bob Kelly'
                                        LIMIT 1];

            r.ProgramApi__Navigation_URL__c = '/cpbase__item?id='+item.Id;
            g.ProgramApi__Navigation_URL__c = '/cpbase__item?id='+item.Id;
            update r;
            update g;


            //DIRECTORY COURSE
            ProgramApi__Requirement__c r1 = [SELECT Id, ProgramApi__Navigation_URL__c, ProgramApi__Requirement_Name__c
            FROM ProgramApi__Requirement__c
            WHERE ProgramApi__Requirement_Name__c =: 'Register for 3 Month Course' LIMIT 1];


            ProgramApi__Goals__c g1 = [SELECT Id, ProgramApi__Requirement__c, ProgramApi__Navigation_URL__c
                                        FROM ProgramApi__Goals__c
                                        WHERE ProgramApi__Requirement_Title__c =: 'Register for 3 Month Course'
                                        AND ProgramApi__Profile_Contact__c ='Bob Kelly'
                                        LIMIT 1];

            r1.ProgramApi__Navigation_URL__c = '/s/searchdirectory?id='+course.Id;
            g1.ProgramApi__Navigation_URL__c = '/s/searchdirectory?id='+course.Id;
            update r1;
            update g1;

            //DIRECTORY EXAM
            ProgramApi__Requirement__c r2 = [SELECT Id, ProgramApi__Navigation_URL__c, ProgramApi__Requirement_Name__c
                                            FROM ProgramApi__Requirement__c
                                            WHERE ProgramApi__Requirement_Name__c =: 'Pass Exam' LIMIT 1];


            ProgramApi__Goals__c g2 = [SELECT Id, ProgramApi__Requirement__c, ProgramApi__Navigation_URL__c
                                        FROM ProgramApi__Goals__c
                                        WHERE ProgramApi__Requirement_Title__c =: 'Pass Exam'
                                        AND ProgramApi__Profile_Contact__c ='Bob Kelly'
                                        LIMIT 1];

            r2.ProgramApi__Navigation_URL__c = '/s/searchdirectory?id='+exam.Id;
            g2.ProgramApi__Navigation_URL__c = '/s/searchdirectory?id='+exam.Id;
            update r2;
            update g2;

            //FORM - EXam Credit
            ProgramApi__Requirement__c r4 = [SELECT Id, ProgramApi__Navigation_URL__c, ProgramApi__Requirement_Name__c
                                            FROM ProgramApi__Requirement__c
                                            WHERE ProgramApi__Requirement_Name__c =: 'Earn 100 Credits' LIMIT 1];


            ProgramApi__Goals__c g4 = [SELECT Id, ProgramApi__Requirement__c, ProgramApi__Navigation_URL__c
                                        FROM ProgramApi__Goals__c
                                        WHERE ProgramApi__Requirement_Title__c =: 'Earn 100 Credits'
                                        AND ProgramApi__Profile_Contact__c ='Bob Kelly'
                                        LIMIT 1];

            r4.ProgramApi__Navigation_URL__c = '/cpbase__form?Id='+creditForm.Id;
            g4.ProgramApi__Navigation_URL__c = '/cpbase__form?Id='+creditForm.Id;
            update r4;
            update g4;

            //FORM 2 - Exam Credit
            ProgramApi__Requirement__c r5 = [SELECT Id, ProgramApi__Navigation_URL__c, ProgramApi__Requirement_Name__c
                                                FROM ProgramApi__Requirement__c
                                                WHERE ProgramApi__Requirement_Name__c =: 'Submit External Credits'
                                                LIMIT 1];

            ProgramApi__Goals__c g5 = [SELECT Id, ProgramApi__Requirement__c, ProgramApi__Navigation_URL__c
                                            FROM ProgramApi__Goals__c
                                            WHERE ProgramApi__Requirement_Title__c =: 'Submit External Credits'
                                            AND ProgramApi__Profile_Contact__c ='Bob Kelly' LIMIT 1];

            r5.ProgramApi__Navigation_URL__c = '/cpbase__form?Id='+creditForm.Id;
            g5.ProgramApi__Navigation_URL__c = '/cpbase__form?Id='+creditForm.Id;
            update r5;
            update g5;

        }
        catch (Exception ex) {
            Framework.log.debugException(ex);
        }
    }

    @future
    private static void updateJobBoardLinks() {
        Framework.Log.push(GDO_Helper.class.getName(),'updateJobBoardLinks');
        try {
            GDO_Settings__c cs = [SELECT Id, Member_Portal_Base_URL__c FROM GDO_Settings__c LIMIT 1];

            //DIRECTORIES - See a Job Board
            DRCTS__Directories__c c = [SELECT Id FROM DRCTS__Directories__c
            WHERE Name ='Job Board'];

            PagesApi__Menu_Item__c m1 = [SELECT Id, PagesApi__Custom_URL__c
            FROM PagesApi__Menu_Item__c
            WHERE Name =: 'See Job Board' LIMIT 1];

            m1.PagesApi__Custom_URL__c ='/s/searchdirectory?id='+c.Id;
            update m1;

            LTE__Menu_Item__c m11 = [SELECT Id, LTE__URL__c
                                    FROM LTE__Menu_Item__c
                                    WHERE Name =: 'See Job Board' LIMIT 1];

            m11.LTE__URL__c = cs.Member_Portal_Base_URL__c + '/s/searchdirectory?id='+c.Id;
            update m11;



            //FORM - Use a Form to Post

            PagesApi__Form__c f2 = [SELECt Id FROM PagesApi__Form__c WHERE Name=: 'Update Job Postings' LIMIT 1];

            PagesApi__Menu_Item__c m5 = [SELECT Id, PagesApi__Custom_URL__c
                                            FROM PagesApi__Menu_Item__c
                                            WHERE Name =: 'Use a Form to Post a Job' LIMIT 1];

            m5.PagesApi__Custom_URL__c ='/cpbase__form?Id='+f2.Id;
            update m5;

            LTE__Menu_Item__c m55 = [SELECT Id, LTE__URL__c
                                        FROM LTE__Menu_Item__c
                                        WHERE Name =: 'Use a Form to Post a Job' LIMIT 1];

            m55.LTE__URL__c = cs.Member_Portal_Base_URL__c + '/cpbase__form?Id='+f2.Id;
            update m55;


            //JOINAPI - Purchase a Posting

            JoinApi__Step__c firstStep = [SELECT Id FROM JoinApi__Step__c
            WHERE Joinapi__Is_First_Step__c = true
            AND joinapi__Page_Title__c = 'Post Your Job Opening Today!' LIMIT 1];


            PagesApi__Menu_Item__c m6 = [SELECT Id, PagesApi__Custom_URL__c
                                        FROM PagesApi__Menu_Item__c
                                        WHERE Name =: 'Purchase a Posting' LIMIT 1];

            m6.PagesApi__Custom_URL__c ='/joinapi__membershiplist?Id='+firstStep.Id+'&order=1';
            update m6;

            LTE__Menu_Item__c m66 = [SELECT Id, LTE__URL__c
                                        FROM LTE__Menu_Item__c
                                        WHERE Name =: 'Purchase a Posting' LIMIT 1];

            m66.LTE__URL__c = cs.Member_Portal_Base_URL__c + '/joinapi__membershiplist?Id='+firstStep.Id+'&order=1';
            update m66;


            OrderApi__Item__c item1 = [SELECT Id FROM OrderApi__Item__c
            WHERE Name =: '30 Day Posting' LIMIT 1];

            OrderApi__Item__c item2 = [SELECT Id FROM OrderApi__Item__c
            WHERE Name =: 'Featured 30 Day Posting' LIMIT 1];

            OrderApi__Item__c item3 = [SELECT Id FROM OrderApi__Item__c
            WHERE Name =: 'Unlimited Job Posts' LIMIT 1];

            JoinApi__Step__c step1 = [SELECT Id,joinapi__Product_Step_Item__c,joinapi__Page_Title__c FROM JoinApi__Step__c
            WHERE joinapi__Is_Product_Step__c = true
            AND joinapi__Page_Title__c = '30 Day Posting' LIMIT 1];

            JoinApi__Step__c step2 = [SELECT Id,joinapi__Product_Step_Item__c,joinapi__Page_Title__c FROM JoinApi__Step__c
            WHERE joinapi__Is_Product_Step__c = true
            AND joinapi__Page_Title__c = 'Featured 30 Day Posting' LIMIT 1];

            JoinApi__Step__c step3 = [SELECT Id,joinapi__Product_Step_Item__c,joinapi__Page_Title__c FROM JoinApi__Step__c
            WHERE joinapi__Is_Product_Step__c = true
            AND joinapi__Page_Title__c = 'Month-to-Month Unlimited Job Postings' LIMIT 1];

            step1.joinapi__Product_Step_Item__c = item1.Id;
            step2.joinapi__Product_Step_Item__c = item2.Id;
            step3.joinapi__Product_Step_Item__c = item3.Id;

            update step1;
            update step2;
            update step3;
        }
        catch (Exception ex) {
            Framework.log.debugException(ex);
        }

    }

}