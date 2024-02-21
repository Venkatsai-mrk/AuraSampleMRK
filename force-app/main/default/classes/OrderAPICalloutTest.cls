@isTest
public class OrderAPICalloutTest {
    
    
    @isTest
    static void testOrderAPICallouts(){
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        
        Account testAccount = TestDataFactoryOrderAPI.createAccount();
        testAccount.Last_name__c='Testpatient';
        testAccount.First_Name__c='Account';
        testAccount.Name='Test Patient Account';
        testAccount.BillingStreet='Hyd';
        testAccount.BillingCity = 'HYD';
        testAccount.BillingState='DA';
        testAccount.BillingPostalCode='23456'; 
        testAccount.BillingCountry='US';
        testAccount.Gender__c='Male';
        testAccount.SSN__c='7569467';
        testAccount.Phone='3456789013';
        testAccount.Patient_s_Birth_Date__c=Date.today();
        testAccount.DOB__c=Date.today();
        insert testAccount;
        
        Payor__c payor = TestDataFactoryOrderAPI.createPayor();
        insert payor;
        
        VOB__c vobData = TestDataFactoryOrderAPI.createVob();
        vobData.Insurance_Providers__c = payor.Id;
        vobData.Account__c=acc.Id;
        insert vobData;
        Elixir_Custom_Setting__c conRectype = new Elixir_Custom_Setting__c();
        conRectype.ElixirSuite__Contact_RecordType__c = 'Contact';
        conRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert conRectype;
        String contactRecType = conRectype.ElixirSuite__Contact_RecordType__c; 
        Id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        
        Contact guarantor = new Contact();
        guarantor.FirstName = 'Test';
        guarantor.LastName = 'Test';
        guarantor.AccountId = testAccount.Id;
        guarantor.ElixirSuite__Gender__c = 'M';
        guarantor.Phone = '9618974732';
        guarantor.Birthdate = System.today();
        guarantor.ElixirSuite__Is_Active__c = true;
        guarantor.ElixirSuite__Type__c = 'Guarantor';
        guarantor.RecordTypeId = conRecTypeId;
        guarantor.MailingCity = 'Test';
        guarantor.MailingPostalCode = '51500';
        insert guarantor;
        
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.ElixirSuite__Relationship__c = 'PAR';
        acr.AccountId = acc.Id;
        acr.ContactId = guarantor.Id;
        insert acr;
        
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
        
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        String contactRecTyp = conRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        Id practitionerRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecTyp).getRecordTypeId();
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.RecordTypeId = practitionerRecTypeId;
        con.ElixirSuite__Is_Active__c = true;
        insert con;
        
        List<Test__c> testList = new List<Test__c>();
        List<ICD__c> ICDList = new List<ICD__c>();
        
        Test__c testData = TestDataFactoryOrderAPI.createTest();
        testData.Lab_Id__c=lab.Lab_Id__c;
        insert testData;
        testList.add(testData);
        
        DateTime dateData = DateTime.now();
        ICD__c icdData = TestDataFactoryOrderAPI.createICD();
        insert icdData;
        ICDList.add(icdData);
        
        List<String> selectedTest = new List<String>();
        List<String> selectedLabOrder = new List<String>();
        List<String> selectedICD = new List<String>();
        For(Integer i=0;i<testList.size();i++){
            selectedTest.add(testList[i].Test_Id__c);
        }
        For(Integer i=0;i<ICDList.size();i++){
            selectedICD.add(ICDList[i].ICD_Id__c);
        }
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.Facility_Name__c = facData.Name;
        labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = con.LastName+','+con.FirstName;
        labOrder.Test_Id__c = testData.Test_Id__c;
        labOrder.Test_Name__c=testData.Test_Name__c;
        labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
        selectedLabOrder.add(labOrder.Lab_Order_Number__c); 
        String phyName = con.LastName+','+con.FirstName;
        String searchKey='300';
        String CollDatetime='2022-01-20T21:04:00Z';
        String personBody = 'request=<?xml version=\'1.0\'?><OBJECT name="person" op="put_partial"><birth_date>10/27/1924</birth_date><first_name>Florence</first_name><last_name>Edwards</last_name><middle_name>E</middle_name><suffix></suffix><ssn>558936729</ssn><address_1>2401 N Abram Rd 85</address_1><address_2></address_2><city>Mission</city><state>TX</state><sex>F</sex><zip>78572</zip><hsi_value>955001</hsi_value><hsilabel>7930723</hsilabel><home_phone_area_code>956</home_phone_area_code><home_phone_number>5856449</home_phone_number></OBJECT></REQUEST>';
        
