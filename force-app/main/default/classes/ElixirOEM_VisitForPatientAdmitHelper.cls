public with sharing class ElixirOEM_VisitForPatientAdmitHelper {
    @AuraEnabled
    public static wrapperForVisit generateAutoNumber(String patientID){
        wrapperForVisit wrpr = new wrapperForVisit();
        ElixirSuite__Visits__c[] forCount = [SELECT ID,Account__r.Name,Name FROM ElixirSuite__Visits__c 
                                             WHERE Account__c = : patientID AND Name LIKE '%Visit%' 
                                             WITH SECURITY_ENFORCED
                                             order by createdDate desc limit 1];
        System.debug('forCount'+forCount);
        List<Account> accLst = [SELECT ID,Name from Account where id = : patientID WITH SECURITY_ENFORCED];
        if(accLst.size()>0 && accLst!=null){ 
            wrpr.accName = accLst[0].Name;
        }
        String tpName;
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
        wrpr.countRecords = Integer.valueOf(tpName)+1;
        System.debug('here '+wrpr);
        // ElixirSuite__Visits__c.Name
        return wrpr;
    }
    public class wrapperForVisit{
        @AuraEnabled  public Integer countRecords;
        @AuraEnabled  public String accName; 
    }
    
    @AuraEnabled
    public static void abc(){
        
    }
}