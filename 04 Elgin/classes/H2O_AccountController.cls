global class H2O_AccountController {


    Id customerContactId;

    private transient List<OrderApi__Invoice__c> paidInvoices;
    private transient List<OrderApi__Invoice__c> outstandingInvoices;
    
    public MUSW__Parcel_Contact2__c[] customerLocations        { get; private set; }
    Set<Id> customerLocationIds;                             
    Set<Id> parcelIds;      
    Set<Id> parcelAccountIds;

    public Integer customerLocationCount                            { get; private set; }                    


    public PagesApi__Site__c getCurrentSite() {
        return PagesApi.Site.getSite();
    }

    public H2O_AccountController() {

        notPaidstatement = new List<Statement>();
        fullPaidStatement = new List<Statement>();

        customerLocationIds = new Set<Id>();
        parcelIds = new Set<Id>();
        parcelAccountIds = new Set<Id>();
        customerLocations = new List<MUSW__Parcel_Contact2__c>();
    	try {
            this.customerContactId = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0].ContactId;
            customerLocations = [SELECT Id, MUSW__Contact__c, MUSW__Parcel__c, MUSW__Parcel__r.Name, MUSW__Parcel__r.Location_ID__c, MUSW__Contact_Type__c, Parcel_Description__c FROM MUSW__Parcel_Contact2__c WHERE MUSW__Contact__c = :this.customerContactId ];
            customerLocationCount = customerLocations.size();
            for (MUSW__Parcel_Contact2__c pc : customerLocations) {
                parcelIds.add(pc.MUSW__Parcel__c);
                customerLocationIds.add(pc.Id);
            }
        } catch (Exception ex) {
    		Framework.Message.addMessage('Error loading the page, please try again.');
    	}
    }

    public Id getCustomerContactId() {
        return customerContactId;
    }
    
    public Set<Id> getParcelIds() {
        return parcelIds;
    }
    
    public String getCurrencyIsoCode() {
        return UserInfo.isMultiCurrencyOrganization() ? (String) getCurrentSite().get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
    }
    /**
     * Returns a list of outstanding (unpaid) invoice sobjects for the customer in
     * context.
     * @return List<OrderApi__Invoice__c>
     */
    public List<OrderApi__Invoice__c> getOutstandingInvoices() {
        if (outstandingInvoices == null && String.isNotEmpty(customerContactId)) {
            outstandingInvoices = new List<OrderApi__Invoice__c>();
            for (OrderApi__Invoice__c inv : H2O_FinancialDocumentSelector.getInvoices(customerContactId,parcelIds)) {
                if (!inv.OrderApi__Is_Paid__c && inv.OrderApi__Balance_Due__c > 0) {
                    outstandingInvoices.add(inv);
                }
            }
        }
        return outstandingInvoices;
    }

    public List<OrderApi__Invoice__c> getPaidInvoices() {
        if (paidInvoices == null && String.isNotEmpty(customerContactId)) {
            paidInvoices = new List<OrderApi__Invoice__c>();
            for (OrderApi__Invoice__c inv : H2O_FinancialDocumentSelector.getInvoices(customerContactId,parcelIds)) {
                if (inv.OrderApi__Balance_Due__c <= 0) {
                    paidInvoices.add(inv);
                }
            }
        }
        return paidInvoices;
    }

    public Decimal getBalanceTotal() {
        Decimal result = 0.00;
        for (OrderApi__Invoice__c inv : getOutstandingInvoices()) {
            result = result + inv.OrderApi__Balance_Due__c;
        }
        return result;
    }

    /**
     * Returns true if the outstanding invoice list size is greater than 0.
     * @return Boolean
     */
    public Boolean getHasOutstandingInvoices() {
        return getOutstandingInvoices().size() > 0;
    }

    /**
     * [setupInvoiceEpayment description]
     * @param  contactId [description]
     * @param  invoiceIdCSV      String of invoice record ids concatenated together with a '=' sign as a separator.
     * @return           [description]
     */
    @RemoteAction
    global static String setupInvoiceEpayment(String customerId, String invoiceIdCSV, String storeId) {
        PageReference checkoutPage = Page.OrderApi__checkout;
        if (String.isNotEmpty(invoiceIdCSV) &&
            String.isNotEmpty(customerId) &&
            String.isNotEmpty(storeId))
        {
            Id storeConfigID = Id.valueOf(storeId);
            OrderApi__Store__c store = [SELECT Id, OrderApi__Business_group__c,OrderApi__Gateway__c from OrderApi__Store__c WHERE Id = :storeConfigID];
            invoiceIdCSV = invoiceIdCSV.removeEnd(',');
            String[] parts = invoiceIdCSV.split(',');
            if (parts.size() > 0) {
                Set<Id> invoiceIds = new Set<Id>();
                for (String idString : parts) {
                    try {
                        invoiceIds.add(Id.valueOf(idString));
                    } catch (Exception ex) {
                        Framework.Message.addMessage(ex,Framework.Message.Severity.Danger);
                    }
                }
                if (invoiceIds.size() > 0) {
                    checkoutPage.getParameters().put('store',storeConfigId);
                    OrderApi__Epayment__c epay = new OrderApi__Epayment__c();
                    epay.OrderApi__Business_group__c = store.OrderApi__Business_group__c;
                    epay.OrderApi__Payment_Gateway__c = store.OrderApi__Gateway__c;
                    if (Id.valueOf(customerId).getSobjectType() == Contact.SobjectType) {
                        epay.OrderApi__Contact__c = customerId;
                        epay.OrderApi__Entity__c = 'Contact';
                    } else {
                        epay.OrderApi__Account__c = customerId;
                        epay.OrderApi__Entity__c = 'Account';
                    }
                    try {
                        insert epay;
                        checkoutPage.getParameters().put('epayment',epay.Id);
                        OrderApi__Invoice__c[] invoicesToPay =
                            (OrderApi__Invoice__c[]) new Framework.Selector(OrderApi__Invoice__c.SobjectType).selectById(invoiceIds);
                        OrderApi__Epayment_Line__c[] lines = new List<OrderApi__Epayment_Line__c>();
                        for (OrderApi__Invoice__c inv : invoicesToPay) {
                            OrderApi__Epayment_Line__c eline = new OrderApi__Epayment_Line__c();
                            eline.OrderApi__Sale_Price__c = inv.OrderApi__Balance_Due__c;
                            eline.OrderApi__Total__c = inv.OrderApi__Balance_Due__c;
                            eline.OrderApi__Quantity__c = 1;
                            eline.OrderApi__Price_Override__c = true;
                            eline.OrderApi__Epayment__c = epay.Id;
                            eline.OrderApi__Invoice__c = inv.Id;
                            eline.OrderApi__Business_group__c = store.OrderApi__Business_group__c;
                            lines.add(eline);
                        }
                        insert lines;
                    } catch (Exception ex) {
                        Framework.Message.addMessage(ex,Framework.Message.Severity.Danger);
                    }
                } else {
                    PageReference errorPage = Page.CPBase__generic_error;
                    errorPage.getParameters().put('message','We are experiencing a problem processing your request. Please check back later and try again.');
                    return errorPage.getUrl();
                }
            }
        }
        return checkoutPage.getUrl();
    }

	public PageReference redirectGuestUsers() {
		if (UserInfo.getUserType().equalsIgnoreCase('Guest'))
			return Page.H2O_Landing;
		return null;
	}

    public List<Statement__c> getOutstandingStatements() {
        List<Statement__c> resultStatements = new List<Statement__c>();
        for(Statement__c statement : H2O_FinancialDocumentSelector.getStatements(customerContactId,parcelIds)) {
            if(statement.Bills__r.size() > 0) {
                resultStatements.add(statement);
            }
        }
        return resultStatements;
    }

    List<Statement__c> paidResultStatements;
    public List<Statement__c> getPaidStatementsInvoice() {
        if (paidResultStatements == null && String.isNotEmpty(customerContactId)) {
            paidResultStatements = new List<Statement__c>();
            for(Statement__c statement : H2O_FinancialDocumentSelector.getStatements(customerContactId,parcelIds)) {
                Boolean add = true;
                for(OrderApi__Invoice__c bill : statement.Bills__r) {
                    if(bill.OrderApi__Balance_Due__c > 0) {
                        add = false;
                    }
                }
                if(add) {
                    paidResultStatements.add(statement);
                }
//                if(statement.Bills__r.size() > 0) {
//                    paidResultStatements.add(statement);
//                }
            }
        }
        return paidResultStatements;
    }

    public List<Statement> notPaidstatement { get; set; }
    public List<Statement> fullPaidStatement { get; set; }

    public Class Statement {

        public Boolean selected { get; set; }
        public Boolean fullPaid { get; set; }
        public Statement__c statementItem { get; set; }
        
        public Statement(Statement__c statementItem, Boolean selected, Boolean fullPaid) {
            this.statementItem =  statementItem;
            this.selected = selected;
            this.fullPaid = fullPaid;
        }
    }

    public Class Bill {

        public Boolean selected { get; set; }
        public Boolean fullPaid { get; set; }
        public Statement__c statementItem { get; set; }
        
        public Bill(Statement__c statementItem, Boolean selected, Boolean fullPaid) {
            this.statementItem =  statementItem;
            this.selected = selected;
            this.fullPaid = fullPaid;
        }
    }

}