public with sharing class newCareApexController {
    
    @AuraEnabled
    public static WrapGetLabOrder countCareEpisode(string patientId){      
        
        list<ElixirSuite__Visits__c> listCareEpisode=[select id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c
                                                      Where ElixirSuite__Account__c=:patientId WITH SECURITY_ENFORCED];
        
        Account acc=[select id,Name from account where id=:patientId WITH SECURITY_ENFORCED];
        WrapGetLabOrder wrp=new WrapGetLabOrder();
        wrp.totalCp=listCareEpisode.size();
        wrp.patientName=acc.Name;
        wrp.patientId=acc.id;
        return wrp;
        
        
        
    }
    public class WrapGetLabOrder{
        @AuraEnabled  public integer totalCp;
        @AuraEnabled  public String patientName; 
        @AuraEnabled  public String patientId;
        @AuraEnabled  public boolean locationCareEpisode;
    }
    
    @AuraEnabled
    Public static boolean customLocationStatus(){
        
        Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();
        if(mcs.ElixirSuite__Care_episode_location_mandatory__c){
            return true;
        }else{
            return false;
        }
        
    }
    @AuraEnabled
    public static WrapperForVisit createCareEpisode(String accountID, String eventId, String eventStatus){
        string patientID;
        WrapperForVisit wrpr = new WrapperForVisit();
        try{
            Event evtList = [SELECT Id, Subject,ElixirSuite__Care_Episode__c,ElixirSuite__Practitioner__c, AccountId FROM Event 
                             WHERE Id=:eventId WITH SECURITY_ENFORCED limit 1];
            if(String.isBlank(accountID)){
                patientID =  evtList.AccountId;
            }else{
                patientID = accountID;
            }
             wrpr.Url = getLoggedinProfile(patientID);
            if(eventStatus == 'Checked in'){
                wrpr.insideIfCheckIn = true;
                if(string.isBlank(evtList.ElixirSuite__Care_Episode__c) && string.isEmpty(evtList.ElixirSuite__Care_Episode__c)){
                    ElixirSuite__Visits__c[] forCount = [SELECT ID,Account__r.Name,Name FROM ElixirSuite__Visits__c 
                                                         WHERE Account__c = : patientID AND Name LIKE '%Visit%' 
                                                         WITH SECURITY_ENFORCED
                                                         order by createdDate desc limit 1];
                    ElixirSuite__Visits__c[] forCounting = [SELECT ID,Account__r.Name,Name FROM ElixirSuite__Visits__c 
                                                            WHERE Account__c = : patientID AND Name LIKE '%Visit%' 
                                                            WITH SECURITY_ENFORCED
                                                            order by createdDate desc];
                    Integer sizeVisitLst = forCounting.size();
                    List<Account> accLst = [SELECT ID,Name from Account where id = : patientID WITH SECURITY_ENFORCED];
                    if(accLst.size()>0 && accLst!=null){
                        wrpr.accName = accLst[0].Name;
                        wrpr.accId = accLst[0].Id;
                    }
                    wrpr.insideIfNoVisit = true;
                    String tpName;
                    if(forCount!=null && forCount.size()>0){
                        if(String.isNotBlank(forCount[0].Name)){ 
                            if(forCount[0].Name.containsIgnoreCase('Visit')){
                                if(sizeVisitLst<10){
                                tpName = forCount[0].Name.right(1); 
                            }         
                                else if(sizeVisitLst>9 && sizeVisitLst<100){
                                    tpName = forCount[0].Name.right(2); 
                                }
                                else{
                                    tpName = forCount[0].Name.right(3);
                                }
                            }       
                        }
                    }
                    else {
                        tpName = '0';
                    } 
                    wrpr.countRecords = Integer.valueOf(tpName)+1;
                    ElixirSuite__Visits__c visit = new ElixirSuite__Visits__c();
                    visit.Name = wrpr.accName +'\''+'s '+evtList.Subject+' Visit - '+wrpr.countRecords;
                    visit.ElixirSuite__Account__c = wrpr.accId;
                    visit.ElixirSuite__Status__c = 'Active';
                    if( evtList.ElixirSuite__Practitioner__c != null){
                    visit.ElixirSuite__Rendering_Provider__c = evtList.ElixirSuite__Practitioner__c;
                    }
                    DMLManager.insertAsUser(visit);
                    newCareApexController.createPatientProcedure(patientID,eventId,visit.Id);//added by Anmol for LX3-9464 
                    evtList.ElixirSuite__Care_Episode__c = visit.Id;
                    evtList.ElixirSuite__Checked_In_Date_Time__c = DateTime.now();
                    evtList.ElixirSuite__Status__c    = 'Checked-In';
                } else{
                    evtList.ElixirSuite__Checked_In_Date_Time__c = DateTime.now();
                    evtList.ElixirSuite__Status__c    = 'Checked-In';
                }   
            }else if(eventStatus == 'In Waiting Room'){
                evtList.ElixirSuite__Status__c    = 'In Waiting Room';
                List<Task> tasks = new List<Task>();
                Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
                wrpr.insideIfWaitingRoom = true;
                String appointmentQueue = customSetting.ElixirSuite__Appointment_Notification_Queue__c;
                if(string.isNotBlank(appointmentQueue) && string.isNotEmpty(appointmentQueue)){
                    Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: appointmentQueue WITH SECURITY_ENFORCED];
                    if (queue != null) {
                        List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queue.Id)
                                            WITH SECURITY_ENFORCED];
                        for (User user : users) {
                            Task newTask = new Task();
                            newTask.Subject = evtList.Subject;
                            newTask.Description = 'Please be reminded of your upcoming appointment.';
                            newTask.WhatId = patientID;
                            newTask.Type = evtList.Subject;
                            newTask.Status = 'Completed';
                            newTask.OwnerId = user.Id;
                            tasks.add(newTask);
                        }
                        DMLManager.insertAsUser(tasks);  
                    }
                }
            }else if(eventStatus == 'Cancel'){
                wrpr.insideIfCancel = true;
                evtList.ElixirSuite__Status__c = 'Cancelled';
            }
            else{
                wrpr.insideNoIf = true;
            }
             DMLManager.updateAsUser(evtList);
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    
    @AuraEnabled
    public static Void createPatientProcedure(String patID, String eveId , String careId){
        List<ElixirSuite__Procedure__c> lstProcedure = new List<ElixirSuite__Procedure__c>();
        try{
            
            Event evtList = [SELECT Id, 
                             Subject,
                             ElixirSuite__Appointment_Type__c,
                             StartDateTime,
                             EndDateTime
                             FROM Event 
                             WHERE Id=:eveId WITH SECURITY_ENFORCED limit 1];
            
            String appointmentType = evtList.ElixirSuite__Appointment_Type__c;
            
            Id tempRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
            
            List<ElixirSuite__Procedure__c> tempProc = [SELECT Id, 
                                                        Name,
                                                        ElixirSuite__Code_Description__c,
                                                        ElixirSuite__Procedure_Duration__c,
                                                        ElixirSuite__Type_of_Procedure__c
                                                        FROM ElixirSuite__Procedure__c
                                                        WHERE Name=:appointmentType
                                                        AND RecordTypeId =:tempRecordTypeId
                                                        WITH SECURITY_ENFORCED limit 1];
            
            
            
            
            Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
            
            if(tempProc[0]!=null){
                //system.debug('inserting procedure');
                ElixirSuite__Procedure__c objProcedure = new ElixirSuite__Procedure__c();
                objProcedure.Name = tempProc[0].Name;
                objProcedure.ElixirSuite__Account__c = patID;
                objProcedure.RecordTypeId = recordTypeId;
                if(  tempProc[0].ElixirSuite__Code_Description__c!=null){
                    objProcedure.ElixirSuite__Code_Description__c = tempProc[0].ElixirSuite__Code_Description__c;
                }
                
                if( tempProc[0].ElixirSuite__Procedure_Duration__c!=null){
                    objProcedure.ElixirSuite__Procedure_Duration__c = tempProc[0].ElixirSuite__Procedure_Duration__c;
                }
                objProcedure.ElixirSuite__Visits__c = careId;
                objProcedure.ElixirSuite__Type_of_Procedure__c = tempProc[0].ElixirSuite__Type_of_Procedure__c;
                objProcedure.ElixirSuite__From_Date_of_Service__c =  evtList.StartDateTime;         
                objProcedure.ElixirSuite__To_Date_of_Service__c =  evtList.EndDateTime;
                objProcedure.ElixirSuite__Is_Billable__c = true;
                objProcedure.ElixirSuite__Days_Units__c = 1;
                objProcedure.ElixirSuite__Event_Id__c = evtList.Id;
                //   objProcedure.ElixirSuite__Charges__c = invetoryIdVsTotalPrice.get(inventory.Id);
                lstProcedure.add(objProcedure);
            }
            
            if(lstProcedure.size() >0 && lstProcedure != null){
                DMLManager.insertAsUser(lstProcedure);
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static String getLoggedinProfile(String patientID){
        String redirectUrl;
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        System.debug('Logged-in user profile name: ' + profileName);
        if(profileName == 'System Administrator'){
            redirectUrl = '/lightning/r/Account/' + patientID + '/related/OpenActivities/view?ws=%2Flightning%2Fr%2FAccount%2F' + patientID + '%2Fview';
        }else{
            redirectUrl = '/lightning/r/Account/'+patientID+'/related/OpenActivities/view';  
        }
        return redirectUrl;
    }
    public class WrapperForVisit{
        @AuraEnabled  public Integer countRecords;
        @AuraEnabled  public String accName; 
        @AuraEnabled  public String accId;
        @AuraEnabled  public String Url;
        @AuraEnabled  public Boolean insideIfCheckIn;
        @AuraEnabled  public Boolean insideIfWaitingRoom;
        @AuraEnabled  public Boolean insideIfNoVisit;
        @AuraEnabled  public Boolean insideIfCancel;
        @AuraEnabled  public Boolean insideNoIf;
        
    }
    
}