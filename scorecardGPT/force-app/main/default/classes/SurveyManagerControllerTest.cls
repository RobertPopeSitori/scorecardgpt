@isTest
public class SurveyManagerControllerTest {
	
    Public static Testmethod void testsurveymanager(){
		Survey__c s = new Survey__c();
    	s.Name = 'Test Survey';
    	s.Submit_Response__c = 'Test'; 
    	insert s;
        
        ApexPages.StandardController StdController = new ApexPages.StandardController(s);
        SurveyManagerController smv = new SurveyManagerController(StdController);
        smv.getEditCSS();
    }
}