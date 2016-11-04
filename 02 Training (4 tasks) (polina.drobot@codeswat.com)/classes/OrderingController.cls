public with sharing class OrderingController{
  
    public OrderingController(SingleProductController controller) {}
    
    @RemoteAction   
    public static String placeOrder(String name, String email, String address, String phone, 
                                    String discount, String productId, String userDiscount, String userDiscountResult) {
        if (discount != null && discount != '' && discountNotExist(discount)) {
            return 'discount';
        }
        Contacts__c contact = renewContact(name, email.trim(), address, phone);
        Product__c prod = decrementProductAmount(productId);
        String newProdId = createSoldProduct(prod, contact, discount, userDiscount, userDiscountResult);
        return newProdId;
    }
    
    private static boolean discountNotExist(String discount) {
        return [SELECT Id FROM Discount__c WHERE Discount_Code__c = :discount LIMIT 1].isEmpty();
    }
    
    private static Contacts__c renewContact(String name, String email, String address, String phone) {
        Contacts__c[] contacts = [SELECT Name, Email__c, Address__c, Phone__c FROM Contacts__c WHERE Email__c = :email LIMIT 1];
        if (contacts.isEmpty()) {
            contacts = new Contacts__c[]{new Contacts__c(Name = name, Email__c = email, Phone__c = phone, Address__c = address)};
            insert contacts[0];
        } else {
          contacts[0].Name = name;
            contacts[0].Phone__c = phone;
            contacts[0].Address__c = address;
            update contacts[0];
        }
        return contacts[0];
    }
    
    private static Product__c decrementProductAmount(String productId) {
        Product__c pr = [SELECT Id, Title__c, Description__c, Name__c, Amount__c, Contacts__c, Cost__c, Discount_Cost__c,
                        (SELECT Id, Name FROM Attachments), Store__c, Date_of_Receipt__c, Name 
                        FROM Product__c where Id = :productId LIMIT 1][0];
        pr.Amount__c--;
        update pr;
        return pr;
    } 
    
    private static String createSoldProduct(Product__c original, Contacts__c contact, String discountCode, 
                                            String userDiscount, String userDiscountResult) {
        Product__c newProd = original.clone(false);
        newProd.Date_of_Purchase__c = Date.today();
        newProd.Number_of_Purchase__c = 1;
        newProd.RecordTypeId = [Select Id From RecordType where Name ='Sold' and SobjectType ='Product__c' limit 1][0].Id;
        newProd.Contacts__c = contact.Id;
        newProd.Image__c = original.Attachments[0].Id;
        newProd.Sale_Status__c = 'Sold';
        if(discountCode != null && discountCode != '') {
            newProd.Discount_Cost__c = DiscountUtil.getDiscountCostByCode(newProd.Cost__c, discountCode);
            newProd.Discount_Result__c = DiscountUtil.discountResult; 
        } else if (userDiscount != null && userDiscount != ''){
            newProd.Discount_Cost__c = Decimal.valueOf(userDiscount);
            newProd.Discount_Result__c = userDiscountResult;
        }
        insert newProd;
        return newProd.Id;
    }
    
}