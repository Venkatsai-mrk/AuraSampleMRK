/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ElixirOEM_AllocateDiscountHelper {
    public class wrapperData{    
          @AuraEnabled Public  ElixirSuite__Master_Transaction__c[] otherTransactionLst;
         @AuraEnabled Public  PaymentController.wrapperData paymntData;
        @AuraEnabled Public  Decimal amt = 0;
        @AuraEnabled public list<ElixirSuite__Master_Transaction__c> customSettingDiscountTable;
         @AuraEnabled public ElixirSuite__ERA_Generation__c[] customSettingData;
         @AuraEnabled public Map<String, String> typeOfDiscount;
    }
    
   @AuraEnabled
    public static  wrapperData customDiscountTable(string acctId){
        list<ElixirSuite__Master_Transaction__c> custmTable =   [SELECT Id, Name, ElixirSuite__Allocated_Amount__c,ElixirSuite__Discount_Code__c, ElixirSuite__Discount_Amount__c, ElixirSuite__Reason_Of_Payment__c, ElixirSuite__Total_Unallocated_Amount__c
                                                                 FROM ElixirSuite__Master_Transaction__c WHERE ElixirSuite__Complete_discount_to_be_utilized__c=false
                                                                 AND ElixirSuite__Allocated_Amount__c>0 AND ElixirSuite__Discount_Amount__c>0 AND ElixirSuite__Divide_the_Discount_Amount_equally_among__c=false  AND ElixirSuite__Total_Unallocated_Amount__c!=0 AND ElixirSuite__Total_Unallocated_Amount__c !=null AND
                                                                 (ElixirSuite__Reason_Of_Payment__c = 'Discounted Payment' OR ElixirSuite__Reason_Of_Payment__c = 'Discounted Percentage')  AND ElixirSuite__Account__c=:acctId WITH SECURITY_ENFORCED order by CreatedDate DESC ];
              
        wrapperData wrp = new wrapperData();
        wrp.customSettingDiscountTable = custmTable;
       wrp.customSettingData = customSettingsData();
        return wrp;
        
    }
    @AuraEnabled 
    public static  ElixirOEM_PrivatePaymentHelper.wrapperData filterProcedureOnMasterTransaction(Date dosFrom,Date dosTo,String procedureName,String CPTCode,String acctId,
                                                                                                 List<String> eisitngIdArr)
    {
        return ElixirOEM_PrivatePaymentHelper.filterProcedureOnMasterTransaction(dosFrom,dosTo,procedureName,CPTCode,
                                                                                 acctId,eisitngIdArr);
    }
    @AuraEnabled
     public static  ElixirSuite__ERA_Generation__c[] customSettingsData(){
        return  [select Id, ElixirSuite__Discount_Coupon_Code__c, ElixirSuite__Discount_Type__c from ElixirSuite__ERA_Generation__c WITH SECURITY_ENFORCED];
        
  }  
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
    @AuraEnabled 
    public static ElixirOEM_PrivatePaymentHelper.wrapperData queryAllProceduresOnMasterTransaction(String acctId){
        return ElixirOEM_PrivatePaymentHelper.queryAllProceduresOnMasterTransaction(acctId);
    }
    @AuraEnabled     
    public static  void allocateDiscountInSystem(ElixirSuite__Master_Transaction__c otherTransaction, string discountType,
                                                 String acctId,String selectedProcedureRecords,Decimal totalUnAllocatedDiscount, decimal appliedDiscount, string discountTableId) 
    {
		
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='PrivateAllocateDiscount' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null){
            Callable paymentIntegration = (Callable) Type.forName(virtualClassName).newInstance();
            paymentIntegration.call('AllocateDiscountPrivatePayment', new Map<String, Object> {
                'otherTransaction' => otherTransaction,
                    'discountType' => discountType,
                    'acctId' => acctId,
                    'selectedProcedureRecords' => selectedProcedureRecords,
                    'totalUnAllocatedDiscount' => totalUnAllocatedDiscount,
                    'appliedDiscount' => appliedDiscount,
                    'discountTableId' => discountTableId
                    });
            
        }
        else{		        
        otherTransaction.ElixirSuite__Transaction_Date__c = system.today();
        otherTransaction.ElixirSuite__Account__c = acctId;
        otherTransaction.ElixirSuite__Total_Amount_Paid__c  = otherTransaction.ElixirSuite__Discount_Amount__c;          
       // insert otherTransaction;
        Map<String,Decimal> idAndCurrentDiscAmt = collectProcedureMasterTransactionIds(selectedProcedureRecords);
        ElixirSuite__Transactions__c [] allTransactionForMT = new List<ElixirSuite__Transactions__c>();
        Set<Id> masterTransactionIdSet = new Set<Id>();
        for(ElixirSuite__Payment_Transaction__c sObj : fetchProcedureMasterTransaction(idAndCurrentDiscAmt.keySet())){            
            if(idAndCurrentDiscAmt.containsKey(sObj.Id)){                       
                Decimal discAmt = idAndCurrentDiscAmt.get(sObj.Id);                                            
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
        //insert allTransactionForMT; 
        list<ElixirSuite__Master_Transaction__c> ListToupdate = [select id,ElixirSuite__Allocated_Amount__c from ElixirSuite__Master_Transaction__c where id=:discountTableId WITH SECURITY_ENFORCED];
            ElixirSuite__Master_Transaction__c unAllocatedDiscountObj = new ElixirSuite__Master_Transaction__c();
               unAllocatedDiscountObj.Id=discountTableId;
                unAllocatedDiscountObj.ElixirSuite__Total_Remaining_Unallocated_Amount__c = totalUnAllocatedDiscount;
                unAllocatedDiscountObj.ElixirSuite__Transaction_Date__c = System.today();
                unAllocatedDiscountObj.ElixirSuite__Allocated_Amount__c = ListToupdate[0].ElixirSuite__Allocated_Amount__c+ appliedDiscount;
                unAllocatedDiscountObj.ElixirSuite__Total_Unallocated_Amount__c = totalUnAllocatedDiscount;
               unAllocatedDiscountObj.ElixirSuite__Complete_discount_to_be_utilized__c = otherTransaction.ElixirSuite__Complete_discount_to_be_utilized__c;
                unAllocatedDiscountObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c = otherTransaction.ElixirSuite__Divide_the_Discount_Amount_equally_among__c;
           // update unAllocatedDiscountObj; 
            DMLManager.updateAsUser(unAllocatedDiscountObj);
        
        calculateRemainingAmt(masterTransactionIdSet, discountType,unAllocatedDiscountObj.Id);
    }
    }
    public static void calculateRemainingAmt(Set<Id> masterTransactionIdSet, string discountType,Id otherTransactionId)
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