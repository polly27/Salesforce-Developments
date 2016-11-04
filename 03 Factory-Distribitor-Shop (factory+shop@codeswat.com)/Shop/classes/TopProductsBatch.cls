global class TopProductsBatch implements
  Database.Batchable<sObject>, Database.Stateful {

  global Map<Id, Integer> totalSold;

  global Database.QueryLocator start(Database.BatchableContext bc) {
    totalSold = new Map<Id, Integer>();
    return Database.getQueryLocator([select Id, Amount__c, Product__c 
                    from Sales_Order_Line__c where CreatedDate = LAST_N_DAYS:7]);
  }

  global void execute(Database.BatchableContext bc, List<Sales_Order_Line__c> scope){
    for(Sales_Order_Line__c sol : scope) {
      Integer prevAmount = totalSold.containsKey(sol.Product__c) ? totalSold.get(sol.Product__c) : 0;
      totalSold.put(sol.Product__c, prevAmount + sol.Amount__c.intValue());
    }
  }

  global void finish(Database.BatchableContext bc){
    Id topListId = getNewTopListId();
    List<Id> topId = getTopTenProductsId();
    for(Id item : topId) {
      createTopProduct(item, topListId);
    }
  }  

  @TestVisible
  private Id getNewTopListId() {
    Top_Ten_Products_List__c topList = new Top_Ten_Products_List__c();
    insert topList;
    return topList.Id;
  }

  @TestVisible
  private List<Id> getTopTenProductsId() {
    List<Id> result = new List<Id>();
    for(Id idItem : totalSold.keySet()) {
      if(result.size() < 10) {
        result.add(idItem);
      } else {
        List<Integer> resultValues = new List<Integer>();
                for(Id tmp : result) {
                    resultValues.add(totalSold.get(tmp));
                }
                resultValues.sort();
        if(totalSold.get(idItem) > resultValues[0]) {
                    for(Integer i = 0; i < result.size(); i++) {
                        if(totalSold.get(result[i]) == resultValues[0]) {
                            result[i] = idItem;
                        }
                    }
        }
      }
    }
    return result;
  }

  @TestVisible
  private void createTopProduct(Id productId, Id topListId) {
    Integer amount = totalSold.get(productId);
    insert new Top_Ten_Product__c(Product__c = productId, Amount__c = amount, Top_List__c = topListId);
  }

}