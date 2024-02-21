public with sharing class Elixir_Utility {
    
    public static PDF_Header__c getPDFData(){
        PDF_Header__c record = PDF_Header__c.getOrgDefaults() ;
        system.debug('vrec' + record);
        return record ;
    }

   //Get getBulkAppointmentType Records
    @AuraEnabled
    public static Wrapper3 getBulkAppointmentType(List<String> practNameLst, List<String> locNameLst , Date startDate){
        List<String> result = new List<String>();
        Wrapper3 wrap = new Wrapper3();
        Set<String> appLst = new Set<String>();
        try{
        List<ElixirSuite__Work_Schedule__c> workSch = [Select Id,ElixirSuite__Practitioner_Name__c,ElixirSuite__Provider_Location__c,ElixirSuite__Appointment_Types__c
                                                       FROM ElixirSuite__Work_Schedule__c
                                                       WHERE ElixirSuite__Practitioner_Name__c IN :practNameLst
                                                       AND ElixirSuite__Provider_Location__c IN :locNameLst
                                                       AND ((ElixirSuite__Start_Date__c >=: startDate)
                                                            OR (ElixirSuite__End_Date__c >=: startDate)
                                                            OR (ElixirSuite__Start_Date__c< :startDate))
                                                       WITH SECURITY_ENFORCED];
        
        Map<String,String> pracVsAppType = new Map<String,String>();
        for(Work_Schedule__c apt : workSch){
            
            String finalKey = String.valueof(apt.ElixirSuite__Practitioner_Name__c) + String.valueof(apt.ElixirSuite__Provider_Location__c);
 
            if(pracVsAppType== null){
                
                if(apt.ElixirSuite__Appointment_Types__c != null){
                    if(apt.ElixirSuite__Appointment_Types__c.contains(';')){
                        List<String> result1 = new List<String>();
                        result1.addAll(apt.ElixirSuite__Appointment_Types__c.split(';'));
                        result1.sort();
                        appLst.add(apt.ElixirSuite__Appointment_Types__c);
                        pracVsAppType.put(finalKey,result1[0]);
                    }else{
                        List<String> result2 = new List<String>();
                        result2.add(apt.ElixirSuite__Appointment_Types__c);
                        result2.sort();
                        appLst.add(apt.ElixirSuite__Appointment_Types__c);
                        pracVsAppType.put(finalKey,result2[0]);
                    }
                }
                
            }else{
                if(pracVsAppType.get(finalKey) == null){
                    if(apt.ElixirSuite__Appointment_Types__c != null){
                        if(apt.ElixirSuite__Appointment_Types__c.contains(';')){
                            List<String> result1 = new List<String>();
                            result1.addAll(apt.ElixirSuite__Appointment_Types__c.split(';'));
                            result1.sort();
                            appLst.add(apt.ElixirSuite__Appointment_Types__c);
                            pracVsAppType.put(finalKey,result1[0]);
                        }else{
                            List<String> result2 = new List<String>();
                            result2.add(apt.ElixirSuite__Appointment_Types__c);
                            result2.sort();
                            appLst.add(apt.ElixirSuite__Appointment_Types__c);
                            pracVsAppType.put(finalKey,result2[0]);
                        }
                    }
                }else{ 
                    
                    if(apt.ElixirSuite__Appointment_Types__c != null){
                        if(apt.ElixirSuite__Appointment_Types__c.contains(';')){
                            String val = pracVsAppType.get(finalKey);
                            List<String> nList1 = new List<String>();
                            nList1.add(val);
                            nList1.addAll(apt.ElixirSuite__Appointment_Types__c.split(';'));
                            nList1.sort();
                            appLst.add(apt.ElixirSuite__Appointment_Types__c);
                            pracVsAppType.put(finalKey,nList1[0]);
                        }else{
                            String val = pracVsAppType.get(finalKey);
                            List<String> nList2 = new List<String>();
                            nList2.add(val);
                            nList2.add(apt.ElixirSuite__Appointment_Types__c);
                            nList2.sort();
                            appLst.add(apt.ElixirSuite__Appointment_Types__c);
                            pracVsAppType.put(finalKey,nList2[0]);
                        }
                    }
                    
                }
                
            }
            
        }
        
        System.debug('pracVsAppType***'+pracVsAppType);
        List<String> appStrings = new List<String>(appLst);
        wrap.pracLocVsAptTyp = pracVsAppType;
        wrap.appTypLstWrp = appStrings;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrap;
    }
    
    @AuraEnabled
    public static Map<String,String> bulkWorkslot(List<String> practName, List<String> locName , Date startDate, List<String> apTypLst, Map<String,String> practLocaVsApt ){
Integer slotsDifference = fetchSlotsDifference();
        Map<string,Integer> appTypeDuration = new Map<string,Integer>();
        Map<String,String> pracVsSlot = new Map<String,String>();
        try{
            
            List<ElixirSuite__Procedure__c> aptTypeDuration = [SELECT Id, Name, ElixirSuite__Active__c, 
                                                               ElixirSuite__Code_Description__c,ElixirSuite__Long_Description__c, 
                                                               ElixirSuite__Procedure_Duration__c, 
                                                               ElixirSuite__Appointment_Type__c 
                                                               FROM ElixirSuite__Procedure__c 
                                                               where ElixirSuite__Active__c = True 
                                                               AND ElixirSuite__Appointment_Type__c = True
                                                               AND ElixirSuite__Procedure_Duration__c!=NULL
                                                               WITH SECURITY_ENFORCED];
            for(ElixirSuite__Procedure__c rec : aptTypeDuration){
                appTypeDuration.put(rec.Name, Integer.valueOf(rec.ElixirSuite__Procedure_Duration__c));
            }
            Integer breakTime;
            
            
            List<ElixirSuite__Work_Schedule__c> workSch = [Select Id,Name,ElixirSuite__Start_Date__c,
                                                           ElixirSuite__Start_Time__c,ElixirSuite__End_Time__c,
                                                           ElixirSuite__Practitioner_Name__c,
                                                           ElixirSuite__Practitioner_Name__r.Name,
                                                           ElixirSuite__Provider_Location__c,
                                                           ElixirSuite__End_Date__c,ElixirSuite__Days__c,
                                                           ElixirSuite__Appointment_Types__c
                                                           FROM ElixirSuite__Work_Schedule__c
                                                           WHERE ElixirSuite__Practitioner_Name__c IN :practName
                                                           AND ElixirSuite__Appointment_Types__c IN :apTypLst
                                                           AND ElixirSuite__Provider_Location__c IN :locName
                                                           AND ((ElixirSuite__Start_Date__c >=: startDate)
                                                                OR (ElixirSuite__End_Date__c >=: startDate)
                                                                OR (ElixirSuite__Start_Date__c< :startDate))
                                                           WITH SECURITY_ENFORCED 
                                                           ORDER BY ElixirSuite__Practitioner_Name__r.Name,
                                                            ElixirSuite__Start_Date__c,
                                                            ElixirSuite__Start_Time__c ];
            
            
            List<Contact> conData = new List<Contact>();
            List<String> practId= new List<String>();
            Map<String,String> userIdVspracId = new Map<String,String>();
            
            conData = [Select Id,Name,ElixirSuite__Practitioner_User__c FROM Contact Where id IN :practName WITH SECURITY_ENFORCED]; 
            if(conData != null && conData.size() > 0){
                for(Contact con : conData){
                    practId.add(con.ElixirSuite__Practitioner_User__c);
                    String finalKey = String.valueof(con.ElixirSuite__Practitioner_User__c) + String.valueof(con.Id);
                    userIdVspracId.put(finalKey,con.Id);
                }
            }
            
            List<Event> entList = [Select Id, OwnerId, WhoId,ElixirSuite__Practitioner__c,
                                   ElixirSuite__Location__c,StartDateTime,EndDateTime FROM Event Where 
                                   OwnerId IN :practId
                                   AND ElixirSuite__Location__c IN :locName
                                   AND DAY_ONLY(StartDateTime) >= :startDate
                                   AND (ElixirSuite__Status__c = 'Scheduled'
                                        OR ElixirSuite__Status__c = 'Rescheduled')     
                                   WITH SECURITY_ENFORCED];
            
            List<DateTime> startDateList = new List<DateTime>();
            List<DateTime> endDateList = new List<DateTime>();
            Map<String,List<DateTime>> startDateMap = new Map<String,List<DateTime>>();
            Map<String,List<DateTime>> endDateMap = new Map<String,List<DateTime>>();
            for(Event ev:entList){
                DateTime startDate1 =  ev.StartDateTime;
                String finalKey1 = String.valueof(ev.OwnerId) + String.valueof(ev.ElixirSuite__Practitioner__c);
                String finalKey = String.valueof(userIdVspracId.get(finalKey1)) + String.valueof(ev.ElixirSuite__Location__c);
                
                while(startDate1 < ev.EndDateTime){
                    startDateList.add(startDate1);
                    
                    if(startDateMap== null){
                        List<DateTime> nList = new List<DateTime>();
                        nList.add(startDate1);
                        startDateMap.put(finalKey, nList); 
                    }else{
                        if(startDateMap.get(finalKey) == null){
                            List<DateTime> nList = new List<DateTime>();
                            nList.add(startDate1);
                            startDateMap.put(finalKey, nList);  
                        }else{
                            List<DateTime> nList = startDateMap.get(finalKey);
                            nList.add(startDate1);
                            startDateMap.put(finalKey, nList); 
                        }
                        
                    }
                    
                    //  startDateMap.put(finalKey,startDate1);
                    startDate1 = startDate1.addMinutes(slotsDifference);
                    endDateList.add(startDate1);
                    
                    if(endDateMap== null){
                        List<DateTime> nList = new List<DateTime>();
                        nList.add(startDate1);
                        endDateMap.put(finalKey, nList); 
                    }else{
                        if(endDateMap.get(finalKey) == null){
                            List<DateTime> nList = new List<DateTime>();
                            nList.add(startDate1);
                            endDateMap.put(finalKey, nList);  
                        }else{
                            List<DateTime> nList = endDateMap.get(finalKey);
                            nList.add(startDate1);
                            endDateMap.put(finalKey, nList); 
                        }
                        
                    }
                    
                    //  endDateMap.put(finalKey,startDate1);
                }
                            }
                        Map<String,List<Wrapper2>> timeSlotMap = new Map<String,List<Wrapper2>>();
            for(ElixirSuite__Work_Schedule__c wr:workSch){
                String finalKey = String.valueof(wr.ElixirSuite__Practitioner_Name__c) + String.valueof(wr.ElixirSuite__Provider_Location__c);
                String apType = practLocaVsApt.get(finalKey);
                breakTime = appTypeDuration.get(apType);
                Date startDate2 =  (wr.ElixirSuite__Start_Date__c > startDate) ? wr.ElixirSuite__Start_Date__c:startDate;
                //   while(startDate2 <= wr.ElixirSuite__End_Date__c){
                /*   if(pracVsSlot.get(finalKey) != null){
break;
}*/
                DateTime myDateTime = (DateTime) startDate2;
                String dayOfWeek = myDateTime.format('EEEE');
                Date nextSlotDate = fetchNextSlotDate(myDateTime, wr.ElixirSuite__Days__c);
                    
                    DateTime startDT = DateTime.newInstance(nextSlotDate, wr.ElixirSuite__Start_Time__c);
                    
                    while(startDT.addMinutes(breakTime) <= DateTime.newInstance(nextSlotDate, wr.ElixirSuite__End_Time__c)){
                        
                        if(pracVsSlot.get(finalKey) != null){
                            break;
                        }
                        if(startDT >= (DateTime.now()).addMinutes(30) && (startDateMap.get(finalKey) == null || (startDateMap.get(finalKey) != null && !(startDateMap.get(finalKey).contains(startDT)))) && (endDateMap.get(finalKey) == null || (endDateMap.get(finalKey) != null && !(endDateMap.get(finalKey).contains(startDT.addMinutes(breakTime))))))
                        {
                            Datetime value = DateTime.newInstance(nextSlotDate.year(), nextSlotDate.month(), nextSlotDate.day());
                            List<Wrapper2> wrpr = timeSlotMap.get((value).format('yyyy-MM-dd'));
                            
                            if(pracVsSlot== null || pracVsSlot.isEmpty()){
                                String nextAvailSlot = value.format('yyyy-MM-dd') +' '+ startDT.format('hh:mm aa');
                                pracVsSlot.put(finalKey, nextAvailSlot);
                                break;
                            }else{
                                if(pracVsSlot.get(finalKey) == null){
                                    String nextAvailSlot = value.format('yyyy-MM-dd') +' '+ startDT.format('hh:mm aa');
                                    pracVsSlot.put(finalKey, nextAvailSlot);  
                                    break;
                                }
                            }
                            
                        }
                        //}
                        
                        startDT = startDT.addMinutes(slotsDifference);
                        
                    }
                                startDate2 = startDate2.addDays(1);
                //   }
                
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return pracVsSlot;
        
    }
    
    //added by vishal to handle 'IsPortalEnabled' field on user
    public static String fetchUserQuery(String preQuery){
        ElixirSuite__Elixir_Custom_Setting__c listCS = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        if(listCS.ElixirSuite__Enable_portal_in_Elixir__c){
            preQuery+=',IsPortalEnabled';
            return preQuery;
        }
        else {
            return preQuery; // 
        }
    }
    

       //added by Anmol for LX3-7236
       public static boolean checkCareEpisodeUtility(string patientId){
        
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
        if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
        String careStatus = 'Active';

        string querystr = '';
        querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Account__c =: patientId WITH SECURITY_ENFORCED order by ';
        querystr += careFilter ;
        List<ElixirSuite__Visits__c> listCareEpisode = database.query(querystr);

        boolean checkAllStatus=true;
        Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();

        for(ElixirSuite__Visits__c exVar:listCareEpisode){
        if(exVar.ElixirSuite__Status__c=='Active'){
        checkAllStatus=false;  
        }
        }
        if(checkAllStatus && mcs.ElixirSuite__CareEpisode__c){
        return true;
        }else{
        return false;
        }

}
//end by Anmol for LX3-7236

    public class Wrapper3{
        @AuraEnabled public Map<String,String> pracLocVsAptTyp;
        @AuraEnabled public List<String> appTypLstWrp;
        
    }
    
    public class Wrapper2{
        @AuraEnabled public DateTime startDate;
        @AuraEnabled public String startTime;
        @AuraEnabled public DateTime endDate;
        @AuraEnabled public String startDateTime;
        @AuraEnabled public String endDateTime;
        
    }
    
     @AuraEnabled(cacheable=true)
     public static list<Elixir_Custom_Setting__c> getNamespaceCustomSetting(){
        String namespace;
        list<Elixir_Custom_Setting__c> record = [Select id,Namespace__c from Elixir_Custom_Setting__c WITH SECURITY_ENFORCED limit 1];

        return record;
    } 
    
    public static String getNamespace(){
        String namespace;
        Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        // system.debug('lk' + record);
        try{
        if(record!=null) {
            System.debug('record '+record.Namespace__c);
           
            if(String.isBlank(record.Namespace__c)){
                namespace = '';
            }
            else{
                namespace = record.Namespace__c;
            }
        }
        else{
            namespace = '';
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
           }
        return namespace;
    }
    public static Boolean getLeadTriggerExecution(){
        Boolean isLeadTrigger;
        Elixir_Custom_Setting__c record = Elixir_Custom_Setting__c.getOrgDefaults();
        // system.debug('lk' + record);
        try{
        if(record!=null) {
            System.debug('record '+record.ElixirSuite__IsLeadTriggerExecution__c);
            isLeadTrigger = record.ElixirSuite__IsLeadTriggerExecution__c;
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
           }
        return isLeadTrigger;
    }
    
    public static DateTime dateTimeConversion(String dateTimeValue){
        try{
        if(dateTimeValue!=null){
            dateTimeValue = dateTimeValue.replace('T', ' ');
            Datetime now = DateTime.valueOf(dateTimeValue);
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset/1000);
            return local;
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
           }
        return null;
    }
    public static void attachProcedureEncounter(List<sObject> defaultProcedures, String accountId,Id sObjectId ,String starttimeProcedure , String endtimeProcedure){
        //sObject defaultProcedure = defaultProcedures[0];
        Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
        
        Visits__c[] lastCreatedEncounter =  [SELECT Id FROM Visits__c 
                                             WHERE Account__c=:accountId
                                             WITH SECURITY_ENFORCED
                                              ORDER BY CreatedDate DESC limit 1];
        String sObjName = sObjectId.getSObjectType().getDescribe().getName();
        
        /*   if (lastCreatedEncounter!=null && lastCreatedEncounter.size() > 0) {                                                                                                                                                                                     
defaultProcedure.put('Visits__c',lastCreatedEncounter[0].id);                                                  

}*/
        //else create a default procedure which will not be attached to any encounter as there is  none in the org.  
        //  system.debug('the val' + defaultProcedure);                                                 
        //    insert defaultProcedure ;   
        Procedure__c newProcedure = new Procedure__c();
        newProcedure.Account__c=accountId; 
        newProcedure.RecordTypeId = devRecordTypeId;
        newProcedure.From_Date__c = date.valueOf(starttimeProcedure) ;
        newProcedure.Start_Time__c = date.valueOf(starttimeProcedure) ;
        newProcedure.To_Date__c = date.valueOf(endtimeProcedure) ;
        newProcedure.End_Time__c = date.valueOf(endtimeProcedure) ;
        newProcedure.put('ElixirSuite__Start_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure));
        newProcedure.put('ElixirSuite__End_Time__c' , Elixir_utility.dateTimeConversion(endtimeProcedure)); 
        newProcedure.Name = 'Form procedure';
        
     
        system.debug('the proc is' + newProcedure);
        try{
          if(Schema.sObjectType.Procedure__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Name.isCreateable() 
            ){
        insert newProcedure;
            }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
           }
        
    }
    //for updation
    public static void attachExistingProcedureEncounter(List<sObject> defaultProcedures, String accountId,Id sObjectId ,
                                                        String starttimeProcedure , String endtimeProcedure){
        sObject defaultProcedure = defaultProcedures[0];
        List<Procedure__c> proceduresList = new  List<Procedure__c>();
        Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
        
        String sObjName = sObjectId.getSObjectType().getDescribe().getName();
        /* if(sObjName.equalsIgnoreCase('FORM__c')){
proceduresList = [SELECT Id FROM HealthCloudGA__EHRProcedure__c WHERE Form__c= :sObjectId AND Ehr_Procedure__c=NULL];
}else if(sObjName.equalsIgnoreCase('ASAM_FORM__c')){
system.debug('*******************');
proceduresList = [SELECT Id FROM HealthCloudGA__EHRProcedure__c WHERE ASAM_FORMS__c= :sObjectId AND Ehr_Procedure__c=NULL];
}
else if(sObjName.equalsIgnoreCase('HealthCloudGA__EHRProcedureRequest__c')){
system.debug('*******************');
proceduresList = [SELECT Id FROM HealthCloudGA__EHRProcedure__c WHERE Ehr_LabOrder__c= :sObjectId AND Ehr_Procedure__c=NULL];
}else if(sObjName.equalsIgnoreCase('Bed__c')){
proceduresList = [SELECT Id FROM HealthCloudGA__EHRProcedure__c WHERE Bed__c= :sObjectId AND Ehr_Procedure__c=NULL];
}else if(sObjName.equalsIgnoreCase('Prescription_Order__c')){
proceduresList = [SELECT Id FROM HealthCloudGA__EHRProcedure__c WHERE Ehr_Prescription_Order__c= :sObjectId AND Ehr_Procedure__c=NULL];
}
*/
        // if(proceduresList!=null && proceduresList.size()>0){
        system.debug('************555555*******');
        Visits__c[] lastCreatedEncounter =  [SELECT Id FROM Visits__c 
                                             WHERE Account__c=:accountId 
                                             WITH SECURITY_ENFORCED
                                             ORDER BY CreatedDate DESC limit 1];
        if (lastCreatedEncounter!=null && lastCreatedEncounter.size() > 0) {                                                                                                                                                                                     
            defaultProcedure.put('Visits__c',lastCreatedEncounter[0].id);                                                  
            
        }
        defaultProcedure.put('Start_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure));
        defaultProcedure.put('End_Time__c' , Elixir_utility.dateTimeConversion(endtimeProcedure));
        defaultProcedure.put('RecordTypeId' , devRecordTypeId);
        defaultProcedure.put('From_Date__c' , date.valueOf(starttimeProcedure));
        defaultProcedure.put('To_Date__c' , date.valueOf(endtimeProcedure));
        defaultProcedure.put('Account__c' , accountId);
        defaultProcedure.put('Name' , 'Edited Form Procedure');
        
        //  defaultProcedure.put('Ehr_procedure__c',proceduresList[0].Id); 
          try{
          if(Schema.sObjectType.Procedure__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Name.isCreateable() 
            ){
        //insert defaultProcedures;
        DMLManager.insertAsUser(defaultProcedures);
            }
        //   }
          }
         catch(Exception e){
         ExceptionLog.logError(e);
           }
        
    }
    public static void createNewProcedure(String starttimeProcedure , String endtimeProcedure ,Treatment_Plan__c newTP ,fflib_SObjectUnitOfWork uow,
                                          Id accountId , List<Visits__c> lastCreatedEncounter, Id existingProcedure){
                                              Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
                                              Procedure__c defaultProcedure = new Procedure__c();
                                              defaultProcedure.start_time__c = Elixir_utility.dateTimeConversion(starttimeProcedure);
                                              defaultProcedure.end_time__c = Elixir_utility.dateTimeConversion(endtimeProcedure); 
                                              //uow.registerRelationship(defaultProcedure, HealthCloudGA__EHRProcedure__c.Case__c , newCase);
                                              defaultProcedure.Account__c=accountId;  
                                              //    system.debug(existingProcedure);  
                                              defaultProcedure.RecordTypeId = devRecordTypeId;
                                              defaultProcedure.From_Date__c = date.valueOf(starttimeProcedure) ;
                                              defaultProcedure.To_Date__c = date.valueOf(endtimeProcedure) ;
                                              
                                              //  defaultProcedure.Ehr_procedure__c = existingProcedure;
                                              system.debug(defaultProcedure);
                                              try{
                                              if (lastCreatedEncounter.size() > 0) {  
                                                  //defaultProcedure.HealthCloudGA__Account__c=accountId;                                                                  
                                                  defaultProcedure.Visits__c=lastCreatedEncounter[0].id;                                                 
                                              }
                                              if(Schema.sObjectType.Procedure__c.isCreateable() &&
                                              Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
                                              Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() &&
                                              Schema.sObjectType.Procedure__c.fields.Visits__c.isCreateable() &&
                                              Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
                                              Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
                                              Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
                                              Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
                                              Schema.sObjectType.Procedure__c.fields.Name.isCreateable()){
                                                insert defaultProcedure;
                                             }
                                            
                                          }
                                              catch(Exception e){
                                              ExceptionLog.logError(e);
                                             }
                                          }
                                          public static Boolean fetchCreateProcedureReturnValue(){
                                            Boolean checkValue;
                                            Elixir_Custom_Setting__c[] lstObj = [SELECT ID,Create_Procedures_Automatically__c FROM Elixir_Custom_Setting__c WITH SECURITY_ENFORCED LIMIT 1];
                                             if(lstObj!=null && lstObj.size()>0){
                                             checkValue = lstObj[0].Create_Procedures_Automatically__c;
                                             }
                                             return checkValue;
                                             }
    public static Date fetchNextSlotDate(Datetime startDateOfWS, String days){
        Map<String, Integer> daysMap = new Map<String, Integer>{
            'Sunday' => 1,
            'Monday' => 2,
            'Tuesday' => 3,
            'Wednesday' => 4,
            'Thursday' => 5,
            'Friday' => 6,
            'Saturday' => 7
        };
        Integer closestOffset = -1;
        for(String day :days.split(';')){
            Integer dayOffset = daysMap.get(day);
            Integer todayOffset = daysMap.get(startDateOfWS.format('EEEE', 'GMT'));
            Integer daysDifference = dayOffset - todayOffset;
            if (daysDifference < 0) {
                daysDifference += 7;
            }
            if(closestOffset == -1){
                closestOffset = daysDifference;
            }
            if(closestOffset>daysDifference){
                closestOffset = daysDifference;
            }
        }
        Date futureDate = Date.valueOf(startDateOfWS).addDays(closestOffset);
        return futureDate; 
    }
    public static Integer fetchSlotsDifference(){
        ElixirSuite__Elixir_Custom_Setting__c listCS = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        if(listCS == null){
            return 15;
        }
        return Integer.valueOf(listCS.ElixirSuite__Appointment_s_Slot_Interval__c);
    }
    /*
public static void bulkTriggerAllergyInsert(List<Medical_Examination__c> triggerList){
List<Visits__c> lastCreatedEncounter = new List<Visits__c>();
List<Procedure__c> proceduresToInsert = new List<Procedure__c>();
List<Procedure__c> masterProceduresToInsert = new List<Procedure__c>();
Map<Id,Visits__c> mapOfAccountToEnconuterLists = new Map<Id,Visits__c>();
Set<Id> accIds = new set<Id>();
for(Medical_Examination__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){
accIds.add(rec.Account__c);  
}           
}
if(accIds.size()>0){
lastCreatedEncounter =  [SELECT Id,Account__c FROM Visits__c
WHERE Account__c IN :accIds ORDER BY CreatedDate DESC limit 9000];
}

for(Visits__c rec : lastCreatedEncounter){
if(!mapOfAccountToEnconuterLists.containsKey(rec.Account__c)){
mapOfAccountToEnconuterLists.put(rec.Account__c , rec);
}            
}

for(Medical_Examination__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){                             
Procedure__c masterProcedure = new Procedure__c();
if(mapOfAccountToEnconuterLists.containsKey(rec.Account__c)){
masterProcedure.Visits__C = mapOfAccountToEnconuterLists.get(rec.Account__c).Id;
}
masterProcedure.Account__c = rec.Account__c;
//    masterProcedure.Ehr_Allergy__c =  rec.Id;
masterProceduresToInsert.add(masterProcedure);

}

}
if(masterProceduresToInsert.size()>0){
insert masterProceduresToInsert;
}

Integer i = 0;
for(Medical_Examination__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){   
Procedure__c defaultProcedure = new Procedure__c();
defaultProcedure.Start_Time__c =  rec.Start_Time__c;
defaultProcedure.End_Time__c = rec.End_Time__c;
if(mapOfAccountToEnconuterLists.containsKey(rec.Account__c)){
defaultProcedure.Visits__c = mapOfAccountToEnconuterLists.get(rec.Account__c).Id;
}
defaultProcedure.Account__c = rec.Account__c;
//  defaultProcedure.Ehr_Allergy__c =  rec.Id;             
//  defaultProcedure.Ehr_procedure__c = masterProceduresToInsert[i].Id;
proceduresToInsert.add(defaultProcedure);
i++;
}
}
if(proceduresToInsert.size()>0){
insert proceduresToInsert;
}

}
public static void bulkTriggerAllergyUpdate(List<HealthCloudGA__EhrAllergyIntolerance__c> triggerList){
List<HealthCloudGA__EhrEncounter__c> lastCreatedEncounter = new List<HealthCloudGA__EhrEncounter__c>();
List<HealthCloudGA__EHRProcedure__c> proceduresToUpdate= new List<HealthCloudGA__EHRProcedure__c>();
Map<Id,HealthCloudGA__EhrEncounter__c> mapOfAccountToEnconuterLists = new Map<Id,HealthCloudGA__EhrEncounter__c>();
Set<Id> accIds = new Set<Id>();
Set<Id> allergyIds = new Set<Id>();
for(HealthCloudGA__EhrAllergyIntolerance__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){
accIds.add(rec.HealthCloudGA__Account__c);  
allergyIds.add(rec.Id);
}           
}
if(accIds.size()>0){
lastCreatedEncounter =  [SELECT Id,HealthCloudGA__Account__c FROM HealthCloudGA__EhrEncounter__c 
WHERE HealthCloudGA__Account__c IN :accIds ORDER BY CreatedDate DESC limit 9000];
}

for(HealthCloudGA__EhrEncounter__c rec : lastCreatedEncounter){
if(!mapOfAccountToEnconuterLists.containsKey(rec.HealthCloudGA__Account__c)){
mapOfAccountToEnconuterLists.put(rec.HealthCloudGA__Account__c , rec);
}            
}       
List<HealthCloudGA__EHRProcedure__c> listOfProcedures = [SELECT Id,Ehr_Allergy__c,HealthCloudGA__Account__c FROM HealthCloudGA__EHRProcedure__c WHERE Ehr_Allergy__c IN :allergyIds AND Ehr_procedure__c=NULL];
Map<Id,HealthCloudGA__EHRProcedure__c> mapOfIdToParentPro = new Map<Id,HealthCloudGA__EHRProcedure__c>();
if(listOfProcedures!=null && listOfProcedures.size()>0){
for(HealthCloudGA__EHRProcedure__c proRec :listOfProcedures){
if(! mapOfIdToParentPro.containsKey(proRec.Ehr_Allergy__c)){
mapOfIdToParentPro.put(proRec.Ehr_Allergy__c,proRec);
}
}

}
for(HealthCloudGA__EhrAllergyIntolerance__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){
HealthCloudGA__EHRProcedure__c defaultProcedure = new HealthCloudGA__EHRProcedure__c();
defaultProcedure.Start_Time__c =  rec.Start_Time__c;
defaultProcedure.End_Time__c = rec.End_Time__c;
if(mapOfAccountToEnconuterLists.containsKey(rec.HealthCloudGA__Account__c)){
defaultProcedure.HealthCloudGA__Encounter__c = mapOfAccountToEnconuterLists.get(rec.HealthCloudGA__Account__c).Id;
}
defaultProcedure.HealthCloudGA__Account__c = rec.HealthCloudGA__Account__c;
defaultProcedure.Ehr_Allergy__c = rec.Id;
defaultProcedure.Ehr_procedure__c = Id.valueOf(String.valueOf(mapOfIdToParentPro.get(rec.Id).get('Id')));
proceduresToUpdate.add(defaultProcedure); 

}
}
if(proceduresToUpdate.size()>0){
insert proceduresToUpdate;
}

}
public static void bulkTriggerVitalSignsInsert(List<HealthCloudGA__EhrObservation__c> triggerList){
List<HealthCloudGA__EhrEncounter__c> lastCreatedEncounter = new List<HealthCloudGA__EhrEncounter__c>();
List<HealthCloudGA__EHRProcedure__c> proceduresToInsert = new List<HealthCloudGA__EHRProcedure__c>();
List<HealthCloudGA__EHRProcedure__c> masterProceduresToInsert = new List<HealthCloudGA__EHRProcedure__c>();
Map<Id,HealthCloudGA__EhrEncounter__c> mapOfAccountToEnconuterLists = new Map<Id,HealthCloudGA__EhrEncounter__c>();
Set<Id> accIds = new set<Id>();
for(HealthCloudGA__EhrObservation__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){
accIds.add(rec.HealthCloudGA__Account__c);  
}           
}
if(accIds.size()>0){
lastCreatedEncounter =  [SELECT Id,HealthCloudGA__Account__c FROM HealthCloudGA__EhrEncounter__c 
WHERE HealthCloudGA__Account__c IN :accIds ORDER BY CreatedDate DESC limit 9000];
}

for(HealthCloudGA__EhrEncounter__c rec : lastCreatedEncounter){
if(!mapOfAccountToEnconuterLists.containsKey(rec.HealthCloudGA__Account__c)){
mapOfAccountToEnconuterLists.put(rec.HealthCloudGA__Account__c , rec);
}            
}

for(HealthCloudGA__EhrObservation__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){                             
HealthCloudGA__EHRProcedure__c masterProcedure = new HealthCloudGA__EHRProcedure__c();
if(mapOfAccountToEnconuterLists.containsKey(rec.HealthCloudGA__Account__c)){
masterProcedure.HealthCloudGA__Encounter__c = mapOfAccountToEnconuterLists.get(rec.HealthCloudGA__Account__c).Id;
}
masterProcedure.HealthCloudGA__Account__c = rec.HealthCloudGA__Account__c;
masterProcedure.Ehr_vitals__c =  rec.Id;
masterProceduresToInsert.add(masterProcedure);

}

}
if(masterProceduresToInsert.size()>0){
insert masterProceduresToInsert;
}

Integer i = 0;
for(HealthCloudGA__EhrObservation__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){   
HealthCloudGA__EHRProcedure__c defaultProcedure = new HealthCloudGA__EHRProcedure__c();
defaultProcedure.Start_Time__c =  rec.Start_Time__c;
defaultProcedure.End_Time__c = rec.End_Time__c;
if(mapOfAccountToEnconuterLists.containsKey(rec.HealthCloudGA__Account__c)){
defaultProcedure.HealthCloudGA__Encounter__c = mapOfAccountToEnconuterLists.get(rec.HealthCloudGA__Account__c).Id;
}
defaultProcedure.HealthCloudGA__Account__c = rec.HealthCloudGA__Account__c;
defaultProcedure.Ehr_vitals__c =  rec.Id;             
defaultProcedure.Ehr_procedure__c = masterProceduresToInsert[i].Id;
proceduresToInsert.add(defaultProcedure);
i++;
}
}
if(proceduresToInsert.size()>0){
insert proceduresToInsert;
}

}
public static void bulkTriggerVitalSignsUpdate(List<HealthCloudGA__EhrObservation__c> triggerList){
List<HealthCloudGA__EhrEncounter__c> lastCreatedEncounter = new List<HealthCloudGA__EhrEncounter__c>();
List<HealthCloudGA__EHRProcedure__c> proceduresToUpdate= new List<HealthCloudGA__EHRProcedure__c>();
Map<Id,HealthCloudGA__EhrEncounter__c> mapOfAccountToEnconuterLists = new Map<Id,HealthCloudGA__EhrEncounter__c>();
Set<Id> accIds = new Set<Id>();
Set<Id> allergyIds = new Set<Id>();
for(HealthCloudGA__EhrObservation__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){
accIds.add(rec.HealthCloudGA__Account__c);  
allergyIds.add(rec.Id);
}           
}
if(accIds.size()>0){
lastCreatedEncounter =  [SELECT Id,HealthCloudGA__Account__c FROM HealthCloudGA__EhrEncounter__c 
WHERE HealthCloudGA__Account__c IN :accIds ORDER BY CreatedDate DESC limit 9000];
}

for(HealthCloudGA__EhrEncounter__c rec : lastCreatedEncounter){
if(!mapOfAccountToEnconuterLists.containsKey(rec.HealthCloudGA__Account__c)){
mapOfAccountToEnconuterLists.put(rec.HealthCloudGA__Account__c , rec);
}            
}       
List<HealthCloudGA__EHRProcedure__c> listOfProcedures = [SELECT Id,Ehr_vitals__c,HealthCloudGA__Account__c FROM HealthCloudGA__EHRProcedure__c WHERE Ehr_vitals__c IN :allergyIds AND Ehr_procedure__c=NULL];
Map<Id,HealthCloudGA__EHRProcedure__c> mapOfIdToParentPro = new Map<Id,HealthCloudGA__EHRProcedure__c>();
if(listOfProcedures!=null && listOfProcedures.size()>0){
for(HealthCloudGA__EHRProcedure__c proRec :listOfProcedures){
if(! mapOfIdToParentPro.containsKey(proRec.Ehr_vitals__c)){
mapOfIdToParentPro.put(proRec.Ehr_vitals__c,proRec);
}
}

}
for(HealthCloudGA__EhrObservation__c rec: triggerList){
if(rec.Source__c != 'ASSESSMENT'){
HealthCloudGA__EHRProcedure__c defaultProcedure = new HealthCloudGA__EHRProcedure__c();
defaultProcedure.Start_Time__c =  rec.Start_Time__c;
defaultProcedure.End_Time__c = rec.End_Time__c;
if(mapOfAccountToEnconuterLists.containsKey(rec.HealthCloudGA__Account__c)){
defaultProcedure.HealthCloudGA__Encounter__c = mapOfAccountToEnconuterLists.get(rec.HealthCloudGA__Account__c).Id;
}
defaultProcedure.HealthCloudGA__Account__c = rec.HealthCloudGA__Account__c;
defaultProcedure.Ehr_vitals__c = rec.Id;
defaultProcedure.Ehr_procedure__c = Id.valueOf(String.valueOf(mapOfIdToParentPro.get(rec.Id).get('Id')));
proceduresToUpdate.add(defaultProcedure); 

}
}
system.debug(proceduresToUpdate);
if(proceduresToUpdate.size()>0){
insert proceduresToUpdate;
}

}*/
}