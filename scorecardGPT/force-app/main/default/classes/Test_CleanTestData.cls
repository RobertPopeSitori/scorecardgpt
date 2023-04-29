/**
 *@Purpose       : Test class for CleanTestData controller
 *@Created Date  : 01-03-2018
 *@Modified Date : 
 */
@isTest
public class Test_CleanTestData {
    static Boolean isInstalled = false;

    public static void install() {
        if (!isInstalled) {
            Framework.Installer.install();
            PagesApi.PackageScripts.install();
            OrderApi.PackageScripts.install();
            EventApi.PackageScripts.install();
            isInstalled = true;
        }
    }
    
    /**
     *@Purpose : to test CleanTestData Controller()
     */
    static testMethod void testCleanSetupAndItemData(){
    // SetupData
        Account account = new Account(Name = 'Test Account1', Is_Test_Data__c = true);
        insert account;
        
        Contact contact= new Contact(LastName = 'Test contact', AccountId = account.Id, OtherStreet = 'city galaxy street', MailingStreet ='Test mailing street', Is_Test_Data__c = true);
        insert contact;
        
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c(Name = 'Test BG', Is_Test_Data__c = true);
        insert bg;
        
       // OrderApi__GL_Account__c GLAcc = new OrderApi__GL_Account__c(Name = 'Test GL Account', OrderApi__Business_Group__c = bg.id, Is_Test_Data__c = true);
        //insert GLAcc;
        
        OrderApi__Tax_Locale__c tl = new OrderApi__Tax_Locale__c(Name = 'Test Tax Locale', Is_Test_Data__c = true);
        insert tl;
        
        // ItemData
        OrderApi__Price_Rule__c pr = new OrderApi__Price_Rule__c(Name='Test Price Rule', OrderApi__Price__c = 12, Is_Test_Data__c = true);
        insert pr;
        
        OrderApi__Price_Rule_Variable__c prv = new OrderApi__Price_Rule_Variable__c(OrderApi__Price_Rule__c = pr.id, OrderApi__Field__c = 'Testfield', OrderApi__Object__c = 'TestObject', OrderApi__Value__c = 'TestValue');
        insert prv;
        
        OrderApi__Item_Class__c itmClass = new OrderApi__Item_Class__c();
        itmClass.Name = 'Memberships';
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Assignment_SObject__c = 'TEST__C';
        itmClass.OrderApi__Business_Group__c = bg.Id;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Is_Test_Data__c = true;
        insert itmClass;
        
        OrderApi__Item__c itm = new OrderApi__Item__c(name='Test Item',OrderApi__Is_Subscription__c=true,OrderApi__Business_Group__c=bg.Id,OrderApi__Item_Class__c = itmClass.Id, OrderApi__Is_Active__c = true , Is_Test_Data__c = true);
        insert itm;
        
        OrderApi__Package_Item__c pi = new OrderApi__Package_Item__c(OrderApi__Package__c = itm.id, Is_Test_Data__c = true);
        insert pi;
        
        OrderApi__Assignment_Role__c ar = new OrderApi__Assignment_Role__c(Name='Test Assignment Role', Is_Test_Data__c = true);
        insert ar;
        
        OrderApi__Renewal_Path__c rp = new OrderApi__Renewal_Path__c(Is_Test_Data__c = true);
        insert rp;
        
        OrderApi__Renewal_Path_Variable__c rpv = new OrderApi__Renewal_Path_Variable__c(OrderApi__Renewal_Path__c = rp.id, OrderApi__Field__c = 'Testfield', OrderApi__Object__c = 'TestObject', OrderApi__Value__c = 'TestValue');
        insert rpv;
        
        OrderApi__Catalog__c  catalog = new OrderApi__Catalog__c(Name='Test Catalog', Is_Test_Data__c = true);
        insert catalog;
        
        OrderApi__Catalog_Item__c ci = new OrderApi__Catalog_Item__c(OrderApi__Catalog__c = catalog.id);
        insert ci;
        
        OrderApi__Badge_Type__c bt = new OrderApi__Badge_Type__c(Name='Test Badge Type', Is_Test_Data__c = true);
        insert bt;
        
        OrderApi__Badge_Workflow__c bw = new OrderApi__Badge_Workflow__c(Name='Test Badge Workflow', Is_Test_Data__c = true);
        insert bw;
        
        OrderApi__Badge__c badge = new OrderApi__Badge__c(Is_Test_Data__c = true);
        insert badge;
        
        OrderApi__Payment_Terms__c pt = new OrderApi__Payment_Terms__c(Name='Test Payment Terms', OrderApi__Display_Name__c = 'Test Display', OrderApi__Variable__c = 12, Is_Test_Data__c = true);
        insert pt;
        
        OrderApi__Source_Code__c sc = new OrderApi__Source_Code__c(Name='Test Source Code', Is_Test_Data__c = true);
        insert sc;
        
        OrderApi__Access_Permission__c ap = new OrderApi__Access_Permission__c(Is_Test_Data__c = true);
        insert ap;
        
        // SubscriptionData
        OrderApi__Subscription_Plan__c sp = new OrderApi__Subscription_Plan__c(Name='Test Access Permission', Is_Test_Data__c = true);
        insert sp;
        
        OrderApi__Item_Subscription_Plan__c isp = new OrderApi__Item_Subscription_Plan__c(OrderApi__Subscription_Plan__c = sp.id, OrderApi__Item__c = itm.id, Is_Test_Data__c = true);
        insert isp;
        
        OrderApi__Subscription__c subscription = new OrderApi__Subscription__c(Is_Test_Data__c = true);
        insert subscription;
        
        OrderApi__Assignment__c assignment = new OrderApi__Assignment__c(Is_Test_Data__c = true);
        insert assignment;
        
        OrderApi__Renewal__c renewal = new OrderApi__Renewal__c(OrderApi__Subscription__c = subscription.id, Is_Test_Data__c = true);
        insert renewal;
        
        OrderApi__Subscription_Line__c sl = new OrderApi__Subscription_Line__c(OrderApi__Subscription__c = subscription.id, Is_Test_Data__c = true);
        insert sl;
        
        Test.startTest();
        CleanTestData.cleanSubscriptionData();
        CleanTestData.cleanItemData();
        CleanTestData.test();
        CleanTestData.cleanSetupData();
        Test.stopTest();
        
        OrderApi__Price_Rule__c[] prLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Price_Rule__c];
        System.assertEquals(0,prLst.size());
        
