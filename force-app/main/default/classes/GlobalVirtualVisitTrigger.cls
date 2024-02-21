global with sharing virtual class GlobalVirtualVisitTrigger {
    global virtual void afterInsert(List<Visits__c> visits){
        VisitController.removeActiveLocation(visits);
        VisitController.createACR(visits);
        List<UserLocation__c> userLocations = [SELECT Id FROM UserLocation__c WITH SECURITY_ENFORCED LIMIT 1];
        Boolean locationConfigured = false;
        if( userLocations.size()>0 && userLocations!=null){
            locationConfigured = true;
        }
     //   Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        StopRecursion.stopLocationUpdation = false;

        List<Elixir_Pluggable_Classes__mdt> pluggableClass1 = new List<Elixir_Pluggable_Classes__mdt>();
        pluggableClass1 = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='InsertChangedLocationsRun' WITH SECURITY_ENFORCED];
        if(pluggableClass1 != null && !pluggableClass1.isEmpty() && pluggableClass1.Size() > 0){
        VisitController.insertChangedLocations(visits);
}
        
        if(locationConfigured){
            /* //  code removal for LX3-10737*/
        }
        
    }
    global virtual void afterUpdate(List<Visits__c> oldVisits, List<Visits__c> newVisits){
        VisitController.removeActiveLocation(newVisits);
        VisitController.createACR(newVisits);
                List<UserLocation__c> userLocations = [SELECT Id FROM UserLocation__c WITH SECURITY_ENFORCED LIMIT 1];
        Boolean locationConfigured = false;
        if(userLocations.size()>0 && userLocations!=null){
            locationConfigured = true;
        }
        Map<Id,Visits__c> oldVisitMap = new Map<Id,Visits__c>(oldVisits);
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        StopRecursion.stopLocationUpdation = false;

        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='UpdateChangedLocationsRun' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty() && pluggableClass.Size() > 0){
        VisitController.updateChangedLocations(oldVisits);
}
        
        List<Elixir_Pluggable_Classes__mdt> pluggableClass1 = new List<Elixir_Pluggable_Classes__mdt>();
        pluggableClass1 = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='InsertChangedLocationsRun' WITH SECURITY_ENFORCED];
        if(pluggableClass1 != null && !pluggableClass1.isEmpty() && pluggableClass1.Size() > 0){
        VisitController.insertChangedLocations(newVisits);
}
        
        
        VisitController.setFlag(newVisits, oldVisitMap);
        VisitController.checkReopenStaus(newVisits);
        if(locationConfigured){
            /* //  code removal for LX3-10737*/
        } 
        //added for LX3-5998
        if(customSetting!=null && customSetting.ElixirSuite__Create_Claim_For_Care_Episode__c){
            visitCloseTriggerHandler.createClaim(oldVisitMap,newVisits);
        }
        //locking the forms start
        if(customSetting!=null && customSetting.ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c){
            VisitController.checkFormStatusWhenClosed(newVisits);
        }
    }
    
    global virtual void beforeInsert(List<Visits__c> visits){
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        Boolean multipleCareEpisode = val.ElixirSuite__Enable_Multiple_Active_Care_Episode__c;
        if(multipleCareEpisode == false && val!=null && val.ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c){
            VisitController.checkCareEpisodeStatus(visits);   
        }
        beforeUpdate(visits);
    }
    global virtual void beforeUpdate(List<Visits__c> visits){
       Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();
            List<UserLocation__c> userLocations = [SELECT Id FROM UserLocation__c WITH SECURITY_ENFORCED LIMIT 1];
            if(userLocations!=null && StopRecursion.stopLocationUpdation){
                for(Visits__c visit :visits){
                    if(visit.Care_Episode_Location__c==null && (mcs!=null &&  mcs.Care_episode_location_mandatory__c)){
                        visit.Care_Episode_Location__c.addError('Please provide location first!');
                    }
                }
            }
    }
    global virtual void afterDelete(List<Visits__c> oldVisits){
        VisitController.removeActiveLocation(oldVisits);
    }
    
    global virtual void afterUpdateVisit(List<ElixirSuite__Visits__c> visits,Map<id,ElixirSuite__Visits__c> oldVisitsMap){
        try{
            List<ElixirSuite__Master_Object__c> masterRecords = [ SELECT Id, ElixirSuite__Visit_Summary_Sections__c, ElixirSuite__Enable_Visit_Summary__c
                FROM ElixirSuite__Master_Object__c
                WHERE ElixirSuite__Patient_Tile_Entity__c = 'Visit Summary' WITH SECURITY_ENFORCED];
        if (!masterRecords.isEmpty() && masterRecords[0].ElixirSuite__Enable_Visit_Summary__c) {
            VisitSummaryData obj = new VisitSummaryData();
            obj.visits = visits;
            obj.oldVisitsMap = oldVisitsMap;
            VisitController.triggerVisitSummary(JSON.serialize(obj));
        }
        }catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        
    }
    global class VisitSummaryData {
        global List<ElixirSuite__Visits__c> visits;
        global Map<id,ElixirSuite__Visits__c> oldVisitsMap;
    }
}