trigger VisitCloseTrigger on Visits__c (before insert, before update, after insert, after update, after delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    
    String virtualClassName = 'GlobalVirtualVisitTrigger';// Added by Himanshu
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='VisitCloseTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalVirtualVisitTrigger virtualVisit = (GlobalVirtualVisitTrigger) t.newInstance(); 
    
    if(trigger.isAfter && trigger.isInsert){ 
        virtualVisit.afterInsert(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate){ 
        virtualVisit.afterUpdate(trigger.old, trigger.new);
        virtualVisit.afterUpdateVisit(trigger.new,trigger.oldMap);
    }
    
    if(trigger.isBefore && trigger.isUpdate){ 
         virtualVisit.beforeUpdate(trigger.new);
         
    }
     if(trigger.isBefore && trigger.isInsert){
         virtualVisit.beforeInsert(trigger.new);
     }
    if(trigger.isAfter && trigger.isDelete){
        virtualVisit.afterDelete(trigger.old);
    }
    
    
    
    
    
    
    
    
    /*if(trigger.isAfter){ //Code Added By Rohit
        List<UserLocation__c> userLocations = [SELECT Id FROM UserLocation__c WITH SECURITY_ENFORCED LIMIT 1];
        Boolean locationConfigured = false;
        if(userLocations!=null){
            locationConfigured = true;
        }
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        if(trigger.isInsert){
            StopRecursion.stopLocationUpdation = false;
            VisitController.insertChangedLocations(trigger.new);
            if(locationConfigured){
                //  code removal for LX3-10737
            }
            for(Visits__c visit: trigger.new) // To update the previous visit status from Active to "closed" once new visit created.
            {
                Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        		Boolean multipleCareEpisode = val.ElixirSuite__Enable_Multiple_Active_Care_Episode__c;
                if(multipleCareEpisode == false){
                    VisitController.statusUpdate(visit);
                }
                /*if(customSetting!=null && customSetting.ElixirSuite__Enable_Multiple_Active_Care_Episode__c){
                    System.debug('bypass the status update');
                }
                else{
                    if(!VisitController.statusUpdate()){
                        visit.addError('Charges not configured on associated Procedure(s) for currently Active care episode, please contact System Admin before creating New care episode!'); //Anusha LX3-6883
                    }
                }*/
        /*    }
        }
        if(trigger.isUpdate){
            StopRecursion.stopLocationUpdation = false;
            VisitController.updateChangedLocations(trigger.old);
            VisitController.insertChangedLocations(trigger.new);
            VisitController.setFlag(trigger.new, trigger.oldMap);
            VisitController.checkReopenStaus(trigger.new);
            if(locationConfigured){
                //  code removal for LX3-10737
            } 
            //added for LX3-5998
            if(customSetting!=null && customSetting.ElixirSuite__Create_Claim_For_Care_Episode__c){
                visitCloseTriggerHandler.createClaim(trigger.oldMap,trigger.new);
            }
             //locking the forms start
            if(customSetting!=null && customSetting.ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c){
            	VisitController.checkFormStatusWhenClosed(trigger.new);
        }
        }
    }
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();
            List<UserLocation__c> userLocations = [SELECT Id FROM UserLocation__c WITH SECURITY_ENFORCED LIMIT 1];
            if(userLocations!=null && StopRecursion.stopLocationUpdation){
                for(Visits__c visit :trigger.new){
                    if(visit.Care_Episode_Location__c==null && (mcs!=null &&  mcs.Care_episode_location_mandatory__c)){
                        visit.Care_Episode_Location__c.addError('Please provide location first!');
                    }
                }
            }
        }
    }
    if(trigger.isBefore && trigger.isInsert){
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        Boolean multipleCareEpisode = val.ElixirSuite__Enable_Multiple_Active_Care_Episode__c;
        if(multipleCareEpisode == false && val!=null && val.ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c){
            VisitController.checkCareEpisodeStatus(trigger.new);   
        }
    }**/
    //locking the forms end
}