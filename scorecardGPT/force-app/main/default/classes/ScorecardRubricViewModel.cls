public class ScorecardRubricViewModel 
{
    public ScorecardRubricViewModel() { }

    public ScorecardRubricViewModel(Scorecard_Rubric__c rubric) 
    { 
        if(rubric == null) return;

        this.id = rubric.Id;
        this.score = integer.valueOf(rubric.Value__c);
        this.description = rubric.Description__c;
        this.recommendation = rubric.Recommendation__c;
    }

    public string id { get; set; }
    public integer score { get; set; }
    public string description { get; set; } 
    public string recommendation { get; set; }

    public static List<ScorecardRubricViewModel> listToView(List<Scorecard_Rubric__c> rubrics)
    {
        List<ScorecardRubricViewModel> models = new List<ScorecardRubricViewModel>();

        for(Scorecard_Rubric__c rubric : rubrics){
            models.add(new ScorecardRubricViewModel(rubric));
        }

        return models;
    }
}