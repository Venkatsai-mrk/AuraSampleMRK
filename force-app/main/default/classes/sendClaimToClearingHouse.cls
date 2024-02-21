public with sharing class sendClaimToClearingHouse {
    /*@AuraEnabled
    public static wrapper updateClaim(string claimId){
        
        String messege ;
        Boolean val ;
        
        Claim__c updClaim = [SELECT id, Name,
                             claim_status__c,
                             Account__c, Master_ERA__r.EOB_Id__c, Master_ERA__c
                             FROM Claim__c 
                             WHERE id =: claimId 
                             LIMIT 1];
        
        if(updClaim.Claim_Status__c == 'Generated'){
            updClaim.Claim_Status__c = 'Transmitted';
            update updClaim ;
            val = true ;
        } else { 
            val = false ;
        }
        
        List<Claim_Line_Items__c> relatedClaimLineItemsToCalims = [SELECT ID,
                                                                   Name,
                                                                   Amount_Paid_by_Insurance__c,
                                                                   Total_Adjustment__c,
                                                                   Patient_Responsibility__c,
                                                                   CPT_HCPCS_Code__c,
                                                                   Procedure__c,
                                                                   ERA_Received__c,
                                                                   Days_Units__c, 
                                                                   Total_Allowed_Amount__c 
                                                                   FROM Claim_Line_Items__c
                                                                   WHERE Claim__c = :updClaim.Id];
        ERA_Generation__c eraCS = ERA_Generation__c.getInstance();
        Boolean manualERA = eraCS.Manual_ERA_Posting_Opted__c;
        if(updClaim.Name != 'Claim-0121') //for demo purpose
        
        {
            if(updClaim.Master_ERA__c != null)//Scenario when we have eraId but no related ERA record. ERA generated was either deleted by mistake or some error was encountered while creating ERA record
            {
                if(updClaim.Master_ERA__r.EOB_ID__c != null && updClaim.Master_ERA__r.EOB_ID__c != '')
                {
                    GetERAIDBatch.entryPointOfExecution(null,updClaim.Master_ERA__r.EOB_ID__c);
                } 
            } 
            else //Scenario when there is no related eraId but the User wants to know if ERA has been generated for this claim. 
            {
                List<Integration_Data__c> data = new List<Integration_Data__c>([SELECT Id, ERA_Id__c, ERA_Generated__c, Check_Number__c FROM Integration_Data__c where ERA_Id__c!= null AND ERA_Generated__c = false LIMIT 50000]);
                if(data != null && data.size()>0)
                {
                    GetERAIDBatch.entryPointOfExecution(data[0],data[0].ERA_Id__c);
                }
            }
        }
        if(updClaim.Name == 'Claim-0121' || Test.isRunningTest())
        {
            String jsonInput = '{"result":{"check_number":"1477512601355754957","paid_amount":"800.00","paid_date":"20201201","payer_name":"MEDICARE","payerid":"04402",';
            jsonInput = jsonInput + '"prov_name":"Field Trip","prov_npi":"1234567893",';
            jsonInput = jsonInput + '"claim":[{"ins_number":"328122222D","pcn":"1489971","prov_npi":"1111111112","total_charge":"1200","total_paid":"800",';
            jsonInput = jsonInput + '"charge":[{"charge":"400","chgid":"171529221","from_dos":"20121207","paid":"300","proc_code":"17340","units":"1","allow":"300",';
            jsonInput = jsonInput + '"adjustment":[{"amount":"100","code":"45","group":"CO"},{"amount":"0","code":"","group":""}]},';
            jsonInput = jsonInput + '{"charge":"800","chgid":"171529222","from_dos":"20121207","paid":"500","proc_code":"G0001","units":"1","allow":"500",';
            jsonInput = jsonInput + '"adjustment":[{"amount":"300","code":"45","group":"CO"},{"amount":"0","code":"0","group":"0"}]}]}]}}}';     
            
            List<CustomJSONParser> incomingCreatedData =   CustomJSONParser.parseClass(jsonInput, updClaim.Id );
            
            List<EOB__c> creteEOBs =  incomingCreatedData[0].creteEOBs;
            
            for(EOB__c e : creteEOBs){
                System.debug('created eob '+e);
            }
            
            List<ERA_Line_Item__c> toInsertChilds =  incomingCreatedData[0].creteELIs;
            
            for(ERA_Line_Item__c updateRecords : toInsertChilds){
                for(Claim_Line_Items__c updateRelatedCLIForELI : relatedClaimLineItemsToCalims){
                    if(updateRecords.Proc_code__c == updateRelatedCLIForELI.CPT_HCPCS_Code__c){
                        updateRecords.Claim_Line_Items__c = updateRelatedCLIForELI.Id;
                        updateRelatedCLIForELI.ERA_Received__c = manualERA? false : true;
                        updateRelatedCLIForELI.Total_Allowed_Amount__c = updateRecords.Total_Allowed_Amount__c;
                        updateRelatedCLIForELI.Total_Adjustment__c = updateRecords.Adjustment_Amount_1__c;
                        updateRelatedCLIForELI.Amount_Paid_by_Insurance__c = updateRecords.Paid__c;
                        
                        System.debug('updateRelatedCLIForELI.Total_Adjustment__c----' + updateRelatedCLIForELI.Total_Adjustment__c);
                        System.debug('updateRelatedCLIForELI.Amount_Paid_by_Insurance__c----' + updateRelatedCLIForELI.Amount_Paid_by_Insurance__c);
                    }
                }
            }
            
            
            if(relatedClaimLineItemsToCalims.size() > 0) {
                update relatedClaimLineItemsToCalims;
            }
            
            if(toInsertChilds.size() > 0) {
                upsert toInsertChilds; 
            }
			
			if(manualERA == false)            
            {
                List<Id> procedureIds = new List<Id>();
                Map<Id,Claim_Line_Items__c> recordCLI = new Map<Id,Claim_Line_Items__c>();
                
                for(Claim_Line_Items__c addPaymentMethod : relatedClaimLineItemsToCalims){
                    if(addPaymentMethod.ERA_Received__c){
                        
                        procedureIds.add(addPaymentMethod.Procedure__c);
                        recordCLI.put(addPaymentMethod.Procedure__c,addPaymentMethod);
                        
                    }
                }
                
                List<Claim_Line_Items__c> CLItoBeUpdatedDup = [SELECT ID,
                                                               Name,
                                                               Amount_Paid_by_Insurance__c,
                                                               Total_Adjustment__c,
                                                               Patient_Responsibility__c,
                                                               CPT_HCPCS_Code__c,Procedure__c,
                                                               ERA_Received__c,
                                                               Days_Units__c,
                                                               Total_Allowed_Amount__c
                                                               FROM Claim_Line_Items__c
                                                               WHERE Claim__c = :updClaim.Id];
                
                Set<Id> ClaimProcedureIds = new Set<Id>();
                Map<Id,Payment_Transaction__c> procedurePaymentTransactionMap = new Map<Id,Payment_Transaction__c>();
                
                for(Claim_Line_Items__c cli : CLItoBeUpdatedDup)
                {
                    if(cli.Procedure__c != null)
                    {
                        ClaimProcedureIds.add(cli.Procedure__c);
                    }
                }
                
                List<Procedure__c> procedurePaymentTransactions = new List<Procedure__c>([SELECT ID, 
                                                                                          (SELECT ID,
                                                                                           Actual_Price__c,
                                                                                           Status__c,
                                                                                           Payment_Adjustments__c, 
                                                                                           Total_Received_Amount__c, 
                                                                                           Insurance_Payments__c,
                                                                                           Credit_Amount__c,
                                                                                           Patient_Responsibility__c, ERA_Arrived__c, Insurance_Responsibility__c
                                                                                           FROM Payment_Transaction__r 
                                                                                           WHERE Master_Transaction__c = null 
                                                                                           AND Payment_Sub_Transaction__c = null 
                                                                                           LIMIT 1) 
                                                                                          FROM Procedure__c 
                                                                                          WHERE id in: ClaimProcedureIds]);
                for(Procedure__c pro : procedurePaymentTransactions)
                {
                    if(pro.Payment_Transaction__r.size()>0)
                    {
                        Payment_Transaction__c temp = pro.Payment_Transaction__r[0];
                        procedurePaymentTransactionMap.put(pro.Id,temp);
                    }
                }
                
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Payment_Transaction__c.SObjectType,
                            Payment_Transaction__c.SObjectType
                            }
                );
                
                fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Master_Transaction__c.SObjectType,
                            Payment_Transaction__c.SObjectType
                            }
                );
                
                List<Payment_Transaction__c> mainPaymentTransactionsToUpdate = new List<Payment_Transaction__c>();
                List<Master_Transaction__c> masterTransactionsToInsert = new List<Master_Transaction__c>();
                List<Payment_Transaction__c> subPaymentTransactionsToInsert = new List<Payment_Transaction__c>();
                
                Id paymntTxnRecordTypeId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Sub_Transaction').getRecordTypeId();
                Id allocatedMasterTxnRecordTypeId = Schema.SObjectType.Master_Transaction__c.getRecordTypeInfosByDeveloperName().get('Allocated_Transaction').getRecordTypeId();
                
                if(procedureIds!=null && procedureIds.size()>0){
                    
                    for(Claim_Line_Items__c cli : CLItoBeUpdatedDup){
                        
                        System.debug('cli - 0987 insurance '+cli.Amount_Paid_by_Insurance__c);
                        System.debug('cli  '+cli.Total_Adjustment__c);
                        
                        System.debug('cli.Procedure__c----' + cli.Procedure__c);
                        
                        if(cli.Procedure__c!=null){
                            
                            Claim_Line_Items__c createPaymentRecord = cli;
                            Payment_Transaction__c paymentRecord  = procedurePaymentTransactionMap.get(cli.Procedure__c);
                            
                            if(createPaymentRecord.Amount_Paid_by_Insurance__c == null) {
                                createPaymentRecord.Amount_Paid_by_Insurance__c = 0;
                            }
                            
                            if(createPaymentRecord.Total_Adjustment__c == null) {
                                createPaymentRecord.Total_Adjustment__c = 0;
                            }
                            
                            //System.debug('paymentRecord.Actual_Price__c----' + paymentRecord.Actual_Price__c);
                            System.debug('createPaymentRecord.Amount_Paid_by_Insurance__c----' + createPaymentRecord.Amount_Paid_by_Insurance__c);
                            System.debug('createPaymentRecord.Total_Adjustment__c----' + createPaymentRecord.Total_Adjustment__c);
                            
                            //Excluding Denied and Overpaid scenarios
                            if(paymentRecord.Actual_Price__c >= createPaymentRecord.Amount_Paid_by_Insurance__c + createPaymentRecord.Total_Adjustment__c) { 
                                
                                if(paymentRecord.Total_Received_Amount__c == null) {
                                    paymentRecord.Total_Received_Amount__c = 0;
                                }
                                
                                if(paymentRecord.Insurance_Payments__c == null) {
                                    paymentRecord.Insurance_Payments__c = 0;
                                }
                                
                                if(paymentRecord.Payment_Adjustments__c == null) {
                                    paymentRecord.Payment_Adjustments__c = 0;
                                }
                                
                                
                                if(paymentRecord.Credit_Amount__c == null) {
                                    paymentRecord.Credit_Amount__c = 0;
                                }
                                
                                paymentRecord.ERA_Arrived__c = true;
                                mainPaymentTransactionsToUpdate.add(paymentRecord);
                                
                                
                                Master_Transaction__c createParentMasterTransaction = new Master_Transaction__c();
                                
                                createParentMasterTransaction.Account__c = updClaim.Account__c;
                                createParentMasterTransaction.Payment_By__c = 'Insurance';
                                createParentMasterTransaction.Transaction_Date__c = System.today();
                                createParentMasterTransaction.Payment_Type__c = 'Online';
                                createParentMasterTransaction.Allocated_Amount__c =createPaymentRecord.Total_Adjustment__c;
                                createParentMasterTransaction.Total_Unallocated_Amount__c = 0;
                                createParentMasterTransaction.Total_Amount_Paid__c = createPaymentRecord.Total_Adjustment__c;
                                createParentMasterTransaction.RecordTypeId = allocatedMasterTxnRecordTypeId;
                                
                                uow1.registerNew(createParentMasterTransaction); 
                                masterTransactionsToInsert.add(createParentMasterTransaction);
                                
                                Payment_Transaction__c createPaymentRecords = new Payment_Transaction__c();
                                
                                createPaymentRecords.Insurance_Payments__c = 0;
                                createPaymentRecords.Payment_Sub_Transaction__c = paymentRecord.Id;
                                createPaymentRecords.Received_From__c = 'Insurance';
                                createPaymentRecords.Received_Amount__c = createPaymentRecord.Total_Adjustment__c;
                                createPaymentRecords.Status__c = 'Paid';
                                createPaymentRecords.Date_Of_Service__c = System.today();
                                createPaymentRecords.Payment_Adjustments__c = createPaymentRecord.Total_Adjustment__c;
                                createPaymentRecords.Payment_Type__c = 'Insurance Adjustments';
                                createPaymentRecords.RecordTypeId = paymntTxnRecordTypeId;
                                createPaymentRecords.Account__c = updClaim.Account__c; //By Sonal
                                
                                uow1.registerRelationship(createPaymentRecords, Payment_Transaction__c.Master_Transaction__c , createParentMasterTransaction);
                                uow1.registerNew(createPaymentRecords); 
                                subPaymentTransactionsToInsert.add(createPaymentRecords);
                                
                                Master_Transaction__c createParentMasterTransactionForInsurance = new Master_Transaction__c();
                                
                                createParentMasterTransactionForInsurance.Account__c = updClaim.Account__c;
                                createParentMasterTransactionForInsurance.Payment_By__c = 'Insurance';
                                createParentMasterTransactionForInsurance.Payment_Type__c = 'Allocated';
                                createParentMasterTransactionForInsurance.Allocated_Amount__c = createPaymentRecord.Amount_Paid_by_Insurance__c;
                                createParentMasterTransactionForInsurance.Total_Amount_Paid__c = createPaymentRecord.Amount_Paid_by_Insurance__c;
                                createParentMasterTransactionForInsurance.Total_Unallocated_Amount__c = 0;
                                createParentMasterTransactionForInsurance.Transaction_Date__c = System.today();
                                createParentMasterTransactionForInsurance.RecordTypeId = allocatedMasterTxnRecordTypeId;
                                
                                uow1.registerNew(createParentMasterTransactionForInsurance); 
                                masterTransactionsToInsert.add(createParentMasterTransactionForInsurance);
                                
                                Payment_Transaction__c createPaymentRecordsInsurance = new Payment_Transaction__c();
                                
                                createPaymentRecordsInsurance.Insurance_Payments__c = createPaymentRecord.Amount_Paid_by_Insurance__c;
                                createPaymentRecordsInsurance.Payment_Sub_Transaction__c = paymentRecord.Id;
                                createPaymentRecordsInsurance.Received_From__c = 'Insurance';
                                createPaymentRecordsInsurance.Received_Amount__c = createPaymentRecord.Amount_Paid_by_Insurance__c;
                                createPaymentRecordsInsurance.Status__c = 'Paid';
                                createPaymentRecordsInsurance.Date_Of_Service__c = System.today();
                                createPaymentRecordsInsurance.Payment_Adjustments__c = 0;
                                createPaymentRecordsInsurance.Payment_Type__c = 'Insurance';
                                createPaymentRecordsInsurance.RecordTypeId = paymntTxnRecordTypeId;
                                createPaymentRecordsInsurance.Account__c = updClaim.Account__c; //By Sonal
                                
                                uow1.registerRelationship(createPaymentRecordsInsurance, Payment_Transaction__c.Master_Transaction__c , createParentMasterTransactionForInsurance);
                                uow1.registerNew(createPaymentRecordsInsurance); 
                                subPaymentTransactionsToInsert.add(createPaymentRecordsInsurance);
                                
                            }
                        }
                        
                    }  
                    try {
                        
                        if(mainPaymentTransactionsToUpdate != null && mainPaymentTransactionsToUpdate.size() >0 ) {
                            update mainPaymentTransactionsToUpdate;
                        }
                        uow1.commitWork();
                        
                    } catch(Exception ex) {
                        System.debug('Error : ' + ex.getMessage());
                    }
                }
            }
        }
        wrapper obj = new wrapper();
        obj.check = val;
        return obj;
    }*/
    
    @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name 
        from User where Id =:currentUid
        WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
        try{
        for(String str : lst_availLicense)
        {
            if(str == 'Elixir EHR')
            {
                lCls.isEhr = True;
                continue;
            }
           
            if(str == 'Elixir Contact Center')
            {
                lCls.isContactCenter = True;
                continue;
            }
            
            if(str == 'Elixir RCM')
            {
                lCls.isRcm = True;
                continue;
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return lCls;
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    }
    
    public class wrapper{
        @AuraEnabled public String messege;
        @AuraEnabled public Boolean check ;
    }
}