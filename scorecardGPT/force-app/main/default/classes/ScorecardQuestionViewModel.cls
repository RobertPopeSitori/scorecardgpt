public class ScorecardQuestionViewModel 
{
    public ScorecardQuestionViewModel() { }

    public ScorecardQuestionViewModel(Scorecard_Question__c source, Scorecard_Role__mdt permission, 
		List<Scorecard_Review__c> reviews)
    {
        this.id = source.Id;
        this.description = source.Description__c;
        this.order = integer.valueOf(source.Order__c);
        this.question = source.Question__c;
		this.sectionId = source.Section__c;
		this.sectionName = source.Section__r.Title__c;

        this.userCanAnswer =  permission.Answer_Question__c;

        this.reviews = new List<ScorecardReviewViewModel>();
        this.answers = new List<ScorecardReviewViewModel>();

        for(Scorecard_Review__c review : reviews)
        {
            //everyone can see the answer
            if(review.Type__c == 'Answer')
			{
				ScorecardReviewViewModel aModel = new ScorecardReviewViewModel(review, permission);
				//List<Scorecard_Comment__c> aComments =ScorecardHelper.getReviewComments(review.Id);
				//aModel.comments = ScorecardCommentViewModel.toList(aComments);

                this.answers.add(aModel);
                continue;
            }

            if(review.Type__c == 'Review')
            {
                //observer can see the reviews
                if(permission.DeveloperName == 'Observer') {
                    this.reviews.add(new ScorecardReviewViewModel(review, permission));
                    continue;
                }

                if(permission.DeveloperName == 'Reviewer')
                {
                    if(review.Scorecard_User__c == UserInfo.getUserId()){
                        this.reviews.add(new ScorecardReviewViewModel(review, permission));
                    }
                }

                if(permission.DeveloperName == 'Lead_Reviewer'){
                    this.reviews.add(new ScorecardReviewViewModel(review, permission));
                }
            }
            
			//only the author/ reviewer can see the final review
			if(review.Type__c == 'Final Review')
			{
				if(review.Scorecard_User__c == UserInfo.getUserId()){
	               this.reviews.add(new ScorecardReviewViewModel(review, permission));
				}
			}
        }
    }

    public string id { get; set; }
    public string description { get; set; }
    public string question { get; set; }
    public integer order { get; set; }
    public string rubric { get; set; }
    public string scorecardId { get; set; }
	public string sectionId { get; set; }
	public string sectionName { get; set; }

    public boolean userCanAnswer { get; set; }
    public boolean userCanReview { get; set; }
    public boolean userCanFinalReview { get; set; }

    public ScorecardReviewViewModel review { get; set; }
    public List<ScorecardRubricViewModel> rubrics { get; set; }
    public List<ScorecardReviewViewModel> answers { get; set; }
    public List<ScorecardReviewViewModel> reviews { get; set; }
}