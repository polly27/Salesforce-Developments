@isTest
private class TestAutoTopTenProducts {
  
    @testSetup static void setup() {
        List<Product__c> products = new List<Product__c>();
    for(Integer i = 1; i <= 100; i++) {
      products.add(new Product__c(Name__c = 'test ' + i, Description__c = 'test descr ' + i, 
            Amount__c = 5 * i, Cost__c = 10 * i));
    }
    insert products;

        Top_Ten_Products_List__c topTenProdList = new Top_Ten_Products_List__c();
        insert topTenProdList;

        Top_Ten_Product__c[] topTenProd = new List<Top_Ten_Product__c>();
        for(Integer i = 0; i < 10; i++) {
            topTenProd.add(new Top_Ten_Product__c(Amount__c = i, Product__c = products[i].Id, Top_List__c = topTenProdList.Id));
        }
        insert topTenProd;
    
    }
    

     @isTest static void testGetPostData() {    
        AutoTopTenProducts attp = new AutoTopTenProducts();
    String postData = attp.getPostData();
    List<String> namesList = (List<String>) system.JSON.deserialize(postData, List<String>.class);
        
        Top_Ten_Products_List__c top = [select Id from Top_Ten_Products_List__c order by CreatedDate desc limit 1][0];
        Top_Ten_Product__c[] lines = [select Product__c from Top_Ten_Product__c where Top_List__c = :top.Id];
        List<Id> ids = new List<Id>();
        for(Top_Ten_Product__c line : lines) {
            ids.add(line.Product__c);
        }
        List<Product__c> products = [select Name__c from Product__c where Id in :ids];
        Set<String> names = new Set<String>();
        for(Product__c p : products) {
            names.add(p.Name__c);
        }
        
        system.assert(names.containsAll(namesList));
    }

}
