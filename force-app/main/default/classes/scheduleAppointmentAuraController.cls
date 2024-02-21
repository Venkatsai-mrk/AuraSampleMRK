public without sharing class scheduleAppointmentAuraController {
    @AuraEnabled
    public static User getUserInfo() {
        String userId = UserInfo.getUserId(); // current user
        User[] userLst =  Database.query('SELECT ID, FirstName, LastName, Name, Title, Profile.Name,  Email,ContactId,Contact.AccountId,AccountId,IsPortalEnabled From User WHERE ID =: userId LIMIT 1');
        return userLst[0];
    }
    //Get AccountTeamMember Records
    @AuraEnabled
    public static  List<Wrapper> getAccountTeamMember(String accountId,String specialityId,String locationId,String genderVal,String filter){
   
        List<sObject> accTeamList = new List<sObject>();
        List<User> userList = new List<User>();
        List<ElixirSuite__UserLocation__c> junctionList = new List<ElixirSuite__UserLocation__c>();
        List<ElixirSuite__UserLocation__c> totalJunctionList = new List<ElixirSuite__UserLocation__c>();
        Set<Id> userIdLst = new Set<Id>();
        Set<Id> contactIdLst = new Set<Id>();
        List<Contact> contactList = new List<Contact>();
        Set<String> juncPracLst = new Set<String>();
        Set<String> juncLocLst = new Set<String>();
        Map< String, Wrapper1> practLocVsPracInf = new Map< String,Wrapper1>();
        Map< String, String> practLocVsSpec = new Map< String,String>();
        List<Account> accLst = [Select Id,Name 
                                from Account 
                                where Id=:accountId
                                WITH SECURITY_ENFORCED];
        List<String> monthNames = new List<String>{'hello','January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'};
                List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.ElixirSuite__Gender__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String accName;
        String teamMemberRole = 'Practitioner';
        Map< String, Map<String,string>> practLocMap = new Map< String, Map<String,string>>();
        
        List<Wrapper> wrprLst = new List<Wrapper>();
        
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        
        if(accLst != null && accLst.size() > 0){
            accName = accLst[0].Name;
        }
        
        Wrapper alWrpr = new Wrapper();
        
        alWrpr.accountName = accName;
        alWrpr.genderSet = pickListValuesList;
        
        wrprLst.add(alWrpr);
        
        
        
        final Map<String, String> actionToClause = new Map<String, String>{
            'Speciality'=>'ElixirSuite__Specialty__c= :specialityId',
                'Location'=>'ElixirSuite__Provider__c= :locationId',
                'Gender'=>'ElixirSuite__Practitioner__r.ElixirSuite__Gender__c=:genderVal',
                'SpecialityandLocation'=>'ElixirSuite__Specialty__c= :specialityId and ElixirSuite__Provider__c= :locationId',
                'GenderplusBoth'=>'ElixirSuite__Specialty__c= :specialityId and ElixirSuite__Provider__c= :locationId and ElixirSuite__Practitioner__r.ElixirSuite__Gender__c= :genderVal',
                'GenderplusSpeciality'=>'ElixirSuite__Specialty__c= :specialityId and ElixirSuite__Practitioner__r.ElixirSuite__Gender__c= :genderVal',
                'GenderplusLocation'=>'ElixirSuite__Provider__c= :locationId and ElixirSuite__Practitioner__r.ElixirSuite__Gender__c= :genderVal'
                
                };
                    System.debug('actionToClause '+actionToClause);
                    
                    try{
                      //  accTeamList = Database.query('SELECT Id,AccountId, UserId,User.Name,TeamMemberRole FROM AccountTeamMember WHERE AccountId =:accountId and TeamMemberRole=:teamMemberRole' );
                        
                        accTeamList=Database.query('SELECT Id, AccountId, ContactId,Contact.FirstName,Contact.LastName, IsDirect, ElixirSuite__Care_Team_Role__c, ElixirSuite__Contact_Type__c FROM AccountContactRelation WHERE AccountId =:accountId AND IsDirect=false AND ElixirSuite__Contact_Type__c =\'Care team\' ');
                        
                        if(accTeamList != null && accTeamList.size() > 0){
                            for(sObject teamMember : accTeamList){
                                userIdLst.add(String.valueOf(teamMember.get('ContactId')));
                            }
                            Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
                            String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
                            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
                            System.debug('userIdLst '+userIdLst);
                            contactList = [SELECT Id, AccountId, Name, OtherCity, 
                                           OtherState, MailingState, MailingCity, 
                                           ElixirSuite__Practitioner_User__c,Phone 
                                           FROM Contact where 
                                           RecordTypeId=:recordTypeId AND
                                           Id IN :userIdLst AND
                                           ElixirSuite__Practitioner_User__c!=null
                                           WITH SECURITY_ENFORCED];
                            
                            if(contactList != null && contactList.size() > 0){
                                for(Contact conRec : contactList){
                                    contactIdLst.add(conRec.Id);
                                }
                                
                                String defaultQuery = 'SELECT Id,ElixirSuite__Provider__c,ElixirSuite__Next_available_slot__c,ElixirSuite__Provider__r.Name,ElixirSuite__Practitioner__c, ElixirSuite__Practitioner__r.Name,ElixirSuite__Practitioner__r.MailingCity,ElixirSuite__Practitioner__r.ElixirSuite__Gender__c,'
                                    +'ElixirSuite__Practitioner__r.MailingState,ElixirSuite__Practitioner__r.Phone,ElixirSuite__Specialty__c,ElixirSuite__Specialty__r.ElixirSuite__Specialty_Name__c'
                                    +' FROM ElixirSuite__UserLocation__c' 
                                    +' WHERE ElixirSuite__Practitioner__c IN :contactIdLst';
                                
                                System.debug(defaultQuery+' defaultQuery');
                                
                                
                                if(actionToClause.containsKey(filter)){
                                    String filterClause = actionToClause.get(filter);
                                    System.debug(filterClause+' filterClause');
                                    defaultQuery+= ' AND ' + String.escapeSingleQuotes(filterClause) ;
                                    System.debug(defaultQuery+' defaultQuery');
                                }
                                
                                defaultQuery+= ' WITH SECURITY_ENFORCED ORDER BY ElixirSuite__Practitioner__r.Name';
                                
                                junctionList = Database.query(defaultQuery);
                                
                                System.debug(defaultQuery+' defaultQuery');
                                
                                system.debug('test' + junctionList);
                                
                                
                                //
                                for(ElixirSuite__UserLocation__c juncRec : junctionList){
                                    
                                    
                        String finalKey = String.valueof(juncRec.ElixirSuite__Practitioner__c) + String.valueof(juncRec.ElixirSuite__Provider__c);
                        
                        if(practLocVsPracInf== null){
                            Wrapper1 wrp = new Wrapper1();
                            wrp.pracName1 = juncRec.ElixirSuite__Practitioner__r.Name;
                            wrp.pracCity1 = juncRec.ElixirSuite__Practitioner__r.MailingCity;
                            wrp.pracState1 = juncRec.ElixirSuite__Practitioner__r.MailingState;
                            wrp.pracPhone1 = juncRec.ElixirSuite__Practitioner__r.Phone;
                            wrp.practionerId1 = juncRec.ElixirSuite__Practitioner__c;
                            wrp.provLocId1 = juncRec.ElixirSuite__Provider__c;
                            wrp.provName1 = juncRec.ElixirSuite__Provider__r.Name;
                            wrp.nextAvailSlot1 = juncRec.ElixirSuite__Next_available_slot__c;
                            
                            practLocVsPracInf.put(finalKey, wrp); 
                        }else{
                            if(practLocVsPracInf.get(finalKey) == null){
                                Wrapper1 wrp = new Wrapper1();
                                wrp.pracName1 = juncRec.ElixirSuite__Practitioner__r.Name;
                                wrp.pracCity1 = juncRec.ElixirSuite__Practitioner__r.MailingCity;
                                wrp.pracState1 = juncRec.ElixirSuite__Practitioner__r.MailingState;
                                wrp.pracPhone1 = juncRec.ElixirSuite__Practitioner__r.Phone;
                                wrp.practionerId1 = juncRec.ElixirSuite__Practitioner__c;
                                wrp.provLocId1 = juncRec.ElixirSuite__Provider__c;
                                wrp.provName1 = juncRec.ElixirSuite__Provider__r.Name;
                                wrp.nextAvailSlot1 = juncRec.ElixirSuite__Next_available_slot__c;
                                
                                practLocVsPracInf.put(finalKey, wrp); 
                            }
                            
                        }
                        
                        if(practLocVsSpec== null){
                            practLocVsSpec.put(finalKey, juncRec.ElixirSuite__Specialty__r.ElixirSuite__Specialty_Name__c);
                                    }else{
                            if(practLocVsSpec.get(finalKey) == null){
                                practLocVsSpec.put(finalKey, juncRec.ElixirSuite__Specialty__r.ElixirSuite__Specialty_Name__c);
                            }else{
                                String prevSpec = practLocVsSpec.get(finalKey);
                                String latSpec = prevSpec + ' , ' + juncRec.ElixirSuite__Specialty__r.ElixirSuite__Specialty_Name__c;
                                practLocVsSpec.put(finalKey, latSpec); 
                            }
                            
                        }
                        
                        juncPracLst.add(String.valueof(juncRec.ElixirSuite__Practitioner__c));
                        juncLocLst.add(String.valueof(juncRec.ElixirSuite__Provider__c));
                        
                    }
                    
                    Date startDate1 = system.today();
                    List<String> pracStrings = new List<String>(juncPracLst);
                    List<String> locStrings = new List<String>(juncLocLst);
                    
                    /*   showAvailabilityAppointmentController.Wrapper3 appointmentTyp1 = showAvailabilityAppointmentController.getBulkAppointmentType(pracStrings,locStrings,startDate1);
                    Map<String,String> pracLocVsAppTyp = appointmentTyp1.pracLocVsAptTyp;
                    List<String> appTypLst = appointmentTyp1.appTypLstWrp;
                    
                    Map<String,String> pracMap = new Map<String,String>();
                    pracMap = showAvailabilityAppointmentController.bulkWorkslot(pracStrings,locStrings,startDate1,appTypLst,pracLocVsAppTyp);
                    */
                    for(String key : practLocVsSpec.keySet()){
                        
                        Wrapper1 wrp1 = new Wrapper1();
                        wrp1 = practLocVsPracInf.get(key);
                        
                                if((String.isNotBlank(wrp1.nextAvailSlot1) && String.isNotEmpty(wrp1.nextAvailSlot1) ) && wrp1.nextAvailSlot1 != 'No Slots'){
                                        Wrapper wrpr = new Wrapper();
                                        wrpr.pracName = wrp1.pracName1;
                                            wrpr.pracCity = wrp1.pracCity1;
                                            wrpr.pracState = wrp1.pracState1;
                                            wrpr.pracPhone = wrp1.pracPhone1;
                                            wrpr.practionerId = wrp1.practionerId1;
                                            wrpr.locationId = wrp1.provLocId1;
                                            wrpr.nextAvailableSlot = wrp1.nextAvailSlot1;
                                            
                                            wrpr.specialityName = practLocVsSpec.get(key);
                                            wrpr.provName = wrp1.provName1;
                                            //   wrpr.nextAvailableSlot = pracMap.get(key);
                                            System.debug('wrpr'+wrpr);
                                            
                                            wrprLst.add(wrpr);
                                            }
                                            
                                        }
                                        
                                        
                                        System.debug('practLocMap'+practLocMap);
                                                                            
                                }
                            }
                                                
                        
                    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        System.debug('wrprLst****'+wrprLst);
        return wrprLst;
    }
    
    //Get All Provider Records
    @AuraEnabled
    public static  List<Wrapper> getProviders(String accountId,String specialityId,String locationId,String genderVal,String filter){
        //    Integer offset = (pageNumber - 1) * pageSize;
        List<Contact> contactList = new List<Contact>();
        List<ElixirSuite__UserLocation__c> junctionList = new List<ElixirSuite__UserLocation__c>();
        List<ElixirSuite__UserLocation__c> totalJunctionList = new List<ElixirSuite__UserLocation__c>();
        Map< String, Map<String,string>> practLocMap = new Map< String, Map<String,string>>();
        Map< String, String> practLocVsSpec = new Map< String,String>();
        
        Set<Id> contactIdLst = new Set<Id>();
        List<String> monthNames = new List<String>{'hello','January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'};
                List<Wrapper> wrprLst = new List<Wrapper>();
        
        final Map<String, String> actionToClause = new Map<String, String>{
            'Speciality'=>'ElixirSuite__Specialty__c= :specialityId',
                'Location'=>'ElixirSuite__Provider__c= :locationId',
                'Gender'=>'ElixirSuite__Practitioner__r.ElixirSuite__Gender__c=:genderVal',
                'SpecialityandLocation'=>'ElixirSuite__Specialty__c= :specialityId and ElixirSuite__Provider__c= :locationId',
                'GenderplusBoth'=>'ElixirSuite__Specialty__c= :specialityId and ElixirSuite__Provider__c= :locationId and ElixirSuite__Practitioner__r.ElixirSuite__Gender__c= :genderVal',
                'GenderplusSpeciality'=>'ElixirSuite__Specialty__c= :specialityId and ElixirSuite__Practitioner__r.ElixirSuite__Gender__c= :genderVal',
                'GenderplusLocation'=>'ElixirSuite__Provider__c= :locationId and ElixirSuite__Practitioner__r.ElixirSuite__Gender__c= :genderVal'
                
                };
                    
                    System.debug(actionToClause+' actionToClause');
        
        try{
            Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
            String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
            Id recordTypeId =
                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                .get(contactRecType).getRecordTypeId();
            
            contactList = [SELECT Id, AccountId, Name, OtherCity,
                           ElixirSuite__Practitioner_User__c ,
                           OtherState, MailingState, MailingCity, 
                           Phone FROM Contact where 
                           RecordTypeId=:recordTypeId AND
                           ElixirSuite__Practitioner_User__c!=null
                           WITH SECURITY_ENFORCED];
            
            if(contactList != null && contactList.size() > 0){
                for(Contact conRec : contactList){
                    contactIdLst.add(conRec.Id);
                }
                
                String defaultQuery = 'SELECT Id,ElixirSuite__Provider__c,ElixirSuite__Next_available_slot__c,ElixirSuite__Provider__r.Name,ElixirSuite__Practitioner__c, ElixirSuite__Practitioner__r.Name,ElixirSuite__Practitioner__r.MailingCity,ElixirSuite__Practitioner__r.ElixirSuite__Gender__c,'
                    +'ElixirSuite__Practitioner__r.MailingState,ElixirSuite__Practitioner__r.Phone,ElixirSuite__Specialty__c,ElixirSuite__Specialty__r.ElixirSuite__Specialty_Name__c'
                    +' FROM ElixirSuite__UserLocation__c' 
                    +' WHERE ElixirSuite__Practitioner__c IN :contactIdLst';
                
                System.debug(defaultQuery+' defaultQuery');
                
                
                if(actionToClause.containsKey(filter)){
                    String filterClause = actionToClause.get(filter);
                    System.debug(filterClause+' filterClause');
                    defaultQuery+= ' AND ' +  String.escapeSingleQuotes(filterClause);
                    System.debug(defaultQuery+' defaultQuery');
                }
                
                
                defaultQuery+= ' WITH SECURITY_ENFORCED ORDER BY ElixirSuite__Practitioner__r.Name';
                System.debug(defaultQuery+' defaultQuery');
                
                junctionList = Database.query(defaultQuery);
                
                
                
                system.debug('test' + junctionList);
                
                Set<String> juncPracLst = new Set<String>();
                Set<String> juncLocLst = new Set<String>();
                Map< String, Wrapper1> practLocVsPracInf = new Map< String,Wrapper1>();
                for(ElixirSuite__UserLocation__c juncRec : junctionList){
                    String finalKey = String.valueof(juncRec.ElixirSuite__Practitioner__c) + String.valueof(juncRec.ElixirSuite__Provider__c);
                    
                    if(practLocVsPracInf== null){
                        Wrapper1 wrp = new Wrapper1();
                        wrp.pracName1 = juncRec.ElixirSuite__Practitioner__r.Name;
                        wrp.pracCity1 = juncRec.ElixirSuite__Practitioner__r.MailingCity;
                        wrp.pracState1 = juncRec.ElixirSuite__Practitioner__r.MailingState;
                        wrp.pracPhone1 = juncRec.ElixirSuite__Practitioner__r.Phone;
                        wrp.practionerId1 = juncRec.ElixirSuite__Practitioner__c;
                        wrp.provLocId1 = juncRec.ElixirSuite__Provider__c;
                        wrp.provName1 = juncRec.ElixirSuite__Provider__r.Name;
                        wrp.nextAvailSlot1 = juncRec.ElixirSuite__Next_available_slot__c;
                        
                        practLocVsPracInf.put(finalKey, wrp); 
                    }else{
                        if(practLocVsPracInf.get(finalKey) == null){
                            Wrapper1 wrp = new Wrapper1();
                            wrp.pracName1 = juncRec.ElixirSuite__Practitioner__r.Name;
                            wrp.pracCity1 = juncRec.ElixirSuite__Practitioner__r.MailingCity;
                            wrp.pracState1 = juncRec.ElixirSuite__Practitioner__r.MailingState;
                            wrp.pracPhone1 = juncRec.ElixirSuite__Practitioner__r.Phone;
                            wrp.practionerId1 = juncRec.ElixirSuite__Practitioner__c;
                            wrp.provLocId1 = juncRec.ElixirSuite__Provider__c;
                            wrp.provName1 = juncRec.ElixirSuite__Provider__r.Name;
                            wrp.nextAvailSlot1 = juncRec.ElixirSuite__Next_available_slot__c;
                            
                            practLocVsPracInf.put(finalKey, wrp); 
                        }
                        
                    }
                    
                    if(practLocVsSpec== null){
                        practLocVsSpec.put(finalKey, juncRec.ElixirSuite__Specialty__r.ElixirSuite__Specialty_Name__c); 
                    }else{
                        if(practLocVsSpec.get(finalKey) == null){
                            practLocVsSpec.put(finalKey, juncRec.ElixirSuite__Specialty__r.ElixirSuite__Specialty_Name__c);
}else{
                            String prevSpec = practLocVsSpec.get(finalKey);
                            String latSpec = prevSpec + ' , ' + juncRec.ElixirSuite__Specialty__r.ElixirSuite__Specialty_Name__c;
                            practLocVsSpec.put(finalKey, latSpec); 
                        }
                        
                    }
                    
                    juncPracLst.add(String.valueof(juncRec.ElixirSuite__Practitioner__c));
                    juncLocLst.add(String.valueof(juncRec.ElixirSuite__Provider__c));
                            
                        }
                        
                Date startDate1 = system.today();
                List<String> pracStrings = new List<String>(juncPracLst);
                List<String> locStrings = new List<String>(juncLocLst);
                /*
                showAvailabilityAppointmentController.Wrapper3 appointmentTyp1 = showAvailabilityAppointmentController.getBulkAppointmentType(pracStrings,locStrings,startDate1);
                Map<String,String> pracLocVsAppTyp = appointmentTyp1.pracLocVsAptTyp;
                List<String> appTypLst = appointmentTyp1.appTypLstWrp;
                
                Map<String,String> pracMap = new Map<String,String>();
                pracMap = showAvailabilityAppointmentController.bulkWorkslot(pracStrings,locStrings,startDate1,appTypLst,pracLocVsAppTyp);
                */
                System.debug('practLocMap'+practLocMap);
                
                for(String key : practLocVsSpec.keySet()){
                    
                    Wrapper1 wrp1 = new Wrapper1();
                    wrp1 = practLocVsPracInf.get(key);
                    
                        if((String.isNotBlank(wrp1.nextAvailSlot1) && String.isNotEmpty(wrp1.nextAvailSlot1) ) && wrp1.nextAvailSlot1 != 'No Slots'){
                        Wrapper wrpr = new Wrapper();
                        wrpr.pracName = wrp1.pracName1;
                            wrpr.pracCity = wrp1.pracCity1;
                            wrpr.pracState = wrp1.pracState1;
                            wrpr.pracPhone = wrp1.pracPhone1;
                            wrpr.practionerId = wrp1.practionerId1;
                            wrpr.locationId = wrp1.provLocId1;
                            wrpr.nextAvailableSlot = wrp1.nextAvailSlot1;
                            
                            wrpr.specialityName = practLocVsSpec.get(key);
                            wrpr.provName = wrp1.provName1;
                            //   wrpr.nextAvailableSlot = pracMap.get(key);
                            System.debug('wrpr'+wrpr);
                            
                            wrprLst.add(wrpr);
                            }
                                            
                }
                
                            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        System.debug('wrprLst****'+wrprLst);
        
        return wrprLst;
    }
    
    public class Wrapper{
        @AuraEnabled public String accountName;
        @AuraEnabled public String specialityName;
        @AuraEnabled public List<ElixirSuite__UserLocation__c> lstOfData;
        @AuraEnabled public List<String> genderSet;
        @AuraEnabled public Integer totalJuncRec;
        @AuraEnabled public Map< String, Map<String,string>> practionerToLocMap;
        @AuraEnabled public String pracName;
        @AuraEnabled public String pracCity;
        @AuraEnabled public String pracState;
        @AuraEnabled public String pracPhone;
        @AuraEnabled public String pracLoc;
        @AuraEnabled public String provName;
        @AuraEnabled public String practionerId;
        @AuraEnabled public String locationId;
        @AuraEnabled public String nextAvailableSlot;
        @AuraEnabled public Datetime nextAvailableSlotDateTm;
        @AuraEnabled public List<ElixirSuite__Work_Schedule__c> lstWorkSchedule;
    }

    public class Wrapper1{
        @AuraEnabled public String pracName1;
        @AuraEnabled public String pracCity1;
        @AuraEnabled public String pracState1;
        @AuraEnabled public String pracPhone1;
        @AuraEnabled public String provLocId1;
        @AuraEnabled public String provName1;
        @AuraEnabled public String practionerId1;
        @AuraEnabled public String nextAvailSlot1;
    }
    
}