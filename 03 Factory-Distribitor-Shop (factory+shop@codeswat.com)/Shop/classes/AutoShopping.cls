public class AutoShopping implements Schedulable {

    public void execute(SchedulableContext sc) {
        Set<Product__c> products = selectProducts();
        Contact contact = selectContact();
        Sales_Order__c salesOrder = createSalesOrder(contact);
        for(Product__c product : products) {
            createSalesOrderLine(product, salesOrder);
        }
    }

    private Integer getRandom(Integer max) {
        return Math.floor(Math.random() * max).intValue();
    }

    @TestVisible
    private Set<Product__c> selectProducts() {
        Set<Product__c> products = new Set<Product__c>();
        Integer count = [select COUNT() from Product__c];
        if(count > 2000) count = getRandom(2000);
        for(Integer i = 0; i < 3; i++) {
            Integer num = getRandom(count);
            Product__c product = [select Id, Amount__c, Cost__c from Product__c limit 1 offset :num][0];
            if(products.contains(product)) {
                i--;
            } else {
                products.add(product);
            }
        }
        return products;
    }

    @TestVisible
    private Contact selectContact() {
        Integer count = [select COUNT() from Contact];
        if(count > 2000) count = getRandom(2000);
        Integer num = getRandom(count);
        return [select Id from Contact limit 1 offset :num];
    }

    @TestVisible
    private Sales_Order__c createSalesOrder(Contact contact) {
        Sales_Order__c salesOrder = new Sales_Order__c(Client__c = contact.Id);
        insert salesOrder;
        return salesOrder;
    }

    @TestVisible
    private Sales_Order_Line__c createSalesOrderLine(Product__c product, Sales_Order__c salesOrder) {
        Integer orderNumber = getRandom(product.Amount__c.intValue());
        Sales_Order_Line__c salesOrderLine = new Sales_Order_Line__c(Amount__c = orderNumber, 
                Cost_Per_Unit__c = product.Cost__c, Product__c = product.Id, Sales_Order__c = salesOrder.Id); 
        insert salesOrderLine;
        product.Amount__c -= orderNumber;
        update product;
        return salesOrderLine;
    }

}