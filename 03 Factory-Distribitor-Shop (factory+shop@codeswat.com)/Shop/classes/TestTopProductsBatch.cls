@isTest
public class TestTopProductsBatch {

  static void testStart() {
    Integer prevNum = [select COUNT() from Top_Ten_Product__c];
        Contact contact = new Contact(LastName = 'Test');
        insert contact;
        Sales_Order__c salesOrder = new Sales_Order__c(Client__c = contact.Id);
        insert salesOrder;
        List<Product__c> products = new List<Product__c>();
    for(Integer i = 1; i <= 100; i++) {
      products.add(new Product__c(Name__c = 'test ' + i, Description__c = 'test descr ' + i, 
            Amount__c = 5 * i, Cost__c = 10 * i));
    }
    insert products;
    List<Sales_Order_Line__c> salesOrderLines = new List<Sales_Order_Line__c>();
    for(Integer i = 0; i < 100; i++) {
      salesOrderLines.add(new Sales_Order_Line__c(Amount__c = Math.floor(Math.random() * products[i].Amount__c).intValue(),
                                Cost_Per_Unit__c = products[i].Cost__c, Product__c = products[i].Id, Sales_Order__c = salesOrder.Id));
    }
    insert salesOrderLines;

    Test.startTest();
    TopProductsBatch tpb = new TopProductsBatch();
        Database.executeBatch(tpb);
        Test.stopTest();

    System.assertEquals([select COUNT() from Top_Ten_Product__c], prevNum + 10);
  }

  @isTest static void testGetNewTopListId() {
    TopProductsBatch tpb = new TopProductsBatch();
    System.assertNotEquals(tpb.getNewTopListId(), null);
  }

  private static Map<Id, Integer> getTotalSoldMap(Integer n) {
    Map<Id, Integer> totalSold = new Map<Id, Integer>();
    for(Integer i = 0; i < n; i++) {
      Product__c product = new Product__c(Name__c = 'test ' + i, Description__c = 'test descr ' + i, 
                        Amount__c = 5 * i, Cost__c = 10 * i);
      insert product;
      totalSold.put(product.Id, 2 * i);
    }
    return totalSold;
  }

  @isTest static void testGetTopTenProductsId() {
    TopProductsBatch tpb = new TopProductsBatch();
    tpb.totalSold = getTotalSoldMap(25);
    List<Id> topTenProductsId = tpb.getTopTenProductsId();
    Integer minTopValue = tpb.totalSold.get(topTenProductsId[0]);
    for(Id idItem : topTenProductsId) {
      if(tpb.totalSold.get(idItem) < minTopValue) {
        minTopValue = tpb.totalSold.get(idItem);
      }
      tpb.totalSold.remove(idItem);
    }

    System.assertEquals(topTenProductsId.size(), 10);
    for(Id idItem : tpb.totalSold.keySet()) {
      System.assert(tpb.totalSold.get(idItem) <= minTopValue);
    }
  }

  @isTest static void testCreateTopProduct() {
    Integer topTenProductNum = [select COUNT() from Top_Ten_Product__c];
    
    TopProductsBatch tpb = new TopProductsBatch();
    tpb.totalSold = getTotalSoldMap(5);
    tpb.createTopProduct((new List<Id>(tpb.totalSold.keySet())).get(0) , tpb.getNewTopListId());
    
    System.assertEquals(topTenProductNum + 1, [select COUNT() from Top_Ten_Product__c]);
  }

}