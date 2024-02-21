public with sharing class AutoNextAvailSlotGeneration implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new NextAvailSlotHandler());
    }
    
    public static void autoSlots(){
        Set<String> juncPracLst = new Set<String>();
        Set<String> juncLocLst = new Set<String>();
        try{
            List<ElixirSuite__UserLocation__c> juncLst = [SELECT Id, Name, ElixirSuite__Practitioner__c, 
                                                          ElixirSuite__Provider__c, ElixirSuite__Next_available_slot__c 
                                                          FROM ElixirSuite__UserLocation__c
                                                          WHERE (ElixirSuite__Next_available_slot__c != ''
                                                                 AND ElixirSuite__Next_available_slot__c != 'No Slots')
                                                          WITH SECURITY_ENFORCED];
            
            for(ElixirSuite__UserLocation__c juncRec : juncLst){
                juncPracLst.add(String.valueof(juncRec.ElixirSuite__Practitioner__c));
                juncLocLst.add(String.valueof(juncRec.ElixirSuite__Provider__c));
            }
            
            Date startDate1 = system.today();
            List<String> pracStrings = new List<String>(juncPracLst);
            List<String> locStrings = new List<String>(juncLocLst);
            
            Elixir_Utility.Wrapper3 appointmentTyp1 = Elixir_Utility.getBulkAppointmentType(pracStrings,locStrings,startDate1);
            Map<String,String> pracLocVsAppTyp = appointmentTyp1.pracLocVsAptTyp;
            List<String> appTypLst = appointmentTyp1.appTypLstWrp;
            
            Map<String,String> pracMap = new Map<String,String>();
            pracMap = Elixir_Utility.bulkWorkslot(pracStrings,locStrings,startDate1,appTypLst,pracLocVsAppTyp);
            
            for(ElixirSuite__UserLocation__c juncRec : juncLst){
                String finalKey = String.valueof(juncRec.ElixirSuite__Practitioner__c) + String.valueof(juncRec.ElixirSuite__Provider__c);
                if(String.isNotBlank(pracMap.get(finalKey)) && String.isNotEmpty(pracMap.get(finalKey))){
                    juncRec.ElixirSuite__Next_available_slot__c = pracMap.get(finalKey);
                }
                else{
                    juncRec.ElixirSuite__Next_available_slot__c = 'No Slots';
                }
            }
            
            DMLManager.updateAsUser(juncLst);
            
        }
        
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
}