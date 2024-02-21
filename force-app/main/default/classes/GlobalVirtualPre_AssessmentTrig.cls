global with sharing virtual class GlobalVirtualPre_AssessmentTrig {
    Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();

    global virtual void beforeInsert(List<Pre_Assessment__c> preAssessmentLst){
        if(record.ElixirSuite__Patient_Deceased__c){ 
            Boolean wasRun = PreAssesmentTriggerHelper.preventEditIfDeceasedCheckedOnAccount(preAssessmentLst);
            PreAssesmentTriggerHelper.stopDeceasedEdit(preAssessmentLst,wasRun);
        }
    }
    global virtual void beforeUpdate(List<Pre_Assessment__c> preAssessmentLst){
        if(record.ElixirSuite__Patient_Deceased__c){ 
            Boolean wasRun = PreAssesmentTriggerHelper.preventEditIfDeceasedCheckedOnAccount(preAssessmentLst);
            PreAssesmentTriggerHelper.stopDeceasedEdit(preAssessmentLst,wasRun);
        }
    }
    global virtual void beforeDelete(List<Pre_Assessment__c> preAssessmentLst){
        if(record.ElixirSuite__Patient_Deceased__c){ 
            PreAssesmentTriggerHelper.blockDeleteIfDeceased(preAssessmentLst);
        }
    }
    global virtual void afterInsert(List<Pre_Assessment__c> preAssessmentLst){
        isInsertAndUpdate(preAssessmentLst,'Insert',new Map<Id,Pre_Assessment__c>(preAssessmentLst), new Map<Id,Pre_Assessment__c>());
    }
    global virtual void afterUpdate(List<Pre_Assessment__c> preAssessmentLst, Map<Id,Pre_Assessment__c> oldAssessmentMap){
        isInsertAndUpdate(preAssessmentLst,'Update',new Map<Id,Pre_Assessment__c>(preAssessmentLst), oldAssessmentMap);
    }
    global virtual void isInsertAndUpdate(List<Pre_Assessment__c> preAssessmentLst, String event, Map<Id,Pre_Assessment__c> preAssessmentMap,  Map<Id,Pre_Assessment__c> oldAssessmentMap){
        List<UserLocation__c> userLocations = [SELECT Id FROM UserLocation__c WITH SECURITY_ENFORCED LIMIT 1];
        Boolean locationConfigured = false;
        if(userLocations.size()>0 && userLocations!=null){
            locationConfigured = true;
        }
        if(locationConfigured){
            Set<Id> oppId = new Set<Id>();
            for(Pre_Assessment__c assessment:preAssessmentLst){
                if(assessment.Opportunity__c!=null && event == 'Update' && assessment.Opportunity__c!=preAssessmentMap.get(assessment.Id).Opportunity__c){
                        oppId.add(assessment.Opportunity__c);
                    }else if(assessment.Opportunity__c!=null && event == 'Insert'){
                        oppId.add(assessment.Opportunity__c);
                    }
                
            }
            List<Opportunity> opportunities = [SELECT Id,AccountId FROM Opportunity WHERE Id IN :oppId WITH SECURITY_ENFORCED];
            Set<Id> accountId = new Set<Id>();
            for(Opportunity opp :opportunities){
                accountId.add(opp.AccountId);
            }
            if(accountId!=null && accountId.size()>0){
                //  code removal for LX3-10737
            }
        }
    }
}