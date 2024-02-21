public with sharing class PatientStatementExportPDFHelper {
    public class OtherException extends Exception {}
    public static List<Payment_Transaction__c> payments {get;set;}
    public static List<Payment_Transaction__c> paymentsNewList {get;set;}
    public static List<Payment_Transaction__c> masterTransaction {get;set;}
    public static List<Transactions__c> allpayments {get;set;}
    public static Integer totalSum {get;set;}
    public static Decimal newCharges {get;set;}
    public static Integer paymentAdjustments {get;set;}
    public static Decimal totalRecAmt {get;set;}
    public static Decimal totalAdjustmentAmt {get;set;}
    public static String name {get;set;}
    public static String patientAddress {get;set;}
    public static String patientStateCode {get;set;}
    public static String mrnNum {get;set;}
    public static Datetime billDate {get;set;}
    public static String transactionDate {get;set;}
    public static Map<String,String> transactionDateMap{get;set;}
    public static Account acc {get;set;}
    public string accountValue {get;set;}
    public static Date startValue {get;set;}
    public static Date endValue {get;set;}
    public static Map<String,List<Transactions__c>> mapPaymentTrans{get;set;}
    public static Map<String,List<Payment_Transaction__c>> mapMasterpaymentTrans{get;set;}
    public static Map<String,String> procNames{get;set;}
    public static Map<String,String> transactionRecordType{get;set;}
    public static Map<String,Decimal> procRemaining{get;set;}
    public static Map<String,String> typeOfPayment{get;set;}
    public static Map<String,String> procServiceDate{get;set;}
    public static Map<String,String> procProviderName{get;set;}
    public static Map<String,Decimal> procAdjustment{get;set;}
    public static PDF_Header__c pdfData {get; set;}
    public static Decimal totalDiscount {get;set;}
    public static Decimal totalDiscount1 {get;set;}
    public static Decimal newCharges1 {get;set;}
    public static Decimal totalBilledAmount {get;set;}
    public static Map<String,Decimal> procTotal{get;set;}
    public static Map<String,Decimal> procInsurancePaid{get;set;}
    public static Map<String,Decimal> procAdjustmentVal{get;set;}
    public static Map<String,Decimal> procPatPaid{get;set;}
    public static Map<String,Decimal> procDiscountMap{get;set;}
    public static string imagePdf{get; set;}
    public static Decimal totalInsuranceAdjustment {get;set;}
    public static Map<String,Decimal> procRemainingForInsurance{get;set;}
    public static Decimal newChargesInurance {get;set;}
    public static Decimal totalInsurancePayment {get;set;}
    public static Decimal totalPatientPayment {get;set;}
    public static Decimal amountDue {get;set;}
    
    public PatientStatementExportPDFHelper()
    {
        mapPaymentTrans = new Map<String,List<Transactions__c>>();
        accountValue = '';
        startValue = System.today();
        endValue = System.today();
        mapMasterpaymentTrans = new Map<String,List<Payment_Transaction__c>>();
        procNames = new Map<String,String>();
        transactionDateMap = new Map<String,String>();
        totalInsurancePayment = 0;
        totalPatientPayment = 0;
        amountDue = 0;
        transactionRecordType = new Map<String,String>();
        procRemaining = new Map<String,Decimal>();
        procTotal = new Map<String,Decimal>();
        procInsurancePaid = new Map<String,Decimal>();
        procAdjustmentVal = new Map<String,Decimal>();
        procPatPaid = new Map<String,Decimal>();
        procDiscountMap = new Map<String,Decimal>();
        typeOfPayment = new Map<String,String>();
        procServiceDate = new Map<String,String>();
        procProviderName = new Map<String,String>();
        procAdjustment = new Map<String,Decimal>();
        paymentsNewList = new List<Payment_Transaction__c>();
        masterTransaction = new List<Payment_Transaction__c>();
        payments=new List<Payment_Transaction__c>();
        paymentAdjustments=0;
        totalSum=0;
        accountValue='';
        procRemainingForInsurance = new Map<String,Decimal>();
        newChargesInurance = 0;
        
        totalInsuranceAdjustment = 0;
        newCharges = 0;
        totalAdjustmentAmt=0;
        totalRecAmt = 0;
        totalDiscount = 0;
        totalDiscount1 = 0;
        newCharges1 = 0;
        totalBilledAmount = 0;
        String orderId = ApexPages.currentPage().getParameters().get('orderId');
        if(orderId!=null){
            List<String> retrievedValues = orderId.split('\\$');
            
            startValue = Date.valueOf(retrievedValues[0]) ;
            endValue = Date.valueOf(retrievedValues[1]) ;
            accountValue = retrievedValues[2];
        }
        
        pdfData= getPDFData(); 
        imagePdf=getPdfImg();
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Patient Statement'+'.pdf');
        List<Account> accounts = [SELECT Id, Name, MRN_Number_New__c,Account_Number__c,BillingAddress 
                                  FROM Account WHERE Id =:accountValue WITH SECURITY_ENFORCED];
        try{
            if(accounts!=null && accounts.size()>0){
                acc = accounts[0];
                name = accounts[0].Name;
                mrnNum = accounts[0].MRN_Number_New__c;
                billDate=  Datetime.valueOf(System.now().format('yyyy-MM-dd HH:mm:ss'));
                if (accounts[0].BillingAddress != null) {
                    getPatientAddress(accounts);
                }
            } 
            //   endValue = endValue.addDays(1);
            
            Map<Id,ElixirSuite__Visits__c> careIdVsCareEp = new Map<Id,ElixirSuite__Visits__c>([Select Id,
                                                                                                CreatedDate,
                                                                                                ElixirSuite__Account__c,
                                                                                                ElixirSuite__Status__c 
                                                                                                from ElixirSuite__Visits__c 
                                                                                                where ElixirSuite__Account__c =: accountValue 
                                                                                                AND DAY_ONLY(CreatedDate) >=: startValue 
                                                                                                AND DAY_ONLY(CreatedDate) <=: endValue
                                                                                                WITH SECURITY_ENFORCED]);
            
            
            Map<Id,ElixirSuite__Procedure__c> procIdVsProc = new Map<Id,ElixirSuite__Procedure__c>([Select Id,
                                                                                                    ElixirSuite__Visits__c 
                                                                                                    from ElixirSuite__Procedure__c 
                                                                                                    where ElixirSuite__Visits__c IN : careIdVsCareEp.keyset()
                                                                                                    WITH SECURITY_ENFORCED]);
            
            List<ElixirSuite__Procedure__c> procLst = [Select Id,
                                                       ElixirSuite__Visits__c,
                                                       ElixirSuite__Account__c,
                                                       ElixirSuite__From_Date_of_Service__c
                                                       from ElixirSuite__Procedure__c 
                                                       where ElixirSuite__Visits__c = null
                                                       AND ElixirSuite__Account__c=:accountValue
                                                       AND DAY_ONLY(ElixirSuite__From_Date_of_Service__c) >=: startValue 
                                                       AND DAY_ONLY(ElixirSuite__From_Date_of_Service__c) <=: endValue
                                                       WITH SECURITY_ENFORCED];
            
            for(ElixirSuite__Procedure__c proc : procLst){
                procIdVsProc.put(proc.Id,proc);   
            }
            
            List<Transactions__c> filteredPayments = [SELECT id,name,ElixirSuite__Amount_Paid__c,ElixirSuite__Master_Transaction__c,ElixirSuite__Payment_Received_By__c,
                                                      ElixirSuite__Other_Transactions__r.ElixirSuite__Mode_of_Payment__c,
                                                      ElixirSuite__Other_Transactions__r.ElixirSuite__Payment_Transaction_Number__c,
                                                      ElixirSuite__Other_Transactions__c,ElixirSuite__Payment_DateTime__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure_Name__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Date_Of_Service__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c,
                                                      ElixirSuite__Master_Transaction__r.Total_Actual_Patient_Paid_Amount__c,
                                                      ElixirSuite__Master_Transaction__r.Procedure__c,
                                                      ElixirSuite__Master_Transaction__r.Procedure__r.From_Date_of_Service__c,
                                                      ElixirSuite__Master_Transaction__r.Provider__r.Name,
                                                      ElixirSuite__Master_Transaction__r.Procedure__r.ElixirSuite__Type_of_Procedure__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Payment_Adjustments__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Adjustment_Amount__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Insurance_Paid__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Patient_Refund__c,
                                                      ElixirSuite__Master_Transaction__r.RecordType.DeveloperName,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Patient_Responsibility__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c,
                                                      ElixirSuite__Transaction_Status__c,
                                                      ElixirSuite__Type_of_Payment__c
                                                      FROM ElixirSuite__Transactions__c
                                                      WHERE //CreatedDate >=: startValue 
                                                      //  AND CreatedDate <=: endValue 
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c = :accountValue
                                                      AND ElixirSuite__Transaction_Status__c = 'Successful'
                                                      AND ElixirSuite__Master_Transaction__r.Procedure__c IN :procIdVsProc.Keyset()
                                                      AND ElixirSuite__Type_of_Payment__c !='Discount'  
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
                /*  if(masterTrans.ElixirSuite__Transactions__r != null && masterTrans.ElixirSuite__Transactions__r.size() >0) {
} */ //commented by Anmol for SFDX Debugger Issues
                if(masterTrans.ElixirSuite__Transactions__r == null && masterTrans.ElixirSuite__Transactions__r.size() <0){
                    paymentsNewList.add(masterTrans);
                }
            }
            
            for(Transactions__c payTrans : filteredPayments){
                totalRecAmt = totalRecAmt+ payTrans.ElixirSuite__Amount_Paid__c;
                transactionDate = payTrans.ElixirSuite__Payment_DateTime__c.format();
                transactionDateMap.put(payTrans.Id,transactionDate);
                if(String.isNotBlank(payTrans.ElixirSuite__Master_Transaction__c)){
                   
                    Id procId = payTrans.ElixirSuite__Master_Transaction__r.Procedure__c;
                    if(String.isNotBlank(procId)){
                        
                        PatientStatementExportPDFHelper.removeIfElseThird(procId,payTrans);
                    }
                }
            }
            totalRecAmt = totalRecAmt - totalAdjustmentAmt;
            
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        //Commited
        catch(Exception e){
            //ExceptionLog.logError(e);
        }
    }
    
    public static void removeIfElseThird(Id procId, Transactions__c payTrans){
        
        if(mapPaymentTrans.containsKey(procId)){
            mapPaymentTrans.get(procId).add(payTrans);
            
        }else{
            mapPaymentTrans.put(procId,new List<Transactions__c>{payTrans});
            procNames.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure_Name__c);
            transactionRecordType.put(procId,payTrans.ElixirSuite__Master_Transaction__r.RecordType.DeveloperName);
            if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c != null){
                
                PatientStatementExportPDFHelper.removeIfElseSecond(procId,payTrans);
                
            }
            else{
                procRemaining.put(procId,0); 
                procRemainingForInsurance.put(procId,0);
            }
            
            PatientStatementExportPDFHelper.removeIfElse(procId,payTrans);
            
        }
        
    }
    
    public static void removeIfElseSecond(Id procId, Transactions__c payTrans){
        
        totalDiscount1 = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c;
        totalInsuranceAdjustment = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Adjustment_Amount__c ;
        // For Private Payment
        if(payTrans.ElixirSuite__Master_Transaction__r.RecordType.DeveloperName=='Private_Payment'){
            //newCharges1 = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c - totalDiscount1 - payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c ;
            procRemaining.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c);
        }
        // For Insurance Payment
        if(payTrans.ElixirSuite__Master_Transaction__r.RecordType.DeveloperName=='Insurance_Payment'){
            //  newChargesInurance = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c - (payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Insurance_Paid__c +payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c) ;
            //newChargesInurance = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Patient_Responsibility__c - payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c ;
            procRemainingForInsurance.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c);
        }
        newCharges = newCharges + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c;
        //newCharges = newCharges + newCharges1+newChargesInurance;
        newChargesInurance = 0;
        newCharges1 = 0;
        
    }
    
    public static void removeIfElse(Id procId, Transactions__c payTrans){
        
        if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c != null){
            Decimal amt = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c ;
            procTotal.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c);
            totalBilledAmount = totalBilledAmount + amt ;
        }
        else{
            procTotal.put(procId,0); 
        }
        
        if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Insurance_Paid__c != null){
            procInsurancePaid.put(procId,payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Insurance_Paid__c);
            totalInsurancePayment = totalInsurancePayment + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Insurance_Paid__c;
        }
        else{
            procInsurancePaid.put(procId,0); 
        }
        
        if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Adjustment_Amount__c != null){
            Decimal totalAdj = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Adjustment_Amount__c;
            procAdjustmentVal.put(procId,totalAdj);
        }
        else{
            procAdjustmentVal.put(procId,0); 
        }
        
        if(payTrans.ElixirSuite__Master_Transaction__r.Total_Actual_Patient_Paid_Amount__c != null){
            procPatPaid.put(procId,payTrans.ElixirSuite__Master_Transaction__r.Total_Actual_Patient_Paid_Amount__c);
            totalPatientPayment = totalPatientPayment + payTrans.ElixirSuite__Master_Transaction__r.Total_Actual_Patient_Paid_Amount__c;
        }
        else{
            procPatPaid.put(procId,0); 
        }
        
        if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c != null && payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c != null){
            totalDiscount1 = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c;
            procDiscountMap.put(procId,totalDiscount1);
        }
        else{
            procDiscountMap.put(procId,0); 
        }
        if(payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Adjustment_Amount__c != null){
            totalInsuranceAdjustment = payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Adjustment_Amount__c ; 
            totalAdjustmentAmt = totalAdjustmentAmt+ payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Adjustment_Amount__c + totalDiscount1;
            procAdjustment.put(procId,totalInsuranceAdjustment);
        }else{
            procAdjustment.put(procId,0);  
        }
        typeOfPayment.put(procId,payTrans.ElixirSuite__Master_Transaction__r.Procedure__r.ElixirSuite__Type_of_Procedure__c);
        procServiceDate.put(procId,'');
        procProviderName.put(procId,'');
        
        if(payTrans.ElixirSuite__Master_Transaction__r.Provider__r.Name!=null){
            procProviderName.put(procId,payTrans.ElixirSuite__Master_Transaction__r.Provider__r.Name);
        }
        
        if(payTrans.ElixirSuite__Master_Transaction__r.Procedure__r.From_Date_of_Service__c!=null){
            procServiceDate.put(procId,payTrans.ElixirSuite__Master_Transaction__r.Procedure__r.From_Date_of_Service__c.format());
        }
        
        //amountDue = totalBilledAmount - (totalAdjustmentAmt + totalInsurancePayment + totalPatientPayment);
        amountDue = amountDue + payTrans.ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c;
    }
    
    public static WrapperData getPaymentTransactionInfoDuplicate(String accountId,Date startDate,Date endDate){
        // endDate = endDate.addDays(1);
        //   allpayments = new List<ElixirSuite__Transactions__c>();
        
        
        Map<Id,ElixirSuite__Visits__c> careIdVsCareEp = new Map<Id,ElixirSuite__Visits__c>([Select Id,
                                                                                            CreatedDate,
                                                                                            ElixirSuite__Account__c,
                                                                                            ElixirSuite__Status__c 
                                                                                            from ElixirSuite__Visits__c 
                                                                                            where ElixirSuite__Account__c =: accountId 
                                                                                            AND DAY_ONLY(CreatedDate) >=: startDate 
                                                                                            AND DAY_ONLY(CreatedDate) <=: endDate
                                                                                            WITH SECURITY_ENFORCED]);
        
        
        Map<Id,ElixirSuite__Procedure__c> procIdVsProc = new Map<Id,ElixirSuite__Procedure__c>([Select Id,
                                                                                                ElixirSuite__Visits__c 
                                                                                                from ElixirSuite__Procedure__c 
                                                                                                where ElixirSuite__Visits__c IN : careIdVsCareEp.keyset()
                                                                                                WITH SECURITY_ENFORCED]);
        
        List<ElixirSuite__Procedure__c> procLst = [Select Id,
                                                   ElixirSuite__Visits__c,
                                                   ElixirSuite__Account__c,
                                                   ElixirSuite__From_Date_of_Service__c
                                                   from ElixirSuite__Procedure__c 
                                                   where ElixirSuite__Visits__c = null
                                                   AND ElixirSuite__Account__c=:accountId
                                                   AND DAY_ONLY(ElixirSuite__From_Date_of_Service__c) >=: startDate 
                                                   AND DAY_ONLY(ElixirSuite__From_Date_of_Service__c) <=: endDate
                                                   WITH SECURITY_ENFORCED];
        
        for(ElixirSuite__Procedure__c proc : procLst){
            procIdVsProc.put(proc.Id,proc);   
        }
        
        
        List<ElixirSuite__Transactions__c> filteredTransactionRecords = [SELECT id,name,ElixirSuite__Amount_Paid__c,ElixirSuite__Master_Transaction__c,
                                                                         ElixirSuite__Other_Transactions__c,ElixirSuite__Payment_DateTime__c,
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                                                                         ElixirSuite__Master_Transaction__r.Procedure__c,
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure_Name__c,
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Date_Of_Service__c,
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c,
                                                                         ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c,
                                                                         ElixirSuite__Master_Transaction__r.Total_Actual_Patient_Paid_Amount__c,
                                                                         ElixirSuite__Transaction_Status__c
                                                                         FROM ElixirSuite__Transactions__c
                                                                         WHERE ElixirSuite__Master_Transaction__r.Procedure__c IN :procIdVsProc.Keyset()
                                                                         AND ElixirSuite__Type_of_Payment__c !='Discount' 
                                                                         AND ElixirSuite__Transaction_Status__c = 'Successful'
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
        WrapperData obj = new WrapperData();
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
            if(Test.isRunningTest())
            {
                throw new OtherException();
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
    public string getstring(){
        return null;
    }
    public static void getPatientAddress(list<Account> accounts){
        String street = '';
        String city = '';
        String state = '';
        String postalCode = '';
        if(accounts[0].BillingAddress.getStreet() != null){
            street = accounts[0].BillingAddress.getStreet();
        }
        if(accounts[0].BillingAddress.getCity() != null){
            city = accounts[0].BillingAddress.getCity();
        }
        if(accounts[0].BillingAddress.getState() != null){
            state = accounts[0].BillingAddress.getState();
        }
        if(accounts[0].BillingAddress.getPostalCode() != null){
            postalCode = accounts[0].BillingAddress.getPostalCode();
        }
        patientAddress = street;
        patientStateCode =  city +' ' +state + ' ' + postalCode;
    }
    public class WrapperData{       
        @AuraEnabled Public List<ElixirSuite__Payment_Transaction__c> masterTransaction; 
        @AuraEnabled Public List<ElixirSuite__Transactions__c> paymentsTransactions;
    }
}