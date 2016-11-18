/*
* -----------------------------------------------------------------------------
* COPYRIGHT (C) 2015, FONTEVA, INC.
* ALL RIGHTS RESERVED.
*
* ALL INFORMATION CONTAINED HEREIN IS, AND REMAINS THE PROPERTY OF FONTEVA
* INCORPORATED AND ITS SUPPLIERS, IF ANY. THE INTELLECTUAL AND TECHNICAL
* CONCEPTS CONTAINED HEREIN ARE PROPRIETARY TO FONTEVA INCORPORATED AND
* ITS SUPPLIERS AND MAY BE COVERED BY U.S. AND FOREIGN PATENTS, PATENTS IN
* PROCESS, AND ARE PROTECTED BY TRADE SECRET OR COPYRIGHT LAW. DISSEMINATION
* OF THIS INFORMATION OR REPRODUCTION OF THIS MATERIAL IS STRICTLY FORBIDDEN
* UNLESS PRIOR WRITTEN PERMISSION IS OBTAINED FROM FONTEVA, INC.
* -----------------------------------------------------------------------------
*/

/**
 * Static methods to return financial related documents by customer.
 * @author Mac Anderson
 */
public with sharing class H2O_FinancialDocumentSelector {

    /**
     * Returns a list of OrderApi__Receipt__c sobjects related to the
     * customerId passed in as an attribute in the component. If the
     * customer Id is related to a Contact Sobject the system queries
     * for Account sobjects where the contact is the primary contact for
     * the account. If the contact is the primary contact the system will
     * include receipts linked to that account as well - including those
     * receipts where the contact is not linked directly.
     * to the receipt.
     * @param  customerId The salesforce record id of the account or contact in context.
     * @return List<OrderApi__Receipt__c>
     */
    public static List<OrderApi__Receipt__c> getReceipts(Id customerId) {
        List<OrderApi__Receipt__c> results = new List<OrderApi__Receipt__c>();
        if (customerId != null) {
            Set<Id> customerQueryIds = new Set<Id>();
            SobjectType customerSobjType = customerId.getSobjectType();
            Boolean isContact = customerSobjType == Contact.SobjectType;
            customerQueryIds.add(customerId);
            if (isContact) {
                Account[] accountList = [SELECT Id FROM Account WHERE OrderApi__Primary_Contact__c = : customerId];
                if (accountList.size() > 0) {
                    for (Account a : accountList) {
                        customerQueryIds.add(a.Id);
                    }
                }
            }
            results = [SELECT Id,
                        Name,
                        OrderApi__Date__c,
                        OrderApi__Type__c,
                        OrderApi__Memo__c,
                        OrderApi__Business_Group__r.Name,
                        OrderApi__Payment_Method__r.OrderApi__Description__c,
                        OrderApi__Payment_Method__r.Name,
                        OrderApi__Total__c,
                        OrderApi__Payment_Method_Description__c,
                        OrderApi__Entity__c,
                        OrderApi__Account__r.Name,
                        OrderApi__Contact__r.FirstName,
                        OrderApi__Contact__r.LastName
                        FROM OrderApi__Receipt__c
                        WHERE
                            OrderApi__Is_Posted__c = TRUE
                            AND (
                                    OrderApi__Contact__c IN :customerQueryIds
                                OR (
                                                OrderApi__Account__c IN :customerQueryIds
                                            AND
                                                OrderApi__Entity__c = 'Account'
                                    )
                                )
                        ORDER BY OrderApi__Date__c DESC];
        }
        return results;
    }

    public static List<OrderApi__Invoice__c> getInvoices(Id customerId) { return new List<OrderApi__Invoice__c>(); }

    /**
     * Returns a list of all OrderApi__Invoice__c sobjects related to the
     * customerId passed in as an attribute in the component. If the
     * customer Id is related to a Contact Sobject the system queries
     * for Account sobjects where the contact is the primary contact for
     * the account. If the contact is the primary contact the system will
     * include invoices linked to that account as well - including those
     * invoices where the contact is not linked directly.
     * to the invoice.
     * @param  Id Salesforce record id for the contact or account in context.
     * @return List<OrderApi__Invoice__c>
     */
    public static List<OrderApi__Invoice__c> getInvoices(Id customerId, Set<Id> parcelIds) {
        List<OrderApi__Invoice__c>  allInvoices = new List<OrderApi__Invoice__c>();
        if (customerId != null) {
            Set<Id> customerQueryIds = new Set<Id>();
            SobjectType customerSobjType = customerId.getSobjectType();
            Boolean isContact = customerSobjType == Contact.SobjectType;
            customerQueryIds.add(customerId);
            if (isContact) {
                Account[] accountList = [SELECT Id FROM Account WHERE OrderApi__Primary_Contact__c = : customerId];
                if (accountList.size() > 0) {
                    for (Account a : accountList) {
                        customerQueryIds.add(a.Id);
                    }
                }
            }
            allInvoices = [SELECT Id,
                        Name,
                        OrderApi__Invoice_Date__c,
                        OrderApi__Payment_Terms__r.Name,
                        OrderApi__Due_Date__c,
                        OrderApi__Has_Payments__c,
                        OrderApi__Payment_Count__c,
                        OrderApi__Has_Refunds__c,
                        OrderApi__Refund_Count__c,
                        OrderApi__Item_Count__c,
                        OrderApi__Business_Group__r.Name,
                        OrderApi__Total__c,
                        OrderApi__Balance_Due__c,
                        OrderApi__Status__c,
                        OrderApi__Is_Overdue__c,
                        OrderApi__Scheduled_Payment__c,
                        OrderApi__Scheduled_Payment__r.OrderApi__Scheduled_Date__c,
                        OrderApi__Scheduled_Payment__r.OrderApi__Payment_Method__r.OrderApi__Description__c,
                        OrderApi__Scheduled_Payment__r.OrderApi__Processed_Date__c,
                        OrderApi__Days_Overdue__c,
                        OrderApi__Paid_Date__c,
                        OrderApi__Is_Paid__c,
                        COE_Dunning_Category__c,
                        COE_Dunning_Category__r.Name,
                        COE_Water_Usage_Rate__c,
                        COE_Water_Units_Consumed_HCFT__c,
                        Sewer_Maintenance_Fee__c,
                        COE_Is_Residential__c,
                        COE_Invoice_Type__c

                        FROM
                            OrderApi__Invoice__c
                        WHERE
                            OrderApi__Is_Posted__c = true
                        AND
                            OrderApi__Is_Voided__c = false
                        AND
                            (
                                COE_Dunning_Category__c IN: parcelIds
                            OR
                                OrderApi__Contact__c IN :customerQueryIds
                            OR  (
                                    OrderApi__Account__c IN :customerQueryIds
                                AND
                                    OrderApi__Entity__c = 'Account'
                                )
                            )
                        ORDER BY
                                OrderApi__Due_Date__c ASC];
        }
        return allInvoices;
    }

    public static List<Statement__c> getStatements(Id customerId, Set<Id> parcelIds) {
        List<Statement__c>  allStatements = new List<Statement__c>();
        if (customerId != null) {
            Set<Id> customerQueryIds = new Set<Id>();
            SobjectType customerSobjType = customerId.getSobjectType();
            Boolean isContact = customerSobjType == Contact.SobjectType;
            customerQueryIds.add(customerId);
            if (isContact) {
                Account[] accountList = [SELECT Id FROM Account WHERE OrderApi__Primary_Contact__c = : customerId];
                if (accountList.size() > 0) {
                    for (Account a : accountList) {
                        customerQueryIds.add(a.Id);
                    }
                }
            }
            allStatements = [SELECT id, Total_Balance_Due__c, Location__c, Billing_End_Date__c, Bill_Total_Balance__c, Name,
                                        (SELECT Id,
                                                Name,
                                                Pay_Order__c,
                                                Bill_Category__c,
                                                OrderApi__Invoice_Date__c,
                                                OrderApi__Payment_Terms__r.Name,
                                                OrderApi__Due_Date__c,
                                                OrderApi__Has_Payments__c,
                                                OrderApi__Payment_Count__c,
                                                OrderApi__Has_Refunds__c,
                                                OrderApi__Refund_Count__c,
                                                OrderApi__Item_Count__c,
                                                OrderApi__Business_Group__r.Name,
                                                OrderApi__Total__c,
                                                OrderApi__Balance_Due__c,
                                                OrderApi__Status__c,
                                                OrderApi__Is_Overdue__c,
                                                OrderApi__Scheduled_Payment__c,
                                                OrderApi__Scheduled_Payment__r.OrderApi__Scheduled_Date__c,
                                                OrderApi__Scheduled_Payment__r.OrderApi__Payment_Method__r.OrderApi__Description__c,
                                                OrderApi__Scheduled_Payment__r.OrderApi__Processed_Date__c,
                                                OrderApi__Days_Overdue__c,
                                                OrderApi__Paid_Date__c,
                                                OrderApi__Is_Paid__c,
                                                COE_Dunning_Category__c,
                                                COE_Dunning_Category__r.Name,
                                                COE_Dunning_Category__r.Dunning_Category__c,
                                                COE_Water_Usage_Rate__c,
                                                COE_Water_Units_Consumed_HCFT__c,
                                                Sewer_Maintenance_Fee__c,
                                                COE_Is_Residential__c,
                                                COE_Invoice_Type__c
                                        FROM
                                            Bills__r
                                        WHERE
                                            OrderApi__Is_Posted__c = true
                                        AND
                                            OrderApi__Is_Voided__c = false
                                        AND
                                            (
                                                COE_Dunning_Category__c IN: parcelIds
                                            OR
                                                OrderApi__Contact__c IN :customerQueryIds
                                            OR  (
                                                    OrderApi__Account__c IN :customerQueryIds
                                                AND
                                                    OrderApi__Entity__c = 'Account'
                                                )
                                            )
                                        ORDER BY
                                            Pay_Order__c ASC,
                                            OrderApi__Balance_Due__c ASC
                                            )
                            FROM Statement__c 
                            WHERE ID IN (SELECT Statement__c 
                                        FROM OrderApi__Invoice__c 
                                        WHERE OrderApi__Is_Posted__c = true AND
                                            OrderApi__Is_Voided__c = false AND
                                            (COE_Dunning_Category__c IN: parcelIds OR
                                                OrderApi__Contact__c IN :customerQueryIds OR  
                                                (
                                                    OrderApi__Account__c IN :customerQueryIds AND
                                                    OrderApi__Entity__c = 'Account'
                                                )
                                            )
                                        )
                            LIMIT 2000];
        }

        return allStatements;
    }
}