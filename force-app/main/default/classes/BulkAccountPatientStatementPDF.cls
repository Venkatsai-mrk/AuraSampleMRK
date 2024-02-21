public with sharing class BulkAccountPatientStatementPDF {
    
    public static Date startValue {get;set;} //Start Date
    public static Date endValue {get;set;} // End Date
    public static List<Account> accDetails {get;set;} // Account Detail
    public static Map<String,List<ElixirSuite__Procedure__c>> accVSListOfProc{get;set;} // Storing accId VS List of Transaction
    public static Map<String,List<Transactions__c>> masterIdVSListOfTrans{get;set;} // Storing masterTranId VS List of Transaction
    public static Map<String,List<Transactions__c>> procVSTrans{get;set;}// Storing procedureId VS List of Transaction
    public static PDF_Header__c pdfData {get; set;}
    public static string imagePdf{get; set;}
    public static Map<String,Decimal> totalInsurancePayment {get;set;} //Storing accId VS Total Insurance Paid
    public static Map<String,Decimal> totalPatientPayment {get;set;} //Storing accId VS Total Patient Paid
    public static Map<String,Decimal> amountDue {get;set;} //Storing accId VS Total Due Amount
    public static Map<String,Decimal> totalBilledAmount {get;set;} //Storing accId VS Total Billed Amount
    public static Map<String,Decimal> totalAdjustmentAmt {get;set;} //Storing accId VS Total Adjustment Amount
    public static Map<String,ElixirSuite__Payment_Transaction__c> procVSMasterTransaction {get;set;} //Storing procedureId VS Master Transaction
    public static Map<String,Integer> accVsSizeOfTrans {get;set;} //Storing accId VS size of Transaction List
    public static Map<String,Decimal> procRemaining{get;set;} //Storing ProcedureId VS Private payment MT Rem. Amount
    public static Map<String,Decimal> procRemainingForInsurance{get;set;} //Storing ProcedureId VS Insurance payment MT Rem. Amount
    public static Map<String,Decimal> procDiscountMap{get;set;} //Storing ProcedureId VS t MT  Discount Amount
    public static Integer accCount{get;set;} // count of Account for pdf generation
    public BulkAccountPatientStatementPDF()
    {
        try{
            
            Set<Id> accId = new Set<Id>();// storing accountId
            accVSListOfProc = new Map<String,List<ElixirSuite__Procedure__c>>();
            masterIdVSListOfTrans = new Map<String,List<Transactions__c>>();
            procVSTrans = new Map<String,List<Transactions__c>>();
            totalInsurancePayment = new Map<String,Decimal>();
            totalPatientPayment = new Map<String,Decimal>();
            amountDue = new Map<String,Decimal>();
            totalBilledAmount = new Map<String,Decimal>();
            totalAdjustmentAmt = new Map<String,Decimal>();
            procVSMasterTransaction = new Map<String,ElixirSuite__Payment_Transaction__c>();
            accVsSizeOfTrans = new Map<String,Integer>();
            procRemaining = new Map<String,Decimal>();
            procRemainingForInsurance = new Map<String,Decimal>();
            procDiscountMap = new Map<String,Decimal>();
            startValue = System.today();
            endValue = System.today();
            accCount=0;
            
            String orderId = ApexPages.currentPage().getParameters().get('orderId');
            if(orderId!=null){
                List<String> retrievedValues = orderId.split('\\$');
                startValue = Date.valueOf(retrievedValues[0]) ;
                endValue = Date.valueOf(retrievedValues[1]);
            }
            
         //   endValue = endValue.addDays(1);
            
            Map<Id,ElixirSuite__Visits__c> careIdVsCareEp = new Map<Id,ElixirSuite__Visits__c>([Select Id,
                                                                                                CreatedDate,
                                                                                                ElixirSuite__Account__c,
                                                                                                ElixirSuite__Status__c 
                                                                                                FROM ElixirSuite__Visits__c 
                                                                                                WHERE ElixirSuite__Account__c !=null 
                                                                                                AND DAY_ONLY(CreatedDate) >=: startValue 
                                                                                                AND DAY_ONLY(CreatedDate) <=: endValue
                                                                                                WITH SECURITY_ENFORCED
                                                                                                ORDER by ElixirSuite__Account__c]);
            
            
            Map<Id,ElixirSuite__Procedure__c> procIdVsProc = new Map<Id,ElixirSuite__Procedure__c>([Select Id,
                                                                                                    Name,
                                                                                                    ElixirSuite__Type_of_Procedure__c,
                                                                                                    ElixirSuite__Charges__c,
                                                                                                    ElixirSuite__Account__c,
                                                                                                    ElixirSuite__Visits__c,
                                                                                                    ElixirSuite__From_Date_of_Service__c
                                                                                                    FROM ElixirSuite__Procedure__c 
                                                                                                    WHERE ElixirSuite__Visits__c IN : careIdVsCareEp.keyset()
                                                                                                    AND ElixirSuite__Type_of_Procedure__c!=null
                                                                                                    AND ElixirSuite__Charges__c>0
                                                                                                    WITH SECURITY_ENFORCED]);
            
            
            List<ElixirSuite__Procedure__c> procLst = [Select Id,
                                                       Name,
                                                       ElixirSuite__Type_of_Procedure__c,
                                                       ElixirSuite__Charges__c,
                                                       ElixirSuite__Visits__c,
                                                       ElixirSuite__Account__c,
                                                       ElixirSuite__From_Date_of_Service__c
                                                       FROM ElixirSuite__Procedure__c 
                                                       WHERE ElixirSuite__Visits__c = null
                                                       AND ElixirSuite__Account__c!=null
                                                       AND DAY_ONLY(ElixirSuite__From_Date_of_Service__c) >=: startValue 
                                                       AND DAY_ONLY(ElixirSuite__From_Date_of_Service__c) <=: endValue
                                                       AND ElixirSuite__Type_of_Procedure__c!=null
                                                       AND ElixirSuite__Charges__c>0
                                                       WITH SECURITY_ENFORCED
                                                       ORDER by ElixirSuite__Account__c];
            
            for(ElixirSuite__Procedure__c proc : procLst){
                procIdVsProc.put(proc.Id,proc);  
            }
            
            for(ElixirSuite__Procedure__c proc : procIdVsProc.values()){
                                
                if(accVSListOfProc == null || accVSListOfProc.isEmpty()){
                    List<ElixirSuite__Procedure__c> pList = new List<ElixirSuite__Procedure__c>();
                    pList.add(proc);   
                    accVSListOfProc.put(proc.ElixirSuite__Account__c,pList); 
                }else if(accVSListOfProc.get(proc.ElixirSuite__Account__c)== null){
                    List<ElixirSuite__Procedure__c> pList = new List<ElixirSuite__Procedure__c>();
                    pList.add(proc);   
                    accVSListOfProc.put(proc.ElixirSuite__Account__c,pList);   
                }else{
                    List<ElixirSuite__Procedure__c> pList = accVSListOfProc.get(proc.ElixirSuite__Account__c);
                    pList.add(proc);   
                    accVSListOfProc.put(proc.ElixirSuite__Account__c,pList);    
                }
            }
                        
            Map<Id,ElixirSuite__Payment_Transaction__c> masterIdVsMasterRec = new Map<Id,ElixirSuite__Payment_Transaction__c>([SELECT Id,
                                                                                                                               ElixirSuite__Procedure__c,
                                                                                                                               ElixirSuite__Procedure_Name__c,
                                                                                                                               (select Id,ElixirSuite__Transaction_Status__c,ElixirSuite__Type_of_Payment__c from ElixirSuite__Transactions__r where ElixirSuite__Transaction_Status__c = 'Successful' AND ElixirSuite__Type_of_Payment__c !='Discount'),
                                                                                                                               ElixirSuite__Date_Of_Service__c,
                                                                                                                               ElixirSuite__Total_Patient_Refund__c,
                                                                                                                               ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                                                                                                                               ElixirSuite__Provider__r.Name,
                                                                                                                               ElixirSuite__Expected_Receivable_amount__c,
                                                                                                                               ElixirSuite__Total_Paid_Amount__c,
                                                                                                                               ElixirSuite__PatientOutstanding__c,
                                                                                                                               ElixirSuite__Account__c,
                                                                                                                               RecordType.DeveloperName,
                                                                                                                               ElixirSuite__Insurance_Paid__c,
                                                                                                                               ElixirSuite__Patient_Responsibility__c,
                                                                                                                               ElixirSuite__Total_Adjustment_Amount__c,
                                                                                                                               ElixirSuite__Other_Discount__c,
                                                                                                                               ElixirSuite__Discount_Amount__c,
                                                                                                                               ElixirSuite__Payment_Adjustments__c,
                                                                                                                               ElixirSuite__Actual_Price__c
                                                                                                                               FROM ElixirSuite__Payment_Transaction__c
                                                                                                                               WHERE ElixirSuite__Procedure__c IN :procIdVsProc.Keyset()
                                                                                                                               WITH SECURITY_ENFORCED]);
            
            for(ElixirSuite__Payment_Transaction__c rec:masterIdVsMasterRec.values()){            
                if(rec.ElixirSuite__Transactions__r.size()==0 && accVSListOfProc!=null && accVSListOfProc.get(rec.ElixirSuite__Account__c)!=null){
                    List<ElixirSuite__Procedure__c> procedureLst = accVSListOfProc.get(rec.ElixirSuite__Account__c);
                    Integer result = procedureLst.indexOf( procIdVsProc.get(rec.ElixirSuite__Procedure__c));
                    procedureLst.remove(result);
                    accVSListOfProc.put(rec.ElixirSuite__Account__c, procedureLst);
                }

                if(rec.ElixirSuite__Transactions__r.size()>0){
                accId.add(rec.ElixirSuite__Account__c);
                if(rec.ElixirSuite__Procedure__c != null){
                    procVSMasterTransaction.put(rec.ElixirSuite__Procedure__c,rec);  
                }
                
                if(accVsSizeOfTrans== null){
                    accVsSizeOfTrans.put(rec.ElixirSuite__Account__c, rec.ElixirSuite__Transactions__r.size());
                }
                else if(accVsSizeOfTrans.get(rec.ElixirSuite__Account__c) == null){
                    accVsSizeOfTrans.put(rec.ElixirSuite__Account__c, rec.ElixirSuite__Transactions__r.size());
                }
                else if(accVsSizeOfTrans.get(rec.ElixirSuite__Account__c) != null){
                    Integer size = accVsSizeOfTrans.get(rec.ElixirSuite__Account__c) +1;
                    accVsSizeOfTrans.put(rec.ElixirSuite__Account__c, size);
                }
                

                if(totalBilledAmount == null && rec.ElixirSuite__Actual_Price__c != null) {
                    totalBilledAmount.put(rec.ElixirSuite__Account__c,rec.ElixirSuite__Actual_Price__c);
                }else if(totalBilledAmount == null && rec.ElixirSuite__Actual_Price__c == null){
                    totalBilledAmount.put(rec.ElixirSuite__Account__c,0);
                }else if(totalBilledAmount.get(rec.ElixirSuite__Account__c) == null && rec.ElixirSuite__Actual_Price__c != null){
                    totalBilledAmount.put(rec.ElixirSuite__Account__c,rec.ElixirSuite__Actual_Price__c);
                }else if(totalBilledAmount.get(rec.ElixirSuite__Account__c) == null && rec.ElixirSuite__Actual_Price__c == null){
                    totalBilledAmount.put(rec.ElixirSuite__Account__c,0); 
                }else if(totalBilledAmount.get(rec.ElixirSuite__Account__c) != null && rec.ElixirSuite__Actual_Price__c != null){
                    Decimal actPrice = totalBilledAmount.get(rec.ElixirSuite__Account__c) + rec.ElixirSuite__Actual_Price__c;
                    totalBilledAmount.put(rec.ElixirSuite__Account__c,actPrice);
                }

                
                if(totalInsurancePayment == null && rec.ElixirSuite__Insurance_Paid__c != null) {
                    totalInsurancePayment.put(rec.ElixirSuite__Account__c,rec.ElixirSuite__Insurance_Paid__c);
                }else if(totalInsurancePayment == null && rec.ElixirSuite__Insurance_Paid__c == null){
                    totalInsurancePayment.put(rec.ElixirSuite__Account__c,0);
                }else if(totalInsurancePayment.get(rec.ElixirSuite__Account__c) == null && rec.ElixirSuite__Insurance_Paid__c != null){
                    totalInsurancePayment.put(rec.ElixirSuite__Account__c,rec.ElixirSuite__Insurance_Paid__c);
                }else if(totalInsurancePayment.get(rec.ElixirSuite__Account__c) == null && rec.ElixirSuite__Insurance_Paid__c == null){
                    totalInsurancePayment.put(rec.ElixirSuite__Account__c,0); 
                }else if(totalInsurancePayment.get(rec.ElixirSuite__Account__c) != null && rec.ElixirSuite__Insurance_Paid__c != null){
                    Decimal insPaid = totalInsurancePayment.get(rec.ElixirSuite__Account__c) + rec.ElixirSuite__Insurance_Paid__c;
                    totalInsurancePayment.put(rec.ElixirSuite__Account__c,insPaid);
                }
                
                if(totalPatientPayment == null && rec.ElixirSuite__Total_Actual_Patient_Paid_Amount__c != null) {
                    totalPatientPayment.put(rec.ElixirSuite__Account__c,rec.ElixirSuite__Total_Actual_Patient_Paid_Amount__c);
                }else if(totalPatientPayment == null && rec.ElixirSuite__Total_Actual_Patient_Paid_Amount__c == null){
                    totalPatientPayment.put(rec.ElixirSuite__Account__c,0);
                }else if(totalPatientPayment.get(rec.ElixirSuite__Account__c) == null && rec.ElixirSuite__Total_Actual_Patient_Paid_Amount__c != null){
                    totalPatientPayment.put(rec.ElixirSuite__Account__c,rec.ElixirSuite__Total_Actual_Patient_Paid_Amount__c);
                }else if(totalPatientPayment.get(rec.ElixirSuite__Account__c) == null && rec.ElixirSuite__Total_Actual_Patient_Paid_Amount__c == null){
                    totalPatientPayment.put(rec.ElixirSuite__Account__c,0); 
                }else if(totalPatientPayment.get(rec.ElixirSuite__Account__c) != null && rec.ElixirSuite__Total_Actual_Patient_Paid_Amount__c != null){
                    Decimal patPaid = totalPatientPayment.get(rec.ElixirSuite__Account__c) + rec.ElixirSuite__Total_Actual_Patient_Paid_Amount__c;
                    totalPatientPayment.put(rec.ElixirSuite__Account__c,patPaid);
                }
                
                if(totalAdjustmentAmt == null && (rec.RecordType.DeveloperName=='Insurance_Payment' || rec.RecordType.DeveloperName=='Private_Payment')) {
                   Decimal adjAmt = rec.ElixirSuite__Discount_Amount__c + rec.ElixirSuite__Other_Discount__c+ rec.ElixirSuite__Total_Adjustment_Amount__c ;
                    totalAdjustmentAmt.put(rec.ElixirSuite__Account__c,rec.ElixirSuite__Total_Paid_Amount__c);
                    //Decimal dueAmount = totalBilledAmount.get(rec.ElixirSuite__Account__c) - (totalInsurancePayment.get(rec.ElixirSuite__Account__c) + totalPatientPayment.get(rec.ElixirSuite__Account__c) + adjAmt);
                    if(amountDue.containsKey(rec.ElixirSuite__Account__c)){
                        Decimal dueAmount = amountDue.get(rec.ElixirSuite__Account__c) + rec.ElixirSuite__PatientOutstanding__c;
                        amountDue.put(rec.ElixirSuite__Account__c,dueAmount);
                    }
                    else{
                        Decimal dueAmount = rec.ElixirSuite__PatientOutstanding__c;
                    	amountDue.put(rec.ElixirSuite__Account__c,dueAmount);
                    }
                    
                    
                }else if(totalAdjustmentAmt.get(rec.ElixirSuite__Account__c) == null && (rec.RecordType.DeveloperName=='Insurance_Payment' || rec.RecordType.DeveloperName=='Private_Payment')){
                    Decimal adjAmt = rec.ElixirSuite__Discount_Amount__c + rec.ElixirSuite__Other_Discount__c+ rec.ElixirSuite__Total_Adjustment_Amount__c ;
                    totalAdjustmentAmt.put(rec.ElixirSuite__Account__c,adjAmt);
                    //Decimal dueAmount = totalBilledAmount.get(rec.ElixirSuite__Account__c) - (totalInsurancePayment.get(rec.ElixirSuite__Account__c) + totalPatientPayment.get(rec.ElixirSuite__Account__c) + adjAmt);
                    if(amountDue.containsKey(rec.ElixirSuite__Account__c)){
                        Decimal dueAmount = amountDue.get(rec.ElixirSuite__Account__c) + rec.ElixirSuite__PatientOutstanding__c;
                        amountDue.put(rec.ElixirSuite__Account__c,dueAmount);
                    }
                    else{
                        Decimal dueAmount = rec.ElixirSuite__PatientOutstanding__c;
                    	amountDue.put(rec.ElixirSuite__Account__c,dueAmount);
                    }
                }else if(totalAdjustmentAmt.get(rec.ElixirSuite__Account__c) != null && (rec.RecordType.DeveloperName=='Insurance_Payment' || rec.RecordType.DeveloperName=='Private_Payment')){
                    Decimal adjAmt = rec.ElixirSuite__Discount_Amount__c + rec.ElixirSuite__Other_Discount__c+ rec.ElixirSuite__Total_Adjustment_Amount__c ;
                    Decimal totalAdjAmt = totalAdjustmentAmt.get(rec.ElixirSuite__Account__c) + adjAmt;
                    totalAdjustmentAmt.put(rec.ElixirSuite__Account__c,totalAdjAmt);
                    //Decimal dueAmount = totalBilledAmount.get(rec.ElixirSuite__Account__c) - (totalInsurancePayment.get(rec.ElixirSuite__Account__c) + totalPatientPayment.get(rec.ElixirSuite__Account__c) + totalAdjAmt);
                    if(amountDue.containsKey(rec.ElixirSuite__Account__c)){
                        Decimal dueAmount = amountDue.get(rec.ElixirSuite__Account__c) + rec.ElixirSuite__PatientOutstanding__c;
                        amountDue.put(rec.ElixirSuite__Account__c,dueAmount);
                    }
                    else{
                        Decimal dueAmount = rec.ElixirSuite__PatientOutstanding__c;
                    	amountDue.put(rec.ElixirSuite__Account__c,dueAmount);
                    }
                }
                
                
                Decimal totalDiscount1 = rec.ElixirSuite__Discount_Amount__c + rec.ElixirSuite__Other_Discount__c;
                procDiscountMap.put(rec.ElixirSuite__Procedure__c,totalDiscount1);
                if(rec.ElixirSuite__PatientOutstanding__c != null && rec.RecordType.DeveloperName=='Private_Payment'){
                    //Decimal newCharges1 = rec.ElixirSuite__Actual_Price__c - totalDiscount1 - rec.ElixirSuite__Total_Paid_Amount__c ;
                    procRemaining.put(rec.ElixirSuite__Procedure__c,rec.ElixirSuite__PatientOutstanding__c);
                }else if(rec.ElixirSuite__PatientOutstanding__c != null && rec.RecordType.DeveloperName=='Insurance_Payment'){
                    //Decimal newChargesInurance = rec.ElixirSuite__Patient_Responsibility__c - rec.ElixirSuite__Total_Paid_Amount__c ;
                    procRemainingForInsurance.put(rec.ElixirSuite__Procedure__c,rec.ElixirSuite__PatientOutstanding__c);
                }else{
                    procRemaining.put(rec.ElixirSuite__Procedure__c,0); 
                    procRemainingForInsurance.put(rec.ElixirSuite__Procedure__c,0);
                }
                
                  }
                
            }

            accDetails = [SELECT Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,MRN_Number_New__c FROM Account where Id IN:accId WITH SECURITY_ENFORCED];
            
            accCount = accDetails.size();
            
            List<Transactions__c> filteredPayments = [SELECT id,name,ElixirSuite__Amount_Paid__c,ElixirSuite__Master_Transaction__c,ElixirSuite__Payment_Received_By__c,
                                                      ElixirSuite__Other_Transactions__r.ElixirSuite__Mode_of_Payment__c,
                                                      ElixirSuite__Other_Transactions__r.ElixirSuite__Payment_Transaction_Number__c,
                                                      ElixirSuite__Other_Transactions__c,ElixirSuite__Payment_DateTime__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Procedure_Name__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Date_Of_Service__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Actual_Price__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Paid_Amount__c,
                                                      ElixirSuite__Master_Transaction__r.Procedure__c,
                                                      ElixirSuite__Master_Transaction__r.Procedure__r.From_Date_of_Service__c,
                                                      ElixirSuite__Master_Transaction__r.Provider__r.Name,
                                                      ElixirSuite__Master_Transaction__r.Procedure__r.ElixirSuite__Type_of_Procedure__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__PatientOutstanding__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Payment_Adjustments__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Discount_Amount__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Other_Discount__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Total_Adjustment_Amount__c,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Insurance_Paid__c,
                                                      ElixirSuite__Master_Transaction__r.RecordType.DeveloperName,
                                                      ElixirSuite__Master_Transaction__r.ElixirSuite__Patient_Responsibility__c,
                                                      ElixirSuite__Type_of_Payment__c,
                                                      ElixirSuite__Transaction_Status__c
                                                      FROM ElixirSuite__Transactions__c
                                                      WHERE //CreatedDate >=: startValue 
                                                      //  AND CreatedDate <=: endValue 
                                                      ElixirSuite__Master_Transaction__c IN :masterIdVsMasterRec.Keyset()
                                                      AND ElixirSuite__Type_of_Payment__c !='Discount'  
                                                      AND ElixirSuite__Transaction_Status__c = 'Successful'
                                                      WITH SECURITY_ENFORCED
                                                      ORDER BY CreatedDate];
            
            
            for(Transactions__c payTrans : filteredPayments){
                
                if(procVSTrans== null){
                    List<Transactions__c> nList = new List<Transactions__c>();
                    nList.add(payTrans);
                    procVSTrans.put(payTrans.ElixirSuite__Master_Transaction__r.Procedure__c, nList); 
                }else if(procVSTrans.get(payTrans.ElixirSuite__Master_Transaction__r.Procedure__c) == null){
                    List<Transactions__c> nList = new List<Transactions__c>();
                    nList.add(payTrans);
                    procVSTrans.put(payTrans.ElixirSuite__Master_Transaction__r.Procedure__c, nList);  
                }else{
                    List<Transactions__c> nList = procVSTrans.get(payTrans.ElixirSuite__Master_Transaction__r.Procedure__c);
                    nList.add(payTrans);
                    procVSTrans.put(payTrans.ElixirSuite__Master_Transaction__r.Procedure__c, nList); 
                }
                
                
                
            }
            
            
            pdfData= getPDFData();   
            imagePdf=getPdfImg();  
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    public static PDF_Header__c getPDFData(){
        PDF_Header__c record = PDF_Header__c.getInstance() ;
        return record ;
    }
@AuraEnabled
    public static Boolean bulkPatientStatementExist(Date startDate,Date endDate){
        Boolean isPatientSt = false;
        
        try{
            
            Map<Id,ElixirSuite__Visits__c> careIdVsCareEp = new Map<Id,ElixirSuite__Visits__c>([Select Id,
                                                                                                CreatedDate,
                                                                                                ElixirSuite__Account__c,
                                                                                                ElixirSuite__Status__c 
                                                                                                FROM ElixirSuite__Visits__c 
                                                                                                WHERE ElixirSuite__Account__c !=null 
                                                                                                AND DAY_ONLY(CreatedDate) >=: startDate 
                                                                                                AND DAY_ONLY(CreatedDate) <=: endDate
                                                                                                WITH SECURITY_ENFORCED
                                                                                                ORDER by ElixirSuite__Account__c]);
            
            
            Map<Id,ElixirSuite__Procedure__c> procIdVsProc = new Map<Id,ElixirSuite__Procedure__c>([Select Id,
                                                                                                    Name,
                                                                                                    ElixirSuite__Type_of_Procedure__c,
                                                                                                    ElixirSuite__Charges__c,
                                                                                                    ElixirSuite__Account__c,
                                                                                                    ElixirSuite__Visits__c,
                                                                                                    ElixirSuite__From_Date_of_Service__c
                                                                                                    FROM ElixirSuite__Procedure__c 
                                                                                                    WHERE ElixirSuite__Visits__c IN : careIdVsCareEp.keyset()
                                                                                                    AND ElixirSuite__Type_of_Procedure__c!=null
                                                                                                    AND ElixirSuite__Charges__c>0
                                                                                                    WITH SECURITY_ENFORCED]);
            
            
            List<ElixirSuite__Procedure__c> procLst = [Select Id,
                                                       Name,
                                                       ElixirSuite__Type_of_Procedure__c,
                                                       ElixirSuite__Charges__c,
                                                       ElixirSuite__Visits__c,
                                                       ElixirSuite__Account__c,
                                                       ElixirSuite__From_Date_of_Service__c
                                                       FROM ElixirSuite__Procedure__c 
                                                       WHERE ElixirSuite__Visits__c = null
                                                       AND ElixirSuite__Account__c!=null
                                                       AND DAY_ONLY(ElixirSuite__From_Date_of_Service__c) >=: startDate 
                                                       AND DAY_ONLY(ElixirSuite__From_Date_of_Service__c) <=: endDate
                                                       AND ElixirSuite__Type_of_Procedure__c!=null
                                                       AND ElixirSuite__Charges__c>0
                                                       WITH SECURITY_ENFORCED
                                                       ORDER by ElixirSuite__Account__c];
            
            for(ElixirSuite__Procedure__c proc : procLst){
                procIdVsProc.put(proc.Id,proc);  
            }
            
            if(procIdVsProc.size()>0){
                isPatientSt = true;
            }
            
        }
        
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        
        return isPatientSt;
    }

    @AuraEnabled
    public static String checkProfile(){
        
        List<Profile> profileRec = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() WITH SECURITY_ENFORCED LIMIT 1 ];
        String myProflieName = profileRec[0].Name;
        return myProflieName;
        
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

    
    public string getstring(){
        return null;
    }
}