public without sharing class AttachedFilesHelper 
{
    public static boolean deleteAttachedFile(Id recordId)
    {
        List<Attached_File__c> attachedFiles = [    SELECT Id, Attached_To_Id__c
                                                    FROM Attached_File__c
                                                    WHERE (Id = :recordId) ];

        if(attachedFiles.size() > 0){
            Attached_File__c attachedFile = new Attached_File__c(Id = recordId);
            delete attachedFile;

            updateNumberOfFiles(attachedFiles[0].Attached_To_Id__c);
        }

        //delete from S3 here?

        return true;
    }

    public static Attached_File__c getAttachedFile(Id recordId) 
    {
        List<Attached_File__c> attachedFiles = [    SELECT Id, Name, Attached_To_Id__c, Attached_To_Type__c, 
                                                        File_Name__c, CreatedDate, CreatedBy.Name, File_Size__c,
                                                        CreatedById 
                                                    FROM Attached_File__c 
                                                    WHERE (Id = :recordId) ];  

        if(attachedFiles.size() > 0) return attachedFiles[0];
        return null; 
    }

    public static List<Attached_File__c> getAttachedFiles(Id attachedToId)
    {
        return [    SELECT Id, Name, Attached_To_Id__c, Attached_To_Type__c, 
                        File_Name__c, CreatedDate, CreatedBy.Name, File_Size__c,
                        CreatedById 
                    FROM Attached_File__c 
                    WHERE (Attached_To_Id__c = :attachedToId) 
                    ORDER BY CreatedDate DESC ];
    }

    public static void updateNumberOfFiles(Id attachedToId)
    {
        if(attachedToId.getSObjectType().getDescribe().getName() == 'Scorecard_Review__c'){
            List<AggregateResult> results = [ SELECT COUNT(Id) FROM Attached_File__c WHERE Attached_To_Id__c = :attachedToId ];
            
            Scorecard_Review__c review = new Scorecard_Review__c();
            review.Id = attachedToId;
            review.Number_Of_Files__c = (Integer)results[0].get('expr0');            
            update review;
        }
    }

    public static UploadData generateUploadData(Id attachedToId, string fileName, integer fileSize, string redirectUrl)
    {
        if(attachedToId == null) return null;
        if(string.isBlank(fileName)) return null;
        if(fileSize == 0) return null;

        fileName = getProperFileName(fileName);

        Attached_File__c attachedFile = new Attached_File__c();
        attachedFile.File_Name__c = fileName;
        attachedFile.Attached_To_Id__c = attachedToId;
        attachedFile.File_Size__c = fileSize;
        insert attachedFile;

        updateNumberOfFiles(attachedToId);

        return getUploadData(attachedFile, redirectUrl);
    }

    public static UploadData getUploadData(Attached_File__c attachedFile, string redirectUrl)
    {
        if(attachedFile == null) return null;
        if(string.isBlank(redirectUrl)) redirectUrl = '#';

        DateTime requestDate = DateTime.now();
        Scorecard_Settings__c settings = Scorecard_Settings__c.getInstance();

        AttachedFilesHelper.UploadData data = new AttachedFilesHelper.UploadData();
        data.accessKey = settings.S3_Access_Key__c;
        data.acl = settings.S3_Default_Acl__c;
        data.actionUrl = settings.S3_Bucket_Url__c;
        data.contentType = 'application/octet-stream';
        data.key = attachedFile.Id + '/' + attachedFile.File_Name__c;
        data.credential = settings.S3_Access_Key__c + '/' + requestDate.format('yyyyMMdd') + '/' + settings.S3_Region__c + '/S3/aws4_request';
        data.requestDate = requestDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

        DateTime expiration = DateTime.now().addHours(24);

        string jsonPolicy = '{';
        jsonPolicy += '    "expiration" : "' + expiration.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '",';
        jsonPolicy += '    "conditions" : [';
        jsonPolicy += '        { "acl" : "public-read" },';
        jsonPolicy += '        { "bucket" : "' + settings.S3_Bucket_Name__c + '" },';
        jsonPolicy += '        { "success_action_redirect" : "' + redirectUrl + '" },';
        jsonPolicy += '        [ "starts-with", "$key", "' + attachedFile.Id + '" ],';
        jsonPolicy += '        { "x-amz-algorithm" : "AWS4-HMAC-SHA256" },';
        jsonPolicy += '        { "x-amz-credential" : "' + data.credential + '" },';
        jsonPolicy += '        { "x-amz-date" : "' + data.requestDate + '" }';
        jsonPolicy += '    ]';
        jsonPolicy += ' }';

        data.policy = EncodingUtil.base64Encode(blob.valueOf(jsonPolicy));
        data.signature = createSignature(data.policy, settings.S3_Secret_Key__c);

        return data;
    }

    public static string createSignature(string canonicalBuffer, string secret) {
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(canonicalBuffer),blob.valueof(secret));
        return EncodingUtil.base64Encode(mac);
    }

    public static string getProperFileName(string fileName){
        fileName = fileName.replace('/', '\\');
        List<string> fullPath = fileName.split('\\\\');
        
        if(fullPath.size() > 0) return fullPath[fullPath.size() - 1];
        return fullPath[0];
    }

    public class UploadData
    {
        public UploadData(){}

        public string actionUrl { get; set; }
        public string key { get; set; }
        public string acl { get; set; }
        public string redirectUrl { get; set; }
        public string contentType { get; set; }
        public string metaId { get; set; }
        public string accessKey { get; set; }
        public string policy { get; set; }
        public string signature { get; set; }
        public string credential { get; set; }
        public string requestDate { get; set; }
    }
}