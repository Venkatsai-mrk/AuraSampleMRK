public with sharing class ElixirOEM_UpdateERAHelper { 
    @AuraEnabled 
    public static WrapperForInitPayload fetchInitPayload(String[] lstOfFields,String parentERARecord) {
        WrapperForInitPayload toRet = new WrapperForInitPayload();
        toRet.fieldsDataGeneric = ElixirOEM_AddEraHelper.fetchPicklistValuesForObjectMdt(lstOfFields);
        //Added by Neha  
        toRet.infoCodePicklistValues = MasterProblemListController.fetchPickListValue('ElixirSuite__ERA_Line_Item__c','ElixirSuite__Adjustment_Remark_Codes__c').values();
        toRet.SuppCodePicklistValues = MasterProblemListController.fetchPickListValue('ElixirSuite__ERA_Line_Item__c','ElixirSuite__Adjustment_Remark_Codes__c').values();
        //
        toRet.parentEOBRecord = fetchParentERARecord(parentERARecord);
ElixirSuite__EOB__c[] eobList = toRet.parentEOBRecord;
        string payerName;
        for(ElixirSuite__EOB__c eb:eobList){
            payerName = eb.ElixirSuite__Payer__r.Name;
        }
        ElixirSuite__EOB__c[] childEOBLst = fetchChildERALst(parentERARecord);   
        toRet.mapOferaToLineItem = collectmapOferaToLineItem(childEOBLst);
        toRet.SecInsACC = secInsForAccount(childEOBLst); //LX3-9271
        toRet.childEOBLst = childEOBLst;       
        toRet.allRelatedClaimLineItem = formulateLineItem(childEOBLst);
ElixirSuite__ERA_Line_Item__c [] eli = toRet.allRelatedClaimLineItem;
        string Code1 ;
        for(ElixirSuite__ERA_Line_Item__c el:eli){
            if(el.ElixirSuite__Code_1__c.contains('-')){
                String inputString = el.ElixirSuite__Code_1__c;
                List<String> parts = inputString.split('-');
                String firstPart = parts[0];
                Code1 = parts[0];
            }else{
                Code1 = el.ElixirSuite__Code_1__c;
            }
        }
        toRet.mapOfAdjustmentGroupCode = MasterProblemListController.fetchPickListValue('ElixirSuite__ERA_Line_Item__c','ElixirSuite__Adjustment_Group_Code__c');  
        toRet.mapOfEraStatusCode = MasterProblemListController.fetchPickListValue('ElixirSuite__EOB__c','ElixirSuite__ERA_Status_Code__c');  
        toRet.mapOfEraActionsToBeTaken = MasterProblemListController.fetchPickListValue('ElixirSuite__EOB__c','ElixirSuite__Action_to_be_Taken__c'); 
        toRet.mapOfCodeToDesciption  = getReasonListFromMDT(payerName,Code1);
       
        return toRet;
    }
public static  Map<String,String> getReasonListFromMDT(String payerName, String Code1){
        String res;
        Map<String,String> mapOfCodeToDesciption = new Map<String,String>();
        String searchKey = '%' + payerName + '%';
        try{
        Map<String, ElixirSuite__Adjustment_Reason_Code__mdt>
         mapEd   = new Map<String, ElixirSuite__Adjustment_Reason_Code__mdt>([SELECT MasterLabel, ElixirSuite__Description__c, ElixirSuite__Payer__c FROM ElixirSuite__Adjustment_Reason_Code__mdt
                                                                                                                                WHERE ElixirSuite__Payer__c like:searchKey OR ElixirSuite__Payer__c like 'ALL']);
            
     //   Map<String, ElixirSuite__Adjustment_Reason_Code__mdt> mapEd = ElixirSuite__Adjustment_Reason_Code__mdt.getAll();        
        for(String nameEmailDomain : mapEd.keySet()){
if(mapEd.get(nameEmailDomain).MasterLabel !=Code1){
if(mapEd.get(nameEmailDomain).ElixirSuite__Description__c != null){
            res = mapEd.get(nameEmailDomain).MasterLabel + '-'+mapEd.get(nameEmailDomain).ElixirSuite__Description__c;
}else{
                res = mapEd.get(nameEmailDomain).MasterLabel;
            }
            mapOfCodeToDesciption.put(nameEmailDomain, res);            
        }
        }
}
        catch(Exception e){ExceptionLog.logError(e);}
         system.debug('mapOfCodeToDesciption@@'+mapOfCodeToDesciption);
        return mapOfCodeToDesciption;
    }
    public static Map<Id,List<ElixirSuite__ERA_Line_Item__c>> collectmapOferaToLineItem(ElixirSuite__EOB__c[] childEOBLst) {
        Set<Id> eobIds = new Set<Id>();
        for(ElixirSuite__EOB__c sObj : childEOBLst){
            eobIds.add(sobj.Id);
        }
        ElixirSuite__ERA_Line_Item__c[] eraLineItems = [SELECT ID,ElixirSuite__EOB__c FROM ElixirSuite__ERA_Line_Item__c where ElixirSuite__EOB__c IN : eobIds WITH SECURITY_ENFORCED];
        Map<Id,List<ElixirSuite__ERA_Line_Item__c>> mapOferaToLineItem = new Map<Id,List<ElixirSuite__ERA_Line_Item__c>>();
        try{
        for(ElixirSuite__ERA_Line_Item__c rec : eraLineItems){
            if(mapOferaToLineItem.containsKey(rec.ElixirSuite__EOB__c)){
                mapOferaToLineItem.get(rec.ElixirSuite__EOB__c).add(rec);
            }else{
                List<ElixirSuite__ERA_Line_Item__c> lineItems = new List<ElixirSuite__ERA_Line_Item__c>();
                lineItems.add(rec);
                mapOferaToLineItem.put(rec.ElixirSuite__EOB__c,lineItems);
            }
        } 
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return mapOferaToLineItem;       
    }
    public static ElixirSuite__ERA_Line_Item__c[] formulateLineItem(ElixirSuite__EOB__c[] childEOBLst) { 
        Set<Id> childEOBIds = new Set<Id>();
        for(ElixirSuite__EOB__c eobsObj : childEOBLst){
            childEOBIds.add(eobsObj.Id);
        }
        return fetchLineItemLst(childEOBIds);
    }
    public static ElixirSuite__ERA_Line_Item__c[] fetchLineItemLst( Set<Id> childEOBIds) {
        String additionFieldsPrefix = ' WHERE ElixirSuite__EOB__c  =: childEOBIds';
        //Added two extra fields by Anusha - Name,code Description to below otherfieldsaddition String - LX3-5744 - 14/10/22
        String otherFieldsAddition =  ' ,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.Name,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c  ';
        String eraLineItemQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__ERA_Line_Item__c',otherFieldsAddition,additionFieldsPrefix+'');
        ElixirOEM_TimelineHelper.mDebugUntruncated(eraLineItemQuery);
        system.debug('Neha ###'+eraLineItemQuery);
        return Database.query(eraLineItemQuery);
    }
    @AuraEnabled 
    public static ElixirOEM_AttachEraLineItemHelper.AttachClaimInitWrapper getClaimLineItemsInParent(String claimId){
        return  ElixirOEM_AttachEraLineItemHelper.getClaimLineItems(claimId);
    }
    public static ElixirSuite__EOB__c[] fetchParentERARecord(String parentERARecord) {    
        String additionFieldsPrefix = buildAdditionalQuery(parentERARecord);  
        String otherFieldsAddition =  ' ,ElixirSuite__Payer__r.Name ';
        String eraQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__EOB__c',otherFieldsAddition,additionFieldsPrefix+'');
        ElixirOEM_TimelineHelper.mDebugUntruncated(eraQuery);
        return Database.query(eraQuery);
    }
    public static ElixirSuite__EOB__c[] fetchChildERALst(String parentERARecord) {
        String additionFieldsPrefix = ' WHERE ElixirSuite__EOB__c  =: parentERARecord';    
        String otherFieldsAddition =  ' ,ElixirSuite__Account__r.Name,ElixirSuite__Claim__r.Name,ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c,ElixirSuite__Claim__r.ElixirSuite__Posted__c '; 
        String eraQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__EOB__c',otherFieldsAddition,additionFieldsPrefix+'');
        ElixirOEM_TimelineHelper.mDebugUntruncated(eraQuery);
        system.debug('Neha @@@'+eraQuery);
        return Database.query(eraQuery);
    }
    
    public static  String buildAdditionalQuery(String parentERARecord){       
        return ' WHERE Id  =: parentERARecord';     
    }
    public class WrapperForInitPayload{
        @AuraEnabled public ElixirOEM_AddEraHelper.WrapperForClaimFields fieldsDataGeneric;
        @AuraEnabled public ElixirSuite__EOB__c[] parentEOBRecord;
        @AuraEnabled public ElixirSuite__EOB__c[] childEOBLst;
        @AuraEnabled public ElixirSuite__ERA_Line_Item__c[] allRelatedClaimLineItem;
        @AuraEnabled public Map<String, String> mapOfAdjustmentGroupCode;
        @AuraEnabled public Map<String, String> mapOfEraStatusCode;
        @AuraEnabled public Map<String,String> mapOfCodeToDesciption;
        @AuraEnabled public Map<String,String> mapOfEraActionsToBeTaken;
        @AuraEnabled public Map<Id,List<ElixirSuite__ERA_Line_Item__c>> mapOferaToLineItem = new Map<Id,List<ElixirSuite__ERA_Line_Item__c>>();
        //Added By Neha 
        @AuraEnabled public List<String> infoCodePicklistValues ;
        @AuraEnabled public List<Id> SecInsACC ;
        @AuraEnabled public List<String> SuppCodePicklistValues ;
        @AuraEnabled public Integer totalPatientResponsibilitySum;
        // @AuraEnabled public ElixirOEM_InforcodeWrapper.wrapperInforCode allRelatedClaimLineItem;
        //
    }
    
    @AuraEnabled 
    public static ElixirSuite__Claim__c[] queryAllClaims(String patientId,String claimName,String payorId,List<String> existingClaimIds){
        String[] existingClaim = new List<String>();
        String additionFieldsPrefix = ElixirOEM_AddEraHelper.buildAdditionalQuery(patientId,claimName,payorId,existingClaim);  
        additionFieldsPrefix+=' AND ID NOT IN : existingClaimIds ';
        String otherFieldsAddition = ' ,ElixirSuite__Account__r.Name '; 
        String clmQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Claim__c',otherFieldsAddition,additionFieldsPrefix+' ORDER BY ElixirSuite__Account__r.Name ');
        ElixirOEM_TimelineHelper.mDebugUntruncated(clmQuery);
        return Database.query(clmQuery);
    }
    @AuraEnabled 
    public static ElixirOEM_AddEraHelper.WrapperForClaimFields fetchPicklistValuesForClaimFields(String objectName,String[] lstOfFields,String claimId) {
        return ElixirOEM_AddEraHelper.fetchPicklistValuesForClaimFields(objectName, lstOfFields, claimId);
    }
    @AuraEnabled 
    public static void updateERAEOB(ElixirSuite__EOB__c eobParentRecord,String stringifiedTablLst,List<String> childERAToDel, 
                                    String notes, String recommendation, String delNotes, String delRecommendation)
    {    
        if (Schema.sObjectType.ElixirSuite__EOB__c.isupdateable()){
            update eobParentRecord;      
        }
        Map<String,Object> claimIdAndObjectMap = new Map<String,Object>();
        Map<String,List<ElixirSuite__ERA_Line_Item__c>> mapOfParentChildRecords = new Map<String,List<ElixirSuite__ERA_Line_Item__c>>();
        ElixirSuite__EOB__c[] childERALst = new List<ElixirSuite__EOB__c>(); // FOR UPDATE
        ElixirSuite__EOB__c[] childERALstToInsert = new List<ElixirSuite__EOB__c>(); // FOR INSERT
        List<String> secClaimCreationList = new  List<String>();
        List<String> accIdList = new List<String>();
        try{
        for(Object obj : utilityMapDeserialize(stringifiedTablLst,'childERAtableList')){
            
            Map<String, Object> mapOfChildEraData = (Map<String, Object>) obj;
            system.debug('===mapOfChildEraData====='+mapOfChildEraData);
            ElixirSuite__EOB__c obj_childERA = new ElixirSuite__EOB__c();  
            claimIdAndObjectMap.put(String.valueOf(mapOfChildEraData.get('claimId')),obj);
            if(String.isNotBlank(String.valueOf(mapOfChildEraData.get('Id')))){
                obj_childERA.Id =  String.valueOf(mapOfChildEraData.get('Id')); // Specifiying ID for update
            }
            
            obj_childERA.ElixirSuite__Account__c =  String.valueOf(mapOfChildEraData.get('patientId'));
            obj_childERA.ElixirSuite__Claim__c =  String.valueOf(mapOfChildEraData.get('claimId'));
            obj_childERA.ElixirSuite__Payer_Claim__c = String.valueOf(mapOfChildEraData.get('payerClaimHash'));
            obj_childERA.ElixirSuite__ERA_Status_Code__c = String.valueOf(mapOfChildEraData.get('eraStatusCode'));
            obj_childERA.ElixirSuite__Total_Charge__c = decimal.valueOf(string.valueOf(mapOfChildEraData.get('totalBilledAmount'))); // total billed amount
            if(string.valueOf(mapOfChildEraData.get('totalContractedAmt')) != null){
            obj_childERA.ElixirSuite__Total_Contracted_Amt__c= decimal.valueOf(string.valueOf(mapOfChildEraData.get('totalContractedAmt')));
            }
            obj_childERA.ElixirSuite__Total_Allowed__c= decimal.valueOf(string.valueOf(mapOfChildEraData.get('totalAllowedAmt')));
            obj_childERA.ElixirSuite__Total_Adjustment_Amount__c= decimal.valueOf(string.valueOf(mapOfChildEraData.get('totalAdjustmentAmt')));
            obj_childERA.ElixirSuite__Total_Paid__c= decimal.valueOf(string.valueOf(mapOfChildEraData.get('paidAmt'))); // total paid amt
            obj_childERA.ElixirSuite__Net_Paid_Amt__c = decimal.valueOf(string.valueOf(mapOfChildEraData.get('netPaidAmount')));
            obj_childERA.ElixirSuite__Payment_Status__c = String.valueOf(mapOfChildEraData.get('paymentStatus'));
            obj_childERA.ElixirSuite__Action_to_be_Taken__c = String.valueOf(mapOfChildEraData.get('actionToBeTakenVal'));
            if(String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) != '' && String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) != null && String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Secondary'){
              secClaimCreationList.add(obj_childERA.ElixirSuite__Claim__c);  
              accIdList.add(obj_childERA.ElixirSuite__Account__c);
            }
            obj_childERA.ElixirSuite__Total_Patient_Responsibility__c = decimal.valueOf(string.valueOf(mapOfChildEraData.get('ver_1_toalPatientResp')));
            obj_childERA.ElixirSuite__Total_Adjustment_Amount__c= decimal.valueOf(string.valueOf(mapOfChildEraData.get('totalAdjustmentAmt')));
            obj_childERA.ElixirSuite__Total_OI_Responsibility__c = decimal.valueOf(string.valueOf(mapOfChildEraData.get('ver_1_totalOtherInsResp')));
            obj_childERA.ElixirSuite__EOB__c = eobParentRecord.Id;
            obj_childERA.ElixirSuite__Line_Items_Reference_Key__c = String.ValueOf(Integer.valueOf(math.rint(math.random()*1000000)));             
            childERALst.add(obj_childERA); 
            
            
            if(mapOfChildEraData.containsKey('lineItemLst')){
                mapOfParentChildRecords.put(obj_childERA.ElixirSuite__Line_Items_Reference_Key__c,deserializeLineItemRecords((List<Object>) mapOfChildEraData.get('lineItemLst')));
            }
        }
        
        if (Schema.sObjectType.ElixirSuite__EOB__c.iscreateable()){
            DMLManager.upsertAsUser(childERALst);
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        //Added by Akanksha
        try{
        List<Object> eraNotesList = (List<Object>) JSON.deserializeUntyped(notes);
        List<Object> eraDelNotesList = (List<Object>) JSON.deserializeUntyped(delNotes);
        List<Object> eraRecommendationList = (List<Object>) JSON.deserializeUntyped(recommendation);
        List<Object> eraDelRecommendationList = (List<Object>) JSON.deserializeUntyped(delRecommendation);
        List<ElixirSuite__Notes__c> noteListToUpsert = new List<ElixirSuite__Notes__c>();
        List<ElixirSuite__Notes__c> noteListToDelete = new List<ElixirSuite__Notes__c>();
        List<ElixirSuite__Recommendation__c> recommendationListToUpsert = new List<ElixirSuite__Recommendation__c>();
        List<ElixirSuite__Recommendation__c> recommendationListToDelete = new List<ElixirSuite__Recommendation__c>();
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
            if(eraDelNotesList[i] != null){ 
                List<Object> delNotesList = (List<Object>) eraDelNotesList[i];
                for(Object delNotesObj : delNotesList){
                    Map<String, Object> delNotesData = (Map<String, Object>) delNotesObj;
                    ElixirSuite__Notes__c obj_delNotes = new ElixirSuite__Notes__c();  
                    if(delNotesData.get('Id') != null && String.isNotBlank(String.valueOf(delNotesData.get('Id')))){
                        obj_delNotes.Id =  String.valueOf(delNotesData.get('Id'));
                    }
                    noteListToDelete.add(obj_delNotes);
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
            if(eraDelRecommendationList[i] != null){ 
                List<Object> delRecommendationList = (List<Object>) eraDelRecommendationList[i];
                for(Object delRecObj : delRecommendationList){
                    Map<String, Object> delRecData = (Map<String, Object>) delRecObj;
                    ElixirSuite__Recommendation__c obj_delRecommendation = new ElixirSuite__Recommendation__c();  
                    if(delRecData.get('Id') != null && String.isNotBlank(String.valueOf(delRecData.get('Id')))){
                        obj_delRecommendation.Id =  String.valueOf(delRecData.get('Id'));
                    }
                    recommendationListToDelete.add(obj_delRecommendation);
                }
            }
        }
        
        if(Schema.sObjectType.ElixirSuite__Notes__c.isUpdateable()
            &&Schema.sObjectType.ElixirSuite__Notes__c.isCreateable()){
            DMLManager.upsertAsUser(noteListToUpsert);
        }
        if (Schema.sObjectType.ElixirSuite__Notes__c.isDeletable()){
            DMLManager.deleteAsUser(noteListToDelete);
        }
        
        if(Schema.sObjectType.ElixirSuite__Recommendation__c.isUpdateable()
            &&Schema.sObjectType.ElixirSuite__Recommendation__c.isCreateable()){
            DMLManager.upsertAsUser(recommendationListToUpsert);
        }
        if (Schema.sObjectType.ElixirSuite__Recommendation__c.isDeletable()){
            DMLManager.deleteAsUser(recommendationListToDelete);
        }
        //end
        insertERALineItemsForchildERA(childERALst,mapOfParentChildRecords); // updateeralineitems
        // delete child ERA and related LINE ITEMS
        formulateDeletion(childERAToDel);
        //Line 161 Added by Meghu
        ElixirOEM_AddEraHelper.claimMultipiclistUpdate(claimIdAndObjectMap);
            system.debug('secClaimCreationList '+secClaimCreationList);
        if(secClaimCreationList != null && secClaimCreationList.size() >0 && accIdList != null && accIdList.size() >0){
            List<Claim__c> secExistingClaim = [Select id, Name, ElixirSuite__Claim__c From ElixirSuite__Claim__c where ElixirSuite__Claim__c IN:secClaimCreationList WITH SECURITY_ENFORCED];
            for(Integer i=0; i<secExistingClaim.size();i++){
                if(secClaimCreationList.contains(secExistingClaim[i].ElixirSuite__Claim__c)){
                   secClaimCreationList.remove(i);
                }
            }
             system.debug('secExistingClaim '+secExistingClaim);
            if(secClaimCreationList != null){
            postERAPayments(eobParentRecord,stringifiedTablLst);
            secClaimCreation(secClaimCreationList,accIdList);
            }
        }
        } catch(Exception e){
            ExceptionLog.logError(e); 
        }
    }
    public static  List<Object>  utilityMapDeserialize(String stringifiedJSON,String keyToGet){         
        Map<String, Object> tableLstJSON =(Map<String, Object>) JSON.deserializeUntyped(stringifiedJSON);
        return  (List<Object>) tableLstJSON.get(keyToGet);
    }
    public static void insertERALineItemsForchildERA(ElixirSuite__EOB__c[] childERALst, Map<String,List<ElixirSuite__ERA_Line_Item__c>> mapOfParentChildRecords){
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
        if(Schema.sObjectType.ElixirSuite__ERA_Line_Item__c.isUpdateable()
            &&Schema.sObjectType.ElixirSuite__ERA_Line_Item__c.isCreateable()){
            system.debug('===eraLine_childRecs==='+eraLine_childRecs);
            DMLManager.upsertAsUser(eraLine_childRecs);
        }
    }
    public static ElixirSuite__ERA_Line_Item__c[] deserializeLineItemRecords( List<Object> lineItemLstPerChildERA ){ 
        system.debug('lineItemLstPerChildERA==='+lineItemLstPerChildERA);
        ElixirSuite__ERA_Line_Item__c[] lineItemLst = new List<ElixirSuite__ERA_Line_Item__c>();
        try{
        for(Object childERA : lineItemLstPerChildERA){            
            if(childERA!=null){
                Map<String, Object> mapOfChildERALineItem = (Map<String, Object>) childERA;
                ElixirSuite__ERA_Line_Item__c eraLine = new ElixirSuite__ERA_Line_Item__c();
                if(String.isNotBlank(String.valueOf(mapOfChildERALineItem.get('Id')))){
                    eraLine.Id = String.valueOf(mapOfChildERALineItem.get('Id'));  // Specifiying ID for update  
                }              
                eraLine.ElixirSuite__Proc_code__c = String.valueOf(mapOfChildERALineItem.get('procCodeERAprocLineItem'));
                eraLine.ElixirSuite__Claim_Line_Items__c =  String.valueOf(mapOfChildERALineItem.get('claimLineItemId')); // attach to claim line item too
                eraLine.ElixirSuite__Charge__c  = decimal.valueOf(string.valueOf(mapOfChildERALineItem.get('billedAmt')));// billed amount
                eraLine.ElixirSuite__Patient_Responsibility__c = decimal.valueOf(string.valueOf(mapOfChildERALineItem.get('patientResp')));
                // conctAmt missing
                // adjustMentAmt
                // providerAdj
                // patientResp
                eraLine.ElixirSuite__Status__c = String.valueOf(mapOfChildERALineItem.get('paymentStatus'));
                eraLine.ElixirSuite__Total_Allowed_Amount__c = decimal.valueOf(string.valueOf(mapOfChildERALineItem.get('allowedAmt')));
                eraLine.ElixirSuite__Paid__c = decimal.valueOf(string.valueOf(mapOfChildERALineItem.get('paidAmt')));
                //Added by Neha
                
                
                List<Object> selectedInfoCodeList = (List<Object>) mapOfChildERALineItem.get('selectedInfoRemarkCodes');
                List<String> templist = new List<String>();
                String inforRemarks='';
                if(selectedInfoCodeList!=null){
                    for(object ob: selectedInfoCodeList){
                        //templist.add(String.valueOf(ob));
                        Map<String, Object> obj = (Map<String, Object>) ob; 
                        templist.add((String) obj.get('Name'));
                    } 
                }
                
                eraLine.ElixirSuite__Adjustment_Remark_Codes__c= String.join(templist, ';');
                //
                deserializeAdjustmentCodeTable(( List<Object> ) mapOfChildERALineItem.get('adjustmentCodeTable'),eraLine); 
                lineItemLst.add(eraLine);                
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return lineItemLst;
    }
    public static void deserializeAdjustmentCodeTable( List<Object> adjCodeTableValues,ElixirSuite__ERA_Line_Item__c eraLine){
        Integer i = 1;
        for(Object adjCodesObj : adjCodeTableValues){
            Map<String, Object> adjCodeAndValues = (Map<String, Object>) adjCodesObj;                        
            eraLine.put('ElixirSuite__Group_'+i+'__c',String.valueOf(adjCodeAndValues.get('adjCdTbl_adjustmentGroupCode')));    
            eraLine.put('ElixirSuite__Code_'+i+'__c',String.valueOf(adjCodeAndValues.get('adjCdTbl_adjustmentCodeReason')));    
            eraLine.put('ElixirSuite__Adjustment_Amount_'+i+'__c',decimal.valueOf(string.valueOf(adjCodeAndValues.get('adjCdTbl_adjustmentAmount'))));
            eraLine.put('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c',String.valueOf(adjCodeAndValues.get('suppRemarkCode')));//Added by Neha 
            i++;                
            eraLine.ElixirSuite__Count_of_total_adjustments_used__c = i-1;
            if(String.isBlank(String.valueOf(eraLine.get('ElixirSuite__Adjustment_Amount_1__c')))){
                eraLine.ElixirSuite__Count_of_total_adjustments_used__c = 0;  
            }
        }
    }
    public static void formulateDeletion(List<String> childERAToDel){
        Map<ID, ElixirSuite__EOB__c> childERAMap = new Map<ID, ElixirSuite__EOB__c>([SELECT Id FROM ElixirSuite__EOB__c WHERE ID IN : childERAToDel  with security_enforced]);
        if (Schema.sObjectType.ElixirSuite__ERA_Line_Item__c.isDeletable()) {
            delete [SELECT ID FROM ElixirSuite__ERA_Line_Item__c WHERE ElixirSuite__EOB__c IN : childERAMap.keySet()  with security_enforced];
        }
        if (Schema.sObjectType.ElixirSuite__Notes__c.isDeletable()){
            delete [SELECT ID FROM ElixirSuite__Notes__c WHERE ElixirSuite__ERA_Notes__c IN : childERAMap.keySet()  with security_enforced];
        }
        if (Schema.sObjectType.ElixirSuite__Recommendation__c.isDeletable()){
            delete [SELECT ID FROM ElixirSuite__Recommendation__c WHERE ElixirSuite__Elixir_ERA__c IN : childERAMap.keySet()  with security_enforced];
        }
        if (Schema.sObjectType.ElixirSuite__EOB__c.isDeletable()) {
            delete [SELECT Id FROM ElixirSuite__EOB__c WHERE ID IN : childERAToDel  with security_enforced];
        }
    }
    @AuraEnabled 
    public static void postERAPayments(ElixirSuite__EOB__c eobParentRecord,String stringifiedTablLst){  
        try{
            ElixirOEM_AddEraHelper.ParentERADataWrapper flow_sObj = new ElixirOEM_AddEraHelper.ParentERADataWrapper();
            flow_sObj.paymentMethod = eobParentRecord.ElixirSuite__Payment_Method__c;
            flow_sObj.parentERAHash =  eobParentRecord.Name;
            Set<String> eobRecordIdSet = new   Set<String>();
            Map<String,Object> claimIdAndObjectMap = new Map<String,Object>();
            for(Object obj : utilityMapDeserialize(stringifiedTablLst,'childERAtableList')){
                Map<String, Object> mapOfChildEraData = (Map<String, Object>) obj;         
                
                if(String.isNotBlank(String.valueOf(mapOfChildEraData.get('Id')))){
                    if ((String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Process as Primary' && 
                         String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Adjustment Writeoff') ||
                        (String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Process as Primary' && 
                         String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Patient') ||
                        (String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Process as Primary' && 
                         String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Secondary') ||
                        (String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Processed as Secondary' && 
                         String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Adjustment Writeoff') ||
                       (String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Processed as Secondary' && 
                         String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Patient')){  // PAYMENT POSTING RECORDS GETS FILTERED OUT
                             eobRecordIdSet.add(String.valueOf(mapOfChildEraData.get('Id')));
                             claimIdAndObjectMap.put(String.valueOf(mapOfChildEraData.get('claimId')),obj);
                         }
                    else if((String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Denied' && 
                             String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Adjustment Writeoff') ||
                            (String.valueOf(mapOfChildEraData.get('eraStatusCode')) == 'Denied' && 
                             String.valueOf(mapOfChildEraData.get('actionToBeTakenVal')) == 'Transfer to Patient')){
                                 eobRecordIdSet.add(String.valueOf(mapOfChildEraData.get('Id')));
                                 claimIdAndObjectMap.put(String.valueOf(mapOfChildEraData.get('claimId')),obj);
                             }                    
                }
            }
            ElixirSuite__EOB__c[] allEOBs = queryAllEOBs(eobRecordIdSet);
            for(ElixirSuite__EOB__c eobObj : allEOBs){
                eobObj.ElixirSuite__Primary_Posted__c =true;  
            }
            update allEOBs;
            if(allEOBs.size() > 0){
            ElixirOEM_PaymentPostingHelper.postPaymentUtility(queryAllEOBs(eobRecordIdSet), flow_sObj, new  Map<String,Object>());
            ElixirOEM_PaymentPostingHelper.updateClaimPerChildERA(claimIdAndObjectMap,flow_sObj);
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e); 
        }
        
    }
    
    public static ElixirSuite__EOB__c[] queryAllEOBs( Set<String> eobRecordIdSet ){
        String additionFieldsPrefix = ' WHERE Id IN : eobRecordIdSet';  
        String otherFieldsAddition = ' ,ElixirSuite__Claim__r.Name ';  
        String eobQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__EOB__c',otherFieldsAddition,additionFieldsPrefix+'');
        ElixirOEM_TimelineHelper.mDebugUntruncated(eobQuery);
        return Database.query(eobQuery);
    }
    //LX3-9271
    public static List<Id> secInsForAccount(List<ElixirSuite__EOB__c> childERAList){
        List<Id> accVSIns = new List<Id>();
        try{
        List<String> accIdList = new List<String>();
        for(ElixirSuite__EOB__c eb :childERAList){
            if(eb.ElixirSuite__Account__c != null){
               accIdList.add(eb.ElixirSuite__Account__c); 
            }
        }
       
        List<Account> accList = new  List<Account>();
        if(accIdList != null && accIdList.size() > 0){
           accList = [Select Id, Name,(Select id,name from ElixirSuite__VOB__r where ElixirSuite__Status__c ='Active' AND RecordType.DeveloperName='Secondary_VOB' LIMIT 1 ) from account where id IN: accIdList WITH SECURITY_ENFORCED];
        }
        System.debug('accList wwww'+accList);
        for(Account ac: accList){
            if(ac.ElixirSuite__VOB__r != null && (ac.ElixirSuite__VOB__r).size() > 0){
               accVSIns.add(ac.Id);
            }
        }
        } catch(Exception e){
            ExceptionLog.logError(e); 
        }
        
        return accVSIns; 
    }
    @future
    public static void secClaimCreation(List<String> secClaimCreationList, List<String> accIdList){
       try{
       Map<String, String> stateAbbreviationMap = new Map<String, String> {
                        'Alabama' => 'AL', 'AL' => 'AL',
                            'Alaska' => 'AK','AK' => 'AK',
                            'Arizona' => 'AZ', 'AZ' => 'AZ',
                            'Arkansas' => 'AR', 'AR' => 'AR',
                            'California' => 'CA', 'CA' => 'CA',
                            'Colorado' => 'CO', 'CO' => 'CO',
                            'Connecticut' => 'CT', 'CT' => 'CT',
                            'District Of Columbia' => 'DC', 'DC' => 'DC',
                            'Florida' => 'FL', 'FL' => 'FL',
                            'Georgia' => 'GA', 'GA' => 'GA',
                            'Hawaii' => 'HI', 'HI' => 'HI',
                            'Idaho' => 'In', 'In' => 'In',
                            'Illinois' => 'IL', 'IL' => 'IL',
                            'Indiana' => 'IN', 'IN' => 'IN',
                            'Iowa' => 'IA', 'IA' => 'IA',
                            'Kansas' => 'KS', 'KS' => 'KS',
                            'Maine' => 'ME', 'ME' => 'ME',
                            'Maryland' => 'MD','MD' => 'MD',
                            'Massachusetts' => 'MA', 'MA' => 'MA',
                            'Michigan' => 'MA', 'MA' => 'MA',
                            'Minnesota' => 'MN', 'MN' => 'MN',
                            'Mississippi' => 'MS', 'MS' => 'MS',
                            'Missouri' => 'MA', 'MA' => 'MA',
                            'Montana' => 'MO', 'MO' => 'MO',
                            'Nebraska' => 'NE', 'NE' => 'NE',
                            'Nevada' => 'MN','MN' => 'MN',
                            'New Jersey' => 'NJ','NJ' => 'NJ',
                            'New Hampshire' => 'NH', 'NH' => 'NH',
                            'New Mexico' => 'MA', 'MA' => 'MA',
                            'New York' => 'NM', 'NM' => 'NM',
                            'North Carolina' => 'NC', 'NC' => 'NC',
                            'Dakota' => 'ND', 'ND' => 'ND',
                            'Ohio' => 'OH', 'OH' => 'OH',
                            'Oklahoma' => 'OK','OK' => 'OK',
                            'Oregon' => 'OR','OR' => 'OR',
                            'Pennsylvania' => 'PA', 'PA' => 'PA',
                            'Rhode Island' => 'RI', 'RI' => 'RI',
                            'South Carolina' => 'SC', 'SC' => 'SC',
                            'South Dakota' => 'SD', 'SD' => 'SD',
                            'Tennessee' => 'TN', 'TN' => 'TN',
                            'Texas' => 'TX','TX' => 'TX',
                            'Utah' => 'UT', 'UT' => 'UT',
                            'Vermont' => 'VT', 'VT' => 'VT',
                            'Virginia' => 'VA','VA' => 'VA',
                            'Washington' => 'WA','WA' => 'WA',
                            'West Virginia' => 'WV','WV' => 'WV',
                            'Wisconsin' => 'WI','WI' => 'WI',
                            'Wyoming' => 'WY','WY' => 'WY'
                            
                            };
        
        Schema.DescribeSObjectResult result = ElixirSuite__Claim__c.sObjectType.getDescribe();
        List<String> apiNames =  new List<String>(result.fields.getMap().keySet());
        String query = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNames,','))  + ',ElixirSuite__payor__r.ElixirSuite__Payer_Code__c' + ' FROM ElixirSuite__Claim__c ';
        query+= 'WHERE Id IN: secClaimCreationList';
        List<ElixirSuite__Claim__c> listOfClaims = (List<ElixirSuite__Claim__c>)Database.query(query);
        
        Schema.DescribeSObjectResult resultVob = ElixirSuite__VOB__c.sObjectType.getDescribe();
        List<String> apiNamesVob =  new List<String>(resultVob.fields.getMap().keySet());
        String queryVob = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNamesVob,','))  + ' FROM ElixirSuite__VOB__c ';
        queryVob+= 'WHERE ElixirSuite__Account__c IN: accIdList AND ElixirSuite__Status__c = ' +'\''+ 'Active' + '\' AND RecordType.DeveloperName= ' +'\''+ 'Secondary_VOB' + '\''+' Order By CreatedDate Asc';
        List<ElixirSuite__VOB__c> listOfSecIns = (List<ElixirSuite__VOB__c>)Database.query(queryVob);
        
        Map<Id,ElixirSuite__VOB__c> VobMap = new Map<Id,ElixirSuite__VOB__c>();
        for(ElixirSuite__VOB__c ins: listOfSecIns){
          VobMap.put(ins.ElixirSuite__Account__c,ins);
        }
        
        List<ElixirSuite__Claim__c> secClaimInsertionList = new List<ElixirSuite__Claim__c>();
        for(Claim__c c: listOfClaims){
          Claim__c newClaim = new Claim__c();
          newClaim.ElixirSuite__Account__c = c.ElixirSuite__Account__c; 
          newClaim.Patient_DOB__c = c.Patient_DOB__c;
          newClaim.ElixirSuite__Patient_Name__c = c.ElixirSuite__Patient_Name__c;
          newClaim.Patient_s_Address__c = c.Patient_s_Address__c;
          newClaim.ElixirSuite__Patient_Address_2__c = c.ElixirSuite__Patient_Address_2__c;
          newClaim.Patient_s_City__c = c.Patient_s_City__c;
          newClaim.Patient_s_State__c = c.Patient_s_State__c;
          newClaim.ElixirSuite__Patient_Country_Code__c = c.ElixirSuite__Patient_Country_Code__c;
          newClaim.Patient_Zip_Code__c = c.Patient_Zip_Code__c;
          newClaim.Patient_s_Phone__c = c.Patient_s_Phone__c;
          newClaim.ElixirSuite__Patient_Account_Number__c = c.ElixirSuite__Patient_Account_Number__c;
          newClaim.ElixirSuite__Patient_Sex__c = c.ElixirSuite__Patient_Sex__c;
          if(VobMap != null && VobMap.get(c.ElixirSuite__Account__c) != null){
             String insuredName;
              if((VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_First_Name__c != null) {
               insuredName = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_First_Name__c;    
              }
              if((VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_Middle_Name__c != null){
                  insuredName = insuredName +' '+(VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_Middle_Name__c;
              }
              if((VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_Last_Name__c != null){
                  insuredName = insuredName +' '+(VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_Last_Name__c;
              }
          newClaim.Insured_s_Name__c =insuredName;
          newClaim.Insurance_Type__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insurance_Type__c;   
          newClaim.Patient_Relationship_to_Insured__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Patient_Relationship_With_Insured__c;
          newClaim.Insured_Address__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_Address__c;
          if(stateAbbreviationMap.get((VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_State__c) != null){
          newClaim.Insured_State__c = stateAbbreviationMap.get((VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_State__c);
          }else{
          newClaim.Insured_State__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_State__c;   
          }
          newClaim.Insured_City__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_City__c;
          newClaim.Insured_Zip_Code__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_Zipcode__c;
          newClaim.Insured_Country_Code__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_Country__c;
          newClaim.Insured_Telephone__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__InsPhone__c;
          newClaim.Insured_s_ID_Number__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Member_Id__c;
          newClaim.Other_Insured_s_Name__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Other_Insured_s_Name__c;
          newClaim.Other_Insured_s_Policy_Group_Number__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Other_Insured_Policy_Group_FECA_Number__c;
          newClaim.Other_Insurance_Plan_Name__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__OtherInsurancePlanName__c; 
          newClaim.Insured_Policy__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insured_Policy_Group_FECA_Number__c;
          newClaim.Insurance_Plan_Name__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Insurance_Plan_Name__c; 
          //newClaim.ElixirSuite__Billing_Provider_Tax_ID_Type__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Federal_Tax_ID_Number__c;
          newClaim.ElixirSuite__Insured_DOB__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Date_Of_Birth__c;
          newClaim.ElixirSuite__VOB_lookup__c =  (VobMap.get(c.ElixirSuite__Account__c)).Id; 
          newClaim.Insured_Sex__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Gender__c =='Female'? 'F' : 'M';
          newClaim.Payor__c = (VobMap.get(c.ElixirSuite__Account__c)).ElixirSuite__Payer__c;
          }
          newClaim.Other_Claim_Id__c = c.Other_Claim_Id__c;
          newClaim.Claim_Codes__c = c.Claim_Codes__c; 
          newClaim.ElixirSuite__Diagnosis_A__c = c.ElixirSuite__Diagnosis_A__c;
          newClaim.ElixirSuite__Diagnosis_B__c = c.ElixirSuite__Diagnosis_B__c;
          newClaim.ElixirSuite__Diagnosis_C__c = c.ElixirSuite__Diagnosis_C__c;
          newClaim.ElixirSuite__Diagnosis_D__c = c.ElixirSuite__Diagnosis_D__c;
          newClaim.ElixirSuite__Diagnosis_E__c = c.ElixirSuite__Diagnosis_E__c;
          newClaim.ElixirSuite__Diagnosis_F__c = c.ElixirSuite__Diagnosis_F__c;
          newClaim.ElixirSuite__Diagnosis_G__c = c.ElixirSuite__Diagnosis_G__c;
          newClaim.ElixirSuite__Diagnosis_H__c = c.ElixirSuite__Diagnosis_H__c;
          newClaim.ElixirSuite__Diagnosis_I__c = c.ElixirSuite__Diagnosis_I__c;
          newClaim.ElixirSuite__Diagnosis_J__c = c.ElixirSuite__Diagnosis_J__c;
          newClaim.ElixirSuite__Diagnosis_K__c = c.ElixirSuite__Diagnosis_K__c;
          newClaim.ElixirSuite__Diagnosis_L__c = c.ElixirSuite__Diagnosis_L__c;
          newClaim.Additional_Claim_Information__c = c.Additional_Claim_Information__c;
          newClaim.Insured_Authorized_Person_Signature__c = c.Insured_Authorized_Person_Signature__c;
          newClaim.Patient_Signature__c = c.Patient_Signature__c;
          newClaim.Federal_Tax_Id_Number__c = c.Federal_Tax_Id_Number__c;
          newClaim.Name_of_referring_provider_Other_sourc__c = c.Name_of_referring_provider_Other_sourc__c;
                    newClaim.Referring_Physician_Signature__c = c.Referring_Physician_Signature__c;
                    newClaim.ElixirSuite__Bill_Phone__c=c.ElixirSuite__Bill_Phone__c;
                    newClaim.Accept_Assignment__c = c.Accept_Assignment__c;
          newClaim.ElixirSuite__Reserved_For_NUCC_Use3__c = c.ElixirSuite__Reserved_For_NUCC_Use3__c;
          newClaim.ElixirSuite__Sign_of_Phy_or_Supplier_Signature__c = c.ElixirSuite__Sign_of_Phy_or_Supplier_Signature__c;
                    newClaim.Reserved_For_NUCC_Use1__c = c.Reserved_For_NUCC_Use1__c;
          newClaim.Reserved_For_NUCC_Use2__c = c.Reserved_For_NUCC_Use2__c;
          newClaim.NPI__c = c.NPI__c;
          newClaim.ElixirSuite__QUAL_For_Date_current_illness_injury__c = c.ElixirSuite__QUAL_For_Date_current_illness_injury__c; 
          newClaim.ElixirSuite__QUAL_For_Other_Dates__c = c.ElixirSuite__QUAL_For_Other_Dates__c;
          newClaim.ElixirSuite__NUCC__c = c.ElixirSuite__NUCC__c;
          newClaim.ElixirSuite__NUCC_Description__c = c.ElixirSuite__NUCC_Description__c;
          newClaim.Outside_Lab_new__c =c.Outside_Lab_new__c;
          newClaim.ElixirSuite__Outside_Lab_Charges__c =c.ElixirSuite__Outside_Lab_Charges__c;
          newClaim.ElixirSuite__QUAL_For_Name_of_referring_provider__c = c.ElixirSuite__QUAL_For_Name_of_referring_provider__c;
          newClaim.ElixirSuite__First_Name_NAME_OF_REFERRING_PROVIDER__c = c.ElixirSuite__First_Name_NAME_OF_REFERRING_PROVIDER__c;
          newClaim.ElixirSuite__Last_Name_NAME_OF_REFERRING_PROVIDER__c = c.ElixirSuite__Last_Name_NAME_OF_REFERRING_PROVIDER__c;
          newClaim.ElixirSuite__MiddleName_NAME_OF_REFERRING_PROVIDER__c = c.ElixirSuite__MiddleName_NAME_OF_REFERRING_PROVIDER__c;
          //newClaim.ElixirSuite__Prior_Authorization_Number__c = c.ElixirSuite__Prior_Authorization_Number__c;
          //newClaim.ElixirSuite__Resubmission_Code__c = c.ElixirSuite__Resubmission_Code__c;
          //newClaim.ElixirSuite__Original_Ref_No__c = c.ElixirSuite__Original_Ref_No__c;
          newClaim.ElixirSuite__Hospitalization_From_Date__c = c.ElixirSuite__Hospitalization_From_Date__c;
          newClaim.ElixirSuite__Hospitalization_To_Date__c = c.ElixirSuite__Hospitalization_To_Date__c;
          newClaim.ElixirSuite__Sign_of_Phy_or_Supplier_Date__c = c.ElixirSuite__Sign_of_Phy_or_Supplier_Date__c;
          newClaim.ElixirSuite__From_Date_Patient_Unable_To_Work__c = c.ElixirSuite__From_Date_Patient_Unable_To_Work__c;
          newClaim.ElixirSuite__To_Date_Patient_Unable_To_Work__c = c.ElixirSuite__To_Date_Patient_Unable_To_Work__c;
          newClaim.Patient_Condition_Related_To_Employment__c = c.Patient_Condition_Related_To_Employment__c;
          newClaim.Patient_Condition_Related_To_Accident__c = c.Patient_Condition_Related_To_Accident__c;
          newClaim.Patient_Condition_to_Other_Accident__c = c.Patient_Condition_to_Other_Accident__c;
          newClaim.Any_Other_Health_Benefit_Plan__c = c.Any_Other_Health_Benefit_Plan__c;
          newClaim.Date_Of_Current_Illness__c = c.Date_Of_Current_Illness__c;
          newClaim.Hospitalization_Dates__c = c.Hospitalization_Dates__c;
          newClaim.Other_Date__c = c.Other_Date__c;
          newClaim.Dates_Patient_Unable_To_Work__c = c.Dates_Patient_Unable_To_Work__c;
          newClaim.ElixirSuite__Amount_Paid__c = c.ElixirSuite__Amount_Paid__c;
          newClaim.Total_Charge__c = c.Total_Charge__c;
          //newClaim.ElixirSuite__Insured_Or_Auth_Persn_Date__c = c.ElixirSuite__Insured_Or_Auth_Persn_Date__c;
          //newClaim.ElixirSuite__Auto_Accident_Related__c = c.ElixirSuite__Auto_Accident_Related__c;
          newClaim.Claim_Status__c = 'Ready to Submit';
          newClaim.ElixirSuite__Payer_Order__c = 'Secondary';
          newClaim.ElixirSuite__Claim__c = c.Id;
            
//Billing Details
          newClaim.ElixirSuite__Billing_Provider_Other_ID__c = c.ElixirSuite__Billing_Provider_Other_ID__c;
          newClaim.ElixirSuite__Billing_Provider_Info__c = c.ElixirSuite__Billing_Provider_Info__c;
          newClaim.ElixirSuite__Billing_Provider_Name__c =c.ElixirSuite__Billing_Provider_Name__c;   
          newClaim.Billing_Provider_Address_1__c=c.Billing_Provider_Address_1__c;
          newClaim.Billing_Provider_Address_2__c=c.Billing_Provider_Address_2__c;
newClaim.ElixirSuite__Billing_Provider_Taxonomy__c = c.ElixirSuite__Billing_Provider_Taxonomy__c;
          newClaim.ElixirSuite__Billing_Provider_City__c=c.ElixirSuite__Billing_Provider_City__c;
          newClaim.ElixirSuite__Billing_Provider_State__c=c.ElixirSuite__Billing_Provider_State__c;
          newClaim.ElixirSuite__Billing_Provider_Zip__c=c.ElixirSuite__Billing_Provider_Zip__c;
          newClaim.ElixirSuite__Billing_Provider_Tax_ID__c=c.ElixirSuite__Billing_Provider_Tax_ID__c;
          newClaim.ElixirSuite__Billing_Provider_Info_NPI__c = c.ElixirSuite__Billing_Provider_Info_NPI__c;  
           newClaim.ElixirSuite__Billing_Provider_Tax_ID_Type__c = c.ElixirSuite__Billing_Provider_Tax_ID_Type__c;
          //Service Details
           newClaim.ElixirSuite__Service_Facility_Location_NPI__c = c.ElixirSuite__Service_Facility_Location_NPI__c;
           newClaim.ElixirSuite__Service_Facility_Location_Information__c = c.ElixirSuite__Service_Facility_Location_Information__c;
           newClaim.ElixirSuite__Servic_Fcility_Loc_Informaton_OtherID__c = c.ElixirSuite__Servic_Fcility_Loc_Informaton_OtherID__c;
           newClaim.ElixirSuite__Service_Facility_Loc_Address__c = c.ElixirSuite__Service_Facility_Loc_Address__c; 
           newClaim.ElixirSuite__Service_Facility_Address_2__c = c.ElixirSuite__Service_Facility_Address_2__c;
           newClaim.ElixirSuite__Service_Facility_Loc_City__c = c.ElixirSuite__Service_Facility_Loc_City__c;
           newClaim.ElixirSuite__Service_Facility_Loc_State__c = c.ElixirSuite__Service_Facility_Loc_State__c;
           newClaim.ElixirSuite__Service_Facility_Loc_Zip__c = c.ElixirSuite__Service_Facility_Loc_Zip__c;
            
          //Rendering Details
           newClaim.ElixirSuite__Rendering_Provider_First_Name__c = c.ElixirSuite__Rendering_Provider_First_Name__c;
           newClaim.ElixirSuite__Rendering_Provider_Last_Name__c = c.ElixirSuite__Rendering_Provider_Last_Name__c;
           newClaim.ElixirSuite__Rendering_Provider_Taxonomy__c = c.ElixirSuite__Rendering_Provider_Taxonomy__c ;
           newClaim.ElixirSuite__Rendering_Provider_NPI__c = c.ElixirSuite__Rendering_Provider_NPI__c;
           newClaim.ElixirSuite__Rendering_Provider_Tax_Id__c = c.ElixirSuite__Rendering_Provider_Tax_Id__c;
           newClaim.ElixirSuite__Rendering_Provider_Address__c = c.ElixirSuite__Rendering_Provider_Address__c;
            
           //Care Episode Lookup
            newClaim.ElixirSuite__Visits__c = c.ElixirSuite__Visits__c;
            
          secClaimInsertionList.add(newClaim);
        }
        
        if(secClaimInsertionList != null && secClaimInsertionList.size() > 0){
            DMLManager.insertAsUser(secClaimInsertionList);
        }
        
        Map<String,String> priClaimVSSecClaim = new Map<String,String>(); 
        for(Claim__c cd:secClaimInsertionList){
           priClaimVSSecClaim.put(cd.ElixirSuite__Claim__c,cd.Id);
        }
        
        Schema.DescribeSObjectResult resultCL = Claim_Line_Items__c.sObjectType.getDescribe();
        List<String> apiNamesCL =  new List<String>(resultCL.fields.getMap().keySet());
        String queryCL = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNamesCL,','))  + ' FROM Claim_Line_Items__c ';
        queryCL+= 'WHERE ElixirSuite__Claim__c IN: secClaimCreationList';
        List<Claim_Line_Items__c> listOfClaimLineItems = (List<Claim_Line_Items__c>)Database.query(queryCL);
        
        List<Claim_Line_Items__c> InsertionClaimLineItemsList = new List<Claim_Line_Items__c>();
        for(Claim_Line_Items__c rec:listOfClaimLineItems){
            Claim_Line_Items__c newClaimLineItem = new  Claim_Line_Items__c();
            if(priClaimVSSecClaim != null && priClaimVSSecClaim.get(rec.Claim__c) != null){
                newClaimLineItem.Claim__c = priClaimVSSecClaim.get(rec.Claim__c);
            }
            newClaimLineItem.ElixirSuite__Claim_Procedure_Line_Item__c = rec.Id;
            newClaimLineItem.ElixirSuite__EMG__c = rec.ElixirSuite__EMG__c;
            newClaimLineItem.ElixirSuite__Place_of_Service__c = rec.ElixirSuite__Place_of_Service__c;
            newClaimLineItem.ElixirSuite__Place_of_Service_Code_s__c = rec.ElixirSuite__Place_of_Service_Code_s__c;
            newClaimLineItem.ElixirSuite__Modifier_1__c = rec.ElixirSuite__Modifier_1__c;
            newClaimLineItem.ElixirSuite__Modifier_2__c = rec.ElixirSuite__Modifier_2__c;
            newClaimLineItem.ElixirSuite__Modifier_3__c = rec.ElixirSuite__Modifier_3__c;
            newClaimLineItem.ElixirSuite__Modifier_4__c = rec.ElixirSuite__Modifier_4__c;
            newClaimLineItem.ElixirSuite__Diagnosis_Pointer__c = rec.ElixirSuite__Diagnosis_Pointer__c;
            newClaimLineItem.ElixirSuite__Procedure_Charge__c = rec.ElixirSuite__Procedure_Charge__c;
            newClaimLineItem.ElixirSuite__Days_Units__c = rec.ElixirSuite__Days_Units__c;
            newClaimLineItem.ElixirSuite__Family_Plan__c = rec.ElixirSuite__Family_Plan__c;
            newClaimLineItem.ElixirSuite__EPSTD__c = rec.ElixirSuite__EPSTD__c;
            newClaimLineItem.ElixirSuite__ID_Qual__c = rec.ElixirSuite__ID_Qual__c;
                        newClaimLineItem.ElixirSuite__CPT_HCPCS_Code__c =  rec.ElixirSuite__CPT_HCPCS_Code__c;                                                           
            newClaimLineItem.Procedure__c= rec.Procedure__c;
            newClaimLineItem.ElixirSuite__From_Date_Of_Service__c = rec.ElixirSuite__From_Date_Of_Service__c;
            newClaimLineItem.ElixirSuite__To_Date_Of_Service__c = rec.ElixirSuite__To_Date_Of_Service__c;

            //Rendering Information
            newClaimLineItem.ElixirSuite__Rendering_Provider_First_Name__c = rec.ElixirSuite__Rendering_Provider_First_Name__c;
            newClaimLineItem.ElixirSuite__Rendering_Provider_Last_Name__c = rec.ElixirSuite__Rendering_Provider_Last_Name__c;
            newClaimLineItem.ElixirSuite__Rendering_Provider_Taxonomy__c = rec.ElixirSuite__Rendering_Provider_Taxonomy__c;
            newClaimLineItem.ElixirSuite__Rendering_Provider_NPI__c = rec.ElixirSuite__Rendering_Provider_NPI__c;
            newClaimLineItem.ElixirSuite__Rendering_Provider_Non_NPI__c = rec.ElixirSuite__Rendering_Provider_Non_NPI__c;
            newClaimLineItem.ElixirSuite__Rendering_Provider_Address__c = rec.ElixirSuite__Rendering_Provider_Address__c;
                
            InsertionClaimLineItemsList.add(newClaimLineItem);
        }
        if(InsertionClaimLineItemsList != null && InsertionClaimLineItemsList.size() > 0){
            DMLManager.insertAsUser(InsertionClaimLineItemsList);
        }
       }catch(Exception e){
            ExceptionLog.logError(e); 
       }
    }
}