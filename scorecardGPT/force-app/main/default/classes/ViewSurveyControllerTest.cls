@isTest
public class ViewSurveyControllerTest {
    
    private static Testmethod void testViewSurveyController() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
        Apexpages.Standardcontroller stc;   
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.init();
        vsc.updateSurveyThankYouAndLink();
        vsc.resultPage();
        
		Survey__c s = new Survey__c(Name = 'Test',Submit_Response__c = 'test resp');
        insert s;
        
        viewShareSurveyComponentController Controller = new viewShareSurveyComponentController();
        
        Survey_Question__c sq = new Survey_Question__c(Survey__c = s.id,OrderNumber__c = 1,Question__c = 'question');
        insert sq;

        for(ViewSurveyController.question vscq: vsc.allQuestions){
            vscq.selectedOption = String.valueof(2);
	        vscq.choices = String.valueof(2);
			vscq.selectedOptions = new List<String>();
	    	vscq.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);             
        System.assertEquals(true, vsc.thankYouRendered);
        
    }
    
    private static Testmethod void testUpdateSurveyName() {
      SurveyTestingUtil tu = new SurveyTestingUtil();
      Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
      Apexpages.Standardcontroller stc; 
      ViewSurveyController vsc = new ViewSurveyController(stc);
      vsc.surveyName = 'new name';
      system.assert(vsc.updateSurveyName() == null);
      
  }
  
    private static Testmethod void testupdateSurveyThankYouAndLink() {
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
    Apexpages.Standardcontroller stc; 
    ViewSurveyController vsc = new ViewSurveyController(stc);
    vsc.surveyThankYouText = 'new stuff';
    vsc.surveyThankYouURL = 'more new stff';
    system.assert(vsc.updateSurveyThankYouAndLink()==null);
        
  }
    
}