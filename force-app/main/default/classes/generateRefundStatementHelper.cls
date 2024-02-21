public with sharing class generateRefundStatementHelper {
    public static wrapperAcc AccData {get;set;}
    public static List<paymentInfo> paymentInformation {get;set;}
    public static List<paymentInfo> paymentInformationList {get;set;}
    public static Decimal TotalAmountPaid {get;set;}
    public static String invoiceDate {get;set;}
    public static PDF_Header__c pdfData {get; set;}
    public static List<ElixirSuite__Refund__c> refundRec {get;set;}   
    public static String transactionTime {get;set;}
    public static List<String> transactions = new List<String>();
    public String tranId { get; set; }
    public static string imagePdf{get; set;}
    public generateRefundStatementHelper(){
        paymentInformationList = new List<paymentInfo>();
         tranId = ApexPages.currentPage().getParameters().get('tranId');
        system.debug('tranId ' +tranId);
        transactions = tranId.split(',');
        system.debug('transactions ' +transactions);
        refundRec = [SELECT Id,
                     Name,
                     ElixirSuite__Date_Created__c, 
                     ElixirSuite__Status__c,
                     ElixirSuite__Account__c,
                     ElixirSuite__Date_Issued__c,
                     ElixirSuite__Mode_of_Payment__c,
                     ElixirSuite__Credit_Check_Reference_field__c,
                     ElixirSuite__Refund_Amount__c, 
                     ElixirSuite__Reason_for_Refund__c, 
                     ElixirSuite__Master_Transaction__c, 
                     ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                     ElixirSuite__Transactions__c,
                     ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c
                     FROM ElixirSuite__Refund__c
                     WHERE Id =:transactions
                     WITH SECURITY_ENFORCED 
                     ORDER BY Name DESC];
        transactionTime = refundRec[0].ElixirSuite__Date_Created__c.format();
        pdfData= getPDFData();           
        AccData= getAccData(refundRec[0].Account__c, transactions);
        paymentInformationList = getPaymentData(refundRec);
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

    public static List<paymentInfo> getPaymentData(List<ElixirSuite__Refund__c> refundData){
         Decimal totalAmount = 0;
        if(refundData!=null && refundData.size()>0){
            for(ElixirSuite__Refund__c record: refundData){
                
                paymentInfo payment = new paymentInfo();
                payment.refundName = record.Name;
                payment.refundStatus = record.ElixirSuite__Status__c;
                if (record.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c != null) {
                    String cardNumber = record.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c;
                    String lastFourDigits = cardNumber.substring(Math.max(0, cardNumber.length() - 4));
                    String payMethod = record.ElixirSuite__Mode_of_Payment__c +' - '+ lastFourDigits;
                    payment.paymentMethod = payMethod;
                }else{
                  payment.paymentMethod = record.ElixirSuite__Mode_of_Payment__c;
                }
                payment.AmountRefunded = record.ElixirSuite__Refund_Amount__c;
                
                 totalAmount+=record.ElixirSuite__Refund_Amount__c;
                paymentInformation.add(payment);
            }
            
        }
        TotalAmountPaid = totalAmount;
        return paymentInformation;
    }
    public static wrapperAcc getAccData(Id accId, List<String> mtId){  
        paymentInformation = new List<paymentInfo>();
        wrapperAcc wrpData = new wrapperAcc();
        try{
            List<Account> accList = [SELECT Id,Name,Insured_s_Address__c,BillingAddress,
                                     ShippingAddress,Phone,Email_Id__c, Outstanding_Amount__c
                                     FROM Account 
                                     WHERE Id= :accId  WITH SECURITY_ENFORCED LIMIT 1];
            system.debug('accList-'+accList);
            if(accList!=null && accList.size()>0){          
                for(Account acc:accList){
                    system.debug('acc-'+acc);
                    wrpData.Name = acc.Name;
                    if (acc.BillingAddress != null) {
                        system.debug('acc.BillingAddress-'+acc.BillingAddress);
                        String street = acc.BillingAddress.getStreet();
                        String city = acc.BillingAddress.getCity();
                        String state = acc.BillingAddress.getState();
                        String postalCode = acc.BillingAddress.getPostalCode();
                        wrpData.add = street + ', ' + city + ', ' + state + ' ' + postalCode;
                        system.debug('wrpData.add-'+wrpData.add);
                    }
                    
                    //   wrpData.add= string.valueOf(acc.BillingAddress);
                    wrpData.phn=acc.Phone;
                    wrpData.email=acc.Email_Id__c;             
                }
            }      
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        system.debug('wrpData-'+wrpData);
        return wrpData;
    }
    
    public class wrapperAcc {
        public String Name {get;set;} 
        public String add {get;set;}
        public String phn {get;set;}
        public String email {get;set;}
    }
    public class paymentInfo{
        public String refundName {get;set;}
        public String refundStatus {get;set;}
        public String paymentMethod {get;set;}
        public decimal  AmountRefunded {get;set;}
        public decimal  totalAmountRefunded {get;set;}
    }
    public static PDF_Header__c getPDFData(){
        PDF_Header__c record = PDF_Header__c.getInstance() ;
        return record ;
    }
}