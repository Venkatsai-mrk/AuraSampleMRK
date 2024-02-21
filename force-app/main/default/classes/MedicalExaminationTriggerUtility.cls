public with sharing class MedicalExaminationTriggerUtility {
    private static boolean run = true;
    public static void populateRecordType(List<ElixirSuite__Medical_Examination__c> recordsToUpdate){     
        for(ElixirSuite__Medical_Examination__c sObj : recordsToUpdate){
            if(String.isNotBlank(sobj.RecordTypeId)){           
                sObj.ElixirSuite__Type__c = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosById().get(sobj.RecordTypeId).getName();
            } 
        }
    }
    public static void preventEndDateLessThanStartDate(List<ElixirSuite__Medical_Examination__c> records){  
        for(ElixirSuite__Medical_Examination__c sObj : records){
            if(sObj.ElixirSuite__End_Time__c <= sObj.ElixirSuite__Start_Time__c){
                sObj.ElixirSuite__End_Time__c = sObj.ElixirSuite__Start_Time__c.addMinutes(1);
            }
            
        }
    }
    public static void populateVitalUnits(List<ElixirSuite__Medical_Examination__c> recordsForUnits){ 
        try{
        for(ElixirSuite__Medical_Examination__c sObj : recordsForUnits){
            if(String.isNotBlank(sObj.Respiration__c)){
                if(!sObj.Respiration__c.contains('Breaths/Minute')){
                    sObj.Respiration__c = sObj.Respiration__c+' Breaths/Minute';
                }
            }
            if(String.isNotBlank(sObj.Oxygen_Saturation__c)){
                if(!sObj.Oxygen_Saturation__c.contains('%')){
                    sObj.Oxygen_Saturation__c = sObj.Oxygen_Saturation__c+' %';
                }
            }
            if(String.isNotBlank(sObj.Blood_Pressure_diasystolic__c)){
                if(!sObj.Blood_Pressure_diasystolic__c.contains('mmHg')){
                    sObj.Blood_Pressure_diasystolic__c = sObj.Blood_Pressure_diasystolic__c+' mmHg';
                }
            }
            if(String.isNotBlank(sObj.Blood_Pressure_Systolic__c)){
                if(!sObj.Blood_Pressure_Systolic__c.contains('mmHg')){
                    sObj.Blood_Pressure_Systolic__c = sObj.Blood_Pressure_Systolic__c+' mmHg';
                }
            }
            if(String.isNotBlank(sObj.Temperature__c)){
                if(!sObj.Temperature__c.contains('F*')){
                    sObj.Temperature__c = sObj.Temperature__c+' F*';
                }
            }
            if(String.isNotBlank(sObj.Pulse__c)){
                if(!sObj.Pulse__c.contains('BPM')){
                    sObj.Pulse__c = sObj.Pulse__c+' BPM';
                }
            }
            
        }
    }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
        
}