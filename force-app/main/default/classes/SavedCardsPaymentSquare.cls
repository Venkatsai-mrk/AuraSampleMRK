public with sharing class SavedCardsPaymentSquare {
    public static String sourceId = '';
    public static String accountId = '';
     public static Map<String,Decimal> idAndRemainingAmt = new Map<String,Decimal>();
     public static Map<String,Decimal> idAndAdditionalDiscAmt = new Map<String,Decimal>();
    public static Map<String,Decimal> idAndAssignedAmt = new Map<String,Decimal>();
    @AuraEnabled
    public static wrapperData getData(string accid){   
        wrapperData wrpr = new wrapperData();
        
        List<Payment_Transaction__c> filteredPayTrans = new List<Payment_Transaction__c>();
        List<Payment_Information__c> PInfo = new List<Payment_Information__c>();
        List<Master_Transaction__c> mt = new List<Master_Transaction__c>();
        
        Account PatData = new Account();
        Id payTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Payment_Transaction').getRecordTypeId();
        
        AggregateResult[] groupedResults =[Select SUM(ElixirSuite__Total_Remaining_Unallocated_Amount__c) from ElixirSuite__Master_Transaction__c WHERE ElixirSuite__Account__c=: accid AND ElixirSuite__Reason_Of_Payment__c='Unallocated Payment' AND ElixirSuite__Payment_Received_By__c='Insurance' WITH SECURITY_ENFORCED]; //Replace 'Patient' with 'Insurance' by Anusha - 06/10/22
       
        PInfo = [Select id,
                 CVV_Number__c,
                 Credit_Card_Number__c,
                 Expiration_Month__c,
                 Expiration_Year__c,
                 First_Name_on_Card__c,
                 Last_Name_on_Card__c, 
                 name,Account__c 
                 from  Payment_Information__c 
                 where Account__c=:accid WITH SECURITY_ENFORCED];
        PatData = [Select id, 
                   name,
                   Patient_s_Birth_Date__c,
                   ElixirSuite__DOB__c,
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
        
       
        wrpr.ProcData=filteredPayTrans;
        wrpr.PayInfo=PInfo;
        wrpr.PatientData=PatData;
        wrpr.MasTrans = mt;
        if(String.valueOf(groupedResults[0].get('expr0'))!=null){
             wrpr.totalRemainingUnallocatedAmount = Decimal.valueOf(String.valueOf(groupedResults[0].get('expr0')));
        }else{
             wrpr.totalRemainingUnallocatedAmount = 0;
        }
       
        return wrpr;
    }
    
    public class wrapperData{
        
        @AuraEnabled Public List<Payment_Transaction__c> ProcData; 
        @AuraEnabled Public List<Payment_Information__c> PayInfo;
        @AuraEnabled Public List<Master_Transaction__c> MasTrans;
        @AuraEnabled Public Account PatientData;
        @AuraEnabled Public Decimal totalRemainingUnallocatedAmount;
         @AuraEnabled Public List<ElixirSuite__Payment_Information__c> PaymentCardData; 
    }
  
     
    //Venkat
    public static ElixirSuite__Payment_Transaction__c[] fetch_Procedure_MasterTransaction_UnSorted(String selectedProcedureRecords){
        return  [SELECT ID,ElixirSuite__Patient_Outstanding__c,ElixirSuite__Patient_Responsibility__c,ElixirSuite__Expected_Receivable_amount__c,ElixirSuite__Other_Discounts__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c FROM ElixirSuite__Payment_Transaction__c WHERE 
                 ID IN : collect_Procedure_MasterTransaction_Ids(selectedProcedureRecords) with security_enforced];
    }
 public static ElixirSuite__Payment_Transaction__c[] fetch_Procedure_MasterTransaction_UnSortedAdditionalDiscount(String selectedProcedureRecords){
        return  [SELECT ID,ElixirSuite__Patient_Outstanding__c,ElixirSuite__Patient_Responsibility__c,ElixirSuite__Expected_Receivable_amount__c,ElixirSuite__Other_Discounts__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c FROM ElixirSuite__Payment_Transaction__c WHERE 
                 ID IN : collect_Procedure_MasterTransaction_IdsAndAdditionaldiscount(selectedProcedureRecords) with security_enforced];
    }
   /* public static ElixirSuite__Payment_Transaction__c[] fetch_Procedure_MasterTransaction_Sorted(String selectedProcedureRecords){
        return  [SELECT ID,ElixirSuite__Patient_Outstanding__c,ElixirSuite__Patient_Responsibility__c,ElixirSuite__Expected_Receivable_amount__c,ElixirSuite__Other_Discounts__c,ElixirSuite__Total_Paid_Amount__c FROM ElixirSuite__Payment_Transaction__c WHERE 
                 ID IN : collect_Procedure_MasterTransaction_Ids(selectedProcedureRecords) with security_enforced order By Date_Of_Service__c asc];
    }*/
    public static Set<Id> collect_Procedure_MasterTransaction_Ids(String selectedProcedureRecords){
        Set<Id> recordIds = new Set<Id>();
        for(Object obj : ElixirOEM_AddEraHelper.utilityMapDeserialize(selectedProcedureRecords,'procedures')){
            Map<String, Object> mapOfSelectedProcedures = (Map<String, Object>) obj;
            recordIds.add(String.valueOf(mapOfSelectedProcedures.get('Id')));
            idAndRemainingAmt.put(String.valueOf(mapOfSelectedProcedures.get('Id')),Decimal.valueOf(String.valueOf(mapOfSelectedProcedures.get('RemainingAmount')))
                                 );            
        
        }
        return recordIds;
    }
 public static Set<Id> collect_Procedure_MasterTransaction_IdsAndAdditionaldiscount(String selectedProcedureRecords){
        Set<Id> recordIds = new Set<Id>();
        for(Object obj : ElixirOEM_AddEraHelper.utilityMapDeserialize(selectedProcedureRecords,'procedures')){
            Map<String, Object> mapOfSelectedProcedures = (Map<String, Object>) obj;
            if((Decimal.valueOf(String.valueOf(mapOfSelectedProcedures.get('inputDiscountNew'))))!=null){
            recordIds.add(String.valueOf(mapOfSelectedProcedures.get('Id')));
            idAndAdditionalDiscAmt.put(String.valueOf(mapOfSelectedProcedures.get('Id')),Decimal.valueOf(String.valueOf(mapOfSelectedProcedures.get('inputDiscountNew')))
                                 );            
        
            }else{
           recordIds.add(String.valueOf(mapOfSelectedProcedures.get('Id')));
            idAndAdditionalDiscAmt.put(String.valueOf(mapOfSelectedProcedures.get('Id')),0)
                                 ;                
            }
        }
        return recordIds;
    }
    //Venkat - End
    @AuraEnabled
    public static ElixirSuite__ERA_Generation__c getERASetting(){
        return ElixirSuite__ERA_Generation__c.getInstance();
    }
    //Anusha
    @AuraEnabled
    public static List<Payment_Transaction__c> getPrivateProc(String acctId){
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
        List<Payment_Transaction__c> PdataForprivatePayment = new List<Payment_Transaction__c>();
        PdataForprivatePayment = [Select Id, 
                                    Name,Date_Of_Service__c,
                                    Account__c,
                                    Procedure_Name__c,
                                    Procedure__r.Name,
                                    Procedure__r.ElixirSuite__Claim_Generation__c,
                                    Procedure__r.ElixirSuite__Claim__r.Name,
                                    Actual_Price__c,
                                    Patient_Responsibility__c, 
                                    ElixirSuite__Total_Paid_Amount__c,
                                  ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                                    Patient_Outstanding__c,
                                    Insurance_Paid__c,
                                    Discount_Amount__c , Other_Discount__c,
                                    Total_Remaining_Amount__c
                                    from  Payment_Transaction__c 
                                    WHERE ElixirSuite__Procedure__r.ElixirSuite__Is_Billable__c = true AND ElixirSuite__Total_Remaining_Amount__c >0  AND ElixirSuite__Account__c = : acctId AND RecordtypeId = : devRecordTypeId
                                    WITH SECURITY_ENFORCED
                                    order By Date_Of_Service__c desc];

        return PdataForprivatePayment;
    }
   //Venkat
     @AuraEnabled
   public static wrapperData getPaymentInfo(String acctId){
       wrapperData wrpr = new wrapperData();
        Id creditcardRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Information__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
       
        List<ElixirSuite__Payment_Information__c> paymentInfo = [Select Id, 
                                    Name,ElixirSuite__Account__c,ElixirSuite__Credit_Card_Company__c, ElixirSuite__Account_Number__c, ElixirSuite__Credit_Card_Number__c, ElixirSuite__First_Name_on_Card__c 
                                    from  ElixirSuite__Payment_Information__c 
                                    WHERE ElixirSuite__Account__c = : acctId AND RecordtypeId = : creditcardRecordTypeId
                                    WITH SECURITY_ENFORCED
                                    ];
       wrpr.PaymentCardData = paymentInfo;
        return wrpr;
         
    }
//Venkat
@AuraEnabled     
    public static  ElixirSuite__Master_Transaction__c makeCollectPayment(Decimal amountToBePaid,
                                           String acctId,String selectedProcedureRecords, 
                                                                         decimal discountAmount, decimal totalRemainingAmount,
                                                                        String strModeOfPayment, String referenceNumber)
    {

            ElixirSuite__Master_Transaction__c otherTransaction = new ElixirSuite__Master_Transaction__c(
                ElixirSuite__Total_Amount_Paid__c = amountToBePaid,
                ElixirSuite__Account__c = acctId,
                 ElixirSuite__Discount_Amount__c = discountAmount,
                ElixirSuite__Type_of_Allocation__c = 'Discounted',
                //ElixirSuite__Payment_Transaction_Number__c = pmtTransactionNumber,
                ElixirSuite__Transaction_Date__c = system.today(), 
                ElixirSuite__Mode_of_Payment__c = strModeOfPayment,
                ElixirSuite__Payment_Transaction_Number__c = referenceNumber,
                ElixirSuite__Reason_Of_Payment__c = 'Applied Payment',
                ElixirSuite__Payment_Received_By__c='Patient'); 

            //insert otherTransaction;
            if(otherTransaction!=null ){
                DMLManager.insertAsUser(otherTransaction);
            }
            //System.debug('totalAppliedAmount '+totalAppliedAmount);
               collectPaymentAllocation(amountToBePaid,acctId,selectedProcedureRecords,
                                        fetch_Procedure_MasterTransaction_UnSorted(selectedProcedureRecords),
                                        otherTransaction,totalRemainingAmount,
                                        fetch_Procedure_MasterTransaction_UnSortedAdditionalDiscount(selectedProcedureRecords) );
        return otherTransaction;

    }
    public static void collectPaymentAllocation(Decimal amountToBePaid,String acctId,String selectedProcedureRecords,ElixirSuite__Payment_Transaction__c[] masterTranRecLst,
                                               ElixirSuite__Master_Transaction__c otherTransaction,Decimal totalRemainingAmount,ElixirSuite__Payment_Transaction__c[] masterTranAdditionalDisc)
    {
        ElixirSuite__Transactions__c [] allTransactionForMT = new List<ElixirSuite__Transactions__c>();
        ElixirSuite__Transactions__c [] DiscountAmountTransaction = new List<ElixirSuite__Transactions__c>();
        ElixirSuite__Payment_Transaction__c[] MT_TO_UPDATE = new List<ElixirSuite__Payment_Transaction__c>();
        Set<Id> masterTransactionIdSet = new Set<Id>();
        for(ElixirSuite__Payment_Transaction__c sObj : masterTranRecLst){
               
                 if(idAndRemainingAmt.containsKey(sObj.Id)){                       
                    Decimal remainingAmt = idAndRemainingAmt.get(sObj.Id);
                     Decimal divideProportional = (remainingAmt/totalRemainingAmount)*amountToBePaid;
                        ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = divideProportional ,
                                                                                                       ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                       ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                       ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                                       ElixirSuite__Payment_Received_By__c = 'Patient',
                                                                                                       ElixirSuite__Type_of_Payment__c = 'Payment');

                       
                        allTransactionForMT.add(transactionRec);
                 }
                MT_TO_UPDATE.add(sObj);
                masterTransactionIdSet.add(sObj.Id);
         
        }
         for(ElixirSuite__Payment_Transaction__c sObj : masterTranAdditionalDisc){
                 if(idAndAdditionalDiscAmt.containsKey(sObj.Id)){                       
                    Decimal inputDiscountNew = idAndAdditionalDiscAmt.get(sObj.Id);
                  if(inputDiscountNew>0){
                        ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = inputDiscountNew ,
                                                                                                       ElixirSuite__Master_Transaction__c = sObj.Id,
                                                                                                       ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                       ElixirSuite__Type_of_Payment__c = 'Discount',
                                                                                                       ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                                                                                                       ElixirSuite__Payment_Received_By__c = 'Patient');

                       
                        DiscountAmountTransaction.add(transactionRec);
                 }
            }
        }
       
        if(Schema.sObjectType.ElixirSuite__Payment_Transaction__c.isUpdateable()){
        update MT_TO_UPDATE;
        }
        if(Schema.sObjectType.ElixirSuite__Transactions__c.isCreateable()){
            insert allTransactionForMT;
             insert DiscountAmountTransaction;
        }
    }
    
       @AuraEnabled
    public static Id createOtherTransaction(String acctId, Id paymentSFId,String procedures, Decimal totalAmount,
    Decimal discountAmount){
       List<Payment_Information__c> infos = [SELECT Id, ElixirSuite__Source_Id__c,ElixirSuite__Account__c FROM ElixirSuite__Payment_Information__c
             								WHERE Id= :paymentSFId AND ElixirSuite__Account__c= :acctId
                                             WITH SECURITY_ENFORCED];
        if(infos!=null && infos.size()>0){
        sourceId = infos[0].ElixirSuite__Source_Id__c;
        accountId = infos[0].ElixirSuite__Account__c;
        }
        Master_Transaction__c otherTransaction = new Master_Transaction__c();  //OT
        otherTransaction.Account__c = acctId;
        otherTransaction.Transaction_Date__c = System.today();
        otherTransaction.Total_Amount_Paid__c = totalAmount;
        otherTransaction.Payment_Type__c = 'Card';
        otherTransaction.ElixirSuite__Reason_Of_Payment__c = 'Applied Payment';
        otherTransaction.ElixirSuite__Payment_Received_By__c='Patient';
        otherTransaction.ElixirSuite__Discount_Amount__c = discountAmount;
        //otherTransaction.ElixirSuite__Discount_Percentage__c = discountPercent;
        //insert otherTransaction;
        if(otherTransaction!=null ){
            DMLManager.insertAsUser(otherTransaction);
        }
       return otherTransaction.Id;
    }
    
    @AuraEnabled
    public static List<Id> createTransaction(Id acctId,String procedures,
     Id otherTransactionId,Decimal totalAmount){
        if(totalAmount!=null){
            totalAmount = Integer.valueOf(totalAmount*100);
        }
        Map<String, Object> m =   (Map<String, Object>) JSON.deserializeUntyped(procedures);
        List<Object> proceduresList = (List<Object>) m.get('procedures');
        List<ElixirSuite__Transactions__c> transactionsToInsert = new List<ElixirSuite__Transactions__c>();
        for(Object procedure :proceduresList){
            Map<String,Object> proc = (Map<String,Object>) procedure;
            String masterId = (String) proc.get('Id');
            if( proc.get('inputDiscountNew')!=null && Decimal.valueOf(String.valueOf(proc.get('inputDiscountNew')))!=0){
                Decimal additionalDiscount = Decimal.valueOf(String.valueOf(proc.get('inputDiscountNew')));
                ElixirSuite__Transactions__c transactionRec = 
                new ElixirSuite__Transactions__c(
                ElixirSuite__Amount_Paid__c = additionalDiscount ,
                ElixirSuite__Master_Transaction__c = masterId,
                ElixirSuite__Payment_DateTime__c = System.now(),
                ElixirSuite__Type_of_Payment__c = 'Discount',
                Payment_Status__c = 'In Progress',
                ElixirSuite__Other_Transactions__c = otherTransactionId,
                ElixirSuite__Payment_Received_By__c = 'Patient');
                transactionsToInsert.add(transactionRec);
            }
            if( proc.get('AmountToBeCharged')!=null && Decimal.valueOf(String.valueOf(proc.get('AmountToBeCharged')))!=0){
                ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c();
                transactionRec.Master_Transaction__c = masterId;
                transactionRec.Payment_DateTime__c = System.now();
                transactionRec.Payment_Status__c = 'In Progress';
                transactionRec.Other_Transactions__c = otherTransactionId;
                transactionRec.ElixirSuite__Payment_Received_By__c = 'Patient';
                transactionRec.ElixirSuite__Amount_Paid__c = Decimal.valueOf(String.valueOf(proc.get('AmountToBeCharged')));   
                transactionsToInsert.add(transactionRec);
            }
        }
        if(transactionsToInsert!=null && transactionsToInsert.size()>0){
            insert transactionsToInsert;
            List<Id> transactionIds = 
            new List<Id>(new Map<Id, ElixirSuite__Transactions__c>(transactionsToInsert).keySet());
            return transactionIds;
        }
        return new List<Id>{};
    }
    
    @AuraEnabled
    public static  String createPaymentsFromSquareUp
    (String acctId, Decimal totalAmount, List<Id> transactionIds, Id paymentSFId){  
        return 'Failed';
    }
    @AuraEnabled
    public static Id createCheckOutOtherTransaction(String recordId, String procedures,
    Decimal totalAmount,Decimal discountAmount){
        Master_Transaction__c otherTransaction = new Master_Transaction__c(); 
        otherTransaction.Account__c = recordId;
        otherTransaction.Transaction_Date__c = System.today();
        otherTransaction.ElixirSuite__Reason_Of_Payment__c = 'Applied Payment';
        otherTransaction.ElixirSuite__Payment_Received_By__c='Patient';
        otherTransaction.Total_Amount_Paid__c = totalAmount;
        otherTransaction.Payment_Type__c = 'Card';
        otherTransaction.Discount_Amount__c = discountAmount;
        //otherTransaction.Discount_Percentage__c = discountPercent;
        //insert otherTransaction;
        if(otherTransaction!=null){
            DMLManager.insertAsUser(otherTransaction);
        }
        Map<String, Object> m =   (Map<String, Object>) JSON.deserializeUntyped(procedures);
        List<Object> proceduresList = (List<Object>) m.get('procedures');
        List<ElixirSuite__Transactions__c> transactionsToInsert = new List<ElixirSuite__Transactions__c>();
        for(Object procedure :proceduresList){
            Map<String,Object> proc = (Map<String,Object>) procedure;
            String masterId = (String) proc.get('Id');
            if( proc.get('inputDiscountNew')!=null && Decimal.valueOf(String.valueOf(proc.get('inputDiscountNew')))!=0){
                Decimal additionalDiscount = Decimal.valueOf(String.valueOf(proc.get('inputDiscountNew')));
                ElixirSuite__Transactions__c transactionRec = 
                new ElixirSuite__Transactions__c(
                ElixirSuite__Amount_Paid__c = additionalDiscount ,
                ElixirSuite__Master_Transaction__c = masterId,
                ElixirSuite__Payment_DateTime__c = System.now(),
                ElixirSuite__Type_of_Payment__c = 'Discount',
                ElixirSuite__Payment_Status__c = 'In Progress',
                ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                ElixirSuite__Payment_Received_By__c = 'Patient');
                transactionsToInsert.add(transactionRec);
            }
            if( proc.get('AmountToBeCharged')!=null && Decimal.valueOf(String.valueOf(proc.get('AmountToBeCharged')))!=0){
                ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c();
                transactionRec.Master_Transaction__c = masterId;
                transactionRec.Payment_DateTime__c = System.now();
                transactionRec.ElixirSuite__Payment_Received_By__c = 'Patient';
transactionRec.ElixirSuite__Type_of_Payment__c = 'Payment';
                transactionRec.Payment_Status__c = 'In Progress';
                transactionRec.Other_Transactions__c = otherTransaction.Id;
                transactionRec.ElixirSuite__Amount_Paid__c = Decimal.valueOf(String.valueOf(proc.get('AmountToBeCharged')));   
                transactionsToInsert.add(transactionRec);
            }
        }
        if(transactionsToInsert!=null && transactionsToInsert.size()>0){
            insert transactionsToInsert;
        }
        return otherTransaction.Id;


    }
    @AuraEnabled
    public static String checkOutApi(String recordId,Decimal totalAmount,
    Decimal discountAmount,Id returnOtherTransactionId){ 
        return 'Failed';  
    }
    @AuraEnabled
    public static terminalWrapper activateTerminal(String recordId, Decimal totalAmount){
        String checkoutId = CreateTerminalCheckout.activateTerminal(recordId, totalAmount);
        terminalWrapper termWrap = new terminalWrapper();
        termWrap.checkoutId = '##';
        return termWrap;
    }
    public class terminalWrapper{
        @AuraEnabled public String checkoutId;
        @AuraEnabled public Integer interval;
        @AuraEnabled public Integer timeOut;
    }
    @AuraEnabled
    public static String checkTerminalPayment(String recordId, String procedures,
    Decimal totalAmount,Decimal discountAmount, String deviceId){
        String paymentId='';
        String cardType = CreateTerminalCheckout.getPaymentInfo(paymentId);
        //cardType will always return null
       	return cardType;
    }
    @AuraEnabled
    public static void closeTerminalPayment(String deviceId){
        CreateTerminalCheckout.cancelTerminalPayment(deviceId);
    }
    @AuraEnabled
    public static String fetchModeofOtherPayments(){
        //updated in relation to the deprecation of Terminal_Checkout custom setting
        return null;
    }
    public static Decimal returnDollar(String val){ 
        if(val.length()<3){
            return 0.00;
        }
        String dollar= val.Substring(0,val.length()-2);
		String cents = val.right(2);
        return Decimal.valueOf(dollar+'.'+cents);    
    }
}