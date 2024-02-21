public with sharing class PaymentController {
    public static Map<String,Decimal> idAndRemainingAmt = new Map<String,Decimal>();
    public static Map<String,Decimal> idAndAssignedAmt = new Map<String,Decimal>();
    @AuraEnabled
    public static wrapperData getData(string accid){   
        wrapperData wrpr = new wrapperData();
        try{
            
            List<Payment_Transaction__c> pData = new List<Payment_Transaction__c>();
            //List<Payment_Schedule__c> lstpayShedule = new List<Payment_Schedule__c>();
            List<ElixirSuite__Payment_Plan__c> lstpaymentplan = new List<ElixirSuite__Payment_Plan__c>();
            List<Payment_Transaction__c> filteredPayTrans = new List<Payment_Transaction__c>();
            List<Payment_Information__c> pInfo = new List<Payment_Information__c>();
            List<Master_Transaction__c> mt = new List<Master_Transaction__c>();
            
            List<Payment_Transaction__c> pDataForInsurancePayment = new List<Payment_Transaction__c>();
            
            Account patData = new Account();
            wrpr.plugDataPresent = false;
            List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
            String virtualClassName;
            pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='NewPaymentIntegration' WITH SECURITY_ENFORCED];
            if(pluggableClass != null && !pluggableClass.isEmpty()){
                
                virtualClassName = pluggableClass[0].Virtual_Class__c;
                
            }
            if(virtualClassName != '' && virtualClassName !=null){
                wrpr.plugDataPresent = true;
            }
            
            Id payTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Payment_Transaction').getRecordTypeId();
            
            Id insuranceTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
            
            pData = [Select Id, 
                     Name,Date_Of_Service__c,
                     Account__c,
                     Procedure_Name__c,
                     Cpt_Codes__c,
                     Actual_Price__c,
                     Received_Amount__c,
                     Patient_Responsibility__c,Procedure__r.ElixirSuite__Is_Billable__c,
                     Insurance_Payments__c, 
                     Procedure__r.Claim__r.Name,
                     Payment_Adjustments__c, Total_Received_Amount__c,PatientOutstanding__c, Patient_Payments__c, Insurance_Responsibility__c, ERA_Arrived__c, Credit_Amount__c
                     from  Payment_Transaction__c 
                     where Account__c=:accid  
                     AND (Status__c = 'UnPaid' OR Status__c = 'Payment Started') AND ElixirSuite__PatientOutstanding__c > 0 AND Procedure__r.ElixirSuite__Is_Billable__c = true AND Procedure__c != null AND RecordTypeId =: payTxnRecordTypeId
                     WITH SECURITY_ENFORCED
                     order By Date_Of_Service__c ];
            
            pDataForInsurancePayment = [Select Id, 
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
                                        PatientOutstanding__c,
                                        Insurance_Paid__c,ElixirSuite__Secondary_Insurance_Paid__c,
                                        ElixirSuite__Total_Adjustment_Amount__c
                                        from  Payment_Transaction__c 
                                        where Account__c=:accid  
                                        AND (Status__c = 'UnPaid' OR Status__c = 'Payment Started')  
                                        AND Procedure__r.ElixirSuite__Is_Billable__c = true 
                                        AND Procedure__r.ElixirSuite__Type_of_Procedure__c='Insurance Payment' 
                                        AND Procedure__c != null AND RecordTypeId =: insuranceTxnRecordTypeId
                                        WITH SECURITY_ENFORCED
                                        order By Date_Of_Service__c desc];
            
            List<Payment_Transaction__c> pDataForInsurancePaymentfiltered = new  List<Payment_Transaction__c>(); //Anusha -start
            if(pDataForInsurancePayment != null && pDataForInsurancePayment.size()>0){
                for(Payment_Transaction__c eachrec : pDataForInsurancePayment){
                    if(eachrec.PatientOutstanding__c != null){
                        if(eachrec.PatientOutstanding__c>0){
                            pDataForInsurancePaymentfiltered.add(eachrec);
                        }
                    }
                    
                } //end
            }
            AggregateResult[] groupedResults =[Select SUM(ElixirSuite__Total_Remaining_Unallocated_Amount__c) from ElixirSuite__Master_Transaction__c WHERE ElixirSuite__Account__c=: accid AND ElixirSuite__Reason_Of_Payment__c='Unallocated Payment'/* AND ElixirSuite__Payment_Received_By__c='Insurance'*/ WITH SECURITY_ENFORCED]; //Replace 'Patient' with 'Insurance' by Anusha - 06/10/22
            
            if(pData != null && pData.size()>0){
                for(Payment_Transaction__c ptrans : pData){
                    if(!(ptrans.ERA_Arrived__c == true && ptrans.PatientOutstanding__c == 0)){
                        filteredPayTrans.add(ptrans);
                    }
                }
            }
            pInfo = [Select id,
                     CVV_Number__c,
                     Credit_Card_Number__c,
                     Expiration_Month__c,
                     Expiration_Year__c,
                     First_Name_on_Card__c,
                     Last_Name_on_Card__c, 
                     name,Account__c 
                     from  Payment_Information__c 
                     where Account__c=:accid WITH SECURITY_ENFORCED];
            patData = [Select id, 
                       name,
                       Patient_s_Birth_Date__c,
                       ElixirSuite__DOB__c, //added by Anusha LX3-5342
                       MRN_Number__c,MRN_Number_New__c ,
                       Unallocated_Amount__c 
                       from  Account 
                       where id=:accid WITH SECURITY_ENFORCED];    
            mt = [select id, 
                  Total_Amount_Paid__c,
                  Total_Unallocated_Amount__c,
                  Payment_Type__c 
                  from Master_Transaction__c 
                  where Account__c=:accid 
                  AND Payment_Type__c=:'Unallocated' WITH SECURITY_ENFORCED];
            
            /*lstpayShedule = [Select Id,Name,Status__c,
                             Installment_Amount__c,
                             Account__c,
                             Net_Balance__c,
                             Pay_Frequency__c,
                             Payment_Schedule__c ,Remaining_Amount__c,
                             ElixirSuite__Due_Date__c,ElixirSuite__Total_Balance_Due__c,
                             CreatedDate 
                             from Payment_Schedule__c 
                             WHERE Account__c =:accid And Payment_Schedule__c = null AND  ElixirSuite__Payment_Status__c ='Active' 
                             AND  ElixirSuite__Total_Balance_Due__c > 0 
                             WITH SECURITY_ENFORCED
                             ORDER BY CreatedDate DESC LIMIT 4000];
            System.debug('AAAA '+lstpayShedule);*/
            lstpaymentplan = [SELECT Id, Name, ElixirSuite__Patient_Name__c, ElixirSuite__Payment_Frequency__c, 
                              ElixirSuite__Patient_Responsibility__c, ElixirSuite__Installment_Amount__c, 
                              ElixirSuite__Status__c, ElixirSuite__Plan_Description__c, ElixirSuite__Total_Amount_Paid__c, 
                              ElixirSuite__Total_Balance_Due__c, ElixirSuite__Payment_Status__c 
                              FROM ElixirSuite__Payment_Plan__c
                              WHERE ElixirSuite__Patient_Name__c =:accid AND  ElixirSuite__Status__c ='Active' 
                              AND ElixirSuite__Total_Balance_Due__c > 0
                             WITH SECURITY_ENFORCED
                             ORDER BY CreatedDate ASC];
            if(filteredPayTrans != null && filteredPayTrans.size()>0){
                wrpr.procData=filteredPayTrans;
            }
            if(pInfo != null && pInfo.size()>0){
                wrpr.payInfo=pInfo;
            }
            if(patData != null ){
                wrpr.patientData=patData;
            }
            if(mt != null && mt.size()>0){
                wrpr.masTrans=mt;
            }
            if(lstpaymentplan != null && lstpaymentplan.size()>0){
                wrpr.lstPayPlan=lstpaymentplan;
            }
            if(pDataForInsurancePaymentfiltered != null && pDataForInsurancePaymentfiltered.size()>0){
                wrpr.procDataForInsurancePayment=pDataForInsurancePaymentfiltered;
            }
            if(String.valueOf(groupedResults[0].get('expr0'))!=null){
                wrpr.totalRemainingUnallocatedAmount = Decimal.valueOf(String.valueOf(groupedResults[0].get('expr0')));
            }else{
                wrpr.totalRemainingUnallocatedAmount = 0;
            }
            
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        return wrpr;
        
    }
    
    @AuraEnabled
    public static List<ElixirSuite__Payment_Plan_Line_Item__c> getPaymentLine(List<String> lstmasterId)
    {
        /*List<Payment_Schedule__c> lstschedules = new List<Payment_Schedule__c>(); 
        
        lstschedules = [Select Id,Name,Status__c,
                        Installment_Amount__c,
                        Account__c,
                        Net_Balance__c,
                        Pay_Frequency__c,
                        ElixirSuite__Balance_Due1__c,
                        Payment_Schedule__c ,Remaining_Amount__c,
                        ElixirSuite__Due_Date__c,
                        ElixirSuite__Payment_Status__c,
                        ElixirSuite__Total_payment_Made_formula__c,
                        CreatedDate 
                        from Payment_Schedule__c 
                        where  Payment_Schedule__c IN :lstmasterId And Payment_Schedule__c != null 
                        AND ElixirSuite__Balance_Due1__c>0
                        WITH SECURITY_ENFORCED
                        ORDER BY CreatedDate DESC LIMIT 4000];
        return lstschedules;*/
        List<ElixirSuite__Payment_Plan_Line_Item__c> lstpaymentline = new List<ElixirSuite__Payment_Plan_Line_Item__c>();
        lstpaymentline = [SELECT Id, Name, ElixirSuite__Due_Date__c, ElixirSuite__Installment_Amount__c, 
                          ElixirSuite__Last_Payment_Amount__c, ElixirSuite__Last_Payment_Date__c, 
                          ElixirSuite__Notes__c, ElixirSuite__Account__c, ElixirSuite__Payment_Plan__c, 
                          ElixirSuite__Payment_Status__c, ElixirSuite__Amount_Paid__c, 
                          ElixirSuite__Balance_Due__c 
                          FROM ElixirSuite__Payment_Plan_Line_Item__c
                          WHERE ElixirSuite__Payment_Plan__c IN :lstmasterId AND ElixirSuite__Payment_Plan__c != null
                          AND ElixirSuite__Balance_Due__c > 0
                          WITH SECURITY_ENFORCED
                          ORDER BY ElixirSuite__Due_Date__c ASC];
        return lstpaymentline;
    }
    
    @AuraEnabled
    public static List<ClaimWrapperData> getClaimsData(String accId)
    {
        List<ClaimWrapperData> wrprList = new List<ClaimWrapperData>();
        
        List<Payment_Transaction__c> pData = new List<Payment_Transaction__c>();
        pData = [Select Id, 
                 Name,Date_Of_Service__c,
                 Account__c,
                 Procedure_Name__c,
                 Cpt_Codes__c,
                 Actual_Price__c,
                 Received_Amount__c,
                 Patient_Responsibility__c,
                 Insurance_Paid__c, //Anusha 27/09/22
                 ElixirSuite__Secondary_Insurance_Paid__c,
                 ElixirSuite__Total_Paid_Amount__c, //Anusha 27/09/22
                 ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                 Insurance_Payments__c, Insurance_Responsibility__c,Procedure__r.ElixirSuite__Is_Billable__c,
                 ElixirSuite__Procedure__r.ElixirSuite__Status__c,
                 Procedure__r.Claim__c,
                 Procedure__r.Claim__r.Name, 
                 Procedure__r.Claim__r.Total_Allowed_Amount__c, 
                 Procedure__r.Claim__r.Total_Patient_Responsibility__c,
                 Procedure__r.Claim__r.Total_Amount_Paid_By_Insurance__c,
                 Procedure__r.Claim__r.Total_Adjustment_Amount__c,
                 Procedure__r.Claim__r.ElixirSuite__Payer_Order__c,
                 Procedure__r.ElixirSuite__Claim_Generation__c, //Anusha 30/09/2022
                 Payment_Adjustments__c, Total_Received_Amount__c,PatientOutstanding__c, Patient_Payments__c
                 from  Payment_Transaction__c 
                 where Account__c=:accid  
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
            ClaimWrapperData obj = new ClaimWrapperData();
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
                    totalBilledAmount+=ptObj.Actual_Price__c!=null?ptObj.Actual_Price__c:0; //Anusha 27/09/22 -Start
                    totalInsurancePaidAmount+=ptObj.Insurance_Paid__c!=null?ptObj.Insurance_Paid__c:0; //Anusha
                    totalSecondaryInsurancePaidAmount+= ptObj.ElixirSuite__Secondary_Insurance_Paid__c!=null?ptObj.ElixirSuite__Secondary_Insurance_Paid__c:0;
                    totalPatientResponsibility+=ptObj.Patient_Responsibility__c!=null?ptObj.Patient_Responsibility__c:0; //Anusha
                    totalPatientPaidAmount+=ptObj.ElixirSuite__Total_Actual_Patient_Paid_Amount__c!=null?ptObj.ElixirSuite__Total_Actual_Patient_Paid_Amount__c:0;//Anusha -end
                    //patientOutstanding+=(ptObj.Patient_Responsibility__c-ptObj.ElixirSuite__Total_Paid_Amount__c); //Anusha - 04/10/22
                    patientOutstanding+= ptObj.PatientOutstanding__c!=null?ptObj.PatientOutstanding__c:0;
                }
                obj.patientResp = patientOutstanding;
                //obj.InsuranceResp = insResp - (insPayment + payAdjusted);
                obj.InsuranceResp = insResp - insPayment;
                obj.totalBilledAmount=totalBilledAmount; //Anusha 27/09/22 -Start
                obj.totalInsurancePaidAmount=totalInsurancePaidAmount; //Anusha
                obj.totalPatientResponsibility=totalPatientResponsibility; //Anusha
                obj.totalPatientPaidAmount=totalPatientPaidAmount;//Anusha -end
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
        return wrprList;
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
    
    public class wrapperData{
        
        @AuraEnabled Public List<Payment_Transaction__c> procData; 
        @AuraEnabled Public List<Payment_Information__c> payInfo;
        @AuraEnabled Public List<Master_Transaction__c> masTrans;
        @AuraEnabled Public Account patientData; 
        @AuraEnabled Public Boolean plugDataPresent;
        //@AuraEnabled Public List<Payment_Schedule__c> lstPaySchedule; 
        @AuraEnabled Public List<ElixirSuite__Payment_Plan__c> lstPayPlan; 
        @AuraEnabled Public List<Payment_Transaction__c> procDataForInsurancePayment; 
        @AuraEnabled Public Decimal totalRemainingUnallocatedAmount;
    }
    public class ClaimWrapperData{
        
        @AuraEnabled public String claimName;
        @AuraEnabled public String claimId;
        @AuraEnabled public Integer openProc;
        @AuraEnabled public Decimal totalAllowed;
        @AuraEnabled public Decimal patientResp;
        @AuraEnabled public Decimal insuranceResp;
        @AuraEnabled public Decimal totalBilledAmount; //Anusha 27/09/22 -Start
        @AuraEnabled public Decimal totalInsurancePaidAmount; //Anusha
        @AuraEnabled public Decimal totalPatientResponsibility; //Anusha
        @AuraEnabled public Decimal totalPatientPaidAmount; //Anusha -end
        @AuraEnabled public Decimal totalSecondaryInsurancePaidAmount; //Anusha
        @AuraEnabled Public List<Payment_Transaction__c> procWrap; 
        
        public ClaimWrapperData()
        {
            claimName = '';
            claimId = '';
            openProc = 0;
            totalAllowed = 0.0;
            patientResp = 0.0;
            insuranceResp = 0.0;
            totalBilledAmount=0.0; //Anusha 27/09/22 -Start
            totalInsurancePaidAmount=0.0; //Anusha
            totalPatientResponsibility=0.0;//Anusha
            totalPatientPaidAmount=0.0;//Anusha -end
            procWrap = new List<Payment_Transaction__c>();
        }
    }
    /*   public static Payment_Transaction__c createSubPayment(String RecvdFrm, Date payDate, String subTxnRecordTypeId, Decimal amount,
String masterTransId, String payTransId, String accId){
Payment_Transaction__c newPaymentTxn = new Payment_Transaction__c();
newPaymentTxn.Payment_Date__c = payDate;
newPaymentTxn.Received_From__c = RecvdFrm;
newPaymentTxn.Received_Amount__c = amount;
newPaymentTxn.Payment_Sub_Transaction__c = payTransId;
newPaymentTxn.Master_Transaction__c = masterTransId;
newPaymentTxn.RecordTypeId = subTxnRecordTypeId;
newPaymentTxn.Account__c = accId; //By Sonal

return newPaymentTxn;
}
public static void updatePaymentTrans(Payment_Transaction__c paymentTra, Decimal amtLeftToAllocate){
paymentTra.Total_Received_Amount__c  = refactorAmount(paymentTra.Total_Received_Amount__c) + amtLeftToAllocate;
paymentTra.Patient_Payments__c = refactorAmount(paymentTra.Patient_Payments__c) + amtLeftToAllocate;
paymentTra.Credit_Amount__c = refactorAmount(paymentTra.Credit_Amount__c) + amtLeftToAllocate;
paymentTra.Status__c = 'Payment Started';
}*/
    
    @auraEnabled
    public static void makeAllocatePayment(Decimal amountPaid,String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                           Decimal totalRemainingUnAllocatedAmt)
    {
        
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='InsuranceAllocatePayment' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null){
            Callable paymentIntegration = (Callable) Type.forName(virtualClassName).newInstance();
            paymentIntegration.call('AllocateInsurancePayment', new Map<String, Object> {
                'amountPaid' => amountPaid,
                    'acctId' => acctId,
                    'selectedProcedureRecords' => selectedProcedureRecords,
                    'totalAppliedAmount' => totalAppliedAmount,
                    'totalRemainingUnAllocatedAmt' => totalRemainingUnAllocatedAmt
                    });
            
        }
        
        else{
            
            Decimal totalAssignedSum=0;
            
            
            if(amountPaid!=null){
                system.debug('444:'+totalAssignedSum);
                if(amountPaid >0){
                    totalAssignedSum = removeif2(amountPaid,acctId,selectedProcedureRecords,totalAppliedAmount);
                }
                else{
                    if(totalAppliedAmount > totalRemainingUnAllocatedAmt){
                          system.debug('450:'+totalAssignedSum);
                        paymentAllocationEngine2(totalRemainingUnAllocatedAmt,acctId,selectedProcedureRecords,
                                                 totalAppliedAmount,fetchProcedureMasterTransactionSorted(selectedProcedureRecords));
                        totalAssignedSum =totalRemainingUnAllocatedAmt;
                        
                    }else{
                        paymentAllocationEngine2(totalRemainingUnAllocatedAmt,acctId,selectedProcedureRecords,
                                                 totalAppliedAmount,fetchProcedureMasterTransactionUnSorted(selectedProcedureRecords) );
                        totalAssignedSum =0;
                        for(String objId: idAndRemainingAmt.keySet()){
                            totalAssignedSum += idAndRemainingAmt.get(objId);
                        }
                         system.debug('462:'+totalAssignedSum);
                    }
                }
            }
            else{
                if(totalAppliedAmount > totalRemainingUnAllocatedAmt){
                    paymentAllocationEngine2(totalRemainingUnAllocatedAmt,acctId,selectedProcedureRecords,
                                             totalAppliedAmount,fetchProcedureMasterTransactionSorted(selectedProcedureRecords));
                    totalAssignedSum =amountPaid;
                    system.debug('471:'+totalAssignedSum);
                }else{
                    paymentAllocationEngine2(totalRemainingUnAllocatedAmt,acctId,selectedProcedureRecords,
                                             totalAppliedAmount,fetchProcedureMasterTransactionUnSorted(selectedProcedureRecords) );
                    
                    totalAssignedSum =0;
                    for(String objId: idAndRemainingAmt.keySet()){
                        totalAssignedSum += idAndRemainingAmt.get(objId);
                    }
                    system.debug('480:'+totalAssignedSum);
                }
                
                
            }
            
            recalculateRemainingUnAllocatedAmount(acctId,totalAppliedAmount) ; 
        }
    }
    
    public static Decimal removeif2(Decimal amountPaid,String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount){
        Decimal totalAssignedSum=0;
        if(totalAppliedAmount > amountPaid){            
            paymentAllocationEngine2(amountPaid,acctId,selectedProcedureRecords,
                                     totalAppliedAmount,fetchProcedureMasterTransactionSorted(selectedProcedureRecords));
            totalAssignedSum =amountPaid;
            system.debug('496:'+totalAssignedSum);
            system.debug('4967:'+amountPaid);
        }
        else{
            //Initially fetch_Procedure_MasterTransaction_UnSorted
            paymentAllocationEngine2(amountPaid,acctId,selectedProcedureRecords,
                                     totalAppliedAmount,fetchProcedureMasterTransactionSorted(selectedProcedureRecords) );
            totalAssignedSum =0;
            for(String objId: idAndRemainingAmt.keySet()){
                totalAssignedSum += idAndRemainingAmt.get(objId);
            }
            system.debug('507:'+totalAssignedSum);
            system.debug('508:'+amountPaid);
        }
        return totalAssignedSum;
    }
   
    public static void recalculateRemainingUnAllocatedAmount(String acctId, Decimal amountAllocated) {
        // modified this method by jami,as Now fething the 'Patient Credit' records & nullify them first and then fetch the remaining records.
        // Lx3 - 11071
        ElixirSuite__Master_Transaction__c[] patientCreditLst = new List<ElixirSuite__Master_Transaction__c>();
        ElixirSuite__Master_Transaction__c[] patientCreditRecords = [SELECT ID, ElixirSuite__Total_Unallocated_Amount__c,
                                                                     ElixirSuite__Total_Remaining_Unallocated_Amount__c, ElixirSuite__Mode_of_Payment__c
                                                                     FROM ElixirSuite__Master_Transaction__c
                                                                     WHERE ElixirSuite__Account__c = :acctId
                                                                     AND ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment'
                                                                     AND ElixirSuite__Mode_of_Payment__c = 'Patient Credit'
                                                                     WITH SECURITY_ENFORCED order by createdDate ASC];
        for(ElixirSuite__Master_Transaction__c mt  : patientCreditRecords){
            if(mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c!=null && mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c > 0){
                patientCreditLst.add(mt);
            }
        }
        if(patientCreditLst.size()>0 && patientCreditLst!= null){
            processRecords(patientCreditRecords, amountAllocated);
        }else{
            
            ElixirSuite__Master_Transaction__c[] cashRecords = [SELECT ID, ElixirSuite__Total_Unallocated_Amount__c,
                                                                ElixirSuite__Total_Remaining_Unallocated_Amount__c, ElixirSuite__Mode_of_Payment__c
                                                                FROM ElixirSuite__Master_Transaction__c
                                                                WHERE ElixirSuite__Account__c = :acctId
                                                                AND ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment'
                                                                AND ElixirSuite__Mode_of_Payment__c != 'Patient Credit'
                                                                WITH SECURITY_ENFORCED order by createdDate ASC];
            
            processRecords(cashRecords, amountAllocated);
        }
    }
    public static void processRecords(ElixirSuite__Master_Transaction__c[] records, Decimal amountAllocated) {
        ElixirSuite__Master_Transaction__c[] lstToUpdt = new List<ElixirSuite__Master_Transaction__c>();
        for (ElixirSuite__Master_Transaction__c mt : records) {
            if (mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c != null && mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c > 0) {
                if (amountAllocated >= mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c) {
                    amountAllocated = amountAllocated - mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c;
                    mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c = 0;
                    lstToUpdt.add(mt);
                } else {
                    mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c = mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c - amountAllocated;
                    amountAllocated = 0;
                    lstToUpdt.add(mt);
                    break;
                }
            }
        }
        DMLManager.updateAsUser(lstToUpdt);
    }
    public static void paymentAllocationEngine2(Decimal amountPaid,
                                                String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,ElixirSuite__Payment_Transaction__c[] masterTranRecLst)
    {
        
        ElixirSuite__Transactions__c [] allTransactionForMT = new List<ElixirSuite__Transactions__c>();
        ElixirSuite__Payment_Transaction__c[] masterTransUpdate = new List<ElixirSuite__Payment_Transaction__c>();
        Set<Id> masterTransactionIdSet = new Set<Id>();
        
        for(ElixirSuite__Payment_Transaction__c sObj : masterTranRecLst){
            if(amountPaid>0){                
                if(idAndRemainingAmt.containsKey(sObj.Id)){ 
                    Decimal remainingAmt = idAndRemainingAmt.get(sObj.Id);
                    allTransactionForMT = removeif3(remainingAmt,amountPaid,sObj);
                }                
                masterTransUpdate.add(sObj);
                masterTransactionIdSet.add(sObj.Id);
            }
        }
        
        Set<String> setOfTransactionId = new Set<String>();
        //insert allTransactionForMT;
        if(allTransactionForMT!=null && allTransactionForMT.size() >0){
            
            Database.SaveResult[] srList = Database.insert(allTransactionForMT, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    setOfTransactionId.add(sr.getId());
                }
            }
            if(setOfTransactionId.size() >0){
                
                updateMasterTransaction(masterTransUpdate,idAndRemainingAmt);
            }
        }
    }
    
    public static ElixirSuite__Transactions__c[] removeif3(Decimal remainingAmt,Decimal amountPaid,ElixirSuite__Payment_Transaction__c sObj){
        ElixirSuite__Transactions__c [] allTransaction = new List<ElixirSuite__Transactions__c>();
        if(remainingAmt >0){
            if(amountPaid>remainingAmt){     // 900>991    
                system.debug('601:'+amountPaid);
            system.debug('602:'+remainingAmt);
                ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = remainingAmt,
                                                                                               ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                               ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                               // ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                               ElixirSuite__Payment_Received_By__c='Patient',
                                                                                               ElixirSuite__Type_of_Payment__c = 'Payment');
                
                
                idAndAssignedAmt.put(sObj.Id, remainingAmt);
                amountPaid = amountPaid - remainingAmt;
                allTransaction.add(transactionRec);
                
            }
            else {                                                   
                ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = amountPaid,
                                                                                               ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                               ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                               //  ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                               ElixirSuite__Payment_Received_By__c='Patient',
                                                                                               ElixirSuite__Type_of_Payment__c = 'Payment');
                
                idAndAssignedAmt.put(sObj.Id, amountPaid);
                amountPaid = 0;
                allTransaction.add(transactionRec);
                
                
            }
            system.debug('631:'+amountPaid);
            system.debug('632:'+remainingAmt);
        }
        return allTransaction;
    }
    public static void updateMasterTransaction(List<ElixirSuite__Payment_Transaction__c> masterTransUpdate, Map<String,Decimal> idAndRemainingAmt){
        
        List<ElixirSuite__Payment_Transaction__c> listOfMasterRecords= [Select id,name,PatientOutstanding__c,ElixirSuite__Patient_Responsibility__c,
                                                                        (Select ElixirSuite__Amount_Paid__c,ElixirSuite__Payment_Received_By__c from ElixirSuite__Transactions__r) from ElixirSuite__Payment_Transaction__c where Id IN: idAndRemainingAmt.keySet() WITH SECURITY_ENFORCED];
        
        
        // List<ElixirSuite__Payment_Transaction__c> masterTransUpdate= [Select id,name,ElixirSuite__Patient_Responsibility__c(Select ElixirSuite__Amount_Paid__c from ElixirSuite__Transactions__r) from ElixirSuite__Payment_Transaction__c where Id IN: setOfMasterId];
        
        Decimal totalAmt;
        if(listOfMasterRecords.size() >0){
            for(ElixirSuite__Payment_Transaction__c paymentTran: listOfMasterRecords){
                totalAmt =0;
                if(paymentTran.ElixirSuite__Transactions__r.size() >0){
                    for(ElixirSuite__Transactions__c child: paymentTran.ElixirSuite__Transactions__r){
                        if(child.ElixirSuite__Payment_Received_By__c == 'Patient'){
                            totalAmt+=child.ElixirSuite__Amount_Paid__c;
                        }
                        
                    }
                }
                
            }
            DMLManager.updateAsUser(listOfMasterRecords);
            /*if(Schema.sObjectType.ElixirSuite__Payment_Transaction__c.isUpdateable()){
update listOfMasterRecords;
}*/
        }
        
    }
    
    @AuraEnabled
    public static Object makeInsurancePayment(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String reasonForPayment,String note,String pmtTransactionNumber,
                                              String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                              Decimal totalUnAllocatedAmount,Boolean noProcedureSelected, string paymentInfoId, string chequeNo)
    {
        Object Obj;
        String otherTransationRecordId;
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='InsuranceRegisterPayment' WITH SECURITY_ENFORCED];
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
                    'chequeNo' => chequeNo
                    });
            return Obj;
        }
        
        else{
            MessageWrapper wrap = new MessageWrapper();
            
            if(noProcedureSelected){
                ElixirSuite__Master_Transaction__c otherPaymentForNoProceduresObj = new ElixirSuite__Master_Transaction__c(
                    ElixirSuite__Total_Unallocated_Amount__c = amountPaid,ElixirSuite__Account__c = acctId,
                    ElixirSuite__Total_Remaining_Unallocated_Amount__c = amountPaid,
                    ElixirSuite__Total_Amount_Paid__c = amountPaid,
                    // add total unallocated to total remoaning allocated too
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
                /*if(Schema.sObjectType.ElixirSuite__Master_Transaction__c.isCreateable()){         
insert otherPaymentForNoProceduresObj;
}*/
                otherTransationRecordId = otherPaymentForNoProceduresObj.Id;
                
            }else{
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
                    system.debug('amountPaid1'+amountPaid);
                    if(totalAppliedAmount > amountPaid){ // this will not be valid anymore as totalappliedamount will never be greater           
                        paymentAllocationEngine(amountPaid,modeOfPayment,dateOfPmt,pmtTransactionNumber,acctId,selectedProcedureRecords,
                                                totalAppliedAmount,totalUnAllocatedAmount,fetchProcedureMasterTransactionSorted(selectedProcedureRecords),
                                                otherTransaction, paymentInfoId,chequeNo);
                    }
                    else{
                        paymentAllocationEngine(amountPaid,modeOfPayment,dateOfPmt,pmtTransactionNumber,acctId,selectedProcedureRecords,
                                                totalAppliedAmount,totalUnAllocatedAmount,fetchProcedureMasterTransactionSorted(selectedProcedureRecords),
                                                otherTransaction, paymentInfoId,chequeNo);
                    }
                }            
            }
            wrap.msgStr = otherTransationRecordId;
            wrap.msgState = 'Success';
            return wrap;
        }
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
                 system.debug('amountPaid2'+amountPaid);
                if(idAndRemainingAmt.containsKey(sObj.Id)){                       
                    Decimal remainingAmt = idAndRemainingAmt.get(sObj.Id);
                    allTransactionForMT = removeif4(remainingAmt,amountPaid,sObj,otherTransaction,paymentInfoId,chequeNo, modeOfPayment);
                }                
                masterTransUpdate.add(sObj);
                masterTransactionIdSet.add(sObj.Id);
            }
        }
        if(totalUnAllocatedAmount>0){ // after payment if any money left
            ElixirSuite__Master_Transaction__c unAllocatedAmtObj = new ElixirSuite__Master_Transaction__c(
                ElixirSuite__Total_Unallocated_Amount__c = totalUnAllocatedAmount,ElixirSuite__Account__c = acctId,
                ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment',
                ElixirSuite__Total_Remaining_Unallocated_Amount__c = totalUnAllocatedAmount,
                ElixirSuite__Mode_of_Payment__c = modeOfPayment);
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
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    setOfTransactionId.add(sr.getId());
                }
            }
            if(setOfTransactionId.size() >0){
                updateMasterTransaction(masterTransUpdate,idAndRemainingAmt);
            }
        }
    }
    public static ElixirSuite__Transactions__c[] removeif4(Decimal remainingAmt, Decimal amountPaid,ElixirSuite__Payment_Transaction__c sObj, ElixirSuite__Master_Transaction__c otherTransaction, string paymentInfoId, string chequeNo,String modeOfPayment){
        ElixirSuite__Transactions__c [] allTransactionForMT = new List<ElixirSuite__Transactions__c>();
         system.debug('amountPaid3'+amountPaid);
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
         system.debug('amountPaid4'+amountPaid);
        return allTransactionForMT;
    }
    public static ElixirSuite__Payment_Transaction__c[] fetchProcedureMasterTransactionUnSorted(String selectedProcedureRecords){
        return  [SELECT ID,PatientOutstanding__c,ElixirSuite__Patient_Responsibility__c,ElixirSuite__Expected_Receivable_amount__c,ElixirSuite__Other_Discounts__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c FROM ElixirSuite__Payment_Transaction__c WHERE 
                 ID IN : collectProcedureMasterTransactionIds(selectedProcedureRecords) with security_enforced];
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
    
    
    @AuraEnabled
    public static ElixirSuite__ERA_Generation__c getERASetting(){
        return ElixirSuite__ERA_Generation__c.getInstance();
    }
    //Anusha LX3-5820
    @AuraEnabled
    public static String getDisplaySetting(){
        return ClaimTypeSelectionApex.fetchDisplaySettings();
    }
    public class MessageWrapper
    {
        @AuraEnabled
        public String msgState;
        @AuraEnabled
        public String msgStr;
    }
}