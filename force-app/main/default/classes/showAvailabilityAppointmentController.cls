public without sharing class showAvailabilityAppointmentController {
    
    @AuraEnabled
    public static String getPatientId() {
        String patientId='';
        String uId = UserInfo.getUserId();
        List<User> userRecs = Database.query('SELECT id,ContactId,AccountId,IsPortalEnabled FROM User WHERE Id =:uId');
        if((Boolean)userRecs[0].get('IsPortalEnabled')){
            patientId = (String)userRecs[0].get('AccountId');
            return patientId;
        }else{
            return NULL;
        }
    }
    
    // Get Appointment type for Portal
    @AuraEnabled
    public static String getAppointmentTypePortal() {
        String appTypeOptions = '';
        
        Id patientPortalId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        
        List<ElixirSuite__Master_Object__c> recordList = [
            SELECT Id,ElixirSuite__Appointment_types__c 
            FROM ElixirSuite__Master_Object__c 
            WHERE RecordTypeId = :patientPortalId AND ElixirSuite__Patient_Tile_Entity__c = 'Portal Definition' 
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        if (!recordList.isEmpty()) {
            appTypeOptions = recordList[0].ElixirSuite__Appointment_types__c;
        }
        return appTypeOptions;
    }

    //Get getAppointmentType Records
    @AuraEnabled
    public static doInitWrap getAppointmentType(String practName, String locName , Date startDate, Date endDate){
        List<String> result = new List<String>();
        doInitWrap wrap = new doInitWrap();
        
        List<ElixirSuite__Work_Schedule__c> workSch = [Select Id,toLabel(ElixirSuite__Appointment_Types__c)
                                                               FROM ElixirSuite__Work_Schedule__c
                                                               WHERE ElixirSuite__Practitioner_Name__c = :practName
                                                               AND ElixirSuite__Provider_Location__c =:locName
                                                               AND ((ElixirSuite__Start_Date__c >=: startDate)
                                                                    OR (ElixirSuite__End_Date__c >=: startDate)
                                                                    OR (ElixirSuite__Start_Date__c< :startDate))
                                                               WITH SECURITY_ENFORCED];
                
		
        for(Work_Schedule__c apt : workSch){
            if(apt.ElixirSuite__Appointment_Types__c != null){
                if(apt.ElixirSuite__Appointment_Types__c.contains(';')){
                     result.addAll(apt.ElixirSuite__Appointment_Types__c.split(';'));
                }else{
                    result.add(apt.ElixirSuite__Appointment_Types__c);
                }
            }     
        }
        result.sort();
        
        List<Map<String, String>> appList = new  List<Map<String, String>>();
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get('ElixirSuite__Work_Schedule__c').getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
        
        if (fieldsMap.containsKey('ElixirSuite__Appointment_Types__c')) {
            Schema.SObjectField picklistField = fieldsMap.get('ElixirSuite__Appointment_Types__c');
            Schema.DescribeFieldResult fieldDescribe = picklistField.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
            
            for (Schema.PicklistEntry picklistValue : picklistValues) {
                if(result.contains(picklistValue.getLabel())){
                    Map<String, String> type = new Map<String, String>();
                    type.put('Label', picklistValue.getLabel());
                     type.put('value', picklistValue.getValue());
                    appList.add(type);
                }
            }
        }
        String appTypeOptions = getAppointmentTypePortal();

        Elixir_Custom_Setting__c elixirCustom = Elixir_Custom_Setting__c.getOrgDefaults();
        Decimal minDays = elixirCustom.ElixirSuite__Appointment_Min_Search__c;
        Decimal maxDays = elixirCustom.ElixirSuite__Appointment_Max_Search__c;
        if(minDays != null && minDays > 0){
         wrap.minDays = minDays;   
        }else{
            wrap.minDays = 0;
        }
        if(maxDays != null && maxDays > 0){
         wrap.maxDays = maxDays;   
        }else{
            wrap.maxDays = 0;
        }
        wrap.appList = appList;
        wrap.appTypeOptions = appTypeOptions;
        return wrap;
    }

    //Get getBulkAppointmentType Records
    @AuraEnabled
    public static Wrapper3 getBulkAppointmentType(List<String> practNameLst, List<String> locNameLst , Date startDate){
        List<String> result = new List<String>();
        Wrapper3 wrap = new Wrapper3();
        Set<String> appLst = new Set<String>();
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
        return wrap;
    }
    
    public class doInitWrap{
        @AuraEnabled public Decimal minDays;
        @AuraEnabled public Decimal maxDays;
        @AuraEnabled public List<Map<String, String>> appList;
        @AuraEnabled public String appTypeOptions;
    }
    
    public class Wrapper2{
        @AuraEnabled public DateTime startDate;
        @AuraEnabled public String startTime;
        @AuraEnabled public DateTime endDate;
        @AuraEnabled public String startDateTime;
        @AuraEnabled public String endDateTime;
        
    }

    public class Wrapper3{
        @AuraEnabled public Map<String,String> pracLocVsAptTyp;
        @AuraEnabled public List<String> appTypLstWrp;
        
    }
    
    
    @AuraEnabled
    public static Map<String,String> bulkWorkslot(List<String> practName, List<String> locName , Date startDate, List<String> apTypLst, Map<String,String> practLocaVsApt ){
        Integer slotsDifference = Elixir_Utility.fetchSlotsDifference();
        Map<string,Integer> appTypeDuration = new Map<string,Integer>();
        
        List<ElixirSuite__Procedure__c> aptTypeDuration = [SELECT Id, Name, ElixirSuite__Active__c, 
                                                           ElixirSuite__Code_Description__c,ElixirSuite__Long_Description__c, 
                                                           ElixirSuite__Procedure_Duration__c, 
                                                           ElixirSuite__Appointment_Type__c 
                                                           FROM ElixirSuite__Procedure__c 
                                                           where ElixirSuite__Active__c = True 
                                                           AND ElixirSuite__Appointment_Type__c = True
                                                           WITH SECURITY_ENFORCED];
        for(Procedure__c rec : aptTypeDuration){
            appTypeDuration.put(rec.Name, Integer.valueOf(rec.ElixirSuite__Procedure_Duration__c));
        }
        Integer breakTime;
        Map<String,String> pracVsSlot = new Map<String,String>();
     
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
        
        System.debug('line271***'+workSch);
        
        List<Contact> conData = new List<Contact>();
        List<String> practId= new List<String>();
        Map<String,String> userIdVspracId = new Map<String,String>();
        
        conData = [Select Id,Name,ElixirSuite__Practitioner_User__c FROM Contact Where id IN :practName WITH SECURITY_ENFORCED]; 
        if(conData != null && conData.size() > 0){
            for(Contact con : conData){
                System.debug('con***'+con.Name);
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
            System.debug('finalKey***'+finalKey);
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
        
        System.debug('startDateMap***'+startDateMap);
        System.debug('endDateMap***'+endDateMap);
        
        Map<String,List<Wrapper2>> timeSlotMap = new Map<String,List<Wrapper2>>();
        for(ElixirSuite__Work_Schedule__c wr:workSch){
            System.debug('line339***'+wr.Name);
            String finalKey = String.valueof(wr.ElixirSuite__Practitioner_Name__c) + String.valueof(wr.ElixirSuite__Provider_Location__c);
            String apType = practLocaVsApt.get(finalKey);
            breakTime = appTypeDuration.get(apType);
            Date startDate2 =  (wr.ElixirSuite__Start_Date__c > startDate) ? wr.ElixirSuite__Start_Date__c:startDate;
            System.debug('line350***'+startDate2);
            while(startDate2 <= wr.ElixirSuite__End_Date__c){
                DateTime myDateTime = (DateTime) startDate2;
                String dayOfWeek = myDateTime.format('EEEE');
                System.debug('dayOfWeek***'+dayOfWeek);
                if((wr.ElixirSuite__Days__c).containsIgnoreCase(dayOfWeek)){
                    System.debug('line356***');
                    DateTime startDT = DateTime.newInstance(startDate2, wr.ElixirSuite__Start_Time__c);
                    System.debug('startDT @ '+startDT);
                    while(startDT.addMinutes(breakTime) <= DateTime.newInstance(startDate2, wr.ElixirSuite__End_Time__c)){
                        System.debug('line360***');
                        //if(startDateMap.get(finalKey) != null && endDateMap.get(finalKey) != null ){
                        if(startDT >= (DateTime.now()).addMinutes(30) && (startDateMap.get(finalKey) == null || (startDateMap.get(finalKey) != null && !(startDateMap.get(finalKey).contains(startDT)))) && (endDateMap.get(finalKey) == null || (endDateMap.get(finalKey) != null && !(endDateMap.get(finalKey).contains(startDT.addMinutes(breakTime))))))
                        {
                            System.debug('line363***');
                            Datetime value = DateTime.newInstance(startDate2.year(), startDate2.month(), startDate2.day());
                            List<Wrapper2> wrpr = timeSlotMap.get((value).format('yyyy-MM-dd'));
                            //List<Wrapper2> wrpr = timeSlotMap.get(((DateTime)startDate2).format('yyyy-MM-dd'));
                           // toAvoidNestedIf(wrpr,startDT,breakTime,timeSlotMap,value);
                            
                            
                            if(pracVsSlot== null || pracVsSlot.isEmpty()){
                                System.debug('line***373'+startDT);
                                System.debug('%%%%%%%*** '+startDT.format('hh:mm aa'));
                                String nextAvailSlot = value.format('yyyy-MM-dd') +' '+ startDT.format('hh:mm aa');
                               // String abc = startDT.format(dateformat,''+userinfo.getTimeZone().toString());
                                pracVsSlot.put(finalKey, nextAvailSlot); 
                            }else{
                                if(pracVsSlot.get(finalKey) == null){
                                    System.debug('line***377'+startDT);
                                    System.debug('%%%%%%%*** '+startDT.format('hh:mm aa'));
                                    String nextAvailSlot = value.format('yyyy-MM-dd') +' '+ startDT.format('hh:mm aa');
                                    //String abc = startDT.format(dateformat,''+userinfo.getTimeZone().toString());
                                    pracVsSlot.put(finalKey, nextAvailSlot);  
                                }else{
                                    //break;
                                }
                                
                            }
                            
                            
                        }
                    //}
                        
                        startDT = startDT.addMinutes(slotsDifference);
                        
                    }
                }else{
                    /*
                    System.debug('line388***');
                    List<Wrapper2> wrpr = timeSlotMap.get(((DateTime)startDate2).format('yyyy-MM-dd'));
                    if(wrpr == null){
                        System.debug('line391***');
                        List<wrapper2> wrp1 = new List<wrapper2>(); 
                        Datetime value = DateTime.newInstance(startDate2.year(), startDate2.month(), startDate2.day());
                        timeSlotMap.put(value.format('yyyy-MM-dd'),wrp1); 
                        timeSlotMap.put(((DateTime)startDate2).format('yyyy-MM-dd'),wrp1);  
                        
                        if(pracVsSlot== null){
                            System.debug('line***403'+value);
                            pracVsSlot.put(finalKey, value); 
                        }else{
                            if(pracVsSlot.get(finalKey) == null){
                                System.debug('line***407'+value);
                                pracVsSlot.put(finalKey, value);  
                            }else{
                            }
                            
                        }
                        
                    } */
    //comment daal yaha
                }
                startDate2 = startDate2.addDays(1);
            }
            
            
        }
        return pracVsSlot;
        
    }
    
        @AuraEnabled
        public static Map<String,List<Wrapper2>> workslot(String practName, String locName , Date startDate, Date endDate,String aptType ){
        Map<String,List<Wrapper2>> timeSlotMap = new Map<String,List<Wrapper2>>();
            try{
        Integer slotsDifference = Elixir_Utility.fetchSlotsDifference();
        Map<string,String> appTypeDuration = new Map<string,String>();
        List<ElixirSuite__Procedure__c> aptTypeDuration = [SELECT Id, Name, ElixirSuite__Active__c, 
                                                           ElixirSuite__Code_Description__c, ElixirSuite__Procedure_Duration__c, 
                                                           ElixirSuite__Appointment_Type__c 
                                                           FROM ElixirSuite__Procedure__c 
                                                           where ElixirSuite__Active__c = True 
                                                           AND ElixirSuite__Appointment_Type__c = True
                                                           WITH SECURITY_ENFORCED];
        for(Procedure__c rec : aptTypeDuration){
            appTypeDuration.put(rec.Name, rec.ElixirSuite__Procedure_Duration__c);
        }
        Integer breakTime;

        string var = appTypeDuration.get(aptType);
        if(var != null){
            breakTime = Integer.valueOf(var);
        }
        
        
        List<ElixirSuite__Work_Schedule__c> workSch = [Select Id,ElixirSuite__Start_Date__c,
                                                       ElixirSuite__Start_Time__c,ElixirSuite__End_Time__c,
                                                       ElixirSuite__Practitioner_Name__c,
                                                       ElixirSuite__Provider_Location__c,
                                                       ElixirSuite__End_Date__c,ElixirSuite__Days__c,
                                                       ElixirSuite__Appointment_Types__c
                                                       FROM ElixirSuite__Work_Schedule__c
                                                       WHERE ElixirSuite__Practitioner_Name__c = :practName
                                                       AND ElixirSuite__Appointment_Types__c INCLUDES (:aptType)
                                                       AND ElixirSuite__Provider_Location__c =:locName
                                                       AND ((ElixirSuite__Start_Date__c >=: startDate
                                                             AND ElixirSuite__Start_Date__c <=: endDate)
                                                            OR (ElixirSuite__End_Date__c >=: startDate
                                                                AND ElixirSuite__End_Date__c <=: endDate)
                                                            OR (ElixirSuite__Start_Date__c< :startDate
                                                                AND ElixirSuite__End_Date__c> :endDate))
														WITH SECURITY_ENFORCED 
                                                       ORDER BY ElixirSuite__Practitioner_Name__r.Name,
                                                       ElixirSuite__Start_Date__c,
                                                       ElixirSuite__Start_Time__c ];

        
        List<Contact> conData = new List<Contact>();
        String practId='';
        
        conData = [Select id,Name,ElixirSuite__Practitioner_User__c FROM Contact Where id=:practName WITH SECURITY_ENFORCED]; 
        if(conData != null && conData.size() > 0){
             practId = conData[0].ElixirSuite__Practitioner_User__c;
        }
         
        List<Event> entList = [Select Id, WhoId,ElixirSuite__Location__c,StartDateTime,EndDateTime FROM Event Where 
                               OwnerId =:practId
                               AND ElixirSuite__Location__c = :locName
                               AND DAY_ONLY(StartDateTime) >= :startDate
                               AND DAY_ONLY(EndDateTime) <= :endDate
                               AND (ElixirSuite__Status__c = 'Scheduled'
                                    OR ElixirSuite__Status__c = 'Rescheduled')     
                               WITH SECURITY_ENFORCED];
        
        List<DateTime> startDateList = new List<DateTime>();
        List<DateTime> endDateList = new List<DateTime>();
        for(Event ev:entList){
            DateTime startDate1 =  ev.StartDateTime;
            while(startDate1 < ev.EndDateTime){
                startDateList.add(startDate1);
                startDate1 = startDate1.addMinutes(slotsDifference);
                endDateList.add(startDate1);
            }
            
        }
        
        
        for(ElixirSuite__Work_Schedule__c wr:workSch){
            Date startDate2 =  (wr.ElixirSuite__Start_Date__c > startDate) ? wr.ElixirSuite__Start_Date__c:startDate;
            while(startDate2 <= wr.ElixirSuite__End_Date__c && startDate2 <= endDate){
                DateTime myDateTime = (DateTime) startDate2;
                // String dayOfWeek = myDateTime.format('EEEE');

                String dayOfWeek = myDateTime.format('EEEE', 'GMT');
                
                if((wr.ElixirSuite__Days__c).containsIgnoreCase(dayOfWeek)){
                    DateTime startDT = DateTime.newInstance(startDate2, wr.ElixirSuite__Start_Time__c);
                    
                    while(startDT.addMinutes(breakTime) <= DateTime.newInstance(startDate2, wr.ElixirSuite__End_Time__c)){
                        if(startDT >= (DateTime.now()).addMinutes(30) && !(startDateList.contains(startDT)) && !(endDateList.contains(startDT.addMinutes(breakTime))))
                        {
                            Datetime value = DateTime.newInstance(startDate2.year(), startDate2.month(), startDate2.day());
                            List<Wrapper2> wrpr = timeSlotMap.get((value).format('yyyy-MM-dd'));
                            //List<Wrapper2> wrpr = timeSlotMap.get(((DateTime)startDate2).format('yyyy-MM-dd'));
                            toAvoidNestedIf(wrpr,startDT,breakTime,timeSlotMap,value);
                        }
                        
                        
                        startDT = startDT.addMinutes(slotsDifference);
                        
                    }
                }else{
                    
                    List<Wrapper2> wrpr = timeSlotMap.get(((DateTime)startDate2).format('yyyy-MM-dd'));
                    if(wrpr == null){
                        List<wrapper2> wrp1 = new List<wrapper2>(); 
                        Datetime value = DateTime.newInstance(startDate2.year(), startDate2.month(), startDate2.day());
                        timeSlotMap.put(value.format('yyyy-MM-dd'),wrp1); 
                        //timeSlotMap.put(((DateTime)startDate2).format('yyyy-MM-dd'),wrp1);  
                    }
                }
                startDate2 = startDate2.addDays(1);
            }
            
            
        }
            }
    catch(Exception e){
            ExceptionLog.logError(e);
        }
        return timeSlotMap;
        
    }
    @AuraEnabled
    public static List<ShowAvailabilityWrapper> getPracDataForPortal(String practitionerId,Date startDate,Date endDate){
        List<ShowAvailabilityWrapper> wrpList = new List<ShowAvailabilityWrapper>();
        ShowAvailabilityWrapper wrp = new ShowAvailabilityWrapper();
        String firstName = '';
        String middleName = '';
        String lastName = '';
        String pracConId = '';
        List<Contact> conList = [SELECT Id,Practitioner_User__c,LastName,MiddleName,FirstName  FROM Contact WHERE ElixirSuite__Practitioner_User__c=:practitionerId WITH SECURITY_ENFORCED LIMIT 1 ];
        
        if(conList != NULL && conList.size() > 0){
            pracConId = conList[0].Id;
            if(String.isNotBlank(conList[0].FirstName)){
                firstName = conList[0].FirstName; 
            }
            if(String.isNotBlank(conList[0].MiddleName)){
                middleName = conList[0].MiddleName;
            }
            lastName = conList[0].LastName;
            wrp.practitionerName = firstName+' '+middleName+' '+lastName;
            wrp.practitionerId = pracConId;
        }
    
        List<UserLocation__c> pracLocList = [SELECT Id,ElixirSuite__Practitioner__c,Specialty__r.Specialty_Name__c, ElixirSuite__Practitioner__r.Name,Provider__c,Provider__r.Name FROM ElixirSuite__UserLocation__c WHERE ElixirSuite__Practitioner__c =:pracConId WITH SECURITY_ENFORCED];
        if(pracLocList != NULL && pracLocList.size() > 0){
            wrp.locationId = pracLocList[0].Provider__c;
            wrp.locationName = pracLocList[0].Provider__r.Name;
            wrp.specialityName = pracLocList[0].Specialty__r.Specialty_Name__c;
            doInitWrap inWrap = new doInitWrap();
            inWrap = getAppointmentType(wrp.practitionerId, wrp.locationId ,startDate,endDate);
wrp.appointmentType = inWrap.appList;
            //it seems location id is coming different
            //practitionerId passing for getAppointmentType should be contactId
        }
        wrpList.add(wrp);
        return wrpList;
    }
    public class ShowAvailabilityWrapper {
        @AuraEnabled
        public String practitionerName;
        @AuraEnabled
        public String practitionerId;
        @AuraEnabled
        public String locationId;
        @AuraEnabled
        public String locationName;
        @AuraEnabled
        public String specialityName;
        @AuraEnabled
        public List<Map<String, String>> appointmentType;
    }
    public static void toAvoidNestedIf(List<Wrapper2> wrpr,DateTime startDT,Integer breakTime,Map<String,List<Wrapper2>> timeSlotMap,Datetime value){
            if(wrpr != null){
            //wrpr,startDT,breakTime
            wrapper2 wrp2 = new wrapper2();
            wrp2.startDate = startDT;
            wrp2.endDate = startDT.addMinutes(breakTime);
            wrp2.startTime = startDT.format('hh:mm aa');
            wrp2.startDateTime = startDT.format();
            wrp2.endDateTime = (startDT.addMinutes(breakTime)).format();
            wrpr.add(wrp2);
            timeSlotMap.put(value.format('yyyy-MM-dd'),wrpr);

            }else{
            List<wrapper2> wrp1 = new List<wrapper2>();
            wrapper2 wrp2 = new wrapper2();
            wrp2.startDate = startDT;
            wrp2.endDate = startDT.addMinutes(breakTime);
            wrp2.startTime = startDT.format('hh:mm aa');
            wrp2.startDateTime = startDT.format();
            wrp2.endDateTime = (startDT.addMinutes(breakTime)).format();
            wrp1.add(wrp2);
            //timeSlotMap.put(((DateTime)startDate2).format('yyyy-MM-dd'),wrp1);
            timeSlotMap.put(value.format('yyyy-MM-dd'),wrp1);
            }
            }


}