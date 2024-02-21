@isTest
public class ElixirHC_UAanalysisApexConrollerTest {
    public  static testMethod void testMethod1(){
        Account forIns = new Account();
        forIns.Name='Test Demo';
        forIns.DOB__c= System.today();
        
        forIns.Gender__c = 'Male';
        forIns.Blood_Group__c = 'O+';
        insert forIns;
        
        Contact c = new Contact(LastName = 'XXX',AccountId = forIns.Id);  
        insert c;
        List<User> getEmail  = [select id,email from user LIMIT 1];
        UA_Sample_Details__c ua = new UA_Sample_Details__c();
        // ua.Name = 'Test';
        ua.Sample_Type__c='Physical';
        ua.ContainerType__c='Test';
        ua.Container_Description__c='Des';
        ua.ContainerSize__c='Test';
        ua.Specimen_Quantity__c= 'Test';
        ua.Additives_if_Any__c = 'Test';
        ua.Specimen_Condition__c = 'Test';
        ua.Notes__c= 'Test';
        ua.Status__c = 'Open';
        ua.Collection_Datetime__c = System.now();
        ua.Specimen_Collector__c='Test';
        ua.Account__c = forIns.id;
        insert ua;
        system.debug('bh' + ua);
        if(getEmail.size()>0 && getEmail!=null){
            ua.Order_to__c = getEmail[0].Id;
        }
        else {
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
            ua.Order_to__c = u.Id;
            
        }
        Test.startTest();
        ElixirHC_UAanalysisApexConroller.getAccountDetails(forIns.Id);
        ElixirHC_UAanalysisApexConroller.savePhysicalDetail(ua);
        Test.stopTest();
        System.assert(ua.Sample_Type__c!=null,'');
        
    }
    public class wrapper{
        public Account accountRec;
        public List<User> listOfUsers;
    }
}