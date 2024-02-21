/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-16-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SendClaimController {
    @AuraEnabled
    public static string updateClaims(String claimLst){
String toastMsg;
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='NewClaimMDIntegration'];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null){
            Callable calloutclaimMd = (Callable) Type.forName(virtualClassName).newInstance();
            calloutclaimMd.call('RefreshClaimMDCallout', new Map<String, Object> {
                'claimLst' => claimLst
                    });
            
        }else{
            if(!Test.isRunningTest()){
            throw new AuraHandledException('Please configure a clearing house to send this claim.Contact your admin for more details');
            }
        }
        toastMsg =Label.Claim_custom_error;
        return toastMsg;
    }
    @AuraEnabled
    public static Duplicate isDuplicateError(String claimLst){
        Boolean duplicate = false;
        List<String> claimIdsSet = splitIds(claimLst);
        List<Claim__c> allClaims = new List<Claim__c>([SELECT Id,Claim_Status__c
                                                       FROM Claim__c 
                                                       WHERE Id IN :claimIdsSet WITH SECURITY_ENFORCED 
                                                       LIMIT 50000]);
        for(Claim__c c :allClaims){  
            if(String.isBlank(c.Claim_Status__c) ||  c.Claim_Status__c== 'Sent to Clearing house'){     
                c.Claim_Status__c = 'Ready to Submit';
                duplicate = true;       
            }       
        }
        
        DMLManager.updateAsUser(allClaims);
        
        Id viewId;
        List<ListView> views = [SELECT Id, DeveloperName, SobjectType 
                                FROM ListView 
                                WHERE DeveloperName='Ready_To_Submit_Claims' WITH SECURITY_ENFORCED LIMIT 1];
        if(views!=null && views.size()>0){
            viewId = views[0].Id;
        }
        Duplicate dup = new Duplicate();
        dup.duplicate = duplicate;
        dup.viewId = viewId;
        return dup;
    }
    @AuraEnabled
    public static Id viewId(){
        List<ListView> views = [SELECT Id, DeveloperName, SobjectType 
                                FROM ListView 
                                WHERE DeveloperName='Ready_To_Submit_Claims' WITH SECURITY_ENFORCED LIMIT 1];
        system.debug(views);
        Id viewId = null;
        if(views!=null && views.size()>0){
            viewId = views[0].Id;
        }
        return viewId;
    }
    public class Duplicate{
        @AuraEnabled public Boolean duplicate;
        @AuraEnabled public String viewId;
    }
    @AuraEnabled
    public static Id viewIdAll(){
        List<ListView> views = [SELECT Id, DeveloperName, SobjectType 
                                FROM ListView 
                                WHERE DeveloperName='All_Claims' WITH SECURITY_ENFORCED LIMIT 1];
        system.debug(views);
        Id viewId = null;
        if(views!=null && views.size()>0){ 
            viewId = views[0].Id;
        }
        return viewId;
    }
    public static void ClaimsValidationforAutoCreation(String claimLst){
       
        List<Claim__c> toSendClaims = new  List<Claim__c>();
        List<String> claimIdsSet = splitIds(claimLst);
        Map<String,Integer> countItems = new Map<String,Integer>();
        List<Claim__c> AllClaims = new List<Claim__c>([SELECT Id,Claim_Status__c,patient_s_state__c,Billing_Provider_Info_NPI__c,payor__r.ElixirSuite__Claim_Processing_via__c
                                                       FROM Claim__c 
                                                       WHERE Id IN :claimIdsSet WITH SECURITY_ENFORCED 
                                                       LIMIT 50000]);
        if(AllClaims.size() > 0){
            Map<Id,List<Claim_Line_Items__c>> mapOfClaimIdToLineItems = lineItems(toSendClaims);
            List<Claim_Line_Items__c> lineItems = new List<Claim_Line_Items__c>();
            try{
                for(List<Claim_Line_Items__c> lineItem :mapOfClaimIdToLineItems.values()){
                    if(lineItem!=null){
                        lineItems.addAll(lineItem);
                    }
                }
                 DMLManager.updateAsUser(lineItems);
            }
            catch(Exception e){
                ExceptionLog.logError(e);
            }
        }
        if(AllClaims.size() > 0){
                            SendClaimController.postClaimsToClearingHouse(claimLst);   
            } 
        }
        public static void postClaimsToClearingHouse(String claimLst){       
        List<String> claimIdsSet = splitIds(claimLst);
        Schema.DescribeSObjectResult result = Claim__c.sObjectType.getDescribe();
        List<String> apiNames =  new List<String>(result.fields.getMap().keySet());
        apiNames.add('ElixirSuite__Account__r.ElixirSuite__First_Name__c');
        apiNames.add('ElixirSuite__Account__r.ElixirSuite__Last_Name__c');
        String query = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNames,','))  + ',payor__r.Payer_Code__c' + ' FROM Claim__c ';
        if(!Test.isRunningTest()){
            query+= 'WHERE Id in: claimIdsSet';
        }   
        List<Claim__c> listOfClaims = (List<Claim__c>)Database.query(query);
        Map<Id,List<Claim_Line_Items__c>> mapOfClaimIdToLineItems = new Map<Id,List<Claim_Line_Items__c>>();
        if(listOfClaims!=null && listOfClaims.size()>0){
            mapOfClaimIdToLineItems = lineItems(listOfClaims);
        } 
        
        if(mapOfClaimIdToLineItems!=null && mapOfClaimIdToLineItems.size()>0){
            validationCheck(mapOfClaimIdToLineItems, listOfClaims);
        }
    }  
    private static void validationCheck(Map<Id,List<Claim_Line_Items__c>> mapOfClaimIdToLineItems, List<Claim__c> listOfClaims){
                Map<Id,Claim__c> mapOfClaims = new Map<Id,Claim__c>(listOfClaims);
        Map<Id,List<Claim_Line_Items__c>> claimWithClaimLineItem = new  Map<Id,List<Claim_Line_Items__c>>();
                for(Id claimId :mapOfClaimIdToLineItems.keySet()){
                        Claim__c claimRecord = mapOfClaims.get(claimId);
            List<Claim__c> claimLstRec = new List<Claim__c>();
            claimLstRec.add(claimRecord);
                        String validationMessage = claimValidationHelper.validate1(claimLstRec,mapOfClaimIdToLineItems.get(claimId)); //Anusha - Start -09/11/22 
            
        }
    }
     
    public static Map<Id,List<Claim_Line_Items__c>> lineItems(List<Claim__c> listOfClaims){
        Map<Id,List<Claim_Line_Items__c>> mapOfClaimIdToLineItems = new Map<Id,List<Claim_Line_Items__c>>();
        try{
            if(listOfClaims!=null && listOfClaims.size()>0){
                Schema.DescribeSObjectResult result = Claim_Line_Items__c.sObjectType.getDescribe();
                List<String> apiNames =  new List<String>(result.fields.getMap().keySet());
                String queryForLineItems = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNames,','))  + ' FROM  Claim_Line_Items__c '+
                    'WHERE ElixirSuite__Claim__c IN :listOfClaims ORDER BY CreatedDate DESC';
                // Creation of map for Claim to List of Claim Line Items 
                for(Claim_Line_Items__c lineItemRecord :Database.query(queryForLineItems)){ // Queried directly in loop to avoid LIMIT 50000 error
                    Id keyForMapOfClaimIdToLineItems = lineItemRecord.Claim__c;
                    system.debug(keyForMapOfClaimIdToLineItems);
                    if(mapOfClaimIdToLineItems.containsKey(keyForMapOfClaimIdToLineItems)){
                        List<Claim_Line_Items__c> itemsToAdd = mapOfClaimIdToLineItems.get(keyForMapOfClaimIdToLineItems);
                        Integer totalItems = itemsToAdd.size() + 1;
                        lineItemRecord.Integration_Order__c = totalItems;
                        itemsToAdd.add(lineItemRecord);
                    }else{
                        lineItemRecord.Integration_Order__c = 1;
                        mapOfClaimIdToLineItems.put(keyForMapOfClaimIdToLineItems,new List<Claim_Line_Items__c>{lineItemRecord});
                    }
                }
            } 
            if(mapOfClaimIdToLineItems.size()==0){
                if(listOfClaims!=null && listOfClaims.size()>0){
                    for(Claim__c claim :listOfClaims){
                        mapOfClaimIdToLineItems.put(claim.Id, new List<Claim_Line_Items__c>{});
                    }
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return mapOfClaimIdToLineItems;
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