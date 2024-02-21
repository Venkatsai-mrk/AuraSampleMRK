public with sharing class updateRelatedMasterSchedule {
    public static void updateMasterPaymentSchedule(List<ElixirSuite__Payment_Schedule__c> currentPayment , map<id,ElixirSuite__Payment_Schedule__c> oldValue){
        Set<Id> relatedChildPaymentScheduleRecIdSet = new Set<Id>();
        for(ElixirSuite__Payment_Schedule__c paymentRec : currentPayment){    
            
            ElixirSuite__Payment_Schedule__c oldschedule = oldValue.get(paymentRec.id);
            if(paymentRec.ElixirSuite__Total_payment_Made_formula__c != oldschedule.ElixirSuite__Total_payment_Made_formula__c){
                if(paymentRec.ElixirSuite__Payment_Schedule__c != Null){
                    relatedChildPaymentScheduleRecIdSet.add(paymentRec.ElixirSuite__Payment_Schedule__c);
                }
            }
        }
        List<ElixirSuite__Payment_Schedule__c> masterRec = new List<ElixirSuite__Payment_Schedule__c>();
        
        if(relatedChildPaymentScheduleRecIdSet.size()>0){
            for(AggregateResult aRes : [SELECT ElixirSuite__Payment_Schedule__c, SUM(ElixirSuite__Total_Payment_Made1__c) Total 
                                        FROM ElixirSuite__Payment_Schedule__c 
                                        WHERE ElixirSuite__Payment_Schedule__c IN :relatedChildPaymentScheduleRecIdSet 
                                        WITH SECURITY_ENFORCED
                                        GROUP BY ElixirSuite__Payment_Schedule__c]) {
                masterRec.add(new ElixirSuite__Payment_Schedule__c(Id = (Id)aRes.get('ElixirSuite__Payment_Schedule__c'), ElixirSuite__Total_Amount_Paid__c = (Decimal)aRes.get('Total')));
            }
            try{
                if(Schema.sObjectType.ElixirSuite__Payment_Schedule__c.fields.ElixirSuite__Total_Amount_Paid__c.isUpdateable()){
                update masterRec;
                }
            }
            catch(DmlException de){
                System.debug(de);
            }
           catch(Exception e){
            ExceptionLog.logError(e);
        } 
        }
    }
}