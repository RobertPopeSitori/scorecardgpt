public class ScorecardReviewViewModel 
{
    public ScorecardReviewViewModel(Scorecard_Review__c source, Scorecard_Role__mdt permission) 
    {
        this.id = source.Id;
        this.questionId = source.Question__c;
        this.scorecardId = source.Question__r.Section__r.Scorecard__c;
        this.htmlText = source.Review__c;
        this.status = source.Status__c;
        this.createdBy = source.LastModifiedBy.Name + '   ' + StringHelper.format(source.LastModifiedDate);
        this.createdDate = StringHelper.format(source.LastModifiedDate);
        this.rubric = new ScorecardRubricViewModel();
		this.files = source.Number_Of_Files__c == null ? 0 : Integer.valueOf(source.Number_Of_Files__c);
		this.comments = new List<ScorecardCommentViewModel>();
        
        //Scorecard_Role__mdt permission = ScorecardUserHelper.getRolePermissions(source.Question__r.Section__r.Scorecard__c);
        if(permission == null) {
            this.type = 'Unknown';
        } else {
            this.type = permission.Answer_Type__c;
        }

		this.userCanEdit = permission.Answer_Question__c;
		if(this.userCanEdit){
			this.userCanEdit = ScorecardHelper.checkReviewEditPermission(source.Question__r.Status__c, source.Status__c, 
				source.Question__r.Section__r.Scorecard__c, permission);
		}


        if(source.Rubric__c != null){
            ScorecardRubricViewModel rubricModel = new ScorecardRubricViewModel(source.Rubric__r);
            this.rubric = rubricModel;
        }
    }

    public string id { get; set; }
    public string htmlText { get; set; }
    public string createdBy { get; set; }
    public string createdDate { get; set; }
    public string type { get; set; }
    public string questionId { get; set; }
    public string scorecardId { get; set; }
    public string status { get; set; }
    public boolean userCanEdit { get; set; }
	public integer files { get; set; }
    public ScorecardRubricViewModel rubric { get; set; }
	public List<ScorecardCommentViewModel> comments { get; set; }

    public Scorecard_Review__c toReviewObject()
    {
        Scorecard_Review__c obj = new Scorecard_Review__c();
        obj.Id = this.id;
        obj.Review__c = this.htmlText;
        obj.Status__c = this.status;

        if(this.rubric != null && string.isNotBlank(this.rubric.id)){
            obj.Rubric__c = rubric.id;
        } 

        return obj;
    }
}