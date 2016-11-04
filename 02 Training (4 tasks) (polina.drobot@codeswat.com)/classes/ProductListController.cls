public class ProductListController {
    private static List<ProductWrapper> products;
    
    private static List<ProductWrapper> getProducts() {
        if(products == null) {
            products = new List<ProductWrapper>();
            for(Product__c item : [SELECT Id, Title__c, Description__c, Name__c, Amount__c, Cost__c, Image__c, Discount_Cost__c,
                 Discount_Result__c, (SELECT Id FROM Attachments) FROM Product__c 
                 WHERE Sale_Status__c = 'For sale' AND Amount__c > 0 LIMIT 100]) {
                products.add(new ProductWrapper(item)); 
            }
        }
        return products;    
    }

    @RemoteAction
    public static String getProducts(Id userId) {
        getProducts();
        return getDiscountJsonProducts(userId);
    }

    @RemoteAction
    public static String searchByName(Id userId, String name) {
        if(products == null) {
            products = new List<ProductWrapper>();
        }
        name = '%' + name + '%';
        for(Product__c item : [SELECT Id, Title__c, Description__c, Name__c, Amount__c, Cost__c, Image__c, Discount_Cost__c,
            Discount_Result__c, (SELECT Id FROM Attachments) FROM Product__c WHERE Sale_Status__c = 'For sale'
            AND Title__c LIKE :name LIMIT 100]) {
            products.add(new ProductWrapper(item)); 
        }
        return getDiscountJsonProducts(userId);
    }

    private static String getDiscountJsonProducts(STring userId) {
        products = DiscountUtil.applyUserDiscount(products, userId);
        List<Map<String,Object>> jsonList = new List<Map<String,Object>>();
        for(ProductWrapper pw : products) {
            jsonList.add(pw.toMap());
        }
        return system.JSON.serialize(jsonList);
    }

}