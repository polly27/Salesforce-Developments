@isTest
public class TestProductWrapper {

    @isTest static void testToMap() {
        Product__c p = new Product__c(Name__c = 'n a m e', Description__c = 'd e s c r i p t i o n', Amount__c = 49, Cost__c = 80);
        insert p;
        ProductWrapper pw = new ProductWrapper(p);
        Map<String,Object> m = pw.toMap();
        System.assertEquals(p.Id, m.get('id'));
        System.assertEquals(p.Name__c, m.get('name'));
        System.assertEquals(p.Description__c, m.get('description'));
        System.assertEquals(p.Amount__c, m.get('amount'));
        System.assertEquals(p.Cost__c, m.get('cost'));
        System.assertEquals(false, m.get('selected'));
        System.assertEquals(1, m.get('orderNumber'));        
    }
    
}