public without sharing class AttachedFilesController
{
     @AuraEnabled
     public static string deleteFile(string recordId, string recordType)
     {
          Id attachedToId = null;
          Attached_File__c attachedFile = AttachedFilesHelper.getAttachedFile(recordId);
          if (attachedFile != null) {
               attachedToId = attachedFile.Attached_To_Id__c;
               AttachedFilesHelper.deleteAttachedFile(recordId);
          }

          return getAttachedFiles(attachedToId, recordType);
     }

     @AuraEnabled
     public static string getAttachedFiles(string recordId, string recordType)
     {
          if (string.isBlank(recordId)) return '';

          List<Attached_File__c> attachedFiles = AttachedFilesHelper.getAttachedFiles(recordId);

          List<AttachedFile> files = new List<AttachedFile> ();
          for (Attached_File__c file : attachedFiles) {
               files.add(new AttachedFile(file));
          }

          return JSON.serialize(files);
     }

     @AuraEnabled
     public static string getUploadData(string fileName, string attachedToId, string redirectUrl, integer fileSize)
     {
          AttachedFilesHelper.UploadData data = AttachedFilesHelper.generateUploadData(attachedToId, fileName, fileSize, redirectUrl);
          return JSON.serialize(data);
     }

     public class AttachedFile
     {
          public AttachedFile(Attached_File__c record)
          {
               Scorecard_Settings__c settings = Scorecard_Settings__c.getInstance();
               bucketUrl = settings.S3_Bucket_Url__c;

               fileId = record.Id;
               //uploadDate = record.CreatedDate.format('MM/dd/yyyy hh:mm:ss');
               uploadDate = StringHelper.format(record.CreatedDate);
               fileName = record.File_Name__c;
               filenumber = record.Name;

               if (record.File_Size__c > 0) {
                    decimal value = record.File_Size__c / 1024 / 1024;
                    fileSize = StringHelper.format(value, 2) + ' Mb';
               }

               createdBy = record.CreatedBy.Name;
               createdByUrl = '/lightning/r/' + record.CreatedById + '/view';
          }

          public string bucketUrl { get; set; }
          public string uploadDate { get; set; }
          public string fileName { get; set; }
          public string fileNumber { get; set; }
          public string createdBy { get; set; }
          public string fileSize { get; set; }
          public string fileId { get; set; }
          public string createdByUrl { get; set; }
     }
}