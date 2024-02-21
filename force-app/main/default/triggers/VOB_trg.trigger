trigger VOB_trg on VOB__c (after insert, after update,before insert,before update,before delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
  Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
    if(record.ElixirSuite__Patient_Deceased__c){ // WORKFLOW DECEASED
         if(trigger.isBefore && (!(trigger.isBefore && Trigger.isDelete))){
            Boolean wasRun = OppFieldsOnVOBHandler.preventEditIfDeceasedCheckedOnAccount(Trigger.new);
            System.debug('wasRun '+wasRun); 
            OppFieldsOnVOBHandler.stopDeceasedEdit(Trigger.new,wasRun);
            
        }
         if(trigger.isBefore && Trigger.isDelete){ 
            OppFieldsOnVOBHandler.blockDeleteIfDeceased(Trigger.old);
        }
    }
      /*
    if(trigger.isInsert){    
        List<ElixirSuite__VOB__c> intList = new List<ElixirSuite__VOB__c>();
        Map<Id, Id> vobOppMap = new Map<Id,Id>();
        for(ElixirSuite__VOB__c vob : Trigger.new){
            if(vob.ElixirSuite__Opportunity__c != null ){
                vobOppMap.put(vob.Id, vob.ElixirSuite__Opportunity__c);
            }
        }
        if(vobOppMap.size() > 0){       
            OppFieldsOnVOBHandler.populateRelatedLookup(vobOppMap);
        }       
    }
    if(trigger.isInsert || trigger.isUpdate){//For Sharing
        List<UserLocation__c> userLocations = [SELECT Id FROM UserLocation__c WITH SECURITY_ENFORCED LIMIT 1];
        Boolean locationConfigured = false;
        if(userLocations!=null){
            locationConfigured = true;
        }
        if(locationConfigured){
            Set<Id> oppId = new Set<Id>();
            for(Vob__c vob:trigger.new){
                if(vob.Opportunity__c!=null){
                    if(trigger.isUpdate && vob.Opportunity__c!=trigger.oldMap.get(vob.Id).Opportunity__c){
                        oppId.add(vob.Opportunity__c);
                    }else if(trigger.isInsert){
                        oppId.add(vob.Opportunity__c);
                    }
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
    }*/
    
    //added this for LX3-7342
    if(trigger.isInsert && trigger.isAfter){
        OppFieldsOnVOBHandler.qualifyStartingRecords(Trigger.newMap);
    }
    //added this for LX3-7343
    if(trigger.isUpdate && trigger.isBefore){
        if(DeceasedGlobalStopRecursion.runForPortal){
        OppFieldsOnVOBHandler.qualifyUpdateRecords(Trigger.newMap, Trigger.oldMap);
    }
}
}