public class ProductWrapper {
    private Product__c product;

    public ProductWrapper() {
        this.product = new Product__c();
        this.selected = false;
        this.orderNumber = 1;
    }
        
    public ProductWrapper(Product__c item) {
        this.product = item;
        this.selected = false;
        this.orderNumber = 1;
    }
        
    public Id id {
        get {return product.Id; }
    }

    public String name {
        get {return product.Name__c; }
        set {product.Name__c = value; }
    }
        
    public String description {
        get {return product.Description__c; }
        set {product.Description__c = value; }
    }
        
        
    public Double amount {
        get {return product.Amount__c; }
        set {product.Amount__c = value; }
    }

    public Double cost {
        get {return product.Cost__c; }
        set {product.Cost__c = value; }
    }

    public String image {
        get {
            return product.Attachments.isEmpty() ? '' : product.Attachments[0].Id;
        }
    }
    
    public Boolean selected { get; set; }
    
    public Integer orderNumber { get; set; }
    
    public Map<String,Object> toMap() {
        Map<String, Object> m = new Map<String, Object>();
        m.put('id', id);
        m.put('name', name);
        m.put('description', description);
        m.put('amount', amount);
        m.put('cost', cost);
        m.put('image', image);
        m.put('selected', selected);
        m.put('orderNumber', orderNumber);
        return m;
    }        
}