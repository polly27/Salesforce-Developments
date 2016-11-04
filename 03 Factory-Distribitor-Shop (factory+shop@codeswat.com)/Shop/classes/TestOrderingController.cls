@isTest
private class TestOrderingController {
    
    private static Map<String, Object> getOrderingControllerInstance(Integer n) {
        Integer prevN = [select COUNT() from Product__c];
        for(Integer i = 1; i <= n; i++) {
            insert new Product__c(Name__c = 'testProduct' + i, Cost__c = i, Amount__c = 5 * i, Description__c = 'test description ' + i);
        }
        String idList = '';
        List<Product__c> products = [select Id from Product__c];
        for(Product__c p : products) {
            idList += p.Id + ',';
        }
        idList = idList.substring(0, idList.length() - 1);
        
        Test.setCurrentPageReference(new PageReference('apex/Ordering'));
    System.currentPageReference().getParameters().put('order', idList);
  
        OrderingController ordering = new OrderingController(new ApexPages.StandardController(new Contact()));
        
        Map<String, Object> m = new Map<String, Object>();
        m.put('orderingController', ordering);
        m.put('idList', idList);
        m.put('N', prevN + n);
        
        return m;
    }
    
    @isTest static void testOrderingController() {
        Map<String, Object> m = getOrderingControllerInstance(10);
        OrderingController ordering = (OrderingController)m.get('orderingController');
    String[] idList = ((String)m.get('idList')).split(',');
    Integer n = (Integer)m.get('N');
        
        System.assertEquals(ordering.orderIdList, idList);
        System.assertEquals(ordering.orderedProducts.size(), n);
    }    
    
    @isTest static void testGetOrderedProducts() {
         Map<String, Object> m = getOrderingControllerInstance(10);
        OrderingController ordering = (OrderingController)m.get('orderingController');
    String[] idList = ((String)m.get('idList')).split(',');
    Integer n = (Integer)m.get('N');
        
        Set<String> idSet = new Set<String>(ordering.orderIdList);
         
        System.assertEquals(idSet.size(), n);
        for(String i : idList) {
          System.assert(idSet.contains(i));    
        }
    }    
    
    @isTest static void testCreateUpdateContact() {
        Map<String, Object> m = getOrderingControllerInstance(10);
        OrderingController ordering = (OrderingController)m.get('orderingController');
        String firstName = 'Test FirstName';
        String lastName = 'Test LastName';
        String phone = '00000000000';
        
        ordering.customer.FirstName = firstName;
        ordering.customer.LastName = lastName;
        ordering.customer.Email = 'test@test.com';
        ordering.customer.Phone = phone;
        while([select COUNT() from Contact where Email =: ordering.customer.Email] > 0) {
            ordering.customer.Email += 'm';
        }
        
        Contact createdContact = ordering.createUpdateContact();
        System.assert(createdContact.Id != null);
        System.assertEquals(createdContact.FirstName, ordering.customer.FirstName);
        System.assertEquals(createdContact.LastName, ordering.customer.LastName);
        System.assertEquals(createdContact.Email, ordering.customer.Email);
        System.assertEquals(createdContact.Phone, ordering.customer.Phone);
        
        ordering.customer.FirstName = 'Test Test FirstName';
        ordering.customer.LastName = 'Test Test LastName';
        ordering.customer.Phone = '111111111111';
        
        Contact updatedContact = ordering.createUpdateContact();
        System.assertEquals(updatedContact.Id, createdContact.Id);
        System.assertNotEquals(updatedContact.FirstName, firstName);
        System.assertNotEquals(updatedContact.LastName, lastName);
        System.assertNotEquals(updatedContact.Phone, phone);
    }
 
    @isTest static void testCreateSalesOrder() {
        Map<String, Object> m = getOrderingControllerInstance(10);
        OrderingController ordering = (OrderingController)m.get('orderingController');
        Contact contact = new Contact();

        Sales_Order__c salesOrder = ordering.createSalesOrder(contact);
        
        System.assertNotEquals(salesOrder.Id, null);
        System.assertEquals(salesOrder.Client__c, contact.Id);
    }   

    @isTest static void testCreateSalesOrderLine() {
        Map<String, Object> m = getOrderingControllerInstance(10);
        OrderingController ordering = (OrderingController)m.get('orderingController');
        String idProduct = ((String)m.get('idList')).split(',')[0];
        Product__c product = [select Id, Cost__c, Amount__c from Product__c where Id =: idProduct limit 1][0];
        Integer originalAmount = Integer.valueOf(product.Amount__c);
        ProductWrapper pw = new ProductWrapper(product);
        Sales_Order__c salesOrder = ordering.createSalesOrder(new Contact());

        Sales_Order_Line__c salesOrderLine = ordering.createSalesOrderLine(pw, salesOrder);
        product = [select Amount__c from Product__c where Id =: idProduct limit 1][0];

        System.assertNotEquals(salesOrderLine.Id, null);
        System.assertEquals(product.Amount__c, originalAmount - salesOrderLine.Amount__c);
    }   

    @isTest static void testCreateOrder() {
        Map<String, Object> m = getOrderingControllerInstance(10);
        OrderingController ordering = (OrderingController)m.get('orderingController');
        ordering.customer.FirstName = 'test firstName';
        ordering.customer.LastName = 'test lastName';
        ordering.customer.Email = 'test@test.com';
        ordering.customer.Phone = '00000000';
        PageReference pr = ordering.createOrder();
        System.assertEquals('/apex/Success', pr.getUrl());        
    }

}
