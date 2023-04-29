@isTest
public class AttendeeBadgeLightningCLSTest {
    
    @isTest
    public static void AttendeeBadgeLightningCLSTestmethod(){
        Account acc=New Account(Name='Test Account');
        insert acc;
        
        Contact cont=New Contact(FirstName='Test',LastName='Test',AccountId=acc.Id);
        insert cont;
        
        EventApi__Event_Category__c category= new EventApi__Event_Category__c();
        category.Name ='Test';
        category.EventApi__Registration_Style__c    = 'Conference';
        category.EventApi__Enable_Registration_Groups__c = True;
        insert category;
        
        EventApi__Event__c event = new EventApi__Event__c();
        event.EventApi__Is_Active__c= True;
        event.Name='Test';
        event.EventApi__Event_Category__c= category.id;
        event.EventApi__Event_Key__c='ab492a59-2bab-4';
        event.EventApi__Schedule_Item_Display_Name__c= 'Test';
        event.EventApi__Start_Date__c = system.today();
        event.EventApi__End_Date__c= (system.today() +1);
        event.EventApi__Time_Zone__c='(GMT-04:00) America/New_York';
        event.EventApi__Ticket_Sales_Start_Date__c = system.today();
        insert event;
        
       /* EventApi__Attendee__c attendee = new EventApi__Attendee__c();
        attendee.EventApi__Contact__c = cont.Id;
        attendee.EventApi__Attendee_Event__c= event.Id;
        
        insert attendee;*/
       // EventApi__Attendee__c att = [select id from EventApi__Attendee__c LIMIT 1];
        
        AttendeeBadgeLightningCLS.getAttende(event.Id);
    }

}