@isTest public class TestProductCreation {
    
    @isTest public static void testCreateNewProducts() {
      TestProductCreationUtil.testSetup();
        List<Product__c> prods = [select Name__c from Product__c limit 5];
        Set<String> names = new Set<String>();
        for(Product__c p : prods) {
            names.add(p.Name__c);
        }
      ProductCreation.createNewProducts(names);
      system.assertNotEquals([select COUNT() from Product__c], 0);
    }
}