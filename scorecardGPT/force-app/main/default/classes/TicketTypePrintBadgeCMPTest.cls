@isTest
public class TicketTypePrintBadgeCMPTest {
    
    @isTest
    public static void TicketTypePrintBadgeCMPTestmethod(){
        
        EventApi__Event_Category__c category= new EventApi__Event_Category__c();
        category.Name ='Test';
        category.EventApi__Registration_Style__c	= 'Conference';
        category.EventApi__Enable_Registration_Groups__c = True;
        insert category;
        date startdate = system.today();
        date enddate = system.today();
        EventApi__Event__c event = new EventApi__Event__c();
        event.EventApi__Is_Active__c= True;
        event.Name='Test';
        event.EventApi__Event_Key__c='ab492a59-2bab-4';
        event.EventApi__Schedule_Item_Display_Name__c= 'Test';
        event.EventApi__Start_Date__c = system.today();
        event.EventApi__End_Date__c= (system.today() +1);
        event.EventApi__Time_Zone__c='(GMT-04:00) America/New_York';
        event.EventApi__Ticket_Sales_Start_Date__c = system.today();
        insert event;
        
        
        
        TicketTypePrintBadgeCMP.returnTicketType(event.Id);
       TicketTypePrintBadgeCMP.send();
        TicketTypePrintBadgeCMP.getAttende(event.Id, startdate, enddate);
    }
}