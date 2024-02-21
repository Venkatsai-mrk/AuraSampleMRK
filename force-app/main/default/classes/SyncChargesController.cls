public with sharing class SyncChargesController {
    
    @AuraEnabled
    public static void syncCharges(String careId){
        
        Map<String,String> procIdVSProv = new Map<String,String>();
        Map<String,Date> procIdVSFromDate = new Map<String,Date>();
        Map<String,String> procIdVSTempProc = new Map<String,String>();
        Map<String,List<String>> tempProcVSProcId = new Map<String,List<String>>();
        Map<String,String> accIdVSGenerateClaim = new Map<String,String>();
        Map<String,Decimal> patProcIdVSActualPrice = new Map<String,Decimal>();
        Map<String,Decimal> patProcIdVSContrPrice = new Map<String,Decimal>();
        Set<Id> tempProviderIds = new Set<Id>();
        Set<Id> tempProcedureIds = new Set<Id>();
        Map<Id,ElixirSuite__VOB__c> patientVOBWithDefaultVOB = new Map<Id,ElixirSuite__VOB__c>(); //Map to store patient vs vob
        Set<String> payerId = new Set<String>(); //set to store Payer Id
        Set<String> payerCode = new Set<String>(); //set to store Payer Code
        List<Procedure__c> updProcLst = new List<Procedure__c>();
        
        try{
            List<ElixirSuite__Visits__c> visitLst = [SELECT Id,
                                                     ElixirSuite__Account__c
                                                     FROM ElixirSuite__Visits__c
                                                     WHERE Id=:careId
                                                     WITH SECURITY_ENFORCED];
            
            List<Procedure__c> procLst = [SELECT Id,
                                          Name,
                                          ElixirSuite__Provider_Location__c,
                                          ElixirSuite__From_Date_of_Service__c,
                                          ElixirSuite__Template_Procedure__c,
                                          ElixirSuite__Type_of_Procedure__c,
                                          ElixirSuite__Charges__c,
                                          ElixirSuite__Account__c,
                                          ElixirSuite__Visits__c
                                          FROM Procedure__c
                                          WHERE ElixirSuite__Visits__c=:careId
                                          WITH SECURITY_ENFORCED];
            
            List<ElixirSuite__VOB__c> patientWithDefaultVOB = [Select id,ElixirSuite__Account__c,ElixirSuite__Status__c,ElixirSuite__Type__c,ElixirSuite__Set_Default_VOB__c,ElixirSuite__Generate_Claim_on__c,ElixirSuite__Payer__c,ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c 
                                                               FROM ElixirSuite__VOB__c
                                                               Where ElixirSuite__Status__c ='Active'
                                                               AND ElixirSuite__Account__c = :visitLst[0].ElixirSuite__Account__c
                                                               AND ElixirSuite__Type__c ='Primary' 
                                                               WITH SECURITY_ENFORCED ORDER BY Createddate ASC ];
            
            for(ElixirSuite__VOB__c vob : patientWithDefaultVOB){
                patientVOBWithDefaultVOB.put(vob.ElixirSuite__Account__c,vob);
                payerCode.add(vob.ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c);
                payerId.add(vob.ElixirSuite__Payer__c);
                accIdVSGenerateClaim.put(vob.ElixirSuite__Account__c,vob.ElixirSuite__Generate_Claim_on__c);
            }
            
            
            List<ElixirSuite__VOB__c> patientWithDefaultVOBYes = [Select id,ElixirSuite__Account__c,ElixirSuite__Status__c,ElixirSuite__Type__c,ElixirSuite__Set_Default_VOB__c,ElixirSuite__Generate_Claim_on__c,ElixirSuite__Payer__c,ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c FROM ElixirSuite__VOB__c
                                                                  Where ElixirSuite__Account__c = :visitLst[0].ElixirSuite__Account__c 
                                                                  AND ElixirSuite__Status__c ='Active'
                                                                  AND ElixirSuite__Type__c ='Primary' 
                                                                  AND ElixirSuite__Set_Default_VOB__c ='Yes'
                                                                  WITH SECURITY_ENFORCED ORDER BY Createddate ASC ];
            for(ElixirSuite__VOB__c vob : patientWithDefaultVOBYes){
                patientVOBWithDefaultVOB.put(vob.ElixirSuite__Account__c,vob);  
                payerCode.add(vob.ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c); 
                payerId.add(vob.ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c);
                accIdVSGenerateClaim.put(vob.ElixirSuite__Account__c,vob.ElixirSuite__Generate_Claim_on__c);
            }
            
            for(Procedure__c proc : procLst){
                procIdVSProv.put(proc.Id, proc.ElixirSuite__Provider_Location__c);
                procIdVSFromDate.put(proc.Id, (proc.ElixirSuite__From_Date_of_Service__c).Date());
                tempProviderIds.add(proc.ElixirSuite__Provider_Location__c);
                procIdVSTempProc.put(proc.Id, proc.ElixirSuite__Template_Procedure__c);
                //   tempProcVSProcId.put(proc.ElixirSuite__Template_Procedure__c,proc.Id);
                tempProcedureIds.add(proc.ElixirSuite__Template_Procedure__c);
                
                if(tempProcVSProcId== null){
                    List<String> nList = new List<String>();
                    nList.add(proc.Id);
                    tempProcVSProcId.put(proc.ElixirSuite__Template_Procedure__c, nList); 
                }else{
                    if(tempProcVSProcId.get(proc.ElixirSuite__Template_Procedure__c) == null){
                        List<String> nList = new List<String>();
                        nList.add(proc.Id);
                        tempProcVSProcId.put(proc.ElixirSuite__Template_Procedure__c, nList);  
                    }else{
                        List<String> nList = tempProcVSProcId.get(proc.ElixirSuite__Template_Procedure__c);
                        nList.add(proc.Id);
                        tempProcVSProcId.put(proc.ElixirSuite__Template_Procedure__c, nList); 
                    }
                    
                }
                
            }
            
            List<ElixirSuite__Provider__c> tempProvLst = [SELECT Id,
                                                          Name,
                                                          ElixirSuite__Provider_Code__c
                                                          FROM ElixirSuite__Provider__c
                                                          WHERE Id IN : tempProviderIds
                                                          WITH SECURITY_ENFORCED];
            
            List<ElixirSuite__Actual_Price__c> actualPriceList = new List<ElixirSuite__Actual_Price__c>(); //get actual price
            actualPriceList = [Select ElixirSuite__Actual_Price_After_Discount__c,ElixirSuite__List_Price__c,ElixirSuite__Provider__c ,ElixirSuite__Procedure__c,
                               ElixirSuite__Pricing_Effective_Start_Date__c,ElixirSuite__Pricing_Effective_End_Date__c,ElixirSuite__Actual_Discount_Applied__c
                               FROM ElixirSuite__Actual_Price__c 
                               where ElixirSuite__Provider__c IN :tempProvLst
                               AND ElixirSuite__Procedure__c IN :tempProcedureIds 
                               AND ElixirSuite__Pricing_Effective_Start_Date__c != null
                               WITH SECURITY_ENFORCED ORDER BY CREATEDDATE ASC];
            
            List<ElixirSuite__Contracted_Price__c> ContractPriceList = new List<ElixirSuite__Contracted_Price__c>(); //get Contract price
            ContractPriceList = [Select ElixirSuite__Payer__c,ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c,ElixirSuite__Pricing_Effective_End_Date__c,
                                 ElixirSuite__Pricing_Effective_Start_Date__c,ElixirSuite__Procedure__c,
                                 ElixirSuite__Contracted_Amount__c 
                                 FROM ElixirSuite__Contracted_Price__c 
                                 where ElixirSuite__Procedure__c IN :tempProcedureIds 
                                 AND ElixirSuite__Payer__c IN :payerId 
                                 AND ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c IN :payerCode
                                 AND ElixirSuite__Pricing_Effective_Start_Date__c != null
                                 WITH SECURITY_ENFORCED
                                 ORDER BY CREATEDDATE ASC];
            
            for(ElixirSuite__Actual_Price__c actPrice : actualPriceList){
                
                if(tempProcVSProcId.get(actPrice.ElixirSuite__Procedure__c) != null){
                    List<String> procIdLst = tempProcVSProcId.get(actPrice.ElixirSuite__Procedure__c);
                    for(String procId : procIdLst){
                        if(procIdVSFromDate.get(procId) !=null
                           &&  procIdVSFromDate.get(procId) >= actPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                           && procIdVSFromDate.get(procId) <= actPrice.ElixirSuite__Pricing_Effective_End_Date__c){
                               patProcIdVSActualPrice.put(procId,actPrice.ElixirSuite__List_Price__c);
                           }
                    }
                }
            }
            
            for(ElixirSuite__Contracted_Price__c actPrice : ContractPriceList){
                
                if(tempProcVSProcId.get(actPrice.ElixirSuite__Procedure__c) != null){
                    List<String> procIdLst = tempProcVSProcId.get(actPrice.ElixirSuite__Procedure__c);
                    for(String procId : procIdLst){
                        if(procIdVSFromDate.get(procId) !=null
                           &&  procIdVSFromDate.get(procId) >= actPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                           && procIdVSFromDate.get(procId) <= actPrice.ElixirSuite__Pricing_Effective_End_Date__c){
                               patProcIdVSContrPrice.put(procId,actPrice.ElixirSuite__Contracted_Amount__c);
                           }
                    }
                }
            }
            
            for(Procedure__c proc : procLst){
                if(proc.ElixirSuite__Type_of_Procedure__c == 'Private Payment' && patProcIdVSActualPrice!=null && patProcIdVSActualPrice.get(proc.Id)!=null){
                    proc.ElixirSuite__Charges__c = patProcIdVSActualPrice.get(proc.Id);
                    updProcLst.add(proc);
                }
                else if(proc.ElixirSuite__Type_of_Procedure__c == 'Insurance Payment' && accIdVSGenerateClaim.get(proc.ElixirSuite__Account__c) == 'Contracted Price' && patProcIdVSContrPrice!=null && patProcIdVSContrPrice.get(proc.Id)!=null){
                    proc.ElixirSuite__Charges__c = patProcIdVSContrPrice.get(proc.Id);
                    updProcLst.add(proc);
                }
                else if(proc.ElixirSuite__Type_of_Procedure__c == 'Insurance Payment' && accIdVSGenerateClaim.get(proc.ElixirSuite__Account__c) == 'Actual Price'  && patProcIdVSActualPrice!=null && patProcIdVSActualPrice.get(proc.Id)!=null){
                    proc.ElixirSuite__Charges__c = patProcIdVSActualPrice.get(proc.Id);
                    updProcLst.add(proc);
                }
                else if(proc.ElixirSuite__Type_of_Procedure__c == 'Insurance Payment' && patientVOBWithDefaultVOB.get(proc.ElixirSuite__Account__c) == null && patProcIdVSActualPrice!=null && patProcIdVSActualPrice.get(proc.Id)!=null){
                    proc.ElixirSuite__Charges__c = patProcIdVSActualPrice.get(proc.Id);
                    updProcLst.add(proc);
                }
            }
            if(updProcLst.size() >0 && updProcLst != null){
                DMLManager.updateAsUser(updProcLst);
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
}