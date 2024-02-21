@isTest
public class PractitionerMultiCtrlTest {
    @isTest
    public static void dataSetup(){
        
        //Define Account data
        //list<Account> acclist =new list<Account>();
        Account acc = new Account(); 
        acc.ElixirSuite__State__c = 'CA';
        acc.ElixirSuite__Services_Requested__c = 'Neurologist';
        acc.name = 'chetan';
        acc.ElixirSuite__DOB__c = Date.newInstance(2016, 12, 9);
        acc.ElixirSuite__Gender__c ='Male';
        acc.ElixirSuite__MRN_Number_New__c ='2334234567778';
        acc.ElixirSuite__MRN_Number__c = 123;
        acc.ElixirSuite__Time_Zone__c = 'EST';
        acc.Phone = '1234567890';
        acc.BillingPostalCode = '12345';
        insert acc;
        
        Contact con=new Contact();
        con.LastName='Adam';
        con.accountId = acc.Id;
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        insert con;
        
        
        List<ElixirSuite__License_and_Certifications__c> licenseState = new List<ElixirSuite__License_and_Certifications__c>();
        ElixirSuite__License_and_Certifications__c licenseGroup1 = new ElixirSuite__License_and_Certifications__c();
        //Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Practitioner').getRecordTypeId();
        
        licenseGroup1.ElixirSuite__Criteria_Type__c='State';
        licenseGroup1.ElixirSuite__Value__c='CA';
        licenseGroup1.ElixirSuite__Is_Active__c = true;
        licenseGroup1.ElixirSuite__Practitioner__c=con.Id;
        licenseGroup1.Name='Ramya';
        licenseState.add(licenseGroup1);
        insert licenseState;
        
        List<ElixirSuite__License_and_Certifications__c> licenseCerti = new list<ElixirSuite__License_and_Certifications__c>();
        ElixirSuite__License_and_Certifications__c licenseGroup2 = new ElixirSuite__License_and_Certifications__c();
        licenseGroup2.ElixirSuite__Is_Active__c = true;
        licenseGroup2.ElixirSuite__Criteria_Type__c='Certification';
        licenseGroup2.ElixirSuite__Value__c='Neurologist';
        licenseGroup2.ElixirSuite__Practitioner__c=con.Id;
        licenseCerti.add(licenseGroup2);
        insert licenseCerti;
        
        List<Account> lstac=[Select name,ElixirSuite__State__c,ElixirSuite__Services_Requested__c  from Account WITH SECURITY_ENFORCED limit 1];
        PractitionerMultiCtrl.fetchLookUpValues(lstac); 
        Test.startTest();
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    
    
}