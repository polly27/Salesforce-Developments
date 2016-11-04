@isTest public class TestRenewDatabase {
    
  @isTest public static void testFillMaterials() {
    delete [select Id from Material__c];
    List<Material__c> materials = new List<Material__c>();
    for(Integer i = 0; i < 10; i++) {
      materials.add(new Material__c(Name = 'test ' + i, Cost_Per_Unit__c = i, Amount__c = 10, Measure_Unit__c = 'test'));
    }
    insert materials;
    Map<Id,Double> amounts = new Map<Id,Double>();
    for(Material__c m : materials) {
      amounts.put(m.Id, m.Amount__c);
    }

    RenewDatabase.fillMaterials();
    
    materials = [select Amount__c from Material__c];
    for(Material__c m : materials) {
      system.assertEquals(amounts.get(m.Id) + 200, m.Amount__c);
    }
  }

  @isTest public static void testFillWorks() {
    delete [select Id from Work__c];
    List<Work__c> works = new List<Work__c>();
    for(Integer i = 0; i < 10; i++) {
      works.add(new Work__c(Name = 'work ' + i, Cost_Per_Hour__c = i, Amount_Of_Hours__c = 5));
    }
    insert works;
    Map<Id,Double> amounts = new Map<Id,Double>();
    for(Work__c w : works) {
      amounts.put(w.Id, w.Amount_Of_Hours__c);
    }

    RenewDatabase.fillWorks();
    
    works = [select Amount_Of_Hours__c from Work__c];
    for(Work__c w : works) {
      system.assertEquals(amounts.get(w.Id) + 10, w.Amount_Of_Hours__c);
    }
  }

  @isTest public static void testCleanProducts() {
    List<Product__c> products = new List<Product__c>();
    for(Integer i = 0; i < 10; i++) {
      products.add(new Product__c(Name__c = 'teeest', Description__c = 'description', Cost__c = 100, Amount__c = 5));
    }
    insert products;

    system.assertNotEquals([select COUNT() from Product__c], 0);
    RenewDatabase.cleanProducts();
    system.assertEquals([select COUNT() from Product__c], 0);
  }

}