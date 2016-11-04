@isTest public class TestEmail {
    
  @isTest public static void testSendProductCreationReport() {
    Product__c[] products = new List<Product__c>();
    for(Integer i = 0; i < 10; i++) {
      products.add(new Product__c(Name__c = 'test ' + i, Description__c = 'description ' + i, Cost__c = 5 * i, Amount__c = i));
    } 
    insert products;
    Integer success = Email.sendProductCreationReport(products);
    System.assertEquals(0, success);
  }

  @isTest public static void testGetSysAdminAdresses() {
    List<String> addresses = Email.getSysAdminAdresses();
    for(String email : addresses) {
      Id profileId = [select ProfileId from User where Email = :email limit 1][0].ProfileId;
      System.assertEquals([select Name from Profile where Id = :profileId].Name, 'System Administrator');
    }
  }

  @isTest public static void testGenerateHtmlBody() {
    Product__c[] products = new List<Product__c>();
    for(Integer i = 0; i < 10; i++) {
      products.add(new Product__c(Name__c = 'testing ' + i, Description__c = 'description ' + i, Cost__c = 5 * i, Amount__c = i));
    } 
    insert products;
    Email.generateHtmlBody(products);
  }

}