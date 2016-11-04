@isTest
public class TestAutoShopping {

  @isTest static void testExecute() {
    for(Integer i = 0; i < 30; i++) {
        insert new Product__c(Name__c = 'test ' + i, Description__c = 'test descr ' + i, Amount__c = 5 * i, Cost__c = 10 * i);
        insert new Contact(LastName = 'test ' + i);
      }
    Integer salesOrderNum = [select COUNT() from Sales_Order__c];
    Integer salesOrderLineNum = [select COUNT() from Sales_Order_Line__c];
        
        AutoShopping shopping = new AutoShopping();
        shopping.execute(null);
        
        System.assertEquals(salesOrderNum + 1,  [select COUNT() from Sales_Order__c]);
        System.assertEquals(salesOrderLineNum + 3,  [select COUNT() from Sales_Order_Line__c]);
  }

    @isTest static void testSelectProducts() {
      for(Integer i = 0; i < 10; i++) {
        insert new Product__c(Name__c = 'test ' + i, Description__c = 'test descr ' + i, Amount__c = 5 * i, Cost__c = 10 * i);
      }
        AutoShopping shopping = new AutoShopping();
        Set<Product__c> products = shopping.selectProducts();
        System.assertEquals(products.size(), 3); // three purchases per shopping
    }

    @isTest static void testSelectContact() {
      for(Integer i = 0; i < 10; i++) {
        insert new Contact(LastName = 'test ' + i);
      }
        AutoShopping shopping = new AutoShopping();
        System.assertNotEquals(shopping.selectContact(), null);
    }

    @isTest static void testCreateSalesOrder() {
        AutoShopping shopping = new AutoShopping();
        Contact contact = new Contact(LastName = 'test');

        Sales_Order__c salesOrder = shopping.createSalesOrder(contact);
        
        System.assertNotEquals(salesOrder.Id, null);
        System.assertEquals(salesOrder.Client__c, contact.Id);
    }   

    @isTest static void testCreateSalesOrderLine() {
        AutoShopping shopping = new AutoShopping();
        Product__c product = new Product__c(Name__c = 'Test', Description__c = 'Description test', Cost__c = 50, Amount__c = 50);
        insert product;
        Integer originalAmount = Integer.valueOf(product.Amount__c);
        Sales_Order__c salesOrder = shopping.createSalesOrder(new Contact(LastName = 'test'));

        Sales_Order_Line__c salesOrderLine = shopping.createSalesOrderLine(product, salesOrder);
        product = [select Amount__c from Product__c where Id =: product.Id limit 1][0];

        System.assertNotEquals(salesOrderLine.Id, null);
        System.assertEquals(product.Amount__c, originalAmount - salesOrderLine.Amount__c);
    }   

}
