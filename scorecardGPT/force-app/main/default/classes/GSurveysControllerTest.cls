@isTest
public class GSurveysControllerTest {
	private static TestMethod void testGSurveysController(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('uId', Userinfo.getUserId());
    Apexpages.Standardcontroller stc;
    GSurveysController sc = new GSurveysController(stc);
    System.assert(sc.allSurveys.size()>0);
  }
    
    private static TestMethod void testMakeNewSurvey(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('uId', Userinfo.getUserId());
    Apexpages.Standardcontroller stc;
    GSurveysController sc = new GSurveysController(stc);
    System.assert(sc.makeNewSurvey()==null);
    sc.surveySite = '--SELECT SITE--';
    sc.newSurveyName = 'TestMakeNewSurvey';
    system.assert(sc.makeNewSurvey()==null);
    sc.surveySite = 'blah';
    System.assert(sc.makeNewSurvey()!=null);
    sc.doSurveyReset();     
  }
    
    private static TestMethod void testDeleteSurvey(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('uId', Userinfo.getUserId());
    Apexpages.Standardcontroller stc;
    GSurveysController sc = new GSurveysController(stc);
    System.assertEquals(GSurveysController.deleteSurvey(tu.surveyId),'true');
  }
}