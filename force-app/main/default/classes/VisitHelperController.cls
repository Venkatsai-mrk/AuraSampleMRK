public with sharing class VisitHelperController {
    @AuraEnabled
    public static wrapper countExistingRecords(String acctId){
        wrapper wrpr = new wrapper();
       
        ElixirSuite__Visits__c[] forCount = [SELECT ID,Account__r.Name,Name FROM ElixirSuite__Visits__c 
                                             WHERE Account__c = : acctId AND Name LIKE '%Visit%' 
                                             WITH SECURITY_ENFORCED
                                             order by createdDate desc limit 1];
        System.debug('forCount'+forCount);
        List<Account> accLst = [SELECT ID,Name from Account where id = : acctId WITH SECURITY_ENFORCED];
        if(accLst.size()>0 && accLst!=null){
            wrpr.accName = accLst[0].Name;
        }
        String tpName;
        try{
        if(forCount!=null && forCount.size()>0){
               System.debug('inside ');
            if(String.isnotBlank(forCount[0].Name)){ 
                if(forCount[0].Name.containsIgnoreCase('Visit')){
                    tpName = forCount[0].Name.right(1); 
                }         
            }
        }
        else {
            tpName = '0';
        } 
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        wrpr.countRecords = Integer.valueOf(tpName)+1;
        System.debug('here '+wrpr);
        // ElixirSuite__Visits__c.Name
        return wrpr;
    }
    public class wrapper{
        @AuraEnabled  public Integer countRecords;
        @AuraEnabled  public String accName; 
    }
}
//Comminted