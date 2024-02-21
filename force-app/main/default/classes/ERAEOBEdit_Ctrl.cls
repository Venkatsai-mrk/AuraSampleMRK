public with sharing class ERAEOBEdit_Ctrl {
    
    @AuraEnabled
    public static ERAWrapper getERARecord(String recordId){ // used for editeraOnPaymentPosting - parent ERA
        ERAWrapper wrap = new ERAWrapper();
        try{
        ElixirSuite__EOB__c eob = [Select id,Name,ElixirSuite__Primary_Posted__c,ElixirSuite__Claim__r.ElixirSuite__Patient_Name__c,ElixirSuite__Claim__r.ElixirSuite__Posted__c,ElixirSuite__Claim__r.Name,ElixirSuite__Claim__r.ElixirSuite__Total_Charge__c,ElixirSuite__EOB__r.Name,ElixirSuite__Payer_Claim__c,ElixirSuite__ERA_Status_Code__c,
                                   ElixirSuite__Payment_Status__c,ElixirSuite__Total_Allowed__c,ElixirSuite__Claim__r.ElixirSuite__Total_Contracted_Amount__c,
                                   ElixirSuite__Total_Adjustment_Amount__c,ElixirSuite__Total_Paid__c,ElixirSuite__Net_Paid_Amt__c,ElixirSuite__Action_to_be_Taken__c,ElixirSuite__Interest_Late_Filling_Charges__c,ElixirSuite__Total_Provider_Adjustment_Amt__c,ElixirSuite__Total_Other_Insurance_Responsibility__c from ElixirSuite__EOB__c where Id=: recordId WITH SECURITY_ENFORCED];
        
        AggregateResult[] groupedResults = [Select SUM(ElixirSuite__Total_Allowed_Amount__c),SUM(ElixirSuite__Paid__c),SUM(ElixirSuite__Patient_Responsibility__c) from ElixirSuite__ERA_Line_Item__c WHERE ElixirSuite__EOB__c=: recordId WITH SECURITY_ENFORCED];
        AggregateResult[] groupedResults1 =[Select SUM(ElixirSuite__Paid__c) from ElixirSuite__ERA_Line_Item__c WHERE ElixirSuite__EOB__c=: recordId AND ElixirSuite__Claim_Line_Items__c!=null WITH SECURITY_ENFORCED];
        
        //ERAWrapper wrap = new ERAWrapper();
        
        wrap.eob = eob;
        wrap.totalAllowedSum = (Decimal.valueOf(String.valueOf(groupedResults[0].get('expr0')))).setScale(2);
        wrap.totalPaidSum = (Decimal.valueOf(String.valueOf(groupedResults[0].get('expr1')))).setScale(2);
        wrap.totalPatientResponsibilitySum = (Decimal.valueOf(String.valueOf(groupedResults[0].get('expr2')))).setScale(2);
        wrap.totalMatchedPaidSum = Decimal.valueOf(String.valueOf(groupedResults1[0].get('expr0')));
        wrap.mapOfERAStatusCode = MasterProblemListController.fetchPickListValue('ElixirSuite__EOB__c','ElixirSuite__ERA_Status_Code__c');   
        wrap.mapOfActionToBeTaken = MasterProblemListController.fetchPickListValue('ElixirSuite__EOB__c','ElixirSuite__Action_to_be_Taken__c');
        wrap.listOfInformationCode = MasterProblemListController.fetchPickListValue('ElixirSuite__ERA_Line_Item__c','ElixirSuite__Adjustment_Remark_Codes__c').values();
                }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrap;
    }
    
    @AuraEnabled
    public static List<ElixirSuite__ERA_Line_Item__c> getERALineItems(String recordId){
        
        List<ElixirSuite__ERA_Line_Item__c> eralineItems = [Select id,ElixirSuite__Claim_Line_Items__c,ElixirSuite__Charge__c,ElixirSuite__Total_Charge__c,ElixirSuite__EOB__c,ElixirSuite__Adjustment_Amount_1__c, ElixirSuite__Adjustment_Amount_2__c, ElixirSuite__Adjustment_Amount_3__c, ElixirSuite__Adjustment_Amount_4__c, ElixirSuite__Adjustment_Amount_5__c, ElixirSuite__Adjustment_Amount_6__c,
                                                            ElixirSuite__Code_1__c, ElixirSuite__Code_2__c, ElixirSuite__Code_3__c, ElixirSuite__Code_4__c, ElixirSuite__Code_5__c, ElixirSuite__Code_6__c, 
                                                            ElixirSuite__Group_1__c, ElixirSuite__Group_2__c, ElixirSuite__Group_3__c, ElixirSuite__Group_4__c, ElixirSuite__Group_5__c, ElixirSuite__Group_6__c,
                                                            ElixirSuite__Adjustment_Amount_7__c, ElixirSuite__Adjustment_Amount_8__c, ElixirSuite__Code_7__c, ElixirSuite__Code_8__c, ElixirSuite__Group_7__c, ElixirSuite__Group_8__c,ElixirSuite__Adjustment_Remark_Codes__c,
                                                            ElixirSuite__Proc_code__c,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure_Charge__c,ElixirSuite__Paid__c,ElixirSuite__Total_Allowed_Amount__c,ElixirSuite__Total_Adjustment_Amount__c,ElixirSuite__Patient_Responsibility__c,ElixirSuite__Other_Insurance_Responsibility__c,ElixirSuite__Provider_Adjustment__c from ElixirSuite__ERA_Line_Item__c 
                                                            where ElixirSuite__EOB__c =: recordId WITH SECURITY_ENFORCED];
        
        return eralineItems;
    }
    public static  List<Object>  utilityMapDeserialize(String stringifiedJSON,String keyToGet){         
        Map<String, Object> tableLstJSON =(Map<String, Object>) JSON.deserializeUntyped(stringifiedJSON);
        return  (List<Object>) tableLstJSON.get(keyToGet);
    } 
    public static void deserializeAdjustmentCodeTable( List<AdjustmentSummaryClass> adjCodeTableValues,ElixirSuite__ERA_Line_Item__c eraLine){
        Integer i = 1;
        for(integer j=0;j<adjCodeTableValues.size(); j++){
            
            eraLine.put('ElixirSuite__Group_'+i+'__c',String.valueOf(adjCodeTableValues[j].SelectedAdjustmentGroupCode));    
            eraLine.put('ElixirSuite__Code_'+i+'__c',String.valueOf(adjCodeTableValues[j].SelectedAdjustmentReason));  
                        
            if(adjCodeTableValues[j].AdjustmentAmount!=null){
                eraLine.put('ElixirSuite__Adjustment_Amount_'+i+'__c',Decimal.valueOf(String.valueOf(adjCodeTableValues[j].AdjustmentAmount)));    
            }
            
            i++;                
            
            system.debug('gp'+adjCodeTableValues[j].SelectedAdjustmentGroupCode);
            system.debug('re'+adjCodeTableValues[j].SelectedAdjustmentReason);
            system.debug('amt'+adjCodeTableValues[j].AdjustmentAmount);
            system.debug('j'+j);
        }
    }
    @AuraEnabled
    public static void saveEraRecord(String recordId,String payerClaim,String statusCode,Decimal billAmt,Decimal allowedAmt,Decimal paidAmt,Decimal adjustmentAmt,
                                     Decimal netPaidAmt,Decimal OtherInsuranceResponsibility, String actionTaken, Decimal matchAmt, Decimal ptResponse, string stringifiedEralineitemList,String stringifiedupdatedlineitemList,
                                     Boolean isPosted,String postingJSON)
    {
        Set<String> setOfEralineItemId = new Set<String>();
        List<ElixirSuite__ERA_Line_Item__c>  listOfEraLineToUpdate= new List<ElixirSuite__ERA_Line_Item__c>();
        
        ElixirSuite__EOB__c eob = [SELECT Id, Name,ElixirSuite__Payer_Claim__c,ElixirSuite__EOB__c,ElixirSuite__ERA_Status_Code__c,ElixirSuite__Patient_Responsibility__c,ElixirSuite__Total_Charge__c,ElixirSuite__Total_Allowed__c,
                                   ElixirSuite__Total_Paid__c,ElixirSuite__Total_Adjustment_Amount__c,ElixirSuite__Net_Paid_Amt__c,ElixirSuite__Action_to_be_Taken__c,ElixirSuite__Matched_Amount__c from 
                                   ElixirSuite__EOB__c where Id =: recordId WITH SECURITY_ENFORCED];
        
        system.debug('stringifiedCL'+stringifiedEralineitemList);
        for(Object obj : utilityMapDeserialize(stringifiedEralineitemList,'key')){
            setOfEralineItemId.add(String.valueOf(obj));
        }
        system.debug('stringified'+stringifiedupdatedlineitemList);
        for(Object obj : utilityMapDeserialize(stringifiedupdatedlineitemList,'key')){
            Map<String, Object> mapOfData = (Map<String, Object>) obj;
            
            Boolean isEdited = Boolean.valueOf(String.valueOf(mapOfData.get('IsEdited')));
            if(isEdited){
                String lineId = String.valueOf(mapOfData.get('lineId'));
                ElixirSuite__ERA_Line_Item__c eraLine = new ElixirSuite__ERA_Line_Item__c(Id = lineId);
                
                eraLine.ElixirSuite__Proc_code__c =String.valueOf(mapOfData.get('ProcedureCode'));
                eraLine.ElixirSuite__Total_Allowed_Amount__c = Decimal.valueOf(String.valueOf(mapOfData.get('allowedAmount')));
                eraLine.ElixirSuite__Paid__c = Decimal.valueOf(String.valueOf(mapOfData.get('paidAmount')));
                eraLine.ElixirSuite__Charge__c =Decimal.valueOf(String.valueOf(mapOfData.get('billedAmount')));
                eraLine.ElixirSuite__Patient_Responsibility__c = Decimal.valueOf(String.valueOf(mapOfData.get('patientResponsibility')));
                String AdjustmentSummary = JSON.serialize(mapOfData.get('ajcdList'));
                
                system.debug('selecteeee'+String.valueOf(mapOfData.get('selectedInfoList')));
                // String tempInfoList = String.valueOf(mapOfData.get('selectedInfoList'));
                List<Object> selectedInfoCodeList = (List<Object>) mapOfData.get('selectedInfoList');
                List<String> templist = new List<String>();
                String inforRemarks='';
                
                for(object ob: selectedInfoCodeList){
                    templist.add(String.valueOf(ob));
                    
                }
                eraLine.ElixirSuite__Adjustment_Remark_Codes__c= String.join(templist, ';');
                
                // List<AdjustmentSummaryClass> adjCodeTableValues= (List<AdjustmentSummaryClass>) JSON.deserializeStrict(AdjustmentSummary,List<AdjustmentSummaryClass>.class);
                
                deserializeAdjustmentCodeTable((List<AdjustmentSummaryClass>) JSON.deserializeStrict(AdjustmentSummary,List<AdjustmentSummaryClass>.class),eraLine); 
                listOfEraLineToUpdate.add(eraLine);
            }
            
            
        }
        
        system.debug('listOfEraLineToUpdate'+listOfEraLineToUpdate.size());
        eob.ElixirSuite__Payer_Claim__c = payerClaim;
        eob.ElixirSuite__ERA_Status_Code__c = statusCode;
        eob.ElixirSuite__Total_Charge__c = billAmt;
        eob.ElixirSuite__Total_Allowed__c = allowedAmt;
        eob.ElixirSuite__Total_Paid__c = paidAmt;
        eob.ElixirSuite__Total_Adjustment_Amount__c = adjustmentAmt;
        eob.ElixirSuite__Net_Paid_Amt__c = netPaidAmt;
        eob.ElixirSuite__Action_to_be_Taken__c = actionTaken;
        eob.ElixirSuite__Matched_Amount__c = matchAmt;
        eob.ElixirSuite__Patient_Responsibility__c = ptResponse;
        eob.ElixirSuite__Total_Patient_Responsibility__c = ptResponse;
        eob.ElixirSuite__Total_OI_Responsibility__c = OtherInsuranceResponsibility;
        if(isPosted){
            eob.ElixirSuite__Primary_Posted__c =isPosted;
        }
        //if (Schema.sObjectType.ElixirSuite__EOB__c.isUpdateable())
        //{
            DMLManager.updateAsUser(eob);
        //}
        
        if(setOfEralineItemId.size() >0){
            system.debug('eralineItems'+setOfEralineItemId);
            List<ElixirSuite__ERA_Line_Item__c> eralineItems = [SELECT Id, Name from ElixirSuite__ERA_Line_Item__c where Id IN: setOfEralineItemId WITH SECURITY_ENFORCED];
            
            system.debug('eralineItems'+eralineItems.size());
            //if (Schema.sObjectType.ElixirSuite__ERA_Line_Item__c.isDeletable()) {
                DMLManager.deleteAsUser(eralineItems);
             //}
        }
        //if (Schema.sObjectType.ElixirSuite__ERA_Line_Item__c.isUpdateable())
        //{
            DMLManager.updateAsUser(listOfEraLineToUpdate);
        //}
        // NOW GO FOR POSTING IF OPTED 
        if(isPosted){
            ElixirOEM_AddEraHelper.ParentERADataWrapper flow_sObj = new ElixirOEM_AddEraHelper.ParentERADataWrapper();
            ElixirSuite__EOB__c[] eobParentRecord = [SELECT ID,Name,ElixirSuite__Payment_Method__c FROM ElixirSuite__EOB__c
                                                     WHERE ID = : eob.ElixirSuite__EOB__c WITH SECURITY_ENFORCED];
            if(eobParentRecord!=null && eobParentRecord.size()>0){
                flow_sObj.paymentMethod = eobParentRecord[0].ElixirSuite__Payment_Method__c;
                flow_sObj.parentERAHash =  eobParentRecord[0].Name;
            }
            Map<String,Object> claimIdAndObjectMap = new Map<String,Object>(); 
            ElixirSuite__EOB__c[] sObjArrToPost = new List<ElixirSuite__EOB__c>(); // TO POST PAYMENT IF OPTED 
            ElixirSuite__EOB__c[] childERALst =  querychildERA(eob.id);
            for(ElixirSuite__EOB__c insertedchildERA : childERALst){
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
            for(Object obj : ElixirOEM_AddEraHelper.utilityMapDeserialize(postingJSON,'childERAtableList')){
                Map<String, Object> mapOfChildEraData = (Map<String, Object>) obj;                
                claimIdAndObjectMap.put(String.valueOf(mapOfChildEraData.get('claimId')),obj);
            }  
            
            ElixirOEM_PaymentPostingHelper.postPaymentUtility(sObjArrToPost, flow_sObj, new Map<String,Object>());
            ElixirOEM_PaymentPostingHelper.updateClaimPerChildERA(claimIdAndObjectMap,flow_sObj);
            
        }
        
    }
    public static ElixirSuite__EOB__c[] querychildERA(String childERAId){
        String additionFieldsPrefix = ' WHERE ID =: childERAId';
        String otherFieldsAddition = ' ,ElixirSuite__Claim__r.Name'; 
        String eraQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__EOB__c',otherFieldsAddition,additionFieldsPrefix+'');
        //    ElixirOEM_TimelineHelper.mDebugUntruncated(eraQuery);
        return Database.query(eraQuery);
    }
    @AuraEnabled
    public static void saveChildEralineRecords(String eraLineObjectList,String adjustmentReasonCode,String recommendationList,String delRecList,String noteList,String delNoteList)
    {
        
        System.debug('NOTES '+JSON.serialize(noteList));
        system.debug('meg test' + adjustmentReasonCode);
        List<ElixirSuite__ERA_Line_Item__c> eraLineLst = new List<ElixirSuite__ERA_Line_Item__c>();
        List<childEraLineClass> rawObjLst = (List<childEraLineClass>) JSON.deserializeStrict(eraLineObjectList,List<childEraLineClass>.class);
        
        
        if(rawObjLst.size() >0){
            for(childEraLineClass obj: rawObjLst){
                //ElixirSuite__ERA_Line_Item__c  eraline = obj.eralineItem;
                eraLineLst.add(obj.lineItem);            
            }
        }
        if(eraLineLst.size()>0){
            DMLManager.updateAsUser(eraLineLst);
        }
        
        //Added by Akanksha
        
        List<Object> eraNotesList = (List<Object>) JSON.deserializeUntyped(noteList);
        List<Object> eraDelNotesList = (List<Object>) JSON.deserializeUntyped(delNoteList);
        List<Object> eraRecommendationList = (List<Object>) JSON.deserializeUntyped(recommendationList);
        List<Object> eraDelRecommendationList = (List<Object>) JSON.deserializeUntyped(delRecList);
        List<ElixirSuite__Recommendation__c> recommendationListToDelete = new List<ElixirSuite__Recommendation__c>();
        List<ElixirSuite__Notes__c> noteListToDelete = new List<ElixirSuite__Notes__c>();
        System.debug('eraNotesList '+eraNotesList);
        List<ElixirSuite__Recommendation__c> recommendationsToUpsert = new List<ElixirSuite__Recommendation__c>();//List to insert Recommendation
        List<ElixirSuite__Notes__c> notesToUpsert = new List<ElixirSuite__Notes__c>();//List to insert Followup Notes
        
        RecordType rt = [select id,name from RecordType where sobjecttype = 'ElixirSuite__Recommendation__c' and name='Adjustment Codes' WITH SECURITY_ENFORCED limit 1 ];
        for(Object recommendation : eraRecommendationList){
           Map<String, Object> recommendationData = (Map<String, Object>) recommendation;

            if(String.isNotBlank(String.valueOf(recommendationData.get('ElixirSuite__Elixir_Recommendation__c')))){
                ElixirSuite__Recommendation__c rec = new ElixirSuite__Recommendation__c();
                if(recommendationData.get('Id') != null && String.isNotBlank(String.valueOf(recommendationData.get('Id')))){
                    rec.Id = String.valueOf(recommendationData.get('Id')); 
                }
                rec.RecordTypeId = rt.Id;
                rec.ElixirSuite__Elixir_Recommendation__c = String.valueOf(recommendationData.get('ElixirSuite__Elixir_Recommendation__c'));
                if(String.isNotBlank(String.valueOf(recommendationData.get('ElixirSuite__Elixir_Assign_To__c')))){
                    rec.ElixirSuite__Elixir_Assign_To__c =  String.valueOf(recommendationData.get('ElixirSuite__Elixir_Assign_To__c'));
                }else{
                    rec.ElixirSuite__Elixir_Assign_To__c =  null;
                }
                rec.ElixirSuite__Elixir_ERA__c = String.valueOf(recommendationData.get('ElixirSuite__Elixir_ERA__c'));
                recommendationsToUpsert.add(rec);
               
            }
        }
        
        for(Object delRecObj : eraDelRecommendationList){
            Map<String, Object> delRecData = (Map<String, Object>) delRecObj;
            ElixirSuite__Recommendation__c obj_delRecommendation = new ElixirSuite__Recommendation__c();  
            if(delRecData.get('Id') != null && String.isNotBlank(String.valueOf(delRecData.get('Id')))){
                obj_delRecommendation.Id =  String.valueOf(delRecData.get('Id'));
            }
            recommendationListToDelete.add(obj_delRecommendation);
        }
        
        
        if(ElixirSuite__Recommendation__c.sObjectType.getDescribe().isCreateable() && recommendationsToUpsert != null){
            DMLManager.upsertAsUser(recommendationsToUpsert);
        }
        if(recommendationListToDelete != null  && ElixirSuite__Recommendation__c.sObjectType.getDescribe().isDeletable()){
            DMLManager.deleteAsUser(recommendationListToDelete); 
        }
        
        RecordType ret = [select id,name from RecordType where sobjecttype = 'ElixirSuite__Notes__c' and name='Claim ERA' WITH SECURITY_ENFORCED limit 1 ];
        
        for(Object notes : eraNotesList){
            Map<String, Object> notesData = (Map<String, Object>) notes;
            if(String.isNotBlank(String.valueOf(notesData.get('ElixirSuite__Follow_Up_Notes__c'))) && String.isNotBlank(String.valueOf(notesData.get('ElixirSuite__Elixir_Assigned_To__c'))) && String.isNotBlank(String.valueOf(notesData.get('ElixirSuite__Elixir_Follow_up_Date__c')))){
                ElixirSuite__Notes__c note = new ElixirSuite__Notes__c();
                if(notesData.get('Id') != null && String.isNotBlank(String.valueOf(notesData.get('Id')))){
                    note.Id =  String.valueOf(notesData.get('Id'));
                }
                note.RecordTypeId = ret.Id;
                note.ElixirSuite__Follow_Up_Notes__c = String.valueOf(notesData.get('ElixirSuite__Follow_Up_Notes__c'));
                note.ElixirSuite__Elixir_Assigned_To__c = String.valueOf(notesData.get('ElixirSuite__Elixir_Assigned_To__c')); 
                note.ElixirSuite__Elixir_Follow_up_Date__c = DateTime.valueOfGmt((String.valueOf(notesData.get('ElixirSuite__Elixir_Follow_up_Date__c'))).replace('T',' '));
                note.ElixirSuite__ERA_Notes__c = String.valueOf(notesData.get('ElixirSuite__ERA_Notes__c'));  
                notesToUpsert.add(note);
                
            }
            
        }
        
        for(Object delNotesObj : eraDelNotesList){
            Map<String, Object> delNotesData = (Map<String, Object>) delNotesObj;
            ElixirSuite__Notes__c obj_delNotes = new ElixirSuite__Notes__c();  
            if(delNotesData.get('Id') != null && String.isNotBlank(String.valueOf(delNotesData.get('Id')))){
                obj_delNotes.Id =  String.valueOf(delNotesData.get('Id'));
            }
            noteListToDelete.add(obj_delNotes);
        }
        
        if(ElixirSuite__Notes__c.sObjectType.getDescribe().isCreateable() && notesToUpsert != null){
            DMLManager.upsertAsUser(notesToUpsert);
        }
        if(noteListToDelete != null  && ElixirSuite__Notes__c.sObjectType.getDescribe().isDeletable()){
            DMLManager.deleteAsUser(noteListToDelete); 
        }
        //End Akanksha
        
    }
    
    public class ERAWrapper{
        @AuraEnabled public ElixirSuite__EOB__c eob;
        @AuraEnabled public Decimal totalAllowedSum;
        @AuraEnabled public Decimal totalPaidSum;
        @AuraEnabled public Decimal totalPatientResponsibilitySum;
        @AuraEnabled public Decimal totalMatchedPaidSum;
        @AuraEnabled public Map<String, String> mapOfERAStatusCode; 
        @AuraEnabled public Map<String, String> mapOfActionToBeTaken;
        @AuraEnabled public List<String> listOfInformationCode;
        //added by Neha
        //  @AuraEnabled public List<String> infoCodePicklistValues ;
        //  @AuraEnabled public List<String> SuppCodePicklistValues ;
    }
    public class childEraLineClass{
        public ElixirSuite__ERA_Line_Item__c lineItem;
        
    }
    
    public class AdjustmentSummaryClass{
        public string AdjustmentAmount;
        public string SelectedAdjustmentGroupCode;
        public string SelectedAdjustmentReason;
        public string SelectedSupplementalCode;
    }
    
}