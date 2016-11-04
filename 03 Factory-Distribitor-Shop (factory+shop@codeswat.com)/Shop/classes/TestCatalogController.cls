@isTest
private class TestCatalogController {

    static void fillDataBaseWithProducts(Integer n) {
        List<Product__c> products = new List<Product__c>();
        for(Integer i = 1; i <= n; i++) {
            products.add(new Product__c(Name__c = 'testProduct' + i, Cost__c = i,
                         Amount__c = 5 * i, Description__c = 'test description ' + i));
        }
        insert products;
    }
    
    @isTest static void testGetProducts() {
        Integer nPrev = [select COUNT() from Product__c];
        Integer n = 50;        
        fillDatabaseWithProducts(n);

        CatalogController.products = null;
        CatalogController.getProducts();
        
        System.assertEquals(nPrev + n, CatalogController.products.size());
    }    

    @isTest static void testGetCatalog() {
        Integer nPrev = [select COUNT() from Product__c where Amount__c > 0];
        Integer n = 50;        
        fillDatabaseWithProducts(n);

        String json = CatalogController.getCatalog();
        List<Map<String,String>> catalog = (List<Map<String,String>>)
                System.JSON.deserialize(json, Type.forName('List<Map<String,String>>'));

        System.assertEquals(catalog.size(), nPrev + n); 
    }
    
    @isTest static void testGetJsonData() {
        fillDataBaseWithProducts(5);
        List<ProductWrapper> products = new List<ProductWrapper>();
        Set<Id> idList = new Set<Id>();
        for(Product__c product : [select Id, Name__c, Cost__c, Amount__c, Description__c from Product__c]) {
            products.add(new ProductWrapper(product));
            idList.add(product.Id);
        }

        String json = CatalogController.getJsonData(products);

        List<Map<String,String>> catalog = (List<Map<String,String>>)
                System.JSON.deserialize(json, Type.forName('List<Map<String,String>>'));

        System.assertNotEquals(catalog.size(), 0); 
        for(Map<String, Object> m : catalog) {
            System.assert(idList.contains((Id)m.get('id')));
        }
    }
 
}