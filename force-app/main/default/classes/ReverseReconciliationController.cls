public with sharing class ReverseReconciliationController {
    
    @AuraEnabled
    public static void reverseReconciliation(String claimLst){
        List<String> procIds = new List<String>();
        List<String> secClaim = new List<String>();
        List<String> claimIdsSet = splitIds(claimLst);
        String payerOrder;
        List<ElixirSuite__Claim__c> updateClaimList = new List<ElixirSuite__Claim__c>();
        List<ElixirSuite__Claim_Line_Items__c> updateClaimLineList = new List<ElixirSuite__Claim_Line_Items__c>();
        List<Transactions__c> updateTransactionList = new List<Transactions__c>();
        List<Transactions__c> insertTransactionList = new List<Transactions__c>();
        List<ElixirSuite__Payment_Transaction__c> updateMasTransactionList = new List<ElixirSuite__Payment_Transaction__c>();
      //  try{
            Schema.DescribeSObjectResult res = ElixirSuite__Claim__c.sObjectType.getDescribe();
            List<String> apiNames =  new List<String>(res.fields.getMap().keySet());
            String query = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNames,','))  + ',ElixirSuite__payor__r.ElixirSuite__Payer_Code__c,ElixirSuite__payor__r.ElixirSuite__Claim_Processing_via__c ' + ' FROM ElixirSuite__Claim__c ';
            query+= 'WHERE Id in: claimIdsSet';
            List<ElixirSuite__Claim__c> AllClaims = (List<ElixirSuite__Claim__c>)Database.query(query);
            
            List<Claim__c> secExistingClaim = [Select id, Name, ElixirSuite__Claim__c From ElixirSuite__Claim__c where ElixirSuite__Claim__c IN:AllClaims WITH SECURITY_ENFORCED];
            
            for(ElixirSuite__Claim__c cl:secExistingClaim){
                secClaim .add(cl.ElixirSuite__Claim__c); 
            }
            
            for(ElixirSuite__Claim__c obj:AllClaims){
                if(!secClaim.isEmpty() && secClaim != null && secClaim.contains(obj.Id)){
                    throw new AuraHandledException('Can not reverse the reconciliation for a claim which has a secondary claim attached.');  
                }
                payerOrder = obj.ElixirSuite__Payer_Order__c;
                obj.ElixirSuite__Amount_Paid__c = 0;
                obj.ElixirSuite__Primary_Patient_Responsibility__c = 0;
                obj.ElixirSuite__Primary_Allowed__c = 0;
                obj.ElixirSuite__Primary_Paid__c = 0;
                obj.ElixirSuite__Primary_Adjustment__c = 0;
                obj.ElixirSuite__Total_Paid__c = 0;
                obj.ElixirSuite__Total_Patient_Responsibility_Primary__c = 0;
                obj.ElixirSuite__Total_Adjustment__c = 0;
                updateClaimList.add(obj);
            }
            
            Schema.DescribeSObjectResult res1 = ElixirSuite__Claim_Line_Items__c.sObjectType.getDescribe();
            List<String> apiNames1 =  new List<String>(res1.fields.getMap().keySet());
            String query1 = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNames1,',')) + ' FROM ElixirSuite__Claim_Line_Items__c ';
            query1+= 'WHERE ElixirSuite__Claim__c IN :claimIdsSet ';
            List<ElixirSuite__Claim_Line_Items__c> claimLineItemList = (List<ElixirSuite__Claim_Line_Items__c>)Database.query(query1);
            for(ElixirSuite__Claim_Line_Items__c obj:claimLineItemList){
                procIds.add(obj.ElixirSuite__Procedure__c);
                
                obj.ElixirSuite__Primary_Allowed__c = 0;
                obj.ElixirSuite__Primary_Paid__c = 0;
                obj.ElixirSuite__Primary_Patient_Responsibility__c = 0;
                obj.ElixirSuite__Primary_Adjustment__c = 0;
                obj.ElixirSuite__Total_Paid__c = 0;
                obj.ElixirSuite__Total_Patient_Responsibility__c = 0;
                obj.ElixirSuite__Total_Adjustment__c = 0;
                updateClaimLineList.add(obj);
            }
            
            Map<Id,ElixirSuite__Payment_Transaction__c> masterIdVsMasterRec = new Map<Id,ElixirSuite__Payment_Transaction__c>([SELECT Id,
                                                                                                                               ElixirSuite__Procedure__c,
                                                                                                                               ElixirSuite__Total_Patient_Refund__c,
                                                                                                                               ElixirSuite__Expected_Receivable_amount__c,
                                                                                                                               ElixirSuite__Total_Paid_Amount__c,
                                                                                                                               ElixirSuite__PatientOutstanding__c,
                                                                                                                               ElixirSuite__Account__c,
                                                                                                                               ElixirSuite__Insurance_Paid__c,
                                                                                                                               ElixirSuite__Patient_Responsibility__c,
                                                                                                                               ElixirSuite__Total_Adjustment_Amount__c,
                                                                                                                               ElixirSuite__Actual_Price__c
                                                                                                                               FROM ElixirSuite__Payment_Transaction__c
                                                                                                                               WHERE ElixirSuite__Procedure__c IN :procIds
                                                                                                                               WITH SECURITY_ENFORCED]);
            List<Transactions__c> transactionList = new  List<Transactions__c>();
            if(payerOrder == 'Secondary'){
                
                transactionList = [SELECT id,name,ElixirSuite__Amount_Paid__c,ElixirSuite__Master_Transaction__c,ElixirSuite__Payment_Received_By__c,
                                   ElixirSuite__Type_of_Payment__c,ElixirSuite__Reverse_Reconciliation__c
                                   FROM ElixirSuite__Transactions__c
                                   WHERE ElixirSuite__Master_Transaction__c IN :masterIdVsMasterRec.Keyset()
                                   AND (ElixirSuite__Type_of_Payment__c ='Adjustment'
                                        OR ElixirSuite__Type_of_Payment__c ='Payment') AND ElixirSuite__Reverse_Reconciliation__c = FALSE AND ElixirSuite__Payment_Received_By__c = 'Secondary Insurance'
                                   WITH SECURITY_ENFORCED ORDER BY CreatedDate];
                
            }else{
                transactionList = [SELECT id,name,ElixirSuite__Amount_Paid__c,ElixirSuite__Master_Transaction__c,ElixirSuite__Payment_Received_By__c,
                                   ElixirSuite__Type_of_Payment__c,ElixirSuite__Reverse_Reconciliation__c
                                   FROM ElixirSuite__Transactions__c
                                   WHERE ElixirSuite__Master_Transaction__c IN :masterIdVsMasterRec.Keyset()
                                   AND (ElixirSuite__Type_of_Payment__c ='Adjustment'
                                        OR ElixirSuite__Type_of_Payment__c ='Payment') AND ElixirSuite__Reverse_Reconciliation__c = FALSE AND ElixirSuite__Payment_Received_By__c != 'Patient'
                                   WITH SECURITY_ENFORCED ORDER BY CreatedDate];
            }
            
            if(transactionList.size() > 0){
                
                for(ElixirSuite__Payment_Transaction__c mt:masterIdVsMasterRec.values()){
                    mt.ElixirSuite__Patient_Responsibility__c = 0;
                    updateMasTransactionList.add(mt);
                }
                
                for(Transactions__c tran:transactionList){
                    
                    tran.ElixirSuite__Reverse_Reconciliation__c = true;
                    Transactions__c tr = new Transactions__c();
                    tr.ElixirSuite__Master_Transaction__c = tran.ElixirSuite__Master_Transaction__c;
                    tr.ElixirSuite__Payment_DateTime__c = Date.Today();
                    tr.ElixirSuite__Payment_Received_By__c = tran.ElixirSuite__Payment_Received_By__c;
                    tr.ElixirSuite__Reverse_Reconciliation__c = true;
                    if(tr.ElixirSuite__Amount_Paid__c != null){
                    tr.ElixirSuite__Amount_Paid__c = -(tran.ElixirSuite__Amount_Paid__c);
                    }
                    if(tran.ElixirSuite__Type_of_Payment__c == 'Payment'){
                        tr.ElixirSuite__Type_of_Payment__c = 'Payment Reversal';  
                    }else if(tran.ElixirSuite__Type_of_Payment__c == 'Adjustment'){
                        tr.ElixirSuite__Type_of_Payment__c = 'Adjustment Reversal';    
                    }
                    insertTransactionList.add(tr);
                    updateTransactionList.add(tran);
                }
                
                if(updateClaimList != null && updateClaimList.size() > 0){
                    DMLManager.updateAsUser(updateClaimList);
                }
                if(updateClaimLineList != null && updateClaimLineList.size() > 0){
                    DMLManager.updateAsUser(updateClaimLineList);
                }
                if(updateMasTransactionList != null && updateMasTransactionList.size() > 0){
                    DMLManager.updateAsUser(updateMasTransactionList);
                }
                if(updateTransactionList != null && updateTransactionList.size() > 0){
                    DMLManager.updateAsUser(updateTransactionList);
                }
                if(insertTransactionList != null && insertTransactionList.size() > 0){
                    DMLManager.insertAsUser(insertTransactionList);
                }
                
            }else{
                throw new AuraHandledException('Reconciliation has already been reversed.');
            }
     /*   }catch(Exception e){
            ExceptionLog.logError(e);
        }  */
        
    }
    public static List<String> splitIds(String claims){
        List<String> listOfClaims = new List<String>();
        try{
            for(String lineItemId : claims.split(',')){
                listOfClaims.add(lineItemId.trim());
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return listOfClaims;
    }
    
}