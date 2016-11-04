public class OrderingController {
    
    @TestVisible
    private String[] orderIdList { get; set; }
    
    public ProductWrapper[] orderedProducts { get; set; }
    
    public Contact customer { get; set; }
    
    public OrderingController(ApexPages.StandardController controller) {
        orderIdList = ApexPages.currentPage().getParameters().get('order').split(',');
        getOrderedProducts();
        customer = (Contact)controller.getRecord();
    }

    @TestVisible
    private List<ProductWrapper> getOrderedProducts() {
        if(orderedProducts == null) {
            orderedProducts = new List<ProductWrapper>();
            for(Product__c item : [SELECT Id, Name__c, Description__c, Amount__c, Cost__c, 
                    (SELECT Id FROM Attachments) FROM Product__c WHERE Id IN :orderIdList AND Amount__c > 0 ]) {
                orderedProducts.add(new ProductWrapper(item)); 
            }
        }
        return orderedProducts;    
    }   
    
    public PageReference createOrder() {
        Contact contact = createUpdateContact();
        Sales_Order__c salesOrder = createSalesOrder(contact);
        for(ProductWrapper pw : orderedProducts) {
            createSalesOrderLine(pw, salesOrder);
        }
        return new PageReference('/apex/Success');
    }

  @TestVisible    
    private Contact createUpdateContact() {
        Contact[] contacts = [select Id from Contact where Email =: customer.Email];
        if(contacts.isEmpty()) {
            insert customer;
            return customer;
        } 
        Contact contactToUpdate = contacts[0];
        contactToUpdate.FirstName = customer.FirstName;
        contactToUpdate.LastName = customer.LastName;
        contactToUpdate.Phone = customer.Phone;
        update contactToUpdate;
        return contactToUpdate;
    }
    
    @TestVisible
    private Sales_Order__c createSalesOrder(Contact contact) {
        Sales_Order__c salesOrder = new Sales_Order__c(Client__c = contact.Id);
        insert salesOrder;
        return salesOrder;
    }
    
    @TestVisible
    private Sales_Order_Line__c createSalesOrderLine(ProductWrapper pw, Sales_Order__c salesOrder) {
        Sales_Order_Line__c salesOrderLine = new Sales_Order_Line__c(Amount__c = pw.orderNumber, 
                Cost_Per_Unit__c = pw.cost, Product__c = pw.id, Sales_Order__c = salesOrder.Id); 
        insert salesOrderLine;
        Product__c product = [select Id, Amount__c from Product__c where Id =: pw.Id limit 1][0];
        product.Amount__c -= pw.orderNumber;
        update product;
        return salesOrderLine;
    }
    
}