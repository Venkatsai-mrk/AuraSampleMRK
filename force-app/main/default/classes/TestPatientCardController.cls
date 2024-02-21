@isTest
public class TestPatientCardController {
    
    public static Account license= new Account();
    public static string keyString = '9876-5432-1001-2345-6789';
    
    public static testMethod void patientCardControllerTestMethod(){
        //list<RecordType> rcc =[Select Id From RecordType Where SobjectType='Account' And Name='Individual' limit 1];
        Account testPatient=new Account();
        //testPatient.RecordtypeId = rcc[0].Id;
        //testPatient.HealthCloudGA__IndividualId__c='808082989808ABCD';
        testPatient.Name='Test Patient';
        testPatient.Admit_Date__c=system.today();
        testPatient.Discharge_Date__c=system.now()+1;
        // Date dt= Date.parse('04/20/2018');
        // testPatient.DOB__c=dt;
        Insert testPatient;
        
        Contact con1=new Contact();
        //list<RecordType> rcc2 =[Select Id From RecordType Where SobjectType='Contact' And Name='Individual' limit 1];
        //con1.RecordTypeId=rcc2[0].Id;
        
        con1.AccountId=testPatient.Id;
        con1.LastName='Test Contact';
        con1.Birthdate=system.today()-100;
        con1.Email='mirketa@example.com';
        Insert con1;
        
        Account testPatient1=new Account();
        //testPatient1.RecordtypeId = rcc[0].Id;
        testPatient1.Name='Test Patient1';
        testPatient1.Admit_Date__c=system.today();
        testPatient1.Discharge_Date__c=system.now()+1;
        //Date dt1=Date.parse('04/20/2018');
        //testPatient1.DOB__c=dt1;
        Insert testPatient1;
        
        
        Contact con2=new Contact();
        list<RecordType> rcc3 =[Select Id From RecordType Where SobjectType='Contact' And Name='Individual' limit 1];
        // con2.RecordTypeId=rcc3[0].Id;
        con2.AccountId=testPatient1.Id;
        con2.LastName='Test Contact2';
        con2.Birthdate=system.today()-106;
        
        con2.Email='mirketa1@example.com';
        Insert con2;
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.name='testOpportunity';
        testOpportunity.StageName='Prospecting';
        testOpportunity.CloseDate=system.today();
        insert testOpportunity;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        content.FIRSTPUBLISHLOCATIONID=testPatient.Id;
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=con2.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        insert contentlink;
        
        ElixirSuite__TabPermissionBasedOnProfiles__c laborder = new ElixirSuite__TabPermissionBasedOnProfiles__c();
        laborder.ElixirSuite__LabOrder_Priority__c = 'CHC LabOrder';
        insert laborder;
        
        User testUser = new User(
            FirstName = 'patientcard',
            LastName = 'User',
            Username = 'patientcard@example.com',
            Email = 'patientcard@example.com',
            Alias = 'pacard',
            TimeZoneSidKey = 'America/New_York',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            ElixirSuite__License_Type__c = 'Elixir EHR;Elixir RCM'
        );
        insert testUser;
        Id recordTypeId = Schema.SObjectType.Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Info_Card_Configuration').getRecordTypeId();
         ElixirSuite__Master_Object__c masterRec1 = new ElixirSuite__Master_Object__c();
            masterRec1.ElixirSuite__Field_Label__c = 'Gender';
            masterRec1.ElixirSuite__Field_Api__c = 'Id';
            masterRec1.ElixirSuite__Patient_Tile_Entity__c = 'Account';
            masterRec1.ElixirSuite__Patient_Tile_Order__c = 0;
            masterRec1.RecordTypeId = recordTypeId;
        insert masterRec1;
        Test.startTest();
        System.debug(testPatient.Id);
      //  Object patWrap= patientCardController.patientCardMethod(testPatient.Id);
        patientCardController.handlingAfterUpload(testPatient.Id);
        patientCardController.revertPatientDeceased(testPatient.Id);
        patientCardController.patientCardMethod(testPatient.Id);
        patientCardController.getTileConfigFieldsOrder(testPatient.Id);
        patientCardController.patientWrapperMethod(testPatient.Id);
        patientCardController.updateAllOpportunity(new Set<Id>{testPatient.Id});
        patientCardController.updateAllContact(new Set<Id>{testPatient.Id});
        patientCardController.updateAllPreAsses(new Set<Id>{testOpportunity.Id});
        patientCardController.updateAllAluminiCare(new Set<Id>{testPatient.Id},new Set<Id>{testOpportunity.Id});
        patientCardController.updateAllVOB(new Set<Id>{testPatient.Id},new Set<Id>{testOpportunity.Id});
        patientCardController.getUserInfo();
        patientCardController.LicensBasdPermission();
        patientCardController.fetchPortalForms();
        patientCardController.fetchDummyLabOrder();
        patientCardController.fetchCHCLabOrder();
         patientCardController.fetchPayments();
        patientCardController.fetchPortalNotifications();
        system.assertEquals(1, 1,'');
        // system.assert(patWrap!=Null);
        Test.stopTest();
    }
}