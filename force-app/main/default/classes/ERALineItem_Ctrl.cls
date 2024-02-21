/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ERALineItem_Ctrl {

    @AuraEnabled
    public static ERALineWrapper getERALineItemRecord(String recordId){
        
        ElixirSuite__ERA_Line_Item__c era = [Select id,
                                             ElixirSuite__Adjustment_Amount_1__c, ElixirSuite__Adjustment_Amount_2__c, ElixirSuite__Adjustment_Amount_3__c, ElixirSuite__Adjustment_Amount_4__c, ElixirSuite__Adjustment_Amount_5__c, ElixirSuite__Adjustment_Amount_6__c,
                                             ElixirSuite__Code_1__c, ElixirSuite__Code_2__c, ElixirSuite__Code_3__c, ElixirSuite__Code_4__c, ElixirSuite__Code_5__c, ElixirSuite__Code_6__c, 
                                             ElixirSuite__Group_1__c, ElixirSuite__Group_2__c, ElixirSuite__Group_3__c, ElixirSuite__Group_4__c, ElixirSuite__Group_5__c, ElixirSuite__Group_6__c,
                                             ElixirSuite__Adjustment_Amount_7__c, ElixirSuite__Adjustment_Amount_8__c, ElixirSuite__Code_7__c, ElixirSuite__Code_8__c, ElixirSuite__Group_7__c, ElixirSuite__Group_8__c,ElixirSuite__Adjustment_Remark_Codes__c,
                                             ElixirSuite__Proc_code__c,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure_Charge__c,ElixirSuite__Paid__c,ElixirSuite__Total_Allowed_Amount__c,ElixirSuite__Total_Adjustment_Amount__c,ElixirSuite__Patient_Responsibility__c,ElixirSuite__Other_Insurance_Responsibility__c,ElixirSuite__Provider_Adjustment__c
                                             from ElixirSuite__ERA_Line_Item__c 
                                             where id =: recordId WITH SECURITY_ENFORCED];
        String claimName;
        String accountName;
        String headerLabel='';
String payerName;
        try{
        if(era!=null)
        {
            if(!String.isBlank(era.ElixirSuite__Claim_Line_Items__c)){
                String claimId = era.ElixirSuite__Claim_Line_Items__c;
                ElixirSuite__Claim_Line_Items__c claimline =[Select id,ElixirSuite__Total_Allowed_Amount__c,ElixirSuite__Claim__c from ElixirSuite__Claim_Line_Items__c  where Id =: claimId WITH SECURITY_ENFORCED];
                
                if(claimline!=null){
                    
                    if(!String.isBlank(claimline.ElixirSuite__Claim__c)){
                        ElixirSuite__Claim__c claim = [Select id,Name,ElixirSuite__Patient_Name__c,ElixirSuite__Account__r.Name, ElixirSuite__Payor__r.Name from ElixirSuite__Claim__c where Id =: claimline.ElixirSuite__Claim__c WITH SECURITY_ENFORCED];
                        
                        if(claim!=null){
                            claimName = claim.Name;
                        }
                        if(claim!=null){
                            accountName = claim.ElixirSuite__Patient_Name__c;
                        }
if(claim!=null){
                            payerName = claim.ElixirSuite__Payor__r.Name;
                            system.debug('payerName@'+payerName);
                        }
                        headerLabel = accountName!=null ? accountName : '';
                        headerLabel+=' - ';
                        headerLabel += claimName!=null ? claimName :'';
                        headerLabel+=' - ';
                    }
                    
                }
            }
            headerLabel += era.ElixirSuite__Proc_code__c!=null ?  era.ElixirSuite__Proc_code__c :'';
        }
        }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
        String res;
        Map<String,String> mapOfCodeToDesciption = new Map<String,String>();
        mapOfCodeToDesciption = getReasonCodesFromMDT(payerName);
        
        ERALineWrapper wrapper = new ERALineWrapper();
        wrapper.mapOfCodeToDesciption = mapOfCodeToDesciption;
        wrapper.SupplementalCode = MasterProblemListController.fetchPickListValue('ElixirSuite__ERA_Line_Item__c','ElixirSuite__Adjustment_Group_Code__c'); 
        wrapper.AdjustmentCode = MasterProblemListController.fetchPickListValue('ElixirSuite__ERA_Line_Item__c','ElixirSuite__Adjustment_Group_Code__c'); 
        wrapper.eraLineItem = era;
        wrapper.headerLabel =headerLabel;
        
        return wrapper;
    }
    @AuraEnabled
    public static Map<String,String> getReasonCodesFromMDT(String payerName){
        String res;
        Map<String,String> mapOfCodeToDesciption = new Map<String,String>();
String searchKey = '%' + payerName + '%';
        try{
        Map<String, ElixirSuite__Adjustment_Reason_Code__mdt>   mapEd   = new Map<String, ElixirSuite__Adjustment_Reason_Code__mdt>([SELECT MasterLabel, ElixirSuite__Description__c, ElixirSuite__Payer__c FROM ElixirSuite__Adjustment_Reason_Code__mdt
                                                                                                                                WHERE ElixirSuite__Payer__c like:searchKey OR ElixirSuite__Payer__c like 'ALL']);
            
        
        for(String nameEmailDomain : mapEd.keySet()){
if(mapEd.get(nameEmailDomain).ElixirSuite__Description__c !=null){
            res = mapEd.get(nameEmailDomain).MasterLabel + '-'+mapEd.get(nameEmailDomain).ElixirSuite__Description__c;
}else{
                res = mapEd.get(nameEmailDomain).MasterLabel;
            }
            mapOfCodeToDesciption.put(nameEmailDomain, res);
            
        }
        }
            catch(Exception e){
            ExceptionLog.logError(e);
        }        
        return mapOfCodeToDesciption;
    }
    
   /* @AuraEnabled
    public static string saveERALineItemRecord(String recordId,String procedureCode,Integer BilledAmount,Integer PaidAmt,Integer AllowedAmt,Integer patientResponsibility,String AdjustmentSummary){
        
        String claimId;
        ElixirSuite__ERA_Line_Item__c eraLine = [SELECT Id, Name,ElixirSuite__Adjustment_Amount_1__c,ElixirSuite__Patient_Responsibility__c, ElixirSuite__Adjustment_Amount_2__c, ElixirSuite__Adjustment_Amount_3__c, ElixirSuite__Adjustment_Amount_4__c, ElixirSuite__Adjustment_Amount_5__c, ElixirSuite__Adjustment_Amount_6__c, ElixirSuite__Adjustment_Code_1__c, ElixirSuite__Adjustment_Code_2__c, ElixirSuite__Adjustment_Code_3__c, ElixirSuite__Adjustment_Code_4__c, ElixirSuite__Adjustment_Code_5__c, ElixirSuite__Adjustment_Code_6__c, ElixirSuite__Claim_Line_Items__c, ElixirSuite__Code_1__c, ElixirSuite__Code_2__c, ElixirSuite__Code_3__c, ElixirSuite__Code_4__c, ElixirSuite__Code_5__c, ElixirSuite__Code_6__c, ElixirSuite__Group_1__c, ElixirSuite__Group_2__c, ElixirSuite__Group_3__c, ElixirSuite__Group_4__c, ElixirSuite__Group_5__c, ElixirSuite__Group_6__c, ElixirSuite__Paid__c, ElixirSuite__Proc_code__c, ElixirSuite__Status__c, ElixirSuite__Total_Adjustment_Amount__c, ElixirSuite__Total_Allowed_Amount__c, ElixirSuite__Total_Charge__c
                                                 FROM ElixirSuite__ERA_Line_Item__c  where Id =: recordId WITH SECURITY_ENFORCED];
        //claimId = eraLine.ElixirSuite__Claim_Line_Items__c;
        //ElixirSuite__Claim_Line_Items__c claimline =[Select id,ElixirSuite__Proc_code__c,ElixirSuite__Procedure_Charge__c,ElixirSuite__Amount_Paid_by_Insurance__c,ElixirSuite__Contracted_Amount__c,ElixirSuite__Total_Adjustment__c,ElixirSuite__Total_Allowed_Amount__c from ElixirSuite__Claim_Line_Items__c  where Id =: claimId WITH SECURITY_ENFORCED];
        
        eraLine.ElixirSuite__Proc_code__c = procedureCode;
        eraLine.ElixirSuite__Total_Allowed_Amount__c = AllowedAmt;
        eraLine.ElixirSuite__Paid__c = PaidAmt;
        eraLine.ElixirSuite__Charge__c = BilledAmount;
        eraLine.ElixirSuite__Patient_Responsibility__c = patientResponsibility;
        deserializeAdjustmentCodeTable((List<AdjustmentSummaryClass>) JSON.deserializeStrict(AdjustmentSummary,List<AdjustmentSummaryClass>.class),eraLine); 
        if (Schema.sObjectType.ElixirSuite__ERA_Line_Item__c.isUpdateable())
        {
            update eraLine;
        }
                                                  /* if(claimline!=null){
                                                       claimline.ElixirSuite__Proc_code__c = procedureCode;
                                                       claimLine.ElixirSuite__Contracted_Amount__c =ContractedAmt;
                                                       claimLine.ElixirSuite__Total_Adjustment__c =AdjustmentAmt;
                                                       claimLine.ElixirSuite__Total_Allowed_Amount__c =AllowedAmt;
                                                       claimLine.ElixirSuite__Procedure_Charge__c =BilledAmount;
                                                   }
                                                   
                                                   
                                                   if(Schema.sObjectType.ElixirSuite__Claim_Line_Items__c.isUpdateable()){
                                                       update claimline;
                                                   }*/


                                                  
       /* return 'success';
    }
    public static void deserializeAdjustmentCodeTable( List<AdjustmentSummaryClass> adjCodeTableValues,ElixirSuite__ERA_Line_Item__c eraLine){
        Integer i = 1;
        for(integer j=0;j<adjCodeTableValues.size(); j++){
            
            eraLine.put('ElixirSuite__Group_'+i+'__c',String.valueOf(adjCodeTableValues[j].SelectedAdjustmentGroupCode));    
            eraLine.put('ElixirSuite__Code_'+i+'__c',String.valueOf(adjCodeTableValues[j].SelectedAdjustmentReason));    
            eraLine.put('ElixirSuite__Adjustment_Amount_'+i+'__c',Integer.valueOf(adjCodeTableValues[j].AdjustmentAmount));    
            i++;                
            
        }
    }
    @AuraEnabled
    public static void deleteEraLineItem(String recordId){
        
        ElixirSuite__ERA_Line_Item__c eraLine = [SELECT Id, Name FROM ElixirSuite__ERA_Line_Item__c  where Id =: recordId WITH SECURITY_ENFORCED];
                                                 
        if (Schema.sObjectType.ElixirSuite__ERA_Line_Item__c.isDeletable())
        {
            delete eraLine;
        }
    }
    
    
    
    public class AdjustmentSummaryClass{
        public string AdjustmentAmount;
        public string SelectedAdjustmentGroupCode;
        public string SelectedAdjustmentReason;
    }*/
    
    public class ERALineWrapper{
        @AuraEnabled public   Map<String,String> mapOfCodeToDesciption;
        @AuraEnabled public   Map<String,String> SupplementalCode;
        @AuraEnabled public   Map<String,String> AdjustmentCode;
        @AuraEnabled public   ElixirSuite__ERA_Line_Item__c eraLineItem;
        @AuraEnabled public String headerLabel;
    }
    
    //added by Neha
    @AuraEnabled
    public static List <String> getPiklistValues() {
        List<String> plValues = new List<String>();
         
        //Get the object type from object name. Here I've used custom object Book.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('ElixirSuite__ERA_Line_Item__c');
         
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
         
        //Get the specific field information from fields name. Here I've used custom field Genre__c of Book object.
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('ElixirSuite__Adjustment_Group_Code__c').getDescribe();
         
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
         
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }
        plValues.sort();
        return plValues;
    }
}