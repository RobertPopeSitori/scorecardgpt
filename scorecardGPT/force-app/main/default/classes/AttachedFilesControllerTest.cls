@IsTest
public class AttachedFilesControllerTest
{
     @testSetup
     public static void setScorecardSettings()
     {
          Scorecard_Settings__c settings = new Scorecard_Settings__c();
          settings.S3_Secret_Key__c = 'TEST-123-SECRET-KEY';
          settings.S3_Region__c = 'aws-east-1';
          settings.S3_Redirect_Url__c = 'https://my.test.com';
          settings.S3_Default_Acl__c = 'public-read';
          settings.S3_Access_Key__c = 'TEST-123-ACCESS-KEY';
          settings.S3_Bucket_Name__c = 's3bucket.name';

          insert settings;
     }

     public static testmethod void willGetUploadData()
     {
          Contact con = new Contact();
          con.LastName = 'Test';
          insert con;

          string jsonData = AttachedFilesController.getUploadData('test.jpg', con.Id, 'https://donotclick.com', 1024);
          System.assert(string.isNotBlank(jsonData));
     }

     public static testmethod void willGetAttachedFiles()
     {
          Contact con = new Contact();
          con.LastName = 'Test';
          insert con;

          string jsonData = AttachedFilesController.getUploadData('test.jpg', con.Id, 'https://donotclick.com', 1024);
          jsonData = AttachedFilesController.getAttachedFiles(con.Id, '');

          System.assert(string.isNotBlank(jsonData));
     }

     public static testmethod void willDeleteAttachedFile()
     {
          Contact con = new Contact();
          con.LastName = 'Test';
          insert con;

          string jsonData = AttachedFilesController.getUploadData('test.jpg', con.Id, 'https://donotclick.com', 1024);
          jsonData = AttachedFilesController.getAttachedFiles(con.Id, '');

          List<Attached_File__c> files = [SELECT Id FROM Attached_File__c WHERE Attached_To_Id__c = :con.Id];
          System.assert(files.size() > 0);

          jsonData = AttachedFilesController.deleteFile(files[0].Id, '');
          System.assert(string.isNotBlank(jsonData));
     }
}