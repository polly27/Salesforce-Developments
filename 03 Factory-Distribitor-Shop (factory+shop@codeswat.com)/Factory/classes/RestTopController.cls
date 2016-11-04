@RestResource(urlMapping='/top')
global with sharing class RestTopController {
   
    @HttpPost
    global static String postTop(String top) {
        Set<String> topProductsNames = (Set<String>)system.JSON.deserialize(top, Set<String>.class);
        system.debug(topProductsNames);
    createProductsAndSendResponse(topProductsNames);
        return 'top accepted';
    }
    
    @future(callout = true)
    private static void createProductsAndSendResponse(Set<String> topProductsNames) {
        List<Product__c> products = ProductCreation.createNewProducts(topProductsNames);
        String postData = system.JSON.serialize(products);
        SystemScheduleResponse.sendResponse(postData);    
    }
    
}