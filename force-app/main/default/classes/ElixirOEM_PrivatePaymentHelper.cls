/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-17-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ElixirOEM_PrivatePaymentHelper {
    public static Map<String,Decimal> idAndRemainingAmt = new Map<String,Decimal>();
    @AuraEnabled 
    public static PaymentController.wrapperData getData(string accid){  
        PaymentController.wrapperData wrpr = PaymentController.getData(accid);
        return wrpr;
    }
    
    public class wrapperData{       
        @AuraEnabled Public List<ElixirSuite__Payment_Transaction__c> allProcedureOnMT; 
        @AuraEnabled Public String queryString; 
        @AuraEnabled public ElixirSuite__ERA_Generation__c[] customSettingData;
        @AuraEnabled public Map<String, String> mapOfModeOfPayment;
    }
    @AuraEnabled 
    public static wrapperData queryAllProceduresOnMasterTransaction(String acctId){
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
        String additionFieldsPrefix = ' WHERE ElixirSuite__Procedure__r.ElixirSuite__Is_Billable__c = true '+  ' AND ' + ' ElixirSuite__PatientOutstanding__c >0 AND ElixirSuite__PatientOutstanding__c !=null AND ElixirSuite__Account__c = : acctId AND RecordtypeId = : devRecordTypeId';
        String otherFieldsAddition = ' ,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Status__c '; 
        String procedureQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Payment_Transaction__c',otherFieldsAddition,additionFieldsPrefix+' order by ElixirSuite__Date_Of_Service__c desc ');
        // ElixirOEM_TimelineHelper.mDebugUntruncated(clmQuery);
        wrapperData wrpData = new wrapperData();
        wrpData.allProcedureOnMT = new List<ElixirSuite__Payment_Transaction__c>();
        wrpData.allProcedureOnMT = Database.query(procedureQuery);
        wrpData.customSettingData = customSettingData();
        wrpData.mapOfModeOfPayment = MasterProblemListController.fetchPickListValue('ElixirSuite__Master_Transaction__c','ElixirSuite__Mode_of_Payment__c'); 
        return wrpData;
    }
    public static  ElixirSuite__ERA_Generation__c[] customSettingData(){
        return  [SELECT ID,ElixirSuite__Other_Discounts__c,ElixirSuite__Expected_Receivable_Amount__c FROM ElixirSuite__ERA_Generation__c with security_enforced];
        
    }
    @AuraEnabled 
    public static  ElixirSuite__Payment_Transaction__c[] procedureList(String searchKeyWord,String acctId){
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
        String searchKey = '%' + searchKeyWord + '%';               
        ElixirSuite__Payment_Transaction__c[] recordLst = [SELECT ID,Name,ElixirSuite__Procedure__c,ElixirSuite__Procedure__r.Name,
                                                           ElixirSuite__Procedure__r.Id FROM ElixirSuite__Payment_Transaction__c where 
                                                           ElixirSuite__Procedure__r.Name 
                                                           LIKE: searchKey AND ElixirSuite__Account__c = : acctId 
                                                           AND  ElixirSuite__Procedure__r.ElixirSuite__Is_Billable__c = true
                                                           AND ElixirSuite__PatientOutstanding__c !=0 AND ElixirSuite__PatientOutstanding__c !=null AND RecordtypeId = : devRecordTypeId
                                                           with security_enforced
                                                          ];
        return recordLst;
    }
    @AuraEnabled 
    public static  wrapperData filterProcedureOnMasterTransaction(Date dosFrom,Date dosTo,String procedureName,String CPTCode,String acctId,
                                                                  List<String> eisitngIdArr)
    {
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
        List<String> queries = new List<String>();
        String otherFieldsAddition = ' ,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Status__c '; 
        String additionFieldsPrefix = ' WHERE ElixirSuite__Procedure__r.ElixirSuite__Is_Billable__c = true '+  ' AND ' + ' ElixirSuite__PatientOutstanding__c >0 AND ElixirSuite__PatientOutstanding__c !=null AND ElixirSuite__Account__c = : acctId  AND RecordtypeId = : devRecordTypeId';
        String prefixClaimName = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Payment_Transaction__c',otherFieldsAddition,additionFieldsPrefix+'');       
        if(String.isNotBlank(procedureName)){
            queries.add('ElixirSuite__Procedure__r.Name= :procedureName');
        }
        if(String.isNotBlank(CPTCode)){
            queries.add('ElixirSuite__Cpt_Codes__c= :CPTCode');
        }
        if(String.isNotBlank(String.valueOf(dosFrom)) && String.isNotBlank(String.valueOf(dosTo))){
            //  dosTo = dosTo + 1;
            queries.add('ElixirSuite__Date_Of_Service__c>= :dosFrom AND ElixirSuite__Date_Of_Service__c<= :dosTo');
        } 
        if(eisitngIdArr!=null){
            queries.add(' ID NOT IN :eisitngIdArr');
        }                                                      
        String clause = prefixClaimName;
        if(queries!=null && queries.size()>0){
            clause = clause + ' AND ' +STring.escapeSingleQuotes(String.join(queries,' AND '))  + ' order by ElixirSuite__Date_Of_Service__c desc';
        }
        ElixirOEM_TimelineHelper.mDebugUntruncated(clause);
        wrapperData wrpData = new wrapperData();
        wrpData.allProcedureOnMT = new List<ElixirSuite__Payment_Transaction__c>();
        wrpData.allProcedureOnMT = Database.query(clause);
        wrpData.queryString = clause;
        return wrpData;   
    }
    @AuraEnabled     
    public static  Object makePrivatePayment(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                             String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                             Decimal totalUnAllocatedAmount,Boolean noProcedureSelected, string paymentInfoId, string chequeNo)
    {
        Object Obj;
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='PrivateRegisterPayment' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null && modeOfPayment == 'Credit Card'){
            Callable paymentIntegration = (Callable) Type.forName(virtualClassName).newInstance();
            Obj = paymentIntegration.call('PrivatePayment', new Map<String, Object> {
                'amountPaid' => amountPaid,
                    'modeOfPayment' => modeOfPayment,
                    'dateOfPmt' => dateOfPmt,
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
                    ElixirSuite__Total_Amount_Paid__c = amountPaid, //Added 'ElixirSuite__Total_Amount_Paid__c = amountPaid' by Anusha -27/10/22 LX3-5610
                    ElixirSuite__Total_Remaining_Unallocated_Amount__c = amountPaid,
                    // add total unallocated to total remoaning allocated too
                    ElixirSuite__Payment_Transaction_Number__c = pmtTransactionNumber,
                    ElixirSuite__Transaction_Date__c = dateOfPmt, ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                    ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment',
                    ElixirSuite__Payment_Received_By__c='Patient'); //Added ElixirSuite__Payment_Received_By__c='Patient' by Anusha -06/10/22     
                if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                    otherPaymentForNoProceduresObj.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                }
                if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                    otherPaymentForNoProceduresObj.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                }
                //if(Schema.sObjectType.ElixirSuite__Master_Transaction__c.isCreateable()){      
                // insert otherPaymentForNoProceduresObj; 
                DMLManager.insertAsUser(otherPaymentForNoProceduresObj); 
                // }
            }
            else{
                ElixirSuite__Master_Transaction__c otherTransaction = new ElixirSuite__Master_Transaction__c(
                    ElixirSuite__Total_Amount_Paid__c = amountPaid,ElixirSuite__Account__c = acctId,
                    ElixirSuite__Payment_Transaction_Number__c = pmtTransactionNumber,
                    ElixirSuite__Transaction_Date__c = dateOfPmt, ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                    ElixirSuite__Reason_Of_Payment__c = 'Applied Payment',
                    ElixirSuite__Payment_Received_By__c='Patient'); //Added ElixirSuite__Payment_Received_By__c='Patient' by Anusha -06/10/22 
                if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                    otherTransaction.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                }
                if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                    otherTransaction.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                }
                DMLManager.insertAsUser(otherTransaction); 
                if(totalAppliedAmount > amountPaid){            
                    paymentAllocationEngine(amountPaid,modeOfPayment,dateOfPmt,pmtTransactionNumber,acctId,selectedProcedureRecords,
                                            totalAppliedAmount,totalUnAllocatedAmount,fetch_Procedure_MasterTransaction_Sorted(selectedProcedureRecords),
                                            otherTransaction, paymentInfoId, chequeNo);
                }
                else{
                    //Intially used fetch_Procedure_MasterTransaction_UnSorted
                    paymentAllocationEngine(amountPaid,modeOfPayment,dateOfPmt,pmtTransactionNumber,acctId,selectedProcedureRecords,
                                            totalAppliedAmount,totalUnAllocatedAmount,fetch_Procedure_MasterTransaction_Sorted(selectedProcedureRecords),
                                            otherTransaction, paymentInfoId, chequeNo);
                }
            }
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
        ElixirSuite__Payment_Transaction__c[] MT_TO_UPDATE = new List<ElixirSuite__Payment_Transaction__c>();
        Set<Id> masterTransactionIdSet = new Set<Id>();
        for(ElixirSuite__Payment_Transaction__c sObj : masterTranRecLst){
            if(amountPaid>0){                
                if(idAndRemainingAmt.containsKey(sObj.Id)){                       
                    Decimal remainingAmt = idAndRemainingAmt.get(sObj.Id);
                    if(amountPaid>remainingAmt){     // 900>991                                               
                        ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = remainingAmt,
                                                                                                       ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                       ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                       ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                                                                                                       ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                                       ElixirSuite__Payment_Received_By__c = 'Patient',
                                                                                                       ElixirSuite__Type_of_Payment__c = 'Payment');
                        if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                            transactionRec.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                        }
                        if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                            transactionRec.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                        } 
                        amountPaid = amountPaid - remainingAmt;
                        allTransactionForMT.add(transactionRec);
                    }
                    else {                                                   
                        ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = amountPaid,
                                                                                                       ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                       ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                       ElixirSuite__Mode_of_Payment__c = modeOfPayment,
                                                                                                       ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                                       ElixirSuite__Payment_Received_By__c = 'Patient',
                                                                                                       ElixirSuite__Type_of_Payment__c = 'Payment');
                        if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                            transactionRec.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                        }
                        if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                            transactionRec.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                        } 
                        
                        amountPaid = 0;
                        allTransactionForMT.add(transactionRec);
                    }                        
                }                
                MT_TO_UPDATE.add(sObj);
                masterTransactionIdSet.add(sObj.Id);
            }
        }
        if(amountPaid>0){ // after payment if any money left
            ElixirSuite__Master_Transaction__c unAllocatedAmtObj = new ElixirSuite__Master_Transaction__c(
                ElixirSuite__Total_Unallocated_Amount__c = amountPaid,ElixirSuite__Account__c = acctId,
                ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment',
                ElixirSuite__Total_Remaining_Unallocated_Amount__c = amountPaid,
                ElixirSuite__Mode_of_Payment__c = modeOfPayment); 
                if(string.isNotEmpty(paymentInfoId) && string.isNotBlank(paymentInfoId)){
                unAllocatedAmtObj.ElixirSuite__Payment_Information__c = paymentInfoId;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                }
                if(string.isNotEmpty(chequeNo) && string.isNotBlank(chequeNo)){
                unAllocatedAmtObj.ElixirSuite__Cheque_Number__c = chequeNo;     // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280            
                } 
            //  insert unAllocatedAmtObj;
                DMLManager.insertAsUser(unAllocatedAmtObj); 
        }
        //if(Schema.sObjectType.ElixirSuite__Payment_Transaction__c.isUpdateable()){
        //update MT_TO_UPDATE;
        DMLManager.updateAsUser(MT_TO_UPDATE);
        //}
        if(Schema.sObjectType.ElixirSuite__Transactions__c.isCreateable()){
            // insert allTransactionForMT;
            DMLManager.insertAsUser(allTransactionForMT); 
        }
        calculateRemainingAmt(masterTransactionIdSet);
    }
    
    public static void calculateRemainingAmt(Set<Id> masterTransactionIdSet)
    {
        
    }
    public static ElixirSuite__Payment_Transaction__c[] fetch_Procedure_MasterTransaction_UnSorted(String selectedProcedureRecords){
        return  [SELECT ID,ElixirSuite__Expected_Receivable_amount__c,ElixirSuite__Other_Discounts__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__PatientOutstanding__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c FROM ElixirSuite__Payment_Transaction__c WHERE 
                 ID IN : collect_Procedure_MasterTransaction_Ids(selectedProcedureRecords) with security_enforced];
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
    public static  wrapperData filterAllProcedureOnMasterTransaction(Date dosFrom,Date dosTo,String procedureName,String CPTCode,String acctId,
                                                                  List<String> eisitngIdArr)
    {
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
        List<String> queries = new List<String>();
        String otherFieldsAddition = ' ,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Status__c '; 
        String additionFieldsPrefix = ' WHERE ElixirSuite__Procedure__r.ElixirSuite__Is_Billable__c = true '+  ' AND ' + ' ElixirSuite__PatientOutstanding__c >0 AND ElixirSuite__PatientOutstanding__c !=null AND ElixirSuite__Account__c = : acctId  AND RecordtypeId = : devRecordTypeId';
        String prefixClaimName = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Payment_Transaction__c',otherFieldsAddition,additionFieldsPrefix+'');       
        if(String.isNotBlank(procedureName)){
            queries.add('ElixirSuite__Procedure__r.Name= :procedureName');
        }
        if(String.isNotBlank(CPTCode)){
            queries.add('ElixirSuite__Cpt_Codes__c= :CPTCode');
        }
        if(String.isNotBlank(String.valueOf(dosFrom)) && String.isNotBlank(String.valueOf(dosTo))){
            //  dosTo = dosTo + 1;
            queries.add('ElixirSuite__Date_Of_Service__c>= :dosFrom AND ElixirSuite__Date_Of_Service__c<= :dosTo');
        } 
        if(eisitngIdArr!=null){
            queries.add(' ID NOT IN :eisitngIdArr');
        }                                                      
        String clause = prefixClaimName;
        if(queries!=null && queries.size()>0){
            clause = clause + ' AND ' +STring.escapeSingleQuotes(String.join(queries,' AND '))  + ' order by ElixirSuite__Date_Of_Service__c desc';
        }
        ElixirOEM_TimelineHelper.mDebugUntruncated(clause);
        wrapperData wrpData = new wrapperData();
        wrpData.allProcedureOnMT = new List<ElixirSuite__Payment_Transaction__c>();
        wrpData.allProcedureOnMT = Database.query(clause);
        wrpData.queryString = clause;
        return wrpData;   
    }
    
    public class MessageWrapper
    {
        @AuraEnabled
        public String msgState;
        @AuraEnabled
        public String msgStr;
    }
}