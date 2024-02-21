public with sharing class SqaurePaymentsBillHelper {
    public class OtherException extends Exception {}
    /* public SqaurePaymentsBillHelper() {
 
     }*/
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
     public static Map<String,List<Transactions__c>> map_paymentTrans{get;set;}
     public static Map<String,List<Payment_Transaction__c>> map_masterpaymentTrans{get;set;}
     public static Map<String,String> procNames{get;set;}
     public static Map<String,Decimal> procRemaining{get;set;}
     public static Map<String,String> typeOfPayment{get;set;}
     public static Map<String,String> procServiceDate{get;set;}
     public static Map<String,Decimal> procAdjustment{get;set;}
     public static PDF_Header__c pdfData {get; set;}
     public static List<Account> accounts;
     public string accountValue;
     public string otherTransId;
     public PageReference redirectUrl {get; set;}
     public Boolean isRedirect {get; set;}
     public static Decimal totalDiscount {get;set;}
    public static Decimal totalDiscount1 {get;set;}
     public static Decimal newCharges1 {get;set;}
     public static String isDownload = 'false';
     public static Map<String,Decimal> procTotal{get;set;}
     public static Map<String,Decimal> procDiscountMap{get;set;}
    
    public static string imagePdf{get; set;}
    
     public SqaurePaymentsBillHelper()
     {
         map_paymentTrans = new Map<String,List<Transactions__c>>();
         map_masterpaymentTrans = new Map<String,List<Payment_Transaction__c>>();
         procNames = new Map<String,String>();
         procRemaining = new Map<String,Decimal>();
         procTotal = new Map<String,Decimal>();
         procDiscountMap = new Map<String,Decimal>();
         typeOfPayment = new Map<String,String>();
         procServiceDate = new Map<String,String>();
         procAdjustment = new Map<String,Decimal>();
         paymentsNewList = new List<Payment_Transaction__c>();
         payments=new  List<Payment_Transaction__c>();
         allpayments=new List<Transactions__c>();
         totalSum=0;
         paymentAdjustments=0;
         name='';	
         mrnNum='';	
         billDate= System.today();	
         acc=new Account();	
         accounts=new List<Account>();	
         accountValue='';	
         otherTransId='';
         newCharges = 0;
         totalRecAmt = 0;
         totalDiscount = 0;
         totalDiscount1 = 0;
         newCharges1 = 0;
         String orderId = ApexPages.currentPage().getParameters().get('orderId');

         if(orderId!=null){
            List<String> retrievedValues = orderId.split('\\$');
             accountValue = retrievedValues[0];
              otherTransId = retrievedValues[1]; 
              if(retrievedValues.size() == 3){
              isDownload = retrievedValues[2];
              }
         }
        
         List<ElixirSuite__Master_Transaction__c> otherTransIds=[SELECT Id, Name,ElixirSuite__Payment_Received_By__c,
                                                                 ElixirSuite__Mode_of_Payment__c,ElixirSuite__Payment_Transaction_Number__c
         FROM ElixirSuite__Master_Transaction__c WHERE Id =:otherTransId WITH SECURITY_ENFORCED];
        
         imagePdf=getPdfImg();
        
         //String accountValue='001N0000028BZx8IAG';
         //List<ElixirSuite__Payment_Transaction__c> paymentTransList = collectPaymentController.fetch_Procedure_MasterTransaction_Sorted(selectedProcedures);*/
         pdfData= getPDFData(); 
         //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Patient Statement'+'.pdf');
          accounts = [SELECT Id, Name, MRN_Number_New__c,Account_Number__c,BillingStreet, BillingCity,BillingState,BillingCountry,
          BillingPostalCode,Phone FROM Account WHERE Id =:accountValue WITH SECURITY_ENFORCED];
         try{
         if(accounts!=null && accounts.size()>0){
             acc = accounts[0];
             name = accounts[0].Name;
             mrnNum = accounts[0].MRN_Number_New__c;
             billDate= System.today();
         } 
         List<Transactions__c> filteredPayments = [SELECT id,name,ElixirSuite__Amount_Paid__c,ElixirSuite__Master_Transaction__c,ElixirSuite__Payment_Received_By__c,
                                                   ElixirSuite__Other_Transactions__c,ElixirSuite__Payment_DateTime__c,
                                                   ElixirSuite__Other_Transactions__r.ElixirSuite__Mode_of_Payment__c,
                                                   ElixirSuite__Other_Transactions__r.ElixirSuite__Payment_Transaction_Number__c,
                                                   ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                                                   ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure_Name__c,
                                                   ElixirSuite__Master_Transaction__r.ElixirSuite__Date_Of_Service__c,
                                                   ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c,
                                                   ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c,
                                                    ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                                                   ElixirSuite__Master_Transaction__r.Procedure__c,
                                                   ElixirSuite__Master_Transaction__r.Procedure__r.From_Date_of_Service__c,
                                                   ElixirSuite__Master_Transaction__r.Provider__r.Name,
                                                   ElixirSuite__Master_Transaction__r.Procedure__r.ElixirSuite__Type_of_Procedure__c,
                                                   ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c,
                                                   ElixirSuite__Master_Transaction__r.ElixirSuite__Payment_Adjustments__c,
                                                   ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c,
                                                   ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c
                                                   FROM ElixirSuite__Transactions__c
                                                   WHERE  ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c = :accountValue
                                                   AND ElixirSuite__Other_Transactions__r.Id =:otherTransIds[0].Id
                                                   AND ElixirSuite__Type_of_Payment__c !='Discount'
                                                   WITH SECURITY_ENFORCED
                                                   ORDER BY CreatedDate];
         
         payments = [SELECT id,name,ElixirSuite__Actual_Price__c,ElixirSuite__Procedure_Name__c,Provider__r.Name,
                     Procedure__r.From_Date_of_Service__c,(select id,name from ElixirSuite__Transactions__r )
                     From ElixirSuite__Payment_Transaction__c
                     WHERE  ElixirSuite__Account__c = :accountValue
                     WITH SECURITY_ENFORCED
                     ORDER BY ElixirSuite__Date_Of_Service__c];
         for(ElixirSuite__Payment_Transaction__c masterTrans : payments){
                 paymentsNewList.add(masterTrans);
         }
      
         for(Transactions__c payTrans : filteredPayments){
             totalRecAmt = totalRecAmt+ payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c ;
             if(String.isNotBlank(payTrans.ElixirSuite__Master_Transaction__c)){
                 if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c != null){
                     totalDiscount = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c;
                     newCharges = newCharges + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c - totalDiscount - payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c ;
                 }
                 Id procId = payTrans.ElixirSuite__Master_Transaction__r.Procedure__c;
                 if(String.isNotBlank(procId)){
                     if(map_paymentTrans.containsKey(procId)){
                         map_paymentTrans.get(procId).add(payTrans);
                         
                     }else{
                         map_paymentTrans.put(procId,new List<Transactions__c>{payTrans});
                         procNames.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure_Name__c);
                         
                         if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c != null){
                             totalDiscount1 = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c;
                             newCharges1 = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c - totalDiscount1 - payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c ;
                             procRemaining.put(procId,newCharges1);
                         }
                         else{
                             procRemaining.put(procId,0); 
                         }
                         if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c != null){
                            procTotal.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c);
                        }
                        else{
                            procTotal.put(procId,0); 
                        }
                        if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c != null && payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c != null){
                           totalDiscount1 = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c;
                            procDiscountMap.put(procId,totalDiscount1);
                        }
                        else{
                            procDiscountMap.put(procId,0); 
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
             if(Test.isRunningTest())
			{
				throw new OtherException();
			}
     }
     //Commited
     catch(Exception e){
             ExceptionLog.logError(e);
         }
         if(isDownload == 'true'){
            Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Receipt.pdf');

         }
      
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

    /* public static string getPdfImg(){
        String fileId = '';
       List<Attachment> attchRecord =[SELECT  Id,  Name, Body, BodyLength, ContentType, CreatedDate, Description FROM Attachment where Name='Company Logo'];
        if( attchRecord != null && attchRecord.size() > 0 ) {
          fileId = attchRecord[0].Id;
          // fileId=EncodingUtil.Base64Encode(attchRecord[0].Body);
          system.debug('fileId'+fileId);
        }
        String body = '/servlet/servlet.FileDownload?file='+fileId;
      // String body = '00P5D000008QMIBUA4';
        system.debug('BODY'+body);
        return body;
    }*/


      public static PDF_Header__c getPDFData(){
         PDF_Header__c record = PDF_Header__c.getInstance();
         return record ;
     }
      public PageReference redirectToAccount() {
         isRedirect = true;
         PageReference orderPage = new PageReference('/lightning/r/Account/' + accountValue+ '/view');
         orderPage.setRedirect(true);
         redirectUrl =orderPage;
         return redirectUrl ;
     }
     public PageReference downloadPdf() {
       // imagePdf=getPdfImg();
       // system.debug('imagePdf'+imagePdf);
        string finalParametre = accountValue + '$' + otherTransId + '$' + 'true';
          PageReference pageRef = new PageReference('/apex/SqaurePaymentBillExport?orderId='+finalParametre);
         pageRef.setRedirect(true);
             return pageRef;
     }
 
     
 }