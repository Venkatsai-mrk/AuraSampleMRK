public with sharing class AppointmentNotificationHandler {
    public static Map<Id,String> accIdToName;
    public static String mySubject;
    public static void appointmentNotifications(Map<Id,String> accLstIds) {
        //  code for form notification  
        accIdToName = new Map<Id,String>();
        ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            String intervalValue = settings.ElixirSuite__Appointment_Interval__c;
        	List<Integer> daysLst = new List<Integer>();
            List<Integer> hourLst = new List<Integer>();
             if(intervalValue != null){
            // Split the intervalValue into a list using commas as the delimiter
            List<String> intervals = intervalValue.split(',');

            for (String s : intervals) {
               if (s.contains('D')) {
                    // Remove 'D' and convert the remaining value to an integer
                    Integer days = Integer.valueOf(s.replaceAll('D', '').trim());
                    daysLst.add(days);
                }
                   if (s.contains('d')) {
                    // Remove 'D' and convert the remaining value to an integer
                    Integer days = Integer.valueOf(s.replaceAll('d', '').trim());
                    daysLst.add(days);
                }
                if (s.contains('H'))  {
                    // Remove 'H' and convert the remaining value to an integer
                    Integer hours = Integer.valueOf(s.replaceAll('H', '').trim());
                    hourLst.add(hours);
                }
                if (s.contains('h')) {
                    // Remove 'H' and convert the remaining value to an integer
                    Integer hours = Integer.valueOf(s.replaceAll('h', '').trim());
                    hourLst.add(hours);
                }
            }
        }     

            
        
        List<Event> appointmentLst = [SELECT Id, WhatId, WhoId, WhoCount, WhatCount,ActivityDateTime, Subject,ElixirSuite__Appointment_Interval__c,
                                      ElixirSuite__Location__c,ElixirSuite__Location__r.Name, Location,AccountId,Account.Name, StartDateTime, EndDateTime, EndDate, 
                                      ElixirSuite__Status__c FROM Event
                                      WHERE (ElixirSuite__Appointment_Interval_In_Days__c IN :daysLst  OR ElixirSuite__Appointment_Interval__c IN :hourLst)  
                                      AND  WhatId IN :accLstIds.keySet()
                                      WITH security_enforced  LIMIT 500];
        
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: CreateFormForPortal.fetchEmailTemplateId('Patient_Notification_for_New_Appointments') WITH security_enforced];
        mySubject=emailTemplate.Subject;
        String templateId=emailTemplate.Id;
        Set<Id> attachmentIds =new Set<Id>();
        
        
        //List<Event> evtLstUpdate = new List<Event>();
        Map<Id, List<Message_Utility.OrderInfo>> patientIdToEventValueIds=new Map<Id, List<Message_Utility.OrderInfo>>();
        Map<Id,String> emailhtmlBody=new Map<Id,String>() ;
        for(Event appList :appointmentLst){
            
            DateTime startDateTime = appList.StartDateTime;
            String startTimeString = startDateTime.format('h:mm a');
            String startDateString = startDateTime.format('MMM dd, yyyy');
    		string appointSubject=appList.Subject;
           

    String accountId = appList.AccountId;
    if(patientIdToEventValueIds.containsKey(accountId)){
        Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
        info.recordId = appList.Id;
        info.startTime=startTimeString;
        info.startDate=startDateString;
        info.appSubject=appointSubject;
        info.location = appList.Location;
        patientIdToEventValueIds.get(accountId).add(info);
    }else{
        Message_Utility.OrderInfo info = new Message_Utility.OrderInfo();
        info.recordId = appList.Id;
        info.startTime=startTimeString;
        info.startDate=startDateString;
        info.location = appList.ElixirSuite__Location__r.Name;
        info.appSubject=appointSubject;
        accIdToName.put(accountId, appList.Account.Name);
        patientIdToEventValueIds.put(accountId, new List<Message_Utility.OrderInfo>{info});
    }
}
//update evtLstUpdate;
emailhtmlBody = createMessage(patientIdToEventValueIds);
if(patientIdToEventValueIds!=null && patientIdToEventValueIds.size()>0 && settings.ElixirSuite__Common_message_utility__c == false){
    Message_Utility.sendEmail(patientIdToEventValueIds, accLstIds, templateId, mySubject, attachmentIds, false, emailhtmlBody);
}
}
public static Map<Id,String> createMessage( Map<Id, List<Message_Utility.OrderInfo>> patientIdToEventValueIds){

fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
    new List<Schema.SObjectType>{
        Message_Subject__c.sObjectType,
            Message_Details__c.sObjectType
            }
);


