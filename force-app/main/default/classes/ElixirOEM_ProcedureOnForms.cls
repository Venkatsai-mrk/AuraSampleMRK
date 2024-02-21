/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ElixirOEM_ProcedureOnForms {
    public static void procedureDataOnForm(String payload,String accountId){ 
        Map<String, Object> mapOfPayload = (Map<String, Object>) JSON.deserializeUntyped(payload);
        List<object> lstOfPayload = ( List<object> ) mapOfPayload.get('updatedProcedure'); 
        deleteProcedureRecords(( List<object> ) mapOfPayload.get('toDelProcRecords')); 
        for(Object rec : lstOfPayload){ 
            Map<String, Object> mapOfData = (Map<String, Object>) rec;
            UpdateProcedureHandler.updateProcedure(String.valueOf(mapOfData.get('payload')),accountId,String.valueOf(mapOfData.get('diagnosisData')),String.valueOf(mapOfData.get('modifierData')),String.valueOf(mapOfData.get('procedureId')),String.valueOf(mapOfData.get('deletediagnosisData')));            
        }            
    }
    public static void deleteProcedureRecords(Object[] toDelRecords){ 
        String[] procedureRecordsLst = new List<String>();
        for(Object rec : toDelRecords){
            procedureRecordsLst.add(String.valueOf(rec));
        }
        System.debug('procedureRecordsLst '+procedureRecordsLst);
        delete[SELECT ID FROM ElixirSuite__Procedure__c WHERE ID IN : procedureRecordsLst WITH SECURITY_ENFORCED];
    }
}