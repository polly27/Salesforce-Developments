public class ProductCreationUtil {

    private final Integer MAX_INT = 2147483647;

  @testVisible    
     private Map<Id, Material__c> materials;

  @testVisible
  private Map<Id, Work__c> works;
    
  @testVisible
    private Map<String, Product__c> products;
    
     public ProductCreationUtil() {
        materials = new Map<Id, Material__c>();
    for(Material__c m : [select Id, Name, Amount__c, Cost_Per_Unit__c from Material__c]) {
      materials.put(m.Id, m);
    }
        works = new Map<Id, Work__c>();
        for(Work__c w : [select Id, Name, Amount_Of_Hours__c, Cost_Per_Hour__c from Work__c]) {
      works.put(w.Id, w);
    }
        products = new Map<String, Product__c>();
    }
    
    public List<Product__c> createProducts(Set<String> topProductsNames) {
        List<Blueprint__c> blueprints = getTopBlueprints(topProductsNames);
        createProductsByBlueprints(blueprints, true);
        
        blueprints = getBlueprints();
        createProductsByBlueprints(blueprints, false);
        
        insert products.values();
        update materials.values();
        update works.values();
    return products.values();
  }
  
  @testVisible
     private List<Blueprint__c> getTopBlueprints(Set<String> topProductsNames) {
    return [select Id, Name, Description__c from Blueprint__c where Name in :topProductsNames];
  }
    
    @testVisible
    private List<Blueprint__c> getBlueprints() {
        return [select Id, Name, Description__c from Blueprint__c];
    }

  @testVisible    
    private void createProductsByBlueprints(List<Blueprint__c> blueprints, Boolean random) {
      List<Blueprint_Line__c> blueprintLines = getBlueprintsLines(blueprints);
        while(!blueprints.isEmpty()) {
            Integer i = getRandom(0, blueprints.size() - 1);
            List<Blueprint_Line__c> currentLines = getCurrentBlueprintLines(blueprints[i].Id, blueprintLines);
            List<Double> maxAmountAndCost = getMaxAmountAndCost(currentLines);
            Integer maxAmount = maxAmountAndCost[0].intValue();
            Double cost = maxAmountAndCost[1] * 1.5;
            if(maxAmount != -1) {
                Integer amount = random ? getRandom(Math.floor(maxAmount / 2 + 1).intValue(), maxAmount) : maxAmount;
              addProduct(blueprints[i].Name, blueprints[i].Description__c, cost, amount);
                if(amount == maxAmount) {
                    blueprints.remove(i);
                }
                renewMaterialsAndWorks(currentLines, amount);        
            } else {
              blueprints.remove(i);
            }
        }
    }
    
    @testVisible
    private List<Blueprint_Line__c> getBlueprintsLines(List<Blueprint__c> blueprints) {
    List<Id> blueprintsId = new List<Id>();
    for(Blueprint__c bp : blueprints) {
      blueprintsId.add(bp.Id);
    }
    return [select Id, Name, RecordType.Name, Blueprint__c, Hours_Needed__c, Material__c, 
        Material_Amount__c, Work__c from Blueprint_Line__c];
  }
    
    @testVisible
    private List<Blueprint_Line__c> getCurrentBlueprintLines(Id blueprintId, List<Blueprint_Line__c> blueprintLines) {
        List<Blueprint_Line__c> currentLines = new List<Blueprint_Line__c>();
    for(Blueprint_Line__c bl : blueprintLines) {
      if(bl.Blueprint__c == blueprintId) {
        currentLines.add(bl);
      }
    }
        return currentLines;
  }
    
     @testVisible
     public List<Double> getMaxAmountAndCost(List<Blueprint_Line__c> currentLines) {
    Boolean create = true;
    Double availableNum, neededNum, maxAmount = MAX_INT, cost = 0;
    for(Blueprint_Line__c bl : currentLines) {
      if (create) {
                if(bl.RecordType.Name == 'Material') {
                    Material__c m = materials.get(bl.Material__c);
          availableNum = m.Amount__c;
          neededNum = bl.Material_Amount__c;
                    cost += m.Cost_Per_Unit__c * bl.Material_Amount__c;
        } else if(bl.RecordType.Name == 'Work') {
                    Work__c w = works.get(bl.Work__c);
          availableNum = w.Amount_Of_Hours__c;
          neededNum = bl.Hours_Needed__c;
                    cost += w.Cost_Per_Hour__c * bl.Hours_Needed__c;
                } 
        create = availableNum >= neededNum;
          if(create) {
          maxAmount = Math.min(maxAmount, availableNum / neededNum);
                }
      }
    }
        maxAmount = create ? Math.floor(maxAmount) : -1;
        return new List<Double>{maxAmount, cost};
  }

     @testVisible
     private void addProduct(String name, String description, Double cost, Integer amount) {
    if(products.containsKey(name)) {
      products.get(name).Amount__c += amount;
    } else {
          Product__c product = new Product__c(Name__c = name, Description__c = description, Cost__c = cost, Amount__c = amount);
      products.put(name, product);
    }
  }

  @testVisible    
    private void renewMaterialsAndWorks(List<Blueprint_Line__c> currentLines, Integer amount) {
    for(Blueprint_Line__c bl : currentLines) {
      if(bl.RecordType.Name == 'Material') {
        materials.get(bl.Material__c).Amount__c -= bl.Material_Amount__c * amount;                
      } else if(bl.RecordType.Name == 'Work') {
                works.get(bl.Work__c).Amount_Of_Hours__c -= bl.Hours_Needed__c * amount;
      }
    }
  }
    
    @testVisible
    private static Integer getRandom(Integer min, Integer max) {
    return Math.floor(Math.random() * ((max - min) + 1) + min).intValue();
  }
}