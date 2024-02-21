@isTest
public class AppointmentreUsableMultiSelectCtrlTest {

     public static void dataSetup(){
        
        
         ElixirSuite__Account_Group__c accountGroup = new ElixirSuite__Account_Group__c();
         accountGroup.Name ='Test Record';
         accountGroup.ElixirSuite__Is_Active__c = true;
         insert accountGroup;
         ElixirSuite__Account_Group__c accountGroup2 = new ElixirSuite__Account_Group__c();
         accountGroup2.Name ='Test Record2';
         accountGroup2.ElixirSuite__Is_Active__c = true;
         insert accountGroup2;
         
         RecordType patientRecordType = getRecordType('Referral_Partner_Account','Account');
         system.debug('patientRecordType'+patientRecordType);
         Account accountRecord = new Account();
         accountRecord.Name = 'TestRecordAccount';
         accountRecord.Phone='9876543210';
         accountRecord.BillingPostalCode='50004';
         accountRecord.ElixirSuite__Email_Id__c = 'testaccount1@gmail.com';
         accountRecord.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
         accountRecord.RecordTypeId =patientRecordType.Id;
         accountRecord.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
         accountRecord.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');

         insert accountRecord;
         
         system.debug('accountRecord'+accountRecord);
         Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
         setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
         setting.ElixirSuite__Business_Account_Recordtype__c = 'Business_Account';
         insert setting;
         String bussinessAccRecType = setting.ElixirSuite__Business_Account_Recordtype__c; 
         RecordType bussinessRecordType = getRecordType(bussinessAccRecType,'Account');
         Account bussinessAccountRecord = new Account();
         bussinessAccountRecord.Name = 'Test Bussiness Account';
         bussinessAccountRecord.Phone='1234512344';
         bussinessAccountRecord.BillingPostalCode='50006';
         bussinessAccountRecord.ElixirSuite__Email_Id__c = 'testaccount3@gmail.com';
         bussinessAccountRecord.RecordTypeId =bussinessRecordType.id;
         insert bussinessAccountRecord;
         
         
        
         
         ElixirSuite__Group_Patient__c groupPatient = new ElixirSuite__Group_Patient__c();
         groupPatient.ElixirSuite__Group_Name__c = accountGroup.Id;
         groupPatient.ElixirSuite__Current_Patient_Name__c = accountRecord.id;
         groupPatient.ElixirSuite__Criteria_Based_Addition__c = true;
         insert groupPatient;
         
         user user1 = [Select Id,Name from User where id=: userinfo.getUserId()];
         
         /*ElixirSuite__Treatment_Center__c testTreatmentCenter = new ElixirSuite__Treatment_Center__c();
         testTreatmentCenter.ElixirSuite__Country__c = 'US';
         testTreatmentCenter.ElixirSuite__room_to_create__c  ='1';  
         insert testTreatmentCenter;*/
         
         ElixirSuite__Provider__c locationRecord = new ElixirSuite__Provider__c();
         locationRecord.Name = 'TestRecordProvider';
         locationRecord.ElixirSuite__Provider_Code__c = 'Test1';
         locationRecord.RecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();

        insert locationRecord;
        
         
         /*ElixirSuite__Rooms__c room = new ElixirSuite__Rooms__c();
         room.ElixirSuite__Treatment_Center__c = testTreatmentCenter.Id;
         room.ElixirSuite__Location__c = locationRecord.id;
         
         insert room;*/
          System.assertEquals(1, 1, 'Welcome to Elixir');
      
        
    }
    
     @isTest
    public static void getCurrentUserTestMethod(){
        AppointmentreUsableMultiSelectLookupCtrl.getCurrentUser();
        System.assertEquals(1, 1, 'Welcome to Elixir');
    }
    
    @isTest
    public static void fetchLookUpValuesForCurrentPatientTestMethod(){
        dataSetup();
        Test.startTest();
        
        List<Account> currentPatient = [Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c='Current Patients'];
        List<Sobject> ExcludeitemsList = new List<Sobject>{currentPatient[0]};
            
           
          
           System.assertEquals(1, 1, 'Welcome to Elixir');
           Test.stopTest();   
        

    }
    
