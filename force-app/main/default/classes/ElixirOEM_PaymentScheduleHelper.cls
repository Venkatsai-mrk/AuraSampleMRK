public with sharing class ElixirOEM_PaymentScheduleHelper {
    public static Map<String,Decimal> idAndRemainingAmt = new Map<String,Decimal>();
    @AuraEnabled 
    public static ElixirOEM_AllocatePaymentHelper.wrapperData initPayloadCallData(String acctId){
        return ElixirOEM_AllocatePaymentHelper.initPayloadCall(acctId);
    }
    @AuraEnabled 
    public static wrapperData paymentSchedulePayload(String acctId){
        wrapperData obj = new wrapperData();
        obj.paymntData = PaymentController.getData(acctId);
        return obj;
    }
    public class wrapperData{       
        @AuraEnabled Public  PaymentController.wrapperData paymntData;
    }
    @AuraEnabled 
    public static ElixirOEM_PrivatePaymentHelper.wrapperData queryAllProceduresOnMasterTransaction(String acctId){
        return  ElixirOEM_PrivatePaymentHelper.queryAllProceduresOnMasterTransaction(acctId);
    }
    @AuraEnabled
    public static List<ElixirSuite__Payment_Plan_Line_Item__c> getPaymentLines(List<String> lst_masterId)
    {
        return PaymentController.getPaymentLine(lst_masterId);
    }
    @AuraEnabled 
    public static  ElixirOEM_PrivatePaymentHelper.wrapperData filterProcedureOnMasterTransaction(Date dosFrom,Date dosTo,String procedureName,String CPTCode,String acctId,
                                                                                                 List<String> eisitngIdArr)
    {
        return ElixirOEM_PrivatePaymentHelper.filterProcedureOnMasterTransaction(dosFrom,dosTo,procedureName,CPTCode,
                                                                                 acctId,eisitngIdArr);
    }
    @AuraEnabled     
    public static  Object allocatePaymentInSystem(Decimal amountPaid,Decimal amountPaidCopy , String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                                String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                Decimal totalUnAllocatedAmount,Boolean noProcedureSelected,Decimal totalUnallocatedAmt,
                                                String selectedParentScheduleId, string paymentInfoId, string chequeNo,List<ElixirSuite__Payment_Plan_Line_Item__c> selectedpaymentplanline)
    {
        Object Obj;
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='PrivatePaymentSchedule' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null && modeOfPayment == 'Credit Card'){
            Callable paymentIntegration = (Callable) Type.forName(virtualClassName).newInstance();
            Obj = paymentIntegration.call('SchedulePrivatePayment', new Map<String, Object> {
                'amountPaid' => amountPaid,
                    'amountPaidCopy' => amountPaidCopy,
                    'modeOfPayment' => modeOfPayment,
                    'dateOfPmt' => dateOfPmt,
                    'pmtTransactionNumber' => pmtTransactionNumber,
                    'acctId' => acctId,
                    'selectedProcedureRecords' => selectedProcedureRecords,
                    'totalAppliedAmount' => totalAppliedAmount,
                    'totalUnAllocatedAmount' => totalUnAllocatedAmount,
                    'noProcedureSelected' => noProcedureSelected,
                    'totalUnallocatedAmt' => totalUnallocatedAmt,
                    'selectedParentScheduleId' => selectedParentScheduleId,
                    'paymentInfoId' => paymentInfoId,
                    'chequeNo' => chequeNo,
                    'selectedpaymentplanline' => selectedpaymentplanline
                    });
            return Obj;
        }
        else{
        MessageWrapper wrap = new MessageWrapper();
            ElixirSuite__Payment_Transaction_Line_Item__c[] toInsertLineLst  = new List<ElixirSuite__Payment_Transaction_Line_Item__c>();
            for(ElixirSuite__Payment_Plan_Line_Item__c ps : selectedpaymentplanline){  
                ElixirSuite__Payment_Transaction_Line_Item__c ptl = new ElixirSuite__Payment_Transaction_Line_Item__c();
                ptl.ElixirSuite__Payment_Plan_Line_Item__c = ps.Id;
                ptl.ElixirSuite__Payment_Date__c = dateOfPmt;
                ptl.ElixirSuite__Account__c = acctId;
                ptl.ElixirSuite__Payment_Amount__c = ps.ElixirSuite__Balance_Due__c; 
                ptl.ElixirSuite__Payment_Reference_Number__c = pmtTransactionNumber;
                ptl.ElixirSuite__Payment_Type__c = modeOfPayment;
                toInsertLineLst.add(ptl);  
            }
            if(toInsertLineLst!=null && toInsertLineLst.size() >0){
                DMLManager.insertAsUser(toInsertLineLst);
            }
            ElixirSuite__Master_Transaction__c[] otherTransaction  = new List<ElixirSuite__Master_Transaction__c>();
            for(ElixirSuite__Payment_Transaction_Line_Item__c payTransLine : toInsertLineLst){  
                ElixirSuite__Master_Transaction__c otherTrans = new ElixirSuite__Master_Transaction__c();
                otherTrans.ElixirSuite__Total_Unallocated_Amount__c = payTransLine.ElixirSuite__Payment_Amount__c;
                otherTrans.ElixirSuite__Account__c = acctId;
                otherTrans.ElixirSuite__Total_Amount_Paid__c = payTransLine.ElixirSuite__Payment_Amount__c; 
                otherTrans.ElixirSuite__Total_Remaining_Unallocated_Amount__c = payTransLine.ElixirSuite__Payment_Amount__c;
                otherTrans.ElixirSuite__Payment_Transaction_Number__c = pmtTransactionNumber;
                otherTrans.ElixirSuite__Transaction_Date__c = dateOfPmt;
                otherTrans.ElixirSuite__Mode_of_Payment__c = modeOfPayment;
                otherTrans.ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment';
                otherTrans.ElixirSuite__Payment_Received_By__c='Patient';
                otherTrans.ElixirSuite__Payment_Transaction_Line_Item__c = payTransLine.Id;
                if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                    otherTrans.ElixirSuite__Payment_Information__c = paymentInfoId;         
                }
                if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                    otherTrans.ElixirSuite__Cheque_Number__c = chequeNo;          
                }
                otherTransaction.add(otherTrans);  
            }
            if(otherTransaction!=null && otherTransaction.size() >0){
                DMLManager.insertAsUser(otherTransaction);
            }
            if(noProcedureSelected){
                wrap.msgState = 'Success';
        		return wrap;
            }
            else{
                ElixirSuite__Master_Transaction__c otherTransactionprocedure = new ElixirSuite__Master_Transaction__c(
                    ElixirSuite__Total_Amount_Paid__c = totalAppliedAmount,ElixirSuite__Account__c = acctId,
                    ElixirSuite__Payment_Transaction_Number__c = pmtTransactionNumber,
                    ElixirSuite__Transaction_Date__c = dateOfPmt, ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                    ElixirSuite__Reason_Of_Payment__c = 'Applied Payment',
                    ElixirSuite__Payment_Received_By__c='Patient');  
                if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                    otherTransactionprocedure.ElixirSuite__Payment_Information__c = paymentInfoId;    
                }
                if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                    otherTransactionprocedure.ElixirSuite__Cheque_Number__c = chequeNo;
                }
                DMLManager.insertAsUser(otherTransactionprocedure); 
                paymentAllocationEngine(amountPaid,modeOfPayment,dateOfPmt,pmtTransactionNumber,acctId,selectedProcedureRecords,
                                            totalAppliedAmount,totalUnAllocatedAmount,fetch_Procedure_MasterTransaction_Sorted(selectedProcedureRecords),
                                            otherTransactionprocedure, paymentInfoId, chequeNo,otherTransaction);
            }
        wrap.msgState = 'Success';
        return wrap;
    }
    }
    public static void paymentAllocationEngine(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                               String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                               Decimal totalUnAllocatedAmount,ElixirSuite__Payment_Transaction__c[] masterTranRecLst,
                                               ElixirSuite__Master_Transaction__c otherTransactionprocedure, string paymentInfoId, string chequeNo,
                                              ElixirSuite__Master_Transaction__c[] otherTransaction)
    {
        decimal amount = totalAppliedAmount;
        ElixirSuite__Transactions__c [] allTransactionForMT = new List<ElixirSuite__Transactions__c>();
        ElixirSuite__Master_Transaction__c [] othertransUpadte = new List<ElixirSuite__Master_Transaction__c>();
        for(ElixirSuite__Payment_Transaction__c sObj : masterTranRecLst){
            if(totalAppliedAmount>0){                
                if(idAndRemainingAmt.containsKey(sObj.Id)){                       
                    Decimal remainingAmt = idAndRemainingAmt.get(sObj.Id);
                    if(totalAppliedAmount>remainingAmt){     // 900>991                                               
                        ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = remainingAmt,
                                                                                                       ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                       ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                       ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                                                                                                       ElixirSuite__Other_Transactions__c = otherTransactionprocedure.Id,
                                                                                                       ElixirSuite__Payment_Received_By__c = 'Patient',
                                                                                                       ElixirSuite__Type_of_Payment__c = 'Payment');
                        if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                            transactionRec.ElixirSuite__Payment_Information__c = paymentInfoId;             
                        }
                        if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                            transactionRec.ElixirSuite__Cheque_Number__c = chequeNo;     
                        } 
                        totalAppliedAmount = totalAppliedAmount - remainingAmt;
                        allTransactionForMT.add(transactionRec);
                    }
                    else {                                                   
                        ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = totalAppliedAmount,
                                                                                                       ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                       ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                       ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                                                                                                       ElixirSuite__Other_Transactions__c = otherTransactionprocedure.Id,
                                                                                                       ElixirSuite__Payment_Received_By__c = 'Patient',
                                                                                                       ElixirSuite__Type_of_Payment__c = 'Payment');
                        if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                            transactionRec.ElixirSuite__Payment_Information__c = paymentInfoId;                 
                        }
                        if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                            transactionRec.ElixirSuite__Cheque_Number__c = chequeNo;          
                        } 
                        
                        totalAppliedAmount = 0;
                        allTransactionForMT.add(transactionRec);
                        break;
                    }                        
                }                
            }
        }
        
        for (ElixirSuite__Master_Transaction__c mt : otherTransaction) {
            if (mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c != null && mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c > 0) {
                if (amount > mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c) {
                    amount = amount - mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c;
                    mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c = 0;
                    othertransUpadte.add(mt);
                } else {
                    mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c = mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c - amount;
                    amount = 0;
                    othertransUpadte.add(mt);
                    break;
                }
            }
        }
        if(allTransactionForMT!=null && allTransactionForMT.size() >0){
            DMLManager.insertAsUser(allTransactionForMT); 
        }
        if(othertransUpadte!=null && othertransUpadte.size() >0){
            DMLManager.updateAsUser(othertransUpadte); 
        }
    }
    public static ElixirSuite__Payment_Transaction__c[] fetch_Procedure_MasterTransaction_Sorted(String selectedProcedureRecords){
        return  [SELECT ID,ElixirSuite__Expected_Receivable_amount__c,ElixirSuite__Other_Discounts__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__PatientOutstanding__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c FROM ElixirSuite__Payment_Transaction__c WHERE 
                 ID IN : collect_Procedure_MasterTransaction_Ids(selectedProcedureRecords) with security_enforced order By Date_Of_Service__c asc ];
    }
    public static Set<Id> collect_Procedure_MasterTransaction_Ids(String selectedProcedureRecords){
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
    public static  ElixirOEM_PrivatePaymentHelper.wrapperData filterAllProcedureOnMasterTransaction(Date dosFrom,Date dosTo,String procedureName,String CPTCode,String acctId,
                                                                                                 List<String> eisitngIdArr)
    {
        return ElixirOEM_PrivatePaymentHelper.filterAllProcedureOnMasterTransaction(dosFrom,dosTo,procedureName,CPTCode,
                                                                                 acctId,eisitngIdArr);
    }
public class MessageWrapper
    {
        @AuraEnabled
        public String msgState;
        @AuraEnabled
        public String msgStr;
    }
}