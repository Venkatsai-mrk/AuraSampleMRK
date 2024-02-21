public with sharing class UpdatePaymentTransaction {
    
    public static void updateTxn(Id accId, Decimal amountPaid, Decimal amountAllocated, Date payDate, List<Id> payTrans) {
        if(accId != null) {
            if(payTrans.size() > 0 && amountPaid > 0) {
                
                Master_Transaction__c newMasterTxnAllo = new Master_Transaction__c();
                try{
                newMasterTxnAllo.Allocated_Amount__c = amountPaid;
                newMasterTxnAllo.Payment_Type__c = 'Allocated';
                if(Schema.sObjectType.Master_Transaction__c.fields.Allocated_Amount__c.isCreateable() &&
                Schema.sObjectType.Master_Transaction__c.fields.Payment_Type__c.isCreateable()){
                    insert newMasterTxnAllo;
                }
                }
                catch(Exception e){
            ExceptionLog.logError(e);
                   }
                Decimal amtLeftToAllocate = amountPaid;
                List<Payment_Transaction__c> paymentTxnsToInsert = new List<Payment_Transaction__c>();
                
                List<Payment_Transaction__c> paymentTxnsToUpdate =  [Select ElixirSuite__PatientOutstanding__c,
                                                                     Received_Amount__c,
                                                                     Account__c,
                                                                     status__c,
                                                                     Actual_Price__c 
                                                                     from  Payment_Transaction__c 
                                                                     where Id in :PayTrans
                                                                     WITH SECURITY_ENFORCED
                                                                     Order By Date_Of_Service__c];
                
                
                for(Payment_Transaction__c paymentTxnRec : paymentTxnsToUpdate) {
                    if(amtLeftToAllocate > 0) {
                        
                        if(amtLeftToAllocate >= paymentTxnRec.ElixirSuite__PatientOutstanding__c) {
                            
                            Payment_Transaction__c newPaymentTxn = new Payment_Transaction__c();
                            newPaymentTxn.Payment_Date__c = payDate;
                            newPaymentTxn.Received_Amount__c = paymentTxnRec.ElixirSuite__PatientOutstanding__c;
                            newPaymentTxn.Payment_Sub_Transaction__c = paymentTxnRec.Id;
                            newPaymentTxn.Master_Transaction__c = newMasterTxnAllo.Id;
                            paymentTxnsToInsert.add(newPaymentTxn);
                            
                            paymentTxnRec.Received_Amount__c = paymentTxnRec.Received_Amount__c + paymentTxnRec.ElixirSuite__PatientOutstanding__c;
                            paymentTxnRec.Status__c = 'Paid';
                            
                            amtLeftToAllocate = amtLeftToAllocate - newPaymentTxn.Received_Amount__c;
                            
                        } else {
                            
                            Payment_Transaction__c newPaymentTxn = new Payment_Transaction__c();
                            newPaymentTxn.Payment_Date__c = payDate;
                            newPaymentTxn.Received_Amount__c = amtLeftToAllocate;
                            newPaymentTxn.Payment_Sub_Transaction__c = paymentTxnRec.Id;
                            newPaymentTxn.Master_Transaction__c = newMasterTxnAllo.Id;
                            paymentTxnsToInsert.add(newPaymentTxn);
                            
                            paymentTxnRec.Received_Amount__c = paymentTxnRec.Received_Amount__c + amtLeftToAllocate;
                            paymentTxnRec.Status__c = 'Payment Started';
                            
                            amtLeftToAllocate = 0;
                        }
                    }
                    
                }
                
                if(amtLeftToAllocate > 0) {                   
                    Master_Transaction__c newMasterTxnUnallo = new Master_Transaction__c();
                    try{
                    newMasterTxnUnallo.Allocated_Amount__c = amtLeftToAllocate;
                    newMasterTxnUnallo.Payment_Type__c = 'Unallocated';
                    if(Schema.sObjectType.Master_Transaction__c.fields.Allocated_Amount__c.isCreateable() &&
                    Schema.sObjectType.Master_Transaction__c.fields.Payment_Type__c.isCreateable()){
                    insert newMasterTxnUnallo;
                    }
                    }
                    catch(Exception e){
                     ExceptionLog.logError(e);
                          }
                    Account patientAcc = [Select Unallocated_Amount__c FROM Account WHERE ID =:accId WITH SECURITY_ENFORCED];
                    if(Schema.sObjectType.Account.fields.Unallocated_Amount__c.isUpdateable()){
                    patientAcc.Unallocated_Amount__c = patientAcc.Unallocated_Amount__c + newMasterTxnUnallo.Allocated_Amount__c;
                    update patientAcc;
                    }
                }
                
                if(paymentTxnsToInsert.size() > 0) {
                    try{
                    if(Schema.sObjectType.Payment_Transaction__c.fields.Payment_Date__c.isCreateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Received_Amount__c.isCreateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Payment_Sub_Transaction__c.isCreateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Master_Transaction__c.isCreateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Received_Amount__c.isCreateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Status__c.isCreateable()){
                    insert paymentTxnsToInsert;
                    }
                    }
                    catch(Exception e){
                    ExceptionLog.logError(e);
                   }
                }
                try{
                if(paymentTxnsToUpdate.size() > 0) {
                    if(Schema.sObjectType.Payment_Transaction__c.fields.Payment_Date__c.isUpdateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Received_Amount__c.isUpdateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Payment_Sub_Transaction__c.isUpdateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Master_Transaction__c.isUpdateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Received_Amount__c.isUpdateable() &&
                    Schema.sObjectType.Payment_Transaction__c.fields.Status__c.isUpdateable()){
                    update paymentTxnsToUpdate;
                    }
                }
                    
                }
                catch(Exception e){
            ExceptionLog.logError(e);
        }
                
            } else if(payTrans.size() == 0 && amountPaid > 0) {
                
                Master_Transaction__c newMasterTxnUnallo = new Master_Transaction__c();
                newMasterTxnUnallo.Allocated_Amount__c = amountPaid;
                newMasterTxnUnallo.Payment_Type__c = 'Unallocated';
                if(Schema.sObjectType.Master_Transaction__c.fields.Allocated_Amount__c.isCreateable() &&
                Schema.sObjectType.Master_Transaction__c.fields.Payment_Type__c.isCreateable()){
                insert newMasterTxnUnallo;
                }
                
                Account patientAcc = [Select Unallocated_Amount__c FROM Account WHERE ID =:accId WITH SECURITY_ENFORCED];
                if(Schema.sObjectType.Account.fields.Unallocated_Amount__c.isUpdateable()){
                patientAcc.Unallocated_Amount__c = patientAcc.Unallocated_Amount__c + newMasterTxnUnallo.Allocated_Amount__c;
                update patientAcc;
                }
                
            } else if(payTrans.size() > 0 && amountAllocated > 0) {
                
                Master_Transaction__c newMasterTxnAllo = new Master_Transaction__c();
                newMasterTxnAllo.Allocated_Amount__c = amountAllocated;
                newMasterTxnAllo.Payment_Type__c = 'Allocated';
                if(Schema.sObjectType.Master_Transaction__c.fields.Allocated_Amount__c.isCreateable() &&
                Schema.sObjectType.Master_Transaction__c.fields.Payment_Type__c.isCreateable()){
                insert newMasterTxnAllo;
                }
                
                Decimal amtLeftToAllocate = amountAllocated;
                List<Payment_Transaction__c> paymentTxnsToInsert = new List<Payment_Transaction__c>();
                
                List<Payment_Transaction__c> paymentTxnsToUpdate =  [Select ElixirSuite__PatientOutstanding__c,
                                                                     Received_Amount__c,
                                                                     Account__c,
                                                                     status__c,
                                                                     Actual_Price__c 
                                                                     from  Payment_Transaction__c 
                                                                     where Id in :PayTrans
                                                                     WITH SECURITY_ENFORCED
                                                                     Order By Date_Of_Service__c];
                
                
                for(Payment_Transaction__c paymentTxnRec : paymentTxnsToUpdate) {
                    if(amtLeftToAllocate > 0) {
                        
                        if(amtLeftToAllocate >= paymentTxnRec.ElixirSuite__PatientOutstanding__c) {
                            
                            Payment_Transaction__c newPaymentTxn = new Payment_Transaction__c();
                            newPaymentTxn.Payment_Date__c = payDate;
                            newPaymentTxn.Received_Amount__c = paymentTxnRec.ElixirSuite__PatientOutstanding__c;
                            newPaymentTxn.Payment_Sub_Transaction__c = paymentTxnRec.Id;
                            newPaymentTxn.Master_Transaction__c = newMasterTxnAllo.Id;
                            paymentTxnsToInsert.add(newPaymentTxn);
                  
                            paymentTxnRec.Received_Amount__c = paymentTxnRec.Received_Amount__c + paymentTxnRec.ElixirSuite__PatientOutstanding__c;
                            paymentTxnRec.Status__c = 'Paid';
                            
                            amtLeftToAllocate = amtLeftToAllocate - newPaymentTxn.Received_Amount__c;
                            
                        } else {
                            
                            Payment_Transaction__c newPaymentTxn = new Payment_Transaction__c();
                            newPaymentTxn.Payment_Date__c = payDate;
                            newPaymentTxn.Received_Amount__c = amtLeftToAllocate;
                            newPaymentTxn.Payment_Sub_Transaction__c = paymentTxnRec.Id;
                            newPaymentTxn.Master_Transaction__c = newMasterTxnAllo.Id;
                            paymentTxnsToInsert.add(newPaymentTxn);
                            
                            paymentTxnRec.Received_Amount__c = paymentTxnRec.Received_Amount__c + amtLeftToAllocate;
                            paymentTxnRec.Status__c = 'Payment Started';
                            
                            amtLeftToAllocate = 0;
                        }
                    }
                    
                }
                
                Account patientAcc = [Select Unallocated_Amount__c 
                                    FROM Account 
                                    WHERE ID =:accId
                                    WITH SECURITY_ENFORCED];
                if(Schema.sObjectType.Account.fields.Unallocated_Amount__c.isUpdateable()){
                patientAcc.Unallocated_Amount__c = patientAcc.Unallocated_Amount__c - amountAllocated + amtLeftToAllocate;
                update patientAcc;
                }
            }
        }
    }
}