//Elixir_Custom_Setting__c portalUrl = [Select Elixir_portal_url__c,ElixirSuite__Form_reminder_Interval__c  from Elixir_Custom_Setting__c];
Elixir_Custom_Setting__c portalUrl = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Patient_Notification_for_New_Appointments' WITH security_enforced];
String htmlBody = emailTemplate.HtmlValue;
mySubject = emailTemplate.Subject;
mySubject = mySubject.replace('{!Organization.Name}',UserInfo.getOrganizationName()); 


Map<Id,String> emailhtmlBody = new Map<Id,String>();
for(String accountId :patientIdToEventValueIds.keySet()){
    
    htmlBody = htmlBody.replace('{!Account.Name}',accIdToName.get(accountId));
    List<Message_Utility.OrderInfo> orderInfoString = patientIdToEventValueIds.get(accountId);
    String timeStart = '';
    String dateStart='';
    String loc='';
    String appointSubject='';
    for(Message_Utility.OrderInfo info :orderInfoString){
        timeStart= info.startTime;
        dateStart=info.startDate;
        loc=info.location;
        appointSubject=info.appSubject;
        
    }
    
     
    
    htmlBody = htmlBody.replace('{!Organization.Name}' , UserInfo.getOrganizationName());
    // htmlBody = htmlBody.replace('{!ElixirSuite__Form_Value__c.ElixirSuite__Form_Name__c}' , formName);
    htmlBody = htmlBody.replace('{Time}' , timeStart);
    htmlBody = htmlBody.replace('{Date}' , dateStart);
   	htmlBody = htmlBody.replace('{!Event.Location}' , loc);
  	htmlBody = htmlBody.replace('{appointment subject}', appointSubject);
    //htmlBody = htmlBody.replace('{Patientportallink}', '<a href='+ portalUrl.Elixir_portal_url__c +'>click here</a>');
    if (portalUrl.ElixirSuite__Enable_portal_in_Elixir__c == true){
    htmlBody = htmlBody.replace('{Patientportallink}', '<a href=' + portalUrl.Elixir_portal_url__c + '>click here</a>');
   	} else {
    // Remove the entire line by replacing it with an empty string
    htmlBody = htmlBody.replace('<p>Please login into your portal {Patientportallink}. </p>', '');
    }
    
    emailhtmlBody.put(accountId,htmlBody);
    if (portalUrl.ElixirSuite__Enable_portal_in_Elixir__c == true){
    String userId = UserInfo.getUserId();
    //Inserting a record in message subject 
    Message_Subject__c messageSubject = new Message_Subject__c();
    messageSubject.Subject__c = mySubject;
    messageSubject.Account__c = accountId;
    messageSubject.IsPortal__c = false;
    messageSubject.User__c = userId;
    uow.registerNew(messageSubject);
    
    //Inserting a record in message Detail 
    Message_Details__c messageDetails = new Message_Details__c();
    messageDetails.Message_Body__c = htmlBody;
    // messageDetails.lookup_Message_Subject__c = messageSubject.Id;
    uow.registerRelationship(messageDetails, Message_Details__c.lookup_Message_Subject__c , messageSubject);
    uow.registerNew(messageDetails);
    
    }
}
uow.commitWork();
return emailhtmlBody ;
}
}