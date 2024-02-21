public class AppointmentScheduleEdit_Ctrl {
   /* @AuraEnabled
     public static ElixirSuite__Group_Patient__c[] getAllPatientDetailsFromGroupIDs(List<String> groupIDs){
         return  [SELECT ID,ElixirSuite__Current_Patient_Name__r.Id, 
                                                            ElixirSuite__Current_Patient_Name__r.Name,ElixirSuite__Current_Patient_Name__r.ElixirSuite__Profile_Picture__c
                                                            FROM ElixirSuite__Group_Patient__c WHERE ElixirSuite__Group_Name__c IN : groupIDs WITH SECURITY_ENFORCED];
     }
     @AuraEnabled
     public static Event getEventDataObject(String eventId){
         
          
        // system.debug('url'+Apexpages.currentPage().getUrl());
        
         Event evenRecord = [Select id,ElixirSuite__Event_Data_Object__c, StartDateTime, EndDateTime from Event where Id =: eventId WITH SECURITY_ENFORCED limit 1];     //Mahesh : Added two extra fields and changed return type to object
        
         return evenRecord;
     }
     
     @AuraEnabled
     public static string modifyEventDataObject(String eventDataId,String patients,String patientGroups,String bussinessAccounts, 
                                                string coFacilitators,String locId, String roomId,String equipments,
                                                String accountAdditionalInfo){
             
         ElixirSuite__Event_Data_Object__c record = [Select id,ElixirSuite__Provider__c,ElixirSuite__Rooms__c,ElixirSuite__Patients__c,ElixirSuite__Patient_Groups__c,ElixirSuite__Related_Business_Accounts__c,ElixirSuite__Co_Facilitators__c from ElixirSuite__Event_Data_Object__c where Id =: eventDataId WITH SECURITY_ENFORCED];
         
                                                    
         record.ElixirSuite__Provider__c = locId;
         record.ElixirSuite__Rooms__c = roomId;
         record.ElixirSuite__Patients__c = patients;
         record.ElixirSuite__Patient_Groups__c = patientGroups;
         record.ElixirSuite__Related_Business_Accounts__c = bussinessAccounts;
         record.ElixirSuite__Co_Facilitators__c = coFacilitators;
        
         record.ElixirSuite__JSON_Data__c = accountAdditionalInfo;
         if (Schema.sObjectType.ElixirSuite__Event_Data_Object__c.isUpdateable())
         {
              update record;
         }
        
         
       return 'success';
     }
     
     
     @AuraEnabled
     public static MulitSelectedRecordsWrapper getMultiSelectedObjectRecords(String evenDataId){
         
         String patients;
         List<String> patientList;
         String groups;
         List<String> groupList;
         String coFacilitators;
         List<String> coFacilitatorList;
         String bussinessAccounts;
         List<String> bussinessAccountList;
         String equipments;
         List<EquipTemp> equipTempList;
         List<equip> modifiedEquipList = new List<equip>();
         
         Set<String> patientsIds = new Set<String>();
         Set<String> groupIds = new Set<String>();
         Set<String> userIds = new Set<String>();
         Set<String> bussinessAccountIds = new Set<String>();
         Set<String> roomIds = new Set<String>();
         Set<String> equipmentIds = new Set<String>();
         String room;
         String location; 
         ElixirSuite__Event_Data_Object__c eventDataRecord =[Select id,ElixirSuite__By_Pass_Check__c,ElixirSuite__Patients__c,ElixirSuite__Patient_Groups__c,ElixirSuite__Provider__c,ElixirSuite__Rooms__c,
                                                            ElixirSuite__Related_Business_Accounts__c,ElixirSuite__Co_Facilitators__c from ElixirSuite__Event_Data_Object__c where Id =: evenDataId WITH SECURITY_ENFORCED];
         
       
         patients = eventDataRecord.ElixirSuite__Patients__c;
         groups = eventDataRecord.ElixirSuite__Patient_Groups__c;
         coFacilitators = eventDataRecord.ElixirSuite__Co_Facilitators__c;
         bussinessAccounts = eventDataRecord.ElixirSuite__Related_Business_Accounts__c;
         room = eventDataRecord.ElixirSuite__Rooms__c;
         location = eventDataRecord.ElixirSuite__Provider__c;
        
         
         
         if(!String.isBlank(patients)){
             patientList = (List<String>)JSON.deserializeStrict(patients,List<String>.class);
             for(String pt: patientList){
                 if(!String.isBlank(pt)){
                     patientsIds.add(pt);
                 }
                 
             }
         }
         if(!String.isBlank(groups)){
             groupList = (List<String>)JSON.deserializeStrict(groups,List<String>.class);
             for(String pt: groupList){
                 if(!String.isBlank(pt)){
                     groupIds.add(pt);
                 }
                 
             }
             
             
         }
         if(!String.isBlank(coFacilitators)){
             coFacilitatorList = (List<String>)JSON.deserializeStrict(coFacilitators,List<String>.class);
             
             for(String pt: coFacilitatorList){
                 if(!String.isBlank(pt)){
                     userIds.add(pt);
                 }
                 
             }
         }
         
         if(!String.isBlank(bussinessAccounts)){
             bussinessAccountList = (List<String>)JSON.deserializeStrict(bussinessAccounts,List<String>.class);
             
             for(String pt: bussinessAccountList){
                 if(!String.isBlank(pt)){
                     bussinessAccountIds.add(pt);
                 }
                
             }
         }
         if(!String.isBlank(equipments)){
             
             equipTempList = (List<EquipTemp>) JSON.deserializeStrict(equipments,List<EquipTemp>.class);
         
             for(EquipTemp eq: equipTempList){
                 if(!String.isBlank(eq.Id)){
                     equipmentIds.add(eq.Id);
                 }
             }
             
             
         }
           
         MulitSelectedRecordsWrapper  newMuliSelectedWrapper = new MulitSelectedRecordsWrapper();
         try{
         newMuliSelectedWrapper.selectedpatientAccounts = [Select id,Name from Account where ID IN: patientsIds];
         newMuliSelectedWrapper.selectedGroups = [Select id,Name from ElixirSuite__Account_Group__c where Id IN: groupIds];
         newMuliSelectedWrapper.selectedCoFacilitators = [Select id,Name from User where Id IN: userIds];
         newMuliSelectedWrapper.selectedbussinessAccounts = [Select id,Name from Account where ID IN: bussinessAccountIds];
         newMuliSelectedWrapper.selectedLocation = [Select id,Name from ElixirSuite__Provider__c where ID =: location].size() >0 ? [Select id,Name from ElixirSuite__Provider__c where ID =: location] : null;
         newMuliSelectedWrapper.selectedRoom = [Select id,Name from ElixirSuite__Rooms__c where ID =: room].size() >0 ? [Select id,Name from ElixirSuite__Rooms__c where ID =: room] : null;
         newMuliSelectedWrapper.selectedEquipList = modifiedEquipList;
         newMuliSelectedWrapper.selectedbyPass =eventDataRecord.ElixirSuite__By_Pass_Check__c;
         
         system.debug('wrap' +newMuliSelectedWrapper);
         }
         catch(Exception e){
             ExceptionLog.logError(e);
         }
      return newMuliSelectedWrapper;   
     }
     
     
     public class EquipTemp{
         String Id;
         String EquipmentNeed;
         
         
     }
     public class equip{
         @AuraEnabled public String Equipment;
         @AuraEnabled public String noOfAvEquip;
         @AuraEnabled public String Needed;
         @AuraEnabled public String Id;
         @AuraEnabled public boolean disabled; 
     }
     
     public class MulitSelectedRecordsWrapper{
         
         @AuraEnabled public List<Account> selectedpatientAccounts = new List<Account>();
         @AuraEnabled public List<ElixirSuite__Account_Group__c> selectedGroups=new List<ElixirSuite__Account_Group__c>();
         @AuraEnabled public List<User> selectedCoFacilitators=new List<User>();
         @AuraEnabled public List<Account> selectedbussinessAccounts=new List<Account>();
         @AuraEnabled public ElixirSuite__Provider__c selectedLocation;
         @AuraEnabled public ElixirSuite__Rooms__c selectedRoom;
         @AuraEnabled public List<Equip> selectedEquipList;
         @AuraEnabled public boolean selectedbyPass;
     
     }
       @AuraEnabled
     public static void functionSeriesDelete(String recordID)
     {
        Event evenRecord = [Select Id,startDateTime,EndDateTime, ElixirSuite__TechTracking_ID__c from Event where Id =:recordID AND startDateTime >:system.today() ];
         List<Event> techtrack  =[Select id,ElixirSuite__TechTracking_ID__c,startDateTime,EndDateTime  from Event where ElixirSuite__TechTracking_ID__c=:evenRecord.ElixirSuite__TechTracking_ID__c AND startDateTime >:system.today()];
        if(evenRecord != null){
            delete evenRecord; //delete single event
         }
         else  if(techtrack.size()>1){
         delete  techtrack; //delete series
         }
        
        //return evenRecord;
     }
       @AuraEnabled
     public static void functionDelete(String recordID,String eventButton)
     {
     
             Event evenRecord = [Select id,ElixirSuite__TechTracking_ID__c from Event where Id =:recordID ];
 
        List<Event> techtrack  =[Select id,ElixirSuite__TechTracking_ID__c,startDateTime,EndDateTime from Event where ElixirSuite__TechTracking_ID__c=:evenRecord.ElixirSuite__TechTracking_ID__c AND startDateTime >:system.today()];
         if(eventButton.contains('deleteSeries') && techtrack.size()>1){
         delete techtrack;
         }
         else if(eventButton.contains('delete') && evenRecord!=null){
             delete evenRecord;
         }
     }*/
    
 }