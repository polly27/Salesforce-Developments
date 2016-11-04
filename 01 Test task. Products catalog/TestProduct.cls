@isTest
public class TestProduct {

    static testMethod void testInStockTrigger() {
        Product__c product = new Product__c(Name = 'testProduct', Price__c = 100, Amount__c = 0, Type__c = 'type', Release_Date__c = Date.parse('09/11/2016'));
        insert product;
        Boolean inStock = [SELECT In_Stock__c FROM Product__c WHERE Id = :product.Id LIMIT 1].get(0).In_Stock__c;
        system.assert(!inStock);
    }
    
    static testMethod void testAddNewProduct() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        controller.getProducts();
        Integer nPrev = controller.products.size();
        controller.newProduct.Name = 'ytrewq';
        controller.newProduct.Price__c = 100;
        controller.newProduct.Amount__c = 1;
        controller.newProduct.Type__c = 'uyt';
        controller.newProduct.Release_Date__c = Date.parse('09/11/2016');
        controller.addNewProduct();
        System.assertEquals(controller.products.size(), nPrev + 1);
    }
    
    static void fillDataBaseWithProducts(Integer n) {
        for(Integer i = 0; i < n; i++) {
            insert new Product__c(Name = 'testProduct' + i, Price__c = i, Amount__c = i, Type__c = 'type', Release_Date__c = Date.parse('09/11/2016').addDays(-i));
        }
    }
    
    static testMethod void testGetProducts() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        controller.getProducts();
        Integer nPrev = controller.products.size();
        Integer n = 100;        
        fillDatabaseWithProducts(n);
        controller.products = null;
        controller.getProducts();
        System.assertEquals(nPrev + n, controller.products.size());
    }    

    static testMethod void testDeleteProducts() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 10, nToDelete = 5;
        fillDatabaseWithProducts(n);
        controller.getProducts();
        n = controller.products.size();
        for(Integer i = 0; i < nToDelete; i++) {
            controller.products.get(i).toDelete = true;
        }
        controller.deleteProducts();
        for(ProductController.ProductWrapper item : controller.products) {
            System.assert(!item.toDelete);
        }
        System.assertEquals(n - nToDelete, controller.products.size());
    }    
    
    static testMethod void testFilterByName() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 5;
        fillDatabaseWithProducts(n);
        controller.searchByName = 'Product0'; // 'testProduct' + i; i = [0, n - 1]
        controller.filter();
        for(ProductController.ProductWrapper item : controller.products) {
          system.assert(item.name.contains(controller.searchByName));            
        }
    }

    static testMethod void testFilterByNameEmptyResult() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 5;
        fillDatabaseWithProducts(n);
        controller.searchByName = 'kiuytfrdxc'; // 'testProduct' + i; i = [0, n - 1]
        controller.filter();
        system.assertEquals(controller.products.size(), 0);
    }
    
    static testMethod void testFilterByDate() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 5;
        fillDatabaseWithProducts(n);
        controller.searchByDate = Date.today();
        controller.filter();
        for(ProductController.ProductWrapper item : controller.products) {
          system.assert(item.dateAdded >= controller.searchByDate);
          system.assert(item.dateAdded < controller.searchByDate.addDays(1));
        }
    }
    
    static testMethod void testFilterByDateEmptyResult() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 5;
        fillDatabaseWithProducts(n);
        controller.searchByDate = Date.today().addDays(-1);
        controller.filter();
        system.assertEquals(controller.products.size(), 0);
    }
    
    static testMethod void testFilterByNameAndData() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 10;
        fillDatabaseWithProducts(n);
        controller.searchByName = 'testPro'; // 'testProduct' + i; i = [0, n - 1]
        controller.searchByDate = Date.today();
        controller.filter();
        for(ProductController.ProductWrapper item : controller.products) {
          system.assert(item.name.contains(controller.searchByName));
          system.assert(item.dateAdded >= controller.searchByDate);
          system.assert(item.dateAdded < controller.searchByDate.addDays(1));
        }
    }
 
    static testMethod void testShowAll() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 20;
        fillDatabaseWithProducts(n);
        controller.getProducts();
    controller.searchByName = 'Product1'; // 'testProduct' + i; i = [0, n - 1]
        controller.searchByDate = Date.today();
        controller.filter();
        System.assert(controller.products.size() < n);
        controller.showAll();
        System.assertEquals(controller.searchByName, '');
        System.assertEquals(controller.searchByDate, null);
        System.assertEquals(controller.products.size(), n);        
    }
    
    static testMethod void testGetStringFormat() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Date d = Date.newInstance(2016, 2, 9);
        String res = controller.getStringFormat(d);
        System.assertEquals(res, '2016-02-09T00:00:00Z');
    }

    static testMethod void testOrderProductsByName() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 20;
        for(Integer i = 0; i < n; i++) {
            insert new Product__c(Name = 'testProduct' + Math.abs(Math.mod(Crypto.getRandomInteger(), 100)), Price__c = i, Amount__c = i, Type__c = 'type', Release_Date__c = Date.parse('09/11/2016').addDays(-i));
        }        
        controller.getProducts();
        controller.orderByName();
        for(Integer i = 0; i < n - 1; i++) {
            system.assert(controller.products.get(i).name.compareTo(controller.products.get(i + 1).name) <= 0);
        }
        controller.orderByName();
        for(Integer i = 0; i < n - 1; i++) {
            system.assert(controller.products.get(i).name.compareTo(controller.products.get(i + 1).name) >= 0);
        }        
    }
     
    static testMethod void testOrderProductsByPrice() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 20;
        for(Integer i = 0; i < n; i++) {
            insert new Product__c(Name = 'testProduct' + i, Price__c = Math.abs(Math.mod(Crypto.getRandomInteger(), 1000)), Amount__c = i, Type__c = 'type', Release_Date__c = Date.parse('09/11/2016').addDays(-i));
        }        
        controller.getProducts();
        controller.orderByPrice();
        for(Integer i = 0; i < n - 1; i++) {
            system.assert(controller.products.get(i).price <= controller.products.get(i + 1).price);
        }
        controller.orderByPrice();
        for(Integer i = 0; i < n - 1; i++) {
            system.assert(controller.products.get(i).price >= controller.products.get(i + 1).price);
        }        
    }
    
    static testMethod void testOrderProductsByReleaseDate() {
        ProductController controller = new ProductController(new ApexPages.StandardController(new Product__c()));
        Integer n = 20;
        for(Integer i = 0; i < n; i++) {
            insert new Product__c(Name = 'testProduct' + i, Price__c = i, Amount__c = i, Type__c = 'type',
                                  Release_Date__c = Date.today().addDays(-Math.abs(Math.mod(Crypto.getRandomInteger(), 100))));
        }        
        controller.getProducts();
        controller.orderByReleaseDate();
        for(Integer i = 0; i < n - 1; i++) {
            system.assert(controller.products.get(i).releaseDate <= controller.products.get(i + 1).releaseDate);
        }
    controller.orderByReleaseDate();
        for(Integer i = 0; i < n - 1; i++) {
            system.assert(controller.products.get(i).releaseDate >= controller.products.get(i + 1).releaseDate);
        }        
    }
}