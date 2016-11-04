public class DiscountUtil {
  
  public static String discountResult {get; set;}

    public static Decimal getDiscountCostByCode(Decimal cost, String discountCode) {
        discountResult = null;
        Discount__c d = getDiscountByCode(discountCode);
        return countBestCost(cost, d.Percentes__c, d.Static_Discount__c);
    } 

    public static Decimal getDiscountCostByUser(Decimal cost, String userId) {
        discountResult = null;
        Discount__c[] discounts = getDiscountsByUser(userId);
        if(discounts != null && !discounts.isEmpty()) {
            Decimal bestCost = cost;
            String bestDiscountResult;
            for(Discount__c d : discounts) {
                Decimal tmp = countBestCost(cost, d.Percentes__c, d.Static_Discount__c);
                if(bestCost > tmp) {
                    bestCost = tmp;
                    bestDiscountResult = discountResult;
                }
            }
            discountResult = bestDiscountResult;
            return bestCost;
        }
        return null;
    } 

    public static ProductWrapper[] applyUserDiscount(ProductWrapper[] products, String userId) {
        Discount__c[] discounts = getDiscountsByUser(userId);
        if(discounts != null && !discounts.isEmpty()) {
            for(ProductWrapper p : products) {
                Decimal bestCost = p.cost;
                for(Discount__c d : discounts) {
                    bestCost = Math.min(bestCost, countBestCost(p.cost, d.Percentes__c, d.Static_Discount__c));
                }
                p.discountCost = bestCost;                
            }
        }
        return products;
    } 

    private static Decimal countBestCost(Decimal originalCost, Decimal percentDiscount, Decimal staticDiscount) {
        Decimal percentResult = originalCost, staticResult = originalCost;
        percentDiscount /= 100;
        if(percentDiscount != null && percentDiscount != 0) {
            percentResult = originalCost * (1 - percentDiscount);
        } if(percentDiscount != null && percentDiscount != 0) {
            staticResult = originalCost - percentDiscount;
            if(staticResult < 0) staticResult = 0;
        }
    if(percentResult <= staticResult) {
            discountResult = String.valueOf(percentDiscount * 100) + '%';
            return percentResult;
        }
        discountResult = '$' + staticDiscount;
        return staticResult;
    }

    private static Discount__c getDiscountByCode(String discountCode) {
    return [SELECT Id, Percentes__c, Static_Discount__c FROM Discount__c WHERE Discount_Code__c = :discountCode LIMIT 1][0];
    }

    private static Discount__c[] getDiscountsByUser(Id userId) {
        Id contactId = [select contactid from User where Id =: userId limit 1][0].contactId;
        Contact[] contact = [select AccountID from Contact where id =: contactId  limit 1];
        if(!contact.isEmpty()) {
            ID accountId  = contact[0].AccountId;
            return [select Id, Percentes__c, Static_Discount__c from Discount__c where Account__c =: accountId];
        }
        return null;
    }

}