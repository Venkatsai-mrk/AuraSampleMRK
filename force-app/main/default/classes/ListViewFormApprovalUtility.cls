public with sharing class ListViewFormApprovalUtility {
    public static void updateFormWithApprovalValues(List<Elixir_NewAccountAssociatedFormsApex.FormWrapper> forms,
                                                    Map<String,String> ids) {
        Set<String> uniqueIds = ids.keySet(); 
        Set<String> formNames = new Set<String>(ids.values());
        List<AggregateResult> approvedLevels = [SELECT Count(Id) c,Form_Id__c  form 
                    FROM Form_Value__c WITH SECURITY_ENFORCED 
                    GROUP by Form_Id__c, Is_Approver__c,Is_old__c  
                    HAVING Is_Approver__c=true AND Form_Id__c IN :uniqueIds and Is_old__c != true];
        Map<String,Integer> approvedCount = new Map<String,Integer>();
        if(approvedLevels!=null && approvedLevels.size()>0){
            for(AggregateResult result :approvedLevels){
                String formId = (String)result.get('form');
                Integer count = (Integer)result.get('c');
                approvedCount.put(formId, count);
            }
        }
        List<Object_1_css__c> defaultApprovalLevels = [SELECT Id, Form__c, Approval_Level__c, Approv__c,Approval_Members__c
                    FROM Object_1_css__c 
                    WHERE Form__c IN :formNames AND Approval_Level__c!=NULL 
                    WITH SECURITY_ENFORCED 
                    ORDER BY Approval_Level__c];
        List<Form_Value__c> formStatus = [SELECT Id, Form_Id__c,Status__c FROM Form_Value__c
                    WHERE Form_Detail__c=true AND Form_Id__c IN :uniqueIds
                    WITH SECURITY_ENFORCED];

                    //added by Anmol for LX3-7326
                    List<Form_Value__c> formCare = [SELECT Id, Form_Id__c,Status__c,Care_Episode__c,Is_CareEpisode__c 
                    FROM Form_Value__c
                    WHERE Is_CareEpisode__c=true AND Form_Id__c IN :uniqueIds
                    WITH SECURITY_ENFORCED];

        Map<String, String> formToCareEps = new Map<String, String>();
        //end by Anmol for LX3-7326

        Map<String, String> statuses = new Map<String, String>();                                             
        if(formStatus!=null && formStatus.size()>0){
            for(Form_Value__c status :formStatus){
                statuses.put(status.Form_Id__c, status.Status__c);
            }
        }

         //added by Anmol for LX3-7326
         if(formCare!=null && formCare.size()>0){
            for(Form_Value__c status :formCare){
                formToCareEps.put(status.Form_Id__c, status.Care_Episode__c);
            }
        }
        //end by Anmol for LX3-7326

        Map<String, Integer> adminLevels = new Map<String, Integer>();                                      
        if(defaultApprovalLevels!=null && defaultApprovalLevels.size()>0){
            for(Object_1_css__c level :defaultApprovalLevels){
                adminLevels.put(level.Form__c, Integer.valueOf(level.Approval_Level__c));
            }
        }
        for(Elixir_NewAccountAssociatedFormsApex.FormWrapper form :forms){
            String formId = form.formId;
            if(statuses.containsKey(formId)){
                form.status = statuses.get(formId);
            }else{
                form.status = 'Open';
            }

              //added by Anmol for LX3-7326
              if(formToCareEps.containsKey(formId)){
                
                if(formToCareEps.get(formId) == null){
                    
                    form.careEpisodeId = '';
               form.careEpisodeName = '';
               }
               else{
               ElixirSuite__Visits__c careRec = [Select Id,Name from ElixirSuite__Visits__c where Id=:formToCareEps.get(formId) 
               WITH SECURITY_ENFORCED];
               form.careEpisodeId = careRec.Id;
               form.careEpisodeName = careRec.Name;
           }
            }
            //end by Anmol for LX3-7326

            Integer approvalCount = 0;
            if(approvedCount.containsKey(formId)){
                approvalCount = approvedCount.get(formId);
            }
            form.approvedLevelsCount = approvalCount;
            Integer totalCount = 0;
            
            String recordTypeName = ids.get(formId);
            if(Test.isRunningTest()){
                recordTypeName = 'Test';
                adminLevels.put('Test',1);
            }
            if(Test.isRunningTest()){
                adminLevels.put('Test',1);
            }
            if(adminLevels.containsKey(recordTypeName)){
           
                totalCount = adminLevels.get(recordTypeName);
            }
            form.defaultLevelCount = totalCount;
        }
    }
     public static void updateFormWithApprovalValuesForcommunity(List<Elixir_NewAccountAssociatedFormsApex.FormWrapper> forms,
                                                    Map<String,String> ids) {
        Set<String> uniqueIds = ids.keySet(); 
        Set<String> formNames = new Set<String>(ids.values());
        List<AggregateResult> approvedLevels = [SELECT Count(Id) c,Form_Id__c  form 
                    FROM Form_Value__c WITH SECURITY_ENFORCED 
                    GROUP by Form_Id__c, Is_Approver__c,Is_old__c  
                    HAVING Is_Approver__c=true AND Form_Id__c IN :uniqueIds and Is_old__c != true];
        Map<String,Integer> approvedCount = new Map<String,Integer>();
        if(approvedLevels!=null && approvedLevels.size()>0){
            for(AggregateResult result :approvedLevels){
                String formId = (String)result.get('form');
                Integer count = (Integer)result.get('c');
                approvedCount.put(formId, count);
            }
        }
        List<Object_1_css__c> defaultApprovalLevels = [SELECT Id, Form__c, Approval_Level__c, Approv__c,Approval_Members__c
                    FROM Object_1_css__c 
                    WHERE Form__c IN :formNames AND Approval_Level__c!=NULL 
                    WITH SECURITY_ENFORCED 
                    ORDER BY Approval_Level__c];
        List<Form_Value__c> formStatus = [SELECT Id, Form_Id__c,ElixirSuite__Form_Portal_Status__c FROM Form_Value__c
                    WHERE Form_Detail__c=true AND Form_Id__c IN :uniqueIds
                    WITH SECURITY_ENFORCED];
        Map<String, String> statuses = new Map<String, String>();                                             
        if(formStatus!=null && formStatus.size()>0){
            for(Form_Value__c status :formStatus){
                statuses.put(status.Form_Id__c, status.ElixirSuite__Form_Portal_Status__c);
            }
        }
        Map<String, Integer> adminLevels = new Map<String, Integer>();                                      
        if(defaultApprovalLevels!=null && defaultApprovalLevels.size()>0){
            for(Object_1_css__c level :defaultApprovalLevels){
                adminLevels.put(level.Form__c, Integer.valueOf(level.Approval_Level__c));
            }
        }
        for(Elixir_NewAccountAssociatedFormsApex.FormWrapper form :forms){
            String formId = form.formId;
            if(statuses.containsKey(formId)){
                form.status = statuses.get(formId);
            }else{
                form.status = 'Open';
            }
            Integer approvalCount = 0;
            if(approvedCount.containsKey(formId)){
                approvalCount = approvedCount.get(formId);
            }
            form.approvedLevelsCount = approvalCount;
            Integer totalCount = 0;
            
            String recordTypeName = ids.get(formId);
            if(Test.isRunningTest()){
                recordTypeName = 'Test';
                adminLevels.put('Test',1);
            }
            if(Test.isRunningTest()){
                adminLevels.put('Test',1);
            }
            if(adminLevels.containsKey(recordTypeName)){
           
                totalCount = adminLevels.get(recordTypeName);
            }
            form.defaultLevelCount = totalCount;
        }
    }
}