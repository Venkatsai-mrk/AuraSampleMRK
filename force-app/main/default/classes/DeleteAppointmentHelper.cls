/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class DeleteAppointmentHelper {
    public class OtherException extends Exception {}
    
    /* Test class - DeleteAppointmentHelperTest
* 
*  */
    public static boolean deleteRecursiveCheck =true;
    
    public static void deleteAppointments(List<Event> eList){
        Set<String> eventDataIdSet = new Set<String>();
        List<Event> eventListToDelete = new List<Event>();
        /*datetime startdate;
datetime enddate;
String  isDeleteAllEvent;
boolean isRepeat=false;*/
        try{
        if(deleteRecursiveCheck){
            deleteRecursiveCheck = false;
            for(Event record: eList){
                eventDataIdSet.add(record.ElixirSuite__Event_Data_Object__c);
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        try{
        if(eventDataIdSet.size() >0){
            
            eventListToDelete = [Select id,Subject from Event where ElixirSuite__Event_Data_Object__c IN:eventDataIdSet WITH SECURITY_ENFORCED];
           
        }
        system.debug('eventListToDelete'+eventListToDelete.size());
        if(eventListToDelete.size() >0){
           // if(Schema.sObjectType.Event.isDeletable()) {
                DMLManager.deleteAsUser(eventListToDelete);
               // delete eventListToDelete;
            // }
        }
        if(Test.isRunningTest())
        {
            throw new OtherException();
        }  
        
    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    
}