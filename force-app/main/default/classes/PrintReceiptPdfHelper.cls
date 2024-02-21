public  with sharing class PrintReceiptPdfHelper {    
    public static wrapperAcc AccData {get;set;}
    public static List<paymentInfo> paymentInformation {get;set;}
    // Added New
    public static List<paymentInfo> paymentInformationList {get;set;}
    public static Decimal TotalAmountPaid {get;set;}
    public static Decimal TotalAmountCredited {get;set;}
    //Ended
    public static String invoiceDate {get;set;}
    public static PDF_Header__c pdfData {get; set;}
    public static List<Master_Transaction__c> masterTrans {get;set;}   
    public static Decimal AmountDue {get;set;}
    public static Decimal AmountPaid {get;set;}
    public static String transactionTime {get;set;}
    public static Datetime transact {get;set;}
    public static List<String> transactions = new List<String>();
    public static string imagePdf{get; set;}
    
    public PrintReceiptPdfHelper(){
        paymentInformationList = new List<paymentInfo>();
        String tranId = ApexPages.currentPage().getParameters().get('tranId');
         
        system.debug('tranId ' +tranId);
        transactions = tranId.split(',');
        system.debug('tranId ' +transactions);
        
        masterTrans=[SELECT Id,Name,Transaction_Date__c,Account__c,Payment_Type__c,Payment_By__c,Total_Amount_Paid__c,
                     CreatedDate FROM Master_Transaction__c WHERE Id IN :transactions WITH SECURITY_ENFORCED];
        system.debug('masterTrans ' +masterTrans);
        
        transact = masterTrans[0].CreatedDate;
        transactionTime = masterTrans[0].CreatedDate.format();
        pdfData= getPDFData();           
        accData= getAccData(masterTrans[0].Account__c, transactions);
        paymentInformationList = getPaymentData(masterTrans[0].Id,masterTrans[0]);
        imagePdf=getPdfImg();
        
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


    public static List<paymentInfo> getPaymentData(String otherTransId, Master_Transaction__c otherTransRecord){
        
        
        List<ElixirSuite__Transactions__c> transactionList = [Select ElixirSuite__Amount_Paid__c,ElixirSuite__Master_Transaction__r.ElixirSuite__Units_days__c,ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c,ElixirSuite__Master_Transaction__r.Procedure__r.Name,ElixirSuite__Other_Transactions__c from ElixirSuite__Transactions__c where 
                                                             ElixirSuite__Other_Transactions__c=: otherTransId WITH SECURITY_ENFORCED];
        
                
        Decimal totalAmount = 0;
        
        if(transactionList!=null && transactionList.size()>0){
            for(ElixirSuite__Transactions__c record: transactionList){
                
                paymentInfo payment = new paymentInfo();
                payment.procedureName = record.ElixirSuite__Master_Transaction__r.Procedure__r.Name;
                payment.actualPrice = record.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c;
                payment.quantity = Integer.valueOf(record.ElixirSuite__Master_Transaction__r.ElixirSuite__Units_days__c);
                payment.AmountPaid = record.ElixirSuite__Amount_Paid__c;
                
               // payment.receivedAmount = 0;
               // payment.remainingAmount = 0;
                
                
               totalAmount+=record.ElixirSuite__Amount_Paid__c;
                paymentInformation.add(payment);
                
            }
            
        }
        TotalAmountPaid = totalAmount;
        TotalAmountCredited = otherTransRecord.Total_Amount_Paid__c - TotalAmountPaid;
        
        return paymentInformation;
    }
    public static wrapperAcc getAccData(Id accId, List<String> mtId){  
        AmountPaid = 0;
        AmountDue = 0;
        paymentInformation = new List<paymentInfo>();
        wrapperAcc wrpData = new wrapperAcc();
        try{
        List<Account> accList = [SELECT Id,Name,Insured_s_Address__c,BillingAddress,
                                 ShippingAddress,Phone,Email_Id__c, Outstanding_Amount__c
                                 FROM Account 
                                 WHERE Id= :accId  WITH SECURITY_ENFORCED LIMIT 1];
        if(accList!=null && accList.size()>0){          
            for(Account acc:accList){
                wrpData.Name = acc.Name;
                if (acc.BillingAddress != null) {
    String street = acc.BillingAddress.getStreet();
    String city = acc.BillingAddress.getCity();
    String state = acc.BillingAddress.getState();
    String postalCode = acc.BillingAddress.getPostalCode();
    wrpData.add = street + ', ' + city + ', ' + state + ' ' + postalCode;
}

             //   wrpData.add= string.valueOf(acc.BillingAddress);
                wrpData.phn=acc.Phone;
                wrpData.email=acc.Email_Id__c;             
            }
        }      
      /*  List<Payment_Transaction__c> payTran= new List<Payment_Transaction__c>();
        payTran = [SELECT Id,Name,Actual_Price__c,Credit_Amount__c,Payment_Sub_Transaction__c,
                    Received_Amount__c,Payment_Sub_Transaction__r.Actual_Price__c
                   FROM Payment_Transaction__c 
                   WHERE Account__c= :accId
                   AND Payment_Sub_Transaction__c!=NULL
                   AND CreatedDate<=:transact WITH SECURITY_ENFORCED];//All transactions Before this Date
        Decimal totalReceivedAmountSoFar = 0;
        Decimal totalActualPrice = 0;
        Set<Id> compiledParentPayment = new Set<Id>();
        if(payTran!=null && payTran.size()>0){
            for(Payment_Transaction__c payment :payTran){
                Decimal recievedAmount = 0;
                if(!compiledParentPayment.contains(payment.Payment_Sub_Transaction__c)){
                    compiledParentPayment.add(payment.Payment_Sub_Transaction__c);
                    totalActualPrice+=refactorAmount(payment.Payment_Sub_Transaction__r.Actual_Price__c);//Total Actual Price
                }
                totalReceivedAmountSoFar+=refactorAmount(payment.Received_Amount__c);//Total Actual Received
            }
        }
        List<Payment_Transaction__c> paymentsMasterTransactionSpecific= new List<Payment_Transaction__c>();
        Map<String,Decimal> receivedPaymentsMasterSpecific = new Map<String,Decimal>();
        paymentsMasterTransactionSpecific = [SELECT Id,Name,Actual_Price__c,Credit_Amount__c,
                    Payment_Sub_Transaction__c,Received_Amount__c
                   FROM Payment_Transaction__c 
                   WHERE Master_Transaction__c= :transactions
                   AND Payment_Sub_Transaction__c!=NULL];
        Set<Id> allParentPayments = new Set<Id>();
        if(paymentsMasterTransactionSpecific!=null && paymentsMasterTransactionSpecific.size()>0){
            for(Payment_Transaction__c payment :paymentsMasterTransactionSpecific){
                Decimal recievedAmount = 0;
                allParentPayments.add(payment.Payment_Sub_Transaction__c);
                if(receivedPaymentsMasterSpecific.containsKey(payment.Payment_Sub_Transaction__c)){
                    recievedAmount= receivedPaymentsMasterSpecific.get(payment.Payment_Sub_Transaction__c);
                    recievedAmount += refactorAmount(payment.Received_Amount__c);
                    receivedPaymentsMasterSpecific.put(payment.Payment_Sub_Transaction__c,recievedAmount);
                }else{
                    receivedPaymentsMasterSpecific.put(payment.Payment_Sub_Transaction__c,refactorAmount(payment.Received_Amount__c));
                }
            }
        }
        if(allParentPayments!=null && allParentPayments.size()>0){
            payTran = [SELECT Id,Name,Actual_Price__c,Credit_Amount__c,Payment_Sub_Transaction__c,Procedure__r.Name,Procedure__r.Days_Units__c
                FROM Payment_Transaction__c WHERE Id IN :allParentPayments WITH SECURITY_ENFORCED];
                Integer quan=1;
                if(payTran!=null && payTran.size()>0){     
                    for(Payment_Transaction__c transactions : payTran){
                        if(transactions.Procedure__r.Days_Units__c!=null){
                            quan = (Integer) transactions.Procedure__r.Days_Units__c;
                        }
                        paymentInfo payment = new paymentInfo();
                        payment.procedureName = transactions.Procedure__r.Name;
                        payment.actualPrice = refactorAmount(transactions.Actual_Price__c);
                        payment.quantity = quan;
                        payment.receivedAmount = receivedPaymentsMasterSpecific.get(transactions.Id);
                        payment.remainingAmount = refactorAmount(transactions.Actual_Price__c) - refactorAmount(payment.receivedAmount);
                        AmountPaid+=payment.receivedAmount;
                        paymentInformation.add(payment);
                    }
                }
        }
        AmountDue = totalActualPrice - totalReceivedAmountSoFar;*/
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpData;
    }
    
    public class wrapperAcc {
        public String Name {get;set;} 
        public String add {get;set;}
        public String phn {get;set;}
        public String email {get;set;}
    }
    public class paymentInfo{
        public String procedureName {get;set;}
        public Integer quantity {get;set;}
        public decimal actualPrice {get;set;}
        //public decimal receivedAmount {get;set;}
        //public decimal remainingAmount {get;set;}
        //public decimal amountDue {get;set;}
      
        public decimal  AmountPaid {get;set;}
    }
    
    public static PDF_Header__c getPDFData(){
        PDF_Header__c record = PDF_Header__c.getInstance() ;
        return record ;
    }
    /*public class pdfHeaderWrapper { 
        public PDF_Header__c pdfAllData;
        public String headerImg;
    }
    private static Decimal refactorAmount(Decimal amt){
        if(amt == null){
            return 0;
        }
        return amt;
    }*/
}