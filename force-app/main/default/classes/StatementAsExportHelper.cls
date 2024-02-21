public with sharing class StatementAsExportHelper {
    public static List<Payment_Transaction__c> payments {get;set;}
    public static List<Payment_Transaction__c> paymentsNewList {get;set;}
    public static List<Transactions__c> allpayments {get;set;}
    public static Integer totalSum {get;set;}
    public static Decimal newCharges {get;set;}
    public static Integer paymentAdjustments {get;set;}
    public static Decimal totalRecAmt {get;set;}
    public static String name {get;set;}
    public static String mrnNum {get;set;}
    public static Datetime billDate {get;set;}
    public static Account acc {get;set;}
    public string accountValue;
    public static Date startValue;
    public static Date endValue;
    public static Map<String,List<Transactions__c>> map_paymentTrans{get;set;}
    public static Map<String,List<Payment_Transaction__c>> map_masterpaymentTrans{get;set;}
    public static Map<String,String> procNames{get;set;}
    public static Map<String,Decimal> procRemaining{get;set;}
    public static Map<String,String> typeOfPayment{get;set;}
    public static Map<String,String> procServiceDate{get;set;}
    public static Map<String,Decimal> procAdjustment{get;set;}
    public static PDF_Header__c pdfData {get; set;}
    public static string imagePdf{get; set;}
    
    public StatementAsExportHelper()
    {
        payments=new List<Payment_Transaction__c>();
        allpayments=new List<Transactions__c>();
        map_paymentTrans = new Map<String,List<Transactions__c>>();
        map_masterpaymentTrans = new Map<String,List<Payment_Transaction__c>>();
        procNames = new Map<String,String>();
        procRemaining = new Map<String,Decimal>();
        typeOfPayment = new Map<String,String>();
        procServiceDate = new Map<String,String>();
        procAdjustment = new Map<String,Decimal>();
        paymentsNewList = new List<Payment_Transaction__c>();
        newCharges = 0;
        totalRecAmt = 0;
        totalSum=0;
        paymentAdjustments=0;
        name='';	
        mrnNum='';	
        billDate= System.today();
        acc=new Account();	
        accountValue='';
       
         
        String orderId = ApexPages.currentPage().getParameters().get('orderId');
        if(orderId!=null){
        List<String> retrievedValues = orderId.split('\\$');
         startValue = Date.valueOf(retrievedValues[0]) - 1;
         endValue = Date.valueOf(retrievedValues[1]) + 1;
         accountValue = retrievedValues[2];
        } 
        
        pdfData= getPDFData(); 
        imagePdf=getPdfImg();
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Patient Statement'+'.pdf');
        List<Account> accounts = [SELECT Id, Name, MRN_Number_New__c,Account_Number__c 
                                  FROM Account WHERE Id =:accountValue WITH SECURITY_ENFORCED];
        try{
        if(accounts!=null && accounts.size()>0){
            acc = accounts[0];
            name = accounts[0].Name;
            mrnNum = accounts[0].MRN_Number_New__c;
            billDate= System.today();
        } 
        endValue = endValue.addDays(1);
        List<Transactions__c> filteredPayments = [SELECT id,name,ElixirSuite__Amount_Paid__c,ElixirSuite__Master_Transaction__c,ElixirSuite__Payment_Received_By__c,
                                                  ElixirSuite__Other_Transactions__c,ElixirSuite__Payment_DateTime__c,
                                                  ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                                                  ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure_Name__c,
                                                  ElixirSuite__Master_Transaction__r.ElixirSuite__Date_Of_Service__c,
                                                  ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c,
                                                  //ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c,
                                                  ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                                                  ElixirSuite__Master_Transaction__r.Procedure__c,
                                                  ElixirSuite__Master_Transaction__r.Procedure__r.From_Date_of_Service__c,
                                                  ElixirSuite__Master_Transaction__r.Provider__r.Name,
                                                  ElixirSuite__Master_Transaction__r.Procedure__r.ElixirSuite__Type_of_Procedure__c,
                                                  ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c,
                                                  ElixirSuite__Master_Transaction__r.ElixirSuite__Payment_Adjustments__c
                                                  FROM ElixirSuite__Transactions__c
                                                  WHERE CreatedDate >=: startValue 
                                                  AND CreatedDate <=: endValue 
                                                  AND ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c = :accountValue
                                                  WITH SECURITY_ENFORCED
                                                  ORDER BY CreatedDate];
        
        payments = [SELECT id,name,ElixirSuite__Actual_Price__c,ElixirSuite__Procedure_Name__c,Provider__r.Name,
                    Procedure__r.From_Date_of_Service__c,ElixirSuite__PatientOutstanding__c,(select id,name from ElixirSuite__Transactions__r  WHERE CreatedDate >=: startValue AND CreatedDate <=: endValue )
                    From ElixirSuite__Payment_Transaction__c
                    WHERE ElixirSuite__Date_Of_Service__c >=: startValue 
                    AND ElixirSuite__Date_Of_Service__c <=: endValue 
                    AND ElixirSuite__Account__c = :accountValue
                    WITH SECURITY_ENFORCED
                    ORDER BY ElixirSuite__Date_Of_Service__c];
        for(ElixirSuite__Payment_Transaction__c masterTrans : payments){
                paymentsNewList.add(masterTrans);
        }
     
        for(Transactions__c payTrans : filteredPayments){
            totalRecAmt = totalRecAmt + payTrans.ElixirSuite__Amount_Paid__c ;
            if(String.isNotBlank(payTrans.ElixirSuite__Master_Transaction__c)){
                if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c != null){
                    newCharges = newCharges + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c ;
                }
                
                Id procId = payTrans.ElixirSuite__Master_Transaction__r.Procedure__c;
                if(String.isNotBlank(procId)){
                    if(map_paymentTrans.containsKey(procId)){
                        map_paymentTrans.get(procId).add(payTrans);
                        
                    }else{
                        map_paymentTrans.put(procId,new List<Transactions__c>{payTrans});
                        procNames.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure_Name__c);
                        if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c != null){
                            procRemaining.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c);
                        }
                        else{
                            procRemaining.put(procId,0); 
                        }
                        if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Payment_Adjustments__c != null){
                            procAdjustment.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Payment_Adjustments__c);
                        }
                        else{
                            procAdjustment.put(procId,0); 
                        }
                        typeOfPayment.put(procId,payTrans.ElixirSuite__Master_Transaction__r.Procedure__r.ElixirSuite__Type_of_Procedure__c);
                        procServiceDate.put(procId,'');
                        if(payTrans.ElixirSuite__Master_Transaction__r.Procedure__r.From_Date_of_Service__c!=null){
                            procServiceDate.put(procId,payTrans.ElixirSuite__Master_Transaction__r.Procedure__r.From_Date_of_Service__c.format());
                        }
                    }
                }
            }
        }
    }
    //Commited
    catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    
    public static wrapperData getPaymentTransactionInfoDuplicate(String accountId,Date startDate,Date endDate){
        endDate = endDate.addDays(1);
        allpayments = new List<ElixirSuite__Transactions__c>();
        List<ElixirSuite__Transactions__c> filteredTransactionRecords = [SELECT id,name,ElixirSuite__Amount_Paid__c,ElixirSuite__Master_Transaction__c,
                                                                         ElixirSuite__Other_Transactions__c,ElixirSuite__Payment_DateTime__c,
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure_Name__c,
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Date_Of_Service__c,
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c,
                                                                         //ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Actual_Patient_Paid_Amount__c
                                                                         FROM ElixirSuite__Transactions__c
                                                                         WHERE CreatedDate >=: startDate 
                                                                         AND CreatedDate <=: endDate 
                                                                         AND ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c = :accountId
                                                                         WITH SECURITY_ENFORCED
                                                                         ORDER BY CreatedDate];
        List<ElixirSuite__Payment_Transaction__c> masterPayments = [SELECT id,name,ElixirSuite__Actual_Price__c
                                                                    From ElixirSuite__Payment_Transaction__c
                                                                    WHERE ElixirSuite__Date_Of_Service__c >=: startDate 
                                                                    AND ElixirSuite__Date_Of_Service__c <=: endDate 
                                                                    AND ElixirSuite__Account__c = :accountId
                                                                    WITH SECURITY_ENFORCED
                                                                    ORDER BY ElixirSuite__Date_Of_Service__c];
        wrapperData obj = new wrapperData();
        obj.masterTransaction = masterPayments;
        obj.paymentsTransactions = filteredTransactionRecords ;
        return obj;
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
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return dateStr;
    }
    public static string getPdfImg(){
        String fileId = '';
       List<Attachment> attchRecord =[SELECT  Id,  Name, Body, BodyLength, ContentType, CreatedDate, Description FROM Attachment where Name='Company Logo' WITH SECURITY_ENFORCED];
        if( attchRecord != null && attchRecord.size() > 0 ) {
          fileId = attchRecord[0].Id;
        }
        String body = '/servlet/servlet.FileDownload?file='+fileId;
        return body;
    }
    
    public static PDF_Header__c getPDFData(){
        PDF_Header__c record = PDF_Header__c.getInstance() ;
        return record ;
    }
    public class wrapperData{       
        @AuraEnabled Public List<ElixirSuite__Payment_Transaction__c> masterTransaction; 
        @AuraEnabled Public List<ElixirSuite__Transactions__c> paymentsTransactions;
    }
}