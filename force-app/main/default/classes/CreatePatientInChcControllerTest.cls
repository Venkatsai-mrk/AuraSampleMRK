@isTest
private class CreatePatientInChcControllerTest {
    @isTest static void testCreatePatientInChcController() {
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        insert setting;
        String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.RecordTypeId = recordTypeId;
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.DOB__c = system.today();
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        insert patient;
        List<Id> idList = new List<Id>();
        idList.add(patient.Id);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ChcMockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String xmlString = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<root>' +
            '  <element>Element 1</element>' +
            '  <element>Element 2</element>' +
            '</root>';
        test.startTest();
        HttpResponse res = CreatePatientInChcController.makeHTTPXMLPost(xmlString);
        CreatePatientInChcController.retrieveFromXMLDom(res, xmlString);
        //CreatePatientInChcController.getCredentials();
        CreatePatientInChcController.getHsiLabel();
        CreatePatientInChcController.createPatientInChc(idList);
        test.stopTest();
        
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'text/xml');
        String actualValue = res.getBody();
        String expectedValue = '<response><message>Success!</message></response>';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }
}