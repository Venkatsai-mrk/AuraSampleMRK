global with sharing virtual class GlobalCreateBedsHelper {
    global virtual void beforeInsert(List<sobject> roomLstRecords){
       
    }
    global virtual void afterUpdate(Map<id,sobject> roomNewMap, Map<id,sobject> roomOldMap,boolean isInsert, List<sobject> contactLst){
       
    }
    global virtual void afterInsert(Map<id,sobject> rooms, Map<id,sobject> roomsOldValues,boolean test, List<sobject> conListRecords){
         
    
    }
    global virtual void beforeRoomDelete(List<sobject> listOfContacts){
        
    }
    global virtual void afterRoomDelete(List<sobject> lstContacts){
       
    }
    global virtual void afterRoomUndelte(List<sobject> contactRecords){
        
    }
   
}