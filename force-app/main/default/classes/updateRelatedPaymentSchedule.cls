/*
 * BY Meghna
 */
public with sharing class updateRelatedPaymentSchedule {
    public static void updateMasterAndChildPaymentSchedule(List<Payment_Line__c> currentPayment){
        Set<Id> relatedPaymentScheduleRecIdSet = new Set<Id>();
        Set<Id> masterPaymentScheduleRecIdSet = new Set<Id>();
        
        // updating child payment schedules
        for(Payment_Line__c paymentRec : currentPayment){    
            if(paymentRec.ElixirSuite__Payment_Schedule__c != Null){
                relatedPaymentScheduleRecIdSet.add(paymentRec.ElixirSuite__Payment_Schedule__c);
            }
        }
        List<Payment_Schedule__c> childSchedules = [Select id, name,ElixirSuite__Last_Payment_Amount__c,ElixirSuite__Last_Payment_Made__c,
                                                                 ElixirSuite__Balance_Due1__c , ElixirSuite__Payment_Status__c,ElixirSuite__Payment_Schedule__c ,
                                                                 ElixirSuite__Total_payment_Made_formula__c
                                                                 from ElixirSuite__Payment_Schedule__c 
                                                                 WHERE id IN :relatedPaymentScheduleRecIdSet 
                                                                 WITH SECURITY_ENFORCED LIMIT 9999];
    
         Map<Id,ElixirSuite__Payment_Schedule__c> childScheduletoUpdate = new Map<Id,ElixirSuite__Payment_Schedule__c>(childSchedules);
            for(Payment_Line__c paymentRec : currentPayment){
                 if(childScheduletoUpdate.containsKey(paymentRec.ElixirSuite__Payment_Schedule__c)){
                     ElixirSuite__Payment_Schedule__c paySch = childScheduletoUpdate.get(paymentRec.ElixirSuite__Payment_Schedule__c);
                     paySch.ElixirSuite__Last_Payment_Amount__c = paymentRec.ElixirSuite__Payment_Amount__c;
                     paySch.ElixirSuite__Last_Payment_Made__c = paymentRec.ElixirSuite__Payment_Date__c ;
                }
            }
        try{
            if(Schema.sObjectType.ElixirSuite__Payment_Schedule__c.fields.ElixirSuite__Last_Payment_Amount__c.isUpdateable() &&
            Schema.sObjectType.ElixirSuite__Payment_Schedule__c.fields.ElixirSuite__Last_Payment_Made__c.isUpdateable()){
            update childScheduletoUpdate.values();
            }
        }
        //
        catch(Exception e){
           ExceptionLog.logError(e);
        }
    }
}