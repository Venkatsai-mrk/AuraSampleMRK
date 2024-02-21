public with sharing class ElixirOEM_AttachEraLineItemHelper {
    @AuraEnabled 
    public static AttachClaimInitWrapper getClaimLineItems(String claimId){
        AttachClaimInitWrapper toRet = new AttachClaimInitWrapper();
        try{
        String additionFieldsPrefix = ' WHERE ElixirSuite__Claim__c =: claimId';
        //Added two extra fields by Anusha - Name,code Description to below otherfieldsaddition String - LX3-5744
        String otherFieldsAddition = ',ElixirSuite__Claim__r.ElixirSuite__Payor__c,ElixirSuite__Claim__r.ElixirSuite__Payor__r.Name ,ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c ';  
        String clmLineItemQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Claim_Line_Items__c',otherFieldsAddition,additionFieldsPrefix+'');
        ElixirOEM_TimelineHelper.mDebugUntruncated(clmLineItemQuery);
        toRet.allRelatedClaimLineItem = Database.query(clmLineItemQuery);
        ElixirSuite__Claim_Line_Items__c clm = toRet.allRelatedClaimLineItem[0];
            string payerName;
            if(clm.ElixirSuite__Claim__r.ElixirSuite__Payor__c != null){
                payerName = clm.ElixirSuite__Claim__r.ElixirSuite__Payor__r.Name;
            }
        toRet.mapOfCodeToDesciption = getReasonListFromMDT(payerName);
        }
        catch(Exception e){ExceptionLog.logError(e);}
        return toRet;
    }
    public class AttachClaimInitWrapper{
        @AuraEnabled public ElixirSuite__Claim_Line_Items__c[] allRelatedClaimLineItem;
        @AuraEnabled public Map<String,String> mapOfCodeToDesciption;
    }
    public static  Map<String,String> getReasonListFromMDT(String payerName){
        String res;
        Map<String,String> mapOfCodeToDesciption = new Map<String,String>();
String searchKey = '%' + payerName + '%';
        try{
        Map<String, ElixirSuite__Adjustment_Reason_Code__mdt> mapEd;
            mapEd   = new Map<String, ElixirSuite__Adjustment_Reason_Code__mdt>([SELECT MasterLabel, ElixirSuite__Description__c, ElixirSuite__Payer__c FROM ElixirSuite__Adjustment_Reason_Code__mdt
                                                                                                                                WHERE ElixirSuite__Payer__c like:searchKey OR ElixirSuite__Payer__c like 'ALL']);
          
        for(String nameEmailDomain : mapEd.keySet()){
if(mapEd.get(nameEmailDomain).ElixirSuite__Description__c != null){
            res = mapEd.get(nameEmailDomain).MasterLabel + '-'+mapEd.get(nameEmailDomain).ElixirSuite__Description__c;
}else{
                    res = mapEd.get(nameEmailDomain).MasterLabel;
                }
            mapOfCodeToDesciption.put(nameEmailDomain, res);            
        }
        }
        catch(Exception e){ExceptionLog.logError(e);}
        return mapOfCodeToDesciption;
    }
}