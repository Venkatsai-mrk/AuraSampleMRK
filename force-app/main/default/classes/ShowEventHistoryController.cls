public with sharing class ShowEventHistoryController {
    @AuraEnabled
    public static AllHistoryWrapper getAllRelatedHistory(String evtId) {
        Event evtToFetch  = [SELECT  AccountId,StartDateTime , EndDateTime , Subject, 
                             ActivityDateTime, WhoId, WhatId FROM Event
                             where id = :evtId WITH SECURITY_ENFORCED LIMIT 1];
        String acctId = evtToFetch.AccountId;
        Contact[] forAcctId = [SELECT AccountId from Contact 
        where id = : evtToFetch.WhoId 
        WITH SECURITY_ENFORCED
        Limit 1];
        //  Id acctId = forAcctId.AccountId;
        // List<Case> createdCases = [Select Id,/*,care_plan_name__c,*/status,/*start_date__c,*/ LastModifiedDate  from Case  where   
//CreatedDate >: evtToFetch.StartDateTime and CreatedDate <:  evtToFetch.EndDateTime AND AccountId = : evtToFetch.AccountId /*AND care_plan_name__c!=NULL*/ order by CreatedDate];

        List<ContentDocument> DocumentList = new List<ContentDocument>();  
        
        Set<Id> documentIds = new Set<Id>(); 
        List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:acctId WITH SECURITY_ENFORCED];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        DocumentList = [select Id,Title,FileType,ContentSize,Description from ContentDocument where id IN: documentIds AND                                         
                        CreatedDate >: evtToFetch.StartDateTime and CreatedDate <:  evtToFetch.EndDateTime WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];  
        // return DocumentList;  // Return list of files on parent record
        
        
        List<Prescription_Order__c> med = [select ID,Drug_Name__c from Prescription_Order__c
                                                                 where  /*CreatedDate >: evtToFetch.StartDateTime and CreatedDate <:  evtToFetch.EndDateTime AND*/ Account__c = : evtToFetch.AccountId
                                                                 WITH SECURITY_ENFORCED
                                                                 order by CreatedDate];
        
        list<Prescription_Order__c> OrderList = [Select id, name, Status__c,Account__c,lastmodifieddate,  createddate from Prescription_Order__c
                                                 where  /*CreatedDate >: evtToFetch.StartDateTime and CreatedDate <:  evtToFetch.EndDateTime AND */Account__c = : evtToFetch.AccountId
                                                 WITH SECURITY_ENFORCED
                                                 order by CreatedDate];
        List<Treatment_Plan__c> createdCases = [Select Id,status__c,Treatment_Plan_Name__c, LastModifiedDate from Treatment_Plan__c 
         where Treatment_Plan_Name__c!=null 
         WITH SECURITY_ENFORCED
         LIMIT 5];
         /*List<Treatment_Plan__c> createdCases = [Select Id,status__c,Treatment_Plan_Name__c, LastModifiedDate from Case  where Treatment_Plan_Name__c!=null LIMIT 5];
       
list<Prescription_Order__c> OrderList = [Select id, name, Status__c,Patient__c,lastmodifieddate,  createddate from Prescription_Order__c limit 5 ];

List<Attachment> att = [SELECT ID,name FROM Attachment LIMIT 5];
List<HealthCloudGA__EhrMedicationPrescription__c> med = [select ID,HealthCloudGA__MedicationName__c from HealthCloudGA__EhrMedicationPrescription__c LIMIT 5];
*/
       /*List<Form__c> listOfFormsToReturn  = [SELECT Id, Name,Form__r.Id, Category__c,Status__c, Sub_Category__c, Sections__c,Approval_Values1__c,Approval_Values_3__c,Approval_Values_2__c, Version__c, Locations__c,
                                             Signature_value_1__c,Signature_value_2__c,Signature_value_3__c FROM Form__c where Id='a1A3i000000Dq0ZEAS'];   
        */
       List<Form__c> listOfFormsToReturn = [SELECT Id, Name, Category__c,Status__c, Sub_Category__c, Sections__c,Approval_Values1__c,Approval_Values_3__c,Approval_Values_2__c,  Version__c, Locations__c,
                                             Signature_value_1__c,Signature_value_2__c,Signature_value_3__c FROM Form__c 
                                             WHERE CreatedDate >: evtToFetch.StartDateTime and CreatedDate <:  evtToFetch.EndDateTime 
                                             AND  Account__c= :acctId AND Account__c!=null 
                                             WITH SECURITY_ENFORCED
                                             ORDER BY CreatedDate desc];
        
        
        AllHistoryWrapper toReturn = new AllHistoryWrapper();
        toReturn.allAttachments = DocumentList;
        toReturn.allCarePlans = createdCases;
        toReturn.allPrescriptions = med;
        toReturn.acctIDToReturn = acctId;
        toReturn.orders = OrderList;
        toReturn.forms = listOfFormsToReturn;
        toReturn.nameSpace=Elixir_Utility.getNamespace();
        System.debug('fetched '+evtToFetch);
        return toReturn;
    }
    /* commented w.r.t architecture change and for package creation on 25-02-2022
    @AuraEnabled
    public static  Elixir_FormApexController.getFormDataWrapper getFormData(String formId,String acctId,Integer intOffSet) {
        Elixir_FormApexController.getFormDataWrapper ret  = Elixir_FormApexController.getFormData(formId,acctId,intOffSet);
        return ret;
    }*/
    @AuraEnabled
    public static String getStatusCarePlan(String caseId){
        List<Case> cse ; 
        String sat ;
        try{
        cse = [SELECT status from Case where id = : caseId WITH SECURITY_ENFORCED LIMIT 1];
        if(cse!=null && cse.size()>0){
            sat=  cse[0].status;
        }
       
    }
      catch(Exception e){
      ExceptionLog.logError(e);
        }
         return sat;
     }
    public class AllHistoryWrapper{
        
        @AuraEnabled  	public List<ContentDocument> allAttachments{ get; set; }
        @AuraEnabled  	public List<Treatment_Plan__c> allCarePlans{ get; set; }
        @AuraEnabled  	public List<Prescription_Order__c> allPrescriptions{ get; set; }
        @AuraEnabled  	public String acctIDToReturn {get;set;}  
        @AuraEnabled  	public list<Prescription_Order__c> orders {get;set;}
        @AuraEnabled  	public List<Form__c> forms {get;set;}
         @AuraEnabled  	public String nameSpace;
    }
 
}