public with sharing class FormApprovalDecision {

    public static Boolean getApprovalAndSignatureData(List<Map<String, String>> formsData){
        
        Boolean isDisabled = false;
        List<String> formIds = new List<String>();
        List<String> formNames = new List<String>();
        Map<String, String[]> objMap = new Map<String, String[]>();
        Map<String, String[]> formValueMap = new Map<String, String[]>();
        
        for (Map<String, String> wrp : formsData) {
            formIds.add(wrp.get('formId'));
            formNames.add(wrp.get('formName'));
        }
        List<ElixirSuite__Object_1_css__c> obj1List = new List<ElixirSuite__Object_1_css__c>();
        obj1List = [
            SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Form__c,ElixirSuite__Approval_Members__c 
            FROM ElixirSuite__Object_1_css__c 
            WHERE ElixirSuite__Form__c IN :formNames AND ElixirSuite__Approval_Level__c != NULL WITH SECURITY_ENFORCED
        ];
        if(obj1List.size()>0){
            for (ElixirSuite__Object_1_css__c css : obj1List) {
                String formName = css.ElixirSuite__Form__c;
                String[] levels = objMap.containsKey(formName) ? objMap.get(formName) : new List<String>();
                levels.add(String.valueOf(css.ElixirSuite__Approval_Level__c));
                objMap.put(formName, levels);
            }
            
            // Create objCountMap to store the size (count) of arrays for each key
            Map<String, String> objCountMap = new Map<String, String>();
            for (String key : objMap.keySet()) {
                objCountMap.put(key,String.valueOf(objMap.get(key).size()));
            }
            
            for(String formNameobj : formNames){
                if(!objCountMap.containsKey(formNameobj)){
                    objCountMap.put(formNameobj,String.valueOf(0));
                } 
            }
            
            List<ElixirSuite__Form_Value__c> formValueList = new   List<ElixirSuite__Form_Value__c>();
            formValueList = [
                SELECT Id, ElixirSuite__Is_Approver__c, ElixirSuite__Form_Id__c, ElixirSuite__Approval_Level__c, ElixirSuite__Form_Name__c, ElixirSuite__Is_old__c
                FROM ElixirSuite__Form_Value__c 
                WHERE ElixirSuite__Form_Id__c IN :formIds AND ElixirSuite__Approval_Level__c != NULL WITH SECURITY_ENFORCED
            ];
            if(formValueList.size()>0){
                Map<String,String> uniqIdAndLabelAMp = new Map<String,String>();
                
                for (ElixirSuite__Form_Value__c fv : formValueList) {
                    uniqIdAndLabelAMp.put(fv.ElixirSuite__Form_Id__c,fv.ElixirSuite__Form_Name__c);
                    String formUniqueId = fv.ElixirSuite__Form_Id__c;
                    String[] levels = formValueMap.containsKey(formUniqueId) ? formValueMap.get(formUniqueId) : new List<String>();
                    levels.add(String.valueOf(fv.ElixirSuite__Approval_Level__c));
                    formValueMap.put(formUniqueId, levels);
                }
                
                 
                // Create formValueCountMap to store the size (count) of arrays for each key
                Map<String, String> formValueCountMap = new Map<String, String>();
                for (String key : formValueMap.keySet()) {
                    formValueCountMap.put(key, String.valueOf(formValueMap.get(key).size()));
                }
                ElixirSuite__Form_Value__c[] formIdNameLst = [SELECT Id, ElixirSuite__Is_Approver__c, ElixirSuite__Form_Id__c, ElixirSuite__Approval_Level__c, ElixirSuite__Form_Name__c, ElixirSuite__Is_old__c
                                                              FROM ElixirSuite__Form_Value__c 
                                                              WHERE ElixirSuite__Form_Id__c IN : formIds WITH SECURITY_ENFORCED];
                Map<String,String> formIdNameMap = new   Map<String,String> ();
                for(ElixirSuite__Form_Value__c obj : formIdNameLst){
                    formIdNameMap.put(obj.ElixirSuite__Form_Id__c,obj.ElixirSuite__Form_Name__c);
                }
                for(String str : formIds){
                    if(!formValueCountMap.containsKey(str)){
                        formValueCountMap.put(str,String.valueOf(0));
                        if(formIdNameMap.containskey(str)){
                            uniqIdAndLabelAMp.put(str,formIdNameMap.get(str));
                        }
                        
                    } 
                } 
                for (String fuq : formValueCountMap.keySet()) {
                    if (!formValueCountMap.get(fuq).equals(objCountMap.get(uniqIdAndLabelAMp.get(fuq)))) {
                        isDisabled = true;
                        break;
                    }
                } 
            }
            else {
                isDisabled = true;
            }
        }
        
        return isDisabled; 
        
    }
    
}