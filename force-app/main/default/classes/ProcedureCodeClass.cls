/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 01-19-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ProcedureCodeClass {
    /*
    public static void insertProcedureCode(List<ElixirSuite__Inventory__c> lstInventory){
        List<ElixirSuite__Procedure__c> lstProcedure = new List<ElixirSuite__Procedure__c>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> InvIdSet = new Set<Id>();
        for(ElixirSuite__Inventory__c inventory : lstInventory){
            if(inventory.ElixirSuite__Account__c != null){
                accIdSet.add(inventory.ElixirSuite__Account__c);
                InvIdSet.add(inventory.Id);
                system.debug('added accounts into set');
            }
        }
        List<Account> acc = [Select Id, Name from Account where Id IN:accIdSet WITH SECURITY_ENFORCED];
        system.debug('acc size is '+acc.size());
        // List<ElixirSuite__Procedure__c> lstPatientInventory = [Select Id,Name from ElixirSuite__Procedure__c where Name='Patient Inventory' AND ElixirSuite__Account__c IN :accIdSet];
        List<ElixirSuite__Inventory__c> lstPatientInventory = [Select Id,Name,ElixirSuite__Procedure_Codes__c,ElixirSuite__Patient_Procedure_Id__c from ElixirSuite__Inventory__c where ElixirSuite__Account__c IN:accIdSet AND ID NOT IN: InvIdSet WITH SECURITY_ENFORCED];
        system.debug('inv record'+ lstPatientInventory );
        if(lstPatientInventory != null && lstPatientInventory.size() > 0){
            lstProcedure = [Select Id,Name from ElixirSuite__Procedure__c where Name =:'Patient Inventory' AND ElixirSuite__Account__c IN:accIdSet WITH SECURITY_ENFORCED];
            
        }
        else{
            Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
            system.debug(recordTypeId);
            
            system.debug('inserting procedure');
            ElixirSuite__Procedure__c objProcedure = new ElixirSuite__Procedure__c();
            objProcedure.Name = 'Patient Inventory';
            objProcedure.ElixirSuite__Account__c = acc[0].id;
            objProcedure.RecordTypeId = recordTypeId;
            objProcedure.ElixirSuite__Type_of_Procedure__c = 'Private Payment';
            objProcedure.ElixirSuite__From_Date_of_Service__c =  system.today();         
            objProcedure.ElixirSuite__To_Date_of_Service__c =  system.today();
            objProcedure.ElixirSuite__Is_Billable__c = true;
            lstProcedure.add(objProcedure);
            if(Schema.sObjectType.ElixirSuite__Procedure__c.isCreateable() &&
               Schema.sObjectType.ElixirSuite__Procedure__c.fields.Name.isCreateable() &&
               Schema.sObjectType.ElixirSuite__Procedure__c.fields.ElixirSuite__Account__c.isCreateable() &&
               Schema.sObjectType.ElixirSuite__Procedure__c.fields.RecordTypeId.isCreateable() &&
               Schema.sObjectType.ElixirSuite__Procedure__c.fields.ElixirSuite__Type_of_Procedure__c.isCreateable() &&
               Schema.sObjectType.ElixirSuite__Procedure__c.fields.ElixirSuite__From_Date_of_Service__c.isCreateable() &&
               Schema.sObjectType.ElixirSuite__Procedure__c.fields.ElixirSuite__To_Date_of_Service__c.isCreateable() &&
               Schema.sObjectType.ElixirSuite__Procedure__c.fields.ElixirSuite__Is_Billable__c.isCreateable()){
                   insert lstProcedure;
               }
        }
        system.debug('proc record'+ lstProcedure[0].Id);
        List<ElixirSuite__Inventory__c> inList = [Select Id,ElixirSuite__Patient_Procedure_Id__c 
                                                  from ElixirSuite__Inventory__c
                                                  where Id IN:InvIdSet WITH SECURITY_ENFORCED];
        Set<Id> patientProcedures = new Set<Id>();
        for(ElixirSuite__Inventory__c inventory : inList){
            inventory.ElixirSuite__Patient_Procedure_Id__c = lstProcedure[0].Id;
            patientProcedures.add(lstProcedure[0].Id);
        }
        if(Schema.sObjectType.ElixirSuite__Inventory__c.isUpdateable()){
            update inList;
        }
        if(inList!= null && inList.size()>0){
            ProcedureCodeClass.updateActualPrice(accIdSet,inList, patientProcedures);
        }
    }*/
    
    
    
    public static void insertProcedureCode(List<ElixirSuite__Inventory__c> lstInventory){
        
        List<ElixirSuite__Procedure__c> lstProcedure = new List<ElixirSuite__Procedure__c>();
        List<ElixirSuite__Inventory__c> updInvLst = new List<ElixirSuite__Inventory__c>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> InvIdSet = new Set<Id>();
        Map<String,String> invetoryIdVsaccId = new Map<String,String>();
        Map<String,String> invetoryIdVsprocedureCodeName = new Map<String,String>();
        Map<String,Decimal> invetoryIdVsTotalPrice = new Map<String,Decimal>();
        Map<String,Decimal> invetoryIdVsUnitsProc = new Map<String,Decimal>();
        Map<String,ElixirSuite__Procedure__c> invetoryIdVsPatientProcedure = new Map<String,ElixirSuite__Procedure__c>();
        
        try{
        for(ElixirSuite__Inventory__c inventory : lstInventory){
            if(inventory.ElixirSuite__Account__c != null){
                accIdSet.add(inventory.ElixirSuite__Account__c);
                InvIdSet.add(inventory.Id);
                invetoryIdVsaccId.put(inventory.Id,inventory.ElixirSuite__Account__c);
               
                invetoryIdVsTotalPrice.put(inventory.Id,inventory.ElixirSuite__Total_Price__c);
                invetoryIdVsUnitsProc.put(inventory.Id,inventory.ElixirSuite__Units_Procured__c);
                system.debug('added accounts into set');
            }
        }
        
                List<ElixirSuite__Inventory__c> invLst1  =[SELECT Id,
                                                 ElixirSuite__Patient_Procedure_Id__c,
                                                 ElixirSuite__Account__c,
                                                 ElixirSuite__Procedure_Codes__r.Name
                                                 FROM ElixirSuite__Inventory__c
                                                 WHERE Id=:InvIdSet WITH SECURITY_ENFORCED];
        
        for(ElixirSuite__Inventory__c inventory : invLst1){
            
            String name  = inventory.ElixirSuite__Procedure_Codes__r.Name;
                System.debug('name***'+name);
                invetoryIdVsprocedureCodeName.put(inventory.Id,name);
            
        }
        
        System.debug('invetoryIdVsaccId***'+invetoryIdVsaccId);
        System.debug('invetoryIdVsprocedureCodeName***'+invetoryIdVsprocedureCodeName);
            
            ElixirSuite__ERA_Generation__c mc = ElixirSuite__ERA_Generation__c.getOrgDefaults();
            
            String typOfPayment;
            
            if(mc.ElixirSuite__Private_Payments__c == true && mc.ElixirSuite__Insurance_Payments__c ==true){
            typOfPayment = 'Insurance Payment';
            }
            if(mc.ElixirSuite__Private_Payments__c == false && mc.ElixirSuite__Insurance_Payments__c ==true){
                typOfPayment = 'Insurance Payment';
            }
            if(mc.ElixirSuite__Private_Payments__c == true && mc.ElixirSuite__Insurance_Payments__c ==false){
                typOfPayment = 'Private Payment';
            }
            
            
        
        for(ElixirSuite__Inventory__c inventory : lstInventory){
            
            if(inventory.ElixirSuite__Account__c != null){
                
                Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
                
                system.debug('inserting procedure');
                ElixirSuite__Procedure__c objProcedure = new ElixirSuite__Procedure__c();
                objProcedure.Name = invetoryIdVsprocedureCodeName.get(inventory.Id);
                objProcedure.ElixirSuite__Account__c = invetoryIdVsaccId.get(inventory.Id);
                objProcedure.RecordTypeId = recordTypeId;
                objProcedure.ElixirSuite__Type_of_Procedure__c = typOfPayment;
                objProcedure.ElixirSuite__From_Date_of_Service__c =  system.today();         
                objProcedure.ElixirSuite__To_Date_of_Service__c =  system.today();
                objProcedure.ElixirSuite__Is_Billable__c = true;
                objProcedure.ElixirSuite__Days_Units__c = invetoryIdVsUnitsProc.get(inventory.Id);
             //   objProcedure.ElixirSuite__Charges__c = invetoryIdVsTotalPrice.get(inventory.Id);
                lstProcedure.add(objProcedure);
                
                invetoryIdVsPatientProcedure.put(inventory.Id,objProcedure);
                
            }
            
        }
        
        if(lstProcedure.size() >0 && lstProcedure != null){
            claimValidationHelper.byPass = false;
            DMLManager.insertAsUser(lstProcedure);
        }
            
            Set<Id> procId = new Set<Id>();
            for(ElixirSuite__Procedure__c proc : lstProcedure){
                
                procId.add(proc.Id);
                
            }
            
            Map<Id,ElixirSuite__Procedure__c> procIdVsCharges = new Map<Id,ElixirSuite__Procedure__c>([SELECT Id, ElixirSuite__Charges__c FROM ElixirSuite__Procedure__c where Id IN:procId]);        
        List<ElixirSuite__Inventory__c> invLst  =[SELECT Id,
                                                 ElixirSuite__Patient_Procedure_Id__c,
                                                 ElixirSuite__Account__c,
                                                 ElixirSuite__Total_Price__c
                                                 FROM ElixirSuite__Inventory__c
                                                 WHERE Id=:InvIdSet WITH SECURITY_ENFORCED];
        
        
        for(ElixirSuite__Inventory__c inventory : invLst){
            
            if(inventory.ElixirSuite__Account__c != null){
                System.debug('invetoryIdVsPatientProcedure***'+invetoryIdVsPatientProcedure);
                System.debug('invetoryIdVsPatientProcedure***ID'+(invetoryIdVsPatientProcedure.get(inventory.Id)).Id);
                inventory.ElixirSuite__Patient_Procedure_Id__c = (invetoryIdVsPatientProcedure.get(inventory.Id)).Id;
                inventory.ElixirSuite__Total_Price__c = (procIdVsCharges.get((invetoryIdVsPatientProcedure.get(inventory.Id)).Id)).ElixirSuite__Charges__c;
                updInvLst.add(inventory);
            }
            
        }
        
        if(updInvLst.size() >0 && updInvLst != null){
            DMLManager.updateAsUser(updInvLst);
        }
    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
    public static void updateActualPrice(Set<Id> accIdSet , List<Inventory__c> inventories, Set<Id> patientProcedures){
        Set<Id> allTemplateProcedures = new Set<Id>();
        Set<String> providerCodeSet = new Set<String>();
        Set<String> patientProcedureRelatedToInventory = new Set<String>();
        Map<Id,String> tempProvToAcc = new Map<Id,String>();
        Map<Id,List<String>> accToAllProviders = new Map<Id,List<String>>();
        if(accIdSet.size() > 0) { // we need to get the actual price of the procedure. Check the patient's current provider
            
            List<Provider__c> providers = [Select Id,name, Provider__c,Account__c,
                                           Provider__r.Provider_Code__c, 
                                           Provider_Code__c from Provider__c 
                                           WHERE Account__c IN :accIdSet
                                           AND Provider__c!=NULL
                                           AND Provider__r.Provider_Code__c!=NULL
                                           WITH SECURITY_ENFORCED];
            if(providers!=null && providers.size()>0){
                for(Provider__c provider :providers){
                    tempProvToAcc.put(provider.Provider__c, provider.Account__c);
                    if(accToAllProviders.containsKey(provider.Account__c)){
                        accToAllProviders.get(provider.Account__c).add(provider.Provider__c);
                    }else{
                        accToAllProviders.put(provider.Account__c, new List<String>{provider.Provider__c});
                    }
                }
            }        
            List<Inventory__c> inventoriesFromDB = [SELECT Id,Name,Procedure_Codes__c,                                                           
                                                    Patient_Procedure_Id__c, Account__c, Units_Procured__c
                                                    FROM Inventory__c 
                                                    WHERE Patient_Procedure_Id__c IN :patientProcedures WITH SECURITY_ENFORCED];   
            if(inventoriesFromDB!=null && inventoriesFromDB.size()>0){
                for(Inventory__c inventory :inventoriesFromDB){
                    String templateProcId = inventory.Procedure_Codes__c;
                    allTemplateProcedures.add(templateProcId);                
                }
            }
            List<Actual_Price__c> actualPrices = [SELECT Id, Procedure__c,
                                                  Provider__c, 
                                                  List_Price__c,Actual_Discount_Applied__c
                                                  FROM Actual_Price__c
                                                  WHERE Procedure__c IN :allTemplateProcedures
                                                  AND Provider__c IN :tempProvToAcc.keySet() WITH SECURITY_ENFORCED];  
            Map<String,Decimal> templProcToActualPrice = new Map<String,Decimal>();
            Map<String,Decimal> templProcToDiscountAmount = new Map<String,Decimal>();
            Map<String,String> accProcToProvider = new Map<String,String>();
            if(actualPrices!=null && actualPrices.size()>0){
                for(Actual_Price__c actualPrice :actualPrices){
                    for(String accId :accToAllProviders.keySet()){
                        if(accToAllProviders.get(accId).contains(actualPrice.Provider__c)){
                            templProcToActualPrice.put(accId+'#'+actualPrice.Procedure__c,actualPrice.List_Price__c);
                            accProcToProvider.put(accId+'#'+actualPrice.Procedure__c,actualPrice.Provider__c);
                            templProcToDiscountAmount.put(accId+'#'+actualPrice.Procedure__c,actualPrice.Actual_Discount_Applied__c);
                        }
                    }
                }
            }
            
            Map<String,Decimal> patientProcToSum = new Map<String,Decimal>();
            Map<String,Decimal> patientProcToDis = new Map<String,Decimal>();
            if(inventoriesFromDB!=null && inventoriesFromDB.size()>0){
                for(Inventory__c inventory :inventoriesFromDB){
                    String templateProcId = inventory.Procedure_Codes__c;
                    String accountId = inventory.Account__c;
                    String patientProcedure = inventory.Patient_Procedure_Id__c;
                    if(templProcToActualPrice.containsKey(accountId+'#'+templateProcId)){
                        Decimal exactPrice = templProcToActualPrice.get(accountId+'#'+templateProcId);
                        if(inventory.Units_Procured__c!=null && inventory.Units_Procured__c!=0){
                            exactPrice = exactPrice*inventory.Units_Procured__c;
                        }
                        if(patientProcToSum.containsKey(patientProcedure)){
                            Decimal totalAmount = patientProcToSum.get(patientProcedure);
                            totalAmount+=exactPrice;
                            patientProcToSum.put(patientProcedure,totalAmount);
                        }else{
                            patientProcToSum.put(patientProcedure,exactPrice);
                        }
                        
                        Decimal discountAmount = templProcToDiscountAmount.get(accountId+'#'+templateProcId);
                        if(inventory.Units_Procured__c!=null && inventory.Units_Procured__c!=0){
                            discountAmount = discountAmount*inventory.Units_Procured__c;
                        }
                        if(patientProcToDis.containsKey(patientProcedure)){
                            Decimal totalAmount = patientProcToDis.get(patientProcedure);
                            totalAmount+=discountAmount;
                            patientProcToDis.put(patientProcedure,totalAmount);
                        }else{
                            patientProcToDis.put(patientProcedure,discountAmount);
                        }
                        
                    }
                }
            }
            
            List<Payment_Transaction__c> masterTransactionRecord = [SELECT Id, Actual_Price__c, Procedure__c, Discount_Amount__c,ElixirSuite__PatientOutstanding__c,Account__c
                                                                    FROM Payment_Transaction__c 
                                                                    WHERE Procedure__c IN :patientProcToSum.keySet() WITH SECURITY_ENFORCED];
            if(masterTransactionRecord!= null && masterTransactionRecord.size() > 0) {
                for(Payment_Transaction__c masterTransRecord : masterTransactionRecord){
                    String patientProcedureId = masterTransRecord.Procedure__c;
                    String accId = masterTransRecord.Account__c;
                    String procId = masterTransRecord.Procedure__c;
                    if(patientProcToSum.containsKey(patientProcedureId)){
                        masterTransRecord.Actual_Price__c = patientProcToSum.get(patientProcedureId); 
                    }
                    if(patientProcToDis.containsKey(patientProcedureId)){
                        masterTransRecord.Discount_Amount__c = patientProcToDis.get(patientProcedureId);
                    }
                    if(accToAllProviders.containsKey(accId)){//Not a good aprroach, written for Davam as it has one provider
                        for(String provId :accToAllProviders.get(accId)){
                            masterTransRecord.Provider__c = provId;
                        }
                    }
                }
                if(Schema.sObjectType.Payment_Transaction__c.isUpdateable()){
                    update masterTransactionRecord;
                }
            }
        }
    }
}