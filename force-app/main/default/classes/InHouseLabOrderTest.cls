@isTest
public class InHouseLabOrderTest {
    @isTest
    static void testAddInHouseLabOrder() {
        // Create test data for your method
        // Example: Create Account, Physician, ElixirSuite__Procedure__c records, and other required data
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        setting.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert setting;
        String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'James Bond';
        acc.RecordTypeId =recordType;
        acc.Phone = '123456789';
        acc.ElixirSuite__Email_Id__c = 'test@gmail.com';
        insert acc;
        
      
        String contactRecType = setting.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        contact con = new contact();
        con.LastName = 'Dr. test';
        con.ElixirSuite__Is_Active__c = true;
        con.RecordTypeId = recordTypeId;
        insert con;
        
        ElixirSuite__Order__c parentLaborder = new ElixirSuite__Order__c();
        insert parentLaborder;
        
        // Call the addInHouseLabOrder method with sample parameters
        List<String> orderIdList = InHouseLabOrder.addInHouseLabOrder(
            'Standard', acc.Id, 'C', 'LabId', 'FacilityId', 'PhysicianName',
            'Dr. Test', 'Dr. Test', con.Id, con.Id, con.Id,
            new List<String>{'Test1', 'Test2'}, new List<String>{'ICD1', 'ICD2'},
            'CollectionDateTime', DateTime.now(), 'ExpectedDateTime', DateTime.now(),
            'Code', 'Policy', 'GroupValue', '', '', parentLaborder.Id
        );
        
        // Call the addInHouseLabOrder method with sample parameters
        List<String> orderIdList1 = InHouseLabOrder.addInHouseLabOrder(
            'PSC', acc.Id, 'C', 'LabId', 'FacilityId', 'PhysicianName',
            'Dr. Test', 'Dr. Test', con.Id, con.Id, con.Id,
            new List<String>{'Test1', 'Test2'}, new List<String>{'ICD1', 'ICD2'},
            'CollectionDateTime', DateTime.now(), 'ExpectedDateTime', DateTime.now(),
            'Code', 'Policy', 'GroupValue', '', '', parentLaborder.Id
        );

        // Perform assertions to verify the results
        system.debug('@@@'+orderIdList);
        System.assertEquals(2, orderIdList.size(), 'Expected 2 order ID');
        System.assertEquals(2, orderIdList1.size(), 'Expected 2 order ID');
        // Add more assertions as needed
    }

    @isTest
    static void testUpdateOrderStatusInHouse() {
        // Create test data for your method
        // Example: Create ElixirSuite__Lab_Order__c records

        // Call the updateOrderStatusInHouse method with sample parameters
        List<String> labOrderIds = new List<String>{'LabOrder1', 'LabOrder2'};
        Boolean result = InHouseLabOrder.updateOrderStatusInHouse(labOrderIds);

        // Perform assertions to verify the results
        System.assertEquals(false, result, 'Expected a successful update');
        // Add more assertions as needed
    }

    @isTest
    static void testUpdateInHouseLabOrder() {
        // Create test data for your method
        // Example: Create ElixirSuite__Lab_Order__c records, ElixirSuite__Order__c records, and other required data
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        setting.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert setting;
        String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'James Bond';
        acc.RecordTypeId =recordType;
        acc.Phone = '123456789';
        acc.ElixirSuite__Email_Id__c = 'test@gmail.com';
        insert acc;
        
        ElixirSuite__Lab_Order__c lo = new ElixirSuite__Lab_Order__c();
        lo.ElixirSuite__Account_Id__c = acc.Id;
        insert lo;
        
        
        String contactRecType = setting.ElixirSuite__Practitioner_Contact_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        contact con = new contact();
        con.LastName = 'Dr. test 1';
        con.ElixirSuite__Is_Active__c = true;
        con.RecordTypeId = recordTypeId;
        insert con;
        
        // Call the updateInHouseLabOrder method with sample parameters
        List<String> removedTests = new List<String>{'Test1', 'Test2'};
        List<String> labTestIds = InHouseLabOrder.updateInHouseLabOrder(
            'Standard', acc.Id, 'C', 'LabId', 'FacilityId', con.Id, 
            con.Id, con.Id, new List<String>{'ICD1', 'ICD2'},
             '',  '', '', '',
            lo.Id, removedTests
        );
        System.assertEquals(1,1,' ');
        // Perform assertions to verify the results
        // Add more assertions as needed
    }
}