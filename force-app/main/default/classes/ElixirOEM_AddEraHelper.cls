public with sharing class ElixirOEM_AddEraHelper {
    
    @AuraEnabled 
    public static  ElixirSuite__Payor__c[] payorList(String searchKeyWord){
        String searchKey = '%' + searchKeyWord + '%';               
        ElixirSuite__Payor__c[] recordLst = [SELECT ID,Name FROM ElixirSuite__Payor__c where Name 
                                             LIKE: searchKey with security_enforced];
        return recordLst;
    } 

    @AuraEnabled
    public static DefWrapper getPaymentMethod(){
        
        DefWrapper def = new DefWrapper();
        String defaultVal;
        Schema.DescribeFieldResult F = ElixirSuite__EOB__c.ElixirSuite__Payment_Method__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = F.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals) {
            if (pv.isDefaultValue()) {
                defaultVal = pv.getValue();
            }    
        }
        
        def.defPaymentMethodValue = defaultVal;
        
        return def;
        
    }
    
    public class DefWrapper{
        @AuraEnabled public String defPaymentMethodValue;
    }
    
    @AuraEnabled 
    public static ElixirSuite__Claim__c[] queryAllClaims(String patientId,String claimName,String payorId,String[] existingClaim){
        String additionFieldsPrefix = buildAdditionalQuery(patientId,claimName,payorId,existingClaim);  
        String otherFieldsAddition = ' ,ElixirSuite__Account__r.Name '; 
        String clmQuery = formulateQueryString('ElixirSuite__Claim__c',otherFieldsAddition,additionFieldsPrefix+' ORDER BY ElixirSuite__Account__r.Name ');
        // ElixirOEM_TimelineHelper.mDebugUntruncated(clmQuery);
        return Database.query(clmQuery);
    }
    @AuraEnabled 
    public static Map<Id,List<ElixirSuite__EOB__c>> fetchAllRelatedERA(List<String> claimIdArr){   
        System.debug('claimIdArr '+claimIdArr);
        Map<Id,List<ElixirSuite__EOB__c>> idLstMap = new Map<Id,List<ElixirSuite__EOB__c>>();
        ElixirSuite__EOB__c[] allEOBs = [SELECT Id, ElixirSuite__Claim__c FROM ElixirSuite__EOB__c
                                         WHERE ElixirSuite__Claim__c IN : claimIdArr WITH SECURITY_ENFORCED];
        Map<Id,List<ElixirSuite__EOB__c>> claimEOBMap = new Map<Id,List<ElixirSuite__EOB__c>>();
        for(ElixirSuite__EOB__c rec : allEOBs){
            if(claimEOBMap.containsKey(rec.ElixirSuite__Claim__c)){
                claimEOBMap.get(rec.ElixirSuite__Claim__c).add(rec); 
            }else{
                List<ElixirSuite__EOB__c> innerLst = new List<ElixirSuite__EOB__c>();
                innerLst.add(rec);
                claimEOBMap.put(rec.ElixirSuite__Claim__c,innerLst);
            }
        }   
        return claimEOBMap;
    }
    public static  String buildAdditionalQuery(String patientId,String claimName,String payorId,String[] existingClaim){
        if(String.isNotBlank(patientId) && String.isNotBlank(claimName)){
            System.debug('AND FILTER');
         String prefixParamHybrid = ' WHERE ElixirSuite__Account__c =:  patientId'+  ' AND ' + ' Name =:claimName AND ElixirSuite__Payor__c=:payorId AND ID NOT IN : existingClaim'; 

            
            return prefixParamHybrid;
        }
        else if(String.isNotBlank(claimName)){
            System.debug('OR FILTER with claimName');
           String prefixClaimName = ' WHERE Name =:claimName AND ElixirSuite__Payor__c=:payorId AND ID NOT IN : existingClaim'; 
    
            return prefixClaimName;
        }
        else if(String.isNotBlank(patientId)){
            System.debug('OR FILTER with patientId');
          String prefixPatientId = ' WHERE ElixirSuite__Account__c =:patientId AND ElixirSuite__Payor__c=:payorId AND ID NOT IN : existingClaim'; 

            return prefixPatientId;
        }
        else return '';
    }
    public static String formulateQueryString(String objectName,String anyOtherFields,String lastAttributes) {
        String fieldApiNames =  ElixirOEM_TimelineHelper.getAllFieldsNameOfObject(objectName)+anyOtherFields;
        fieldApiNames+=' FROM '+ String.escapeSingleQuotes(objectName)+lastAttributes;
        return fieldApiNames;
    }
    @AuraEnabled 
    public static WrapperForClaimFields fetchPicklistValuesForClaimFields(String objectName,String[] lstOfFields,String claimId) {
        WrapperForClaimFields toRet = new WrapperForClaimFields();
        if(lstOfFields!=null && lstOfFields.size()>0){
            toRet.mapOfEraStatusCode =   MasterProblemListController.fetchPickListValue('ElixirSuite__EOB__c',lstOfFields[0]);
            toRet.mapOfActionsToBeTaken =  MasterProblemListController.fetchPickListValue('ElixirSuite__EOB__c',lstOfFields[1]); 
            toRet.defaultValueForActionTBTField = fetchDefaultValue();
        }
        List<Account> accList = new  List<Account>();
        List<Id> accIdList = new List<Id>();
        String payorValue;
        if(claimId != null && claimId != ''){
            List<Claim__c> clmList = [Select Id, Name, Account__c,ElixirSuite__Payer_Order__c From Claim__c where Id=:claimId WITH SECURITY_ENFORCED LIMIT 1 ];
            String accId;
            
            if(clmList != null && clmList.size() >0 && clmList[0].Account__c != null && clmList[0].ElixirSuite__Payer_Order__c != null){
               accId = clmList[0].Account__c; 
               payorValue = clmList[0].ElixirSuite__Payer_Order__c; 
            }
            if(accId != null && accId !=''){
              accList = [Select Id, Name,(Select id,name from ElixirSuite__VOB__r where ElixirSuite__Status__c ='Active' AND RecordType.DeveloperName='Secondary_VOB' LIMIT 1) from account where id =: accId WITH SECURITY_ENFORCED];
            }
            if(accList[0].ElixirSuite__VOB__r != null && (accList[0].ElixirSuite__VOB__r).size() > 0){
               accIdList.add(accList[0].Id); 
            }
           
        }
        toRet.claimLineItemData = ElixirOEM_AttachEraLineItemHelper.getClaimLineItems(claimId);  
        toRet.SecInsACC = accIdList;
        toRet.payorOrder = payorValue;
        return toRet;
    }
    @AuraEnabled 
    public static WrapperForClaimFields fetchPicklistValuesForObjectMdt(String[] lstOfFields) {
        WrapperForClaimFields toRet = new WrapperForClaimFields();
        if(lstOfFields!=null && lstOfFields.size()>0){
            toRet.mapOfClaimPaymentMethod =   MasterProblemListController.fetchPickListValue('ElixirSuite__EOB__c','ElixirSuite__Payment_Method__c');
            toRet.mapOfAdjustmentgroupCode = MasterProblemListController.fetchPickListValue('ElixirSuite__ERA_Line_Item__c','ElixirSuite__Adjustment_Group_Code__c');  
        }
        //Added by Neha  
        toRet.infoCodePicklistValues = MasterProblemListController.fetchPickListValue('ElixirSuite__ERA_Line_Item__c','ElixirSuite__Adjustment_Remark_Codes__c').values();
        toRet.SuppCodePicklistValues = MasterProblemListController.fetchPickListValue('ElixirSuite__ERA_Line_Item__c','ElixirSuite__Adjustment_Remark_Codes__c').values();
        //
        return toRet;
    }
    public static String fetchDefaultValue(){
        String defaultVal;
        Schema.DescribeFieldResult F = ElixirSuite__EOB__c.ElixirSuite__Action_to_be_Taken__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = F.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals) {
            if (pv.isDefaultValue()) {
                defaultVal = pv.getValue();
            }    
        }
        return defaultVal;
        
    }
    public class WrapperForClaimFields{
        @AuraEnabled public Map<String, String> mapOfEraStatusCode;
        @AuraEnabled public Map<String, String> mapOfClaimPaymentMethod;
        @AuraEnabled public Map<String, String> mapOfAdjustmentgroupCode;
        @AuraEnabled public Map<String, String> mapOfActionsToBeTaken;
        @AuraEnabled public String defaultValueForActionTBTField;
        @AuraEnabled public List<Id> SecInsACC ;//
        @AuraEnabled public ElixirOEM_AttachEraLineItemHelper.AttachClaimInitWrapper claimLineItemData;
        //Added By Neha 
        @AuraEnabled public List<String>infoCodePicklistValues ;
        @AuraEnabled public List<String> SuppCodePicklistValues ;
        //
        @AuraEnabled public String payorOrder;
    }
    public class ParentERADataWrapper{
        public String paymentMethod = '';
        public String reasonForPayment = '';
        public String parentERAHash = '';
    }
    @AuraEnabled 
    public static ElixirOEM_AttachEraLineItemHelper.AttachClaimInitWrapper getClaimLineItemsInParent(String claimId){
        return  ElixirOEM_AttachEraLineItemHelper.getClaimLineItems(claimId);
    }
    
    
    @AuraEnabled 
    public static list<Id> saveERAEOB(ElixirSuite__EOB__c eobParentRecord,String stringifiedTablLst,Boolean isInsert,
                                      Boolean isPosted,String notes, String recommendation)
    {
        System.debug('id '+stringifiedTablLst);
        System.debug('stringifiedTablLst '+JSON.serialize(stringifiedTablLst));
        list<Id> eraIds = new list<Id>();
        if (Schema.sObjectType.ElixirSuite__EOB__c.iscreateable()){
            if(isInsert){
                 DMLManager.insertAsUser(eobParentRecord);
            }
            else{
                 DMLManager.updateAsUser(eobParentRecord);
            }
        }
        ElixirSuite__EOB__c[] nameLst =  [SELECT Name FROM ElixirSuite__EOB__c WHERE ID = : eobParentRecord.Id];
        ParentERADataWrapper flow_sObj = new ParentERADataWrapper();
        flow_sObj.paymentMethod = eobParentRecord.ElixirSuite__Payment_Method__c;
        if(nameLst!=null && nameLst.size()>0){
            flow_sObj.parentERAHash =  nameLst[0].Name;
        }
        
        Map<String,Object> claimIdAndObjectMap = new Map<String,Object>();
        Object[] sObjToPost_JSON = new List<Object>();
        Map<String,List<ElixirSuite__ERA_Line_Item__c>> mapOfParentChildRecords = new Map<String,List<ElixirSuite__ERA_Line_Item__c>>();
        Map<String,Object> mapOfsObjToJSON = new Map<String,Object>();
        ElixirSuite__EOB__c[] childERALst = new List<ElixirSuite__EOB__c>();
        for(Object obj : utilityMapDeserialize(stringifiedTablLst,'childERAtableList')){
            Map<String, Object> mapOfChildEraData = (Map<String, Object>) obj;
            ElixirSuite__EOB__c obj_childERA = new ElixirSuite__EOB__c();
            if ((String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Process as Primary' && 
                 String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Adjustment Writeoff') ||
                (String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Process as Primary' && 
                 String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Patient')){  // PAYMENT POSTING RECORDS GETS FILTERED OUT
                     claimIdAndObjectMap.put(String.valueOf(mapOfChildEraData.get('claimId')),obj);
                 }
            else if((String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Denied' && 
                     String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Adjustment Writeoff') ||
                    (String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Denied' && 
                     String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Patient')){
                         claimIdAndObjectMap.put(String.valueOf(mapOfChildEraData.get('claimId')),obj);
                     }
            obj_childERA.ElixirSuite__Account__c =  String.valueOf(mapOfChildEraData.get('patientId'));
            obj_childERA.ElixirSuite__Claim__c =  String.valueOf(mapOfChildEraData.get('claimId'));
            obj_childERA.ElixirSuite__Payer_Claim__c = String.valueOf(mapOfChildEraData.get('payerClaimHash'));
            obj_childERA.ElixirSuite__ERA_Status_Code__c = String.valueOf(mapOfChildEraData.get('eraStatusCode'));
            obj_childERA.ElixirSuite__Total_Charge__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalBilledAmount'))); // total billed amount
            obj_childERA.ElixirSuite__Total_Contracted_Amt__c= Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalContractedAmt')));
            obj_childERA.ElixirSuite__Total_Allowed__c= Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalAllowedAmt')));
            obj_childERA.ElixirSuite__Total_Adjustment_Amount__c= Decimal.valueOf(String.valueOf(mapOfChildEraData.get('totalAdjustmentAmt')));
            obj_childERA.ElixirSuite__Total_Paid__c= Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt'))); // total paid amt
            obj_childERA.ElixirSuite__Matched_Amount__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('paidAmt')));
            obj_childERA.ElixirSuite__Net_Paid_Amt__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('netPaidAmount')));
            obj_childERA.ElixirSuite__Payment_Status__c = String.valueOf(mapOfChildEraData.get('paymentStatus'));
            obj_childERA.ElixirSuite__Action_to_be_Taken__c = String.valueOf(mapOfChildEraData.get('actionToBeTakenVal'));
            obj_childERA.ElixirSuite__Total_Patient_Responsibility__c = mapOfChildEraData.get('ver_1_toalPatientResp') != null ?
    Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_toalPatientResp'))) : 0;
          //  obj_childERA.ElixirSuite__Total_Patient_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_toalPatientResp')));
            obj_childERA.ElixirSuite__Total_OI_Responsibility__c =  mapOfChildEraData.get('ver_1_totalOtherInsResp') != null ?
    Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_totalOtherInsResp'))) : 0;
           // obj_childERA.ElixirSuite__Total_OI_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfChildEraData.get('ver_1_totalOtherInsResp')));
            obj_childERA.ElixirSuite__EOB__c = eobParentRecord.Id;
            if(isPosted){
                obj_childERA.ElixirSuite__Primary_Posted__c =isPosted;
            }
            obj_childERA.ElixirSuite__Line_Items_Reference_Key__c = String.ValueOf(Integer.valueOf(math.rint(math.random()*1000000))); 
            mapOfsObjToJSON.put(obj_childERA.ElixirSuite__Line_Items_Reference_Key__c,obj);
            childERALst.add(obj_childERA);
            if(mapOfChildEraData.containsKey('lineItemLst')){
                mapOfParentChildRecords.put(obj_childERA.ElixirSuite__Line_Items_Reference_Key__c,deserializeLineItemRecords((List<Object>) mapOfChildEraData.get('lineItemLst')));
                
            }
        }
        //Line 161 added by MEGHNA
        claimMultipiclistUpdate(claimIdAndObjectMap);
        if (Schema.sObjectType.ElixirSuite__EOB__c.isCreateable()){
             DMLManager.insertAsUser(childERALst);
        }
        // added be Neha for LX3-5268/70
        List<Object> eraNotesList = (List<Object>) JSON.deserializeUntyped(notes);
        List<Object> eraRecommendationList = (List<Object>) JSON.deserializeUntyped(recommendation);
        List<ElixirSuite__Notes__c> noteListToUpsert = new List<ElixirSuite__Notes__c>();
        List<ElixirSuite__Recommendation__c> recommendationListToUpsert = new List<ElixirSuite__Recommendation__c>();
        
        System.debug('eraNotesList[i]-- '+notes);
        for(Integer i=0; i<childERALst.size() && i<eraNotesList.size(); i++)
        {
            
            if(eraNotesList[i] != null){
                List<Object> notesList = (List<Object>) eraNotesList[i];
                for(Object notesObj : notesList){
                    Map<String, Object> notesData = (Map<String, Object>) notesObj;
                    if(String.isNotBlank(String.valueOf(notesData.get('ElixirSuite__Follow_Up_Notes__c'))) && String.isNotBlank(String.valueOf(notesData.get('ElixirSuite__Elixir_Assigned_To__c'))) && String.isNotBlank(String.valueOf(notesData.get('ElixirSuite__Elixir_Follow_up_Date__c')))){
                        ElixirSuite__Notes__c obj_notes = new ElixirSuite__Notes__c();  
                        if(notesData.get('Id') != null && String.isNotBlank(String.valueOf(notesData.get('Id')))){
                            obj_notes.Id =  String.valueOf(notesData.get('Id'));
                        }
                        obj_notes.ElixirSuite__Follow_Up_Notes__c =  String.valueOf(notesData.get('ElixirSuite__Follow_Up_Notes__c'));
                        obj_notes.ElixirSuite__Elixir_Assigned_To__c =  String.valueOf(notesData.get('ElixirSuite__Elixir_Assigned_To__c'));    
                        obj_notes.ElixirSuite__Elixir_Follow_up_Date__c =  DateTime.valueOfGmt((String.valueOf(notesData.get('ElixirSuite__Elixir_Follow_up_Date__c'))).replace('T',' '));
                        obj_notes.ElixirSuite__ERA_Notes__c =  String.valueOf(childERALst[i].Id);
                        noteListToUpsert.add(obj_notes);
                    }
                }
            }
            
            if(eraRecommendationList[i] != null){
                List<Object> recommendationList = (List<Object>) eraRecommendationList[i];
                for(Object recObj : recommendationList){
                    Map<String, Object> recommendationData = (Map<String, Object>) recObj;
                    if(String.isNotBlank(String.valueOf(recommendationData.get('ElixirSuite__Elixir_Recommendation__c')))){
                        ElixirSuite__Recommendation__c obj_recommendation = new ElixirSuite__Recommendation__c();  
                        if(recommendationData.get('Id') != null && String.isNotBlank(String.valueOf(recommendationData.get('Id')))){
                            obj_recommendation.Id =  String.valueOf(recommendationData.get('Id'));
                        }
                        obj_recommendation.ElixirSuite__Elixir_Recommendation__c =  String.valueOf(recommendationData.get('ElixirSuite__Elixir_Recommendation__c'));
                        if(String.isNotBlank(String.valueOf(recommendationData.get('ElixirSuite__Elixir_Assign_To__c')))){
                            obj_recommendation.ElixirSuite__Elixir_Assign_To__c =  String.valueOf(recommendationData.get('ElixirSuite__Elixir_Assign_To__c'));
                        }else{
                            obj_recommendation.ElixirSuite__Elixir_Assign_To__c =  null;
                        }
                        obj_recommendation.ElixirSuite__Elixir_ERA__c =  String.valueOf(childERALst[i].Id);
                        recommendationListToUpsert.add(obj_recommendation);
                    }
                }
            }   
        }
        
        if (noteListToUpsert != null && noteListToUpsert.size() > 0 && Schema.sObjectType.ElixirSuite__Notes__c.isUpdateable() &&
            Schema.sObjectType.ElixirSuite__Notes__c.isCreateable()){
            DMLManager.upsertAsUser(noteListToUpsert);
        }
        if (recommendationListToUpsert != null && recommendationListToUpsert.size() > 0 && Schema.sObjectType.ElixirSuite__Recommendation__c.isUpdateable() &&
            Schema.sObjectType.ElixirSuite__Recommendation__c.isCreateable()){
            DMLManager.upsertAsUser(recommendationListToUpsert);  
        }
        //end
        // PAYMENT POSTING LOGIC 
        ElixirSuite__EOB__c[] sObjArrToPost = new List<ElixirSuite__EOB__c>(); // TO POST PAYMENT IF OPTED
        for(ElixirSuite__EOB__c  insertedchildERA : childERALst){
            eraIds.add(insertedchildERA.Id);
            if((insertedchildERA.ElixirSuite__ERA_Status_Code__c == 'Process as Primary' && 
                insertedchildERA.ElixirSuite__Action_to_be_Taken__c == 'Adjustment Writeoff') ||
               (insertedchildERA.ElixirSuite__ERA_Status_Code__c == 'Process as Primary' && 
                insertedchildERA.ElixirSuite__Action_to_be_Taken__c == 'Transfer to Patient'))
            { 
                sObjArrToPost.add(insertedchildERA);
            }
            else if((insertedchildERA.ElixirSuite__ERA_Status_Code__c == 'Denied' && 
                     insertedchildERA.ElixirSuite__Action_to_be_Taken__c == 'Adjustment Writeoff') ||
                    (insertedchildERA.ElixirSuite__ERA_Status_Code__c == 'Denied' && 
                     insertedchildERA.ElixirSuite__Action_to_be_Taken__c == 'Transfer to Patient'))
            {
                sObjArrToPost.add(insertedchildERA); 
            }
            
        }
        ElixirSuite__ERA_Line_Item__c[] sucessInsertERALineItem = insertERALineItemsForchildERA(childERALst,mapOfParentChildRecords);
        
        System.debug('isPosted '+isPosted);
        if(isPosted){
            ElixirOEM_PaymentPostingHelper.postPaymentUtility(sObjArrToPost, flow_sObj, mapOfsObjToJSON);
            ElixirOEM_PaymentPostingHelper.updateClaimPerChildERA(claimIdAndObjectMap,flow_sObj);
            
            
        }
        
        return eraIds;
    }
    //For Claim Live feeds - By meghna
    public static void claimMultipiclistUpdate(Map<String,Object> claimIdAndObjectMap){
        Set<String> adjustmentCodes = new Set<String>();
        Set<String> informationalRemarkCodes = new Set<String>();
        Set<String> supplementalRemarkCodes = new Set<String>();
        ElixirSuite__Claim__c[] allClmToUpdate =  ElixirOEM_PaymentPostingHelper.queryAllClaims(claimIdAndObjectMap.keySet());
        for(ElixirSuite__Claim__c obj : allClmToUpdate){
            Map<String,Object> claim = (Map<String , Object>) claimIdAndObjectMap.get(obj.Id);
            List<Object> lineItems = (List<Object>) claim.get('lineItemLst');
            for(Object childERA : lineItems){ 
                system.debug('meghna'+ childERA);
                if(childERA!=null){
                    Map<String, Object> mapOfChildERALineItem = (Map<String, Object>) childERA;
                    // Will add when neha to give the key name
                    informationalRemarkCodes.add(String.valueOf(mapOfChildERALineItem.get('selectedInfoRemarkCodes')));
                    List<Object> adjCodeTableValues = ( List<Object> ) mapOfChildERALineItem.get('adjustmentCodeTable');
                    for(Object adjCodesObj : adjCodeTableValues){
                        Map<String, Object> adjCodeAndValues = (Map<String, Object>) adjCodesObj; 
                        adjustmentCodes.add(String.valueOf(adjCodeAndValues.get('adjCdTbl_adjustmentGroupCode')));
                        // Will add when neha to give the key name
                        supplementalRemarkCodes.add(String.valueOf(adjCodeAndValues.get('suppRemarkCode')));
                    }
                }
            }
            List<String> adjList = new List<String>();
            List<String> informationalList = new List<String>();
            List<String> supplementalList = new List<String>();
            adjList.addAll(adjustmentCodes);
            informationalList.addAll(informationalRemarkCodes);
            supplementalList.addAll(supplementalRemarkCodes);
            obj.ElixirSuite__Adjustment_Code__c = String.join(adjList, ';');
            obj.ElixirSuite__Informational_Remark_Codes__c = String.join(informationalList, ';');
            obj.ElixirSuite__Supplemental_Group_Code__c = String.join(supplementalList, ';');
        }
        if (Schema.sObjectType.ElixirSuite__Claim__c.isUpdateable()) {
            DMLManager.updateAsUser(allClmToUpdate); 
         }
    }
    //Ending For Claim Live feeds - By meghna
    
    public static  List<Object>  utilityMapDeserialize(String stringifiedJSON,String keyToGet){         
        Map<String, Object> tableLstJSON =(Map<String, Object>) JSON.deserializeUntyped(stringifiedJSON);
        return  (List<Object>) tableLstJSON.get(keyToGet);
    }
    public static ElixirSuite__ERA_Line_Item__c[] insertERALineItemsForchildERA(ElixirSuite__EOB__c[] childERALst, Map<String,List<ElixirSuite__ERA_Line_Item__c>> mapOfParentChildRecords){
        List<ElixirSuite__ERA_Line_Item__c> eraLine_childRecs = new List<ElixirSuite__ERA_Line_Item__c>();
        for(ElixirSuite__EOB__c insertedRecords : childERALst){
            for(String createMap : mapOfParentChildRecords.keySet()){
                if(insertedRecords.ElixirSuite__Line_Items_Reference_Key__c == createMap){              
                    for(ElixirSuite__ERA_Line_Item__c updtIDs : mapOfParentChildRecords.get(insertedRecords.ElixirSuite__Line_Items_Reference_Key__c)){
                        updtIDs.ElixirSuite__EOB__c = insertedRecords.Id;
                        eraLine_childRecs.add(updtIDs);
                    }
                }
            }
        }
        if (Schema.sObjectType.ElixirSuite__ERA_Line_Item__c.isCreateable()){
             DMLManager.insertAsUser(eraLine_childRecs);
        }
        return eraLine_childRecs;
    }
    public static ElixirSuite__ERA_Line_Item__c[] deserializeLineItemRecords( List<Object> lineItemLstPerChildERA ){       
        ElixirSuite__ERA_Line_Item__c[] lineItemLst = new List<ElixirSuite__ERA_Line_Item__c>();
        for(Object childERA : lineItemLstPerChildERA){            
            if(childERA!=null){
                Map<String, Object> mapOfChildERALineItem = (Map<String, Object>) childERA;            
                ElixirSuite__ERA_Line_Item__c eraLine = new ElixirSuite__ERA_Line_Item__c();
                eraLine.ElixirSuite__Proc_code__c = String.valueOf(mapOfChildERALineItem.get('procCodeERAprocLineItem'));
                eraLine.ElixirSuite__Claim_Line_Items__c =  String.valueOf(mapOfChildERALineItem.get('claimLineItemId')); // attach to claim line item too
                eraLine.ElixirSuite__Charge__c  = Decimal.valueOf(String.valueOf(mapOfChildERALineItem.get('billedAmt')));// billed amount
                eraLine.ElixirSuite__Patient_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfChildERALineItem.get('patientResp')));
                eraLine.ElixirSuite__Status__c = String.valueOf(mapOfChildERALineItem.get('paymentStatus'));
                eraLine.ElixirSuite__Total_Allowed_Amount__c = Decimal.valueOf(String.valueOf(mapOfChildERALineItem.get('allowedAmt')));
                eraLine.ElixirSuite__Paid__c = Decimal.valueOf(String.valueOf(mapOfChildERALineItem.get('paidAmt')));
                deserializeAdjustmentCodeTable(( List<Object> ) mapOfChildERALineItem.get('adjustmentCodeTable'),eraLine); 
                //Added by Neha
                //  system.debug('===suppremarkcode==='+mapOfChildERALineItem.get('selectedInfoRemarkCodes'));
                                List<Object> selectedInfoCodeList = (List<Object>) mapOfChildERALineItem.get('selectedInfoRemarkCodes');
                List<String> templist = new List<String>();
                String inforRemarks='';            
                for(object ob: selectedInfoCodeList){
                    Map<String, Object> obj = (Map<String, Object>) ob; 
                    templist.add((String) obj.get('Name'));                     
                }
                eraLine.ElixirSuite__Adjustment_Remark_Codes__c= String.join(templist, ';');
                //
                lineItemLst.add(eraLine);                
            }
        }
        return lineItemLst;
    }
    public static void deserializeAdjustmentCodeTable( List<Object> adjCodeTableValues,ElixirSuite__ERA_Line_Item__c eraLine){
        Integer i = 1;
        for(Object adjCodesObj : adjCodeTableValues){
            Map<String, Object> adjCodeAndValues = (Map<String, Object>) adjCodesObj;                        
            eraLine.put('ElixirSuite__Group_'+i+'__c',String.valueOf(adjCodeAndValues.get('adjCdTbl_adjustmentGroupCode')));    
            eraLine.put('ElixirSuite__Code_'+i+'__c',String.valueOf(adjCodeAndValues.get('adjCdTbl_adjustmentCodeReason')));    
            eraLine.put('ElixirSuite__Adjustment_Amount_'+i+'__c',Decimal.valueOf(String.valueOf(adjCodeAndValues.get('adjCdTbl_adjustmentAmount')))); 
                        
            i++;                
            eraLine.ElixirSuite__Count_of_total_adjustments_used__c = i-1;
            if(String.isBlank(String.valueOf(eraLine.get('ElixirSuite__Adjustment_Amount_1__c')))){
                eraLine.ElixirSuite__Count_of_total_adjustments_used__c = 0;  
            }
        }
    }
}