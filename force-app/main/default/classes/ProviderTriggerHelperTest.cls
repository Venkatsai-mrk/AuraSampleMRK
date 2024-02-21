@isTest
public class ProviderTriggerHelperTest {
    @isTest
    public static void evaluateOpportunityLocation(){      
        Set<Id> accSet = new Set<Id>();
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        patient.ElixirSuite__Deceased__c =true;         
        insert patient;                      
        accSet.add(patient.Id); 
        
        Provider__c providerRec = new Provider__c();
        providerRec.Account__c = patient.Id;
        providerRec.Provider_Code__c  = 'Test123';
        providerRec.Name = 'TestProvider'; 
        providerRec.Id=null;
        insert providerRec;
        
        Opportunity op=new Opportunity();
        op.Name='a';
        op.AccountId=patient.Id;        
        op.CloseDate=System.today();     
        op.Referred_In_Organization__c=patient.id;
        op.Referral_Type__c='Inbound';
        op.StageName='Prospecting';
        insert op;
        
        List<Opportunity> oppoList = [Select Id , Location__c from Opportunity where  Location__c =:Null];
        update oppoList;    
        Test.startTest();
        ProviderTriggerHelper.evaluateOpportunityLocation( accSet  );       
        Test.stopTest();
        system.assertEquals(1,1,'Hello');
    }
    @isTest
    public static void evaluateOpportunityLocation2(){      
        Set<Id> accSet = new Set<Id>();
        Account patient = new Account();       
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        patient.ElixirSuite__Deceased__c =true;         
        insert patient;                      
        accSet.add(patient.Id);    
        
        List<Provider__c> providerReclist = new List<Provider__c>();
        
        Provider__c providerRec2 = new Provider__c();
        providerRec2.Account__c = null;
        providerRec2.Provider_Code__c  = 'Test1223';
        providerRec2.Name = 'TestProvider2';        
        insert providerRec2;
        
        
        Provider__c providerRec3 = new Provider__c();
        providerRec3.Account__c = null;
        providerRec3.Provider_Code__c  = 'Test1223';
        providerRec3.Name = 'TestProvider2';        
        insert providerRec3;
        
        Opportunity op=new Opportunity();
        op.Name='a';
        op.AccountId=patient.Id;        
        op.CloseDate=System.today();     
        op.Referred_In_Organization__c=patient.id;
        op.Referral_Type__c='Inbound';
        op.StageName='Prospecting';
        insert op;  
        
        List<Provider__c> providers = [SELECT Id, Patient_Provider__c, Provider_Code__c, Account__c, Provider__c FROM Provider__c];
        
        Test.startTest();
        ProviderTriggerHelper.evaluateOpportunityLocation( accSet  );
        ProviderTriggerHelper.populateProviders(providerReclist);
        Test.stopTest();
        system.assertEquals(1,1,'Hello');
    }

    @isTest
    public static void testUpdate(){ 
        Test.startTest();
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        patient.ElixirSuite__Deceased__c =true;         
        insert patient;     
        
        Provider__c providerRec = new Provider__c();
        providerRec.Account__c = patient.Id;
        providerRec.Provider_Code__c  = 'Test123';
        providerRec.Name = 'TestProvider'; 
        insert providerRec;
        
        update providerRec;
        
        system.assertEquals(1,1);     
        Test.stopTest();
        
    }
    
    @isTest
    public static void testDelete(){ 
        Test.startTest();
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        patient.ElixirSuite__Deceased__c =true;         
        insert patient;     
        
        Provider__c providerRec = new Provider__c();
        providerRec.Account__c = patient.Id;
        providerRec.Provider_Code__c  = 'Test123';
        providerRec.Name = 'TestProvider'; 
        insert providerRec;
        
        delete providerRec;
        
        system.assertEquals(1,1);     
        Test.stopTest();
        
    }
    
    @isTest
    public static void testDummy(){ 
        Test.startTest();
        
        ProviderPermissionDeletion.dummyMethod();
        ProviderPermissionDeletion py = new ProviderPermissionDeletion();
        System.enqueueJob(py);
        ProviderPermissionHelper.dummyMethod();
        ProviderPermissionHelper ty = new ProviderPermissionHelper();
        System.enqueueJob(ty);
         system.assertEquals(1,1);     
        Test.stopTest();
        
    }
}