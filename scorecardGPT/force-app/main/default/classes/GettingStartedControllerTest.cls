@isTest
public class GettingStartedControllerTest {
    
    @isTest(SeeAllData='true')
	public static void testGettingStarted()
  {
      List<Survey__c> surveys = [select Id, Name From Survey__c where Name='SurveyForce Sample Survey'];
      GettingStartedController gsc = new GettingStartedController();
      if (surveys.size() >=1)
      {
        System.assertEquals(true,gsc.testSurveyAvailable);
      } 
      else
      {
        System.assertEquals(false,gsc.testSurveyAvailable);
      }
      gsc.makeTestSurvey();
      gsc.takeSurvey();
      gsc.viewResults();
      gsc.viewSurvey();
      
      
      List<Survey__c> surveys2  = [select Id, Name From Survey__c where Name='SurveyForce Sample Survey'];
      System.assertEquals(surveys.size() + 1, surveys2.size());
      System.assertEquals(true,gsc.testSurveyAvailable);
     
      
  }
}