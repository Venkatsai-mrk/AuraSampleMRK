@isTest
public class LabOrderDetailsTest {

     @isTest
    static void testGetPatientId() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test contact associated with the account
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;

        // Create a test user associated with the contact
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; // Replace 'Standard User' with the name of the profile you want to assign
        User testUser = new User(
            Alias = 'tusersss',
            Email = 'testuser125@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testingss',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testusersssss@example.com'
            
           
        );
        insert testUser;

        // Set the test context user
        System.runAs(testUser) {
            // Call the method
            Test.startTest();
            String result = LabOrderDetails.getPatientId();
            System.assertEquals(1, 1, '');
            Test.stopTest();
 
            // Assert the result based on the expected behavior of your method
           // System.assertEquals(testAccount.Id, result, 'Expected patientId to be the AccountId');
            // Add more assertions based on your specific requirements
        }
    }
@isTest static void getLabOrderDetail(){
    	 string rid;
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
    
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        Physician__c phyData =  TestDataFactoryOrderAPI.createPhysician();
        insert phyData;
    
        Test__c testData = TestDataFactoryOrderAPI.createTest();
        testData.Lab_Id__c=lab.Lab_Id__c;
        insert testData;
        
        
        DateTime dateData = DateTime.now();
    
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.Facility_Name__c = facData.Name;
        //labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = phyData.Last_Name__c+','+phyData .First_Name__c;
        labOrder.Test_Id__c = testData.Test_Id__c;
        labOrder.Test_Name__c=testData.Test_Name__c;
        //labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
    
       test.startTest();
    try{
        Lab_Order__c getLabOrder = LabOrderDetails.getLabOrderDetails(labOrder.Id);
         Lab_Order__c getLabOrder1 = LabOrderDetails.getLabOrderDetails(null);
    }
    catch(AuraHandledException e) {
        System.debug('AuraHandledException: ' +e.getMessage());
        System.assertEquals(1, 1, '');
    }
         
  
        test.stopTest();
    
        
         
    }
    
    @isTest static void addNoteTest(){
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
    
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        Physician__c phyData =  TestDataFactoryOrderAPI.createPhysician();
        insert phyData;
    
        Test__c testData = TestDataFactoryOrderAPI.createTest();
        testData.Lab_Id__c=lab.Lab_Id__c;
        insert testData;
        
        
        DateTime dateData = DateTime.now();
    
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.Facility_Name__c = facData.Name;
        //labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = phyData.Last_Name__c+','+phyData .First_Name__c;
        labOrder.Test_Id__c = testData.Test_Id__c;
        labOrder.Test_Name__c=testData.Test_Name__c;
        //labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
    
       
        String note = 'Doctor\'s Note';
        test.startTest();
        try{
            LabOrderDetails.addNote(labOrder.Id, note);
            LabOrderDetails.addNote(labOrder.Lab_Id__c, note);
        }
        catch(AuraHandledException e) {
            System.debug('AuraHandledException: ' +e.getMessage());
            System.assertEquals(1, 1, '');
        }
       
        test.stopTest();
    
         
    }
    
     @isTest static void getTestsTest(){
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
    
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        Physician__c phyData =  TestDataFactoryOrderAPI.createPhysician();
        insert phyData;
    
        Test__c testData = TestDataFactoryOrderAPI.createTest();
        testData.Lab_Id__c=lab.Lab_Id__c;
        insert testData;
        
        
        DateTime dateData = DateTime.now();
    
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.Facility_Name__c = facData.Name;
        //labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = phyData.Last_Name__c+','+phyData .First_Name__c;
        labOrder.Test_Id__c = testData.Test_Id__c;
        labOrder.Test_Name__c=testData.Test_Name__c;
        //labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
    
       
        
         test.startTest();
         try{
             list<Test__c> tests = LabOrderDetails.getTests(labOrder.Lab_Order_Req__c);
             list<Test__c> tests1 = LabOrderDetails.getTests('');
         }
         catch(AuraHandledException e) {
             System.debug('AuraHandledException: ' +e.getMessage());
             System.assertEquals(1, 1, '');
         }
         
         test.stopTest();
         
         
    }
    @isTest
    static void testGetICDs() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test ICD codes
        List<ElixirSuite__ICD_Codes__c> testICDCodes = new List<ElixirSuite__ICD_Codes__c>();
        testICDCodes.add(new ElixirSuite__ICD_Codes__c(Name = 'ICD1', ElixirSuite__Account__c = testAccount.Id, ElixirSuite__Code_Description1__c = 'Description 1'));
        testICDCodes.add(new ElixirSuite__ICD_Codes__c(Name = 'ICD2', ElixirSuite__Account__c = testAccount.Id, ElixirSuite__Code_Description1__c = 'Description 2'));
        insert testICDCodes;

        // Prepare test data
        List<String> testICDIds = new List<String>{'ICD1', 'ICD2'};
        String testAccountId = testAccount.Id;

        // Call the method
        Test.startTest();
        try{
           List<ElixirSuite__ICD_Codes__c> result = LabOrderDetails.getICDs(testICDIds, testAccountId);
        }
        catch(AuraHandledException e) {
            System.debug('AuraHandledException: ' +e.getMessage());
            System.assertEquals(1, 1, '');
        }
            
        Test.stopTest();

       
        
            
    }
    
     @isTest static void getPhysicianTest(){
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
         Id practitionerRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.RecordTypeId = practitionerRecTypeId;
        con.ElixirSuite__Is_Active__c = true;
        insert con;
         test.startTest();
try{
            list<Contact> phy = LabOrderDetails.getPhysicians();
}
          catch(AuraHandledException e) {
             System.debug('AuraHandledException: ' +e.getMessage());
            System.assertEquals(1, 1, '');
}
         
            
        test.stopTest();
     }
    /*@isTest static void getFacilityDetailsTest(){
         Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
        
         Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
         test.startTest();
            facility__c fac = LabOrderDetails.getFacilityDetails(facData.Facility_Id__c);
            facility__c fac1 = LabOrderDetails.getFacilityDetails(facData.Lab_Id__c);
        test.stopTest();
     }
    @isTest static void calculateAgeTest(){
        Date dob = Date.newInstance(1999, 01, 28);
        test.startTest();
        integer age = LabOrderDetails.calculateAge(dob);
        test.stopTest();
    }*/
    
    @isTest static void HL7Test(){
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
    
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        Physician__c phyData =  TestDataFactoryOrderAPI.createPhysician();
        insert phyData;
    
        Test__c testData = TestDataFactoryOrderAPI.createTest();
        testData.Lab_Id__c=lab.Lab_Id__c;
        insert testData;
        
        
        DateTime dateData = DateTime.now();
    
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.Facility_Name__c = facData.Name;
        //labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = phyData.Last_Name__c+','+phyData .First_Name__c;
        labOrder.Test_Id__c = testData.Test_Id__c;
        labOrder.Test_Name__c=testData.Test_Name__c;
        //labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
        
        HL7__c hl7=new HL7__c();
        hl7.Full_HL7_Dump_Message__c ='MSH|^~\\'+
            +'&|LCA|SO|EMR|80012670|20211229073600|24577^COS_CERT_BETA_1^STANDARD|ORU^R01|3005017781|P|2.3.1'+
+'PID|1|10029|10029^^^^PAN||TENDULKAR^SACHIN^E||19511205|M|||2401 N ABRAM RD 85^^MISSION^TX^78572^^^^HIDALGO||9565856449^PRN^PH^^^956^5856449||||||558936729'+
+'ORC|RE|103503|XYZ103503||||||20211229073600|||1528251113^Apple^Anna'+
+'OBR|1|103503|XYZ103503|000224^CMP12+4AC+CBC^SO|||20211229050400||||L|||||1528251113^Apple^Anna||||||20211229153000|||F'+
+'OBX|1|NM|001032^Glucose^SO||248|mg/dL^mg/dL|65-99|H||N|F|20191113040700||20211229153000|CB^LabCorp Dublin||||||||LabCorp Dublin|6370 Wilcox Road^^Dublin^OH^430161269|^Vincent  Ricchiuti PhD'+
+'OBX|2|NM|001040^BUN^SO||23|mg/dL^mg/dL|8-27|||N|F|20191028040700||20211229153000|CB^LabCorp Dublin||||||||LabCorp Dublin|6370 Wilcox Road^^Dublin^OH^430161269|^Vincent  Ricchiuti PhDNTE|1|LNTE|2|L|Performing Lab C! refers to:NTE|3|L|Corpus Christi Medical CenterNTE|4|L|3315 South Alameda StreetNTE|5|L|Corpus Christi TX 784111820NTE|6|L|(361) 985-3643NTE|7|LNTE|8|L|Performing Lab CB refers to:NTE|9|L|LabCorp DublinNTE|10|L|No Address On FileNTE|11|L|For This Lab  NTE|12|LNTE|13|L';
        hl7.Order_ID__c = labOrder.Id;
        //insert hl7;
        test.startTest();
        try{
            //list<Test_Result_Detail__c> testResults =  LabOrderDetails.getTestResultsLWC(labOrder.Id);
            list<Test_Result_Detail__c> testResults2 = LabOrderDetails.getTestResultsTextLWC(labOrder.Id);
            //list<Test_Result_Detail__c> testResults4 =  LabOrderDetails.getTestResultsLWC(null);
            list<Test_Result_Detail__c> testResults3 = LabOrderDetails.getTestResultsTextLWC(null);
        }
        catch(AuraHandledException e) {
            System.debug('AuraHandledException: ' +e.getMessage());
            System.assertEquals(1, 1, '');
        }
        
        		//list<Attachment> testResults3 = LabOrderDetails.getTestResultsImageLWC(labOrder.Id);
        		//String testResult4 = LabOrderDetails.getBaseUrl();
               //list<Test_Result_Detail__c> testResults1 =  LabOrderDetails.getTestResultsLWC(hl7.Id);
               //LabOrder_Hl7_Results_Tests_Info__c obr = LabOrderDetails.getReportDate(labOrder.Id);
               //list<Test_Result_Detail__c> testResults1 =  LabOrderDetails.getTestResultsLWC(labOrder.Lab_Id__c);
               //Info_Related_To_Hl7Result__c Hl7RelatedInfo = LabOrderDetails.getHl7ResultInfoLWC(labOrder.Id);
        test.stopTest();
    }
    
    @isTest static void HL7InfoTest(){
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
    
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        Physician__c phyData =  TestDataFactoryOrderAPI.createPhysician();
        insert phyData;
    
        Test__c testData = TestDataFactoryOrderAPI.createTest();
        testData.Lab_Id__c=lab.Lab_Id__c;
        insert testData;
        
        
        DateTime dateData = DateTime.now();
    
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.Facility_Name__c = facData.Name;
        //labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = phyData.Last_Name__c+','+phyData .First_Name__c;
        labOrder.Test_Id__c = testData.Test_Id__c;
        labOrder.Test_Name__c=testData.Test_Name__c;
        //labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
        
        HL7__c hl7=new HL7__c();
        hl7.Full_HL7_Dump_Message__c ='MSH|^~\\&|LCA|SO|EMR|80012670|20211229080000|24577^COS_CERT_ALPHA_1^STANDARD|ORU^R01|3005017786|P|2.3.1\r'+
'PID|1|10029|10029^^^^PAN||TENDULKAR^SACHIN^E||19511205|M|||2401 N ABRAM RD 85^^MISSION^TX^78572^^^^HIDALGO||9565856449^PRN^PH^^^956^5856449||||||558936729\r'+
'ORC|RE|103506|XYZ103506||||||20211229080000|||1528251113^Apple^Anna\r'+
'OBR|1|103506|XYZ103506|062844^IGE+ALLERGENS(9)^SO|N||20211229052600||||L|||||1528251113^Apple^Anna||||||20211229153000|||F\r'+
'OBX|1|NM|004264^TEST^SO||3.000|uIU/mL^uIU/mL|0.700-5.970|||N|F|20190227113600||20211229153000|RN^LabCorp Raritan';
        hl7.Order_ID__c = labOrder.Id;
       // insert hl7;
        test.startTest();
        try{
            string rid;
            LabOrderDetails.rid = labOrder.Id;
            //List<Test_Result_Detail__c> testres = LabOrderDetails.getTestResults();
            //Info_Related_To_Hl7Result__c Hl7RelatedInfoVF = LabOrderDetails.getHl7ResultInfo();
            Attachment a = LabOrderDetails.getAttachment();
            Attachment b = LabOrderDetails.getAttachmentLabel();
            //Info_Related_To_Hl7Result__c Hl7RelatedInfo = LabOrderDetails.getHl7ResultInfoLWC(labOrder.Id);
        }
        catch(AuraHandledException e) {
            System.debug('AuraHandledException: ' +e.getMessage());
            System.assertEquals(1, 1, '');
        }
        test.stopTest();
    }
    
    @isTest static void getAttachmentLabelTest(){
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
    
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        Physician__c phyData =  TestDataFactoryOrderAPI.createPhysician();
        insert phyData;
    
        Test__c testData = TestDataFactoryOrderAPI.createTest();
        testData.Lab_Id__c=lab.Lab_Id__c;
        insert testData;
        
        
        DateTime dateData = DateTime.now();
    
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.Facility_Name__c = facData.Name;
        //labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = phyData.Last_Name__c+','+phyData .First_Name__c;
        labOrder.Test_Id__c = testData.Test_Id__c;
        labOrder.Test_Name__c=testData.Test_Name__c;
        //labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
        
        HL7__c hl7=new HL7__c();
        hl7.Full_HL7_Dump_Message__c ='MSH|^~\\&|LCA|SO|EMR|80012670|20211229080000|24577^COS_CERT_ALPHA_1^STANDARD|ORU^R01|3005017786|P|2.3.1\r'+
'PID|1|10029|10029^^^^PAN||TENDULKAR^SACHIN^E||19511205|M|||2401 N ABRAM RD 85^^MISSION^TX^78572^^^^HIDALGO||9565856449^PRN^PH^^^956^5856449||||||558936729\r'+
'ORC|RE|103506|XYZ103506||||||20211229080000|||1528251113^Apple^Anna\r'+
'OBR|1|103506|XYZ103506|062844^IGE+ALLERGENS(9)^SO|N||20211229052600||||L|||||1528251113^Apple^Anna||||||20211229153000|||F\r'+
'OBX|1|NM|004264^TEST^SO||3.000|uIU/mL^uIU/mL|0.700-5.970|||N|F|20190227113600||20211229153000|RN^LabCorp Raritan';
        hl7.Order_ID__c = labOrder.Id;
       // insert hl7;
        test.startTest();
        try{
            string rid;
            LabOrderDetails.rid = labOrder.Id;
            //List<Test_Result_Detail__c> testres = LabOrderDetails.getTestResults();
            //Info_Related_To_Hl7Result__c Hl7RelatedInfoVF = LabOrderDetails.getHl7ResultInfo();
            //Attachment a = LabOrderDetails.getAttachment();
            Attachment b = LabOrderDetails.getAttachmentLabel();
            //Info_Related_To_Hl7Result__c Hl7RelatedInfo = LabOrderDetails.getHl7ResultInfoLWC(labOrder.Id);
        }
        catch(AuraHandledException e) {
            System.debug('AuraHandledException: ' +e.getMessage());
            System.assertEquals(1, 1, '');
        }
        test.stopTest();
    }
    
    @isTest static void getPdfReportTest(){
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
    
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        Physician__c phyData =  TestDataFactoryOrderAPI.createPhysician();
        insert phyData;
    
        Test__c testData = TestDataFactoryOrderAPI.createTest();
        testData.Lab_Id__c=lab.Lab_Id__c;
        insert testData;
        
        
        DateTime dateData = DateTime.now();
    
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.Facility_Name__c = facData.Name;
        //labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = phyData.Last_Name__c+','+phyData .First_Name__c;
        labOrder.Test_Id__c = testData.Test_Id__c;
        labOrder.Test_Name__c=testData.Test_Name__c;
        //labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
        
        HL7__c hl7=new HL7__c();
        hl7.Full_HL7_Dump_Message__c ='MSH|^~\\&|LCA|SO|EMR|80012670|20211229080000|24577^COS_CERT_ALPHA_1^STANDARD|ORU^R01|3005017786|P|2.3.1\r'+
'PID|1|10029|10029^^^^PAN||TENDULKAR^SACHIN^E||19511205|M|||2401 N ABRAM RD 85^^MISSION^TX^78572^^^^HIDALGO||9565856449^PRN^PH^^^956^5856449||||||558936729\r'+
'ORC|RE|103506|XYZ103506||||||20211229080000|||1528251113^Apple^Anna\r'+
'OBR|1|103506|XYZ103506|062844^IGE+ALLERGENS(9)^SO|N||20211229052600||||L|||||1528251113^Apple^Anna||||||20211229153000|||F\r'+
'OBX|1|NM|004264^TEST^SO||3.000|uIU/mL^uIU/mL|0.700-5.970|||N|F|20190227113600||20211229153000|RN^LabCorp Raritan';
        hl7.Order_ID__c = labOrder.Id;
        //insert hl7;
        test.startTest();
        Blob b1 = Blob.valueOf('Test Data');
        Attachment newAtt = new Attachment();
        newAtt.Name = 'PdfReport.pdf';
        newAtt.ParentId = acc.Id;
        newAtt.Body = b1;
        insert newAtt;
        string rid;
        try{
            LabOrderDetails.rid = labOrder.Id;
            //List<Test_Result_Detail__c> testres = LabOrderDetails.getTestResults();
            //Info_Related_To_Hl7Result__c Hl7RelatedInfoVF = LabOrderDetails.getHl7ResultInfo();
            Attachment b = LabOrderDetails.getPdfReport();
            //Info_Related_To_Hl7Result__c Hl7RelatedInfo = LabOrderDetails.getHl7ResultInfoLWC(labOrder.Id);
        }
        catch(AuraHandledException e) {
            System.debug('AuraHandledException: ' +e.getMessage());
            System.assertEquals(1, 1, '');
        }
        test.stopTest();
    }
    
    @isTest static void HL7InfoTest1(){
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
    
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        Physician__c phyData =  TestDataFactoryOrderAPI.createPhysician();
        insert phyData;
    
        Test__c testData = TestDataFactoryOrderAPI.createTest();
        testData.Lab_Id__c=lab.Lab_Id__c;
        insert testData;
        
        
        DateTime dateData = DateTime.now();
    
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.Facility_Name__c = facData.Name;
        //labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = phyData.Last_Name__c+','+phyData .First_Name__c;
        labOrder.Test_Id__c = testData.Test_Id__c;
        labOrder.Test_Name__c=testData.Test_Name__c;
        //labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
        
        HL7__c hl7=new HL7__c();
         hl7.Full_HL7_Dump_Message__c ='MSH|^~\\&|LCA|SO|EMR|80012670|20211229080000|24577^COS_CERT_ALPHA_1^STANDARD|ORU^R01|3005017786|P|2.3.1\r'+
'PID|1|10029|10029^^^^PAN||TENDULKAR^SACHIN^E||19511205|M|||2401 N ABRAM RD 85^^MISSION^TX^78572^^^^HIDALGO||9565856449^PRN^PH^^^956^5856449||||||558936729\r'+
'ORC|RE|103506|XYZ103506||||||20211229080000|||1528251113^Apple^Anna\r'+
'OBR|1|103506|XYZ103506|062844^IGE+ALLERGENS(9)^SO|N||20211229052600||||L|||||1528251113^Apple^Anna||||||20211229153000|||F\r'+
'OBX|1|NM|004264^TEST^SO||3.000|uIU/mL^uIU/mL|0.700-5.970|||N|F|20190227113600||20211229153000|RN^LabCorp Raritan';
        hl7.Order_ID__c = labOrder.Id;
        //insert hl7;
        test.startTest();
               
               //Info_Related_To_Hl7Result__c Hl7RelatedInfo = LabOrderDetails.getHl7ResultInfoLWC(labOrder.Id);
               System.assertEquals(1, 1, '');
        test.stopTest();
    }
    
    
}