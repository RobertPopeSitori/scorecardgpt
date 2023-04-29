public class ScorecardSectionViewModel 
{
    public ScorecardSectionViewModel() { 
        this.isSelected = false;
        this.questions = new List<ScorecardQuestionViewModel>();
    }

    public ScorecardSectionViewModel(Scorecard_Section__c source)
    {
        this.isSelected = false;
        this.id = source.Id;
        this.title = source.Title__c;
        this.description = source.Description__c;
        this.order = integer.valueOf(source.Order__c);
        this.questions = new List<ScorecardQuestionViewModel>();
    }

    public ScorecardSectionViewModel(Scorecard_Section__c source, List<Scorecard_Question__c> sortedList, boolean selected, 
        Scorecard_Role__mdt permission, List<Scorecard_Review__c> reviews)
    {
        this.isSelected = selected;
        this.id = source.Id;
        this.title = source.Title__c;
        this.description = source.Description__c;
        this.order = integer.valueOf(source.Order__c);
        this.userRole = permission.MasterLabel;

        this.questions = new List<ScorecardQuestionViewModel>();
        for(Scorecard_Question__c question : sortedList)
        {
            List<Scorecard_Review__c> reviewItems = new List<Scorecard_Review__c>();
            for(Scorecard_Review__c review : reviews) {
                if(review.Question__c == question.Id) {
                    reviewItems.add(review);
                }
            }

            this.questions.add(new ScorecardQuestionViewModel(question, permission, reviewItems));
        }
    }

    public string id { get; set; }
    public string title { get; set; }
    public string description { get; set; }
    public integer order { get; set; }
    public List<ScorecardQuestionViewModel> questions { get; set; }
    public boolean isSelected { get; set; }
    public string userRole { get; set; }

    public boolean userCanAccessSection { get; set; }
}