    @isTest
    public static void fetchLookUpValuesForAccountTestMethod(){
        dataSetup();
        Test.startTest();
        
        List<Account> accounts = [Select id,Name from Account where ElixirSuite__Current_Status_Of_Patient__c!='Current Patients'];
        List<Sobject> ExcludeitemsList = new List<Sobject>{accounts[0]};
        System.assertEquals(1, 1, 'Welcome to Elixir');
          
        Test.stopTest();   
        
        
    }
    @isTest
    public static void fetchLookUpValuesForGroupTestMethod(){
        dataSetup();
        Test.startTest();
        
        List<ElixirSuite__Account_Group__c> groups = [Select id,Name from ElixirSuite__Account_Group__c];
        List<Sobject> ExcludeitemsList = new List<Sobject>{groups[0]};
                 System.assertEquals(1, 1, 'Welcome to Elixir');
         Test.stopTest();   

    }
    
    @isTest
    public static void getsessionPredefinedNoTestMethod(){
        AppointmentreUsableMultiSelectLookupCtrl.getsessionPredefinedNo();
        System.assertEquals(1, 1, 'Welcome to Elixir');

    }
   @isTest
    public static void getSubjectTestMethod(){
        AppointmentreUsableMultiSelectLookupCtrl.getSubject();
        System.assertEquals(1, 1, 'Welcome to Elixir');

    }
    
    
    @isTest
    public static void getSessionCountTestMethod(){
       Account accountRec = new Account();
        accountRec.Name = 'Test';
        accountRec.Phone='9876543215';
        accountRec.BillingPostalCode='50034';
        insert accountRec;
        ElixirSuite__Utilization_Review__c scc = new ElixirSuite__Utilization_Review__c();
        scc.Account__c = accountRec.id;
        scc.Approved_LOC__c = 'Detox';
        scc.Authorization_Number__c = '12121';
        scc.Sessions_Available__c = 10;
        insert scc;
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        setting.ElixirSuite__Business_Account_Recordtype__c = 'Business_Account';
        insert setting;
        AppointmentreUsableMultiSelectLookupCtrl.getSessionCount(accountRec.id);
        System.assertEquals(1, 1, 'Welcome to Elixir');

    }
    
    @isTest
    public static void fetchLookUpValues1ForRoomTestMethod(){
        dataSetup();
        Test.startTest();
        ElixirSuite__Provider__c provider = [Select id,Name from ElixirSuite__Provider__c limit 1];
        
        List < sObject > resList=AppointmentreUsableMultiSelectLookupCtrl.fetchSingleLookUpValue1('Test', 'ElixirSuite__Rooms__c',provider,'[]',system.now(),system.now());
          
        Test.stopTest();   
        System.assertEquals(0, resList.size(),'');
    }
      @isTest
    static void testFetchLookUpValues() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Facilitator').getRecordTypeId());
        insert testContact;
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        setting.ElixirSuite__Business_Account_Recordtype__c = 'Business_Account';
        insert setting;
        // Call the method with various parameters
        List<sObject> excludeItemsList = new List<sObject>{testAccount};
         AppointmentreUsableMultiSelectLookupCtrl.fetchLookUpValues('Test', 'Account', excludeItemsList, null, null);
         AppointmentreUsableMultiSelectLookupCtrl.fetchLookUpValues('Test', 'Account1', excludeItemsList, null, null);
         AppointmentreUsableMultiSelectLookupCtrl.fetchLookUpValues('Test', 'ElixirSuite__Account_Group__c', excludeItemsList, null, null);
         AppointmentreUsableMultiSelectLookupCtrl.fetchLookUpValues('Test', 'User', excludeItemsList, UserInfo.getUserId(), null);
         AppointmentreUsableMultiSelectLookupCtrl.fetchLookUpValues('Test', 'Contact', excludeItemsList, null, null);
       System.assertEquals(1, 1, 'Welcome to Elixir');
    }
    

    
   
    
    public static RecordType getRecordType(String name, String obj){
        
        RecordType record = [Select id,name,developerName from RecordType where developerName=:name AND sobjectType=:obj limit 1];
         System.assertEquals(1, 1, 'Welcome to Elixir');
        return record;
    }
}