public with sharing class RefundController {
    @AuraEnabled
    public static wrapperData getData(string accid){   
        wrapperData wrpr = new wrapperData();
        
        List<Payment_Transaction__c> PdataForPayment = new List<Payment_Transaction__c>();
        List<Payment_Transaction__c> FinalPayment = new List<Payment_Transaction__c>();
        List<ElixirSuite__Refund__c> refundLst = new List<ElixirSuite__Refund__c>();
        List<Payment_Information__c> PInfo = new List<Payment_Information__c>();
        Id payTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
        
        Id InsuranceTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
        
        refundLst = [SELECT Id,
                     Name,
                     ElixirSuite__Date_Created__c, 
                     ElixirSuite__Status__c,
                     ElixirSuite__Date_Issued__c,
                     ElixirSuite__Mode_of_Payment__c,
                     ElixirSuite__Credit_Check_Reference_field__c,
                     ElixirSuite__Refund_Amount__c, 
                     ElixirSuite__Reason_for_Refund__c, 
                     ElixirSuite__Master_Transaction__c, 
                     ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                     ElixirSuite__Transactions__c,
                     ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c
                     FROM ElixirSuite__Refund__c
                     WHERE ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c=:accid AND ElixirSuite__Status__c='Requested'
                     WITH SECURITY_ENFORCED
                     ORDER BY Name DESC];
        
        PdataForPayment = [Select Id, 
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
                           Insurance_Paid__c ,ElixirSuite__Other_Discount__c,
                           RecordtypeId,ElixirSuite__Expected_Receivable_amount__c
                           from  Payment_Transaction__c 
                           where Account__c=:accid  
                           AND (Status__c = 'UnPaid' OR Status__c = 'Payment Started') 
                           AND Procedure__r.ElixirSuite__Is_Billable__c = true AND Procedure__c != null
                           AND ElixirSuite__Total_Actual_Patient_Paid_Amount__c > 0
                           WITH SECURITY_ENFORCED
                           order By Date_Of_Service__c desc];
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
        ERA_Generation__c eraCS = ERA_Generation__c.getInstance();
        ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        for(Payment_Transaction__c rec : PdataForPayment){
            if(rec.RecordtypeId == payTxnRecordTypeId && eraCS.ElixirSuite__Private_Payments__c == true){
                FinalPayment.add(rec);
            }
            else if(rec.RecordtypeId == InsuranceTxnRecordTypeId && eraCS.ElixirSuite__Insurance_Payments__c == true){
                FinalPayment.add(rec);
            }
            else if(rec.RecordtypeId == payTxnRecordTypeId && customSetting.ElixirSuite__Include_CMS1500_Form__c == false
                    && customSetting.ElixirSuite__Include_UB04_Form__c == false){
                        FinalPayment.add(rec);
                    }
            
            
        }
        wrpr.PrivateRecordtypeId = payTxnRecordTypeId;
        wrpr.ProcDataForPayment = FinalPayment;
        wrpr.patientRefundLst = refundLst;
        wrpr.paymentInfo = PInfo;
        return wrpr;
    }
    
    @AuraEnabled
    public static String getAccountName(string accountId){
        String res='';
        List<Account> accLst = [Select Id,Name 
                                from Account 
                                where Id=:accountId
                                WITH SECURITY_ENFORCED];
        
        if(accLst != null && accLst.size() > 0){
            res = accLst[0].Name;
        }
        return res;
    }
    
    public class wrapperData{
        
        @AuraEnabled Public string PrivateRecordtypeId; 
        
        @AuraEnabled Public List<Payment_Transaction__c> ProcDataForPayment;
        
        @AuraEnabled Public List<ElixirSuite__Refund__c> patientRefundLst;
        @AuraEnabled Public List<ElixirSuite__Refund__c> refundLst ;
        @AuraEnabled Public List<ElixirSuite__Payment_Information__c> paymentInfo ;
    }
    
    @AuraEnabled
    public static wrapperData filterProcedurebasedOnDOS(string accid,Date dosFrom,Date dosTo){   
        wrapperData wrpr = new wrapperData();
        
        List<Payment_Transaction__c> PdataForPayment = new List<Payment_Transaction__c>();
        List<Payment_Transaction__c> FinalPayment = new List<Payment_Transaction__c>();
        Id payTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
        
        Id InsuranceTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
        
        
        PdataForPayment = [Select Id, 
                           Name,Date_Of_Service__c,
                           Account__c,
                           Procedure_Name__c,
                           Procedure__r.Name,
                           Procedure__r.ElixirSuite__Claim_Generation__c,
                           Procedure__r.ElixirSuite__Claim__r.Name,
                           Actual_Price__c,
                           ElixirSuite__Cpt_Codes__c,
                           Patient_Responsibility__c, 
                           ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c,
                           PatientOutstanding__c,
                           Insurance_Paid__c ,ElixirSuite__Other_Discount__c,
                           RecordtypeId,ElixirSuite__Expected_Receivable_amount__c
                           from  Payment_Transaction__c 
                           where Account__c=:accid  
                           AND (Status__c = 'UnPaid' OR Status__c = 'Payment Started') 
                           AND Procedure__r.ElixirSuite__Is_Billable__c = true AND Procedure__c != null
                           AND ElixirSuite__Total_Actual_Patient_Paid_Amount__c > 0
                           AND ElixirSuite__Date_Of_Service__c>= :dosFrom AND ElixirSuite__Date_Of_Service__c<= :dosTo
                           WITH SECURITY_ENFORCED
                           order By Date_Of_Service__c desc];
        ERA_Generation__c eraCS = ERA_Generation__c.getInstance();
        ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        for(Payment_Transaction__c rec : PdataForPayment){
            if(rec.RecordtypeId == payTxnRecordTypeId && eraCS.ElixirSuite__Private_Payments__c == true){
                FinalPayment.add(rec);
            }
            else if(rec.RecordtypeId == InsuranceTxnRecordTypeId && eraCS.ElixirSuite__Insurance_Payments__c == true){
                FinalPayment.add(rec);
            }
            else if(rec.RecordtypeId == payTxnRecordTypeId && customSetting.ElixirSuite__Include_CMS1500_Form__c == false
                    && customSetting.ElixirSuite__Include_UB04_Form__c == false){
                        FinalPayment.add(rec);
                    }
            
            
        }
        wrpr.PrivateRecordtypeId = payTxnRecordTypeId;
        wrpr.ProcDataForPayment = FinalPayment;
        
        return wrpr;
        
    }
    @AuraEnabled
    public static wrapperData filterRefundDates(string accid,Date dosFrom,Date dosTo,String seletedStatus){ 
        try{
            wrapperData wrpr = new wrapperData();
            List<ElixirSuite__Refund__c> refundDateLst = new List<ElixirSuite__Refund__c>();
            if(seletedStatus!='All'){
                refundDateLst = [SELECT Id,
                                 Name,
                                 ElixirSuite__Date_Created__c, 
                                 ElixirSuite__Status__c,
                                 ElixirSuite__Date_Issued__c,
                                 ElixirSuite__Mode_of_Payment__c,
                                 ElixirSuite__Credit_Check_Reference_field__c,
                                 ElixirSuite__Refund_Amount__c, 
                                 ElixirSuite__Reason_for_Refund__c, 
                                 ElixirSuite__Master_Transaction__c, 
                                 ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                                 ElixirSuite__Transactions__c,
                                 ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c
                                 FROM ElixirSuite__Refund__c
                                 WHERE ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c=:accid
                                 AND ((ElixirSuite__Date_Created__c >= :dosFrom AND ElixirSuite__Date_Created__c <= :dosTo)
                                      AND ElixirSuite__Status__c = :seletedStatus) WITH SECURITY_ENFORCED  ORDER BY Name DESC];
            }else{
                refundDateLst = [SELECT Id,
                                 Name,
                                 ElixirSuite__Date_Created__c, 
                                 ElixirSuite__Status__c,
                                 ElixirSuite__Date_Issued__c,
                                 ElixirSuite__Mode_of_Payment__c,
                                 ElixirSuite__Credit_Check_Reference_field__c,
                                 ElixirSuite__Refund_Amount__c, 
                                 ElixirSuite__Reason_for_Refund__c, 
                                 ElixirSuite__Master_Transaction__c, 
                                 ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                                 ElixirSuite__Transactions__c,
                                 ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c 
                                 FROM ElixirSuite__Refund__c
                                 WHERE ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c=:accid
                                 AND ElixirSuite__Date_Created__c >= :dosFrom AND ElixirSuite__Date_Created__c <= :dosTo
                                 WITH SECURITY_ENFORCED 
                                 ORDER BY Name DESC];
            }
            wrpr.refundLst = refundDateLst;
            return wrpr;
        }catch(Exception e){
            Exceptionlog.logError(e);
            return NULL;
        }
    }
    @AuraEnabled
    public static wrapperData filterRefundStatus(string accid, String seletedStatus){ 
        wrapperData wrpr = new wrapperData();
        List<ElixirSuite__Refund__c> refundDateLst = new List<ElixirSuite__Refund__c>();
        if(seletedStatus!='All'){
            refundDateLst = [SELECT Id,
                             Name,
                             ElixirSuite__Date_Created__c, 
                             ElixirSuite__Status__c,
                             ElixirSuite__Date_Issued__c,
                             ElixirSuite__Mode_of_Payment__c,
                             ElixirSuite__Credit_Check_Reference_field__c,
                             ElixirSuite__Refund_Amount__c, 
                             ElixirSuite__Reason_for_Refund__c, 
                             ElixirSuite__Master_Transaction__c, 
                             ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                             ElixirSuite__Transactions__c,
                             ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c 
                             FROM ElixirSuite__Refund__c
                             WHERE ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c=:accid
                             AND ElixirSuite__Status__c = :seletedStatus WITH SECURITY_ENFORCED  ORDER BY Name DESC];
        }else{
            refundDateLst = [SELECT Id,
                             Name,
                             ElixirSuite__Date_Created__c, 
                             ElixirSuite__Status__c,
                             ElixirSuite__Date_Issued__c,
                             ElixirSuite__Mode_of_Payment__c,
                             ElixirSuite__Credit_Check_Reference_field__c,
                             ElixirSuite__Refund_Amount__c, 
                             ElixirSuite__Reason_for_Refund__c, 
                             ElixirSuite__Master_Transaction__c, 
                             ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c,
                             ElixirSuite__Transactions__c,
                             ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c
                             FROM ElixirSuite__Refund__c
                             WHERE ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c=:accid
                             WITH SECURITY_ENFORCED 
                             ORDER BY Name DESC];
        }
        wrpr.refundLst = refundDateLst;
        return wrpr;
    }
    @AuraEnabled
    public static Object savemethod(string accid,List<ElixirSuite__Refund__c> refundIds){
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        Object Obj;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='ProcessRefundIntegration' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null && refundIds[0].ElixirSuite__Mode_of_Payment__c.contains('Credit Card')){
            Callable paymentIntegration = (Callable) Type.forName(virtualClassName).newInstance();
           Obj = paymentIntegration.call('ProcessRefund', new Map<String, Object> {
                'accid' => accid,
                    'refundIds' => refundIds
                    });
            return Obj;
        }
        else{
            MessageWrapper wrap = new MessageWrapper();
        wrap.msgState = 'Success';
            wrap.msgStr = 'Refund processed successfully';
            
        List<String> PayInfolist = new List<String>();
        Map<Id,Id> masterid = new Map<Id,Id>();
        Map<Id, Transactions__c> refundIdToTransactionMap = new Map<Id, Transactions__c>();
        Map<Id, Master_Transaction__c> transactionToOtherTransactionMap = new Map<Id, Master_Transaction__c>();
        List<ElixirSuite__Master_Transaction__c> otherTransaction = new List<ElixirSuite__Master_Transaction__c>();
        String userId = UserInfo.getUserId();
        for(ElixirSuite__Refund__c recId : refundIds){
            if((recId.ElixirSuite__Credit_Check_Reference_field__c == null || recId.ElixirSuite__Credit_Check_Reference_field__c=='') && recId.ElixirSuite__Status__c == 'Requested' &&
               (recId.ElixirSuite__Mode_of_Payment__c.contains('Credit Card') || recId.ElixirSuite__Mode_of_Payment__c == 'Cheque' || recId.ElixirSuite__Mode_of_Payment__c == 'Cash')){
                   
                   throw new AuraHandledException('Credit/Cheque Reference Field must have a value to process item!!');
               }
            if(recId.ElixirSuite__Status__c == 'Requested'){
                masterid.put(recId.id,recId.ElixirSuite__Master_Transaction__c);
            }
            if(recId.ElixirSuite__Mode_of_Payment__c.contains('Credit Card')){
                PayInfolist.add(recId.ElixirSuite__Payment_Information__c) ;
            }
        }
        //LX3-9283 Refund to Unallocated Patient Credit
        for(ElixirSuite__Refund__c rec : refundIds){
            if(rec.ElixirSuite__Mode_of_Payment__c == 'Patient Credit' && rec.ElixirSuite__Status__c == 'Requested'){
                ElixirSuite__Master_Transaction__c otherTransRec = new ElixirSuite__Master_Transaction__c();
                otherTransRec.ElixirSuite__Total_Amount_Paid__c =  rec.ElixirSuite__Refund_Amount__c;
                otherTransRec.ElixirSuite__Total_Unallocated_Amount__c = rec.ElixirSuite__Refund_Amount__c;
                otherTransRec.ElixirSuite__Account__c = accid;
                otherTransRec.ElixirSuite__Total_Remaining_Unallocated_Amount__c = rec.ElixirSuite__Refund_Amount__c;
                otherTransRec.ElixirSuite__Transaction_Date__c = Date.today();
                otherTransRec.ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment';
                otherTransRec.ElixirSuite__Mode_of_Payment__c	= 'Patient Credit';
                otherTransRec.ElixirSuite__Payment_Received_By__c = 'User';
                otherTransRec.ElixirSuite__User__c = userId;
                otherTransRec.ElixirSuite__Reference_Number__c = rec.ElixirSuite__Credit_Check_Reference_field__c;
                transactionToOtherTransactionMap.put(rec.Id, otherTransRec);
            }
            
        }
        List<Master_Transaction__c> otherTransRecList = new List<Master_Transaction__c>(transactionToOtherTransactionMap.values());
        DMLManager.insertAsUser(otherTransRecList);
        
        for(ElixirSuite__Refund__c rec : refundIds){
            if(rec.ElixirSuite__Status__c == 'Requested'){
                string masterTransactionid = masterid.get(rec.id);
                Transactions__c transObj = new Transactions__c();
                transObj.ElixirSuite__Master_Transaction__c = masterTransactionid;
                transObj.ElixirSuite__Amount_Paid__c = rec.ElixirSuite__Refund_Amount__c;
                transObj.ElixirSuite__Payment_DateTime__c = system.now();
                transObj.ElixirSuite__Payment_Received_By__c = 'Patient';
                transObj.ElixirSuite__Type_of_Payment__c = 'Refund';
                if(rec.ElixirSuite__Mode_of_Payment__c == 'Patient Credit'){
                    Master_Transaction__c othertransId = transactionToOtherTransactionMap.get(rec.Id);
                    transObj.ElixirSuite__Other_Transactions__c = othertransId.Id;
                }
                refundIdToTransactionMap.put(rec.Id, transObj);
            }
            
        }
        
        List<Transactions__c> transRecList = new List<Transactions__c>(refundIdToTransactionMap.values());
        DMLManager.insertAsUser(transRecList); 
        
        for (ElixirSuite__Refund__c rec : refundIds) {
            if (refundIdToTransactionMap.containsKey(rec.Id) && rec.ElixirSuite__Status__c == 'Requested') {
                Transactions__c transId = refundIdToTransactionMap.get(rec.Id);
                rec.ElixirSuite__Transactions__c = transId.Id;
                rec.ElixirSuite__Date_Issued__c = Date.today();
                rec.ElixirSuite__Issued_User__c = userId;
                rec.ElixirSuite__Status__c = 'Issued';
            }
            else if(rec.ElixirSuite__Status__c == 'Denied'){
                //For Denied records
                rec.ElixirSuite__Date_Issued__c = Date.today();
                rec.ElixirSuite__Issued_User__c = userId;
            }
            if(rec.ElixirSuite__Mode_of_Payment__c.contains('-')){
                string modeOfPayment =  rec.ElixirSuite__Mode_of_Payment__c.substringBefore('-').trim();
                rec.ElixirSuite__Mode_of_Payment__c = modeOfPayment;
            }
            
        }
        DMLManager.updateAsUser(refundIds); 
            return wrap;
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