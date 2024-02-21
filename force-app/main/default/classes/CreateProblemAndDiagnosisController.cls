public with sharing class CreateProblemAndDiagnosisController {
    @AuraEnabled
    public static String patientDiagnosisAndProblemType(String recordId){
        String objectName = '';
        Id recordId2 = recordId;
        SObjectType objectType = recordId2.getSObjectType();
        String objTypeStr = String.valueOf(objectType);
        if(objTypeStr == 'ElixirSuite__ICD_Codes__c'){
            objectName = objTypeStr;
        }
        else if(objTypeStr == 'ElixirSuite__Dataset1__c'){
            objectName = objTypeStr;
        }   
        system.debug(objectName);
        return objectName;
    }
    @AuraEnabled
    public static String getCareEpisodeId(String recordId) {
        try {
            
            Id myId = recordId;
            String objectName = myId.getSObjectType().getDescribe().getName();
            if(objectName == 'ElixirSuite__ICD_Codes__c'){
                ElixirSuite__ICD_Codes__c  diagnosisLst = [
                    SELECT
                        Id, ElixirSuite__Account__c, 
                        ElixirSuite__Account__r.Name, 
                        ElixirSuite__Care_Episode__c, 
                        ElixirSuite__Care_Episode__r.Name
                    FROM
                    ElixirSuite__ICD_Codes__c 
                    WHERE
                        ID = :recordId
                    WITH SECURITY_ENFORCED];
            
                if (diagnosisLst != null && diagnosisLst.ElixirSuite__Care_Episode__c!=null) {
                    return diagnosisLst.ElixirSuite__Care_Episode__c;
                }
               
            }
            else if(objectName == 'ElixirSuite__Dataset1__c'){
                ElixirSuite__Dataset1__c  patientProblemsLst = [
                    SELECT
                        Id, ElixirSuite__Account__c, 
                        ElixirSuite__Account__r.Name, 
                        ElixirSuite__Care_Episode__c, 
                        ElixirSuite__Care_Episode__r.Name
                    FROM
                        ElixirSuite__Dataset1__c 
                    WHERE
                        ID = :recordId
                    WITH SECURITY_ENFORCED];
            
                if (patientProblemsLst != null && patientProblemsLst.ElixirSuite__Care_Episode__c!=null) {
                    return patientProblemsLst.ElixirSuite__Care_Episode__c;
                }
            } 
            

            return '';   
        } catch (Exception e) {
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String getAccountId(String recordId) {
        try {
            Id myId = recordId;
            String objectName = myId.getSObjectType().getDescribe().getName();
            if(objectName == 'ElixirSuite__ICD_Codes__c'){
                ElixirSuite__ICD_Codes__c  diagnosisLst = [
                    SELECT
                        Id, ElixirSuite__Account__c, 
                        ElixirSuite__Account__r.Name, 
                        ElixirSuite__Care_Episode__c, 
                        ElixirSuite__Care_Episode__r.Name
                    FROM
                    ElixirSuite__ICD_Codes__c 
                    WHERE
                        ID = :recordId
                    WITH SECURITY_ENFORCED];
            
                    if (diagnosisLst != null && diagnosisLst.ElixirSuite__Account__c!=null) {
                        return diagnosisLst.ElixirSuite__Account__c;
                    }
               
            }
            else if(objectName == 'ElixirSuite__Dataset1__c'){
                ElixirSuite__Dataset1__c  patientProblemsLst = [
                    SELECT
                        Id, ElixirSuite__Account__c, 
                        ElixirSuite__Account__r.Name, 
                        ElixirSuite__Care_Episode__c, 
                        ElixirSuite__Care_Episode__r.Name
                    FROM
                        ElixirSuite__Dataset1__c 
                    WHERE
                        ID = :recordId
                    WITH SECURITY_ENFORCED];
            
                    if (patientProblemsLst != null && patientProblemsLst.ElixirSuite__Account__c!=null) {
                        return patientProblemsLst.ElixirSuite__Account__c;
                    }
            } 
        
            return '';   
        } catch (Exception e) {
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}