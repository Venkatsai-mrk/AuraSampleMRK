public  with sharing class ManualLabOrderTriggerHelper {
    
    public static void createPatientProcedure(List<Lab_Order__c> manualLabOrderList)
    {
        List<ElixirSuite__Procedure__c> manualLabOrderToInsert = new List<ElixirSuite__Procedure__c>();
        //List<String> procedureCodeIds = new List<string>();
        //To store the unique test ids for the incoming Lab orders
        Set<Id> testIds=new Set<Id>();
        for(Lab_Order__c manualLabOrder : manualLabOrderList)
        {
            //procedureCodeIds.add(manualLabOrder.ElixirSuite__Template_Test__c);
            testIds.add(manualLabOrder.ElixirSuite__Test__c);
        }
        Map<String,ElixirSuite__Procedure__c> templateProcedureMap = new Map<String,ElixirSuite__Procedure__c>([Select id ,name, ElixirSuite__Test__c,ElixirSuite__Type_of_Procedure__c from ElixirSuite__Procedure__c where ElixirSuite__Test__c In : testIds WITH SECURITY_ENFORCED]);
      //  ExceptionLog.logDebugString('templateProcedureMap: '+templateProcedureMap);
        
        
        List<ElixirSuite__Procedure__c> relatedProcedures = [SELECT Id, Name, ElixirSuite__Test__c, ElixirSuite__Type_of_Procedure__c
                                                             FROM ElixirSuite__Procedure__c
                                                             WHERE ElixirSuite__Test__c IN :testIds AND ElixirSuite__Type_of_Procedure__c !=null WITH SECURITY_ENFORCED];
        
        for(Lab_Order__c manualLabOrder : manualLabOrderList)  {
            String typeOfPayment;
            ElixirSuite__ERA_Generation__c mc = ElixirSuite__ERA_Generation__c.getOrgDefaults();
                            for (ElixirSuite__Procedure__c procedure : relatedProcedures)
                {
                    if (procedure.ElixirSuite__Test__c == manualLabOrder.ElixirSuite__Test__c){
            if(mc.ElixirSuite__Private_Payments__c && mc.ElixirSuite__Insurance_Payments__c){
            
            if(manualLabOrder.ElixirSuite__Bill_Type__c =='C' || manualLabOrder.ElixirSuite__Bill_Type__c =='P'){
              typeOfPayment='Private Payment';
            
            }
            else If (manualLabOrder.ElixirSuite__Bill_Type__c =='T'){
                typeOfPayment = 'Insurance Payment';
            }
            }
            else{
                typeOfPayment='Private Payment';
}
                    }
            
            Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
            
            ElixirSuite__Procedure__c objProcedure = new ElixirSuite__Procedure__c();

            objProcedure.Name = fetchProcedureName(manualLabOrder.ElixirSuite__Test__c,manualLabOrder.Name ); //code from template lab record --> name field
            
            
            objProcedure.ElixirSuite__Account__c = manualLabOrder.ElixirSuite__Account_Id__c;
            
            objProcedure.RecordTypeId = recordTypeId; // patient procedure recordtype
            
            objProcedure.ElixirSuite__Type_of_Procedure__c = typeOfPayment;
            
            objProcedure.ElixirSuite__From_Date_of_Service__c =  system.today();      // start date/time of lab  
            
            objProcedure.ElixirSuite__To_Date_of_Service__c =  system.today();        // end date/time of lab
            
            objProcedure.ElixirSuite__Is_Billable__c = true;
            
            objProcedure.ElixirSuite__Days_Units__c =1;
            
            manualLabOrderToInsert.add(objProcedure);
            
        }
}
        
        if(manualLabOrderToInsert.size() > 0)
        {
            DMLManager.insertAsUser(manualLabOrderToInsert);
        }
    }
    
    public static void createPatientProcedureOnInsert(List<Lab_Order__c> manualLabOrderList)
    {
        List<Lab_Order__c> labOrderList = new List<Lab_Order__c>();
        List<ElixirSuite__Elixir_Custom_Setting__c> elixirCustomSetting = new List<ElixirSuite__Elixir_Custom_Setting__c>();
        elixirCustomsetting = [select id,ElixirSuite__Lab_Order_Billing_On_Status__c from ElixirSuite__Elixir_Custom_Setting__c where ElixirSuite__Lab_Order_Billing_On_Status__c != null limit 1];
        String labOrderStatus = 'Final Order'; 
        
        if(elixirCustomsetting.size() > 0)
        {
            labOrderStatus=elixirCustomsetting[0].ElixirSuite__Lab_Order_Billing_On_Status__c;
        }
        for(Lab_Order__c manualLabOrder : manualLabOrderList)
        {
            if(manualLabOrder.ElixirSuite__Status__c ==labOrderStatus)
            {
                labOrderList.add(manualLabOrder);
            }
        }
        
    	if(labOrderList.size() > 0 )
        {
            createPatientProcedure(labOrderList);
        }
        
    }
    
    public static void createPatientProcedureOnUpdate(List<Lab_Order__c> manualLabOrderList, Map<Id,Lab_Order__c> manualLabOrderOldMap)
    {
        List<Lab_Order__c> labOrderList = new List<Lab_Order__c>();
        List<ElixirSuite__Elixir_Custom_Setting__c> elixirCustomSetting = new List<ElixirSuite__Elixir_Custom_Setting__c>();
        elixirCustomsetting = [select id,ElixirSuite__Lab_Order_Billing_On_Status__c from ElixirSuite__Elixir_Custom_Setting__c where ElixirSuite__Lab_Order_Billing_On_Status__c != null limit 1];
        String labOrderStatus = 'Final Order'; 
        
        if(elixirCustomsetting.size() > 0)
        {
            labOrderStatus=elixirCustomsetting[0].ElixirSuite__Lab_Order_Billing_On_Status__c;
        }
        for(Lab_Order__c manualLabOrder : manualLabOrderList)
        {
            if((manualLabOrderOldMap.get(manualLabOrder.id).ElixirSuite__Status__c != manualLabOrder.ElixirSuite__Status__c) && manualLabOrder.ElixirSuite__Status__c==labOrderStatus )
            {
                labOrderList.add(manualLabOrder);
            }
        }
    	if(labOrderList.size() > 0 )
        {
            createPatientProcedure(labOrderList);
        }
        
    }

    public static String fetchProcedureName(String testId,String labName){
        String procName = '';
        List<ElixirSuite__Procedure__c> listProc = [SELECT ID,Name FROM ElixirSuite__Procedure__c WHERE ElixirSuite__Test__c =: testId WITH SECURITY_ENFORCED];
        If(listProc != null && !listProc.isEmpty()){
            if(String.isNotBlank(labName)){
                procName = labName + ' , '+listProc[0].Name;
            }else{
                procName = listProc[0].Name;
            }
            return procName;
        }
        else{
            return '';
        }
    }
    

}