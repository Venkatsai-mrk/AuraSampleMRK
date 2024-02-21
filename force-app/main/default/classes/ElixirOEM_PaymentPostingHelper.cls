public with sharing class ElixirOEM_PaymentPostingHelper {
    public static void postPaymentUtility( ElixirSuite__EOB__c[] sObjArrToPost, ElixirOEM_AddEraHelper.ParentERADataWrapper flow_sObj,
                                          Map<String,Object> mapOfsObjToJSON)
    { 
        Map<String,String> mapOfChildERAAndOtherTransaction = new Map<String,String> ();
        ElixirSuite__Master_Transaction__c[] otherTrasnactionLstForChildERA = new List<ElixirSuite__Master_Transaction__c>();
        Set<String> eobId = new  Set<String>();
        Map<String,String> idNameMap = generateNameMap(sObjArrToPost);
        try{
        for(ElixirSuite__EOB__c obj : sObjArrToPost){
            eobId.add(obj.Id);
            String clmNumber = '';
            if(mapOfsObjToJSON.size()>0){
                clmNumber  = fetchSFObjectFromFluffy(mapOfsObjToJSON,obj.ElixirSuite__Line_Items_Reference_Key__c,'ClaimNumber');
            }
            else {
                clmNumber =  obj.ElixirSuite__Claim__r.Name;
            }
            String name  = '';
            if(idNameMap.containsKey(obj.Id)){
                name = idNameMap.get(obj.Id);
            }
            if(obj.ElixirSuite__Net_Paid_Amt__c!=null && obj.ElixirSuite__Total_Paid__c!=null)
            {
                Decimal intrstOrLateFilingCharges = obj.ElixirSuite__Net_Paid_Amt__c - obj.ElixirSuite__Total_Paid__c;
                if(intrstOrLateFilingCharges != 0 ){
                    ElixirSuite__Master_Transaction__c otherTransaction = new ElixirSuite__Master_Transaction__c(
                        ElixirSuite__Account__c = obj.ElixirSuite__Account__c,
                        ElixirSuite__Allocated_Amount__c = 0,
                        ElixirSuite__Reason_Of_Payment__c  = 'Interest/Late Filing Charges',          
                        ElixirSuite__Payment_Notes__c = flow_sObj.parentERAHash + name  + clmNumber,
                        ElixirSuite__Mode_of_Payment__c = flow_sObj.paymentMethod,
                        ElixirSuite__Payment_Received_By__c = 'Insurance',
                        ElixirSuite__Transaction_Date__c = System.today(),
                        ElixirSuite__Total_Amount_Paid__c = intrstOrLateFilingCharges,                                              
                        ElixirSuite__Interest_Late_Filling_Charges__c = intrstOrLateFilingCharges
                    ); 
                    otherTrasnactionLstForChildERA.add(otherTransaction);
                }
            } 
            ElixirSuite__Master_Transaction__c otherTransactionStatic = new ElixirSuite__Master_Transaction__c(
                ElixirSuite__Account__c = obj.ElixirSuite__Account__c,
                ElixirSuite__Allocated_Amount__c = obj.ElixirSuite__Total_Paid__c,
                ElixirSuite__Reason_Of_Payment__c  = 'ERA/EOB Payment',          
                ElixirSuite__Payment_Notes__c = flow_sObj.parentERAHash  + name + clmNumber,
                ElixirSuite__Mode_of_Payment__c = flow_sObj.paymentMethod,
                ElixirSuite__Payment_Received_By__c = 'Insurance',
                ElixirSuite__Transaction_Date__c = System.today(),
                ElixirSuite__Total_Amount_Paid__c = obj.ElixirSuite__Total_Paid__c,
                ElixirSuite__Refrence_Key__c = obj.Id
            ); 
            otherTrasnactionLstForChildERA.add(otherTransactionStatic); 
        }
        if(Schema.sObjectType.ElixirSuite__Master_Transaction__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Account__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Allocated_Amount__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Payment_Notes__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Mode_of_Payment__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Payment_Received_By__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Transaction_Date__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Total_Amount_Paid__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Refrence_Key__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Reason_Of_Payment__c.isCreateable() &&	
             Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Interest_Late_Filling_Charges__c.isCreateable()){	
    
        insert otherTrasnactionLstForChildERA;
        }
        createPaymentTransactionForERALineItem(queryAllERALineItems(eobId),mapOfChildERAAndOtherTransaction);
    }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    
    public static  Map<String,String> generateNameMap( ElixirSuite__EOB__c[] sObjArrToPost){       
        Set<Id> allRecId = new Set<Id>();
        for(ElixirSuite__EOB__c eob : sObjArrToPost){
            allRecId.add(eob.Id);
        }
        ElixirSuite__EOB__c[] dbFreshRecords = [SELECT Name FROM ElixirSuite__EOB__c WHERE ID IN : allRecId WITH SECURITY_ENFORCED];
        Map<String,String> idNameMap = new Map<String,String>();
        for(ElixirSuite__EOB__c eob : dbFreshRecords){
            idNameMap.put(eob.Id,eob.Name);
        }
        return idNameMap;
    }
    public static Map<String,String> createMapOfChildERAAndOtherTransaction(ElixirSuite__Master_Transaction__c[] otherTrasnactionLstForChildERA)
    {
       
        Map<String,String> mapOfChildERAAndOtherTransaction = new  Map<String,String> ();
        try{
        for(ElixirSuite__Master_Transaction__c mt : otherTrasnactionLstForChildERA){
            mapOfChildERAAndOtherTransaction.put(mt.ElixirSuite__Refrence_Key__c,mt.Id);
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return mapOfChildERAAndOtherTransaction;
    }
    public static String fetchSFObjectFromFluffy(Map<String,Object> mapOfsObjToJSON,String lineItemRefKey,String keyToFetch){
        Object obj = mapOfsObjToJSON.get(lineItemRefKey);
        Map<String, Object> mapOfChildEraData = (Map<String, Object>) obj;
        return String.valueOf(mapOfChildEraData.get(keyToFetch));
    }
    public static void createPaymentTransactionForERALineItem(ElixirSuite__ERA_Line_Item__c[] sucessInsertERALineItem,
                                                              Map<String,String> mapOfChildERAAndOtherTransaction
                                                             )
    {
        ElixirSuite__Transactions__c[] toInsertTransaction = new List<ElixirSuite__Transactions__c>();
        Set<String> cliIdSet = new Set<String>();
        try{
        for(ElixirSuite__ERA_Line_Item__c collectsObj : sucessInsertERALineItem){
            cliIdSet.add(collectsObj.ElixirSuite__Claim_Line_Items__c);
        }
        ElixirSuite__Claim_Line_Items__c[] cliLst = [SELECT ID,ElixirSuite__Primary_Patient_Responsibility__c,ElixirSuite__Procedure__c FROM ElixirSuite__Claim_Line_Items__c WHERE ID IN : cliIdSet WITH SECURITY_ENFORCED];
        Map<String,String> cliProcMap = new Map<String,String>();
        for(ElixirSuite__Claim_Line_Items__c cl : cliLst){
            cliProcMap.put(cl.Id,cl.ElixirSuite__Procedure__c);
        }
        Map<ID, ElixirSuite__Procedure__c> allProc = new Map<ID, ElixirSuite__Procedure__c>([SELECT ID FROM ElixirSuite__Procedure__c WHERE ID IN : cliProcMap.values()]);      
        ElixirSuite__Payment_Transaction__c[] masterTrlst = [SELECT ID,ElixirSuite__Procedure__c FROM ElixirSuite__Payment_Transaction__c WHERE ElixirSuite__Procedure__c
                                                             IN : allProc.keySet() WITH SECURITY_ENFORCED ORDER BY CREATEDDATE DESC];
        
        Map<String,String> procTranMap = new Map<String,String>();
        for(ElixirSuite__Payment_Transaction__c masterTrObj : masterTrlst){
            procTranMap.put(masterTrObj.ElixirSuite__Procedure__c,masterTrObj.Id);
        }
        Set<Id> toUpdateMasterTranLst = new Set<Id>();
        for(ElixirSuite__ERA_Line_Item__c sObj : sucessInsertERALineItem){
            String masterTranId = procTranMap.get(cliProcMap.get(sObj.ElixirSuite__Claim_Line_Items__c));
            if(String.isNotBlank(masterTranId)){
                toUpdateMasterTranLst.add(procTranMap.get(cliProcMap.get(sObj.ElixirSuite__Claim_Line_Items__c)));
                if(sObj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Claim__r.ElixirSuite__Posted__c){
                   
                    ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = sObj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Total_Billed__c - sObj.ElixirSuite__Paid__c,                                                                                        
                                                                                                   ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                   ElixirSuite__Master_Transaction__c = masterTranId ,
                                                                                                   ElixirSuite__Other_Transactions__c = mapOfChildERAAndOtherTransaction.get(sObj.ElixirSuite__EOB__c),
                                                                                                   ElixirSuite__Type_of_Payment__c = 'Payment');  
                    if(sObj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c == 'Secondary'){
                        transactionRec.ElixirSuite__Payment_Received_By__c='Secondary Insurance';
                    }else{
                        transactionRec.ElixirSuite__Payment_Received_By__c='Insurance';      
                    }
                    toInsertTransaction.add(transactionRec);
                    if(sObj.ElixirSuite__EOB__r.ElixirSuite__Action_to_be_Taken__c != 'Transfer to Patient' || sObj.ElixirSuite__EOB__r.ElixirSuite__Action_to_be_Taken__c != 'Transfer to Secondary'){
                        
                        ElixirSuite__Transactions__c transactionRec1 = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = sObj.ElixirSuite__Provider_Adjustment__c,                                                                                        
                                                                                                   ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                   ElixirSuite__Type_of_Payment__c='Adjustment',
                                                                                                   ElixirSuite__Master_Transaction__c = masterTranId ,
                                                                                                   ElixirSuite__Other_Transactions__c = mapOfChildERAAndOtherTransaction.get(sObj.ElixirSuite__EOB__c));
                       if(sObj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c == 'Secondary'){
                            transactionRec1.ElixirSuite__Payment_Received_By__c='Secondary Insurance';
                        }else{
                       		 transactionRec1.ElixirSuite__Payment_Received_By__c='Insurance';      
                    }
                        toInsertTransaction.add(transactionRec1);
                        
                    }
                    
                }else{
                    ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = sObj.ElixirSuite__Paid__c,                                                                                        
                                                                                                   ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                   ElixirSuite__Master_Transaction__c = masterTranId ,
                                                                                                   ElixirSuite__Other_Transactions__c = mapOfChildERAAndOtherTransaction.get(sObj.ElixirSuite__EOB__c),
                                                                                                   ElixirSuite__Type_of_Payment__c = 'Payment');  
                    if(sObj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c == 'Secondary'){
                        transactionRec.ElixirSuite__Payment_Received_By__c='Secondary Insurance';
                    }else{
                        transactionRec.ElixirSuite__Payment_Received_By__c='Insurance';      
                    }
                    toInsertTransaction.add(transactionRec);
                    
                    if(sObj.ElixirSuite__EOB__r.ElixirSuite__Action_to_be_Taken__c != 'Transfer to Patient' || sObj.ElixirSuite__EOB__r.ElixirSuite__Action_to_be_Taken__c != 'Transfer to Secondary'){
                        
                        ElixirSuite__Transactions__c transactionRec1 = new ElixirSuite__Transactions__c(ElixirSuite__Amount_Paid__c = sObj.ElixirSuite__Provider_Adjustment__c,                                                                                        
                                                                                                   ElixirSuite__Payment_DateTime__c = System.now(),
                                                                                                   ElixirSuite__Type_of_Payment__c='Adjustment',
                                                                                                   ElixirSuite__Master_Transaction__c = masterTranId ,
                                                                                                   ElixirSuite__Other_Transactions__c = mapOfChildERAAndOtherTransaction.get(sObj.ElixirSuite__EOB__c));
                       if(sObj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c == 'Secondary'){
                            transactionRec1.ElixirSuite__Payment_Received_By__c='Secondary Insurance';
                        }else{
                            transactionRec1.ElixirSuite__Payment_Received_By__c='Insurance';      
                    }
                        toInsertTransaction.add(transactionRec1);
                        
                    }
                }
            }
            }
            if(Schema.sObjectType.ElixirSuite__Transactions__c.isCreateable()){ 
                DMLManager.insertAsUser(toInsertTransaction);
            }
        updateMasterTranObj(toUpdateMasterTranLst,sucessInsertERALineItem,cliProcMap,procTranMap);
    }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    
    
    public static void updateMasterTranObj(Set<Id> toUpdateMasterTranLst,ElixirSuite__ERA_Line_Item__c[] sucessInsertERALineItem,
                                           Map<String,String> cliProcMap, Map<String,String> procTranMap)
    {
        
        Map<ID, ElixirSuite__Payment_Transaction__c> mstLst = new Map<ID, ElixirSuite__Payment_Transaction__c>([SELECT ID,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__PatientOutstanding__c,ElixirSuite__Posted__c,ElixirSuite__Patient_Responsibility__c,ElixirSuite__Actual_Price__c FROM ElixirSuite__Payment_Transaction__c WHERE ID IN : toUpdateMasterTranLst WITH SECURITY_ENFORCED]); 
        ElixirSuite__Payment_Transaction__c[] toUpdtLst = new List<ElixirSuite__Payment_Transaction__c>();
        try{
        for(ElixirSuite__ERA_Line_Item__c sObj : sucessInsertERALineItem){
            String masterTranId = procTranMap.get(cliProcMap.get(sObj.ElixirSuite__Claim_Line_Items__c));
            if(String.isNotBlank(masterTranId)){
                if(mstLst.containsKey(masterTranId)){
                    ElixirSuite__Payment_Transaction__c obj =   mstLst.get(masterTranId);
                    if(sObj.ElixirSuite__EOB__r.ElixirSuite__Action_to_be_Taken__c == 'Transfer to Patient'){
                    obj.ElixirSuite__Patient_Responsibility__c = sObj.ElixirSuite__Charge__c - sObj.ElixirSuite__Paid__c;    
                    }else if(sObj.ElixirSuite__EOB__r.ElixirSuite__Action_to_be_Taken__c == 'Transfer to Secondary'){
                    obj.ElixirSuite__Patient_Responsibility__c = 0;    
                    }else{
                    obj.ElixirSuite__Patient_Responsibility__c = sObj.ElixirSuite__Patient_Responsibility__c;
                    }
                    obj.ElixirSuite__Posted__c = true;
                    toUpdtLst.add(obj);  
                }
            }
        }
        if(Schema.sObjectType.ElixirSuite__Payment_Transaction__c.isUpdateable() &&	
        Schema.sObjectType.ElixirSuite__Payment_Transaction__c.fields.ElixirSuite__Posted__c.isUpdateable() &&	
        Schema.sObjectType.ElixirSuite__Payment_Transaction__c.fields.ElixirSuite__Patient_Responsibility__c.isUpdateable() &&	
        Schema.sObjectType.ElixirSuite__Payment_Transaction__c.fields.ElixirSuite__Actual_Price__c.isUpdateable()){
        update toUpdtLst;
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    public static void updateClaimPerChildERA(Map<String,Object> claimIdAndObjectMap,ElixirOEM_AddEraHelper.ParentERADataWrapper flow_sObj)                                                            
    {
        ElixirSuite__Claim__c[] allClmToUpdate =  queryAllClaims(claimIdAndObjectMap.keySet());
        Map<String,Object> claimLineItemIdAndObjectMap = new Map<String,Object>(); 
        Map<String,String> claimLineItemActionTaken = new Map<String,String>(); 
        Map<String,String> claimLineItemClaimStatus = new Map<String,String>(); 
        ElixirSuite__Master_Transaction__c[] differenceAmtOTLst = new List<ElixirSuite__Master_Transaction__c>();
        try{
        for(ElixirSuite__Claim__c obj : allClmToUpdate){
            if(claimIdAndObjectMap.containsKey(obj.Id)){
                Object objChildERA = claimIdAndObjectMap.get(obj.Id);
                Map<String, Object> mapOfChildEraData = (Map<String, Object>) objChildERA;
                obj.ElixirSuite__Primary_Billed__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalBilledAmount')));
                obj.ElixirSuite__Primary_Allowed__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalAllowedAmt')));
                if(obj.ElixirSuite__Posted__c){
                     createDifferenceOtherTransaction(differenceAmtOTLst,flow_sObj,obj.ElixirSuite__Primary_Paid__c,
                                                         String.valueOf(mapOfChildEraData.get('patientId')),Decimal.valueOf(String.valueOf(mapOfChildEraData.get('netPaidAmount'))),obj.ElixirSuite__Posted__c);  
                    
                }
                obj.ElixirSuite__Primary_Paid__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                obj.ElixirSuite__Amount_Paid__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                obj.ElixirSuite__Primary_Patient_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_toalPatientResp')));
                
                obj.ElixirSuite__Primary_Other_Insurance_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_totalOtherInsResp')));
                obj.ElixirSuite__Interest_Late_filing_charges__c =   Decimal.valueOf(String.valueOf(mapOfChildEraData.get('netPaidAmount'))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                obj.ElixirSuite__Primary_Adjustment__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalAdjustmentAmt'))); // primary adjustment
                obj.ElixirSuite__Total_Billed__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalBilledAmount')));
                
                obj.ElixirSuite__Total_Paid__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('netPaidAmount')));
                obj.ElixirSuite__Posted__c = true;
                obj.ElixirSuite__Manual_Reconciliation_Count__c += 1;//LX3-10588
                if(String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Adjustment Writeoff' && String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Process as Primary'){
                  
                  obj.ElixirSuite__Total_Patient_Responsibility_Primary__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_toalPatientResp')));
                 if(Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_toalPatientResp'))) != null){
                    obj.ElixirSuite__Total_Adjustment__c = (Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalBilledAmount'))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('netPaidAmount')))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_toalPatientResp')));    
                    }else{
                        obj.ElixirSuite__Total_Adjustment__c = (Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalBilledAmount'))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('netPaidAmount'))));
                  }
                }else if(String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Patient' && String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Process as Primary'){
                  obj.ElixirSuite__Total_Patient_Responsibility_Primary__c = (Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalBilledAmount'))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')))) - (Decimal.valueOf(String.valueOf(mapOfChildEraData.get('netPaidAmount'))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt'))));
                  obj.ElixirSuite__Total_Adjustment__c = (Decimal.valueOf(String.valueOf(mapOfChildEraData.get('netPaidAmount'))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt'))));
                  
                }else if(String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Secondary' && String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Process as Primary'){
                   obj.Claim_Status__c = 'Paid with Patient Responsibility – Ready to submit Secondary Insurance';
                   obj.ElixirSuite__Total_Adjustment__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalAdjustmentAmt')));
                   obj.ElixirSuite__Total_Patient_Responsibility_Primary__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_toalPatientResp')));
                }else if(String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Adjustment Writeoff' && String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Processed as Secondary'){
                    Decimal patientres=0;
                    Decimal adjAmt = 0;
                    patientres = obj.ElixirSuite__Claim__r.ElixirSuite__Primary_Patient_Responsibility__c - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                    
                    if(patientres > 0 || patientres >0.0){
                        obj.ElixirSuite__Primary_Patient_Responsibility__c = patientres;
                        obj.ElixirSuite__Total_Patient_Responsibility_Primary__c = patientres;
                         adjAmt = obj.ElixirSuite__Total_Charge__c - obj.ElixirSuite__Claim__r.ElixirSuite__Primary_Paid__c - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt'))) - patientres;
                    }else{
                        obj.ElixirSuite__Primary_Patient_Responsibility__c = 0;
                        obj.ElixirSuite__Total_Patient_Responsibility_Primary__c = 0; 
                         adjAmt = obj.ElixirSuite__Total_Charge__c - obj.ElixirSuite__Claim__r.ElixirSuite__Primary_Paid__c - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                    }
                    
                   
                    obj.ElixirSuite__Total_Adjustment__c = adjAmt;
                    obj.ElixirSuite__Primary_Adjustment__c = adjAmt;
                }else if(String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Patient' && String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Processed as Secondary'){
                 Decimal patientres=0;
                 patientres = obj.ElixirSuite__Total_Charge__c - obj.ElixirSuite__Claim__r.ElixirSuite__Primary_Paid__c - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                 obj.ElixirSuite__Primary_Patient_Responsibility__c = patientres;
                 obj.ElixirSuite__Total_Patient_Responsibility_Primary__c = patientres;
                 obj.ElixirSuite__Total_Adjustment__c = 0;
                 obj.ElixirSuite__Primary_Adjustment__c = 0;
                }
                deserializeLineItemRecords((List<Object>) mapOfChildEraData.get('lineItemLst'),claimLineItemIdAndObjectMap);
                lineItemRecords((List<Object>) mapOfChildEraData.get('lineItemLst'),claimLineItemActionTaken,String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')));
                claimErastatus((List<Object>) mapOfChildEraData.get('lineItemLst'),claimLineItemClaimStatus,String.valueOf(mapOfChildEraData.get('eraStatusCode')));
                
            }            
        }
        if(Schema.sObjectType.ElixirSuite__Claim__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Primary_Billed__c.isUpdateable() &&	
           Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Primary_Allowed__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Primary_Paid__c.isUpdateable() &&	
           Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Primary_Patient_Responsibility__c.isUpdateable() &&
          Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Primary_Other_Insurance_Responsibility__c.isUpdateable() &&	
          Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Interest_Late_filing_charges__c.isUpdateable() &&	
          Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Primary_Adjustment__c.isUpdateable() &&	
          Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Total_Billed__c.isUpdateable() &&	
          Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Total_Paid__c.isUpdateable() &&	
          Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Total_Patient_Responsibility_Primary__c.isUpdateable() &&	
          Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Total_Adjustment__c.isUpdateable() &&
          Schema.sObjectType.ElixirSuite__Claim__c.fields.ElixirSuite__Posted__c.isUpdateable() ){
              
             update allClmToUpdate;
       
        }
           
        if(differenceAmtOTLst!=null && differenceAmtOTLst.size()>0){
            if(Schema.sObjectType.ElixirSuite__Master_Transaction__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Reason_Of_Payment__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Mode_of_Payment__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Payment_Received_By__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Transaction_Date__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Total_Amount_Paid__c.isCreateable() &&	
            Schema.sObjectType.ElixirSuite__Master_Transaction__c.fields.ElixirSuite__Account__c.isCreateable()){
            insert differenceAmtOTLst;
            }
        }
        }
            catch(Exception e){
        ExceptionLog.logError(e);
        }
        updateClaimLineItemPerChildERALineItem(claimLineItemIdAndObjectMap,claimLineItemActionTaken,claimLineItemClaimStatus);
    }
    public static void createDifferenceOtherTransaction(ElixirSuite__Master_Transaction__c[] differenceAmtOTLst,
                                                        ElixirOEM_AddEraHelper.ParentERADataWrapper flow_sObj,
                                                        Decimal diffAmt,String acctId,Decimal paidAmt,Boolean isPosted)
    {
        if(isPosted){
             ElixirSuite__Master_Transaction__c diffAmtsObj = new ElixirSuite__Master_Transaction__c(
            ElixirSuite__Account__c =  acctId,
            ElixirSuite__Reason_Of_Payment__c  = 'ERA/EOB Payment',          
            ElixirSuite__Mode_of_Payment__c = flow_sObj.paymentMethod,
            ElixirSuite__Payment_Received_By__c = 'Insurance',
            ElixirSuite__Transaction_Date__c = System.today(),
            ElixirSuite__Total_Amount_Paid__c = diffAmt - paidAmt
        ); 
        differenceAmtOTLst.add(diffAmtsObj);
          
        }
    }
    public static Map<String,Object> deserializeLineItemRecords( List<Object> lineItemLstPerChildERA , Map<String,Object> claimLineItemIdAndObjectMap){ 
        
        for(Object lineItemObj : lineItemLstPerChildERA){                     
            Map<String, Object> mapOfChildERALineItem = (Map<String, Object>) lineItemObj;
            claimLineItemIdAndObjectMap.put(String.valueOf(mapOfChildERALineItem.get('claimLineItemId')),lineItemObj);
            
        }
        return claimLineItemIdAndObjectMap;
    }
    public static Map<String,Object> lineItemRecords( List<Object> lineItemLstPerChildERA , Map<String,String> claimLineItemActionTaken, String actionTaken){ 
        
        for(Object lineItemObj : lineItemLstPerChildERA){                     
            Map<String, Object> mapOfChildERALineItem = (Map<String, Object>) lineItemObj;
            claimLineItemActionTaken.put(String.valueOf(mapOfChildERALineItem.get('claimLineItemId')),actionTaken);
        }
        return claimLineItemActionTaken;
    }
    public static Map<String,Object> claimErastatus( List<Object> lineItemLstPerChildERA , Map<String,String> claimLineItemClaimStatus, String eraStatus){ 
        
        for(Object lineItemObj : lineItemLstPerChildERA){                     
            Map<String, Object> mapOfChildERALineItem = (Map<String, Object>) lineItemObj;
            claimLineItemClaimStatus.put(String.valueOf(mapOfChildERALineItem.get('claimLineItemId')),eraStatus);
        }
        return claimLineItemClaimStatus;
    }
    
    public static void updateClaimLineItemPerChildERALineItem(Map<String,Object> claimLineItemIdAndObjectMap, Map<String,String> claimLineItemActionTaken, Map<String,String> claimLineItemClaimStatus)
    {
        ElixirSuite__Claim_Line_Items__c[] allClmLineItemToUpdate =  queryAllClaimsLineItems(claimLineItemIdAndObjectMap.keySet());
Set<ID> procId = new Set<ID>();
        Map<ID, Decimal> procVsPatientResp = new Map<ID, Decimal>();
        try{
        for(ElixirSuite__Claim_Line_Items__c obj : allClmLineItemToUpdate){
            if(claimLineItemIdAndObjectMap.containsKey(obj.Id)){     
               
                Map<String, Object> mapOfChildEraData = (Map<String, Object>) claimLineItemIdAndObjectMap.get(obj.Id);
                obj.ElixirSuite__Primary_Billed__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('billedAmt')));
                obj.ElixirSuite__Primary_Allowed__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('allowedAmt')));
                obj.ElixirSuite__Primary_Paid__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                obj.ElixirSuite__Primary_Patient_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('patientResp')));
                obj.ElixirSuite__Primary_Other_Insurance_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('otherInsuranceResposibility')));
                obj.ElixirSuite__Primary_Adjustment__c =   Decimal.valueOf(String.valueOf(mapOfChildEraData.get('adjustMentAmt')));
                
                obj.ElixirSuite__Total_Billed__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('billedAmt')));
                obj.ElixirSuite__Total_Paid__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                if(claimLineItemClaimStatus.get(obj.Id) == 'Process as Primary' && claimLineItemActionTaken.get(obj.Id) == 'Adjustment Writeoff'){
                obj.ElixirSuite__Total_Patient_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('patientResp')));
                    if(Decimal.valueOf(String.valueOf(mapOfChildEraData.get('patientResp'))) != null){
                        obj.ElixirSuite__Total_Adjustment__c =  (Decimal.valueOf(String.valueOf(mapOfChildEraData.get('billedAmt'))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('patientResp')));
                    }else{
                        obj.ElixirSuite__Total_Adjustment__c =  (Decimal.valueOf(String.valueOf(mapOfChildEraData.get('billedAmt'))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt'))));    
                    }
                }else if(claimLineItemClaimStatus.get(obj.Id) == 'Process as Primary' && claimLineItemActionTaken.get(obj.Id) == 'Transfer to Patient'){
                obj.ElixirSuite__Total_Patient_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('billedAmt'))) - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                obj.ElixirSuite__Total_Adjustment__c = 0;
                }else if(claimLineItemClaimStatus.get(obj.Id) == 'Process as Primary' && claimLineItemActionTaken.get(obj.Id) == 'Transfer to Secondary'){
                obj.ElixirSuite__Total_Patient_Responsibility__c= Decimal.valueOf(String.valueOf(mapOfChildEraData.get('patientResp')));
                obj.ElixirSuite__Total_Adjustment__c= Decimal.valueOf(String.valueOf(mapOfChildEraData.get('adjustMentAmt')));
                }else if(claimLineItemClaimStatus.get(obj.Id) == 'Processed as Secondary' && claimLineItemActionTaken.get(obj.Id) == 'Adjustment Writeoff'){
                    Decimal patientres=0;
                    patientres = obj.ElixirSuite__Claim_Procedure_Line_Item__r.ElixirSuite__Primary_Patient_Responsibility__c - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                    Decimal totalCharge = 0;
                    if(obj.ElixirSuite__Days_Units__c != 0 && obj.ElixirSuite__Days_Units__c != null){
                        totalCharge = obj.ElixirSuite__Days_Units__c * obj.ElixirSuite__Procedure_Charge__c;
                    }else{
                        totalCharge = obj.ElixirSuite__Procedure_Charge__c;   
                    }
                    Decimal adjAmt = 0;
                    if(patientres > 0 || patientres >0.0){
                        obj.ElixirSuite__Primary_Patient_Responsibility__c = patientres;
                        obj.ElixirSuite__Total_Patient_Responsibility__c = patientres;
                        adjAmt = totalCharge - obj.ElixirSuite__Claim_Procedure_Line_Item__r.ElixirSuite__Primary_Paid__c - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt'))) - patientres;
//LX3-10438
                   		procId.add(obj.ElixirSuite__Claim_Procedure_Line_Item__r.ElixirSuite__Procedure__c);
                        procVsPatientResp.put(obj.ElixirSuite__Claim_Procedure_Line_Item__r.ElixirSuite__Procedure__c,patientres);
                    }else{
                        obj.ElixirSuite__Primary_Patient_Responsibility__c = 0;
                        obj.ElixirSuite__Total_Patient_Responsibility__c = 0; 
                        adjAmt = totalCharge - obj.ElixirSuite__Claim_Procedure_Line_Item__r.ElixirSuite__Primary_Paid__c - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                    }
                    
                    
                    obj.ElixirSuite__Total_Adjustment__c = adjAmt;
                    obj.ElixirSuite__Primary_Adjustment__c =  adjAmt;
                }else if(claimLineItemClaimStatus.get(obj.Id) == 'Processed as Secondary' && claimLineItemActionTaken.get(obj.Id) == 'Transfer to Patient'){
                    Decimal patientres=0;
                    Decimal totalCharge = 0;
                    if(obj.ElixirSuite__Days_Units__c != 0 && obj.ElixirSuite__Days_Units__c != null){
                        totalCharge = obj.ElixirSuite__Days_Units__c * obj.ElixirSuite__Procedure_Charge__c;
                    }else{
                        totalCharge = obj.ElixirSuite__Procedure_Charge__c;   
                    }
                    patientres = totalCharge - obj.ElixirSuite__Claim_Procedure_Line_Item__r.ElixirSuite__Primary_Paid__c - Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
                    obj.ElixirSuite__Primary_Patient_Responsibility__c = patientres;
                    obj.ElixirSuite__Total_Patient_Responsibility__c = patientres;
                    obj.ElixirSuite__Total_Adjustment__c = 0;
                    obj.ElixirSuite__Primary_Adjustment__c = 0;
                }
            }           
        }
        if(Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Primary_Billed__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Primary_Allowed__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Primary_Paid__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Primary_Patient_Responsibility__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Primary_Other_Insurance_Responsibility__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Primary_Adjustment__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Total_Billed__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Total_Paid__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Total_Patient_Responsibility__c.isUpdateable() &&
           Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.fields.ElixirSuite__Total_Adjustment__c.isUpdateable()){
               
               update allClmLineItemToUpdate;
        }

        List<ElixirSuite__Payment_Transaction__c> masterRec = [Select id,ElixirSuite__Procedure__c,ElixirSuite__Patient_Responsibility__c,
                                                               ElixirSuite__PatientOutstanding__c,ElixirSuite__Total_Paid_Amount__c
                                                              FROM ElixirSuite__Payment_Transaction__c
                                                              WHERE ElixirSuite__Procedure__c IN :procId
                                                              WITH SECURITY_ENFORCED];
            for(ElixirSuite__Payment_Transaction__c mRec : masterRec){
                Decimal patResp = procVsPatientResp.get(mRec.ElixirSuite__Procedure__c);
                mRec.ElixirSuite__Patient_Responsibility__c = patResp;
                
            }
            if(masterRec != null && masterRec.size()>0){
                DMLManager.updateAsUser(masterRec);
            }
            
            
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    
    public static ElixirSuite__Claim__c[] queryAllClaims(Set<String> existingClaimIds){
        String additionFieldsPrefix = ' WHERE ID IN : existingClaimIds';
        String otherFieldsAddition = ' ,ElixirSuite__Account__r.Name,ElixirSuite__Claim__r.ElixirSuite__Primary_Paid__c,ElixirSuite__Claim__r.ElixirSuite__Primary_Patient_Responsibility__c,ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c,ElixirSuite__Claim__r.ElixirSuite__Posted__c,ElixirSuite__Claim__r.ElixirSuite__Manual_Reconciliation_Count__c'; 
        String clmQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Claim__c',otherFieldsAddition,additionFieldsPrefix+'');
        return Database.query(clmQuery);
    }
    public static ElixirSuite__Claim_Line_Items__c[] queryAllClaimsLineItems(Set<String> existingClaimLineItemIds){
        String additionFieldsPrefix = ' WHERE ID IN : existingClaimLineItemIds';
        String otherFieldsAddition = ' ,ElixirSuite__Claim_Procedure_Line_Item__r.ElixirSuite__Primary_Paid__c,ElixirSuite__Claim_Procedure_Line_Item__r.ElixirSuite__Primary_Patient_Responsibility__c,ElixirSuite__Claim_Procedure_Line_Item__r.ElixirSuite__Procedure__c '; 
        String clmLineItemQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Claim_Line_Items__c',otherFieldsAddition,additionFieldsPrefix+'');
        ElixirOEM_TimelineHelper.mDebugUntruncated(clmLineItemQuery);
        return Database.query(clmLineItemQuery);
    }
    
    public static ElixirSuite__ERA_Line_Item__c[] queryAllERALineItems(Set<String> parentERAIdSet){
        String additionFieldsPrefix = ' WHERE ElixirSuite__EOB__c IN : parentERAIdSet';
        String otherFieldsAddition = ' ,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Claim__r.ElixirSuite__Posted__c,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Total_Billed__c,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Primary_Patient_Responsibility__c,ElixirSuite__EOB__r.ElixirSuite__Action_to_be_Taken__c,ElixirSuite__EOB__r.ElixirSuite__ERA_Status_Code__c,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c '; 
        String eraLineItemQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__ERA_Line_Item__c',otherFieldsAddition,additionFieldsPrefix+'');
      //  ElixirOEM_TimelineHelper.mDebugUntruncated(eraLineItemQuery);
        return Database.query(eraLineItemQuery);
    }
}