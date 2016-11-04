public class ProductCreation {

  public static List<Product__c> createNewProducts(Set<String> topProductsNames) {
    RenewDatabase.cleanProducts();
        ProductCreationUtil pcu = new ProductCreationUtil();
    List<Product__c> products = pcu.createProducts(topProductsNames);
        Email.sendProductCreationReport(products);
    RenewDatabase.fillMaterials();
    RenewDatabase.fillWorks();
        return products;
  }

}