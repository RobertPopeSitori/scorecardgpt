@istest
public class SurveyTestingUtilTest {
	public static TestMethod void testConstructor(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Survey__c s = new Survey__c();
    s.Name = 'Testing Survey';
    s.Submit_Response__c = 'empty'; 
    insert s;
    
	tu.surveyId = s.Id;
    System.assert(tu.surveyId != null);
  }
}