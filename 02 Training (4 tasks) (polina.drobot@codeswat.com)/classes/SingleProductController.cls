public class SingleProductController {
  private static ProductWrapper product;
 
    public static void loadProduct(Id recordId) {
        Product__c pr = [SELECT Id, Title__c, Description__c, Name__c, Amount__c, Cost__c, Image__c,
                Discount_Cost__c, Discount_Result__c, (SELECT Id FROM Attachments) FROM Product__c where Id = :recordId]; 
        product = new ProductWrapper(pr);
    } 
    
   @RemoteAction   
    public static String getJsonProduct(Id prodId, Id userId) {
        loadProduct(prodId);
        product.discountCost = DiscountUtil.getDiscountCostByUser(product.cost, userId);
        product.discountResult = DiscountUtil.discountResult;
        return system.JSON.serialize(product.toMap());
    }
}