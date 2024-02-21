/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ElixirOEM_AllocatePaymentHelper {
    @AuraEnabled 
    public static wrapperData initPayloadCall(String acctId){
        wrapperData toRet = new wrapperData();
        List<Payment_Information__c> PInfo = new List<Payment_Information__c>();
        ElixirSuite__Master_Transaction__c[] otherTransactionLst = fetchOtherTransactionsForUnallocatedAmount(acctId);
        toRet.otherTransactionLst = otherTransactionLst;

        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='NewPaymentIntegration'  WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null){
            toRet.plugDataPresent = true;
        }
        
        AggregateResult[] groupedResults =[Select SUM(ElixirSuite__Total_Remaining_Unallocated_Amount__c) from ElixirSuite__Master_Transaction__c WHERE ElixirSuite__Account__c=: acctId AND ElixirSuite__Reason_Of_Payment__c='Unallocated Payment' WITH SECURITY_ENFORCED]; //Replace 'Patient' with 'Insurance' by Anusha - 06/10/22
        if(String.valueOf(groupedResults[0].get('expr0'))!=null){
        toRet.amt = Decimal.valueOf(String.valueOf(groupedResults[0].get('expr0')));
        }else{
        toRet.amt = 0;
        }
         PInfo = [Select id,
                 CVV_Number__c,
                 Credit_Card_Number__c,
                 Expiration_Month__c,
                 Expiration_Year__c,
                 First_Name_on_Card__c,
                 Last_Name_on_Card__c, 
                 name,Account__c 
                 from  Payment_Information__c 
                 where Account__c=:acctId WITH SECURITY_ENFORCED];
        toRet.PayInfo = PInfo;
        //toRet.amt =calculateUnAllocatedAmount(otherTransactionLst);
        return toRet;
    }
    public static Decimal calculateUnAllocatedAmount(ElixirSuite__Master_Transaction__c[] otherTransactionLst){
        Decimal amt = 0;
        for(ElixirSuite__Master_Transaction__c mt : otherTransactionLst){
            if(String.isNotBlank(String.valueOf(mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c)) && (mt.ElixirSuite__Reason_Of_Payment__c =='Unallocated Payment')){
                amt+=mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c;   
            }
        }
        return amt;
    }
    public static ElixirSuite__Master_Transaction__c[] fetchOtherTransactionsForUnallocatedAmount(String acctId){
        return [SELECT ID,ElixirSuite__Total_Unallocated_Amount__c,ElixirSuite__Total_Remaining_Unallocated_Amount__c
                FROM ElixirSuite__Master_Transaction__c
                WHERE ElixirSuite__Account__c =:acctId AND ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment'
                with security_enforced];  
    }
    public class wrapperData{       
        @AuraEnabled Public  ElixirSuite__Master_Transaction__c[] otherTransactionLst;
        @AuraEnabled Public  Decimal amt = 0;
        @AuraEnabled Public List<Payment_Information__c> PayInfo;
        @AuraEnabled Public Boolean plugDataPresent;
    }
    @AuraEnabled 
    public static ElixirOEM_PrivatePaymentHelper.wrapperData queryAllProceduresOnMasterTransaction(String acctId){
        return  ElixirOEM_PrivatePaymentHelper.queryAllProceduresOnMasterTransaction(acctId);
    }
    @AuraEnabled 
    public static  ElixirOEM_PrivatePaymentHelper.wrapperData filterProcedureOnMasterTransaction(Date dosFrom,Date dosTo,String procedureName,String CPTCode,String acctId,
                                                                                                 List<String> eisitngIdArr)
    {
        return ElixirOEM_PrivatePaymentHelper.filterProcedureOnMasterTransaction(dosFrom,dosTo,procedureName,CPTCode,
                                                                                 acctId,eisitngIdArr);
    }
    @AuraEnabled     
    public static  void allocatePaymentInSystem(Decimal amountAllocated,String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                        String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                        Decimal totalUnAllocatedAmount,Boolean noProcedureSelected,Decimal totalUnallocatedAmt, string paymentInfoId, string chequeNo)
    {
        
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='PrivateAllocatePayment'  WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null){
            Callable paymentIntegration = (Callable) Type.forName(virtualClassName).newInstance();
            paymentIntegration.call('AllocatePrivatePayment', new Map<String, Object> {
                'amountAllocated' => amountAllocated,
                    'modeOfPayment' => modeOfPayment,
                    'dateOfPmt' => dateOfPmt,
                    'pmtTransactionNumber' => pmtTransactionNumber,
                    'acctId' => acctId,
                    'selectedProcedureRecords' => selectedProcedureRecords,
                    'totalAppliedAmount' => totalAppliedAmount,
                    'totalUnAllocatedAmount' => totalUnAllocatedAmount,
                    'noProcedureSelected' => noProcedureSelected,
                    'totalUnallocatedAmt' => totalUnallocatedAmt,
                    'paymentInfoId' => paymentInfoId,
                    'chequeNo' => chequeNo
                    });
            
        }
        else{
        ElixirOEM_PrivatePaymentHelper.makePrivatePayment(amountAllocated, modeOfPayment, dateOfPmt, pmtTransactionNumber,
                                                          acctId, selectedProcedureRecords, totalAppliedAmount,
                                                          totalUnAllocatedAmount, noProcedureSelected,paymentInfoId,chequeNo);
        recalculateUnAllocatedAmount(acctId,totalUnallocatedAmt,amountAllocated);
    }
    }
    public static  void recalculateUnAllocatedAmount(String acctId,Decimal totalUnallocatedAmt,Decimal amountAllocated){
        ElixirSuite__Master_Transaction__c[] unallocatedRecords =   [SELECT ID,ElixirSuite__Total_Unallocated_Amount__c,
                                                                     ElixirSuite__Total_Remaining_Unallocated_Amount__c
                                                                     FROM ElixirSuite__Master_Transaction__c
                                                                     WHERE ElixirSuite__Account__c =:acctId AND ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment'
                                                                     AND ElixirSuite__Total_Remaining_Unallocated_Amount__c >= 0
                                                                     with security_enforced  order by createdDate ASC]; 
        ElixirSuite__Master_Transaction__c[] lstToUpdt = new List<ElixirSuite__Master_Transaction__c>();
        try{
        for(ElixirSuite__Master_Transaction__c mt  : unallocatedRecords){
            if(amountAllocated >= mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c){
                amountAllocated = amountAllocated - mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c;
                mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c = 0;
            }
            else {
                System.debug('amountAllocated '+amountAllocated);
                  System.debug('Id '+mt.Id);
                 System.debug('ElixirSuite__Total_Remaining_Unallocated_Amount__c '+mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c);
                mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c = mt.ElixirSuite__Total_Remaining_Unallocated_Amount__c - amountAllocated;
                amountAllocated = 0;
            }
            lstToUpdt.add(mt);
            

            
        }

        //if (Schema.sObjectType.ElixirSuite__Master_Transaction__c.isUpdateable()) {
           // update lstToUpdt;
            DMLManager.updateAsUser(lstToUpdt);
       // }
        
    }

    catch(Exception e){
        ExceptionLog.logError(e);
    }


}
}