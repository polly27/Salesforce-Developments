public class AutoTopTenProducts implements Schedulable {

    public void execute(SchedulableContext sc) {
       TopProductsBatch b = new TopProductsBatch();
    Database.executeBatch(b);
        sendTopToDistributor();
    }
    
    @testVisible
    private String getPostData() {
        Top_Ten_Products_List__c top = [select Id from Top_Ten_Products_List__c order by CreatedDate desc limit 1][0];
        Product__c[] lines = [select Name__c from Product__c where Id in (select Product__c from Top_Ten_Product__c 
                                      where Top_List__c = :top.Id)];
        String[] names = new List<String>();
        for(Product__c pr : lines) {
            names.add(pr.Name__c);
        }
        return system.JSON.serialize(names);
    }
    
    private void sendTopToDistributor() {
        String postData = getPostData();
        system.debug(postData);
        Heroku_Connection__mdt[] connections = [select Endpoint__c from Heroku_Connection__mdt];
        for(Heroku_Connection__mdt c : connections) {
            AutoTopTenProducts.callout(c.Endpoint__c, postData);
        }
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