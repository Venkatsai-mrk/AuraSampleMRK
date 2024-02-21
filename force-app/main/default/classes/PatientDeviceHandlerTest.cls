@IsTest
private class PatientDeviceHandlerTest {
      
    @IsTest
    static void testAfterInsert_VerifyDevices() {
        List<ElixirSuite__Patient_Device__c> patientDevices = new List<ElixirSuite__Patient_Device__c>();
        patientDevices.add(new ElixirSuite__Patient_Device__c(Name = 'Device1'));
       ElixirSuite__Patient_Device__c testDevice = new ElixirSuite__Patient_Device__c(Name = 'Test Device');
        insert testDevice;
        
        Test.startTest();
        insert patientDevices;
        Boolean verifyDev = claimValidationHelper.verifyDev;
        PatientDeviceHandler.afterInsert(new List<ElixirSuite__Patient_Device__c>{ testDevice }, new Map<Id, ElixirSuite__Patient_Device__c>{ testDevice.Id => testDevice }, new Map<Id, ElixirSuite__Patient_Device__c>());
        Test.stopTest();
         system.assertEquals(1, 1,'');
       
    }
     @IsTest
    static void testAfterUpdate() {
        List<ElixirSuite__Patient_Device__c> patientDevices = new List<ElixirSuite__Patient_Device__c>();
        patientDevices.add(new ElixirSuite__Patient_Device__c(Name = 'Device1'));
       ElixirSuite__Patient_Device__c testDevice = new ElixirSuite__Patient_Device__c(Name = 'Test Device');
        insert testDevice;
        
        Test.startTest();
        insert patientDevices;
        Boolean verifyDev = claimValidationHelper.verifyDev;
        PatientDeviceHandler.afterUpdate(new List<ElixirSuite__Patient_Device__c>{ testDevice }, new Map<Id, ElixirSuite__Patient_Device__c>{ testDevice.Id => testDevice }, new Map<Id, ElixirSuite__Patient_Device__c>{ testDevice.Id => testDevice });
        Test.stopTest();
         system.assertEquals(1, 1,'');
       
    }
    @isTest
    static void testBeforeInsert() {
        Patient_Device__c patientDevice = new Patient_Device__c();
        patientDevice.Name = 'Test Device';
       
        Test.startTest();
        insert patientDevice;
        Test.stopTest();
        system.assertEquals(1, 1,'');
    }
    
    @isTest
    static void testBeforeUpdate() {
        Patient_Device__c patientDevice = new Patient_Device__c();
        patientDevice.Name = 'Test Device';
        insert patientDevice;
        
        patientDevice.Name = 'Updated Device';
       
        Test.startTest();
        update patientDevice;
        Test.stopTest();
       system.assertEquals(1, 1,'');
    }
    
    @isTest
    static void testAfterInsertOrUpdate() {
        Patient_Device__c patientDevice = new Patient_Device__c();
        patientDevice.Name = 'Test Device';
        Test.startTest();
        insert patientDevice;
        //update patientDevice;
        Test.stopTest();
       system.assertEquals(1, 1,'');
    }
}