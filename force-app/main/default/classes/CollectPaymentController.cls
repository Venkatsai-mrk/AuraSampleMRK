public with sharing class CollectPaymentController {
    public static Map<String,Decimal> idAndRemainingAmt = new Map<String,Decimal>();
    public static Map<String,Decimal> idAndAssignedAmt = new Map<String,Decimal>();
	@AuraEnabled
    public static wrapperData fetchdetails(string accountId){
        wrapperData wrpr = new wrapperData();
        try{
            List<Payment_Information__c> pInfo = new List<Payment_Information__c>();
            List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
            Map<String, String> ModeOfPayment = MasterProblemListController.fetchPickListValue('ElixirSuite__Master_Transaction__c','ElixirSuite__Mode_of_Payment__c');
            pInfo = [Select id, CVV_Number__c,Credit_Card_Number__c,Expiration_Month__c, Expiration_Year__c,First_Name_on_Card__c,Last_Name_on_Card__c,name,Account__c 
                     from  Payment_Information__c 
                     where Account__c=:accountId WITH SECURITY_ENFORCED];
            if(acc!= null && acc.size() > 0 ){
                wrpr.patientData = acc[0];
            }
             if(pInfo != null && pInfo.size()>0){
                wrpr.payInfo=pInfo;
            }
            if(ModeOfPayment != null && ModeOfPayment.size()>0){
                wrpr.mapOfModeOfPayment=ModeOfPayment;
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    
     @AuraEnabled
    public static List<ElixirSuite__Master_Transaction__c> fetchCreditData(string accountId){
        List<ElixirSuite__Master_Transaction__c> otherTransRec = [SELECT Id, Name, RecordTypeId, ElixirSuite__Account__c, ElixirSuite__Allocated_Amount__c, 
                                                                  ElixirSuite__Cheque_Number__c, ElixirSuite__Complete_discount_to_be_utilized__c, 
                                                                  ElixirSuite__Discount_Amount__c, ElixirSuite__Discount_Code__c, 
                                                                  ElixirSuite__Maximum_Discount__c, ElixirSuite__Mode_of_Payment__c, ElixirSuite__Payment_By__c, 
                                                                  ElixirSuite__Notes__c, ElixirSuite__Payment_Due__c, ElixirSuite__Payment_Information__c, 
                                                                  ElixirSuite__Payment_Notes__c, ElixirSuite__Payment_Received_By__c, 
                                                                  ElixirSuite__Payment_Transaction_Number__c, ElixirSuite__Payment_Type__c, 
                                                                  ElixirSuite__Reference_Number__c, ElixirSuite__Reason_Of_Payment__c, 
                                                                  ElixirSuite__Total_Amount_Paid__c, ElixirSuite__Total_Remaining_Unallocated_Amount__c, 
                                                                  ElixirSuite__Total_Unallocated_Amount__c, ElixirSuite__Transaction_Date__c, 
                                                                  ElixirSuite__Type_of_Allocation__c, ElixirSuite__User__c 
                                                                  FROM ElixirSuite__Master_Transaction__c
                                                                  WHERE ElixirSuite__Account__c= :accountId 
                                                                  AND ElixirSuite__Total_Remaining_Unallocated_Amount__c > 0
                                                                  AND ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment'                                                                  WITH SECURITY_ENFORCED
                                                                  ORDER BY ElixirSuite__Transaction_Date__c ASC];
        return otherTransRec;
    }
    
    @AuraEnabled
    public static wrapperData getdata(string accountId){
        wrapperData wrpr = new wrapperData();
        try{
             Id insuranceTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
             Id privateTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
             List<Payment_Transaction__c> masterTranscationRec = new List<Payment_Transaction__c>();
             masterTranscationRec = [Select Id, 
                                        Name,Date_Of_Service__c,
                                        Account__c,
                                        Procedure_Name__c,
                                        Procedure__r.Name,
                                        Procedure__r.ElixirSuite__Claim_Generation__c,
                                        Procedure__r.ElixirSuite__Claim__r.Name,
                                        Procedure__r.ElixirSuite__Status__c,
                                        Actual_Price__c,
                                        ElixirSuite__Cpt_Codes__c,
                                        Patient_Responsibility__c, 
                                        ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                                        PatientOutstanding__c,ElixirSuite__Other_Discount__c,ElixirSuite__Expected_Receivable_amount__c,
                                        Insurance_Paid__c,ElixirSuite__Secondary_Insurance_Paid__c,
                                        RecordTypeId,
                                        ElixirSuite__Total_Adjustment_Amount__c
                                        from  Payment_Transaction__c 
                                        where Account__c=:accountId  
                                        AND (Status__c = 'UnPaid' OR Status__c = 'Payment Started')  
                                        AND Procedure__r.ElixirSuite__Is_Billable__c = true 
                                        AND PatientOutstanding__c > 0
                                        WITH SECURITY_ENFORCED
                                        order By Date_Of_Service__c desc];
            
            List<claimWrapperData> wrprList = new List<claimWrapperData>();
        
            List<Payment_Transaction__c> pData = new List<Payment_Transaction__c>();
            pData = [Select Id, 
                     Name,Date_Of_Service__c,
                     Account__c,
                     Procedure_Name__c,
                     Cpt_Codes__c,
                     Actual_Price__c,
                     Received_Amount__c,
                     Patient_Responsibility__c,
                     Insurance_Paid__c, 
                     ElixirSuite__Secondary_Insurance_Paid__c,
                     ElixirSuite__Total_Paid_Amount__c, 
                     ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                     Insurance_Payments__c, Insurance_Responsibility__c,Procedure__r.ElixirSuite__Is_Billable__c,
                     Procedure__r.ElixirSuite__Status__c,
                     Procedure__r.Claim__c,
                     Procedure__r.Claim__r.Name, 
                     Procedure__r.Claim__r.Total_Allowed_Amount__c, 
                     Procedure__r.Claim__r.Total_Patient_Responsibility__c,
                     Procedure__r.Claim__r.Total_Amount_Paid_By_Insurance__c,
                     Procedure__r.Claim__r.Total_Adjustment_Amount__c,
                     Procedure__r.Claim__r.ElixirSuite__Payer_Order__c,
                     Procedure__r.ElixirSuite__Claim_Generation__c, 
                     Payment_Adjustments__c, Total_Received_Amount__c,PatientOutstanding__c, Patient_Payments__c
                     from  Payment_Transaction__c 
                     where Account__c=:accountId  
                     AND (Status__c = 'UnPaid' OR Status__c = 'Payment Started') AND Procedure__r.ElixirSuite__Claim_Generation__c=true  AND Procedure__r.ElixirSuite__Is_Billable__c = true AND Procedure__c != null
                     AND PatientOutstanding__c>0
                     WITH SECURITY_ENFORCED
                     order By Procedure__r.Claim__c asc, Date_Of_Service__c Desc, Procedure_Name__c asc];
            Map<String,List<Payment_Transaction__c>> claimOpenProcedures = new Map<String,List<Payment_Transaction__c>>();
            Map<String,List<Payment_Transaction__c>> noClaimOpenProcedures = new Map<String,List<Payment_Transaction__c>>();
             
            for(Payment_Transaction__c pt : pData){
                if(pt.Procedure__r.Claim__c != null)
                {
                    if(pt.PatientOutstanding__c>0 ){
                        claimOpenProcedures = removeif(claimOpenProcedures,pt);
                        
                    }
                }
                else
                {
                    if(noClaimOpenProcedures.containsKey(''))
                    {
                        List<Payment_Transaction__c> tempPt = noClaimOpenProcedures.get('');
                        tempPt.add(pt);
                        noClaimOpenProcedures.put('', tempPt);
                    }
                    else
                    {
                        List<Payment_Transaction__c> tempPt = new List<Payment_Transaction__c>();
                        tempPt.add(pt);
                        noClaimOpenProcedures.put('', tempPt);
                    }
                }
            }
            
            //To add procedures with no claims at the end of the map
            for(String key : noClaimOpenProcedures.keySet())
            {
                claimOpenProcedures.put(key,noClaimOpenProcedures.get(key));
            }
            
            Set<String> claimNamesSetToSort=claimOpenProcedures.KeySet();
            List<String> claimNamesListToSort=new List<String>(claimNamesSetToSort);
            List<String> sortedClaimNamesList=new List<String>();
            for(Integer i = claimNamesListToSort.size()-1; i>=0;i--)
            {
                sortedClaimNamesList.add(claimNamesListToSort.get(i));
            }
            for(String key : sortedClaimNamesList)
            {
                claimWrapperData obj = new claimWrapperData();
                if(key != '')
                {
                    obj.claimName = key;
                    obj.claimId = claimOpenProcedures.get(key)[0].Procedure__r.Claim__c;
                    if(claimOpenProcedures.get(key)[0].Procedure__r.Claim__r.Total_Allowed_Amount__c != null){
                        obj.totalAllowed = claimOpenProcedures.get(key)[0].Procedure__r.Claim__r.Total_Allowed_Amount__c;
                    }else{
                        obj.totalAllowed = 0;
                    }
                    Decimal patientOutstanding = 0;
                    Decimal insPayment = 0;
                    Decimal insResp = 0;
                    Decimal payAdjusted = 0;
                    Decimal totalBilledAmount=0; //Anusha 27/09/22 - start
                    Decimal totalInsurancePaidAmount=0;
                    Decimal totalPatientResponsibility=0;
                    Decimal totalPatientPaidAmount=0;//Anusha -end
                    Decimal totalSecondaryInsurancePaidAmount = 0;
                    for(Payment_Transaction__c ptObj : claimOpenProcedures.get(key))
                    {
                        if(ptObj.Insurance_Payments__c != null)
                        {
                            insPayment += ptObj.Insurance_Payments__c;
                        }
                        if(ptObj.Insurance_Responsibility__c != null)
                        {
                            insResp += ptObj.Insurance_Responsibility__c;
                        }
                        if(ptObj.Payment_Adjustments__c != null)
                        {
                            payAdjusted += ptObj.Payment_Adjustments__c;
                        }
                        totalBilledAmount+=ptObj.Actual_Price__c!=null?ptObj.Actual_Price__c:0; 
                        totalInsurancePaidAmount+=ptObj.Insurance_Paid__c!=null?ptObj.Insurance_Paid__c:0;
                        totalSecondaryInsurancePaidAmount+= ptObj.ElixirSuite__Secondary_Insurance_Paid__c!=null?ptObj.ElixirSuite__Secondary_Insurance_Paid__c:0;
                        totalPatientResponsibility+=ptObj.Patient_Responsibility__c!=null?ptObj.Patient_Responsibility__c:0;
                        totalPatientPaidAmount+=ptObj.ElixirSuite__Total_Actual_Patient_Paid_Amount__c!=null?ptObj.ElixirSuite__Total_Actual_Patient_Paid_Amount__c:0;//Anusha -end

                        patientOutstanding+= ptObj.PatientOutstanding__c!=null?ptObj.PatientOutstanding__c:0;
                    }
                    obj.patientResp = patientOutstanding;
                    obj.InsuranceResp = insResp - insPayment;
                    obj.totalBilledAmount=totalBilledAmount; 
                    obj.totalInsurancePaidAmount=totalInsurancePaidAmount;
                    obj.totalPatientResponsibility=totalPatientResponsibility; 
                    obj.totalPatientPaidAmount=totalPatientPaidAmount;
                    obj.totalSecondaryInsurancePaidAmount = totalSecondaryInsurancePaidAmount;
                }
                else
                {
                    obj.claimName = '-';
                    obj.claimId = '';
                }
                obj.openProc = claimOpenProcedures.get(key).size();
                obj.procWrap = claimOpenProcedures.get(key);
                
                wrprList.add(obj);
            }
            if(masterTranscationRec != null && masterTranscationRec.size()>0){
                wrpr.procData=masterTranscationRec;
            }
            if(insuranceTxnRecordTypeId != null ){
                wrpr.insuranceId=insuranceTxnRecordTypeId;
            }
            if(insuranceTxnRecordTypeId != null){
                wrpr.privateId=privateTxnRecordTypeId;
            }
            if(wrprList != null && wrprList.size()>0 != null){
                wrpr.claimData=wrprList;
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    
    
    @AuraEnabled
    public static wrapperData filterProcedurebasedOnDOS(string accountId,Date dosFrom,Date dosTo){
        wrapperData wrpr = new wrapperData();
        try{
             Id insuranceTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
             Id privateTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
             List<Payment_Transaction__c> masterTranscationRec = new List<Payment_Transaction__c>();
             masterTranscationRec = [Select Id, 
                                        Name,Date_Of_Service__c,
                                        Account__c,
                                        Procedure_Name__c,
                                        Procedure__r.Name,
                                        Procedure__r.ElixirSuite__Claim_Generation__c,
                                        Procedure__r.ElixirSuite__Claim__r.Name,
                                        Procedure__r.ElixirSuite__Status__c,
                                        Actual_Price__c,
                                        ElixirSuite__Cpt_Codes__c,
                                        Patient_Responsibility__c, 
                                        ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                                        PatientOutstanding__c,ElixirSuite__Other_Discount__c,ElixirSuite__Expected_Receivable_amount__c,
                                        Insurance_Paid__c,ElixirSuite__Secondary_Insurance_Paid__c,
                                        RecordTypeId,
                                        ElixirSuite__Total_Adjustment_Amount__c
                                        from  Payment_Transaction__c 
                                        where Account__c=:accountId  
                                        AND (Status__c = 'UnPaid' OR Status__c = 'Payment Started')  
                                        AND Procedure__r.ElixirSuite__Is_Billable__c = true 
                                        AND ElixirSuite__Date_Of_Service__c>= :dosFrom AND ElixirSuite__Date_Of_Service__c<= :dosTo
                                        AND PatientOutstanding__c > 0
                                        WITH SECURITY_ENFORCED
                                        order By Date_Of_Service__c desc];
            List<claimWrapperData> wrprList = new List<claimWrapperData>();
        
            List<Payment_Transaction__c> pData = new List<Payment_Transaction__c>();
            pData = [Select Id, 
                     Name,Date_Of_Service__c,
                     Account__c,
                     Procedure_Name__c,
                     Cpt_Codes__c,
                     Actual_Price__c,
                     Received_Amount__c,
                     Patient_Responsibility__c,
                     Insurance_Paid__c, 
                     ElixirSuite__Secondary_Insurance_Paid__c,
                     ElixirSuite__Total_Paid_Amount__c, 
                     ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                     Insurance_Payments__c, Insurance_Responsibility__c,Procedure__r.ElixirSuite__Is_Billable__c,
                     Procedure__r.Claim__c,
                     Procedure__r.Claim__r.Name, 
                     Procedure__r.Claim__r.Total_Allowed_Amount__c, 
                     Procedure__r.Claim__r.Total_Patient_Responsibility__c,
                     Procedure__r.Claim__r.Total_Amount_Paid_By_Insurance__c,
                     Procedure__r.Claim__r.Total_Adjustment_Amount__c,
                     Procedure__r.Claim__r.ElixirSuite__Payer_Order__c,
                     Procedure__r.ElixirSuite__Claim_Generation__c, 
                     Procedure__r.ElixirSuite__Status__c,
                     Payment_Adjustments__c, Total_Received_Amount__c,PatientOutstanding__c, Patient_Payments__c
                     from  Payment_Transaction__c 
                     where Account__c=:accountId  
                     AND (Status__c = 'UnPaid' OR Status__c = 'Payment Started') AND Procedure__r.ElixirSuite__Claim_Generation__c=true  AND Procedure__r.ElixirSuite__Is_Billable__c = true AND Procedure__c != null
                     AND PatientOutstanding__c>0
                     AND ElixirSuite__Date_Of_Service__c>= :dosFrom AND ElixirSuite__Date_Of_Service__c<= :dosTo
                     WITH SECURITY_ENFORCED
                     order By Procedure__r.Claim__c asc, Date_Of_Service__c Desc, Procedure_Name__c asc];
            Map<String,List<Payment_Transaction__c>> claimOpenProcedures = new Map<String,List<Payment_Transaction__c>>();
            Map<String,List<Payment_Transaction__c>> noClaimOpenProcedures = new Map<String,List<Payment_Transaction__c>>();
            for(Payment_Transaction__c pt : pData){
                if(pt.Procedure__r.Claim__c != null)
                {
                    if(pt.PatientOutstanding__c>0 ){
                        
                        claimOpenProcedures = removeif(claimOpenProcedures,pt);
                        
                    }
                }
                else
                {
                    if(noClaimOpenProcedures.containsKey(''))
                    {
                        List<Payment_Transaction__c> tempPt = noClaimOpenProcedures.get('');
                        tempPt.add(pt);
                        noClaimOpenProcedures.put('', tempPt);
                    }
                    else
                    {
                        List<Payment_Transaction__c> tempPt = new List<Payment_Transaction__c>();
                        tempPt.add(pt);
                        noClaimOpenProcedures.put('', tempPt);
                    }
                }
            }
            
            //To add procedures with no claims at the end of the map
            for(String key : noClaimOpenProcedures.keySet())
            {
                claimOpenProcedures.put(key,noClaimOpenProcedures.get(key));
            }
            
            //Sort claimOpenProcedures Map based on Name - Added by Anusha
            Set<String> claimNamesSetToSort=claimOpenProcedures.KeySet();
            List<String> claimNamesListToSort=new List<String>(claimNamesSetToSort);
            List<String> sortedClaimNamesList=new List<String>();
            for(Integer i = claimNamesListToSort.size()-1; i>=0;i--)
            {
                sortedClaimNamesList.add(claimNamesListToSort.get(i));
            }//end - Anusha
            
            for(String key : sortedClaimNamesList) //Replaced 'claimOpenProcedures.KeySet()' with 'sortedClaimNamesList' by Anusha
            {
                claimWrapperData obj = new claimWrapperData();
                if(key != '')
                {
                    obj.claimName = key;
                    obj.claimId = claimOpenProcedures.get(key)[0].Procedure__r.Claim__c;
                    if(claimOpenProcedures.get(key)[0].Procedure__r.Claim__r.Total_Allowed_Amount__c != null){
                        obj.totalAllowed = claimOpenProcedures.get(key)[0].Procedure__r.Claim__r.Total_Allowed_Amount__c;
                    }else{
                        obj.totalAllowed = 0;
                    }
                    Decimal patientOutstanding = 0;
                    Decimal insPayment = 0;
                    Decimal insResp = 0;
                    Decimal payAdjusted = 0;
                    Decimal totalBilledAmount=0; //Anusha 27/09/22 - start
                    Decimal totalInsurancePaidAmount=0;
                    Decimal totalPatientResponsibility=0;
                    Decimal totalPatientPaidAmount=0;//Anusha -end
                    Decimal totalSecondaryInsurancePaidAmount = 0;
                    for(Payment_Transaction__c ptObj : claimOpenProcedures.get(key))
                    {
                        if(ptObj.Insurance_Payments__c != null)
                        {
                            insPayment += ptObj.Insurance_Payments__c;
                        }
                        if(ptObj.Insurance_Responsibility__c != null)
                        {
                            insResp += ptObj.Insurance_Responsibility__c;
                        }
                        if(ptObj.Payment_Adjustments__c != null)
                        {
                            payAdjusted += ptObj.Payment_Adjustments__c;
                        }
                        totalBilledAmount+=ptObj.Actual_Price__c!=null?ptObj.Actual_Price__c:0; 
                        totalInsurancePaidAmount+=ptObj.Insurance_Paid__c!=null?ptObj.Insurance_Paid__c:0;
                        totalSecondaryInsurancePaidAmount+= ptObj.ElixirSuite__Secondary_Insurance_Paid__c!=null?ptObj.ElixirSuite__Secondary_Insurance_Paid__c:0;
                        totalPatientResponsibility+=ptObj.Patient_Responsibility__c!=null?ptObj.Patient_Responsibility__c:0;
                        totalPatientPaidAmount+=ptObj.ElixirSuite__Total_Actual_Patient_Paid_Amount__c!=null?ptObj.ElixirSuite__Total_Actual_Patient_Paid_Amount__c:0;//Anusha -end

                        patientOutstanding+= ptObj.PatientOutstanding__c!=null?ptObj.PatientOutstanding__c:0;
                    }
                    obj.patientResp = patientOutstanding;
                    obj.InsuranceResp = insResp - insPayment;
                    obj.totalBilledAmount=totalBilledAmount; 
                    obj.totalInsurancePaidAmount=totalInsurancePaidAmount;
                    obj.totalPatientResponsibility=totalPatientResponsibility; 
                    obj.totalPatientPaidAmount=totalPatientPaidAmount;
                    obj.totalSecondaryInsurancePaidAmount = totalSecondaryInsurancePaidAmount;
                }
                else
                {
                    obj.claimName = '-';
                    obj.claimId = '';
                }
                obj.openProc = claimOpenProcedures.get(key).size();
                obj.procWrap = claimOpenProcedures.get(key);
                
                wrprList.add(obj);
            }
            if(masterTranscationRec != null && masterTranscationRec.size()>0){
                wrpr.procData=masterTranscationRec;
            }
            if(insuranceTxnRecordTypeId != null ){
                wrpr.insuranceId=insuranceTxnRecordTypeId;
            }
            if(insuranceTxnRecordTypeId != null){
                wrpr.privateId=privateTxnRecordTypeId;
            }
            if(wrprList != null && wrprList.size()>0 != null){
                wrpr.claimData=wrprList;
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    
     public static Map<String,List<Payment_Transaction__c>> removeif(Map<String,List<Payment_Transaction__c>> claimOpenProcedures,Payment_Transaction__c pt){
        if(claimOpenProcedures.containsKey(pt.Procedure__r.Claim__r.Name))
        {
            List<Payment_Transaction__c> tempPt = claimOpenProcedures.get(pt.Procedure__r.Claim__r.Name);
            tempPt.add(pt);
            claimOpenProcedures.put(pt.Procedure__r.Claim__r.Name, tempPt);
        }
        else
        {
            List<Payment_Transaction__c> tempPt = new List<Payment_Transaction__c>();
            tempPt.add(pt);
            claimOpenProcedures.put(pt.Procedure__r.Claim__r.Name, tempPt);
        }
        return claimOpenProcedures;
    }

    @AuraEnabled
    public static String addDiscount(String acctId,String selectedProcedureRecords)
    {
        Map<String, Object> objDataLst =(Map<String, Object>) JSON.deserializeUntyped(selectedProcedureRecords);
        List<Object> apexDataLst = (List<Object>) objDataLst.get('procedures');
        List<ElixirSuite__Transactions__c> transLst = new List<ElixirSuite__Transactions__c>();
        ElixirSuite__Master_Transaction__c otherTransaction = new ElixirSuite__Master_Transaction__c();
        String res;
        Decimal totalDisc= 0;
        
        for(Object obj : apexDataLst){
            Map<String,Object> mpData = ( Map<String,Object>) obj;
            System.debug('discountAmt***'+Integer.valueof(mpData.get('otherDiscount')));
            System.debug('masterTransId***'+String.valueof(mpData.get('Id')));
            Decimal discAmt;
            if(String.valueof(mpData.get('discountType')) == 'Amount'){
                discAmt = Decimal.valueof(String.valueof(mpData.get('otherDiscount')));
            }
            else if(String.valueof(mpData.get('discountType')) == 'Percentage'){
                Decimal patOut = Decimal.valueof(String.valueof(mpData.get('ElixirSuite__PatientOutstanding__c')));
                System.debug('patOut***'+patOut);
                discAmt = (Decimal.valueof(String.valueof(mpData.get('otherDiscount'))) / 100 ) * patOut;
            }
            System.debug('discAmt***'+discAmt);
            totalDisc = totalDisc + discAmt;
            ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = discAmt,
                                                                                           ElixirSuite__Master_Transaction__c = String.valueof(mpData.get('Id')),
                                                                                           ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                           ElixirSuite__Type_of_Payment__c = 'Discount',
                                                                                           ElixirSuite__Payment_Received_By__c = 'Patient');
            
            transLst.add(transactionRec);
            
        }
        otherTransaction.ElixirSuite__Transaction_Date__c = system.today();
        otherTransaction.ElixirSuite__Account__c = acctId;
        otherTransaction.ElixirSuite__Total_Amount_Paid__c  = totalDisc;
        DMLManager.insertAsUser(otherTransaction);
        for(ElixirSuite__Transactions__c transactionRec : transLst){
            transactionRec.ElixirSuite__Other_Transactions__c = otherTransaction.Id;
        }
        DMLManager.insertAsUser(transLst);
        res = 'completed';
        return res;
    }
    
    @AuraEnabled
    public static Object makePayment(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String reasonForPayment,String note,String pmtTransactionNumber,
                                              String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,Decimal totalCreditAmount,
                                              Decimal totalUnAllocatedAmount,Boolean noProcedureSelected, string paymentInfoId, string chequeNo,
                                             List<ElixirSuite__Master_Transaction__c> creditMemo)
    {
        Object Obj;
        String otherTransationRecordId;
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='NewPaymentIntegration'  WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null && modeOfPayment == 'Credit Card'){
            Callable paymentIntegration = (Callable) Type.forName(virtualClassName).newInstance();
            Obj = paymentIntegration.call('InsurancePayment', new Map<String, Object> {
                'amountPaid' => amountPaid,
                    'modeOfPayment' => modeOfPayment,
                    'dateOfPmt' => dateOfPmt,
                    'reasonForPayment' => reasonForPayment,
                    'note' => note,
                    'pmtTransactionNumber' => pmtTransactionNumber,
                    'acctId' => acctId,
                    'selectedProcedureRecords' => selectedProcedureRecords,
                    'totalAppliedAmount' => totalAppliedAmount,
                    'totalUnAllocatedAmount' => totalUnAllocatedAmount,
                    'noProcedureSelected' => noProcedureSelected,
                    'paymentInfoId' => paymentInfoId,
                    'chequeNo' => chequeNo,
                    'creditMemo' => creditMemo
                    });
            return Obj;
        }
        
        else{
            MessageWrapper wrap = new MessageWrapper();
            wrap.msgState = 'Success';
            if(noProcedureSelected){
                ElixirSuite__Master_Transaction__c otherPaymentForNoProceduresObj = new ElixirSuite__Master_Transaction__c(
                    ElixirSuite__Total_Unallocated_Amount__c = amountPaid,ElixirSuite__Account__c = acctId,
                    ElixirSuite__Total_Remaining_Unallocated_Amount__c = amountPaid,
                    ElixirSuite__Total_Amount_Paid__c = amountPaid, 
                    ElixirSuite__Reference_Number__c = pmtTransactionNumber,
                    ElixirSuite__Payment_Transaction_Number__c = pmtTransactionNumber,
                    ElixirSuite__Transaction_Date__c = dateOfPmt, ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                    ElixirSuite__Reason_Of_Payment__c = reasonForPayment, 
                    
                    ElixirSuite__Payment_Notes__c = note,
                    ElixirSuite__Payment_Received_By__c='Patient'); //Anusha Added condition check
                if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                    otherPaymentForNoProceduresObj.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                }
                if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                    otherPaymentForNoProceduresObj.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                }
                DMLManager.insertAsUser(otherPaymentForNoProceduresObj);

                otherTransationRecordId = otherPaymentForNoProceduresObj.Id;
                
            }else{
                if(creditMemo != null){
                    paymentAllocationEngine2(totalCreditAmount,acctId,selectedProcedureRecords,creditMemo,
                                     totalAppliedAmount,fetchProcedureMasterTransactionSorted(selectedProcedureRecords) );
                }
                if(reasonForPayment == 'Applied Payment' && modeOfPayment != null ){
                    ElixirSuite__Master_Transaction__c otherTransaction = new ElixirSuite__Master_Transaction__c(
                    ElixirSuite__Total_Amount_Paid__c = amountPaid,ElixirSuite__Account__c = acctId,
                    ElixirSuite__Payment_Transaction_Number__c = pmtTransactionNumber,
                    ElixirSuite__Transaction_Date__c = dateOfPmt, ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                    ElixirSuite__Reason_Of_Payment__c = reasonForPayment,
                    ElixirSuite__Payment_Notes__c = note,
                    ElixirSuite__Payment_Received_By__c='Patient'); //Anusha Added condition check      
                    if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                        otherTransaction.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                    }
                    if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                        otherTransaction.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                    } 
                    //insert otherTransaction;
                    DMLManager.insertAsUser(otherTransaction);
                    
                    otherTransationRecordId = otherTransaction.Id;
                    
                    
                    if(reasonForPayment == 'Applied Payment'){      
                            paymentAllocationEngine(amountPaid,modeOfPayment,dateOfPmt,pmtTransactionNumber,acctId,selectedProcedureRecords,
                                                    totalAppliedAmount,totalUnAllocatedAmount,fetchProcedureMasterTransactionSorted(selectedProcedureRecords),
                                                    otherTransaction, paymentInfoId,chequeNo);
                    }            
                }
                
            }
            wrap.msgStr = otherTransationRecordId;
            return wrap;
        }
    }
    	public static void paymentAllocationEngine2(Decimal amountPaid,String acctId,String selectedProcedureRecords,
                                                    List<ElixirSuite__Master_Transaction__c> creditMemo, Decimal totalAppliedAmount,ElixirSuite__Payment_Transaction__c[] masterTranRecLst)
        {
            
            ElixirSuite__Transactions__c [] allTransactionForMT = new List<ElixirSuite__Transactions__c>();
            Set<Id> masterTransactionIdSet = new Set<Id>();
            Decimal totalProcedureAmt = 0;
            for(ElixirSuite__Payment_Transaction__c sObj : masterTranRecLst){
                if(amountPaid>0){                
                    if(idAndRemainingAmt.containsKey(sObj.Id)){ 
                        Decimal remainingAmt = idAndRemainingAmt.get(sObj.Id);
                         if(remainingAmt >0){
                            if(amountPaid>remainingAmt){     
                                ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = remainingAmt,
                                                                                                               ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                               ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                               // ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                                               ElixirSuite__Payment_Received_By__c='Patient',
                                                                                                               ElixirSuite__Type_of_Payment__c = 'Payment');
                                
                                
                                //idAndAssignedAmt.put(sObj.Id, remainingAmt);
                                totalProcedureAmt += remainingAmt;
                                amountPaid = amountPaid - remainingAmt;
                                allTransactionForMT.add(transactionRec);
                                
                            }
                            else {                                                   
                                ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = amountPaid,
                                                                                                               ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                               ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                               //  ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                                               ElixirSuite__Payment_Received_By__c='Patient',
                                                                                                               ElixirSuite__Type_of_Payment__c = 'Payment');
                                
                                //idAndAssignedAmt.put(sObj.Id, amountPaid);
                                totalProcedureAmt += amountPaid;
                                amountPaid = 0;
                                allTransactionForMT.add(transactionRec);
                                
                                
                            }
                        }
                    }                
                    masterTransactionIdSet.add(sObj.Id);
                }
            }
            //insert allTransactionForMT;
            if(allTransactionForMT!=null && allTransactionForMT.size() >0){
                 DMLManager.insertAsUser(allTransactionForMT);
            }
            processRecords(creditMemo,totalProcedureAmt); 
        }
    
    	
        public static void processRecords(ElixirSuite__Master_Transaction__c[] records, Decimal amountAllocated) {
            ElixirSuite__Master_Transaction__c[] lstToUpdt = new List<ElixirSuite__Master_Transaction__c>();
            for (ElixirSuite__Master_Transaction__c mt : records) {
                if (mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c != null && mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c > 0) {
                    if (amountAllocated >= mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c) {
                        amountAllocated = amountAllocated - mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c;
                        mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c = 0;
                        mt.ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment';
                        lstToUpdt.add(mt);
                    } else {
                        mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c = mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c - amountAllocated;
                        mt.ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment';
                        amountAllocated = 0;
                        lstToUpdt.add(mt);
                        break;
                    }
                }
            }
            DMLManager.updateAsUser(lstToUpdt);
        }
    
    	public static void paymentAllocationEngine(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                               String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                               Decimal totalUnAllocatedAmount,ElixirSuite__Payment_Transaction__c[] masterTranRecLst,
                                               ElixirSuite__Master_Transaction__c otherTransaction, string paymentInfoId, string chequeNo)
        {
            ElixirSuite__Transactions__c [] allTransactionForMT = new List<ElixirSuite__Transactions__c>();
            ElixirSuite__Payment_Transaction__c[] masterTransUpdate = new List<ElixirSuite__Payment_Transaction__c>();
            Set<Id> masterTransactionIdSet = new Set<Id>();
            for(ElixirSuite__Payment_Transaction__c sObj : masterTranRecLst){
                if(amountPaid>0){                
                    if(idAndRemainingAmt.containsKey(sObj.Id)){                       
                        Decimal remainingAmt = idAndRemainingAmt.get(sObj.Id);                        
                        if(amountPaid>remainingAmt && remainingAmt >0){     // 991>900                                            
                            ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = remainingAmt,
                                                                                                           ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                           ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                           ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                                                                                                           ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                                           ElixirSuite__Payment_Received_By__c='Patient',
                                                                                                           ElixirSuite__Type_of_Payment__c = 'Payment');
                            if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                                transactionRec.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                            }
                            if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                                transactionRec.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                            } 
                            
                            idAndAssignedAmt.put(sObj.Id, remainingAmt);
                            amountPaid = amountPaid - remainingAmt;
                            allTransactionForMT.add(transactionRec);
                            
                        }
                        else if(remainingAmt >0) {                                                   
                            ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = amountPaid,
                                                                                                           ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                           ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                           ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                                                                                                           ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                                           ElixirSuite__Payment_Received_By__c='Patient',
                                                                                                           ElixirSuite__Type_of_Payment__c = 'Payment');
                            if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                                transactionRec.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                            }
                            if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                                transactionRec.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                            } 
                            idAndAssignedAmt.put(sObj.Id, amountPaid);
                            amountPaid = 0;
                            allTransactionForMT.add(transactionRec);
                            
                            
                        }
                    }                
                    masterTransUpdate.add(sObj);
                    masterTransactionIdSet.add(sObj.Id);
                }
            }
            if(totalUnAllocatedAmount>0){ // after payment if any money left
                ElixirSuite__Master_Transaction__c unAllocatedAmtObj = new ElixirSuite__Master_Transaction__c(
                    ElixirSuite__Total_Unallocated_Amount__c = totalUnAllocatedAmount,ElixirSuite__Account__c = acctId,
                    ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment',
                    ElixirSuite__Payment_Transaction_Number__c = pmtTransactionNumber,
                    ElixirSuite__Total_Remaining_Unallocated_Amount__c = totalUnAllocatedAmount,
                    ElixirSuite__Mode_of_Payment__c = modeOfPayment,ElixirSuite__Reference_Number__c = pmtTransactionNumber,
                    ElixirSuite__Payment_Received_By__c='Patient',
                ElixirSuite__Transaction_Date__c = dateOfPmt);
                if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                    unAllocatedAmtObj.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                }
                if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                    unAllocatedAmtObj.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                } 
                //insert unAllocatedAmtObj;
                DMLManager.insertAsUser(unAllocatedAmtObj);
            }
            
            Set<String> setOfTransactionId = new Set<String>();
            if(allTransactionForMT!=null && allTransactionForMT.size() >0){
                
                Database.SaveResult[] srList = Database.insert(allTransactionForMT, false);
                /*for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        setOfTransactionId.add(sr.getId());
                    }
                }*/
            }
        }
    
    
    public static ElixirSuite__Payment_Transaction__c[] fetchProcedureMasterTransactionSorted(String selectedProcedureRecords){
        return  [SELECT ID,PatientOutstanding__c,ElixirSuite__Patient_Responsibility__c,ElixirSuite__Expected_Receivable_amount__c,ElixirSuite__Other_Discounts__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c FROM ElixirSuite__Payment_Transaction__c WHERE 
                 ID IN : collectProcedureMasterTransactionIds(selectedProcedureRecords) with security_enforced order By Date_Of_Service__c asc];
    }
    public static Set<Id> collectProcedureMasterTransactionIds(String selectedProcedureRecords){
        Set<Id> recordIds = new Set<Id>();
        for(Object obj : ElixirOEM_AddEraHelper.utilityMapDeserialize(selectedProcedureRecords,'procedures')){
            Map<String, Object> mapOfSelectedProcedures = (Map<String, Object>) obj;
            recordIds.add(String.valueOf(mapOfSelectedProcedures.get('Id')));
            idAndRemainingAmt.put(String.valueOf(mapOfSelectedProcedures.get('Id')),Decimal.valueOf(String.valueOf(mapOfSelectedProcedures.get('ElixirSuite__PatientOutstanding__c')))
                                 );            
            
        }
        return recordIds;
    }
    
    
    
    public class wrapperData{
        
        @AuraEnabled Public List<Payment_Transaction__c> procData; 
        @AuraEnabled Public List<Payment_Information__c> payInfo;
        @AuraEnabled Public Account patientData; 
        @AuraEnabled Public Id insuranceId;
        @AuraEnabled Public Id privateId; 
        @AuraEnabled public Map<String, String> mapOfModeOfPayment;
        @AuraEnabled Public List<claimWrapperData> claimData; 
    }
    
    public class claimWrapperData{
        
        @AuraEnabled public String claimName;
        @AuraEnabled public String claimId;
        @AuraEnabled public Integer openProc;
        @AuraEnabled public Decimal totalAllowed;
        @AuraEnabled public Decimal patientResp;
        @AuraEnabled public Decimal insuranceResp;
        @AuraEnabled public Decimal totalBilledAmount; 
        @AuraEnabled public Decimal totalInsurancePaidAmount; 
        @AuraEnabled public Decimal totalPatientResponsibility;
        @AuraEnabled public Decimal totalPatientPaidAmount; 
        @AuraEnabled public Decimal totalSecondaryInsurancePaidAmount;
        @AuraEnabled Public List<Payment_Transaction__c> procWrap; 
        
        public claimWrapperData()
        {
            claimName = '';
            claimId = '';
            openProc = 0;
            totalAllowed = 0.0;
            patientResp = 0.0;
            insuranceResp = 0.0;
            totalBilledAmount=0.0; 
            totalInsurancePaidAmount=0.0; 
            totalPatientResponsibility=0.0;
            totalPatientPaidAmount=0.0;
            procWrap = new List<Payment_Transaction__c>();
        }
    }
    public class MessageWrapper
    {
        @AuraEnabled
        public String msgState;
        @AuraEnabled
        public String msgStr;
    }
}