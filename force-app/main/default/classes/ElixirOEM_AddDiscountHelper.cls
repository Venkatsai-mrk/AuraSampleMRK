/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ElixirOEM_AddDiscountHelper {
    @AuraEnabled 
    public static wrapperData initPayloadCallData(String acctId){
        wrapperData toRet = new wrapperData();
        ElixirSuite__Master_Transaction__c[] otherTransactionLst = ElixirOEM_AllocatePaymentHelper.fetchOtherTransactionsForUnallocatedAmount(acctId);
        toRet.otherTransactionLst = otherTransactionLst;
        //toRet.amt = ElixirOEM_AllocatePaymentHelper.calculateUnAllocatedAmount(otherTransactionLst);
        toRet.typeOfDiscount =  MasterProblemListController.fetchPickListValue('ElixirSuite__Payment_Transaction__c','ElixirSuite__Type_of_Discount__c');
        return toRet;
    }
    @AuraEnabled 
    public static wrapperData paymentSchedulePayload(String acctId){
        wrapperData obj = new wrapperData();
        obj.paymntData = PaymentController.getData(acctId);
        return obj;
    }
    public class wrapperData{       
        @AuraEnabled Public  PaymentController.wrapperData paymntData;
        @AuraEnabled Public  ElixirSuite__Master_Transaction__c[] otherTransactionLst;
        @AuraEnabled Public  Decimal amt = 0;
        @AuraEnabled public Map<String, String> typeOfDiscount;
          @AuraEnabled Public List<ElixirSuite__Payment_Transaction__c> allProcedureOnMT; 
        @AuraEnabled Public String queryString; 
    }
    @AuraEnabled 
    public static ElixirOEM_PrivatePaymentHelper.wrapperData queryAllProceduresOnMasterTransaction(String acctId){
        return ElixirOEM_PrivatePaymentHelper.queryAllProceduresOnMasterTransaction(acctId);
    }
    @AuraEnabled 
    public static  wrapperData filterProcedureOnMasterTransaction(Date dosFrom,Date dosTo,String procedureName,String CPTCode,String acctId,
                                                                  List<String> eisitngIdArr)
    {
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
        List<String> queries = new List<String>();
        String otherFieldsAddition = ' ,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Status__c '; 
        String additionFieldsPrefix = ' WHERE ElixirSuite__Procedure__r.ElixirSuite__Is_Billable__c = true '+  ' AND ' + ' ElixirSuite__PatientOutstanding__c !=null AND ElixirSuite__PatientOutstanding__c >0 AND ElixirSuite__Account__c = : acctId AND RecordtypeId = : devRecordTypeId';

        String prefixClaimName = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Payment_Transaction__c',otherFieldsAddition,additionFieldsPrefix+'');       
        if(String.isNotBlank(procedureName)){
            queries.add('ElixirSuite__Procedure__r.Name= :procedureName');
        }
        if(String.isNotBlank(CPTCode)){
            queries.add('ElixirSuite__Cpt_Codes__c= :CPTCode');
        }
        if(String.isNotBlank(String.valueOf(dosFrom)) && String.isNotBlank(String.valueOf(dosTo))){
            dosTo = dosTo + 1;
            queries.add('ElixirSuite__Date_Of_Service__c>= :dosFrom AND ElixirSuite__Date_Of_Service__c<= :dosTo');
        } 
        if(eisitngIdArr!=null){
            queries.add(' ID NOT IN :eisitngIdArr');
        }                                                      
        String clause = prefixClaimName;
        if(queries!=null && queries.size()>0){
            clause = clause + ' AND ' +String.escapeSingleQuotes(String.join(queries,' AND '))  + ' order by ElixirSuite__Date_Of_Service__c desc';
        }
        ElixirOEM_TimelineHelper.mDebugUntruncated(clause);
        wrapperData wrpData = new wrapperData();
        wrpData.allProcedureOnMT = new List<ElixirSuite__Payment_Transaction__c>();
        wrpData.allProcedureOnMT = Database.query(clause);
        wrpData.queryString = clause;
        return wrpData;   
    }
    @AuraEnabled     
    public static  void allocateDiscountInSystem(ElixirSuite__Master_Transaction__c otherTransaction,
                                                 String acctId,String selectedProcedureRecords,Decimal totalUnAllocatedDiscount, decimal appliedDiscount, string DiscountCode, string Notes) 
    {
		
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='PrivateAddDiscount' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null){
            Callable paymentIntegration = (Callable) Type.forName(virtualClassName).newInstance();
            paymentIntegration.call('AddDiscountPrivatePayment', new Map<String, Object> {
                'otherTransaction' => otherTransaction,
                    'acctId' => acctId,
                    'selectedProcedureRecords' => selectedProcedureRecords,
                    'totalUnAllocatedDiscount' => totalUnAllocatedDiscount,
                    'appliedDiscount' => appliedDiscount,
                    'DiscountCode' => DiscountCode,
                    'Notes' => Notes
                    });
            
        }
        else{    
        otherTransaction.ElixirSuite__Transaction_Date__c = system.today();
        otherTransaction.ElixirSuite__Account__c = acctId;
        otherTransaction.ElixirSuite__Total_Amount_Paid__c  = otherTransaction.ElixirSuite__Discount_Amount__c;          
        //insert otherTransaction;
        DMLManager.insertAsUser(otherTransaction);
        Map<String,Decimal> idAndCurrentDiscAmt = collectProcedureMasterTransactionIds(selectedProcedureRecords);
        ElixirSuite__Transactions__c [] allTransactionForMT = new List<ElixirSuite__Transactions__c>();
        Decimal  discAmt;
        Set<Id> masterTransactionIdSet = new Set<Id>();
        for(ElixirSuite__Payment_Transaction__c sObj : fetchProcedureMasterTransaction(idAndCurrentDiscAmt.keySet())){            
            if(idAndCurrentDiscAmt.containsKey(sObj.Id)){                       
                discAmt = idAndCurrentDiscAmt.get(sObj.Id); 
                ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = discAmt,
                                                                                               ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                               ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                               ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                               ElixirSuite__Type_of_Payment__c = 'Discount',
                                                                                               ElixirSuite__Payment_Received_By__c = 'Patient');                
                allTransactionForMT.add(transactionRec);
                masterTransactionIdSet.add(sObj.Id);
            }
     
        }
        DMLManager.insertAsUser(allTransactionForMT);
      //  insert allTransactionForMT; 
       
            ElixirSuite__Master_Transaction__c unAllocatedDiscountObj = new ElixirSuite__Master_Transaction__c();
               
                unAllocatedDiscountObj.ElixirSuite__Account__c = acctId;
                unAllocatedDiscountObj.ElixirSuite__Reason_Of_Payment__c = otherTransaction.ElixirSuite__Reason_Of_Payment__c;
                unAllocatedDiscountObj.ElixirSuite__Complete_discount_to_be_utilized__c = otherTransaction.ElixirSuite__Complete_discount_to_be_utilized__c;
                unAllocatedDiscountObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c = otherTransaction.ElixirSuite__Divide_the_Discount_Amount_equally_among__c;
                unAllocatedDiscountObj.ElixirSuite__Type_of_Allocation__c = 'UnAllocated';
                unAllocatedDiscountObj.ElixirSuite__Total_Remaining_Unallocated_Amount__c = totalUnAllocatedDiscount;
                unAllocatedDiscountObj.ElixirSuite__Transaction_Date__c = System.today();
                unAllocatedDiscountObj.ElixirSuite__Allocated_Amount__c = appliedDiscount;
                unAllocatedDiscountObj.ElixirSuite__Discount_Code__c = DiscountCode;
                unAllocatedDiscountObj.ElixirSuite__Notes__c = Notes;
                  if(otherTransaction.ElixirSuite__Reason_Of_Payment__c=='Discounted Payment'){
                    unAllocatedDiscountObj.ElixirSuite__Discount_Amount__c = otherTransaction.ElixirSuite__Discount_Amount__c;
                    unAllocatedDiscountObj.ElixirSuite__Total_Unallocated_Amount__c = totalUnAllocatedDiscount;
               }
               if(otherTransaction.ElixirSuite__Reason_Of_Payment__c=='Discounted Percentage'){
                unAllocatedDiscountObj.ElixirSuite__Discount_Amount__c = otherTransaction.ElixirSuite__Discount_Percentage__c;
               if(otherTransaction.ElixirSuite__Maximum_Discount__c!=0){
               unAllocatedDiscountObj.ElixirSuite__Total_Unallocated_Amount__c = otherTransaction.ElixirSuite__Maximum_Discount__c- appliedDiscount;
               }else{
                 unAllocatedDiscountObj.ElixirSuite__Total_Unallocated_Amount__c=null;  
            }
       }
          //  insert unAllocatedDiscountObj; 
            DMLManager.insertAsUser(unAllocatedDiscountObj);
        calculateRemainingAmt(masterTransactionIdSet,discAmt);
    }
    }
    public static void calculateRemainingAmt(Set<Id> masterTransactionIdSet, Decimal discAmt)
    {
        
        
    }
    public static  Map<String,Decimal> collectProcedureMasterTransactionIds(String selectedProcedureRecords){
        Map<String,Decimal> idAndCurrentDiscAmt = new Map<String,Decimal>();
        for(Object obj : ElixirOEM_AddEraHelper.utilityMapDeserialize(selectedProcedureRecords,'procedures')){
            Map<String, Object> mapOfSelectedProcedures = (Map<String, Object>) obj;           
            idAndCurrentDiscAmt.put(String.valueOf(mapOfSelectedProcedures.get('Id')),Decimal.valueOf(String.valueOf(mapOfSelectedProcedures.get('currentDiscAmt')))
                                   );            
        }
        return idAndCurrentDiscAmt; 
    }
    public static ElixirSuite__Payment_Transaction__c[] fetchProcedureMasterTransaction(Set<String> selectedProcedureRecords){
        return  [SELECT ID,ElixirSuite__Expected_Receivable_amount__c,ElixirSuite__Other_Discounts__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c FROM ElixirSuite__Payment_Transaction__c WHERE 
                 ID IN : selectedProcedureRecords with security_enforced];
    }    
}