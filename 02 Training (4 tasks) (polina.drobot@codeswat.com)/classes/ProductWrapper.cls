public class ProductWrapper {
        private Product__c product;

        public ProductWrapper() {
            this.product = new Product__c();
        }
        
        public ProductWrapper(Product__c item) {
            this.product = item;
        }
        
        public Id id {
            get {return product.Id; }
        }
        
        public String title {
            get {return product.Title__c; }
            set {
                product.Title__c = value;
            }
        }
        
        public String description {
            get {return product.Description__c; }
            set {product.Description__c = value; }
        }
        
        public String name {
            get {return product.Name__c; }
            set {product.Name__c = value; }
        }
        
        public Double amount {
            get {return product.Amount__c; }
            set {product.Amount__c = value; }
        }

        public Double cost {
            get {return product.Cost__c; }
            set {product.Cost__c = value; }
        }

        public Double discountCost {
            get {return product.Discount_Cost__c; }
            set {product.Discount_Cost__c = value; }
        }

        public String discountResult {
            get {return product.Discount_Result__c; }
            set {product.Discount_Result__c = value; }
        }
        
        public String image {
            get {
                if(!product.Attachments.isEmpty()) {
                  return product.Attachments[0].Id; 
                } else if(product.Image__c != '') {
                  return product.Image__c;
                }
                return '';
            }
        }
        
    public Map<String,Object> toMap() {
            Map<String, Object> m = new Map<String, Object>();
            m.put('id', id);
            m.put('title', title);
            m.put('description', description);
            m.put('cost', cost);
            m.put('discountCost', discountCost);
            m.put('discountResult', discountResult);
            m.put('amount', amount);
            m.put('image', image);
            return m;
        }        
}