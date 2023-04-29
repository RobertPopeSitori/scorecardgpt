public class AuraResponse 
{
    public AuraResponse() {
        success = false;
        message = '';
        model = null;
    }

    public boolean success { get; set; }
    public string message { get; set; }
    public object model { get; set; }
    public string url { get; set; }
}