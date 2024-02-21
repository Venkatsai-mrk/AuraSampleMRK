public with sharing class ElixirHC_PhysicalAnalysisHelper {
    
    public Sample_Analysis__c physicalAnalysis {get;set;}
    public Account accounts {get;set;}
    public wrapperDataOnVF dataOnVF {get;set;} 
    
    public ElixirHC_PhysicalAnalysisHelper(){
        wrapperDataOnVF customData = new wrapperDataOnVF();
        String orderId = ApexPages.currentPage().getParameters().get('orderId'); 
        System.debug('orderId for ' + orderId); 
        Sample_Analysis__c extData  = (Sample_Analysis__c)  System.JSON.deserialize(orderId, Sample_Analysis__c.class);
        customData.wrapperExtData = extData;
        customData.examinedDateTimeInString = getStringifiedDate(Date.valueOf(extData.Examined_Datetime__c));
        try{
        if(!String.isBlank(extData.Examined_By__c)) {
            customData.examinedBy = [SELECT ID,Name from User where id =: extData.Examined_By__c
            WITH SECURITY_ENFORCED].Name;
        }
        DateTime currentDateConversion = Datetime.now();
        customData.dateOutput = currentDateConversion.format('dd-MM-yyyy'); 
        dataOnVF = customData ; 
        }
        catch(Exception e){ ExceptionLog.logError(e);}
        
    }
    
    public static String getStringifiedDate (Date receivedDate){
        String dateStr = '';
        try{
        if(!String.isBlank(String.valueOf(receivedDate))){
            dateStr = receivedDate.day() + '/' + receivedDate.month() + '/' + receivedDate.year();
        }
        else {
            dateStr = '--';
        }
        }
        catch(Exception e){ ExceptionLog.logError(e);}
        return dateStr;
        
    }
    public class wrapperDataOnVF {
        public Sample_Analysis__c wrapperExtData {get;set;}
        public String examinedDateTimeInString {get;set;}
        public String examinedBy {get;set;}
        public String dateOutput {get;set;}
    }
    
    public void getAccountInfo(Id accountId){
        List<Account> accountList = [select Id, name, Age__c,DOB__c from account where id=:accountId
        WITH SECURITY_ENFORCED];
        accounts = accountList.get(0);
    }
    
    
    
    
    
    
}