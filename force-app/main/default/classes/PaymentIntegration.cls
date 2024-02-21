global class PaymentIntegration implements Callable {
    
    global Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'InsurancePayment' {
                MessageWrapper1  wrp = insurancePaymentIntegration2((Decimal)args.get('amountPaid'),(String)args.get('modeOfPayment'),(Date)args.get('dateOfPmt'),
                                                                    (String)args.get('reasonForPayment'),(String)args.get('note'),(String)args.get('pmtTransactionNumber'),
                                                                    (String)args.get('acctId'), (String)args.get('selectedProcedureRecords'), (Decimal)args.get('totalAppliedAmount'),
                                                                    (Decimal)args.get('totalUnAllocatedAmount'),(Boolean)args.get('noProcedureSelected'),(String)args.get('paymentInfoId'),
                                                                    (String)args.get('chequeNo'));
                return wrp ;  
            }
            when 'AllocateInsurancePayment' {
                allocateInsurancePaymentIntegration((Decimal)args.get('amountPaid'),(String)args.get('acctId'), (String)args.get('selectedProcedureRecords'), 
                                                    (Decimal)args.get('totalAppliedAmount'),(Decimal)args.get('totalRemainingUnAllocatedAmt'));
                return null;
            }
            when 'PrivatePayment' {
                MessageWrapper1  wrp =   privatePaymentIntegration2((Decimal)args.get('amountPaid'),(String)args.get('modeOfPayment'),(Date)args.get('dateOfPmt'),
                                                                    (String)args.get('pmtTransactionNumber'),(String)args.get('acctId'), (String)args.get('selectedProcedureRecords'), 
                                                                    (Decimal)args.get('totalAppliedAmount'),(Decimal)args.get('totalUnAllocatedAmount'),(Boolean)args.get('noProcedureSelected'),
                                                                    (String)args.get('paymentInfoId'),(String)args.get('chequeNo'));
                return wrp ;  
            }
            when 'AllocatePrivatePayment' {
                allocatePrivatePaymentIntegration((Decimal)args.get('amountAllocated'),(String)args.get('modeOfPayment'),(Date)args.get('dateOfPmt'),
                                                  (String)args.get('pmtTransactionNumber'),(String)args.get('acctId'), (String)args.get('selectedProcedureRecords'), 
                                                  (Decimal)args.get('totalAppliedAmount'),(Decimal)args.get('totalUnAllocatedAmount'),(Boolean)args.get('noProcedureSelected'),
                                                  (Decimal)args.get('totalUnallocatedAmt'),(String)args.get('paymentInfoId'),(String)args.get('chequeNo'));
                return null ;  
            }
            when 'SchedulePrivatePayment' {
                MessageWrapper1  wrp = schedulePrivatePaymentIntegration2((Decimal)args.get('amountPaid'),(Decimal)args.get('amountPaidCopy'),(String)args.get('modeOfPayment'),(Date)args.get('dateOfPmt'),
                                                                          (String)args.get('pmtTransactionNumber'),(String)args.get('acctId'), (String)args.get('selectedProcedureRecords'), 
                                                                          (Decimal)args.get('totalAppliedAmount'),(Decimal)args.get('totalUnAllocatedAmount'),(Boolean)args.get('noProcedureSelected'),
                                                                          (Decimal)args.get('totalUnallocatedAmt'),(String)args.get('selectedParentScheduleId'),(String)args.get('paymentInfoId'),(String)args.get('chequeNo'));
                return wrp ;  
            }
            when 'AddDiscountPrivatePayment' {
                addDiscountPrivatePaymentIntegration((ElixirSuite__Master_Transaction__c)args.get('otherTransaction'),(String)args.get('acctId'), (String)args.get('selectedProcedureRecords'), 
                                                     (Decimal)args.get('totalUnAllocatedDiscount'),(Decimal)args.get('appliedDiscount'),(String)args.get('DiscountCode'),(String)args.get('Notes'));
                return null;
            }
            when 'AllocateDiscountPrivatePayment' {
                allocateDiscountPrivatePaymentIntegration((ElixirSuite__Master_Transaction__c)args.get('otherTransaction'),(String)args.get('discountType'),(String)args.get('acctId'), (String)args.get('selectedProcedureRecords'), 
                                                          (Decimal)args.get('totalUnAllocatedDiscount'),(Decimal)args.get('appliedDiscount'),(String)args.get('discountTableId'));
                return null;
            }
            when 'CreateRefundRequest' {
                createRefundRequestIntegration((String)args.get('itemListJson'));
                return null;
            }
            when 'ProcessRefund' {
                MessageWrapper1  wrp = processRefundIntegration1((String)args.get('accid'),(List<ElixirSuite__Refund__c>)args.get('refundIds'));
                return wrp;
            }
            when else {
                throw new ExtensionMalformedCallException('Method not implemented');
            }
        }
    }
    
    global class ExtensionMalformedCallException extends Exception {}
    
    @deprecated
    global static MessageWrapper processRefundIntegration(string accid,List<ElixirSuite__Refund__c> refundIds){
        MessageWrapper wrap = new MessageWrapper();
        return wrap;
        
    }
    
    @deprecated
    global static void privatePaymentIntegration(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                                 String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                 Decimal totalUnAllocatedAmount,Boolean noProcedureSelected, string paymentInfoId, string chequeNo){}
    
    @deprecated
    global static MessageWrapper privatePaymentIntegration1(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                                            String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                            Decimal totalUnAllocatedAmount,Boolean noProcedureSelected, string paymentInfoId, string chequeNo){
                                                                
                                                                MessageWrapper wrap;
                                                                if(paymentInfoId == ''){
                                                                    wrap = new MessageWrapper();
                                                                }
                                                                else{
                                                                    wrap = new MessageWrapper();
                                                                }
                                                                return wrap;
                                                                
                                                            }
    
    @deprecated
    global static void schedulePrivatePaymentIntegration(Decimal amountPaid,Decimal amountPaidCopy , String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                                         String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                         Decimal totalUnAllocatedAmount,Boolean noProcedureSelected,Decimal totalUnallocatedAmt,
                                                         String selectedParentScheduleId, string paymentInfoId, string chequeNo){}
    @deprecated
    global static MessageWrapper schedulePrivatePaymentIntegration1(Decimal amountPaid,Decimal amountPaidCopy , String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                                                    String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                                    Decimal totalUnAllocatedAmount,Boolean noProcedureSelected,Decimal totalUnallocatedAmt,
                                                                    String selectedParentScheduleId, string paymentInfoId, string chequeNo){
                                                                        
                                                                        MessageWrapper wrap;
                                                                        if(paymentInfoId == ''){
                                                                            wrap = new MessageWrapper();
                                                                        }
                                                                        else{
                                                                            wrap = new MessageWrapper();
                                                                        }
                                                                        return wrap;
                                                                        
                                                                    }
    
    @deprecated
    global static void insurancePaymentIntegration(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String reasonForPayment,String note,String pmtTransactionNumber,
                                                   String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                   Decimal totalUnAllocatedAmount,Boolean noProcedureSelected, string paymentInfoId, string chequeNo){}
    @deprecated
    global static MessageWrapper insurancePaymentIntegration1(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String reasonForPayment,String note,String pmtTransactionNumber,
                                                              String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                              Decimal totalUnAllocatedAmount,Boolean noProcedureSelected, string paymentInfoId, string chequeNo){
                                                                  
                                                                  MessageWrapper wrap;
                                                                  if(paymentInfoId == ''){
                                                                      wrap = new MessageWrapper();
                                                                  }
                                                                  else{
                                                                      wrap = new MessageWrapper();
                                                                  }
                                                                  return wrap;
                                                                  
                                                              }
    
    global static MessageWrapper1 insurancePaymentIntegration2(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String reasonForPayment,String note,String pmtTransactionNumber,
                                                               String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                               Decimal totalUnAllocatedAmount,Boolean noProcedureSelected, string paymentInfoId, string chequeNo){
                                                                   
                                                                   MessageWrapper1 wrap;
                                                                   if(paymentInfoId == ''){
                                                                       wrap = new MessageWrapper1('URL','');
                                                                   }
                                                                   else{
                                                                       wrap = new MessageWrapper1('Success','');
                                                                   }
                                                                   return wrap;
                                                                   
                                                               }
    
    global static void allocateInsurancePaymentIntegration(Decimal amountPaid,String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                           Decimal totalRemainingUnAllocatedAmt){
                                                               
                                                           }
    
    global static MessageWrapper1 privatePaymentIntegration2(Decimal amountPaid,String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                                             String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                             Decimal totalUnAllocatedAmount,Boolean noProcedureSelected, string paymentInfoId, string chequeNo){
                                                                 
                                                                 MessageWrapper1 wrap;
                                                                 if(paymentInfoId == ''){
                                                                     wrap = new MessageWrapper1('URL','');
                                                                 }
                                                                 else{
                                                                     wrap = new MessageWrapper1('Success','');
                                                                 }
                                                                 return wrap;
                                                                 
                                                             }
    
    global static void allocatePrivatePaymentIntegration(Decimal amountAllocated,String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                                         String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                         Decimal totalUnAllocatedAmount,Boolean noProcedureSelected,Decimal totalUnallocatedAmt, string paymentInfoId, string chequeNo){
                                                             
                                                         }
    
    
    global static MessageWrapper1 schedulePrivatePaymentIntegration2(Decimal amountPaid,Decimal amountPaidCopy , String modeOfPayment,Date dateOfPmt,String pmtTransactionNumber,
                                                                     String acctId,String selectedProcedureRecords,Decimal totalAppliedAmount,
                                                                     Decimal totalUnAllocatedAmount,Boolean noProcedureSelected,Decimal totalUnallocatedAmt,
                                                                     String selectedParentScheduleId, string paymentInfoId, string chequeNo){
                                                                         System.debug('success');
                                                                         MessageWrapper1 wrap;
                                                                         if(paymentInfoId == ''){
                                                                             wrap = new MessageWrapper1('URL','');
                                                                         }
                                                                         else{
                                                                             wrap = new MessageWrapper1('Success','');
                                                                         }
                                                                         return wrap;
                                                                         
                                                                     }
    
    global static void addDiscountPrivatePaymentIntegration(ElixirSuite__Master_Transaction__c otherTransaction,String acctId,String selectedProcedureRecords,
                                                            Decimal totalUnAllocatedDiscount, decimal appliedDiscount, string DiscountCode, string Notes){
                                                                
                                                            }
    global static void allocateDiscountPrivatePaymentIntegration(ElixirSuite__Master_Transaction__c otherTransaction, string discountType,
                                                                 String acctId,String selectedProcedureRecords,Decimal totalUnAllocatedDiscount, 
                                                                 decimal appliedDiscount, string discountTableId){
                                                                     
                                                                 }
    global static void createRefundRequestIntegration(string itemListJson){
        
    }
    
    global static MessageWrapper1 processRefundIntegration1(string accid,List<ElixirSuite__Refund__c> refundIds){
        MessageWrapper1 wrap = new MessageWrapper1('Success','Refund processed successfully');
        return wrap;
        
    }
    
    @deprecated
    global class MessageWrapper{
        @AuraEnabled
        global String msgState;
        @AuraEnabled
        global String msgStr;
        
    }
    
    global class MessageWrapper1{
        @AuraEnabled
        global String msgState;
        @AuraEnabled
        global String msgStr;
        
        global MessageWrapper1(String msgState, String msgStr){
            this.msgState = msgState;
            this.msgStr = msgStr;
        }
        
    }
    
    
}