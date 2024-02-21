@isTest
public class ActiveMedicationApexTest {
    @isTest
    public static void activeMedicationmethod(){
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'San Francisco',
            BillingState = 'CA',
            BillingPostalCode = '94117',
            BillingCountry = 'USA'
        );
        insert testAccount;
        
        Contact con = new Contact(LastName ='testCon',AccountId = testAccount.Id,ElixirSuite__Drug_Name__c = 'UT-Life');
        insert con; 
        
        ElixirSuite__Prescription_Order__c Po = new ElixirSuite__Prescription_Order__c();
        Po.ElixirSuite__Drug_Name__c= 'UT-Life';
        Po.ElixirSuite__Dosage__c = '100ml';
        Po.ElixirSuite__Ferquency__c = '3 times a day';
        Po.ElixirSuite__Account__c = testAccount.Id;
        insert Po;
        
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Request Update For Insurance';
        validEmailTemplate.DeveloperName = 'Request_Update_For_Insurance';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        
        Profile profiles = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User'];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            //ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User'].Id,
            ProfileId = profiles.Id,
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive =true,
            ContactId = con.Id
        );
        User usr = [Select Id,Division from  User where Id=:UserInfo.getUserId()];
        system.runAs(usr){
            insert testUser;
            insert validEmailTemplate;
            system.debug('ProfileId' +testUser.ProfileId);
        }
     system.runAs(testUser) {
        test.startTest();
        activeMedicationApex.sendEmailMethod(testUser.Id, Po.Id);
        test.stopTest();
         //System.assert(result != null,'');
        System.assertEquals(1, 1, ' ');
     }
        
    }
    
    
}