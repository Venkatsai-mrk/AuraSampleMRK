public with sharing class WorkScheduleTriggerHandler {
    
    public static void dateValidations(List<Work_Schedule__c> lstWorkSchedule){
        for(Work_Schedule__c workSchedule : lstWorkSchedule){
            system.debug('workSchedule.Start_Date__c'+workSchedule.Start_Date__c);
        	system.debug('workSchedule.End_Date__c'+workSchedule.End_Date__c);
            if(workSchedule.Start_Date__c < system.today()){
                workSchedule.addError('Start date should not be less than today');
            }
            if(workSchedule.End_Date__c < system.today()){
                workSchedule.addError('End date should not be less than today');
            }
            if(workSchedule.End_Date__c < workSchedule.Start_Date__c){
                workSchedule.addError('End date should not be less than start date');
            }
            if((workSchedule.Start_Date__c == workSchedule.End_Date__c) && (workSchedule.End_Time__c < workSchedule.Start_Time__c)){
                workSchedule.addError('End Time should not be less than start Time');
            }
            if((workSchedule.End_Time__c == workSchedule.Start_Time__c)){
                workSchedule.addError('End Time should not be equal to start Time');
            }
        }
        
    }

    public static void calculateNextAvailSlot(List<Work_Schedule__c> lstWorkSchedule,Map<Id,Work_Schedule__c> oldWorkScheduleMap){
        
        Set<String> juncPracLst = new Set<String>();
        Set<String> juncLocLst = new Set<String>();
        
        try{
        for(Work_Schedule__c workSch : lstWorkSchedule){
            juncPracLst.add(String.valueof(workSch.ElixirSuite__Practitioner_Name__c));
            juncLocLst.add(String.valueof(workSch.ElixirSuite__Provider_Location__c));
            if (oldWorkScheduleMap != null && !oldWorkScheduleMap.isEmpty()) {
                juncLocLst.add(String.valueof(oldWorkScheduleMap.get(workSch.Id).ElixirSuite__Provider_Location__c));
                juncPracLst.add(String.valueof(oldWorkScheduleMap.get(workSch.Id).ElixirSuite__Practitioner_Name__c));
            }
        }
            List<String> pracStrings1 = new List<String>(juncPracLst);
            List<String> locStrings1 = new List<String>(juncLocLst);
            
            WorkScheduleTriggerHandler.createSlots(pracStrings1,locStrings1);
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
    @future(callout=true)
    public static void createSlots(List<String> pracStrings,List<String> locStrings){
        
        Date startDate1 = system.today();
        try{
        Elixir_Utility.Wrapper3 appointmentTyp1 = Elixir_Utility.getBulkAppointmentType(pracStrings,locStrings,startDate1);
        Map<String,String> pracLocVsAppTyp = appointmentTyp1.pracLocVsAptTyp;
        List<String> appTypLst = appointmentTyp1.appTypLstWrp;
        
        Map<String,String> pracMap = new Map<String,String>();
        pracMap = Elixir_Utility.bulkWorkslot(pracStrings,locStrings,startDate1,appTypLst,pracLocVsAppTyp);
        
        List<ElixirSuite__UserLocation__c> juncLst = [SELECT Id, Name, ElixirSuite__Practitioner__c, 
                                                      ElixirSuite__Provider__c, ElixirSuite__Next_available_slot__c 
                                                      FROM ElixirSuite__UserLocation__c
                                                      WHERE ElixirSuite__Practitioner__c IN : pracStrings
                                                      AND ElixirSuite__Provider__c IN : locStrings
                                                      WITH SECURITY_ENFORCED];
        
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
    
    
    /*public static void dateFieldUpdate(List<Work_Schedule__c> lstWorkSchedule){
        
        for(Work_Schedule__c workSchedule : lstWorkSchedule){
            if(workSchedule.Start_Date__c == null && workSchedule.End_Date__c == null){
                workSchedule.Start_Date__c = system.today();
                workSchedule.End_Date__c = workSchedule.Start_Date__c.addYears(1);
                
            }
            if(workSchedule.Start_Date__c != null && workSchedule.End_Date__c == null){
                workSchedule.End_Date__c = workSchedule.Start_Date__c.addYears(1);
            }
            if(workSchedule.Start_Date__c == null && workSchedule.End_Date__c != null){
                workSchedule.Start_Date__c = system.today();
            }
        }
    }*/
    public static void checkLocation(List<Work_Schedule__c> lstWorkSchedule){
        try{
            
            set<Id> practitionerId = new set<Id>();
            Set<Id> locationlst = new Set<Id>();
            Map<Id,Set<Id>> locationmap = new Map<Id,Set<Id>>();
            for(Work_Schedule__c wcc : lstWorkSchedule){
                    practitionerId.add(wcc.Practitioner_Name__c);            
            }
            List<UserLocation__c> junctionlst = [SELECT Id, Practitioner__c, Provider__c FROM UserLocation__c
                                                where Practitioner__c IN : practitionerId
                                                WITH SECURITY_ENFORCED];
            if(junctionlst.size() > 0 && junctionlst != null){
                
                for(UserLocation__c rec: junctionlst){
                    if(locationmap.containsKey(rec.Practitioner__c)){
                        locationmap.get(rec.Practitioner__c).add(rec.ElixirSuite__Provider__c);
                    }
                    else{
                        locationlst =new Set<Id>();
                        locationlst.add(rec.ElixirSuite__Provider__c);
                        locationmap.put(rec.Practitioner__c,locationlst);
                    }
                }
            }
            for(Work_Schedule__c newRec : lstWorkSchedule)
            {
				Set<Id> locations = locationmap.get(newRec.Practitioner_Name__c);
                if(!locations.contains(newRec.Provider_Location__c) && newRec.Provider_Location__c != null ){
                    newRec.addError('Practitioner is not provisioned to work at this location');
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void workScheduleduplicate(List<Work_Schedule__c> lstWorkSchedule){
        try{
            set<Id> practitionerId = new set<Id>();
            for(Work_Schedule__c wcc : lstWorkSchedule){
                practitionerId.add(wcc.Practitioner_Name__c);            
            }
            system.debug('practitionerId'+ practitionerId);
            List<Work_Schedule__c> existingRec = [Select id, Days__c,Start_Time__c,End_Time__c,Start_Date__c,
                                                  End_Date__c,Practitioner_Name__c from Work_Schedule__c
                                                  where Practitioner_Name__c IN : practitionerId
                                                  WITH SECURITY_ENFORCED];
            system.debug('existingRec'+ existingRec.size()+ existingRec);
            if(existingRec != null && existingRec.size() >0){
                for(Work_Schedule__c existing : existingRec){            
                	for(Work_Schedule__c newRec :lstWorkSchedule){
                    if((newRec.ElixirSuite__Practitioner_Name__c == existing.ElixirSuite__Practitioner_Name__c) && 
                       ((newRec.Start_Date__c >= existing.Start_Date__c && newRec.Start_Date__c <= existing.End_Date__c) || 
                       (newRec.End_Date__c >= existing.Start_Date__c && newRec.End_Date__c <= existing.End_Date__c) ||
                       (existing.Start_Date__c >= newRec.Start_Date__c && existing.Start_Date__c <= newRec.End_Date__c)  ||
                       (existing.End_Date__c >= newRec.Start_Date__c && existing.End_Date__c <= newRec.End_Date__c)))
                    {
                        system.debug('newRec'+newRec.Days__c);
                        system.debug('existingRec'+existing.Days__c);
                        
                        List<String> list1 = new List<String>();
                        List<String> list2 = new List<String>();
                        String newDays = newRec.Days__c;
                        String existingDays = existing.Days__c;
                        
                        if (newDays != null && newDays != '' && existingDays != null && existingDays != '') {
                            list1 = newDays.split(';');
                            list2 = existingDays.split(';');
                        }
                        Set<String> newDaysList = new Set<String>(list1);
                        Set<String> existingDaysList = new Set<String>(list2);
                        //retainAll method removes all elements from the first set that are not present in the second set
                        newDaysList.retainAll(existingDaysList);   
                        system.debug('newDaysList'+newDaysList);
                        if(newDaysList.size() > 0 && newDaysList != null)
                        {
                             if((newRec.Start_Time__c >= existing.Start_Time__c && newRec.Start_Time__c <= existing.End_Time__c) || 
                                (newRec.End_Time__c >= existing.Start_Time__c && newRec.End_Time__c <= existing.End_Time__c)  ||
                                (existing.Start_Time__c >= newRec.Start_Time__c && existing.Start_Time__c <= newRec.End_Time__c)  ||
                                (existing.End_Time__c >= newRec.Start_Time__c && existing.End_Time__c <= newRec.End_Time__c))
                             {
                                 
                                 newRec.addError('Duplicate slots exists for this practitioner');
                             }
                        }
                    }
                }
            }
    	}
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    
     public static void workScheduleduplicateupdate(List<Work_Schedule__c> lstWorkSchedule){
        try{
            set<Id> practitionerId = new set<Id>();
            for(Work_Schedule__c wcc : lstWorkSchedule){
                practitionerId.add(wcc.Practitioner_Name__c);            
            }
            system.debug('practitionerId'+ practitionerId);
            List<Work_Schedule__c> existingRec = [Select id, Days__c,Start_Time__c,End_Time__c,Start_Date__c,
                                                  End_Date__c,Practitioner_Name__c from Work_Schedule__c
                                                  where Practitioner_Name__c IN : practitionerId
                                                  WITH SECURITY_ENFORCED];
            system.debug('existingRec'+ existingRec.size()+ existingRec);
            if(existingRec != null && existingRec.size() >0){
                for(Work_Schedule__c existing : existingRec){            
                	for(Work_Schedule__c newRec :lstWorkSchedule){
                    if((newRec.Id != existing.Id ) && (newRec.ElixirSuite__Practitioner_Name__c == existing.ElixirSuite__Practitioner_Name__c) && 
                       ((newRec.Start_Date__c >= existing.Start_Date__c && newRec.Start_Date__c <= existing.End_Date__c) || 
                       (newRec.End_Date__c >= existing.Start_Date__c && newRec.End_Date__c <= existing.End_Date__c) ||
                       (existing.Start_Date__c >= newRec.Start_Date__c && existing.Start_Date__c <= newRec.End_Date__c)  ||
                       (existing.End_Date__c >= newRec.Start_Date__c && existing.End_Date__c <= newRec.End_Date__c)))
                    {
                        List<String> list1 = new List<String>();
                        List<String> list2 = new List<String>();
                        String newDays = newRec.Days__c;
                        String existingDays = existing.Days__c;
                        
                        if (newDays != null && newDays != '' && existingDays != null && existingDays != '') {
                            list1 = newDays.split(';');
                            list2 = existingDays.split(';');
                        }
                        Set<String> newDaysList = new Set<String>(list1);
                        Set<String> existingDaysList = new Set<String>(list2);
                        //retainAll method removes all elements from the first set that are not present in the second set
                        newDaysList.retainAll(existingDaysList);   
                        if(newDaysList.size() > 0 && newDaysList != null)
                        {
                             if((newRec.Start_Time__c >= existing.Start_Time__c && newRec.Start_Time__c <= existing.End_Time__c) || 
                                (newRec.End_Time__c >= existing.Start_Time__c && newRec.End_Time__c <= existing.End_Time__c)  ||
                                (existing.Start_Time__c >= newRec.Start_Time__c && existing.Start_Time__c <= newRec.End_Time__c)  ||
                                (existing.End_Time__c >= newRec.Start_Time__c && existing.End_Time__c <= newRec.End_Time__c))
                             {
                                 
                                 newRec.addError('Duplicate slots exists for this practitioner');
                             }
                        }
                    }
                }
            }
    	}
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    /*
    public static void afterInsertWorkSchedule(List<Work_Schedule__c> lstWorkSchedule){
        
        List<String> daysArray = new List<String>();
        List<Date> selectedDateList = new List<Date>();
        List<Work_Schedule__c> newWorkScheduleList = new List<Work_Schedule__c>();
        for(Work_Schedule__c workSchedule : lstWorkSchedule){
            Integer interval = workSchedule.Start_Date__c.daysBetween(workSchedule.End_Date__c)+1;
            for(Integer i=0; i<interval; i++){
                Date newDate = workSchedule.Start_Date__c.addDays(i);
                system.debug('newDate'+newDate);
                selectedDateList.add(newDate);
            }
            daysArray = workSchedule.Days__c.split(';');
            for(Date d : selectedDateList){
                DateTime dtConverted = Datetime.newInstance(d.year(), d.month(),d.day(),0,0,0); 
                String day = dtConverted.format('EEEE');
                if(daysArray.contains(day)){
                    Work_Schedule__c newWorkSchedule = new Work_Schedule__c();
                    newWorkSchedule.Start_Date__c = d;
                    newWorkSchedule.Start_Time__c = workSchedule.Start_Time__c;
                    newWorkSchedule.Time_Zone__c = workSchedule.Time_Zone__c;
                    newWorkSchedule.Start_Date_Time__c = workSchedule.Start_Date_Time__c;
                    newWorkSchedule.End_Date__c = d;
                    newWorkSchedule.End_Time__c = workSchedule.End_Time__c;
                    newWorkSchedule.End_Date_Time__c = workSchedule.Start_Date_Time__c;
                    newWorkSchedule.Days__c = day;
                    newWorkSchedule.Practitioner_Name__c = workSchedule.Practitioner_Name__c;
                    newWorkSchedule.Work_Schedule__c = workSchedule.Id;
                    newWorkScheduleList.add(newWorkSchedule);
                }
            }
        }
        if(Schema.sObjectType.Work_Schedule__c.isCreateable() && Schema.sObjectType.Work_Schedule__c.fields.Start_Date__c.isCreateable() &&
           Schema.sObjectType.Work_Schedule__c.fields.Start_Time__c.isCreateable() &&Schema.sObjectType.Work_Schedule__c.fields.Time_Zone__c.isCreateable() &&
           Schema.sObjectType.Work_Schedule__c.fields.Start_Date_Time__c.isCreateable() && Schema.sObjectType.Work_Schedule__c.fields.End_Date__c.isCreateable() &&
           Schema.sObjectType.Work_Schedule__c.fields.End_Time__c.isCreateable() && Schema.sObjectType.Work_Schedule__c.fields.End_Date_Time__c.isCreateable() && 
           Schema.sObjectType.Work_Schedule__c.fields.Days__c.isCreateable() && Schema.sObjectType.Work_Schedule__c.fields.Practitioner_Name__c.isCreateable() && 
           Schema.sObjectType.Work_Schedule__c.fields.Work_Schedule__c.isCreateable()){
               insert newWorkScheduleList;
           }
    }
    public static void afterUpdateWorkSchedule(Map<Id,Work_Schedule__c> newWorkScheduleMap,Map<Id,Work_Schedule__c> oldWorkScheduleMap){
        /*
        List<String> daysArray = new List<String>();
        List<Date> selectedDateList = new List<Date>();
        List<Work_Schedule__c> newWorkScheduleList = new List<Work_Schedule__c>();
        Map<Date,String> dateDayNameMap;
        DMLManager.deleteAsUser([Select Id,Start_Date__c FROM Work_Schedule__c WHERE Start_Date__c >=:system.today() AND Work_Schedule__c IN:oldWorkScheduleMap.keyset()]);
        for(Work_Schedule__c workSchedule : newWorkScheduleMap.values()){
            if(workSchedule.Start_Date__c != oldWorkScheduleMap.get(workSchedule.Id).Start_Date__c ||
               workSchedule.End_Date__c != oldWorkScheduleMap.get(workSchedule.Id).End_Date__c ||
               workSchedule.Start_Time__c != oldWorkScheduleMap.get(workSchedule.Id).Start_Time__c ||
               workSchedule.End_Time__c != oldWorkScheduleMap.get(workSchedule.Id).End_Time__c ||
               workSchedule.Days__c != oldWorkScheduleMap.get(workSchedule.Id).Days__c ||
               workSchedule.Time_Zone__c != oldWorkScheduleMap.get(workSchedule.Id).Time_Zone__c
              ){
                  Integer interval = workSchedule.Start_Date__c.daysBetween(workSchedule.End_Date__c)+1;
                  for(Integer i=0; i<interval; i++){
                      Date newDate = workSchedule.Start_Date__c.addDays(i);
                      system.debug('newDate'+newDate);
                      selectedDateList.add(newDate);
                  }
                  daysArray = workSchedule.Days__c.split(';');
                  system.debug(daysArray+' daysArray');
                  for(Date d : selectedDateList){
                      DateTime dtConverted = Datetime.newInstance(d.year(), d.month(),d.day(),0,0,0);
                      String day = dtConverted.format('EEEE');
                      if(daysArray.contains(day)){
                          Date dat = date.newinstance(dtConverted.year(), dtConverted.month(), dtConverted.day());
                          Work_Schedule__c newWorkSchedule = new Work_Schedule__c();
                          newWorkSchedule.Start_Date__c = d;
                          newWorkSchedule.Start_Time__c = workSchedule.Start_Time__c; 
                          newWorkSchedule.Time_Zone__c = workSchedule.Time_Zone__c;
                          newWorkSchedule.Start_Date_Time__c = workSchedule.Start_Date_Time__c;
                          newWorkSchedule.End_Date__c = d;
                          newWorkSchedule.End_Time__c = workSchedule.End_Time__c;
                          newWorkSchedule.End_Date_Time__c = workSchedule.Start_Date_Time__c;
                          newWorkSchedule.Days__c = day;
                          newWorkSchedule.Practitioner_Name__c = workSchedule.Practitioner_Name__c;
                          newWorkSchedule.Work_Schedule__c = workSchedule.Id;
                          newWorkScheduleList.add(newWorkSchedule);
                      }
                  }
              }
        }
        if(Schema.sObjectType.Work_Schedule__c.isCreateable() && Schema.sObjectType.Work_Schedule__c.fields.Start_Date__c.isCreateable() &&
           Schema.sObjectType.Work_Schedule__c.fields.Start_Time__c.isCreateable() &&Schema.sObjectType.Work_Schedule__c.fields.Time_Zone__c.isCreateable() &&
           Schema.sObjectType.Work_Schedule__c.fields.Start_Date_Time__c.isCreateable() && Schema.sObjectType.Work_Schedule__c.fields.End_Date__c.isCreateable() &&
           Schema.sObjectType.Work_Schedule__c.fields.End_Time__c.isCreateable() && Schema.sObjectType.Work_Schedule__c.fields.End_Date_Time__c.isCreateable() && 
           Schema.sObjectType.Work_Schedule__c.fields.Days__c.isCreateable() && Schema.sObjectType.Work_Schedule__c.fields.Practitioner_Name__c.isCreateable() && 
           Schema.sObjectType.Work_Schedule__c.fields.Work_Schedule__c.isCreateable()){
               insert newWorkScheduleList;
           }
    }
    public static void beforeInsertOrUpdateDateTimeConversion(List<Work_Schedule__c> lstWorkSchedule){
        for(Work_Schedule__c workSchedule : lstWorkSchedule){
            Date targetStartDate = workSchedule.Start_Date__c;
            Date targetEndDate = workSchedule.End_Date__c;
            Time targetStartTime = workSchedule.Start_Time__c;
            Time targetEndTime = workSchedule.End_Time__c;
            TimeZone targetTimezone = TimeZone.getTimeZone(workSchedule.Time_Zone__c);
            Integer offsetSecondsForStartTime = targetTimezone.getOffset(targetStartDate) / 1000;
            Integer offsetSecondsForEndTime = targetTimezone.getOffset(targetEndDate) / 1000;
            Datetime dtGMTStartDateTime = Datetime.newInstance(targetStartDate, targetStartTime).addSeconds(-offsetSecondsForStartTime);
            Datetime dtGMTEndDateTime = Datetime.newInstance(targetEndDate, targetEndTime).addSeconds(-offsetSecondsForEndTime);
            workSchedule.Start_Date_Time__c = dtGMTStartDateTime;
            workSchedule.End_Date_Time__c = dtGMTEndDateTime;
        }
    }*/
    
}