        OrderApi__Price_Rule_Variable__c[] prvLst = [SELECT Id, OrderApi__Price_Rule__c FROM OrderApi__Price_Rule_Variable__c];
        System.assertEquals(0,prvLst.size());
        
        OrderApi__Package_Item__c[] piLst = [SELECT Id,Is_Test_Data__c FROM OrderApi__Package_Item__c];
        System.assertEquals(0,piLst.size());
        
        OrderApi__Item__c[] itemsLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Item__c];
        System.assertEquals(0,itemsLst.size());
        
        OrderApi__Assignment_Role__c[] arLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Assignment_Role__c];
        System.assertEquals(0,arLst.size());
        
        OrderApi__Item_Class__c[] clLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Item_Class__c];
        System.assertEquals(0,clLst.size());
        
        OrderApi__Renewal_Path__c[] rpLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Renewal_Path__c];
        System.assertEquals(0,rpLst.size());
        
        OrderApi__Renewal_Path_Variable__c[] rpvLst = [SELECT Id, OrderApi__Renewal_Path__c FROM OrderApi__Renewal_Path_Variable__c];
        System.assertEquals(0,rpvLst.size());
        
        OrderApi__Catalog__c[] catalogLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Catalog__c];
        System.assertEquals(0,catalogLst.size());
        
        OrderApi__Catalog_Item__c[] ciLst = [SELECT Id, OrderApi__Catalog__c FROM OrderApi__Catalog_Item__c];
        System.assertEquals(0,ciLst.size());
        
        OrderApi__Badge_Type__c[] btLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Badge_Type__c];
        System.assertEquals(0,btLst.size());
        
        OrderApi__Badge_Workflow__c[] bwLst = [SELECT Id, OrderApi__Badge_Type__c FROM OrderApi__Badge_Workflow__c];
        System.assertEquals(0,bwLst.size());
        
       // OrderApi__Badge__c[] badgeLst = [SELECT Id, OrderApi__Badge_Workflow__c FROM OrderApi__Badge__c];
        //System.assertEquals(0,badgeLst.size());
        
        OrderApi__Payment_Terms__c[] ptLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Payment_Terms__c];
        System.assertEquals(0,ptLst.size());
        
        OrderApi__Source_Code__c[] scLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Source_Code__c];
        System.assertEquals(0,scLst.size());
        
        OrderApi__Access_Permission__c[] apLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Access_Permission__c];
        System.assertEquals(0,apLst.size());
        
        OrderApi__Subscription_Plan__c[] spLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Subscription_Plan__c];
        System.assertEquals(0,spLst.size());
        
        OrderApi__Item_Subscription_Plan__c[] ispLst = [SELECT Id, OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c];
        System.assertEquals(0,ispLst.size());
        
        OrderApi__Subscription__c[] subscriptionLst = [SELECT Id,OrderApi__Subscription_Plan__c FROM OrderApi__Subscription__c];
        System.assertEquals(0,subscriptionLst.size());
        
        OrderApi__Assignment__c[] assignmentLst = [SELECT Id,OrderApi__Subscription__c FROM OrderApi__Assignment__c];
        System.assertEquals(0,assignmentLst.size());
        
        OrderApi__Renewal__c[] renewalLst = [SELECT Id FROM OrderApi__Renewal__c];
        System.assertEquals(0,renewalLst.size());
        
        OrderApi__Subscription_Line__c[] slLst = [SELECT Id FROM OrderApi__Subscription_Line__c];
        System.assertEquals(0,slLst.size());
        
        Account[] accLst = [SELECT Id, Is_Test_Data__c FROM Account];
        System.assertEquals(0,accLst.size());
        
        Contact[] contLst = [SELECT Id FROM Contact];
        System.assertEquals(0,contLst.size());
        
        OrderApi__GL_Account__c[] GLAccLst = [SELECT Id, Is_Test_Data__c FROM OrderApi__GL_Account__c];
        System.assertEquals(0,GLAccLst.size());
        
        OrderApi__Tax_Locale__c[] tlLst = [SELECT Id, Is_Test_Data__c FROM OrderApi__Tax_Locale__c];
        System.assertEquals(0,tlLst.size());
        
        OrderApi__Business_Group__c[] bgLst = [SELECT Id, Is_Test_Data__c FROM OrderApi__Business_Group__c];
        System.assertEquals(0,bgLst.size());
        
    }
    
   /* static testMethod void testCleanEventAndDirectoryData(){
        // EventData
        EventApi__Event__c events = new EventApi__Event__c(Name='Test Event', EventApi__Event_Key__c = '123ews34567qw234', Is_Test_Data__c = true);
        insert events;
        
        EventApi__Event_Status__c statuses = new EventApi__Event_Status__c(Name='Test Event Status', EventApi__Order__c = 123456, EventApi__Event__c = events.id);
        insert statuses;
        
        EventApi__Event_Page__c ePage = new EventApi__Event_Page__c(EventApi__Navigation_Label__c = 'abcxyz', EventApi__Page_Name__c = 'xyzabc');
        insert ePage;
        
        EventApi__Event_Status_Page__c esp = new EventApi__Event_Status_Page__c(EventApi__Event_Page__c = ePage.id, EventApi__Order__c = 123456, EventApi__Event_Status__c = statuses.id);
        insert esp;
        
        EventApi__Section__c sections = new EventApi__Section__c(Name='Test Section', EventApi__Display_Order__c = 1, EventApi__Event__c = events.id);
        insert sections;
        
        EventApi__Ticket_Type__c tt = new EventApi__Ticket_Type__c(Name='Test Ticket Type', Is_Test_Data__c = true);
        insert tt;

        EventApi__Section_Ticket__c sts = new EventApi__Section_Ticket__c(EventApi__Section__c = sections.id, EventApi__Ticket_Type__c = tt.id);
        insert sts;
        
        
        EventApi__Event_Category__c cats = new EventApi__Event_Category__c(Name='Test Event Category', Is_Test_Data__c = true);
        insert cats;
        
        EventApi__Schedule_Item__c s = new EventApi__Schedule_Item__c(Name='Test Schedule Item', Is_Test_Data__c = true);
        insert s;

        EventApi__Speaker__c speaker = new EventApi__Speaker__c(Name='Test Speaker', Is_Test_Data__c = true);
        insert speaker;

        EventApi__Venue__c ven = new EventApi__Venue__c(Name='Test Venue', Is_Test_Data__c = true);
        insert ven;

        EventApi__Sponsor_Package__c spackage = new EventApi__Sponsor_Package__c(Name='Test Sponsor Package', EventApi__Price__c = 23, Is_Test_Data__c = true);
        insert spackage;

        EventApi__Sponsor__c sponsor = new EventApi__Sponsor__c(Name='Test Sponsor', Is_Test_Data__c = true);
        insert sponsor;

        OrderApi__Store__c stores = new OrderApi__Store__c(Name='Test Store', Is_Test_Data__c = true);
        insert stores;

        OrderApi__Custom_Payment_Type__c cts = new OrderApi__Custom_Payment_Type__c(Name='Test Custom Payment Type', OrderApi__Store__c = stores.id, OrderApi__Custom_Payment_Type_Template__c = 'Test temp', Is_Test_Data__c = true);
        insert cts;
        
        PagesApi__Site__c site = new PagesApi__Site__c(Name='Test Site', Is_Test_Data__c = true);
        insert site;

        OrderApi__Payment_Gateway__c w = new OrderApi__Payment_Gateway__c(Name='Test Payment Gateway', Is_Test_Data__c = true);
        insert w;

        PagesApi__Theme__c theme = new PagesApi__Theme__c(Name='Test Theme', Is_Test_Data__c = true);
        insert theme;
        
        // DirectoryData
        DRCTS__Directories__c Direc = new DRCTS__Directories__c(Name='Test Directories', Is_Test_Data__c = true);
        insert Direc;
            
        DirectoryApi__Directory__c MemDirectory = new DirectoryApi__Directory__c(Name='Test Directory', Is_Test_Data__c = true);
        insert MemDirectory;
        
        DirectoryApi__Site_Directory__c sd = new DirectoryApi__Site_Directory__c(DirectoryApi__Directory__c = MemDirectory.id, DirectoryApi__Site__c = site.id, Is_Test_Data__c = true);
        insert sd;
        
        Test.startTest();
        CleanTestData.cleanEventData();
        CleanTestData.cleanDirectoryData();
        Test.stopTest();
        
        EventApi__Event__c[] eventsLst = [SELECT ID, Is_Test_Data__c FROM EventApi__Event__c];
        System.assertEquals(0,eventsLst.size());

        EventApi__Event_Status__c[] statusesLst = [SELECT Id, EventApi__Event__c FROM EventApi__Event_Status__c];
        System.assertEquals(0,statusesLst.size());
        
        EventApi__Event_Status_Page__c[] espLst = [SELECT Id,EventApi__Event_Status__c FROM EventApi__Event_Status_Page__c];
        System.assertEquals(0,espLst.size());
        
        EventApi__Section__c[] sectionsLst = [SELECT Id,EventApi__Event__c FROM EventApi__Section__c];
        System.assertEquals(0,sectionsLst.size());
        
        EventApi__Section_Ticket__c[] stsLst = [SELECT Id FROM EventApi__Section_Ticket__c];
        System.assertEquals(0,stsLst.size());
        
        EventApi__Event_Category__c[] catsLst = [SELECT ID FROM EventApi__Event_Category__c];
        System.assertEquals(0,catsLst.size());
        
        EventApi__Ticket_Type__c[] ttLst = [SELECT Id, Is_Test_Data__c FROM EventApi__Ticket_Type__c];
        System.assertEquals(0,ttLst.size());
        
        EventApi__Schedule_Item__c[] sLst = [SELECT Id, Is_Test_Data__c FROM EventApi__Schedule_Item__c];
        System.assertEquals(0,sLst.size());
        
        EventApi__Speaker__c[] spLst = [SELECT Id, Is_Test_Data__c FROM EventApi__Speaker__c];
        System.assertEquals(0,spLst.size());
        
        EventApi__Venue__c[] venLst = [SELECT Id, Is_Test_Data__c FROM EventApi__Venue__c];
        System.assertEquals(0,venLst.size());
        
        EventApi__Sponsor_Package__c[] spackageLst = [SELECT ID, Is_Test_Data__c FROM EventApi__Sponsor_Package__c];
        System.assertEquals(0,spackageLst.size());
        
        EventApi__Sponsor__c[] sponsorLst = [SELECT ID, Is_Test_Data__c FROM EventApi__Sponsor__c];
        System.assertEquals(0,sponsorLst.size());
        
        OrderApi__Store__c[] storesLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Store__c];
        System.assertEquals(0,storesLst.size());
        
        OrderApi__Custom_Payment_Type__c[] ctsLst = [SELECT Id FROM OrderApi__Custom_Payment_Type__c];
        System.assertEquals(0,ctsLst.size());
        
        PagesApi__Site__c[] siteLst = [SELECT ID, Is_Test_Data__c FROM PagesApi__Site__c];
        System.assertEquals(0,siteLst.size());
        
        OrderApi__Payment_Gateway__c[] wLst = [SELECT ID, Is_Test_Data__c FROM ORderApi__Payment_Gateway__c];
        System.assertEquals(0,wLst.size());
        
        PagesApi__Theme__c[] themeLst = [SELECT ID, Is_Test_Data__c FROM PagesApi__Theme__c];
        System.assertEquals(0,themeLst.size());
        
        DRCTS__Directories__c[] DirecLst = [SELECT Id, Is_Test_Data__c FROM DRCTS__Directories__c];
        System.assertEquals(0,DirecLst.size());
        
        DirectoryApi__Directory__c[] MemDirectoryLst = [SELECT Id, Is_Test_Data__c FROM DirectoryApi__Directory__c];
        System.assertEquals(0,MemDirectoryLst.size());
        
        DirectoryApi__Site_Directory__c[] sdLst = [SELECT Id, Is_Test_Data__c, DirectoryApi__Directory__c FROM DirectoryApi__Site_Directory__c];
        System.assertEquals(0,sdLst.size());
    }
    
    static testMethod void testCleanFinanceData(){
        // FinanceData
        OrderApi__Payment_Method__c pm = new OrderApi__Payment_Method__c(Is_Test_Data__c = true);
        insert pm;
        
        OrderApi__Shipping_Region__c sr = new OrderApi__Shipping_Region__c(Name='Test Shipping Region', Is_Test_Data__c = true);
        insert sr;
        
      //  OrderApi__Scheduled_Payment__c schpay = new OrderApi__Scheduled_Payment__c(OrderApi__Saved_Payment_Method__c  = pm.id, Is_Test_Data__c = true);
       // insert schpay;
        
        OrderApi__Batch__c batch = new OrderApi__Batch__c(Name='Test Batch', Is_Test_Data__c = true);
        insert batch;
        
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(Is_Test_Data__c = true);
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = so.id, Is_Test_Data__c = true);
        insert sol;
        
        OrderApi__Invoice__c inv = new OrderApi__Invoice__c(Is_Test_Data__c = true);
        insert inv;
        
        OrderApi__Invoice_Line__c il = new OrderApi__Invoice_Line__c(OrderApi__Invoice__c = inv.id, Is_Test_Data__c = true);
        insert il;
        
        OrderApi__EPayment__c ep = new OrderApi__EPayment__c(Is_Test_Data__c = true);
        insert ep;
        
        OrderApi__EPayment_Line__c epl = new OrderApi__EPayment_Line__c(OrderApi__EPayment__c = ep.id, Is_Test_Data__c = true);
        insert epl;
        
        OrderApi__Receipt__c rec = new OrderApi__Receipt__c(Is_Test_Data__c = true);
        insert rec;
        
        OrderApi__Receipt_Line__c rl = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c = rec.id, Is_Test_Data__c = true);
        insert rl;
        
        OrderApi__Transaction__c tran = new OrderApi__Transaction__c(Is_Test_Data__c = true);
        insert tran;
        
        OrderApi__Transaction_Line__c tranLine = new OrderApi__Transaction_Line__c(OrderApi__Transaction__c = tran.id, Is_Test_Data__c = true);
        insert tranLine;
        
        Test.startTest();
        CleanTestData.cleanFinanceData();
        Test.stopTest();
        
        OrderApi__Payment_Method__c[] pmLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Payment_Method__c];
        System.assertEquals(0,pmLst.size());
        
        OrderApi__Shipping_Region__c[] srLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Shipping_Region__c];
        System.assertEquals(0,srLst.size());
        
      //  OrderApi__Scheduled_Payment__c[] spLst = [SELECT ID, Is_Test_Data__c, OrderApi__Saved_Payment_Method__c  FROM OrderApi__Scheduled_Payment__c];
       // System.assertEquals(0,spLst.size());
        
        OrderApi__Batch__c[] batchLst = [SELECT ID, Is_Test_Data__c FROM OrderApi__Batch__c];
        System.assertEquals(0,batchLst.size());
        
        OrderApi__Sales_Order__c[] soLst = [SELECT Id, Is_Test_Data__c, OrderApi__Payment_Method__c FROM OrderApi__Sales_Order__c];
        System.assertEquals(0,soLst.size());
        
        OrderApi__Sales_Order_Line__c[] solLst = [SELECT Id,Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__Sales_Order_Line__c];
        System.assertEquals(0,solLst.size());
        
        OrderApi__Invoice__c[] invLst = [SELECT Id, Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__Invoice__c];
        System.assertEquals(0,invLst.size());
        
        OrderApi__Invoice_Line__c[] renewalLst = [SELECT Id, Is_Test_Data__c, OrderApi__Invoice__c FROM OrderApi__Invoice_Line__c];
        System.assertEquals(0,renewalLst.size());
        
        OrderApi__EPayment__c[] epLst = [SELECT Id, Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__EPayment__c];
        System.assertEquals(0,epLst.size());
        
        OrderApi__EPayment_Line__c[] eplLst = [SELECT Id, Is_Test_Data__c, OrderApi__EPayment__c FROM OrderApi__EPayment_Line__c];
        System.assertEquals(0,eplLst.size());
        
        OrderApi__Receipt__c[] recLst = [SELECT Id, Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__Receipt__c];
        System.assertEquals(0,recLst.size());
        
        OrderApi__Receipt_Line__c[] rlLst = [SELECT Id, Is_Test_Data__c, OrderApi__Receipt__c FROM OrderApi__Receipt_Line__c];
        System.assertEquals(0,rlLst.size());
        
        OrderApi__Transaction__c[] tranLst = [SELECT Id, Is_Test_Data__c, OrderApi__Sales_Order__c FROM OrderApi__Transaction__c];
        System.assertEquals(0,tranLst.size());
        
        OrderApi__Transaction_Line__c[] tlLst = [SELECT Id, Is_Test_Data__c, OrderApi__Transaction__c FROM OrderApi__Transaction_Line__c];
        System.assertEquals(0,tlLst.size());
    }
    
    static testMethod void testCleanCommunityData(){
        // CommunityData
        PagesApi__Community_Group__c cg = new PagesApi__Community_Group__c(Name='Test Community Group', Is_Test_Data__c = true);
        insert cg;
            
        PagesApi__Community_Group_Member__c cgm = new PagesApi__Community_Group_Member__c(PagesApi__Community_Group__c = cg.id, Is_Test_Data__c = true);
        insert cgm;
        
        Test.startTest();
        CleanTestData.cleanCommunityData();
        Test.stopTest();
        
        PagesApi__Community_Group__c[] cgLst = [SELECT Id, Is_Test_Data__c FROM PagesApi__Community_Group__c];
        System.assertEquals(0,cgLst.size());
        
        PagesApi__Community_Group_Member__c[] cgmLst = [SELECT Id, Is_Test_Data__c, PagesApi__Community_Group__c FROM PagesApi__Community_Group_Member__c];
        System.assertEquals(0,cgmLst.size());
    }
    
    static testMethod void testCleanFormsData(){
        // FormsData
        PagesApi__Form__c form = new PagesApi__Form__c(Name='Test Form', Is_Test_Data__c = true);
        insert form;
            
        PagesApi__Field_Group__c fg = new PagesApi__Field_Group__c(Name='Test Field Group', Is_Test_Data__c = true);
        insert fg;
        
        PagesApi__Field__c field = new PagesApi__Field__c(Name='Test Field', Is_Test_Data__c = true);
        insert field;
        
        PagesApi__Form_Response__c foRe = new PagesApi__Form_Response__c(Is_Test_Data__c = true);
        insert foRe;
        
        PagesApi__Field_Response__c fr = new PagesApi__Field_Response__c(Is_Test_Data__c = true);
        insert fr;
        
        Test.startTest();
        CleanTestData.cleanFormsData();
        Test.stopTest();
        
        PagesApi__Form__c[] formLst = [SELECT Id, Is_Test_Data__c FROM PagesApi__Form__c];
        System.assertEquals(0,formLst.size());
        
        PagesApi__Field_Group__c[] fgLst = [SELECT Id, Is_Test_Data__c, PagesApi__Form__c FROM PagesApi__Field_Group__c];
        System.assertEquals(0,fgLst.size());
        
        PagesApi__Field__c[] fieldLst = [SELECT Id, Is_Test_Data__c, PagesApi__Field_Group__c FROM PagesApi__Field__c];
        System.assertEquals(0,fieldLst.size());
        
        PagesApi__Form_Response__c[] foReLst = [SELECT Id, Is_Test_Data__c, PagesApi__Form__c FROM PagesApi__Form_Response__c];
        System.assertEquals(0,foReLst.size());
        
        PagesApi__Field_Response__c[] frLst = [SELECT Id, Is_Test_Data__c, PagesApi__Field__c FROM PagesApi__Field_Response__c];
        System.assertEquals(0,frLst.size());
    }
    
    static testMethod void testCleanProgramsAndFundraisingData(){
        // ProgramsData
        ProgramApi__Program_Type__c ProTy = new ProgramApi__Program_Type__c(Is_Test_Data__c = true);
        insert ProTy;
            
        ProgramApi__Program__c prg = new ProgramApi__Program__c(Name='Test Program', Is_Test_Data__c = true);
        insert prg;
        
        ProgramApi__Program_Profile__c ProProf = new ProgramApi__Program_Profile__c(Is_Test_Data__c = true);
        insert ProProf;
        
        ProgramApi__Program_Term__c proTerm = new ProgramApi__Program_Term__c(Is_Test_Data__c = true);
        insert proTerm;
        
        ProgramApi__Goals__c ProGoal = new ProgramApi__Goals__c(Is_Test_Data__c = true);
        insert ProGoal;
        
        // FundraisingData
        OrderApi__Campaign_Page__c cp = new OrderApi__Campaign_Page__c(Is_Test_Data__c = true);
        insert cp;
        
        Test.startTest();
        CleanTestData.cleanProgramsData();
        CleanTestData.cleanFundraisingData();
        Test.stopTest();
        
        ProgramApi__Program_Type__c[] ProTyLst = [SELECT Id, Is_Test_Data__c FROM ProgramApi__Program_Type__c];
        System.assertEquals(0,ProTyLst.size());
        
        ProgramApi__Program__c[] prgLst = [SELECT Id, Is_Test_Data__c, ProgramApi__Program_Type__c FROM ProgramApi__Program__c];
        System.assertEquals(0,prgLst.size());
        
        ProgramApi__Program_Profile__c[] ProProfLst = [SELECT Id, Is_Test_Data__c, ProgramApi__Program__c FROM ProgramApi__Program_Profile__c];
        System.assertEquals(0,ProProfLst.size());
        
        ProgramApi__Program_Term__c[] ptLst = [SELECT Id, Is_Test_Data__c, ProgramApi__Profile__c FROM ProgramApi__Program_Term__c];
        System.assertEquals(0,ptLst.size());
        
        ProgramApi__Goals__c[] ProGoalLst = [SELECT Id, Is_Test_Data__c, ProgramApi__Program_Profile__c FROM ProgramApi__Goals__c];
        System.assertEquals(0,ProGoalLst.size());
        
        OrderApi__Campaign_Page__c[] cpLst = [SELECT Id, Is_Test_Data__c FROM OrderApi__Campaign_Page__c];
        System.assertEquals(0,cpLst.size());
    }*/
}