public class RenewDatabase {

  public static void fillMaterials() {
    List<Material__c> materials = [select Id, Amount__c from Material__c];
    for(Material__c m : materials) {
      m.Amount__c += 200;
    }
    update materials;
  }

  public static void fillWorks() {
    List<Work__c> works = [select Id, Amount_Of_Hours__c from Work__c];
    for(Work__c w : works) {
      w.Amount_Of_Hours__c += 10;
    }
    update works;
  }

  public static void cleanProducts() {
    delete [select Id from Product__c];
  }

}