public class deviceIdVerificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

 

    public Database.QueryLocator start(Database.BatchableContext context) {
        return null;
    }

    public void execute(Database.BatchableContext context, List<ElixirSuite__Patient_Device__c> scope) {

 

    }

    public void finish(Database.BatchableContext context) {
    }

    public static void verifyDeviceid(List<ElixirSuite__Patient_Device__c> patientDevices) {
    }
    }