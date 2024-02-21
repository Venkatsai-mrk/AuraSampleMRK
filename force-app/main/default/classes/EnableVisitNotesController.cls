public with sharing class EnableVisitNotesController {
	@AuraEnabled
    public static Boolean getVisitNotes() {
        try{
            
            Id patientPortalId =Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
            
            List<ElixirSuite__Master_Object__c> record = new List<ElixirSuite__Master_Object__c>();
            
            record =[select id,ElixirSuite__Enable_Visit_Notes__c from ElixirSuite__Master_Object__c where recordtypeId =:patientPortalId and ElixirSuite__Patient_Tile_Entity__c='Visit Notes' WITH SECURITY_ENFORCED];
            
            if(record.size() > 0)
            {
                return record[0].ElixirSuite__Enable_Visit_Notes__c;
            }
            else
            {
                ElixirSuite__Master_Object__c masterRecord = new ElixirSuite__Master_Object__c();
                masterRecord.RecordTypeId = patientPortalId;
                masterRecord.ElixirSuite__Patient_Tile_Entity__c='Visit Notes';
                masterRecord.ElixirSuite__Enable_Visit_Notes__c=true;
                DMLManager.insertAsUser(masterRecord);
               // insert masterRecord;
                
                
                return true;
            }
        }
        catch (Exception e) {
            ExceptionLog.logError(e);
            return null;
        }
    }
    @AuraEnabled
    public static void updateMasterRecord(Boolean enableVisitNotesValue) {
     try {
            Id patientPortalId =Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
            
            List<ElixirSuite__Master_Object__c> record =new List<ElixirSuite__Master_Object__c>();
            record =[select id,ElixirSuite__Enable_Visit_Notes__c from ElixirSuite__Master_Object__c where recordtypeId=:patientPortalId and ElixirSuite__Patient_Tile_Entity__c='Visit Notes' WITH SECURITY_ENFORCED LIMIT 1];
            if(record.size() > 0)
            {
                record[0].ElixirSuite__Enable_Visit_Notes__c = enableVisitNotesValue;
                //DMLManager.updateAsUser(record[0]); 
                update record[0];
            }
            
        }
        catch (Exception e) {
            ExceptionLog.logError(e);
        }
}
}