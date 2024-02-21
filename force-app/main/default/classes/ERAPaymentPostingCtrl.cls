/*
Created By - Meghna Goel
Created Date - 17-Nov-2020
Description - ERA Payment Posting Screen
Lightning Component - ERAPaymentPostingCmp
*/

public with sharing class ERAPaymentPostingCtrl {
    
    @AuraEnabled
    public static wrapperData getParentERA(Integer parentERAPageNo ,Integer recordToDisplay,Integer childERAPageNo){
        List<EOB__c> parentERAList = new List<EOB__c>();
        List<EOB__c> childERAList = new List<EOB__c>();
        
        wrapperData wrpr = new wrapperData();
        
        wrpr.recordToDisplay=recordToDisplay;
        wrpr.parentERAPageNo=parentERAPageNo; 
        wrpr.childERAPageNo=childERAPageNo; 
        
        
        AggregateResult[] parentERAGroupedResults  = [SELECT count(Id)cnt FROM ElixirSuite__EOB__c where ElixirSuite__EOB__c = '' WITH SECURITY_ENFORCED]; 
        wrpr.totalParentERA = Integer.valueof(parentERAGroupedResults[0].get('cnt')); 
        
        AggregateResult[] childERAGroupedResults  = [SELECT count(Id)cnt FROM ElixirSuite__EOB__c where ElixirSuite__EOB__c != '' WITH SECURITY_ENFORCED]; 
        wrpr.totalChildERA = Integer.valueof(childERAGroupedResults[0].get('cnt')); 
        
        
        
        
        parentERAList = [SELECT Id, Name, CreatedDate, CreatedById, ElixirSuite__Payer__c,ElixirSuite__Payment_Trace__c,ElixirSuite__EOB_Id__c,
                         ElixirSuite__Check_Number__c, ElixirSuite__Check_EFT_Date__c, ElixirSuite__Account__c, ElixirSuite__EOB__c ,ElixirSuite__Payer__r.Name
                         FROM ElixirSuite__EOB__c where ElixirSuite__EOB__c = '' WITH SECURITY_ENFORCED order by createddate  desc  LIMIT :recordToDisplay OFFSET :(parentERAPageNo - 1) * recordToDisplay ];
        childERAList = [SELECT Id, Name, CreatedDate, CreatedById, ElixirSuite__Payer__c,ElixirSuite__Payment_Trace__c,ElixirSuite__EOB_Id__c,
                        ElixirSuite__Check_Number__c, ElixirSuite__Check_EFT_Date__c, ElixirSuite__Account__r.Name, ElixirSuite__Claim__r.Name,
                        ElixirSuite__Account__c,ElixirSuite__Claim__c,ElixirSuite__ERA_Status_Code__c,ElixirSuite__Matched_Amount__c,ElixirSuite__Unmatched_Amount__c
                        FROM ElixirSuite__EOB__c where ElixirSuite__EOB__c != '' WITH SECURITY_ENFORCED order by createddate desc  LIMIT :recordToDisplay OFFSET :(childERAPageNo - 1) * recordToDisplay ];
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = ElixirSuite__EOB__c.ElixirSuite__ERA_Status_Code__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Values & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        
        wrpr.picklistOptions = options;
        wrpr.parentEob = parentERAList ;
        wrpr.childEob = childERAList ;
        
        return wrpr ;
    }
    
    public class wrapperData {
        
        @AuraEnabled public List<EOB__c> parentEob;
        @AuraEnabled public List<EOB__c> childEob; 
        @AuraEnabled public Map<String, String> picklistOptions ;
        @AuraEnabled public Integer recordToDisplay {get;set;} 
        @AuraEnabled public Integer parentERAPageNo {get;set;} 
        @AuraEnabled public Integer childERAPageNo {get;set;} 
        @AuraEnabled public Integer totalParentERA {get;set;} 
        @AuraEnabled public Integer totalChildERA {get;set;} 
    }
    
    @AuraEnabled
    public static wrapperData getMasterERA(Date fromDate, Date toDate, String paymentTrace, String eraId, String payerId, String eraNo,Integer parentERAPageNo ,Integer recordToDisplay)
    {
        
        List<EOB__c> parentERAList = new List<EOB__c>();
        wrapperData wrpr = new wrapperData();
        List<String> queries = new List<String>();
       String prefixClaimName = 'SELECT Id,Name,ElixirSuite__EOB_Id__c,ElixirSuite__Payment_Trace__c,ElixirSuite__Payer__c,ElixirSuite__Payer__r.Name,CreatedDate FROM ElixirSuite__EOB__c WHERE ElixirSuite__EOB__c = NULL';

        if(String.isNotBlank(paymentTrace)){
            queries.add('ElixirSuite__Payment_Trace__c= :paymentTrace');
        }
        if(String.isNotBlank(eraId)){
            queries.add('ElixirSuite__EOB_Id__c= :eraId');
        }
        if(fromDate!=null && toDate!=null){
            toDate = toDate + 1;
            queries.add('CreatedDate>= :fromDate AND CreatedDate<= :toDate');
        }
          system.debug('fromDate'+ payerId);
        if(payerId!=null){
            
            queries.add('ElixirSuite__Payer__c= :payerId');
        }
        if(eraNo != null){
            queries.add('Id= :eraNo');
        }
         system.debug('queries'+ queries);
        String clause = prefixClaimName;
        String totalClause = prefixClaimName;
        if(queries!=null && queries.size()>0){
            totalClause = String.escapeSingleQuotes(totalClause) + ' AND ' +String.escapeSingleQuotes(String.join(queries,' AND '))  ;
            clause = String.escapeSingleQuotes(clause) + ' AND ' + String.escapeSingleQuotes(String.join(queries,' AND ')) + ' order by createddate desc LIMIT '+ recordToDisplay+' OFFSET '+(parentERAPageNo - 1) *recordToDisplay;
        }
        else{
            clause = String.escapeSingleQuotes(clause)  + ' order by createddate desc LIMIT '+ recordToDisplay+' OFFSET '+(parentERAPageNo - 1) * recordToDisplay;
        }
        
         wrpr.recordToDisplay=recordToDisplay;
         wrpr.parentERAPageNo=parentERAPageNo; 
         List<EOB__c> totalParentERAList = new List<EOB__c>();
         totalParentERAList = (List<EOB__c>)Database.query(totalClause);
         wrpr.totalParentERA = Integer.valueof(totalParentERAList.size()); 
        
        system.debug('queries'+ clause);
        parentERAList = (List<EOB__c>)Database.query(clause);
         system.debug('queries'+ parentERAList.size());
        wrpr.parentEob = parentERAList ;
        return wrpr ;
    }
    
     @AuraEnabled
    //public static wrapperData getClaimERA(Date fromDate, Date toDate, String eraNo, String patName, String claimId, String statusCde, Boolean matchedUnmatched)
    public static wrapperData getClaimERA(Date fromDate, Date toDate, String eraNo, String patName, String claimId,Integer childERAPageNo ,Integer recordToDisplay) //sagili siva
    {
      // system.debug('ab' + matchedUnmatched);
        List<EOB__c> childERAList = new List<EOB__c>();
        wrapperData wrpr = new wrapperData();
        List<String> queries = new List<String>();
        String prefixClaimName = 'SELECT Id,Name,ElixirSuite__Unmatched_Amount__c,ElixirSuite__ERA_Status_Code__c,ElixirSuite__Claim__c,ElixirSuite__Claim__r.Name,ElixirSuite__Account__c,ElixirSuite__Account__r.Name,CreatedDate FROM ElixirSuite__EOB__c WHERE ElixirSuite__EOB__c != NULL';
        if(String.isNotBlank(eraNo)){
            queries.add('Id= :eraNo');
        }
        if(String.isNotBlank(patName)){
            queries.add('ElixirSuite__Account__c= :patName');
        }
         if(fromDate!=null && toDate!=null){
               toDate = toDate + 1;
            queries.add('CreatedDate>= :fromDate AND CreatedDate<= :toDate');
        }
        if(String.isNotBlank(claimId)){
            queries.add('ElixirSuite__Claim__c= :claimId');
        }
        //sagili siva
	   /* if(statusCde != ''){
            queries.add('ElixirSuite__ERA_Status_Code__c= :statusCde');
        }
        if(matchedUnmatched == true){
            queries.add('ElixirSuite__Unmatched_Amount__c= 0');
        }*/
        String clause = prefixClaimName;
        String totalClause = prefixClaimName;
        system.debug('aa'+ queries);
        if(queries!=null && queries.size()>0){
            totalClause = String.escapeSingleQuotes(totalClause) + ' AND ' + String.escapeSingleQuotes(String.join(queries,' AND '));
            clause = String.escapeSingleQuotes(clause) + ' AND ' + String.escapeSingleQuotes(String.join(queries,' AND ')) + ' order by createddate desc  LIMIT '+ recordToDisplay+' OFFSET '+(childERAPageNo - 1) * recordToDisplay;
        }
        
        wrpr.recordToDisplay=recordToDisplay;
        wrpr.childERAPageNo=childERAPageNo; 
        List<EOB__c> totalchildERAList = new List<EOB__c>();
        totalchildERAList = (List<EOB__c>)Database.query(totalClause);
        wrpr.totalChildERA = Integer.valueof(totalchildERAList.size()); 
        system.debug(clause);
        childERAList = (List<EOB__c>)Database.query(clause);
        wrpr.childEob = childERAList ;
        return wrpr ;
    }
    
    /*
    @AuraEnabled
    public static List<MasterERACls> getMasterERADup(Date fromDate, Date toDate, String checkNum, String filterEraId)
    {
        List<EOB__c> masterERAList = new List<EOB__c>();
        Boolean flag = false;
        String query = 'Select id, Name,ElixirSuite__Claim__c, ElixirSuite__EOB_Id__c, Check_Number__c,'+ 
            +'ElixirSuite__Paid_Date__c, ElixirSuite__Posted__c, ElixirSuite__Payment_Posted__c, ElixirSuite__PaidDate__c, (Select id, Name, ElixirSuite__Claim__c, ElixirSuite__Claim__r.ElixirSuite__Total_Patient_Responsibility__c, ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c, ElixirSuite__Total_Charge__c, ElixirSuite__Total_Paid__c, ElixirSuite__Payment_Posted__c, ElixirSuite__Posted__c  from ElixirSuite__EOB__r where ElixirSuite__Claim__c != null AND ElixirSuite__Manual_ERA__c = true) from ElixirSuite__EOB__c where ElixirSuite__EOB__c = null AND ElixirSuite__Claim__c = null';
        
        if(checkNum != '' || filterEraId != '' || (fromDate != null && toDate != null))
        {
            query= query + ' and ';
        }
        if(checkNum != '')
        {
            String checkNumStr = '%'+checkNum+'%';
            //query = query  + 'Check_Number__c = \'' + checkNum +'\'';
            query = query  + 'ElixirSuite__Check_Number__c LIKE : checkNumStr';
            flag = true;
        }
        if(filterEraId != '')
        {
            if(flag == true)
            {
                query = query + ' and ';
            }
            String filterEraIdStr = '%'+filterEraId+'%';
            //query = query  + 'EOB_Id__c = \'' + filterEraId +'\'';
            query = query  + 'ElixirSuite__EOB_Id__c LIKE : filterEraIdStr';
            flag = true;
        }
        if(fromDate != null && toDate != null)
        {
            if(flag == true)
            {
                query = query + ' and ';
            }
            query = query + 'ElixirSuite__PaidDate__c >=: fromDate and ElixirSuite__PaidDate__c <=: toDate';
        }
        query = query + ' order by ElixirSuite__PaidDate__c desc Limit 50000';
        system.debug('#### query master ERA :  ' + query);
        masterERAList = (List<EOB__c>)Database.query(query);
        
        System.debug('masterERAList===='+masterERAList[0].ElixirSuite__Claim__c);
        Set<Id> childERAId = new Set<Id>();
        Set<Id> claimsId = new Set<Id>();
        Map<Id, List<Id>> eraMap = new Map<Id, List<Id>>();
        for(EOB__c era : masterERAList)
        {
            if(era.EOB__r.size()>0)
            {
                system.debug('#### ERA M--- ' + era.EOB__r);
                for(EOB__c eraChild : era.EOB__r)
                {
                    childERAId.add(eraChild.Id);
                    claimsId.add(eraChild.Claim__c);
                    system.debug('#### ERA Child --- ' + eraChild);
                    if(eraMap.containsKey(era.Id))
                    {
                        List<Id> temp = eraMap.get(era.Id);
                        temp.add(eraChild.Id);
                        eraMap.put(era.Id,temp);
                    }
                    else
                    {
                        List<Id> temp = new List<Id>();
                        temp.add(eraChild.Id);
                        eraMap.put(era.Id,temp);
                    }
                }
                
            }
        }
        Map<Id,EOB__c> eobEraItemsMap = new Map<Id,EOB__c>([Select id, Posted__c, Payment_Posted__c, (Select id, Claim_Line_Items__c, Claim_Line_Items__r.Procedure__c, 
                                                                                                      Total_Adjustment_Amount__c, Paid__c from ERA_Line_Item__r where Claim_Line_Items__c != null 
                                                                                                      AND Claim_Line_Items__r.Procedure__c != null) from EOB__c where Id in: childERAId
                                                                                                      WITH SECURITY_ENFORCED]);
        Map<Id, Map<Id,Id>> eobEraItemProcMap = new Map<Id,Map<Id,Id>>();
        Set<Id> procIds = new Set<Id>();
        for(EOB__c era : eobEraItemsMap.values())
        {
            if(era.ERA_Line_Item__r.size() > 0)
            {
                system.debug('#### ERA with ELIs ---- ' + era);
                Map<Id,Id> eraItemProcMap = new Map<Id,Id>();
                for(ERA_Line_Item__c eli : era.ERA_Line_Item__r)
                {
                    System.debug('#### ELI --- ' + eli);
                    eraItemProcMap.put(eli.Id,eli.Claim_Line_Items__r.Procedure__c);
                    procIds.add(eli.Claim_Line_Items__r.Procedure__c);
                }
                if(eobEraItemProcMap.containsKey(era.Id))
                {
                    Map<Id,Id> temp = eobEraItemProcMap.get(era.Id);
                    temp.putAll(eraItemProcMap);
                    eobEraItemProcMap.put(era.Id,temp);
                }
                else
                {
                    eobEraItemProcMap.put(era.Id,eraItemProcMap);
                }
            }
            
        }
        Map<Id, Payment_Transaction__c> procPayTransMap = new Map<Id,Payment_Transaction__c>();
        for(Payment_Transaction__c payTrans : [select id, Patient_Payments__c, Procedure__c, Payment_Adjustments__c, Insurance_Payments__c
                                                from Payment_Transaction__c where Procedure__c in: procIds
                                               WITH SECURITY_ENFORCED])
        {
            procPayTransMap.put(payTrans.Procedure__c, payTrans);
        }
        
        List<MasterERACls> masterEraLst = new List<MasterERACls>();
        for(EOB__c masterEra : masterERAList)
        {
            Id eraId = masterEra.Id;
            Boolean hasItems = false;
            if(eraMap.containsKey(eraId))
            {
                MasterERACls eraObj = new MasterERACls();
                Decimal totalRemb = 0;
                Decimal totalPayApplied = 0;
                Decimal totalPayPosted = 0;
                Decimal remainingPatientResp = 0;
                Integer noOfPostedChildERA = 0;
                Integer totalNoOfChildERA = eraMap.get(eraId).size();
                for(Id childEobId : eraMap.get(eraId))
                {
                    if(eobEraItemProcMap.containsKey(childEobId))
                    {
                        
                        Map<Id,Id> eliProcMap = eobEraItemProcMap.get(childEobId);
                        EOB__C childEOBRec = eobEraItemsMap.get(childEobId);
                        if(childEOBRec.Posted__c == true)
                        {
                            noOfPostedChildERA = noOfPostedChildERA + 1;
                        }
                        if(childEOBRec.Payment_Posted__c == null){childEOBRec.Payment_Posted__c = 0;}
                        totalPayPosted = totalPayPosted + childEOBRec.Payment_Posted__c;
                        
                        System.debug('#### childEOBRec : ' + childEOBRec);
                        for(Era_line_Item__c eliRec : childEOBRec.ERA_Line_Item__r)
                        {
                            System.debug('#### eliRec : ' + eliRec);
                            if(eliRec.Paid__c == null) {eliRec.Paid__c = 0;}
                            totalRemb = totalRemb + eliRec.Total_Adjustment_Amount__c + eliRec.Paid__c;
                        }
                        for(Id eliId : eliProcMap.keySet())
                        {
                            Id ProcId = eliProcMap.get(eliId);
                            if(procPayTransMap.containsKey(ProcId))
                            {
                                Payment_Transaction__c payTransObj = procPayTransMap.get(ProcId);
                                hasItems = true;
                                if(payTransObj.Payment_Adjustments__c == null){payTransObj.Payment_Adjustments__c = 0;}
                                if(payTransObj.Insurance_Payments__c == null){payTransObj.Insurance_Payments__c = 0;}
                                
                                if(payTransObj.Patient_Payments__c == null){payTransObj.Patient_Payments__c = 0;}
                                totalPayApplied  = totalPayApplied + payTransObj.Patient_Payments__c;
                                
                            }
                        }
                        
                    }
                    
                }
                if(hasItems == true && noOfPostedChildERA != totalNoOfChildERA)
                    //if(hasItems == true)
                {	
                    eraObj.eraWrap = masterEra;
                    eraobj.Selected = false;
                    eraObj.totalRemb = totalRemb;
                    eraObj.totalPayApplied = totalPayApplied;
                    eraObj.totalPayPosted = totalPayPosted;
                    eraObj.remainingPatientResp = remainingPatientResp;
                    
                    masterEraLst.add(eraObj);
                }
            }
        }
        
        return masterEraLst;
    }
    
    @AuraEnabled
    public static List<EOB__c> getSelectedERAs(Date fromDate, Date toDate, String checkNum, String masterERAId, String childClaimId)
    {
        List<EOB__c> selERAList = new List<EOB__c>();
        //
        Boolean flag = false;
        String query = 'Select id, Name, ElixirSuite__Paid_Date__c, ElixirSuite__Claim__c, ElixirSuite__Provider_Name__c, ElixirSuite__Claim__r.ElixirSuite__Account__r.Name, ElixirSuite__Total_Allowed__c, ElixirSuite__Claim__r.Name, ElixirSuite__Claim__r.ElixirSuite__Total_Allowed_Amount__c, ElixirSuite__Claim__r.ElixirSuite__Total_Patient_Responsibility__c, ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c,ElixirSuite__Claim__r.ElixirSuite__Total_Charge__c, ElixirSuite__Total_Charge__c, ElixirSuite__Total_Paid__c, ElixirSuite__Claim__r.ElixirSuite__Claimid__c, (Select id, ElixirSuite__Claim_Line_Items__c, ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__c, ElixirSuite__Total_Adjustment_Amount__c, ElixirSuite__Paid__c from ElixirSuite__ERA_Line_Item__r where ElixirSuite__Claim_Line_Items__c != null AND ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__c != null) from ElixirSuite__EOB__c where ElixirSuite__EOB__c =: masterERAId AND ElixirSuite__Claim__c != null and ElixirSuite__Posted__c = false AND (ElixirSuite__Manual_ERA_Status__c = \'ERA Generated\' OR ElixirSuite__Manual_ERA_Status__c = \'Saved\') AND ElixirSuite__Manual_ERA__c = true';
        if(checkNum != '' || (fromDate != null && toDate != null) || childClaimId != '')
        {
            query = query + ' and ';
        }
        if(checkNum != '')
        {
            flag = true;
            String checkNumStr = '%'+checkNum+'%';
            //query= query + 'Check_Number__c = \'' + checkNum +'\'';
            query = query  + 'ElixirSuite__Check_Number__c LIKE : checkNumStr';
        }
        if(fromDate != null && toDate != null)
        {
            if(flag == true)
            {
                query = query + ' and ';
            }
            flag = true;
            DateTime fromDT = DateTime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0));
            DateTime toDT = DateTime.newInstance(toDate, Time.newInstance(0, 0, 0, 0));
            
            query = query + 'LastModifiedDate >=: fromDT and LastModifiedDate <=: toDT';
        }
        if(childClaimId != '')
        {
            if(flag == true)
            {
                query = query + ' and ';
            }
            String childClaimIdStr = '%'+childClaimId+'%';
            query= query + 'ElixirSuite__Claim__r.Name LIKE : childClaimIdStr';
        }
        query = query + ' Limit 50000';
        System.debug('#### sub ERA query' + query ) ;
        selERAList = (List<EOB__c>)Database.query(query);
        
        
        return selERAList;
    }
    
    @AuraEnabled
    public static List<ERA_Line_Item__c> getERALineItems(String selERAId)
    {
        List<ERA_Line_Item__c> ERALineItemList = new List<ERA_Line_Item__c>(); 
        String query = 'Select id, ElixirSuite__Deductible__c, ElixirSuite__CoPay__c, ElixirSuite__Proc_code__c, ElixirSuite__Charge__c, ElixirSuite__Total_Allowed_Amount__c, ElixirSuite__EOB__r.ElixirSuite__CoPayment__c, ElixirSuite__EOB__r.ElixirSuite__Deductible__c, ElixirSuite__Total_Adjustment_Amount__c, ElixirSuite__Paid__c, ElixirSuite__Claim_Line_Items__c, ElixirSuite__Claim_Line_Items__r.ElixirSuite__Patient_Responsibility__c, ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__c, ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__From_Date_of_Service__c, ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__To_Date_of_Service__c , ElixirSuite__Claim_Line_Items__r.ElixirSuite__Modifier_1__c,ElixirSuite__Claim_Line_Items__r.ElixirSuite__Modifier_2__c, ElixirSuite__Claim_Line_Items__r.ElixirSuite__Modifier_3__c, ElixirSuite__Claim_Line_Items__r.ElixirSuite__Modifier_4__c, ElixirSuite__Adjustment_Amount_1__c, ElixirSuite__Adjustment_Amount_2__c, ElixirSuite__Adjustment_Amount_3__c, ElixirSuite__Adjustment_Amount_4__c, ElixirSuite__Adjustment_Amount_5__c, ElixirSuite__Adjustment_Amount_6__c, ElixirSuite__Adjustment_Code_1__c, ElixirSuite__Adjustment_Code_2__c,ElixirSuite__Adjustment_Code_3__c, ElixirSuite__Adjustment_Code_4__c, ElixirSuite__Adjustment_Code_5__c, ElixirSuite__Adjustment_Code_6__c from ElixirSuite__ERA_Line_Item__c where ElixirSuite__Claim_Line_Items__c != null AND ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__c != null AND ElixirSuite__EOB__c = \''+selERAId+'\'';
        query = query + ' Limit 50000';
        System.debug(' --- ' + query);
        ERALineItemList = (List<ERA_Line_Item__c>)Database.query(query);
        system.debug('#### ERALineItemList : ' + ERALineItemList);
        return ERALineItemList;
    }
    @AuraEnabled
    public static void postERAPayments(List<ERAItem> eraItemList, String parentEraId) {
        
        Set<Id> eliIdSet = new Set<Id>();
        List<ERA_Line_Item__c> eliToSave = new List<ERA_Line_Item__c>();
        
        SObjectType contactType = Schema.getGlobalDescribe().get('ElixirSuite__EOB__c');
        Map<String,Schema.SObjectField> mfields = contactType.getDescribe().fields.getMap();
        System.debug('mfields=='+mfields);
        List<String> sObjectDetailsList = new List<String>();
        System.debug('sObjectDetailsList=='+sObjectDetailsList);
        for(String s : mfields.keySet()){
            sObjectDetailsList.add(String.valueOf(mfields.get(s)));
        }
        System.debug('sObjectDetailsList Final=='+sObjectDetailsList);
        String query = 'Select ' + String.join(sObjectDetailsList,',') + ' ,ElixirSuite__Claim__r.ElixirSuite__Account__c from ElixirSuite__EOB__c where id =  \''+parentEraId+'\'';
        List<EOB__c> oldEOB = (List<EOB__c>)Database.query(query);
        //EOB__c oldEOB = [Select id, Name, Paid_Date__c, Claim__c, Provider_Name__c, Total_Allowed__c, Total_Charge__c, Total_Paid__c, EOB__c, Manual_ERA__c, Manual_ERA_Status__c from EOB__c where Id =: parentERAId LIMIT 1];
        for(ERAItem item : eraItemList)
        {
            eliIdSet.add(item.Id);
        }
        SObjectType eliType = Schema.getGlobalDescribe().get('ElixirSuite__ERA_Line_Item__c');
        Map<String,Schema.SObjectField> mfields2 = eliType.getDescribe().fields.getMap();
        List<String> sObjectDetailsList2 = new List<String>();
        for(String s : mfields2.keySet()){
            sObjectDetailsList2.add(String.valueOf(mfields2.get(s)));
        }
        String query2 = 'Select ' + String.join(sObjectDetailsList2,',') + ' from ElixirSuite__ERA_Line_Item__c where id in: eliIdSet';
        //List<ERA_Line_Item__c> eliLst = new List<ERA_Line_Item__c>([Select id, Proc_code__c, Charge__c, Total_Allowed_Amount__c, Total_Adjustment_Amount__c, Paid__c, Claim_Line_Items__c from ERA_Line_Item__c where Id in: eliIdSet]);
        List<ERA_Line_Item__c> eliLst = (List<ERA_Line_Item__c>) Database.query(query2);
        Map<Id,ERA_Line_Item__c> eliMap = new Map<Id,ERA_Line_Item__c>();
        Set<Id> cliIdSet = new Set<Id>();
        for(ERA_Line_Item__c eli : eliLst)
        {
            cliIdSet.add(eli.Claim_Line_Items__c);
            eliMap.put(eli.Id,eli);
        }
        Map<Id,Claim_Line_Items__c> cliMap = new Map<Id,Claim_Line_Items__c>([SELECT ID,
                                                                              Name,
                                                                              Amount_Paid_by_Insurance__c,
                                                                              Total_Adjustment__c,
                                                                              Patient_Responsibility__c,
                                                                              CPT_HCPCS_Code__c,Procedure__c,
                                                                              ERA_Received__c,
                                                                              Days_Units__c,
                                                                              Total_Allowed_Amount__c 
                                                                              FROM Claim_Line_Items__c
                                                                              WHERE Id in: cliIdSet
                                                                              WITH SECURITY_ENFORCED]);
        Set<Id> ClaimProcedureIds = new Set<Id>();
        Map<Id,Payment_Transaction__c> procedurePaymentTransactionMap = new Map<Id,Payment_Transaction__c>();
        
        for(Claim_Line_Items__c cli : cliMap.values())
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
                                                                                  WHERE id in: ClaimProcedureIds
                                                                                  WITH SECURITY_ENFORCED]);
        for(Procedure__c pro : procedurePaymentTransactions)
        {
            if(pro.Payment_Transaction__r.size()>0)
            {
                Payment_Transaction__c temp = pro.Payment_Transaction__r[0];
                procedurePaymentTransactionMap.put(pro.Id,temp);
            }
        }
        List<EOB__c> copyEOBLst = new List<EOB__c>();
        if(oldEOB.size() > 0)
        {
            copyEOBLst = [Select id from EOB__c where Claim__c =: oldEOB[0].Claim__c AND Claim__r.Manual_ERA__c = true AND Manual_ERA__c = false AND Copy_Of_Original_ERA__c = true AND EOB__c =: oldEOB[0].Id
            WITH SECURITY_ENFORCED]; //checking if we already have a copy
        }
        if(! (copyEOBLst.size() > 0))
        {
            EOB__c eraClone  = oldEOB[0].clone(false, false, false, false);
            eraClone.Manual_ERA__c = false;
            eraClone.Manual_ERA_Status__c = '';
            eraClone.EOB__c = oldEOB[0].Id;
            eraClone.Copy_Of_Original_ERA__c = true;
            insert eraClone;
            
            List<ERA_Line_Item__c> cloneEliLst = new List<ERA_Line_Item__c>();
            
            for(ERA_Line_Item__c eli : eliLst)
            {
                ERA_Line_Item__c eliClone = eli.clone(false,false,false,false);
                eliClone.EOB__c = eraClone.Id;
                cloneEliLst.add(eliClone);
                cliIdSet.add(eli.Claim_Line_Items__c);
            }
            insert cloneEliLst;
        }
        Decimal totalCharge = 0;
        Decimal totalAllowed = 0;
        Decimal totalProviderPaid = 0;
        Decimal totalDeductible = 0;
        Decimal totalCopay = 0;
        Decimal totalAdjustment = 0;
        List<Claim_Line_Items__c> cliToUpdate = new List<Claim_Line_Items__c>();
        
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
        for(ERAItem item : eraItemList)
        {
            //eliIdSet.add(item.Id);
            ERA_Line_Item__c eliRec = eliMap.get(item.Id);
            eliRec.Charge__c = item.Charge == null ? 0 : item.Charge;
            eliRec.Total_Allowed_Amount__c = item.AllowedAmount == null ? 0 : item.AllowedAmount;
            eliRec.Paid__c = item.ProviderPaid == null ? 0 : item.ProviderPaid ;
            eliRec.Deductible__c = item.Deductible == null ? 0 : item.Deductible;
            eliRec.CoPay__c = item.CoPay == null ? 0 : item.CoPay;
            eliRec.Adjustment_Amount_1__c = item.Adjustment_Amount_1 == null ? 0 : item.Adjustment_Amount_1;
            eliRec.Adjustment_Amount_2__c = item.Adjustment_Amount_2 == null ? 0 : item.Adjustment_Amount_2;
            eliRec.Adjustment_Amount_3__c = item.Adjustment_Amount_3 == null ? 0 : item.Adjustment_Amount_3;
            eliRec.Adjustment_Amount_4__c = item.Adjustment_Amount_4 == null ? 0 : item.Adjustment_Amount_4;
            eliRec.Adjustment_Amount_5__c = item.Adjustment_Amount_5 == null ? 0 : item.Adjustment_Amount_5;
            eliRec.Adjustment_Amount_6__c = item.Adjustment_Amount_6 == null ? 0 : item.Adjustment_Amount_6;
            
            eliToSave.add(eliRec);
            
            oldEOB[0].Deductible__c = item.Deductible;
            oldEOB[0].CoPayment__c = item.CoPay;
            oldEOB[0].Manual_ERA_Status__c = 'Posted';
            oldEOB[0].Posted__c = true;
            totalCharge += eliRec.Charge__c;
            totalAllowed += eliRec.Total_Allowed_Amount__c;
            totalProviderPaid += eliRec.Paid__c;
            totalDeductible += eliRec.Deductible__c;
            totalCoPay += eliRec.CoPay__c;
            totalAdjustment += eliRec.Adjustment_Amount_1__c + eliRec.Adjustment_Amount_2__c + eliRec.Adjustment_Amount_3__c+ eliRec.Adjustment_Amount_4__c+eliRec.Adjustment_Amount_5__c+eliRec.Adjustment_Amount_6__c;
            
            
            Id cliId = eliMap.get(item.Id).Claim_Line_Items__c;
            Claim_Line_Items__c createPaymentRecord = cliMap.get(cliId);
            createPaymentRecord.Modifier_1__c = item.Mod1 == null ? '' : item.Mod1;
            createPaymentRecord.Modifier_2__c = item.Mod2 == null ? '': item.Mod2;
            createPaymentRecord.Modifier_3__c = item.Mod3 == null ? '' : item.Mod3;
            createPaymentRecord.Modifier_4__c = item.Mod4 == null ? '' : item.Mod4;
            createPaymentRecord.ERA_Received__c = true;
            
            cliToUpdate.add(createPaymentRecord);
            
            Payment_Transaction__c paymentRecord  = procedurePaymentTransactionMap.get(createPaymentRecord.Procedure__c);
            
            if(createPaymentRecord.Amount_Paid_by_Insurance__c == null) {
                createPaymentRecord.Amount_Paid_by_Insurance__c = 0;
            }
            
            if(createPaymentRecord.Total_Adjustment__c == null) {
                createPaymentRecord.Total_Adjustment__c = 0;
            }
            
            if(paymentRecord.Actual_Price__c >= eliRec.Paid__c + eliRec.Total_Adjustment_Amount__c) { 
                
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
                
                
                paymentRecord.Total_Received_Amount__c = paymentRecord.Total_Received_Amount__c + eliRec.Paid__c;
                paymentRecord.Insurance_Payments__c =  paymentRecord.Insurance_Payments__c + eliRec.Paid__c;
                paymentRecord.Payment_Adjustments__c = paymentRecord.Payment_Adjustments__c + eliRec.Total_Adjustment_Amount__c;

                paymentRecord.Insurance_Responsibility__c = eliRec.Paid__c;

                paymentRecord.ERA_Arrived__c = true;
                mainPaymentTransactionsToUpdate.add(paymentRecord);
                
                
                Master_Transaction__c createParentMasterTransaction = new Master_Transaction__c();
                
                createParentMasterTransaction.Account__c = oldEOB[0].Claim__r.Account__c;
                createParentMasterTransaction.Payment_By__c = 'Insurance';
                createParentMasterTransaction.Transaction_Date__c = System.today();
                createParentMasterTransaction.Payment_Type__c = 'Online';
                createParentMasterTransaction.Allocated_Amount__c =eliRec.Total_Adjustment_Amount__c;
                createParentMasterTransaction.Total_Unallocated_Amount__c = 0;
                createParentMasterTransaction.Total_Amount_Paid__c = eliRec.Total_Adjustment_Amount__c;
                createParentMasterTransaction.RecordTypeId = allocatedMasterTxnRecordTypeId;
                
                uow1.registerNew(createParentMasterTransaction); 
                masterTransactionsToInsert.add(createParentMasterTransaction);
                
                Payment_Transaction__c createPaymentRecords = new Payment_Transaction__c();
                
                createPaymentRecords.Insurance_Payments__c = 0;
                createPaymentRecords.Payment_Sub_Transaction__c = paymentRecord.Id;
                createPaymentRecords.Received_From__c = 'Insurance';
                createPaymentRecords.Received_Amount__c = eliRec.Total_Adjustment_Amount__c;
                createPaymentRecords.Status__c = 'Paid';
                createPaymentRecords.Date_Of_Service__c = System.today();
                createPaymentRecords.Payment_Adjustments__c = eliRec.Total_Adjustment_Amount__c;
                createPaymentRecords.Payment_Type__c = 'Insurance Adjustments';
                createPaymentRecords.RecordTypeId = paymntTxnRecordTypeId;
                createPaymentRecords.Account__c = oldEOB[0].Claim__r.Account__c; //By Sonal
                
                uow1.registerRelationship(createPaymentRecords, Payment_Transaction__c.Master_Transaction__c , createParentMasterTransaction);
                uow1.registerNew(createPaymentRecords); 
                subPaymentTransactionsToInsert.add(createPaymentRecords);
                
                Master_Transaction__c createParentMasterTransactionForInsurance = new Master_Transaction__c();
                
                createParentMasterTransactionForInsurance.Account__c = oldEOB[0].Claim__r.Account__c;
                createParentMasterTransactionForInsurance.Payment_By__c = 'Insurance';
                createParentMasterTransactionForInsurance.Payment_Type__c = 'Allocated';
                createParentMasterTransactionForInsurance.Allocated_Amount__c = eliRec.Paid__c;
                createParentMasterTransactionForInsurance.Total_Amount_Paid__c = eliRec.Paid__c;
                createParentMasterTransactionForInsurance.Total_Unallocated_Amount__c = 0;
                createParentMasterTransactionForInsurance.Transaction_Date__c = System.today();
                createParentMasterTransactionForInsurance.RecordTypeId = allocatedMasterTxnRecordTypeId;
                
                uow1.registerNew(createParentMasterTransactionForInsurance); 
                masterTransactionsToInsert.add(createParentMasterTransactionForInsurance);
                
                Payment_Transaction__c createPaymentRecordsInsurance = new Payment_Transaction__c();
                
                createPaymentRecordsInsurance.Insurance_Payments__c = eliRec.Paid__c;
                createPaymentRecordsInsurance.Payment_Sub_Transaction__c = paymentRecord.Id;
                createPaymentRecordsInsurance.Received_From__c = 'Insurance';
                createPaymentRecordsInsurance.Received_Amount__c = eliRec.Paid__c;
                createPaymentRecordsInsurance.Status__c = 'Paid';
                createPaymentRecordsInsurance.Date_Of_Service__c = System.today();
                createPaymentRecordsInsurance.Payment_Adjustments__c = 0;
                createPaymentRecordsInsurance.Payment_Type__c = 'Insurance';
                createPaymentRecordsInsurance.RecordTypeId = paymntTxnRecordTypeId;
                createPaymentRecordsInsurance.Account__c = oldEOB[0].Claim__r.Account__c; //By Sonal
                
                uow1.registerRelationship(createPaymentRecordsInsurance, Payment_Transaction__c.Master_Transaction__c , createParentMasterTransactionForInsurance);
                uow1.registerNew(createPaymentRecordsInsurance); 
                subPaymentTransactionsToInsert.add(createPaymentRecordsInsurance);
                
            }
        }
        oldEOB[0].Total_Charge__c = totalCharge;
        oldEOB[0].Total_Allowed__c = totalAllowed;
        oldEOB[0].Total_Paid__c = totalProviderPaid;
        oldEOB[0].Deductible__c = totalDeductible;
        oldEOB[0].CoPayment__c = totalCoPay;
        oldEOB[0].Total_Adjustment_Amount__c = totalAdjustment;
        oldEOB[0].Payment_Posted__c = totalProviderPaid + totalAdjustment;
        try {
            Claim__c claimToUpdate = new Claim__c();
            claimToUpdate.Id = oldEOB[0].Claim__c;
            claimToUpdate.Manual_ERA__c = false;
            update claimToUpdate;
            
            update oldEOB;
            update eliToSave;
            update cliToUpdate;
            if(mainPaymentTransactionsToUpdate != null && mainPaymentTransactionsToUpdate.size() >0 ) {
                update mainPaymentTransactionsToUpdate;
            }
            uow1.commitWork();
            
        } catch(Exception ex) {
            System.debug('Error : ' + ex.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static void saveERA(List<ERAItem> eraItemList, String parentEraId)
    {
        Set<Id> eliIdSet = new Set<Id>();
        List<ERA_Line_Item__c> eliToSave = new List<ERA_Line_Item__c>();
        
        SObjectType contactType = Schema.getGlobalDescribe().get('ElixirSuite__EOB__c');
        Map<String,Schema.SObjectField> mfields = contactType.getDescribe().fields.getMap();
        List<String> sObjectDetailsList = new List<String>();
        for(String s : mfields.keySet()){
            sObjectDetailsList.add(String.valueOf(mfields.get(s)));
        }
        String query = 'Select ' + String.join(sObjectDetailsList,',') + ' from ElixirSuite__EOB__c where id =  \''+parentEraId+'\'';
        List<EOB__c> oldEOB = (List<EOB__c>)Database.query(query);
        //EOB__c oldEOB = [Select id, Name, Paid_Date__c, Claim__c, Provider_Name__c, Total_Allowed__c, Total_Charge__c, Total_Paid__c, EOB__c, Manual_ERA__c, Manual_ERA_Status__c from EOB__c where Id =: parentERAId LIMIT 1];
        for(ERAItem item : eraItemList)
        {
            eliIdSet.add(item.Id);
        }
        SObjectType eliType = Schema.getGlobalDescribe().get('ElixirSuite__ERA_Line_Item__c');
        Map<String,Schema.SObjectField> mfields2 = eliType.getDescribe().fields.getMap();
        List<String> sObjectDetailsList2 = new List<String>();
        for(String s : mfields2.keySet()){
            sObjectDetailsList2.add(String.valueOf(mfields2.get(s)));
        }
        String query2 = 'Select ' + String.join(sObjectDetailsList2,',') + ' from ElixirSuite__ERA_Line_Item__c where id in: eliIdSet';
        //List<ERA_Line_Item__c> eliLst = new List<ERA_Line_Item__c>([Select id, Proc_code__c, Charge__c, Total_Allowed_Amount__c, Total_Adjustment_Amount__c, Paid__c, Claim_Line_Items__c from ERA_Line_Item__c where Id in: eliIdSet]);
        List<ERA_Line_Item__c> eliLst = (List<ERA_Line_Item__c>) Database.query(query2);
        Map<Id,ERA_Line_Item__c> eliMap = new Map<Id,ERA_Line_Item__c>();
        Set<Id> cliIdSet = new Set<Id>();
        for(ERA_Line_Item__c eli : eliLst)
        {
            cliIdSet.add(eli.Claim_Line_Items__c);
            eliMap.put(eli.Id,eli);
        }
        Map<Id,Claim_Line_Items__c> cliMap = new Map<Id,Claim_Line_Items__c>([SELECT ID,
                                                                              Name,
                                                                              Amount_Paid_by_Insurance__c,
                                                                              Total_Adjustment__c,
                                                                              Patient_Responsibility__c,
                                                                              CPT_HCPCS_Code__c,Procedure__c,
                                                                              ERA_Received__c,
                                                                              Days_Units__c,
                                                                              Total_Allowed_Amount__c 
                                                                              FROM Claim_Line_Items__c
                                                                              WHERE Id in: cliIdSet
                                                                              WITH SECURITY_ENFORCED]);
        List<EOB__c> copyEOBLst = new List<EOB__c>();
        if(oldEOB!=null && oldEOB.size()>0)
            copyEOBLst = new List<EOB__c>([Select id from EOB__c 
            where Claim__c =: oldEOB[0].Claim__c AND Claim__r.Manual_ERA__c = true AND
             Manual_ERA__c = false AND Copy_Of_Original_ERA__c = true AND EOB__c =: oldEOB[0].Id
             WITH SECURITY_ENFORCED]); //checking if we already have a copy
        
        if(! (copyEOBLst.size() > 0))
        {
            EOB__c eraClone  = oldEOB[0].clone(false, false, false, false);
            eraClone.Manual_ERA__c = false;
            eraClone.Manual_ERA_Status__c = '';
            eraClone.EOB__c = oldEOB[0].Id;
            eraClone.Copy_Of_Original_ERA__c = true;
            insert eraClone;
            
            List<ERA_Line_Item__c> cloneEliLst = new List<ERA_Line_Item__c>();
            for(ERA_Line_Item__c eli : eliLst)
            {
                ERA_Line_Item__c eliClone = eli.clone(false,false,false,false);
                eliClone.EOB__c = eraClone.Id;
                cloneEliLst.add(eliClone);
            }
            insert cloneEliLst;
        }
        Decimal totalCharge = 0;
        Decimal totalAllowed = 0;
        Decimal totalProviderPaid = 0;
        Decimal totalDeductible = 0;
        Decimal totalCopay = 0;
        Decimal totalAdjustment = 0;
        List<Claim_Line_Items__c> cliToUpdate = new List<Claim_Line_Items__c>();
        for(ERAItem item : eraItemList)
        {
            //eliIdSet.add(item.Id);
            ERA_Line_Item__c eliRec = new ERA_Line_Item__c();
            eliRec.Id = item.Id;
            eliRec.Charge__c = item.Charge == null ? 0 : item.Charge;
            eliRec.Total_Allowed_Amount__c = item.AllowedAmount == null ? 0 : item.AllowedAmount;
            eliRec.Paid__c = item.ProviderPaid == null ? 0 : item.ProviderPaid ;
            eliRec.Deductible__c = item.Deductible == null ? 0 : item.Deductible;
            eliRec.CoPay__c = item.CoPay == null ? 0 : item.CoPay;
            eliRec.Adjustment_Amount_1__c = item.Adjustment_Amount_1 == null ? 0 : item.Adjustment_Amount_1;
            eliRec.Adjustment_Amount_2__c = item.Adjustment_Amount_2 == null ? 0 : item.Adjustment_Amount_2;
            eliRec.Adjustment_Amount_3__c = item.Adjustment_Amount_3 == null ? 0 : item.Adjustment_Amount_3;
            eliRec.Adjustment_Amount_4__c = item.Adjustment_Amount_4 == null ? 0 : item.Adjustment_Amount_4;
            eliRec.Adjustment_Amount_5__c = item.Adjustment_Amount_5 == null ? 0 : item.Adjustment_Amount_5;
            eliRec.Adjustment_Amount_6__c = item.Adjustment_Amount_6 == null ? 0 : item.Adjustment_Amount_6;
            
            eliToSave.add(eliRec);
            
            oldEOB[0].Deductible__c = item.Deductible;
            oldEOB[0].CoPayment__c = item.CoPay;
            oldEOB[0].Manual_ERA_Status__c = 'Saved';
            
            totalCharge += eliRec.Charge__c;
            totalAllowed += eliRec.Total_Allowed_Amount__c;
            totalProviderPaid += eliRec.Paid__c;
            totalDeductible += eliRec.Deductible__c;
            totalCoPay += eliRec.CoPay__c;
            totalAdjustment += eliRec.Adjustment_Amount_1__c + eliRec.Adjustment_Amount_2__c + eliRec.Adjustment_Amount_3__c+ eliRec.Adjustment_Amount_4__c+eliRec.Adjustment_Amount_5__c+eliRec.Adjustment_Amount_6__c;
            
            Id cliId = eliMap.get(item.Id).Claim_Line_Items__c;
            Claim_Line_Items__c createPaymentRecord = cliMap.get(cliId);
            createPaymentRecord.Modifier_1__c = item.Mod1 == null ? '' : item.Mod1;
            createPaymentRecord.Modifier_2__c = item.Mod2 == null ? '': item.Mod2;
            createPaymentRecord.Modifier_3__c = item.Mod3 == null ? '' : item.Mod3;
            createPaymentRecord.Modifier_4__c = item.Mod4 == null ? '' : item.Mod4;
            
            cliToUpdate.add(createPaymentRecord);
        }
        oldEOB[0].Total_Charge__c = totalCharge;
        oldEOB[0].Total_Allowed__c = totalAllowed;
        oldEOB[0].Total_Paid__c = totalProviderPaid;
        oldEOB[0].Deductible__c = totalDeductible;
        oldEOB[0].CoPayment__c = totalCoPay;
        oldEOB[0].Total_Adjustment_Amount__c = totalAdjustment;
        try
        {
            update oldEOB;
            update eliToSave;
            update cliToUpdate;
        }
        catch(Exception ex)
        {
            System.debug('Error : ' + ex.getMessage());
        }
    }
    
    public class MasterERACls
    {
        @AuraEnabled
        public Boolean Selected;
        
        @AuraEnabled
        public EOB__c eraWrap;
        
        @AuraEnabled
        public Decimal remainingPatientResp;
        
        @AuraEnabled
        public Decimal totalRemb;
        
        @AuraEnabled
        public Decimal totalPayApplied;
        
        @AuraEnabled
        public Decimal totalPayPosted;
        
        
        public MasterERACls()
        {
            selected = false;
            eraWrap = new EOB__c();
            totalRemb = 0;
            totalPayApplied = 0;
            totalPayPosted = 0;
        }
    }
    
    public class ERAItem {
        
        @AuraEnabled public Id        Id             {get; set;}
        @AuraEnabled public String    ProcCode       {get; set;}
        @AuraEnabled public Date      StartDate      {get; set;}
        @AuraEnabled public Date      EndDate        {get; set;}
        @AuraEnabled public String    Mod1           {get; set;}
        @AuraEnabled public String    Mod2           {get; set;}
        @AuraEnabled public String    Mod3           {get; set;}
        @AuraEnabled public String    Mod4           {get; set;}
        @AuraEnabled public Decimal   Charge         {get; set;}
        @AuraEnabled public Decimal   AllowedAmount  {get; set;}
        @AuraEnabled public Decimal   Deductible     {get; set;}
        @AuraEnabled public Decimal   CoPay          {get; set;}
        @AuraEnabled public Decimal   totalAdjustment{get; set;}
        @AuraEnabled public Decimal   ProviderPaid   {get; set;}
        @AuraEnabled public Decimal   PatientResp    {get; set;}
        @AuraEnabled public Decimal   Adjustment_Amount_1    {get; set;}
        @AuraEnabled public Decimal   Adjustment_Amount_2    {get; set;}
        @AuraEnabled public Decimal   Adjustment_Amount_3    {get; set;}
        @AuraEnabled public Decimal   Adjustment_Amount_4    {get; set;}
        @AuraEnabled public Decimal   Adjustment_Amount_5    {get; set;}
        @AuraEnabled public Decimal   Adjustment_Amount_6    {get; set;}
        
        /*public ERAItem(Id Idno , String PcCe,Date StDe,Date EDe,String Mod11,String Mod22,String Mod33,String Mod44,Decimal Chge,Decimal Allot,Decimal Dedble,Decimal CPay,Decimal tolAdjt,Decimal PrPd,Decimal PatRp,Decimal Adj1,Decimal Adj2,Decimal Adj3,Decimal Adj4,Decimal Adj5,Decimal Adj6)
{
Id =Idno;
ProcCode =   PcCe;
StartDate  =  StDe; 
EndDate      =EDe;
Mod1       = Mod11;
Mod2     =  Mod22;
Mod3      =Mod33;
Mod4 = Mod44;
Charge    =Chge;  
AllowedAmount =Allot;
Deductible   =Dedble;
CoPay       =   CPay;
totalAdjustment= tolAdjt;
ProviderPaid  =PrPd;
PatientResp   = PatRp;
Adjustment_Amount_1   = Adj1;
Adjustment_Amount_2   =Adj2;
Adjustment_Amount_3   =Adj3;
Adjustment_Amount_4   =Adj4;
Adjustment_Amount_5   =Adj5;
Adjustment_Amount_6  =Adj6;
}
        
    }*/
   
}