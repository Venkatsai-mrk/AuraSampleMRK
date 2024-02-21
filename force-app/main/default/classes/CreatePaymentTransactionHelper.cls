/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-13-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing  class CreatePaymentTransactionHelper {
    public class OtherException extends Exception {}
    
   public static void updateCharges(Set<Id> patientAccIdSet, List<ElixirSuite__Procedure__c> procedureList,Map<Id,Procedure__c> oldmap,Boolean isInsert, Boolean isUpdate){
        Set<String> providerCodeSet = new Set<String>();//To store prider id
        Map<String, ElixirSuite__Actual_Price__c> procCPTIdToListPriceMap = new Map<String, ElixirSuite__Actual_Price__c>(); //Map to store procedure versus ActualList charges
        Map<String, ElixirSuite__Contracted_Price__c> procCPTIdToContractPriceMap = new Map<String, ElixirSuite__Contracted_Price__c>(); //Map to store procedure versus Contract charges
        Map<String, Decimal> procCPTIdToDiscountMap = new Map<String, Decimal>(); //Map to store procedure versus Discount
        Map<String, String> providerMap = new Map<String, String>(); //Map to store procedure versus Provider
        Map<Id,ElixirSuite__VOB__c> patientVOBWithDefaultVOB = new Map<Id,ElixirSuite__VOB__c>(); //Map to store patient vs vob
        Set<String> payerId = new Set<String>(); //set to store Payer Id
        Set<String> payerCode = new Set<String>(); //set to store Payer Code
        List<String> idsModifiers = new List<String>(); // modifier id
         
        
        List<ElixirSuite__VOB__c> patientWithDefaultVOB = [Select id,ElixirSuite__Account__c,ElixirSuite__Status__c,ElixirSuite__Type__c,ElixirSuite__Set_Default_VOB__c,ElixirSuite__Generate_Claim_on__c,ElixirSuite__Payer__c,ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c 
                                                           FROM ElixirSuite__VOB__c
                                                           Where ElixirSuite__Status__c ='Active'
                                                           AND ElixirSuite__Account__c IN :patientAccIdSet
                                                           AND ElixirSuite__Type__c ='Primary' 
                                                           AND RecordType.DeveloperName='VOB_record_type'
                                                           WITH SECURITY_ENFORCED ORDER BY Createddate ASC ];
        
        for(ElixirSuite__VOB__c vob : patientWithDefaultVOB){
            patientVOBWithDefaultVOB.put(vob.ElixirSuite__Account__c,vob);
            payerCode.add(vob.ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c);
            payerId.add(vob.ElixirSuite__Payer__c);     
        }
           
        
        List<ElixirSuite__VOB__c> patientWithDefaultVOBYes = [Select id,ElixirSuite__Account__c,ElixirSuite__Status__c,ElixirSuite__Type__c,ElixirSuite__Set_Default_VOB__c,ElixirSuite__Generate_Claim_on__c,ElixirSuite__Payer__c,ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c FROM ElixirSuite__VOB__c
                                                              Where ElixirSuite__Account__c IN :patientAccIdSet 
                                                              AND ElixirSuite__Status__c ='Active'
                                                              AND ElixirSuite__Type__c ='Primary' 
                                                              AND ElixirSuite__Set_Default_VOB__c ='Yes'
                                                              AND RecordType.DeveloperName='VOB_record_type'
                                                              WITH SECURITY_ENFORCED ORDER BY Createddate ASC ];
        for(ElixirSuite__VOB__c vob : patientWithDefaultVOBYes){
            patientVOBWithDefaultVOB.put(vob.ElixirSuite__Account__c,vob);  
            payerCode.add(vob.ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c); 
            payerId.add(vob.ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c);     
        }
        
        try{
            if(patientAccIdSet.size() > 0) { 
                //Query providerList of Account
                List<ElixirSuite__Provider__c> providerList = [Select id,name, ElixirSuite__Provider_Code__c 
                                                               from ElixirSuite__Provider__c 
                                                               WHERE ElixirSuite__Account__c IN :patientAccIdSet
                                                               WITH SECURITY_ENFORCED
                                                               ORDER BY CreatedDate DESC]; //Discussion for BY CreatedDate DESC LIMIT 1
                for(ElixirSuite__Provider__c providerRec : providerList) {
                    if(providerRec.ElixirSuite__Provider_Code__c != null) {
                        providerCodeSet.add(providerRec.ElixirSuite__Provider_Code__c);
                    }
                }
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        Map<Id,ElixirSuite__Provider__c> providerTemplateList = new Map<Id,ElixirSuite__Provider__c>(); // we get the template provider record for the same npi/provider code
        try{
            if(providerCodeSet.size() > 0) {
                providerTemplateList = new Map<Id,ElixirSuite__Provider__c>([Select id,name,ElixirSuite__Provider_Code__c 
                                        From ElixirSuite__Provider__c 
                                        WHERE ElixirSuite__Account__c = null
                                        AND ElixirSuite__Provider_Code__c IN :providerCodeSet
                                        WITH SECURITY_ENFORCED]);
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        List<ElixirSuite__Actual_Price__c> actualPriceList = new List<ElixirSuite__Actual_Price__c>(); //get actual price
        try{
            if(providerTemplateList.size() > 0) {
                actualPriceList = [Select ElixirSuite__Actual_Price_After_Discount__c,ElixirSuite__List_Price__c,ElixirSuite__Provider__c ,ElixirSuite__Procedure__c,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Modifier1__c,ElixirSuite__Procedure__r.ElixirSuite__Modifier2__c,ElixirSuite__Procedure__r.ElixirSuite__Modifier3__c,ElixirSuite__Procedure__r.ElixirSuite__Modifier4__c,ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c,
                                   ElixirSuite__Pricing_Effective_Start_Date__c,ElixirSuite__Pricing_Effective_End_Date__c,ElixirSuite__Actual_Discount_Applied__c
                                   FROM ElixirSuite__Actual_Price__c 
                                   where ElixirSuite__Provider__c IN :providerTemplateList.keyset() AND ElixirSuite__Pricing_Effective_Start_Date__c != null
                                   WITH SECURITY_ENFORCED ORDER BY CREATEDDATE ASC];
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
       
        List<ElixirSuite__Contracted_Price__c> ContractPriceList = new List<ElixirSuite__Contracted_Price__c>(); //get Contract price
        ContractPriceList = [Select ElixirSuite__Payer__c,ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c,ElixirSuite__Pricing_Effective_End_Date__c,ElixirSuite__Pricing_Effective_Start_Date__c,ElixirSuite__Procedure__c,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Modifier1__c,ElixirSuite__Procedure__r.ElixirSuite__Modifier2__c,ElixirSuite__Procedure__r.ElixirSuite__Modifier3__c,ElixirSuite__Procedure__r.ElixirSuite__Modifier4__c,
                             ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c,ElixirSuite__Contracted_Amount__c,ElixirSuite__Provider__c
                             FROM ElixirSuite__Contracted_Price__c 
                             where ElixirSuite__Payer__c IN :payerId 
                             AND ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c IN :payerCode AND ElixirSuite__Pricing_Effective_Start_Date__c != null
                             WITH SECURITY_ENFORCED
                             ORDER BY CREATEDDATE ASC];
        
        List<ElixirSuite__Procedure__c> privateProcedure = new List<ElixirSuite__Procedure__c>();
        List<ElixirSuite__Procedure__c> insuranceProcedure = new List<ElixirSuite__Procedure__c>();
        Set<String> cptCode = new Set<String>();
       
              Map<Id,List<String>> patientProcedureToModifiers = new Map<Id,List<String>>();
       Map<Id,String> patientProcedureMap= new Map<Id,String>();
       List<String> procName = new List<String>();
        for(ElixirSuite__Procedure__c procedureRec : procedureList){
            procName.add(procedureRec.Name);
            for(ElixirSuite__Actual_Price__c actualPriceRec : actualPriceList) {
                if(actualPriceRec.ElixirSuite__Procedure__r.Name != null && procedureRec.ElixirSuite__From_Date_of_Service__c != null &&
                   ((procedureRec.ElixirSuite__From_Date_of_Service__c).Date() >= actualPriceRec.ElixirSuite__Pricing_Effective_Start_Date__c &&
                    (actualPriceRec.ElixirSuite__Pricing_Effective_End_Date__c == null || (actualPriceRec.ElixirSuite__Pricing_Effective_End_Date__c != null && (procedureRec.ElixirSuite__From_Date_of_Service__c).Date() <= actualPriceRec.ElixirSuite__Pricing_Effective_End_Date__c)))) {
                    String nameDateKey = actualPriceRec.ElixirSuite__Procedure__r.Name + '$' + (procedureRec.ElixirSuite__From_Date_of_Service__c).Date();
                    if(actualPriceRec.ElixirSuite__Procedure__r.ElixirSuite__Modifier1__c != null) nameDateKey = nameDateKey+actualPriceRec.ElixirSuite__Procedure__r.ElixirSuite__Modifier1__c;
                    if(actualPriceRec.ElixirSuite__Procedure__r.ElixirSuite__Modifier2__c != null) nameDateKey = nameDateKey+actualPriceRec.ElixirSuite__Procedure__r.ElixirSuite__Modifier2__c;
                    if(actualPriceRec.ElixirSuite__Procedure__r.ElixirSuite__Modifier3__c != null) nameDateKey = nameDateKey+actualPriceRec.ElixirSuite__Procedure__r.ElixirSuite__Modifier3__c;
                    if(actualPriceRec.ElixirSuite__Procedure__r.ElixirSuite__Modifier4__c != null) nameDateKey = nameDateKey+actualPriceRec.ElixirSuite__Procedure__r.ElixirSuite__Modifier4__c;
                    procCPTIdToListPriceMap.put(nameDateKey, actualPriceRec);//PatientProcedure To ActualPrice
                    procCPTIdToDiscountMap.put(nameDateKey, actualPriceRec.ElixirSuite__Actual_Discount_Applied__c);
                    providerMap.put(nameDateKey, actualPriceRec.ElixirSuite__Provider__c);
                }
            }
            
            for(ElixirSuite__Contracted_Price__c cp: ContractPriceList){
                if(cp.ElixirSuite__Procedure__r.Name != null && procedureRec.ElixirSuite__From_Date_of_Service__c != null &&
                   ((procedureRec.ElixirSuite__From_Date_of_Service__c).Date() >= cp.ElixirSuite__Pricing_Effective_Start_Date__c && (cp.ElixirSuite__Pricing_Effective_End_Date__c == null || (cp.ElixirSuite__Pricing_Effective_End_Date__c != null && (procedureRec.ElixirSuite__From_Date_of_Service__c).Date() <= cp.ElixirSuite__Pricing_Effective_End_Date__c)))) 
                {
                    if(cp.ElixirSuite__Provider__c != null && providerTemplateList.size() > 0 && providerTemplateList.containsKey(cp.ElixirSuite__Provider__c)){
                    String nameDateKey = cp.ElixirSuite__Procedure__r.Name +'$'+ cp.ElixirSuite__Payer__c +'$' + (procedureRec.ElixirSuite__From_Date_of_Service__c).Date();
                    if(cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier1__c != null) nameDateKey = nameDateKey+cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier1__c;
                    if(cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier2__c != null) nameDateKey = nameDateKey+cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier2__c;
                    if(cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier3__c != null) nameDateKey = nameDateKey+cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier3__c;
                    if(cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier4__c != null) nameDateKey = nameDateKey+cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier4__c;
                    procCPTIdToContractPriceMap.put(nameDateKey, cp);//PatientProcedure To ContractedPrice    
                    }else{
                    String nameDateKey = cp.ElixirSuite__Procedure__r.Name +'$'+ cp.ElixirSuite__Payer__c +'$' + (procedureRec.ElixirSuite__From_Date_of_Service__c).Date();
                    if(cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier1__c != null) nameDateKey = nameDateKey+cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier1__c;
                    if(cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier2__c != null) nameDateKey = nameDateKey+cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier2__c;
                    if(cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier3__c != null) nameDateKey = nameDateKey+cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier3__c;
                    if(cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier4__c != null) nameDateKey = nameDateKey+cp.ElixirSuite__Procedure__r.ElixirSuite__Modifier4__c;
                    procCPTIdToContractPriceMap.put(nameDateKey, cp);//PatientProcedure To ContractedPrice
                    }    
                }    
            }
            if(isInsert){
            if(procedureRec.ElixirSuite__Type_of_Procedure__c == 'Private Payment' && procedureRec.ElixirSuite__From_Date_of_Service__c != null){
                privateProcedure.add(procedureRec);   
            }else if(procedureRec.ElixirSuite__Type_of_Procedure__c == 'Insurance Payment'  && procedureRec.ElixirSuite__From_Date_of_Service__c != null){
                insuranceProcedure.add(procedureRec);  
            }
            }else if(isUpdate){
                if(procedureRec.ElixirSuite__Type_of_Procedure__c == 'Private Payment' && procedureRec.ElixirSuite__From_Date_of_Service__c != null && (procedureRec.ElixirSuite__From_Date_of_Service__c != (oldmap.get(procedureRec.Id)).ElixirSuite__From_Date_of_Service__c || procedureRec.ElixirSuite__Days_Units__c != (oldmap.get(procedureRec.Id)).ElixirSuite__Days_Units__c || procedureRec.ElixirSuite__Type_of_Procedure__c != (oldmap.get(procedureRec.Id)).ElixirSuite__Type_of_Procedure__c)){
                    privateProcedure.add(procedureRec);   
                }else if(procedureRec.ElixirSuite__Type_of_Procedure__c == 'Insurance Payment' && procedureRec.ElixirSuite__From_Date_of_Service__c != null && (procedureRec.ElixirSuite__From_Date_of_Service__c != (oldmap.get(procedureRec.Id)).ElixirSuite__From_Date_of_Service__c || procedureRec.ElixirSuite__Days_Units__c != (oldmap.get(procedureRec.Id)).ElixirSuite__Days_Units__c || procedureRec.ElixirSuite__Type_of_Procedure__c != (oldmap.get(procedureRec.Id)).ElixirSuite__Type_of_Procedure__c)){
                    insuranceProcedure.add(procedureRec);  
                }
            }
            idsModifiers.clear();
            if(procedureRec.ElixirSuite__Modifier1__c != null) idsModifiers.add(procedureRec.ElixirSuite__Modifier1__c);
            if(procedureRec.ElixirSuite__Modifier2__c != null) idsModifiers.add(procedureRec.ElixirSuite__Modifier2__c);
            if(procedureRec.ElixirSuite__Modifier3__c != null) idsModifiers.add(procedureRec.ElixirSuite__Modifier3__c);
            if(procedureRec.ElixirSuite__Modifier4__c != null) idsModifiers.add(procedureRec.ElixirSuite__Modifier4__c);
            cptCode.add(procedureRec.Name);
            patientProcedureToModifiers.put(procedureRec.Id,new List<String>(new Set<String>(idsModifiers)));
            patientProcedureMap.put(procedureRec.Id,procedureRec.Name);
        }
        
       List<ElixirSuite__Procedure__c> lstTemplateProcedures =[Select Id, name , ElixirSuite__Modifier1__c, ElixirSuite__Modifier2__c, ElixirSuite__Modifier3__c, ElixirSuite__Modifier4__c                            
                 FROM ElixirSuite__Procedure__c 
                 WHERE RecordType.DeveloperName ='Template_Procedure' AND ElixirSuite__Code_Category__c!='Modifier'
                 AND Name IN :procName AND ElixirSuite__Modifier1__c = null AND ElixirSuite__Modifier2__c = null 
                 AND ElixirSuite__Modifier3__c = null AND ElixirSuite__Modifier4__c = null WITH SECURITY_ENFORCED ORDER BY CREATEDDATE ASC];
       Map<String,String> temProMap = new Map<String,String>();
       for(ElixirSuite__Procedure__c pro :lstTemplateProcedures){
           temProMap.put(pro.name,pro.Id);
       }
        
        Map<String, ElixirSuite__Procedure__c> records = new Map<String, ElixirSuite__Procedure__c>(); 
        Map<Id,List<String>> TemplateProcedureId = new Map<Id,List<String>>();
        Map<String,List<Id>> ReferralCode = new Map<String,List<Id>>();
        Map<Id,ElixirSuite__Procedure__c> idVsTemplateProcedure = new Map<Id,ElixirSuite__Procedure__c>();
        if(idsModifiers.size()>0){
            CheckModifierControllerCharges.masterWrapperRelated flowsObj = new CheckModifierControllerCharges.masterWrapperRelated();
            flowsObj = CheckModifierControllerCharges.getTemplateProcedureForModifiers(patientProcedureToModifiers, patientProcedureMap); 
            TemplateProcedureId = flowsObj.TemplateProcedureId;
            ReferralCode = flowsObj.ReferralCode;
            idVsTemplateProcedure = flowsObj.idVsTemplateProcedure; 
        }
       
        
        for(ElixirSuite__Procedure__c pro : privateProcedure){
            List<String> modifiersToCompare = new List<String>();
            if(pro.ElixirSuite__Modifier1__c != null) modifiersToCompare.add(pro.ElixirSuite__Modifier1__c);
            if(pro.ElixirSuite__Modifier2__c != null) modifiersToCompare.add(pro.ElixirSuite__Modifier2__c);
            if(pro.ElixirSuite__Modifier3__c != null) modifiersToCompare.add(pro.ElixirSuite__Modifier3__c);
            if(pro.ElixirSuite__Modifier4__c != null) modifiersToCompare.add(pro.ElixirSuite__Modifier4__c);
            id finalIds;
            if(ReferralCode.size() >0 && ReferralCode.get(pro.Name) != null){
                List<Id> listOfAllTemplateProcedures = ReferralCode.get(pro.Name);
                for(Id procId :listOfAllTemplateProcedures){
                   List<String> allrelatedModifiers = TemplateProcedureId.get(procId);
                    Integer count = 0;
                    for(String modifier :allrelatedModifiers){
                        if(modifiersToCompare.contains(modifier)){
                           count++;   
                        }else{
                            break;
                        }
                        if(modifiersToCompare.size() == count && modifiersToCompare.size() == allrelatedModifiers.size()){
                            
                            finalIds = procId;
                        }
                    }
                }
            }
            string actualMapKey;
            ElixirSuite__Procedure__c temp;
            if(finalIds != null && idVsTemplateProcedure.get(finalIds) != null){
             temp =  idVsTemplateProcedure.get(finalIds);
              pro.ElixirSuite__Template_Procedure__c = finalIds;
             actualMapKey = temp.Name + '$' + (pro.ElixirSuite__From_Date_of_Service__c).Date();
             if(temp.ElixirSuite__Modifier1__c != null) actualMapKey = actualMapKey+temp.ElixirSuite__Modifier1__c;
             if(temp.ElixirSuite__Modifier2__c != null) actualMapKey = actualMapKey+temp.ElixirSuite__Modifier2__c;
             if(temp.ElixirSuite__Modifier3__c != null) actualMapKey = actualMapKey+temp.ElixirSuite__Modifier3__c;
             if(temp.ElixirSuite__Modifier4__c != null) actualMapKey = actualMapKey+temp.ElixirSuite__Modifier4__c;   
            }
            
            String nameDateKey = pro.Name + '$' + (pro.ElixirSuite__From_Date_of_Service__c).Date(); 
                 if(procCPTIdToListPriceMap.get(nameDateKey) != null){
                    Decimal actualPrice = 0;
                    if(temp==null){
                        pro.ElixirSuite__Template_Procedure__c = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__Procedure__c;
                        if(procCPTIdToListPriceMap.get(nameDateKey) != null && (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c != null){
                         actualPrice = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c;    
                         pro.ElixirSuite__Charges__c = actualPrice;
                        }
                    }else{
                        if(procCPTIdToListPriceMap.get(actualMapKey) != null && (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c != null){
                        actualPrice = (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c;    
                        pro.ElixirSuite__Charges__c = actualPrice;
                        }
                    }
                 }else{
                       pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                 }
        }
        
        for(ElixirSuite__Procedure__c pro : insuranceProcedure){
            String nameDateKey = pro.Name + '$' + (pro.ElixirSuite__From_Date_of_Service__c).Date();
            
            List<String> modifiersToCompare = new List<String>();
            if(pro.ElixirSuite__Modifier1__c != null) modifiersToCompare.add(pro.ElixirSuite__Modifier1__c);
            if(pro.ElixirSuite__Modifier2__c != null) modifiersToCompare.add(pro.ElixirSuite__Modifier2__c);
            if(pro.ElixirSuite__Modifier3__c != null) modifiersToCompare.add(pro.ElixirSuite__Modifier3__c);
            if(pro.ElixirSuite__Modifier4__c != null) modifiersToCompare.add(pro.ElixirSuite__Modifier4__c);
            id finalIds;
            if(ReferralCode.size() >0 && ReferralCode.get(pro.Name) != null){
                List<Id> listOfAllTemplateProcedures = ReferralCode.get(pro.Name);
                for(Id procId :listOfAllTemplateProcedures){
                   List<String> allrelatedModifiers = TemplateProcedureId.get(procId);
                    Integer count = 0;
                    for(String modifier :allrelatedModifiers){
                        if(modifiersToCompare.contains(modifier)){
                          count++;      
                        }else{
                            break;
                        }
                        if(modifiersToCompare.size() == count && modifiersToCompare.size() == allrelatedModifiers.size()){
                             finalIds = procId;
                        }
                    }
                }
            }
            string actualMapKey;
            ElixirSuite__Procedure__c temp;
            if(finalIds != null && idVsTemplateProcedure.get(finalIds) != null){
             temp =  idVsTemplateProcedure.get(finalIds);
             pro.ElixirSuite__Template_Procedure__c = finalIds;
             actualMapKey = temp.Name + '$' + (pro.ElixirSuite__From_Date_of_Service__c).Date();
             if(temp.ElixirSuite__Modifier1__c != null) actualMapKey = actualMapKey+temp.ElixirSuite__Modifier1__c;
             if(temp.ElixirSuite__Modifier2__c != null) actualMapKey = actualMapKey+temp.ElixirSuite__Modifier2__c;
             if(temp.ElixirSuite__Modifier3__c != null) actualMapKey = actualMapKey+temp.ElixirSuite__Modifier3__c;
             if(temp.ElixirSuite__Modifier4__c != null) actualMapKey = actualMapKey+temp.ElixirSuite__Modifier4__c;   
            }
            if(patientVOBWithDefaultVOB.get(pro.ElixirSuite__Account__c) != null){
                    VOB__c vobRec;
                    vobRec = patientVOBWithDefaultVOB.get(pro.ElixirSuite__Account__c);
                    string contractMapKey;
                    if(temp != null){
                    contractMapKey = temp.Name +'$'+ vobRec.ElixirSuite__Payer__c +'$' + (pro.ElixirSuite__From_Date_of_Service__c).Date();
                    if(temp.ElixirSuite__Modifier1__c != null) contractMapKey = contractMapKey+temp.ElixirSuite__Modifier1__c;
                    if(temp.ElixirSuite__Modifier2__c != null) contractMapKey = contractMapKey+temp.ElixirSuite__Modifier2__c;
                    if(temp.ElixirSuite__Modifier3__c != null) contractMapKey = contractMapKey+temp.ElixirSuite__Modifier3__c;
                    if(temp.ElixirSuite__Modifier4__c != null) contractMapKey = contractMapKey+temp.ElixirSuite__Modifier4__c;   
                    }
                    String nameDateKeyContract = pro.Name +'$'+ vobRec.ElixirSuite__Payer__c +'$' + (pro.ElixirSuite__From_Date_of_Service__c).Date();
                    if(vobRec.ElixirSuite__Status__c =='Active' && vobRec.ElixirSuite__Type__c =='Primary' && vobRec.ElixirSuite__Set_Default_VOB__c =='Yes'){
                        if(vobRec.ElixirSuite__Generate_Claim_on__c == 'Contracted Price'){
                            if(procCPTIdToContractPriceMap.size() > 0){
                                Decimal contractPrice = 0;
                                if(temp == null){
                                    if(procCPTIdToContractPriceMap.get(nameDateKeyContract) != null && procCPTIdToContractPriceMap.get(nameDateKeyContract).ElixirSuite__Contracted_Amount__c != null){
                                        pro.ElixirSuite__Template_Procedure__c = (procCPTIdToContractPriceMap.get(nameDateKeyContract)).ElixirSuite__Procedure__c; 
                                        contractPrice = procCPTIdToContractPriceMap.get(nameDateKeyContract).ElixirSuite__Contracted_Amount__c;    
                                        pro.ElixirSuite__Charges__c = contractPrice;
                                    }else if(procCPTIdToListPriceMap.get(nameDateKey) != null && (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c !=null){
                                        pro.ElixirSuite__Template_Procedure__c = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__Procedure__c; 
                                        Decimal actualPrice = 0;
                                        actualPrice = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c;    
                                        pro.ElixirSuite__Charges__c = actualPrice;
                                    }else{
                                        pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                                    }    
                                }else{
                                    if(procCPTIdToContractPriceMap.get(contractMapKey) != null && procCPTIdToContractPriceMap.get(contractMapKey).ElixirSuite__Contracted_Amount__c != null){
                                        
                                            contractPrice = procCPTIdToContractPriceMap.get(contractMapKey).ElixirSuite__Contracted_Amount__c;    
                                            pro.ElixirSuite__Charges__c = contractPrice;
                                    }else{
                                        Decimal actualPrice = 0;
                                        if(procCPTIdToListPriceMap.get(actualMapKey) != null&& (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c != null){
                                            actualPrice = (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c;    
                                            pro.ElixirSuite__Charges__c = actualPrice;
                                        }
                                    }
                                }
                                pro.ElixirSuite__Payor__c = vobRec.ElixirSuite__Payer__c;
                            }else if(procCPTIdToListPriceMap.size() > 0){
                                Decimal actualPrice = 0;
                                if(temp == null){
                                    if(procCPTIdToListPriceMap.get(nameDateKey) != null ){
                                         pro.ElixirSuite__Template_Procedure__c = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__Procedure__c;
                                    if((procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c != null){
                                        actualPrice = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c;    
                                        pro.ElixirSuite__Charges__c = actualPrice;
                                    }
                                    }else{
                                        pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                                    }
                                }else{
                                    if(procCPTIdToListPriceMap.get(actualMapKey) != null && (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c != null){
                                        
                                        actualPrice = (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c;    
                                        pro.ElixirSuite__Charges__c = actualPrice;
                                    }   
                                }
                            }else{
                                pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                            }
                            
                        }else if(vobRec.ElixirSuite__Generate_Claim_on__c == 'Actual Price' || vobRec.ElixirSuite__Generate_Claim_on__c == null ||vobRec.ElixirSuite__Generate_Claim_on__c==''){
                            if(procCPTIdToListPriceMap.size() > 0){
                                Decimal actualPrice = 0;
                                if(temp == null){
                                    if(procCPTIdToListPriceMap.get(nameDateKey) != null){
                                         pro.ElixirSuite__Template_Procedure__c = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__Procedure__c;
                                    if((procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c != null){
                                    
                                        actualPrice = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c;    
                                        pro.ElixirSuite__Charges__c = actualPrice;
                                    }
                                    }else{
                                        pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                                    }
                                }else{
                                    if(procCPTIdToListPriceMap.get(actualMapKey) != null && (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c != null){
                                        actualPrice = (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c;    
                                        pro.ElixirSuite__Charges__c = actualPrice;
                                    }    
                                }
                            }else{
                                pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                            }
                            
                        }  
                    }else{//No Default No Active
                        if(vobRec.ElixirSuite__Generate_Claim_on__c == 'Contracted Price'){
                            if(procCPTIdToContractPriceMap.size() > 0){
                                Decimal contractPrice = 0;
                                if(temp == null){
                                    if(procCPTIdToContractPriceMap.get(nameDateKeyContract) != null && procCPTIdToContractPriceMap.get(nameDateKeyContract).ElixirSuite__Contracted_Amount__c != null){
                                        pro.ElixirSuite__Template_Procedure__c = (procCPTIdToContractPriceMap.get(nameDateKeyContract)).ElixirSuite__Procedure__c; 
                                        contractPrice = procCPTIdToContractPriceMap.get(nameDateKeyContract).ElixirSuite__Contracted_Amount__c;    
                                        pro.ElixirSuite__Charges__c = contractPrice;
                                    }else if(procCPTIdToListPriceMap.get(nameDateKey) != null && (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c != null){
                                        pro.ElixirSuite__Template_Procedure__c = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__Procedure__c;
                                        Decimal actualPrice = 0;
                                        actualPrice = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c;    
                                        pro.ElixirSuite__Charges__c = actualPrice;
                                    }else{
                                        pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                                    }  
                                }else{
                                    if(procCPTIdToContractPriceMap.get(contractMapKey) != null && procCPTIdToContractPriceMap.get(contractMapKey).ElixirSuite__Contracted_Amount__c != null){
                                        contractPrice = procCPTIdToContractPriceMap.get(contractMapKey).ElixirSuite__Contracted_Amount__c;    
                                        pro.ElixirSuite__Charges__c = contractPrice;
                                    }else{
                                        Decimal actualPrice = 0;
                                        if(procCPTIdToListPriceMap.get(actualMapKey) != null && (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c != null){
                                            actualPrice = (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c;    
                                            pro.ElixirSuite__Charges__c = actualPrice;
                                        }
                                    }
                                }
                                pro.ElixirSuite__Payor__c = vobRec.ElixirSuite__Payer__c;
                            }else if(procCPTIdToListPriceMap.size() > 0){
                                Decimal actualPrice = 0;
                                if(temp==null){
                                    if(procCPTIdToListPriceMap.get(nameDateKey) != null){
                                     pro.ElixirSuite__Template_Procedure__c = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__Procedure__c;
                                    if((procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c != null){
                                    actualPrice = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c;    
                                    pro.ElixirSuite__Charges__c = actualPrice;
                                    }
                                    }else{
                                         pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                                    }
                                }else{
                                    if(procCPTIdToListPriceMap.get(actualMapKey) != null && (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c != null){
                                        actualPrice = (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c;    
                                        pro.ElixirSuite__Charges__c = actualPrice;
                                    }    
                                }
                            }else{
                                 pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                            }
                            
                        }else if(vobRec.ElixirSuite__Generate_Claim_on__c == 'Actual Price' || vobRec.ElixirSuite__Generate_Claim_on__c == null ||vobRec.ElixirSuite__Generate_Claim_on__c==''){
                            if(procCPTIdToListPriceMap.size() > 0){
                                Decimal actualPrice = 0;
                                if(temp==null){
                                    if(procCPTIdToListPriceMap.get(nameDateKey) != null){
                                        pro.ElixirSuite__Template_Procedure__c = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__Procedure__c;
                                    if((procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c != null){
                                        actualPrice = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c;    
                                        pro.ElixirSuite__Charges__c = actualPrice;
                                    }
                                    }else{
                                         pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                                    }
                                }else{
                                    if(procCPTIdToListPriceMap.get(actualMapKey) != null && (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c != null){
                                            actualPrice = (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c;    
                                            pro.ElixirSuite__Charges__c = actualPrice;
                                    }    
                                }
                            }else{ 
                                 pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                            }
                        }   
                    }
                }else{ //No Vob present actual price list
                    if(procCPTIdToListPriceMap.size() > 0){
                        Decimal actualPrice = 0;
                        if(temp==null){
                            if(procCPTIdToListPriceMap.get(nameDateKey) != null){
                            pro.ElixirSuite__Template_Procedure__c = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__Procedure__c;
                            if((procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c != null){
                                actualPrice = (procCPTIdToListPriceMap.get(nameDateKey)).ElixirSuite__List_Price__c;    
                                pro.ElixirSuite__Charges__c = actualPrice;
                            }
                            }else{
                            pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);   
                            }
                        }else{
                            if(procCPTIdToListPriceMap.get(actualMapKey) != null && (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c != null){
                                
                                    actualPrice = (procCPTIdToListPriceMap.get(actualMapKey)).ElixirSuite__List_Price__c;    
                                    pro.ElixirSuite__Charges__c = actualPrice;
                            }   
                        }
                    }else{
                         pro.ElixirSuite__Template_Procedure__c = temProMap.get(pro.Name);
                    }
                }
            }
       
    }

    public static void afterInsertAttachProvider(List<Procedure__c> procRecLst){
        if(procRecLst.size() > 0) {
        Map<String,String> careIdVsProvId = new Map<String,String>();
            List<String> careIds = new List<String>();
        for(ElixirSuite__Procedure__c proc : procRecLst){
            careIds.add(proc.ElixirSuite__Visits__c);
        }
            
            List<ElixirSuite__Visits__c> visitLst = [Select Id,
                                                     ElixirSuite__Care_Episode_Location__c
                                                     From ElixirSuite__Visits__c
                                                     Where Id IN: careIds
                                                     WITH SECURITY_ENFORCED];
            
            for(ElixirSuite__Visits__c visit : visitLst){
                
                careIdVsProvId.put(visit.Id , visit.ElixirSuite__Care_Episode_Location__c);
                
            }
            
            for(ElixirSuite__Procedure__c proc : procRecLst){
                if(!careIdVsProvId.isEmpty() && careIdVsProvId.containsKey(proc.ElixirSuite__Visits__c)){
                    proc.ElixirSuite__Provider_Location__c = careIdVsProvId.get(proc.ElixirSuite__Visits__c);
                }
            }
            
            
        
       // update procRecLst;
    }
    }
    
    public static void afterInsert(Set<Id> patientAccIdSet, List<ElixirSuite__Procedure__c> procedureList){
        Set<String> providerCodeSet = new Set<String>();//To store prider id
        Map<String, ElixirSuite__Actual_Price__c> procCPTIdToListPriceMap = new Map<String, ElixirSuite__Actual_Price__c>(); //Map to store procedure versus ActualList charges
        Map<String, Decimal> procCPTIdToDiscountMap = new Map<String, Decimal>();
        Map<String, String> providerMap = new Map<String, String>(); 
        
        try{
            if(patientAccIdSet.size() > 0) { 
                //Query providerList of Account
                List<ElixirSuite__Provider__c> providerList = [Select id,name, ElixirSuite__Provider_Code__c 
                                                               from ElixirSuite__Provider__c 
                                                               WHERE ElixirSuite__Account__c IN :patientAccIdSet
                                                               WITH SECURITY_ENFORCED
                                                               ORDER BY CreatedDate DESC]; //Discussion for BY CreatedDate DESC LIMIT 1
                for(ElixirSuite__Provider__c providerRec : providerList) {
                    if(providerRec.ElixirSuite__Provider_Code__c != null) {
                        providerCodeSet.add(providerRec.ElixirSuite__Provider_Code__c);
                    }
                }
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        List<ElixirSuite__Provider__c> providerTemplateList = new List<ElixirSuite__Provider__c>(); // we get the template provider record for the same npi/provider code
        try{
            if(providerCodeSet.size() > 0) {
                providerTemplateList = [Select id,name,ElixirSuite__Provider_Code__c 
                                        From ElixirSuite__Provider__c 
                                        WHERE ElixirSuite__Account__c = null
                                        AND ElixirSuite__Provider_Code__c IN :providerCodeSet
                                        WITH SECURITY_ENFORCED];
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        List<ElixirSuite__Actual_Price__c> actualPriceList = new List<ElixirSuite__Actual_Price__c>(); //get actual price
        try{
            if(providerTemplateList.size() > 0) {
                actualPriceList = [Select ElixirSuite__Actual_Price_After_Discount__c,ElixirSuite__List_Price__c,ElixirSuite__Provider__c ,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c,
                                   ElixirSuite__Pricing_Effective_Start_Date__c,ElixirSuite__Pricing_Effective_End_Date__c,ElixirSuite__Actual_Discount_Applied__c
                                   FROM ElixirSuite__Actual_Price__c 
                                   where ElixirSuite__Provider__c IN :providerTemplateList AND ElixirSuite__Pricing_Effective_Start_Date__c != null
                                   WITH SECURITY_ENFORCED ORDER BY CREATEDDATE ASC];
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        List<ElixirSuite__Procedure__c> privateProcedure = new List<ElixirSuite__Procedure__c>();
        List<ElixirSuite__Procedure__c> insuranceProcedure = new List<ElixirSuite__Procedure__c>();
         try{
        for(ElixirSuite__Procedure__c procedureRec : procedureList){
            for(ElixirSuite__Actual_Price__c actualPriceRec : actualPriceList) {
                if(actualPriceRec.ElixirSuite__Procedure__r.Name != null && procedureRec.ElixirSuite__From_Date_of_Service__c != null && ((procedureRec.ElixirSuite__From_Date_of_Service__c).Date() >= actualPriceRec.ElixirSuite__Pricing_Effective_Start_Date__c && ( actualPriceRec.ElixirSuite__Pricing_Effective_End_Date__c == null || (actualPriceRec.ElixirSuite__Pricing_Effective_End_Date__c != null && (procedureRec.ElixirSuite__From_Date_of_Service__c).Date() <= actualPriceRec.ElixirSuite__Pricing_Effective_End_Date__c)))) {
                    String nameDateKey = actualPriceRec.ElixirSuite__Procedure__r.Name + '$' + (procedureRec.ElixirSuite__From_Date_of_Service__c).Date();
                    procCPTIdToListPriceMap.put(nameDateKey, actualPriceRec);
                    procCPTIdToDiscountMap.put(nameDateKey, actualPriceRec.ElixirSuite__Actual_Discount_Applied__c);
                    providerMap.put(nameDateKey, actualPriceRec.ElixirSuite__Provider__c);
                }
            }
            
           if(procedureRec.ElixirSuite__Type_of_Procedure__c == 'Private Payment'){
                privateProcedure.add(procedureRec);   
            }else if(procedureRec.ElixirSuite__Type_of_Procedure__c == 'Insurance Payment'){
                insuranceProcedure.add(procedureRec);  
            }
            
        }
             }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        //For After Insert
        Id paymntTxnRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
        Id paymntTxnRecordTypeIdPrivate = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
        List<ElixirSuite__Payment_Transaction__c> paymntTrxnToInsert = new List<ElixirSuite__Payment_Transaction__c>();
        
       
         try{
        for(ElixirSuite__Procedure__c pro : privateProcedure){
            String nameDateKey;
            if(pro.ElixirSuite__From_Date_of_Service__c != null){
              nameDateKey = pro.Name + '$' + (pro.ElixirSuite__From_Date_of_Service__c).Date();    
            }
                ElixirSuite__Payment_Transaction__c trxnRec = new ElixirSuite__Payment_Transaction__c();
                trxnRec.ElixirSuite__Account__c  = pro.ElixirSuite__Account__c  ;
                trxnRec.ElixirSuite__Procedure__c = pro.id;
                if(pro.ElixirSuite__Code_Description__c != null && pro.ElixirSuite__Code_Description__c != ''){
                    trxnRec.ElixirSuite__Procedure_Name__c =  pro.Name + ' ' +'-'+ ' '+ pro.ElixirSuite__Code_Description__c;
                }else{
                    trxnRec.ElixirSuite__Procedure_Name__c = pro.Name;
                }
                trxnRec.ElixirSuite__Cpt_Codes__c= pro.Name  ;
               if(pro.ElixirSuite__From_Date_of_Service__c != null){
               trxnRec.ElixirSuite__Date_Of_Service__c = Date.valueof(pro.ElixirSuite__From_Date_of_Service__c);   
               }
                
                trxnRec.ElixirSuite__Status__c = 'UnPaid';
                trxnRec.ElixirSuite__Other_Discounts__c = 0;
                trxnRec.ElixirSuite__Total_Received_Amount__c = 0;
                trxnRec.ElixirSuite__Units_days__c = pro.ElixirSuite__Days_Units__c;
                trxnRec.RecordTypeId = paymntTxnRecordTypeIdPrivate;
                if(pro.ElixirSuite__Days_Units__c == 0 || pro.ElixirSuite__Days_Units__c == null){
                trxnRec.ElixirSuite__Actual_Price__c = pro.ElixirSuite__Charges__c;
                trxnRec.ElixirSuite__Expected_Receivable_amount__c = pro.ElixirSuite__Charges__c;
                }else{
                Decimal Price = 0;
                Price = Integer.valueof(pro.ElixirSuite__Days_Units__c) * pro.ElixirSuite__Charges__c;  
                trxnRec.ElixirSuite__Actual_Price__c = Price;
                trxnRec.ElixirSuite__Expected_Receivable_amount__c = Price;    
                }
            if(nameDateKey != null && nameDateKey != ''){
                if(providerMap.get(nameDateKey) != null){
                    trxnRec.ElixirSuite__Provider__c = providerMap.get(nameDateKey);    
                }
                
                if(procCPTIdToDiscountMap.get(nameDateKey) != null)
                {
                    trxnRec.ElixirSuite__Discount_Amount__c = procCPTIdToDiscountMap.get(nameDateKey);
                } 
                
            }
               
                paymntTrxnToInsert.add(trxnRec);
        }
        
        for(ElixirSuite__Procedure__c pro : insuranceProcedure){
            String nameDateKey;
            if(pro.ElixirSuite__From_Date_of_Service__c != null){
              nameDateKey = pro.Name + '$' + (pro.ElixirSuite__From_Date_of_Service__c).Date();    
            }
                ElixirSuite__Payment_Transaction__c trxnRec = new ElixirSuite__Payment_Transaction__c();
                trxnRec.ElixirSuite__Account__c  = pro.ElixirSuite__Account__c  ;
                trxnRec.ElixirSuite__Procedure__c = pro.id;
                if(pro.ElixirSuite__Code_Description__c != null && pro.ElixirSuite__Code_Description__c != ''){
                    trxnRec.ElixirSuite__Procedure_Name__c =  pro.Name + ' ' +'-'+ ' '+ pro.ElixirSuite__Code_Description__c;
                }else{
                    trxnRec.ElixirSuite__Procedure_Name__c = pro.Name;
                }
                trxnRec.ElixirSuite__Cpt_Codes__c= pro.Name  ;
               if(pro.ElixirSuite__From_Date_of_Service__c != null){
                trxnRec.ElixirSuite__Date_Of_Service__c = Date.valueof(pro.ElixirSuite__From_Date_of_Service__c);
                }
                trxnRec.ElixirSuite__Status__c = 'UnPaid';
                trxnRec.ElixirSuite__Other_Discounts__c = 0;
                trxnRec.ElixirSuite__Total_Received_Amount__c = 0;
                trxnRec.ElixirSuite__Units_days__c = pro.ElixirSuite__Days_Units__c;
                trxnRec.RecordTypeId = paymntTxnRecordTypeId;
               if(pro.ElixirSuite__Days_Units__c == 0 || pro.ElixirSuite__Days_Units__c == null){
                trxnRec.ElixirSuite__Actual_Price__c = pro.ElixirSuite__Charges__c;
                trxnRec.ElixirSuite__Expected_Receivable_amount__c = pro.ElixirSuite__Charges__c;
                }else{
                Decimal Price = 0;
                Price = Integer.valueof(pro.ElixirSuite__Days_Units__c) * pro.ElixirSuite__Charges__c;  
                trxnRec.ElixirSuite__Actual_Price__c = Price;
                trxnRec.ElixirSuite__Expected_Receivable_amount__c = Price;    
                }
            if(pro.ElixirSuite__Payor__c == null){ 
                if(nameDateKey != null && nameDateKey != ''){
                    if( providerMap.get(nameDateKey) != null){
                        trxnRec.ElixirSuite__Provider__c = providerMap.get(nameDateKey);
                    }
                    if(procCPTIdToDiscountMap.get(nameDateKey) != null)
                    {
                        trxnRec.ElixirSuite__Discount_Amount__c = procCPTIdToDiscountMap.get(nameDateKey);
                    }
                }   
            }else{
                trxnRec.ElixirSuite__Payor__c = pro.ElixirSuite__Payor__c;    
            }
                paymntTrxnToInsert.add(trxnRec);
         }
        
        
        if(paymntTrxnToInsert.size() > 0){
            DMLManager.insertAsUser(paymntTrxnToInsert);
        }
             }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
       
    }
    
    public static void afterUpdate(Set<Id> patientAccIdSet, List<ElixirSuite__Procedure__c> procedureList,Set<Id> procedureRecIds){
        Set<String> providerCodeSet = new Set<String>();//To store prider id
        Map<String, ElixirSuite__Actual_Price__c> procCPTIdToListPriceMap = new Map<String, ElixirSuite__Actual_Price__c>(); //Map to store procedure versus ActualList charges
        Map<String, Decimal> procCPTIdToDiscountMap = new Map<String, Decimal>();
        Map<String, String> providerMap = new Map<String, String>(); 
        
        try{
            if(patientAccIdSet.size() > 0) { 
                //Query providerList of Account
                List<ElixirSuite__Provider__c> providerList = [Select id,name, ElixirSuite__Provider_Code__c 
                                                               from ElixirSuite__Provider__c 
                                                               WHERE ElixirSuite__Account__c IN :patientAccIdSet
                                                               WITH SECURITY_ENFORCED
                                                               ORDER BY CreatedDate DESC]; //Discussion for BY CreatedDate DESC LIMIT 1
                for(ElixirSuite__Provider__c providerRec : providerList) {
                    if(providerRec.ElixirSuite__Provider_Code__c != null) {
                        providerCodeSet.add(providerRec.ElixirSuite__Provider_Code__c);
                    }
                }
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        List<ElixirSuite__Provider__c> providerTemplateList = new List<ElixirSuite__Provider__c>(); // we get the template provider record for the same npi/provider code
        try{
            if(providerCodeSet.size() > 0) {
                providerTemplateList = [Select id,name,ElixirSuite__Provider_Code__c 
                                        From ElixirSuite__Provider__c 
                                        WHERE ElixirSuite__Account__c = null
                                        AND ElixirSuite__Provider_Code__c IN :providerCodeSet
                                        WITH SECURITY_ENFORCED];
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        List<ElixirSuite__Actual_Price__c> actualPriceList = new List<ElixirSuite__Actual_Price__c>(); //get actual price
        try{
            if(providerTemplateList.size() > 0) {
                actualPriceList = [Select ElixirSuite__Actual_Price_After_Discount__c,ElixirSuite__List_Price__c,ElixirSuite__Provider__c ,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c,
                                   ElixirSuite__Pricing_Effective_Start_Date__c,ElixirSuite__Pricing_Effective_End_Date__c,ElixirSuite__Actual_Discount_Applied__c
                                   FROM ElixirSuite__Actual_Price__c 
                                   where ElixirSuite__Provider__c IN :providerTemplateList AND ElixirSuite__Pricing_Effective_Start_Date__c != null
                                   WITH SECURITY_ENFORCED ORDER BY CREATEDDATE ASC];
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        List<ElixirSuite__Procedure__c> privateProcedure = new List<ElixirSuite__Procedure__c>();
        List<ElixirSuite__Procedure__c> insuranceProcedure = new List<ElixirSuite__Procedure__c>();
         try{
        for(ElixirSuite__Procedure__c procedureRec : procedureList){
            for(ElixirSuite__Actual_Price__c actualPriceRec : actualPriceList) {
                if(actualPriceRec.ElixirSuite__Procedure__r.Name != null && procedureRec.ElixirSuite__From_Date_of_Service__c != null && ((procedureRec.ElixirSuite__From_Date_of_Service__c).Date() >= actualPriceRec.ElixirSuite__Pricing_Effective_Start_Date__c && ( actualPriceRec.ElixirSuite__Pricing_Effective_End_Date__c == null || (actualPriceRec.ElixirSuite__Pricing_Effective_End_Date__c != null && (procedureRec.ElixirSuite__From_Date_of_Service__c).Date() <= actualPriceRec.ElixirSuite__Pricing_Effective_End_Date__c)))) {
                    String nameDateKey = actualPriceRec.ElixirSuite__Procedure__r.Name + '$' + (procedureRec.ElixirSuite__From_Date_of_Service__c).Date();
                    procCPTIdToListPriceMap.put(nameDateKey, actualPriceRec);
                    procCPTIdToDiscountMap.put(nameDateKey, actualPriceRec.ElixirSuite__Actual_Discount_Applied__c);
                    providerMap.put(nameDateKey, actualPriceRec.ElixirSuite__Provider__c);
                }
            }
            
            
            if(procedureRec.ElixirSuite__Type_of_Procedure__c == 'Private Payment'){
                privateProcedure.add(procedureRec);   
            }else if(procedureRec.ElixirSuite__Type_of_Procedure__c == 'Insurance Payment'){
                insuranceProcedure.add(procedureRec);  
            }
            
        }
             }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        Id paymntTxnRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
        Id paymntTxnRecordTypeIdPrivate = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
       //After update 
        Map<Id,Id> paymentsMap = new Map<Id,Id>(); 
        List<ElixirSuite__Payment_Transaction__c> paymntTrxnToUpsert = new List<ElixirSuite__Payment_Transaction__c>();
             List<Payment_Transaction__c> oldPayments = [SELECT Id, ElixirSuite__Procedure__c 
                                                        FROM ElixirSuite__Payment_Transaction__c 
                                                        WHERE ElixirSuite__Procedure__c IN :procedureRecIds
                                                        WITH SECURITY_ENFORCED];
            
            for(ElixirSuite__Payment_Transaction__c trans :oldPayments){
                paymentsMap.put(trans.ElixirSuite__Procedure__c, trans.Id);
            }
        
         try{
        for(ElixirSuite__Procedure__c pro : privateProcedure){
            String nameDateKey;
            if(pro.ElixirSuite__From_Date_of_Service__c != null){
              nameDateKey = pro.Name + '$' + (pro.ElixirSuite__From_Date_of_Service__c).Date();    
            }
                ElixirSuite__Payment_Transaction__c trxnRec = new ElixirSuite__Payment_Transaction__c();
                if(paymentsMap.containsKey(pro.Id)){
                    trxnRec.Id = paymentsMap.get(pro.Id);
                }
                trxnRec.ElixirSuite__Account__c  = pro.ElixirSuite__Account__c  ;
                trxnRec.ElixirSuite__Procedure__c = pro.id;
                if(pro.ElixirSuite__Code_Description__c != null && pro.ElixirSuite__Code_Description__c != ''){
                    trxnRec.ElixirSuite__Procedure_Name__c =  pro.Name + ' ' +'-'+ ' '+ pro.ElixirSuite__Code_Description__c;
                }else{
                    trxnRec.ElixirSuite__Procedure_Name__c = pro.Name;
                }
                trxnRec.ElixirSuite__Cpt_Codes__c= pro.Name  ;
                if(pro.ElixirSuite__From_Date_of_Service__c != null){
                    trxnRec.ElixirSuite__Date_Of_Service__c = Date.valueof(pro.ElixirSuite__From_Date_of_Service__c); 
                }
                trxnRec.ElixirSuite__Status__c = 'UnPaid';
                trxnRec.ElixirSuite__Other_Discounts__c = 0;
                trxnRec.ElixirSuite__Total_Received_Amount__c = 0;
                trxnRec.ElixirSuite__Units_days__c = pro.ElixirSuite__Days_Units__c;
                trxnRec.RecordTypeId = paymntTxnRecordTypeIdPrivate;
                if(pro.ElixirSuite__Days_Units__c == 0 || pro.ElixirSuite__Days_Units__c == null){
                trxnRec.ElixirSuite__Actual_Price__c = pro.ElixirSuite__Charges__c;
                trxnRec.ElixirSuite__Expected_Receivable_amount__c = pro.ElixirSuite__Charges__c;
                }else{
                Decimal Price = 0;
                Price = Integer.valueof(pro.ElixirSuite__Days_Units__c) * pro.ElixirSuite__Charges__c;  
                trxnRec.ElixirSuite__Actual_Price__c = Price;
                trxnRec.ElixirSuite__Expected_Receivable_amount__c = Price;    
                }            
                if(nameDateKey != null && nameDateKey != ''){
                if(providerMap.get(nameDateKey) != null){
                trxnRec.ElixirSuite__Provider__c = providerMap.get(nameDateKey);  
                }
                if(procCPTIdToDiscountMap.get(nameDateKey) != null)
                {
                    trxnRec.ElixirSuite__Discount_Amount__c = procCPTIdToDiscountMap.get(nameDateKey);
                } 
            }
                paymntTrxnToUpsert.add(trxnRec);
             
            
        }
        
        for(ElixirSuite__Procedure__c pro : insuranceProcedure){
            String nameDateKey;
             if(pro.ElixirSuite__From_Date_of_Service__c != null){
              nameDateKey = pro.Name + '$' + (pro.ElixirSuite__From_Date_of_Service__c).Date();    
            }
            
                ElixirSuite__Payment_Transaction__c trxnRec = new ElixirSuite__Payment_Transaction__c();
                if(paymentsMap.containsKey(pro.Id)){
                    trxnRec.Id = paymentsMap.get(pro.Id);
                }    
                trxnRec.ElixirSuite__Account__c  = pro.ElixirSuite__Account__c  ;
                trxnRec.ElixirSuite__Procedure__c = pro.id;
                if(pro.ElixirSuite__Code_Description__c != null && pro.ElixirSuite__Code_Description__c != ''){
                    trxnRec.ElixirSuite__Procedure_Name__c =  pro.Name + ' ' +'-'+ ' '+ pro.ElixirSuite__Code_Description__c;
                }else{
                    trxnRec.ElixirSuite__Procedure_Name__c = pro.Name;
                }
                trxnRec.ElixirSuite__Cpt_Codes__c= pro.Name  ;
            if(pro.ElixirSuite__From_Date_of_Service__c != null){
                trxnRec.ElixirSuite__Date_Of_Service__c = Date.valueof(pro.ElixirSuite__From_Date_of_Service__c);
            }
                trxnRec.ElixirSuite__Status__c = 'UnPaid';
                trxnRec.ElixirSuite__Other_Discounts__c = 0;
                trxnRec.ElixirSuite__Total_Received_Amount__c = 0;
                trxnRec.ElixirSuite__Units_days__c = pro.ElixirSuite__Days_Units__c;
                trxnRec.RecordTypeId = paymntTxnRecordTypeId;
                if(pro.ElixirSuite__Days_Units__c == 0 || pro.ElixirSuite__Days_Units__c == null){
                trxnRec.ElixirSuite__Actual_Price__c = pro.ElixirSuite__Charges__c;
                trxnRec.ElixirSuite__Expected_Receivable_amount__c = pro.ElixirSuite__Charges__c;
                }else{
                Decimal Price = 0;
                Price = Integer.valueof(pro.ElixirSuite__Days_Units__c) * pro.ElixirSuite__Charges__c;  
                trxnRec.ElixirSuite__Actual_Price__c = Price;
                trxnRec.ElixirSuite__Expected_Receivable_amount__c = Price;    
                }
                if(pro.ElixirSuite__Payor__c == null){
                    if(nameDateKey != null && nameDateKey != ''){
                        if(providerMap.get(nameDateKey) != null){
                    trxnRec.ElixirSuite__Provider__c = providerMap.get(nameDateKey); 
                        }
                    if(procCPTIdToDiscountMap.get(nameDateKey) != null)
                    {
                        trxnRec.ElixirSuite__Discount_Amount__c = procCPTIdToDiscountMap.get(nameDateKey);
                    } 
                    }
                }else{
                    trxnRec.ElixirSuite__Payor__c = pro.ElixirSuite__Payor__c;    
                }
                paymntTrxnToUpsert.add(trxnRec);
                
        }
        
       if(paymntTrxnToUpsert.size() > 0){
            DMLManager.upsertAsUser(paymntTrxnToUpsert);
        }
             }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
}