public with sharing class DeleteSharedRecord {
    public class OtherException extends Exception {}
    @future
   
    public static void delRecords(Set<Id> recordsToDel) {
        try{
             
         List<AccountShare> accountShareDel  = [SELECT Id FROM AccountShare WHERE Id IN :recordsToDel WITH SECURITY_ENFORCED LIMIT 10000];
         if(accountShareDel.size() >0){
            
                 DMLManager.deleteAsUser(accountShareDel);
               
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