public class CatalogController {
    @TestVisible
    private static List<ProductWrapper> products;
    
    @TestVisible
    private static List<ProductWrapper> getProducts() {
        if(products == null) {
            products = new List<ProductWrapper>();
            for(Product__c item : [SELECT Id, Name__c, Description__c, Amount__c, Cost__c, 
                    (SELECT Id FROM Attachments) FROM Product__c WHERE Amount__c > 0]) {
                products.add(new ProductWrapper(item)); 
            }
        }
        return products;    
    }

    @RemoteAction
    public static String getCatalog() {
        getProducts();
        return getJsonData(products);
    }

    public static String getJsonData(List<ProductWrapper> prod) {
        List<Map<String,Object>> catalog = new List<Map<String,Object>>();
        for(ProductWrapper pw : prod) {
            catalog.add(pw.toMap());
        }
        return system.JSON.serialize(catalog);
    }

}