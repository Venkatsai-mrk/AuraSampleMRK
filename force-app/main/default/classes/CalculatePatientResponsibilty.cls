public with sharing class CalculatePatientResponsibilty {
    
    public static void calculateResponsibiltyAmt(List<Payment_Transaction__c> paymentTxnRecords) {
        
        Set<Id> patientAccIdSet = new Set<Id>();
        for(Payment_Transaction__c paymentTxn : paymentTxnRecords) {
            if(paymentTxn.Account__c != null) {
                patientAccIdSet.add(paymentTxn.Account__c);
            }
        }
        
        if(patientAccIdSet.size() > 0) {
            List<Payment_Transaction__c> paymentTxnList = [Select Patient_Responsibility__c, Account__c 
            FROM Payment_Transaction__c WHERE Account__c IN :patientAccIdSet
            WITH SECURITY_ENFORCED];
            
            Map<Id, Decimal> patientAccIdToPatientRespMap = new Map<Id, Decimal>();
            
            for(Payment_Transaction__c paymentTxnRec : paymentTxnList) {
                if(paymentTxnRec.Account__c != null) {
                    if(patientAccIdToPatientRespMap.containsKey(paymentTxnRec.Account__c)) {
                        Decimal patientResp = patientAccIdToPatientRespMap.get(paymentTxnRec.Account__c);
                        System.debug(paymentTxnRec.Patient_Responsibility__c);
                        if(paymentTxnRec.Patient_Responsibility__c == null) {
                            paymentTxnRec.Patient_Responsibility__c = 0;
                        }
                        patientResp = patientResp + paymentTxnRec.Patient_Responsibility__c;
                        patientAccIdToPatientRespMap.put(paymentTxnRec.Account__c, patientResp);
                    } else {
                        if(paymentTxnRec.Patient_Responsibility__c == null) {
                            paymentTxnRec.Patient_Responsibility__c = 0;
                        }
                        patientAccIdToPatientRespMap.put(paymentTxnRec.Account__c, paymentTxnRec.Patient_Responsibility__c); 
                    }
                }
                
            }
            
            List<Account> patientAccList = [Select Total_Patient_Responsibility__c FROM Account
             WHERE ID IN :patientAccIdSet WITH SECURITY_ENFORCED];//
            
            for(Account patientAccRec : patientAccList) {
                if(patientAccIdToPatientRespMap.containsKey(patientAccRec.Id)) {
                    patientAccRec.Total_Patient_Responsibility__c = patientAccIdToPatientRespMap.get(patientAccRec.Id);
                }
            }
            if(patientAccList.size() > 0){
            try{
                if(Schema.sObjectType.Form_Value__c.isUpdateable() &&
                Schema.sObjectType.Account.fields.Total_Patient_Responsibility__c.isUpdateable()){
                update patientAccList;
                }
            } catch(Exception ex) {
                System.debug('Exception ****'+ex.getMessage());
            }
        }
            
        }
        
    }
}