trigger Paymentline on Payment_Line__c (after insert,after update,after delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
   /*  if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
         updateRelatedPaymentSchedule.updateMasterAndChildPaymentSchedule(Trigger.new);
     }*/
   // paymentLineHelper.opportunitycheck(Trigger.new);
   String virtualClassName = 'GlobalPaymentline';// Added in Review
   List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
   pluggableClass = [SELECT
                   DeveloperName,
                   Virtual_Class__c
                   FROM Elixir_Pluggable_Classes__mdt
                   WHERE DeveloperName='Paymentline' WITH SECURITY_ENFORCED];
   if(!pluggableClass.isEmpty()){
       virtualClassName = pluggableClass[0].Virtual_Class__c;
   }
   Type t = Type.forName(virtualClassName);
   GlobalPaymentline  paymentRelated= (GlobalPaymentline) t.newInstance(); 
   
   if(Trigger.isInsert && Trigger.isAfter){
    paymentRelated.afterInsert(trigger.new);
   }
   if(Trigger.isUpdate && Trigger.isAfter){
    paymentRelated.afterUpdate(trigger.new);
   }

}