public with sharing class CreatePaymentTransaction {    
    public static void updateCharges(List<Procedure__c> procedureList,Map<Id,Procedure__c> oldmap,Boolean isInsert, Boolean isUpdate){
        Set<Id> patientAccIdSet = new Set<Id>();
        List<Procedure__c> filteredProcedures = new List<Procedure__c>();  
        List<Procedure__c> procCareRecIds = new List<Procedure__c>();
        try{
        for(Procedure__c procedureRec : procedureList){  
            
            if(procedureRec.Account__c != null && procedureRec.RecordType.DeveloperName != 'Template_Procedure'){            
                patientAccIdSet.add(procedureRec.Account__c); 
                filteredProcedures.add(procedureRec);
            }
            if(procedureRec.Account__c != null && procedureRec.RecordType.DeveloperName != 'Template_Procedure' && procedureRec.ElixirSuite__Visits__c != null){
                procCareRecIds.add(procedureRec);
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        if(isInsert){
       CreatePaymentTransactionHelper.updateCharges(patientAccIdSet, filteredProcedures,null, isInsert,  isUpdate);
       CreatePaymentTransactionHelper.afterInsertAttachProvider(procCareRecIds);
        }else if(isUpdate){
            CreatePaymentTransactionHelper.updateCharges(patientAccIdSet, filteredProcedures, oldmap, isInsert,  isUpdate);
        }
    }
   
    public static void afterProcedureInsertCharges(List<Procedure__c> procedureList){
        Set<Id> patientAccIdSet = new Set<Id>();
        Set<Id> procedureRecIds = new Set<Id>();
        List<Procedure__c> filteredProcedures = new List<Procedure__c>();  
        try{
        for(Procedure__c procedureRec : procedureList){  
            
            if(procedureRec.Account__c != null && procedureRec.RecordType.DeveloperName != 'Template_Procedure'){  
                procedureRecIds.add(procedureRec.Id);
                patientAccIdSet.add(procedureRec.Account__c); 
                filteredProcedures.add(procedureRec);
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        CreatePaymentTransactionHelper.afterInsert(patientAccIdSet, filteredProcedures);
    }
    public static void afterProcedureupdation(List<Procedure__c> procedureList){
        Set<Id> patientAccIdSet = new Set<Id>();
        Set<Id> procedureRecIds = new Set<Id>();
        List<Procedure__c> filteredProcedures = new List<Procedure__c>();  
        try{
        for(Procedure__c procedureRec : procedureList){  
            
            if(procedureRec.Account__c != null && procedureRec.RecordType.DeveloperName != 'Template_Procedure'){  
                procedureRecIds.add(procedureRec.Id);
                patientAccIdSet.add(procedureRec.Account__c); 
                filteredProcedures.add(procedureRec);
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        CreatePaymentTransactionHelper.afterUpdate(patientAccIdSet, filteredProcedures,procedureRecIds);
    }
   
}