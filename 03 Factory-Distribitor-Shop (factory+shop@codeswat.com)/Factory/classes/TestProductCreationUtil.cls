@isTest public class TestProductCreationUtil {
    
  @testSetup public static void testSetup() {
    Integer n = 10;
    Integer materialsN = 20 * n, worksN = 5 * n, productsN = 2 * n, bluebrintsN = 3 * n;    

    List<Material__c> materials = new List<Material__c>();
    for(Integer i = 0; i < materialsN; i++) {
      materials.add(new Material__c(Name = 'material ' + i, Cost_Per_Unit__c = i + 1,
        Amount__c = ProductCreationUtil.getRandom(50, 300), Measure_Unit__c = 'test'));
    }
    insert materials;

    List<Work__c> works = new List<Work__c>();
    for(Integer i = 0; i < worksN; i++) {
      works.add(new Work__c(Name = 'work ' + i, Cost_Per_Hour__c = i + 1,
        Amount_Of_Hours__c = ProductCreationUtil.getRandom(3, 15)));
    }
    insert works;

    List<Blueprint__c> bluebrints = new List<Blueprint__c>();
    for(Integer i = 0; i < bluebrintsN; i++) {
      bluebrints.add(new Blueprint__c(Name = 'bluebrint ' + i, Description__c = 'test ' + i));
    }
    insert bluebrints;

        Id materialId = [select Id, Name from RecordType where name = 'Material'][0].Id;
    Id workId = [select Id, Name from RecordType where name = 'Work'][0].Id;

    List<Blueprint_Line__c> bluebrintLines = new List<Blueprint_Line__c>();
    for(Integer i = 0; i < bluebrintsN; i++) {
      Integer k = ProductCreationUtil.getRandom(1, 3);
      Set<Id> added = new Set<Id>();
      for(Integer j = 0; j < 3 * k; j++) {
        Material__c m = materials[ProductCreationUtil.getRandom(0, materialsN - 1)];
        if(added.contains(m.Id)) {
          j--;
        } else {
          bluebrintLines.add(new Blueprint_Line__c(RecordTypeId = materialId, Blueprint__c = bluebrints[i].Id, 
            Material__c = m.Id, Material_Amount__c = ProductCreationUtil.getRandom(1, 15)));
          added.add(m.Id);
        }
      }
      for(Integer j = 0; j < k; j++) {
        Work__c w = works[ProductCreationUtil.getRandom(0, worksN - 1)];
        if(added.contains(w.Id)) {
          j--;
        } else {
          bluebrintLines.add(new Blueprint_Line__c(RecordTypeId = workId, Blueprint__c = bluebrints[i].Id, 
            Work__c = w.Id, Hours_Needed__c = Double.valueOf(ProductCreationUtil.getRandom(1, 10)) / 10));
          added.add(w.Id);
        }

      }
    }
    insert bluebrintLines;
  } 

  @isTest public static void testProductCreationUtil() {
    Integer materials = [select COUNT() from Material__c];
    Integer works = [select COUNT() from Work__c];
    ProductCreationUtil pcu = new ProductCreationUtil();
    system.assertEquals(materials, pcu.materials.size());
    system.assertEquals(works, pcu.works.size());
  }

  @isTest public static void testCreateProducts() {
    Integer n = [select COUNT() from Product__c];
        List<Blueprint__c> bpList = [select Name from Blueprint__c limit 10];
        Set<String> topProductsNames = new Set<String>();
        for(Blueprint__c bp : bpList) {
            topProductsNames.add(bp.Name);
        }
    ProductCreationUtil pcu = new ProductCreationUtil();
    List<Product__c> products = pcu.createProducts(topProductsNames);
    system.assertEquals([select COUNT() from Product__c] - n, products.size());
  }

  @isTest public static void testGetTopBlueprints() {
    List<Blueprint__c> topProducts = [select Id, Name from Blueprint__c limit 5 offset 3];
    Set<String> topNames = new Set<String>();
    for(Blueprint__c p : topProducts) {
      topNames.add(p.Name);
    }

    ProductCreationUtil pcu = new ProductCreationUtil();
    List<Blueprint__c> bp = pcu.getTopBlueprints(topNames);

    system.assertEquals(topProducts.size(), bp.size());
    for(Blueprint__c item : bp) {
      system.assert(topNames.contains(item.Name));
    }
  }

  @isTest public static void testGetBlueprints() {
    Integer n = [select COUNT() from Blueprint__c];
    
    ProductCreationUtil pcu = new ProductCreationUtil();
    List<Blueprint__c> bp = pcu.getBlueprints();

    system.assertEquals(n, bp.size());
  }

  @isTest public static void testCreateProductsByBlueprints() {
    ProductCreationUtil pcu = new ProductCreationUtil();
    pcu.createProductsByBlueprints([select Id, Name, Description__c from Blueprint__c], true);
    system.assertNotEquals(pcu.products.size(), 0);
  }

  @isTest public static void testGetBlueprintsLines() {
    ProductCreationUtil pcu = new ProductCreationUtil();
    List<Blueprint_Line__c> bl = pcu.getBlueprintsLines([select Id, Name, Description__c from Blueprint__c]);
    system.assertEquals([select COUNT() from Blueprint_Line__c], bl.size());
  }

  @isTest public static void testGetCurrentBlueprintLines() {
    ProductCreationUtil pcu = new ProductCreationUtil();
    Blueprint__c b = [select Id from Blueprint__c limit 1][0];
    Blueprint_Line__c[] blList = [select Id, Blueprint__c from Blueprint_Line__c];
    List<Blueprint_Line__c> currentLines = pcu.getCurrentBlueprintLines(b.Id, blList);
    for(Blueprint_Line__c bl : currentLines) {
      system.assertEquals(b.Id, bl.Blueprint__c);
    }
  }

  @isTest public static void testGetMaxAmountAndCost() {
    Blueprint__c b = [select Id from Blueprint__c limit 1][0];
    Blueprint_Line__c[] blList = [select Id, Blueprint__c, RecordType.Name, Material__c, Material_Amount__c,
      Work__c, Hours_Needed__c from Blueprint_Line__c];
    Map<Id,Material__c> materials = new Map<Id,Material__c>([select Id, Amount__c from Material__c]);
    Map<Id,Work__c> works = new Map<Id,Work__c>([select Id, Amount_Of_Hours__c from Work__c]);
    ProductCreationUtil pcu = new ProductCreationUtil();
    List<Blueprint_Line__c> currentLines = pcu.getCurrentBlueprintLines(b.Id, blList);

    List<Double> maxAmountAndCost = pcu.getMaxAmountAndCost(currentLines);
    Double maxAmount = maxAmountAndCost[0], cost = maxAmountAndCost[1];

    if(maxAmount != -1) {
      for(Blueprint_Line__c bl : currentLines) {
        if(bl.RecordType.Name == 'Material') {
          system.assert(maxAmount * bl.Material_Amount__c <= materials.get(bl.Material__c).Amount__c);
        }
        if(bl.RecordType.Name == 'Work') {
          system.assert(maxAmount * bl.Hours_Needed__c <= works.get(bl.Work__c).Amount_Of_Hours__c);
        }
      }
    } else {
      Boolean create = true;
      for(Blueprint_Line__c bl : currentLines) {
        if(create) {
          if(bl.RecordType.Name == 'Material') {
            create = maxAmount * bl.Material_Amount__c <= materials.get(bl.Material__c).Amount__c;
          }
          if(bl.RecordType.Name == 'Work') {
            create = maxAmount * bl.Hours_Needed__c <= works.get(bl.Work__c).Amount_Of_Hours__c;
          }
        }
      }
      system.assertEquals(false, create);
    }
  }

  @isTest public static void testAddProduct() {
    ProductCreationUtil pcu = new ProductCreationUtil();
    Product__c product = new Product__c(Name__c = 'teeest', Description__c = 'description', Cost__c = 100, Amount__c = 5);

    pcu.addProduct(product.Name__c, product.Description__c, Double.valueOf(product.Cost__c), Integer.valueOf(product.Amount__c));
    Product__c prod = pcu.products.get(product.Name__c);
    system.assertEquals(prod.Amount__c, product.Amount__c);
    
    pcu.addProduct(product.Name__c, product.Description__c, Double.valueOf(product.Cost__c), Integer.valueOf(product.Amount__c));
    prod = pcu.products.get(product.Name__c);
    system.assertEquals(prod.Amount__c, product.Amount__c * 2);
  }

  @isTest public static void testRenewMaterialsAndWorks() {
    ProductCreationUtil pcu = new ProductCreationUtil();
    Blueprint__c b = [select Id from Blueprint__c limit 1][0];
    Blueprint_Line__c[] blList = [select Id, Blueprint__c, RecordType.Name, Material__c, Material_Amount__c,
      Work__c, Hours_Needed__c from Blueprint_Line__c];
    List<Blueprint_Line__c> currentLines = pcu.getCurrentBlueprintLines(b.Id, blList);

    Integer amount = pcu.getMaxAmountAndCost(currentLines)[0].intValue();
    Map<Id, Double> materials = new Map<Id,Double>();
    for(Material__c m : pcu.materials.values()) {
      materials.put(m.Id, m.Amount__c);
    }
    Map<Id, Double> works = new Map<Id,Double>();
    for(Work__c w : pcu.works.values()) {
      works.put(w.Id, w.Amount_Of_Hours__c);
    }
    pcu.renewMaterialsAndWorks(currentLines, amount);

    for(Blueprint_Line__c bl : currentLines) {
      if(bl.RecordType.Name == 'Material') {
        system.assertEquals(pcu.materials.get(bl.Material__c).Amount__c, 
          materials.get(bl.Material__c) - bl.Material_Amount__c * amount);
        system.assert(pcu.materials.get(bl.Material__c).Amount__c >= 0);
      } else if(bl.RecordType.Name == 'Work') {
                system.assertEquals(pcu.works.get(bl.Work__c).Amount_Of_Hours__c,
                  works.get(bl.Work__c) - bl.Hours_Needed__c * amount);
                system.assert(pcu.works.get(bl.Work__c).Amount_Of_Hours__c >= 0);
      }
    }

  }

  @isTest public static void testGetRandom() {
    Integer min = -5, max = 5;
    for(Integer i = 0; i < 20; i++) {
      Integer rand = ProductCreationUtil.getRandom(min, max); 
      system.assert(rand >= min);
      system.assert(rand <= max);
    }
  }

}