global with sharing virtual class GlobalOnCreateOrderHelper {
    
    global virtual void beforeInsert(List<Lab_Order__c> labOrderLst){
        onCreateOrder(labOrderLst);
    }
    global virtual void beforeUpdate(List<Lab_Order__c> labOrderLst){
        onCreateOrder(labOrderLst);
    }
    global virtual void onCreateOrder(List<Lab_Order__c> labOrderLst)
    {
        Set<String> testIds = new Set<String>();
        Set<String> facilityIds = new Set<String>();
        Set<String> labIds = new Set<String>();
       
        
        for(Lab_Order__c a : labOrderLst) {
            testIds.add(a.Test_Id__c);
            facilityIds.add(a.Facility_Id__c);
            labIds.add(a.Lab_Id__c);
        }
        
        List<Test__c> tests = [Select id, Test_Id__c, Test_Name__c,ElixirSuite__Loinc_Code__c  from Test__c where Test_Id__c IN:testIds WITH SECURITY_ENFORCED];
        Map<String,String> testMap = new Map<String,String>();
        Map<String,String> loincMap = new Map<String,String>();
        for(Test__c l : tests)
        {
            testMap.put(l.Test_Id__c, l.Test_Name__c);
            loincMap.put(l.Test_Id__c,l.ElixirSuite__Loinc_Code__c);
        }
        
        for(Lab_Order__c a : labOrderLst) {
            a.Test_Name__c = testMap.get(a.Test_Id__c);
            a.ElixirSuite__LOINC_Code__c=loincMap.get(a.Test_Id__c);
           
        }
        
        List<Facility__c> facility = [Select id, Name, Facility_Id__c from Facility__c where Facility_Id__c IN:facilityIds WITH SECURITY_ENFORCED];
        Map<String,String> facilityMap = new Map<String,String>();
        for(Facility__c fac : facility){
            facilityMap.put(fac.Facility_Id__c, fac.Name);
        }
        
        for(Lab_Order__c f:labOrderLst){
            f.Facility_Name__c   = facilityMap.get(f.Facility_Id__c);
        }
        
        List<Lab__c> labs = [Select id, Name, Lab_Id__c , ElixirSuite__Lab_Type__c from Lab__c where Lab_Id__c IN:labIds WITH SECURITY_ENFORCED];
        Map<String,String> labsMap = new Map<String,String>();
        Map<String, String> labTypeMap = new Map<String, String>();
        for(Lab__c lab : labs){
            labsMap.put(lab.Lab_Id__c, lab.Name);
            labTypeMap.put(lab.Lab_Id__c, lab.ElixirSuite__Lab_Type__c);
        } 
        
        for(Lab_Order__c f:labOrderLst){
            f.LabName__c   = labsMap.get(f.Lab_Id__c);
            f.ElixirSuite__Lab_Type__c =labTypeMap.get(f.Lab_Id__c);
        }
    }

    global virtual void afterInsert(List<Lab_Order__c> manualLabOrderList){
        ManualLabOrderTriggerHelper.createPatientProcedureOnInsert(manualLabOrderList);
    }
    global virtual void afterUpdate(List<Lab_Order__c> manualLabOrderList, Map<Id,Lab_Order__c> manualLabOrderOldMap){
        ManualLabOrderTriggerHelper.createPatientProcedureOnUpdate(manualLabOrderList,manualLabOrderOldMap);
    }
    
}