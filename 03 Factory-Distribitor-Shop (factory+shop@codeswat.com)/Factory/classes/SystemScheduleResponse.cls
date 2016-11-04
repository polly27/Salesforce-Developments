public class SystemScheduleResponse implements Schedulable {

    private String postData;
    private String jobName;
    
    public SystemScheduleResponse(String jobName, String postData) {
        this.postData = postData;
        this.jobName = jobName;
    }
    
  public static void sendResponse(String postData) {
    Integer minute = Datetime.now().minute() + 1;
        String jobName = 'Send product response';
    String croneExpr = '0 ' + minute + ' * * * ? ';
    System.schedule(jobName, croneExpr, new SystemScheduleResponse(jobName, postData));
  }

    public void execute(SchedulableContext sc) {
        Heroku_Connection__mdt[] connections = [select Endpoint__c from Heroku_Connection__mdt];
        for(Heroku_Connection__mdt c : connections) {
            callout(c.Endpoint__c, postData);
        }
        Id jobId = [select Id from CronTrigger where CronJobDetail.Name = :jobName].Id;
        system.abortJob(jobId);
    }
    
    @future(callout = true)
    private static void callout(String url, String postData) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(postData);
        new Http().send(req);
    }
    
}