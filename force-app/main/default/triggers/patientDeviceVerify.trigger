trigger patientDeviceVerify on Patient_Device__c (before update, after update, after insert,before insert,before delete) {
    
    if(trigger.isAfter &&  trigger.isInsert){
        if(!claimValidationHelper.getVerifyDev1()){
            PatientDeviceHandler.afterInsert(trigger.new, trigger.newMap,trigger.oldMap);
        }
    }
    if(trigger.isAfter &&  trigger.isUpdate){
       if(!claimValidationHelper.getVerifyDev1()){
            PatientDeviceHandler.afterUpdate(trigger.new,trigger.newMap,trigger.oldMap);
        }  
    }
}