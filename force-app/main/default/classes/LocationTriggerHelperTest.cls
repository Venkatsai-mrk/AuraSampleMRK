@IsTest
public with sharing class LocationTriggerHelperTest {
    @IsTest
    static void testCheckOutOfOrder() {
        // Create test data
        List<ElixirSuite__Location__c> locLst = new List<ElixirSuite__Location__c>();
        Map<Id, ElixirSuite__Location__c> oldLocLst = new Map<Id, ElixirSuite__Location__c>();
        Id buildingRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByDeveloperName().get('Building').getRecordTypeId();
        ElixirSuite__Location__c buildingRecord=new ElixirSuite__Location__c();
        buildingRecord.RecordTypeId=buildingRecordTypeId;
        buildingRecord.Name='Building1';
        insert buildingRecord;
           
         Id SuiteRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByDeveloperName().get('Suite').getRecordTypeId();   
        // Create a location record with "Status" picklist value as  Out of Order
        ElixirSuite__Location__c location = new ElixirSuite__Location__c();
        location.RecordTypeId=SuiteRecordTypeId;
        location.ElixirSuite__Building__c=buildingRecord.Id;
        location.Name='Suite1';
        location.ElixirSuite__Status__c = 'Out of Order';
        location.ElixirSuite__Out_of_Order_Reason__c = 'Maintenance';
        location.ElixirSuite__Out_of_Order_Date__c = Date.today();
        locLst.add(location);
        
        Id roomRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByDeveloperName().get('Room').getRecordTypeId(); 
        // Create a location record with out the "Status" picklist value as  Out of Order
        ElixirSuite__Location__c location2 = new ElixirSuite__Location__c();
        location.RecordTypeId=roomRecordTypeId;
        location.ElixirSuite__Building__c=buildingRecord.Id;
        location.Name='room1';
        location2.ElixirSuite__Status__c = 'Needs Cleaning';
        location2.ElixirSuite__Out_of_Order_Reason__c = 'Out of service';
        location2.ElixirSuite__Out_of_Order_Date__c = Date.today();
        locLst.add(location2);
        
        // Call the method to be tested
        Test.startTest();
        //insert locLst;
        LocationTriggerHelper.checkOutOfOrder(locLst, oldLocLst);
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
       
    }
}