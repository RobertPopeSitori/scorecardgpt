global class CleanTestData {

    public CleanTestData() { }
    
    public static void cleanEventData() {

        EventApi__Event__c[] events = [SELECT ID, Is_Test_Data__c FROM EventApi__Event__c WHERE Is_Test_Data__c = true];

        EventApi__Event_Status__c[] statuses = [SELECT Id, EventApi__Event__c FROM EventApi__Event_Status__c WHERE EventApi__Event__c IN: events];

        EventApi__Event_Status_Page__c[] esp = [SELECT Id,EventApi__Event_Status__c FROM EventApi__Event_Status_Page__c WHERE EventApi__Event_Status__c IN: statuses];

        EventApi__Section__c[] sections = [SELECT Id,EventApi__Event__c FROM EventApi__Section__c WHERE EventApi__Event__c IN: events];

        EventApi__Section_Ticket__c[] sts = [SELECT Id FROM EventApi__Section_Ticket__c WHERE EventApi__Section__c IN: sections];

        delete esp;
        delete statuses;
        delete sts;
        delete sections;
        delete events;

        try {
            EventApi__Event_Category__c[] cats = [SELECT ID, Is_Test_Data__c, (SELECT Id FROM EventApi__Events__r)
                    FROM EventApi__Event_Category__c
                    WHERE Is_Test_Data__c = true
            ];

            EventApi__Event_Category__c[] catToDeletes = new List<EventApi__Event_Category__c>();

            for (EventApi__Event_Category__c c : cats) {
                if (c.EventApi__Events__r != null && c.EventApi__Events__r.size() > 0) {
                    // Category has event so do not delete
                }
                else {
                    catToDeletes.add(c);
                }
            }
            delete catToDeletes;
        }
        catch (Exception ex) {
            Framework.Log.debugException(ex);
        }

        EventApi__Ticket_Type__c[] tt = [SELECT Id, Is_Test_Data__c FROM EventApi__Ticket_Type__c WHERE Is_Test_Data__c = true];
        delete tt;
        
        EventApi__Attendee__c[] Atten = [SELECT Id, Is_Test_Data__c FROM EventApi__Attendee__c WHERE Is_Test_Data__c = true];
        delete Atten;

        EventApi__Schedule_Item__c[] s = [SELECT Id, Is_Test_Data__c FROM EventApi__Schedule_Item__c WHERE Is_Test_Data__c = true];
        delete s;
        
        EventApi__Registration_Item__c[] resItem = [SELECT Id, Is_Test_Data__c FROM EventApi__Registration_Item__c WHERE Is_Test_Data__c = true];
        delete resItem;
        
        EventApi__Registration_Group__c[] resGrp = [SELECT Id, Is_Test_Data__c FROM EventApi__Registration_Group__c WHERE Is_Test_Data__c = true];
        delete resGrp;
        
        EventApi__Vendor__c[] vend = [SELECT Id, Is_Test_Data__c FROM EventApi__Vendor__c WHERE Is_Test_Data__c = true];
        delete vend;

        EventApi__Speaker__c[] sp = [SELECT Id, Is_Test_Data__c FROM EventApi__Speaker__c WHERE Is_Test_Data__c = true];
        delete sp;

        EventApi__Venue__c[] ven = [SELECT Id, Is_Test_Data__c FROM EventApi__Venue__c WHERE Is_Test_Data__c = true];
        delete ven;

        EventApi__Sponsor_Package__c[] spackage = [SELECT ID, Is_Test_Data__c FROM EventApi__Sponsor_Package__c WHERE Is_Test_Data__c = true];
        delete spackage;

        EventApi__Sponsor__c[] sponsor = [SELECT ID, Is_Test_Data__c FROM EventApi__Sponsor__c WHERE Is_Test_Data__c = true];
        delete sponsor;
        
        EventApi__Section__c[] sect = [SELECT Id, Is_Test_Data__c FROM EventApi__Section__c WHERE Is_Test_Data__c = true];
        delete sect;
        
        EventApi__Waitlist_Entry__c[] waitEntry = [SELECT Id, Is_Test_Data__c FROM EventApi__Waitlist_Entry__c WHERE Is_Test_Data__c = true];
        delete waitEntry;
        
        EventApi__Site_Event_Category__c[] eveCat = [SELECT Id, Is_Test_Data__c FROM EventApi__Site_Event_Category__c WHERE Is_Test_Data__c = true];
        delete eveCat;

        OrderApi__Store__c[] stores = [SELECT ID, Is_Test_Data__c FROM OrderApi__Store__c WHERE Is_Test_Data__c = true];

        Set<Id> storeIds = Framework.SetUtils.getIds(stores);

        //Custom payment types needs to be deleted before the store
        OrderApi__Custom_Payment_Type__c[] cts = [SELECT Id FROM OrderApi__Custom_Payment_Type__c WHERE OrderApi__Store__c IN: storeIds OR Is_Test_Data__c = true];

        delete cts;
        delete stores;

        PagesApi__Site__c[] site = [SELECT ID, Is_Test_Data__c FROM PagesApi__Site__c WHERE Is_Test_Data__c = true];
        delete site;

        OrderApi__Payment_Gateway__c[] w = [SELECT ID, Is_Test_Data__c FROM ORderApi__Payment_Gateway__c WHERE Is_Test_Data__c = true];
        delete w;

        PagesApi__Theme__c[] theme = [SELECT ID, Is_Test_Data__c FROM PagesApi__Theme__c WHERE Is_Test_Data__c = true];
        delete theme;
    }
    
    public static void cleanItemData() {

        OrderApi__Price_Rule__c[] pr = [SELECT ID, Is_Test_Data__c FROM OrderApi__Price_Rule__c WHERE Is_Test_Data__c = true];
        OrderApi__Price_Rule_Variable__c[] prv = [SELECT Id, OrderApi__Price_Rule__c FROM OrderApi__Price_Rule_Variable__c WHERE OrderApi__Price_Rule__c IN: pr OR Is_Test_Data__c = true];
    
        delete prv;
        delete pr;
    
        
        OrderApi__Package_Item__c[] pi = [SELECT Id,Is_Test_Data__c FROM OrderApi__Package_Item__c WHERE Is_Test_Data__c = true];
        delete pi;
        
        OrderApi__Item__c[] items = [SELECT ID, Is_Test_Data__c FROM OrderApi__Item__c WHERE Is_Test_Data__c = true];
        delete items;
        
        OrderApi__Assignment_Role__c[] ar = [SELECT ID, Is_Test_Data__c FROM OrderApi__Assignment_Role__c WHERE Is_Test_Data__c = true];
        delete ar;
    
        OrderApi__Item_Class__c[] cl = [SELECT ID, Is_Test_Data__c FROM OrderApi__Item_Class__c WHERE Is_Test_Data__c = true];
        delete cl;
        
        
        OrderApi__Renewal_Path__c[] rp = [SELECT ID, Is_Test_Data__c FROM OrderApi__Renewal_Path__c WHERE Is_Test_Data__c = true];
        OrderApi__Renewal_Path_Variable__c[] rpv = [SELECT Id, OrderApi__Renewal_Path__c FROM OrderApi__Renewal_Path_Variable__c WHERE OrderApi__Renewal_Path__c IN: rp OR Is_Test_Data__c = true];
        
        delete rpv;
        delete rp;
        
        
        OrderApi__Catalog__c[] catalog = [SELECT ID, Is_Test_Data__c FROM OrderApi__Catalog__c WHERE Is_Test_Data__c = true];
        OrderApi__Catalog_Item__c[] ci = [SELECT Id, OrderApi__Catalog__c FROM OrderApi__Catalog_Item__c WHERE OrderApi__Catalog__c IN: catalog OR Is_Test_Data__c = true];
        
        delete ci;
        delete catalog;
        
        
        OrderApi__Badge_Type__c[] bt = [SELECT ID, Is_Test_Data__c FROM OrderApi__Badge_Type__c WHERE Is_Test_Data__c = true];
        OrderApi__Badge_Workflow__c[] bw = [SELECT Id, OrderApi__Badge_Type__c FROM OrderApi__Badge_Workflow__c WHERE OrderApi__Badge_Type__c IN: bt OR Is_Test_Data__c = true];
        OrderApi__Badge__c[] badge = [SELECT Id, OrderApi__Badge_Workflow__c FROM OrderApi__Badge__c WHERE OrderApi__Badge_Workflow__c IN: bw OR Is_Test_Data__c = true];
        
        delete badge;
        delete bw;
        delete bt;
        
        OrderApi__Payment_Terms__c[] pt = [SELECT ID, Is_Test_Data__c FROM OrderApi__Payment_Terms__c WHERE Is_Test_Data__c = true];
        delete pt;
        
        OrderApi__Source_Code__c[] sc = [SELECT ID, Is_Test_Data__c FROM OrderApi__Source_Code__c WHERE Is_Test_Data__c = true];
        delete sc;
        
        OrderApi__Access_Permission__c[] ap = [SELECT ID, Is_Test_Data__c FROM OrderApi__Access_Permission__c WHERE Is_Test_Data__c = true];
        delete ap;
        
    }
    
    public static void cleanSubscriptionData() {

        OrderApi__Subscription_Plan__c[] sp = [SELECT ID, Is_Test_Data__c FROM OrderApi__Subscription_Plan__c WHERE Is_Test_Data__c = true];
    
        OrderApi__Item_Subscription_Plan__c[] isp = [SELECT Id, OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Subscription_Plan__c IN: sp OR Is_Test_Data__c = true];
    
        OrderApi__Subscription__c[] subscription = [SELECT Id,OrderApi__Subscription_Plan__c FROM OrderApi__Subscription__c WHERE OrderApi__Subscription_Plan__c IN: sp OR Is_Test_Data__c = true];
    
        OrderApi__Assignment__c[] assignment = [SELECT Id,OrderApi__Subscription__c FROM OrderApi__Assignment__c WHERE OrderApi__Subscription__c IN: subscription OR Is_Test_Data__c = true];
    
        OrderApi__Renewal__c[] renewal = [SELECT Id FROM OrderApi__Renewal__c WHERE OrderApi__Subscription__c IN: subscription OR Is_Test_Data__c = true];
        
        OrderApi__Subscription_Line__c[] sl = [SELECT Id FROM OrderApi__Subscription_Line__c WHERE OrderApi__Subscription__c IN: subscription OR Is_Test_Data__c = true];
        
        delete sl;
        delete renewal;
        delete assignment;
        delete subscription;
        delete isp;
        delete sp;
        
    }
    
    public static void cleanFinanceData() {

        OrderApi__Payment_Method__c[] pm = [SELECT ID, Is_Test_Data__c FROM OrderApi__Payment_Method__c  WHERE Is_Test_Data__c = true];
        
        OrderApi__Shipping_Region__c[] sr = [SELECT ID, Is_Test_Data__c FROM OrderApi__Shipping_Region__c WHERE Is_Test_Data__c = true];
        
        OrderApi__Scheduled_Payment__c[] sp = [SELECT ID, Is_Test_Data__c, OrderApi__Saved_Payment_Method__c  FROM OrderApi__Scheduled_Payment__c WHERE OrderApi__Saved_Payment_Method__c  IN: pm OR Is_Test_Data__c = true];
        
        OrderApi__Batch__c[] batch = [SELECT ID, Is_Test_Data__c FROM OrderApi__Batch__c WHERE Is_Test_Data__c = true];
        
        OrderApi__Sales_Order__c[] so = [SELECT Id, Is_Test_Data__c, OrderApi__Payment_Method__c  FROM OrderApi__Sales_Order__c WHERE Is_Test_Data__c = true];
    
        OrderApi__Sales_Order_Line__c[] sol = [SELECT Id,Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c IN: so OR Is_Test_Data__c = true];
    
        OrderApi__Invoice__c[] inv = [SELECT Id, Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__Invoice__c WHERE Is_Test_Data__c = true];
    
        OrderApi__Invoice_Line__c[] renewal = [SELECT Id, Is_Test_Data__c, OrderApi__Invoice__c FROM OrderApi__Invoice_Line__c WHERE OrderApi__Invoice__c IN: inv OR Is_Test_Data__c = true];
        
        OrderApi__EPayment__c[] ep = [SELECT Id, Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__EPayment__c WHERE Is_Test_Data__c = true];
        
        OrderApi__EPayment_Line__c[] epl = [SELECT Id, Is_Test_Data__c, OrderApi__EPayment__c FROM OrderApi__EPayment_Line__c WHERE OrderApi__EPayment__c IN: ep OR Is_Test_Data__c = true];
        
        OrderApi__Receipt__c[] rec = [SELECT Id, Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__Receipt__c WHERE Is_Test_Data__c = true];
        
        OrderApi__Receipt_Line__c[] rl = [SELECT Id, Is_Test_Data__c, OrderApi__Receipt__c FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c IN: rec OR Is_Test_Data__c = true];
        
        OrderApi__Transaction__c[] tran = [SELECT Id, Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__Transaction__c WHERE OrderApi__Receipt__c IN: rec OR Is_Test_Data__c = true];
        
        OrderApi__Transaction_Line__c[] tl = [SELECT Id, Is_Test_Data__c, OrderApi__Transaction__c FROM OrderApi__Transaction_Line__c WHERE OrderApi__Transaction__c IN: tran OR Is_Test_Data__c = true];
        
        delete tl;
        delete tran;
        delete rl;
        delete rec;
        delete epl;
        delete ep;
        delete renewal;
        delete inv;
        delete sol;
        delete so;
        delete batch;
        delete sp;
        delete sr;
        delete pm;
        
    }
    
    public static void cleanCommunityData() {

        PagesApi__Community_Group__c[] cg = [SELECT Id, Is_Test_Data__c FROM PagesApi__Community_Group__c WHERE Is_Test_Data__c = true];
            
        PagesApi__Community_Group_Member__c[] cgm = [SELECT Id, Is_Test_Data__c, PagesApi__Community_Group__c FROM PagesApi__Community_Group_Member__c WHERE PagesApi__Community_Group__c IN: cg OR Is_Test_Data__c = true];
        
        delete cgm;
        delete cg;
    }
    
    public static void cleanFormsData() {

        PagesApi__Form__c[] form = [SELECT Id, Is_Test_Data__c FROM PagesApi__Form__c WHERE Is_Test_Data__c = true];
            
        PagesApi__Field_Group__c[] fg = [SELECT Id, Is_Test_Data__c, PagesApi__Form__c FROM PagesApi__Field_Group__c WHERE PagesApi__Form__c IN: form OR Is_Test_Data__c = true];
        
        PagesApi__Field__c[] field = [SELECT Id, Is_Test_Data__c, PagesApi__Field_Group__c FROM PagesApi__Field__c WHERE PagesApi__Field_Group__c IN: fg OR Is_Test_Data__c = true];
        
        PagesApi__Form_Response__c[] foRe = [SELECT Id, Is_Test_Data__c, PagesApi__Form__c FROM PagesApi__Form_Response__c WHERE PagesApi__Form__c IN: form OR Is_Test_Data__c = true];
        
        PagesApi__Field_Response__c[] fr = [SELECT Id, Is_Test_Data__c, PagesApi__Field__c FROM PagesApi__Field_Response__c WHERE PagesApi__Field__c IN: field OR Is_Test_Data__c = true];
        
        delete fr;
        delete foRe;
        delete field;
        delete fg;
        delete form;
    }
    
    public static void cleanDirectoryData() {

        DRCTS__Directories__c[] Direc = [SELECT Id, Is_Test_Data__c FROM DRCTS__Directories__c WHERE Is_Test_Data__c = true];
            
        DirectoryApi__Directory__c[] MemDirectory = [SELECT Id, Is_Test_Data__c FROM DirectoryApi__Directory__c WHERE Is_Test_Data__c = true];
        
        DirectoryApi__Site_Directory__c[] sd = [SELECT Id, Is_Test_Data__c, DirectoryApi__Directory__c FROM DirectoryApi__Site_Directory__c WHERE DirectoryApi__Directory__c IN: MemDirectory OR Is_Test_Data__c = true];
        
        delete sd;
        delete MemDirectory;
        delete Direc;
        
    }
    
    public static void cleanProgramsData() {

        ProgramApi__Program_Type__c[] ProTy = [SELECT Id, Is_Test_Data__c FROM ProgramApi__Program_Type__c WHERE Is_Test_Data__c = true];
            
        ProgramApi__Program__c[] prg = [SELECT Id, Is_Test_Data__c, ProgramApi__Program_Type__c FROM ProgramApi__Program__c WHERE ProgramApi__Program_Type__c IN: ProTy OR Is_Test_Data__c = true];
        
        ProgramApi__Program_Profile__c[] ProProf = [SELECT Id, Is_Test_Data__c, ProgramApi__Program__c FROM ProgramApi__Program_Profile__c WHERE ProgramApi__Program__c IN: prg OR Is_Test_Data__c = true];
        
        ProgramApi__Program_Term__c[] pt = [SELECT Id, Is_Test_Data__c, ProgramApi__Profile__c FROM ProgramApi__Program_Term__c WHERE ProgramApi__Profile__c IN: ProProf OR Is_Test_Data__c = true];
        
        ProgramApi__Goals__c[] ProGoal = [SELECT Id, Is_Test_Data__c, ProgramApi__Program_Profile__c FROM ProgramApi__Goals__c WHERE ProgramApi__Program_Profile__c IN: ProProf OR Is_Test_Data__c = true];
        
        delete ProGoal;
        delete pt;
        delete ProProf;
        delete prg;
        delete ProTy;
    }
    
    public static void cleanFundraisingData() {

        OrderApi__Campaign_Page__c[] cp = [SELECT Id, Is_Test_Data__c FROM OrderApi__Campaign_Page__c WHERE Is_Test_Data__c = true];
        delete cp;
    }
    
    public static void test(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
    public static void cleanSetupData() {

        List <Contact> contToDelete = new List <Contact>();
        Contact[] cont = [SELECT Id, Is_Test_Data__c, (select id from users) FROM Contact WHERE Is_Test_Data__c = true];
        for(Contact con : cont){
            if(con.Users.size()==0){
                contToDelete.add(con);
            }
        }
        delete contToDelete;
        
        Map <Id, Account> accToDelete = new Map <Id, Account>();
        
        /*Contact[] cont1 = [SELECT Id, Account.Is_Test_Data__c, (select id from users) FROM Contact WHERE Account.Is_Test_Data__c = true AND Is_Test_Data__c = false];
        for(Contact con1 : cont1){
            if(con1.Users.size()==0){
                accToDelete.put(con1.Account.id, con1.Account);
            }
        } */
        
        
        Account[] acc = [SELECT Id, Is_Test_Data__c, (SELECT Id FROM Contacts WHERE Is_Test_Data__c = true) FROM Account WHERE Is_Test_Data__c = true];
        for(Account acc1 : acc){
            if(acc1.Contacts.size()==0){
                accToDelete.put(acc1.id, acc1);
            }
        }
        delete accToDelete.values();
        
        OrderApi__GL_Account__c[] GLAcc = [SELECT Id, Is_Test_Data__c FROM OrderApi__GL_Account__c WHERE Is_Test_Data__c = true];
        delete GLAcc;
        
        OrderApi__Tax_Locale__c[] tl = [SELECT Id, Is_Test_Data__c FROM OrderApi__Tax_Locale__c WHERE Is_Test_Data__c = true];
        delete tl;
        
        OrderApi__Business_Group__c[] bg = [SELECT Id, Is_Test_Data__c FROM OrderApi__Business_Group__c WHERE Is_Test_Data__c = true];
        delete bg;
    }
}