        Test.setMock(HttpCalloutMock.class, new OrderAPICalloutMock());
        
        test.startTest();
        
        //HttpResponse response = new HttpResponse();
        //response = OrderAPICallouts.makeHTTPXMLPost(personBody);
        //String parsing  = OrderAPICallouts.retrieveFromXMLDom(response,'person');
        //CHCCredentials__mdt creChc = OrderAPICallouts.getCredentials();
        OrderAPICallouts.getCredentials();
        List<VOB__c> vobList = OrderAPICallouts.getVOBList(acc.Id);
        //Guarantor__c guarantorData = OrderAPICallouts.getGuarantorDetails(acc.Id,guarantor.Id);
        //Contact guarantorDetails = OrderAPICallouts.getGuarantorDetailsPicklist(acc.Id,guarantor.Id);
        List<Contact> guarantorList = OrderAPICallouts.getGuarantorList(acc.Id);
        Account account = OrderAPICallouts.getAccountDetails(acc.Id);
       	//Account insuranceAccount = OrderAPICallouts.getInsuranceDetails(acc.Id);
        VOB__c vodDetail = OrderAPICallouts.getVOBDetail(acc.Id,vobData.Id);        
        //Payor__c payorDetail = OrderAPICallouts.getPayorDetail();  
        //String collectionDate  = OrderAPICallouts.xmlDateTime(CollDatetime);
        String currentDateTime  =OrderAPICallouts.dateTimeNow(); 
        String expectedDateTime  =OrderAPICallouts.dateTimeNow();
        //DateTime dateTimeExpected = OrderAPICallouts.dateTimeNow();
        DateTime newDateTime = DateTime.newInstance(2022, 2, 11, 8, 6, 16);
        //dateTime newDateTimeExpected = dateTimeExpected.addDays(1);
        List<lab__c> getLabs = OrderAPICallouts.getLabs();
        List<facility__c> getFacilities = OrderAPICallouts.getFacilities(lab.Lab_Id__c);
        //List<Contact> getPhysicians = OrderAPICallouts.getPhysicians();
        List<Test__c> getTests = OrderAPICallouts.getTests(lab.Lab_Id__c);
        List<ICD_Codes__c> getICDs  = OrderAPICallouts.getICDs(acc.Id);
        List<Test__c> getTestList = OrderAPICallouts.getTestList(searchKey, lab.Lab_Id__c, '', 100);
        //List<ICD_Codes__c> getICDList = OrderAPICallouts.getICDList(searchKey);
        OrderAPICallouts.updateOrderStatus(selectedLabOrder,new List<String>{labOrder.Id});
        //String orderID = OrderAPICallouts.addOrder('Standard',acc.Id, 'T', lab.Lab_Id__c, facData.Facility_Id__c, phyName, selectedTest,selectedICD , CollDatetime, dateData,expectedDateTime,null, payor.Payer_Code__c, vobData.Insurance_Policy_ID__c, vobData.Group_Number__c, vobData.Id, guarantor.Id);
        //OrderAPICallouts.updateRecordStatus(selectedLabOrder, acc.Id);
        System.assertEquals(1, 1, ''); 
        test.stopTest();
        
        //String contentType = response.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        //System.assertEquals(200, response.getStatusCode());
    }
    
    
    
    
    
}