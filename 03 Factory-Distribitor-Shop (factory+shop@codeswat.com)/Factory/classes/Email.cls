public class Email {

  public static Integer sendProductCreationReport(List<Product__c> products) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(getSysAdminAdresses());
    mail.setSenderDisplayName('Salesforce Factory Report');
    mail.setSubject('New Products Created');
    mail.setHtmlBody(generateHtmlBody(products));
    Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return results[0].success ? 0 : 1;
  }
    
    @testVisible
    public static List<String> getSysAdminAdresses() {
        Profile sysadminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        List<User> sysadmins = [SELECT Id, Email FROM User WHERE ProfileId = :sysadminProfile.Id];
        String[] addresses = new List<String>();
        for(User u : sysadmins) {
            addresses.add(u.Email);
        }
        return addresses;
    }

    @testVisible
    private static String generateHtmlBody(List<Product__c> products) {
        String body = 
            '<br><h2>New products were created:</h2>' + 
            '<table cellpadding="3px" cellspacing="3px" style="min-width: 50%; font-size: 12px;">' + 
              '<tr style="font-size: 14px">' + 
                '<th>Product</th>' + 
                '<th>Amount created</th>' + 
                '<th>Cost per item</th>' + 
              '</tr>';
        for(Product__c p : products) {
            body += 
                '<tr>' + 
                  '<td>' + p.Name__c + '</td>' + 
                  '<td style="text-align: center">' + p.Amount__c + '</td>' + 
                  '<td style="text-align: center">$' + p.Cost__c + '</td>' +
                '</tr>';
        }
        body += '</table><br><br>';
        return body;
    }

}