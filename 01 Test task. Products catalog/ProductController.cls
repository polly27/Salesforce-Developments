public class ProductController {
    public ApexPages.StandardController controller;
    
    public List<ProductWrapper> products;
  
    public Product__c newProduct {get; set;}

    public String orderBy {get; set;}

    private Boolean ascendingOrder {get; set;}
    
    public String searchByName {get; set;}
    
    public Date searchByDate {get; set;}

    public ProductController(ApexPages.StandardController Controller) {
        this.newProduct = (Product__c)Controller.getRecord(); 
        this.controller = Controller;  
        this.orderBy = 'dateAdded';
        this.ascendingOrder = true;
        this.searchByName = '';
    } 
          
    public List<ProductWrapper> getProducts() {
        if(products == null) {
            products = new List<ProductWrapper>();
            for(Product__c item : [SELECT Id, Name, Price__c, Amount__c, Type__c, CreatedDate, Release_Date__c, In_Stock__c FROM Product__c]) {
                products.add(new ProductWrapper(item, this));
            }
            products.sort();
        }
        return products;    
    }

    public void orderByName() {
        orderProducts('name');
    }

    public void orderByPrice() {
        orderProducts('price');
    }

    public void orderByDateAdded() {
        orderProducts('dateAdded');
    }

    public void orderByReleaseDate() {
        orderProducts('releaseDate');
    }

    public void orderProducts(String field) {
        if (orderBy.equals(field)) {
            ascendingOrder = !ascendingOrder;
            products = reverse(products);
        } else {
          orderBy = field;    
          products.sort();
        }
    }

    private List<ProductWrapper> reverse(List<ProductWrapper> a) {
        List<ProductWrapper> b = new List<ProductWrapper>();
        for(Integer i = a.size() - 1; i > -1; i--) {
          b.add(a.get(i));
        }
        return b;
    }
    
    public PageReference deleteProducts() {
        for(Integer i = 0; i < products.size(); i++) {
            if(products.get(i).toDelete) {
                delete [SELECT Id FROM Product__c WHERE Id = :products.get(i).id];
                products.remove(i--);
            }
        }
        return null;
    }
    
    public PageReference addNewProduct() {
        try {
          insert newProduct;    
            ProductWrapper pw = new ProductWrapper([SELECT Id, Name, Price__c, Amount__c, Type__c, CreatedDate, Release_Date__c,
                                                    In_Stock__c FROM Product__c WHERE Id = :newProduct.Id LIMIT 1], this);        
            if(searchByName != '' || searchByDate != null) {
                showAll();
            } else {
                products.add(pw);        
              products.sort();
            }
            newProduct = new Product__c();     
        } catch (DmlException e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    @TestVisible
    private String getStringFormat(Date d) {
        if(d == null) {
            return null;
        }
        String day = String.valueOf(d.day());
        if(d.day() < 10) {
            day = '0' + day;
        }
        String month = String.valueOf(d.month());
        if(d.month() < 10) {
            month = '0' + month;
        }
        return d.year() + '-' + month + '-' + day + 'T00:00:00Z';
    }
    
    public PageReference filter() {
        if(!searchByName.equals('') || searchByDate != null) {
          String query = 'SELECT Id, Name, Price__c, Amount__c, Type__c, CreatedDate, Release_Date__c, In_Stock__c FROM Product__c WHERE ';
            if(!searchByName.equals('')) {
              String name = '%' + searchByName + '%';
                query += 'Name LIKE \'' + name + '\'';
            }
            if(searchByDate != null) {
                if(!searchByName.equals('')) {
                    query += ' AND ';
                }
                String fromDate = getStringFormat(searchByDate);
            String toDate = getStringFormat(searchByDate.addDays(1));
            query += 'CreatedDate >= ' + fromDate + ' AND CreatedDate < ' + toDate;
            }
            products = new List<ProductWrapper>();
            for(Product__c item : Database.query(query)) {
                products.add(new ProductWrapper(item, this));
            }
            products.sort();
        }
        return null;
    }
    
    public PageReference showAll() {
        searchByName = '';
        searchByDate = null;
        products = null;
        getProducts();
        return null;
    }

    public class ProductWrapper implements Comparable {
        private Product__c product;

        public Boolean test { get; set; }

        private ProductController controller;
                
        public ProductWrapper(ProductController controller) {
            this.product = new Product__c();
            this.controller = controller;
            this.toDelete = false;
            this.test = false;
        }
        
        public ProductWrapper(Product__c item, ProductController controller) {
            this.product = item;
            this.controller = controller;
            this.toDelete = false;
            this.test = false;
        }
        
        public String id {
            get {return product.Id; }
        }
        
        public String name {
            get {return product.Name; }
            set {product.Name = name; }
        }
        
        public Decimal price {
            get {return product.Price__c; }
            set {product.Price__c = price; }
        }
        
        public Double amount {
            get {return product.Amount__c; }
            set {product.Amount__c = amount; }
        }

        public String productType {
            get {return product.Type__c; }
            set {product.Type__c = productType; }
        }
        
        public Datetime dateAdded {
            get {return product.CreatedDate; }
        }
        
        public Date releaseDate {
            get {return product.Release_Date__c; }
            set {product.Release_Date__c = releaseDate; }
        }
        
        public Boolean inStock {
            get {return product.In_Stock__c; }          
            set {product.In_Stock__c = inStock; }
        }
        
        public Boolean toDelete { get; set; }
        
        private Integer compareDecimal(Decimal a, Decimal b) {
                Decimal difference = a - b;
            if (difference > 0) {
                return 1;
            } 
            if (difference < 0) {
                return -1;
            } 
            return 0;
        }
        
        private Integer compareDate(Date a, Date b) {
                        Integer returnVal = a.year() - b.year();                    
            if (returnVal == 0) {
                returnVal = a.month() - b.month();                    
                if (returnVal == 0) {
                    returnVal = a.day() - b.day();                    
                }
            }
            return returnVal;
        }

        private Integer compareDateTime(DateTime a, DateTime b) {            
            Integer returnVal = a.year() - b.year();                    
            if (returnVal == 0) {
                returnVal = a.month() - b.month();                    
                if (returnVal == 0) {
                    returnVal = a.day() - b.day();                    
                    if (returnVal == 0) {
                        returnVal = a.hour() - b.hour();                    
                        if (returnVal == 0) {
                            returnVal = a.minute() - b.minute();                    
                        }
                    }
                }
            }
            return returnVal;
        }

        public Integer compareTo(Object compareTo) {
            ProductWrapper pw = (ProductWrapper) compareTo;
            Integer returnVal;    
            if (controller.orderBy.equals('name')) {
                returnVal = this.name.toLowerCase().compareTo(pw.name.toLowerCase());
            } else if (controller.orderBy.equals('price')) {
                returnVal = compareDecimal(this.price, pw.price);
            } else if (controller.orderBy.equals('dateAdded')) {
              returnVal = compareDateTime(this.dateAdded, pw.dateAdded);
            } else if (controller.orderBy.equals('releaseDate')) {
                returnVal = compareDate(this.releaseDate, pw.releaseDate);            
            }
            if (!controller.ascendingOrder) {
                returnVal = -returnVal;
            }
            return returnVal;
        }        
    }
}