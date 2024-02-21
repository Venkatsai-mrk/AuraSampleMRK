public with sharing class DataDisplayController {
    // Test class name : DataDisplayControllerTest
    public UA_Sample_Details__c labOrder {get;set;}
    public Account accounts {get;set;}
	public static  Contact contacts {get;set;}
    public static Integer age{get;set;}
    public String PDFData {get;set;} 
    public String approvalString {get;set;}
   
    public DataDisplayController(){
        approvalString = '/servlet/servlet.FileDownload?file=';
        String orderId = ApexPages.currentPage().getParameters().get('orderId').escapeHtml4();
         System.debug('orderId---' + orderId);    
        getlabOrderInfo(orderId);
      //  Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Laborder'+labOrder.Name +'.pdf');
              
    }
   
    public  void getlabOrderInfo(Id orderId){    
       System.debug('list answer '+orderId);
        List<UA_Sample_Details__c> orderList = [select Id,Name,Order_By__r.name,Medical_Test__c,Fax__c,Ordered_Via__c,Signature_Comments__c,Signed_Date__c, Signature_Link__c,Status__c,
                                                                 Account__r.Name ,Ordered_By__c,Ordered_By__r.Name,Frequency__c,Necessity_Details__c,On_Admission__c,Account__c,Start_Date__c
                                                                 from UA_Sample_Details__c  where id=:orderId
                                                                 WITH SECURITY_ENFORCED] ;
        
        System.debug('list answer '+orderList[0].On_Admission__c);
        labOrder = orderList[0];
        //getSampleInfo(orderId);
       // getLabInfo(labOrder.Lab__c);
        getAccountInfo(labOrder.Account__c);
    }
    public  void getAccountInfo(Id accountId){
        try{
        List<Account> accountList = [select Id, name, Age__c,DOB__c from account where id=:accountId
        WITH SECURITY_ENFORCED];
         List<Contact> con=[select Id,name,birthdate from contact where AccountId=:accountId  
         WITH SECURITY_ENFORCED limit 1];
        system.debug('djd' + accountList);
        accounts = accountList.get(0);
        contacts = con.get(0);
        if(con[0].birthdate!=null){
                Integer days = con[0].birthdate.daysBetween(Date.Today());
                age = Integer.valueOf(days/365);
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
   

	
}