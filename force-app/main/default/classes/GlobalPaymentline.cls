Global with sharing virtual class GlobalPaymentline {
    global virtual void afterInsert(List<Payment_Line__c> paymentRecords){
     updateRelatedPaymentSchedule.updateMasterAndChildPaymentSchedule(paymentRecords);
    }
    global virtual void afterUpdate(List<Payment_Line__c> paymentRecordsLst){
        updateRelatedPaymentSchedule.updateMasterAndChildPaymentSchedule(paymentRecordsLst);
       }
}