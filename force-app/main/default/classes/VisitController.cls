public with sharing class VisitController {
    
    public static void createACR(List<Visits__c> careEpisodes) {
        try {
            List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
            
            Set<Id> accountIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            
            for (ElixirSuite__Visits__c visit : careEpisodes) {
                if (visit.ElixirSuite__Attending_Doctor__c != null) {
                    accountIds.add(visit.ElixirSuite__Account__c);
                    contactIds.add(visit.ElixirSuite__Attending_Doctor__c);
                }
                if (visit.ElixirSuite__Consulting_Doctor__c != null) {
                    accountIds.add(visit.ElixirSuite__Account__c);
                    contactIds.add(visit.ElixirSuite__Consulting_Doctor__c);
                }
                if (visit.ElixirSuite__Admitting_Doctor__c != null) {
                    accountIds.add(visit.ElixirSuite__Account__c);
                    contactIds.add(visit.ElixirSuite__Admitting_Doctor__c);
                }
                if (visit.ElixirSuite__Referring_Doctor__c != null) {
                    accountIds.add(visit.ElixirSuite__Account__c);
                    contactIds.add(visit.ElixirSuite__Referring_Doctor__c);
                }
            }
            
            Map<Id, Set<Id>> existingACRContactIds = new Map<Id, Set<Id>>();
            
            for (AccountContactRelation existingACR : [SELECT AccountId, ContactId
                                                       FROM AccountContactRelation
                                                       WHERE AccountId IN :accountIds
                                                       WITH SECURITY_ENFORCED]) {
                                                           if (!existingACRContactIds.containsKey(existingACR.AccountId)) {
                                                               existingACRContactIds.put(existingACR.AccountId, new Set<Id>());
                                                           }
                                                           existingACRContactIds.get(existingACR.AccountId).add(existingACR.ContactId);
                                                       }
            
            for (ElixirSuite__Visits__c visit : careEpisodes) {
                if (!String.isBlank(visit.ElixirSuite__Attending_Doctor__c)) {                    
                    if(existingACRContactIds.containsKey(visit.ElixirSuite__Account__c)){
                        Set<Id> setid = existingACRContactIds.get(visit.ElixirSuite__Account__c);
                        AccountContactRelation acr=getAcr(setid, visit);
                        accountContactRelations.add(acr);
                        existingACRContactIds.get(visit.ElixirSuite__Account__c).add(visit.ElixirSuite__Attending_Doctor__c);
                        
                    }else{
                        AccountContactRelation acr = new AccountContactRelation(
                            AccountId = visit.ElixirSuite__Account__c,
                            ContactId = visit.ElixirSuite__Attending_Doctor__c
                        );
                        accountContactRelations.add(acr);
                        existingACRContactIds.put(visit.ElixirSuite__Account__c, new Set<Id>{visit.ElixirSuite__Attending_Doctor__c});
                    }                   
                    
                    
                }
                if (!String.isBlank(visit.ElixirSuite__Consulting_Doctor__c))  {
                    if(existingACRContactIds.containsKey(visit.ElixirSuite__Account__c)){
                        Set<Id> setid = existingACRContactIds.get(visit.ElixirSuite__Account__c);
                        AccountContactRelation acr=getAcrForConsulting(setid, visit);
                        accountContactRelations.add(acr);
                        existingACRContactIds.get(visit.ElixirSuite__Account__c).add(visit.ElixirSuite__Consulting_Doctor__c);
                        
                    }else{
                        AccountContactRelation acr = new AccountContactRelation(
                            AccountId = visit.ElixirSuite__Account__c,
                            ContactId = visit.ElixirSuite__Consulting_Doctor__c
                        );
                        accountContactRelations.add(acr);
                        existingACRContactIds.put(visit.ElixirSuite__Account__c, new Set<Id>{visit.ElixirSuite__Attending_Doctor__c});
                        
                    }
                }
                if (!String.isBlank(visit.ElixirSuite__Admitting_Doctor__c)) {
                    if(existingACRContactIds.containsKey(visit.ElixirSuite__Account__c)){
                        Set<Id> setid = existingACRContactIds.get(visit.ElixirSuite__Account__c);
                        AccountContactRelation acr=getAcrForAdmitting(setid, visit);
                        accountContactRelations.add(acr);
                        existingACRContactIds.get(visit.ElixirSuite__Account__c).add(visit.ElixirSuite__Admitting_Doctor__c);
                        
                    }else{
                        AccountContactRelation acr = new AccountContactRelation(
                            AccountId = visit.ElixirSuite__Account__c,
                            ContactId = visit.ElixirSuite__Admitting_Doctor__c
                        );
                        accountContactRelations.add(acr);
                        existingACRContactIds.put(visit.ElixirSuite__Account__c, new Set<Id>{visit.ElixirSuite__Attending_Doctor__c});
                        
                    } 
                }
                if (!String.isBlank(visit.ElixirSuite__Referring_Doctor__c ))  {
                    if( existingACRContactIds.containsKey(visit.ElixirSuite__Account__c )){
                        Set<Id> setid = existingACRContactIds.get(visit.ElixirSuite__Account__c);
                        AccountContactRelation acr=getAcrForReferring(setid, visit);
                        accountContactRelations.add(acr);
                        existingACRContactIds.get(visit.ElixirSuite__Account__c).add(visit.ElixirSuite__Referring_Doctor__c);
                        
                    }else{
                        AccountContactRelation acr = new AccountContactRelation(
                            AccountId = visit.ElixirSuite__Account__c,
                            ContactId = visit.ElixirSuite__Referring_Doctor__c
                        );
                        accountContactRelations.add(acr);
                        existingACRContactIds.put(visit.ElixirSuite__Account__c, new Set<Id>{visit.ElixirSuite__Attending_Doctor__c});
                        
                    }
                }
            }
            
            if (!accountContactRelations.isEmpty()) {
                DMLManager.insertAsUser(accountContactRelations);
            }
        } catch(Exception e) {
            ExceptionLog.logError(e);
        }
    }
    public static AccountContactRelation getAcr(Set<Id> setid, ElixirSuite__Visits__c visit){
        AccountContactRelation acr = new AccountContactRelation();
        if (!setid.contains(visit.ElixirSuite__Attending_Doctor__c)) {
            acr.AccountId = visit.ElixirSuite__Account__c;
            acr.ContactId = visit.ElixirSuite__Attending_Doctor__c;
            
        }
        return acr;
    }
    public static AccountContactRelation getAcrForConsulting(Set<Id> setid, ElixirSuite__Visits__c visit){
        AccountContactRelation acr = new AccountContactRelation();
        if (!setid.contains(visit.ElixirSuite__Consulting_Doctor__c)) {
            acr.AccountId = visit.ElixirSuite__Account__c;
            acr.ContactId = visit.ElixirSuite__Consulting_Doctor__c;
            
        }
        return acr;
    }
    public static AccountContactRelation getAcrForAdmitting(Set<Id> setid, ElixirSuite__Visits__c visit){
        AccountContactRelation acr = new AccountContactRelation();
        if (!setid.contains(visit.ElixirSuite__Admitting_Doctor__c)) {
            acr.AccountId = visit.ElixirSuite__Account__c;
            acr.ContactId = visit.ElixirSuite__Admitting_Doctor__c;
            
        }
        return acr;
    }
    public static AccountContactRelation getAcrForReferring(Set<Id> setid, ElixirSuite__Visits__c visit){
        AccountContactRelation acr = new AccountContactRelation();
        if (!setid.contains(visit.ElixirSuite__Referring_Doctor__c)) {
            acr.AccountId = visit.ElixirSuite__Account__c;
            acr.ContactId = visit.ElixirSuite__Referring_Doctor__c;
            
        }
        return acr;
    }
    
    
    //Added by Ashwini
    @AuraEnabled
    public static string fetchAccountName(string accountId){
        List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        string accName = acc[0].name;
        return accName;
    }
    @Future(callout=true)
    public static void triggerVisitSummary(String visitSummaryStringifiedData){
        
        Map<String,Object> convertedMap = (Map<String,Object>) JSON.deserializeUntyped(visitSummaryStringifiedData);
        List<object> visittLstObj = (List<object>) convertedMap.get('visits');
        List<ElixirSuite__Visits__c> visits = new  List<ElixirSuite__Visits__c>();
        for (Object visitObj : visittLstObj) {
            Map<String, Object> visitMap = (Map<String, Object>) visitObj;
            // Create a new Visits__c object and populate its fields
            Visits__c visit = new Visits__c();
            visit.Id = (String) visitMap.get('Id');
            visit.Name = (String) visitMap.get('Name');
            visit.ElixirSuite__Status__c=(String) visitMap.get('ElixirSuite__Status__c');
            visit.ElixirSuite__Account__c = (Id) visitMap.get('ElixirSuite__Account__c');
            // Add the visit to the visits list
            visits.add(visit);
        }
        
        Map<String,Object> objMap = ( Map<String,Object>)  convertedMap.get('oldVisitsMap'); 
        Map<id,Visits__c> oldVisitsMap  = new Map<Id,Visits__c>(); 
        for (String key : objMap.keySet()) {
            // Convert the key from String to Id
            Id visitId = (Id) key;
            
            Map<String, Object> visitMap = (Map<String, Object>) objMap.get(key);
            // Create a new Visits__c object and populate its fields
            Visits__c visit = new Visits__c();
            visit.Id = visitId;
            visit.Name = (String) visitMap.get('Name');
            visit.ElixirSuite__Status__c=(String) visitMap.get('ElixirSuite__Status__c');
            visit.ElixirSuite__Account__c = (Id) visitMap.get('ElixirSuite__Account__c');
            // Add the visit to the oldVisitsMap using the Id as the key
            oldVisitsMap.put(visitId, visit);
        }
        
        Set<String> allVisitId = new Set<String>();
        String accId = visits[0].Account__c;
        String accountName = visits[0].Name;
        
        for (Visits__c visit : visits) {
            if (visit.ElixirSuite__Status__c == 'Closed') {
                allVisitId.add(visit.Id); 
            }
        }
        if (!allVisitId.isEmpty()) {
            Event[] allRelatedAppointments = [SELECT ID,WhatId,ElixirSuite__Care_Episode__c FROM Event where ElixirSuite__Care_Episode__c in : allVisitId with security_enforced];
            ExceptionLog.logDebugString('allRelatedAppointments: '+allRelatedAppointments);
            ContentVersion[] cvLst = new List<ContentVersion>();
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            //Map<String,ContentVersion> cvCdMap = new Map<String,ContentVersion>();
            for (Event evt : allRelatedAppointments) {
                PageReference pdfPage = Page.VisitSummaryTemplatePdf;
                pdfPage.getParameters().put('accountId', accId);
                pdfPage.getParameters().put('visitId', evt.ElixirSuite__Care_Episode__c);
                Blob pdfBlob = pdfPage.getContentAsPDF();
                
                ContentVersion cv = new ContentVersion();
                cv.Title = 'VisitSummary__' + accountName + '.pdf';
                cv.PathOnClient = 'VisitSummary__' + 'patient' + '.pdf';
                cv.VersionData = pdfBlob;
                
                cvLst.add(cv);
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = evt.Id;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                contentDocumentLinks.add(cdl);
            }
            
            DMLManager.insertAsUser(cvLst);
            
            // Query for the ContentDocumentId values after insert
            Map<Id, Id> contentVersionIdToContentDocumentId = new Map<Id, Id>();
            for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :cvLst WITH SECURITY_ENFORCED]) {
                contentVersionIdToContentDocumentId.put(cv.Id, cv.ContentDocumentId);
            }
            
            // Populate ContentDocumentLink records with the correct ContentDocumentId values
            for (Integer i = 0; i < cvLst.size(); i++) {
                ContentDocumentLink cdl = contentDocumentLinks[i];
                cdl.ContentDocumentId = contentVersionIdToContentDocumentId.get(cvLst[i].Id);
            }
            ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            
            DMLManager.insertAsUser(contentDocumentLinks);
            if(settings.ElixirSuite__Notification_for_visit_summaries__c == true &&
               settings.ElixirSuite__Enable_portal_in_Elixir__c == true){
                   VisitSummaryNotificationHandler.visitNotifications(accId);
               }
            
            
        }
        
    }
    //Added by Anmol for LX3-8141
    @AuraEnabled
    public static boolean generateSuperBill(String accountId,List<Id> careLst){
        
        List<ElixirSuite__VOB__c> vobLst = new List<ElixirSuite__VOB__c>();
        
        boolean checkStatus=false;
        try{
            vobLst=[SELECT Id, 
                    ElixirSuite__Account__c, 
                    ElixirSuite__Status__c 
                    FROM ElixirSuite__VOB__c 
                    WHERE ElixirSuite__Account__c= :accountId
                    AND ElixirSuite__Status__c='Active' 
                    WITH SECURITY_ENFORCED];
            
            if(vobLst != null && vobLst.size() > 0){
                checkStatus = true;
                SuperBill_PdfGenerator.createPdf(careLst,accountId);   
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        return checkStatus;
    }
    //End by Anmol for LX3-8141
    
    @AuraEnabled
    public static wrapper visitRecords(String accountId ){
        // String query ;
        /*query = 'select id, name,ElixirSuite__Pre_Authorization_Number__c,ElixirSuite__Days__c,ElixirSuite__Status__c,LastModifiedDate, ElixirSuite__account__c from ElixirSuite__Visits__c where ElixirSuite__account__c=:accountId order by createddate desc';
List<Visits__c> listOfencounter =  Database.query(query);*/
        String objectName = 'ElixirSuite__Visits__c';
        Wrapper wrpr = new Wrapper();
        try{
            List<String> fields = new List<String>(Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet());
            fields.add('ElixirSuite__Parent_Care_Episode__r.Name');
            fields.add('ElixirSuite__Account__r.Name');
            fields.add('ElixirSuite__Care_Episode_Location__r.Name');
            
            for(integer i=0;i<fields.size();i++){
                if(fields[i]=='ElixirSuite__Opportunity__c'){
                    fields.remove(i);
                }
            }
            
            String query  = 'SELECT '+String.escapeSingleQuotes(String.join(fields, ','))+' FROM ElixirSuite__Visits__c where ElixirSuite__account__c=:accountId WITH SECURITY_ENFORCED order by createddate desc';
            
            List<Visits__c> listOfencounter =Database.query(query);
            String namespace = Elixir_utility.getNameSpace();
            
            wrpr.listOfencounter = listOfencounter;
            wrpr.namespace = namespace;
            
        }
        
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    
    public class Wrapper{
        @AuraEnabled public String namespace;
        @AuraEnabled public List<Visits__c> listOfencounter;
    }
    
  /*  @AuraEnabled               
    public static Boolean statusUpdate(Visits__c visit){
        List<Visits__c> listdatatoUpdate =new List<Visits__c>();
        List<Visits__c> listdata =new List<Visits__c>();
        boolean isCharges = false;
        listdata=[Select id, name, Status__c, account__c from Visits__c 
                  WITH SECURITY_ENFORCED 
                  order by createddate desc Limit 1 ];
        if(listdata != null && listdata.size() > 0){
            
            //added by Anmol for LX3-7236
            Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
            String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
            if(string.isBlank(careFilter)){
                careFilter = 'createddate desc';
            }
            String careStatus = 'Active';
            String accId = listdata[0].account__c;
            
            string querystr = '';
            querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED order by ';
            querystr += careFilter ;
            listdatatoUpdate = database.query(querystr);
            //end by Anmol for LX3-7236
            
            set<id> visitIds = new set<id>(); //Anusha LX3-6883
            for (Integer i = listdatatoUpdate.size() - 1; i >= 0 ; --i) {
                visitIds.add(listdatatoUpdate[i].id); //Anusha LX3-6883
                if (listdatatoUpdate.get(i) == listdata[0] || listdatatoUpdate.get(i).get('id') == listdata[0].get('id')) {
                    listdatatoUpdate.remove(i); 
                }
            }
            //Anusha - start LX3-6883
            List<ElixirSuite__Procedure__c> procedureList = [Select Id, ElixirSuite__Visits__c,ElixirSuite__Charges__c from ElixirSuite__Procedure__c where ElixirSuite__Visits__c in :visitIds
                                                             AND ElixirSuite__Is_Billable__c = true WITH SECURITY_ENFORCED];
            Map<id,List<ElixirSuite__Procedure__c>> visitAndItsProc = new Map<id,List<ElixirSuite__Procedure__c>>();
            for(ElixirSuite__Procedure__c eachProc : procedureList){
                if(visitAndItsProc.containsKey(eachProc.ElixirSuite__Visits__c)){
                    visitAndItsProc.get(eachProc.ElixirSuite__Visits__c).add(eachProc);
                }else{
                    visitAndItsProc.put(eachProc.ElixirSuite__Visits__c,new List<ElixirSuite__Procedure__c>{eachProc});
                }
            }
            if(listdatatoUpdate != null && listdatatoUpdate.size() > 0){
                for(Visits__c e:listdatatoUpdate){
                    isCharges =getIsCharges(e, visitAndItsProc, accId);
                    
                    //Anusha - end LX3-6883
                    e.Status__c='Closed';
                }
            }
            if(listdatatoUpdate.size() > 0  && isCharges != true && accId != null)
            {
                                DMLManager.updateAsUser(listdatatoUpdate);
                
            }
        }
        return true;
            }
    public static Boolean getIsCharges(Visits__c e, Map<id,List<ElixirSuite__Procedure__c>> visitAndItsProc, String accId){
        boolean isCharge;
        if(visitAndItsProc.get(e.Id) != null){
            for(ElixirSuite__Procedure__c eachProc: visitAndItsProc.get(e.Id)){
                if( eachProc.ElixirSuite__Charges__c==null){
                    eachProc.ElixirSuite__Charges__c =0;
                }
                if(eachProc.ElixirSuite__Charges__c==0 && accId != null){
                    //return false; // display message here
                    isCharge = true;
                    e.addError('Before starting a new care episode, kindly ensure that the procedure charges have been added to your previous active care episode');
                    
                }
            }
        }
        return isCharge;
    }
    */
    // Added by Himanshu for  LX3-7644
    public static void removeActiveLocation(List<Visits__c> visits){
        Set<Id> accIds = new Set<Id>();
        Set<Id> accIdWithNoActiveVisit = new Set<Id>();
        List<Account> accToUpdate = new List<Account>();
        for(Visits__c visit : visits){
            accIds.add(visit.ElixirSuite__Account__c);
        }
        List<AggregateResult> activeCareEp = [SELECT Account__c, COUNT(Id) 
                                              FROM Visits__c WHERE Status__c = 'Active' 
                                              AND Account__c IN:accIds 
                                              WITH SECURITY_ENFORCED
                                              GROUP BY Account__c];
        
        if(activeCareEp!=null && activeCareEp.size()>0){
            for (AggregateResult visit : activeCareEp){
                Object idCount = visit.get('expr0');
                Id acc = (Id) visit.get('ElixirSuite__Account__c');
                if(idCount == 0){
                    accIdWithNoActiveVisit.add(acc);
                }
            }
        }
        else{
            accIdWithNoActiveVisit = accIds;
        }
        List<Account> accList = [SELECT Id, Active_Care_Episode_Location__c 
                                 FROM Account 
                                 WHERE Id IN:accIdWithNoActiveVisit
                                 WITH SECURITY_ENFORCED];
        
        for(Account aa : accList){
            aa.Active_Care_Episode_Location__c = null;
            accToUpdate.add(aa);
        }
        StopRecursion.stopLocationUpdation = false;
        //update accToUpdate;
        if(accToUpdate != null && accToUpdate.size() > 0){
            DMLManager.updateAsUser(accToUpdate);
        }
    }
    
    @AuraEnabled
    public static Visits__c deleteRecords(String encounterId ){
        Visits__c c = new Visits__c();
        c=[select id from Visits__c where id=:encounterId WITH SECURITY_ENFORCED];
        if(c!=null){
            DMLManager.deleteAsUser(c); 
        }
        return c;
    }
    
    @AuraEnabled
    
    public static List < String > deleteAllVisit(List < String > lstRecordId) {
        
        // for store Error Messages 
        
        List < String > oErrorMsg = new List < String > (); 
        try{
            // Query Records for delete where id in lstRecordId [which is pass from client side controller]
            
            List < Visits__c > lstDeleteRec = [select Id from Visits__c where id IN: lstRecordId
                                               WITH SECURITY_ENFORCED];
            
            Database.DeleteResult[] drDels = Database.delete(lstDeleteRec, false);
            
            // Iterate through each returned result
            
            for (Database.DeleteResult dr: drDels) {
                
                if (!dr.isSuccess()) {
                    oErrorMsg.add('');
                    
                    for (Database.Error err: dr.getErrors()) {                            
                        oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());     
                    }                         
                } 
                
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return oErrorMsg;
    }
    @AuraEnabled
    public static WrapperForVisit generateAutoNumber(String patientID){
        WrapperForVisit wrpr = new WrapperForVisit();
        try{
            ElixirSuite__Visits__c[] forCount = [SELECT ID,Account__r.Name,Name FROM ElixirSuite__Visits__c 
                                                 WHERE Account__c = : patientID AND Name LIKE '%Visit%' 
                                                 WITH SECURITY_ENFORCED
                                                 order by createdDate desc limit 1];
            
            ElixirSuite__Visits__c[] forCounting = [SELECT ID,Account__r.Name,Name FROM ElixirSuite__Visits__c 
                                                    WHERE Account__c = : patientID AND Name LIKE '%Visit%' 
                                                    WITH SECURITY_ENFORCED
                                                    order by createdDate desc];
            Integer sizeVisitLst = forCounting.size();
            
            
            List<Account> accLst = [SELECT ID,Name from Account where id = : patientID WITH SECURITY_ENFORCED];
            wrpr.accName=getAccName(accLst);
            String tpName;
            if(forCount!=null && forCount.size()>0){
                if(String.isNotBlank(forCount[0].Name)){
                    tpName= getTpValue(forCount, sizeVisitLst);
                    
                }
            }
            else {
                tpName = '0';
            } 
            wrpr.countRecords = Integer.valueOf(tpName)+1;
            
        }catch(Exception e){
            return wrpr;
        }
        return wrpr;
        // ElixirSuite__Visits__c.Name
    }
    public static string getAccName(List<Account> accLst){
        String accName;
        if(accLst.size()>0 && accLst!=null){
            accName = accLst[0].Name;
        }
        return accName;
    }
    public static String getTpValue(ElixirSuite__Visits__c[] forCount, Integer sizeVisitLst){
        String tpName1;
        if(forCount[0].Name.containsIgnoreCase('Visit')){
            if(sizeVisitLst<10){
                tpName1 = forCount[0].Name.right(1); 
            }
            else if(sizeVisitLst>9 && sizeVisitLst<100){
                tpName1 = forCount[0].Name.right(2); 
            }
            else{
                tpName1 = forCount[0].Name.right(3);
            }
        }
        return tpName1;
        
    }
    public class WrapperForVisit{
        @AuraEnabled  public Integer countRecords;
        @AuraEnabled  public String accName; 
    }
    public static void insertChangedLocations(List<Visits__c> visits){
        Map<Id,Id> accountIdToLocation = new Map<Id,Id>();
        for(Visits__c visit :visits){
            if(visit.Status__c!='Closed'){ // Added by Himanshu
                Id accountId = visit.Account__c;
                Id locationId = visit.Care_Episode_Location__c;
                if(accountId!=null && locationId!=null){
                    accountIdToLocation.put(accountId,locationId);
                }
            }
        }
        List<Provider__c> providers = [SELECT Id, Name, Address__c, Provider_First_Name__c, Patient_Provider__c, 
                                       Provider_Code__c, Provider_Last_Name__c, Account__c, Provider_Taxonomy__c, 
                                       Provider_Tax_Id__c, Provider_TaxId_Type__c, Provider_City__c, 
                                       Provider_State__c, Provider_Zip__c, ID_Qualifier__c FROM Provider__c
                                       WHERE Id IN :accountIdToLocation.values() 
                                       WITH SECURITY_ENFORCED
                                       LIMIT 999];
        Map<Id,Provider__c> provs = new Map<Id,Provider__c>(providers);
        
        if(accountIdToLocation!=null && accountIdToLocation.size()>0){//Update Location on Account
            List<Account> accounts = [SELECT Id, Active_Care_Episode_Location__c FROM Account
                                      WHERE Id IN :accountIdToLocation.keySet() WITH SECURITY_ENFORCED];
            for(Account acc :accounts){
                acc.Active_Care_Episode_Location__c = accountIdToLocation.get(acc.Id);
            }
            /*if(accounts!=null &&
Schema.sObjectType.Account.fields.Active_Care_Episode_Location__c.isUpdateable()){
update accounts;
}*/
            if(accounts != null && accounts.size() > 0){
                DMLManager.updateAsUser(accounts);
            }
            
        }
        /*  if(accountIdToLocation!=null && accountIdToLocation.size()>0){//Update Location on Opportunity
List<String> excludingStages = new List<String>{'Referred Out', 'Discharged', 'Closed Lost'};
List<Account> accounts = [SELECT Id, Active_Care_Episode_Location__c,(SELECT Id, Location__c,Location_Text_Id__c FROM Opportunities
WHERE StageName Not IN :excludingStages ORDER By CreatedDate DESC LIMIT 1) FROM Account
WHERE Id IN :accountIdToLocation.keySet() WITH SECURITY_ENFORCED];
List<Opportunity> oppToUpdate = new List<Opportunity>();
for(Account acc :accounts){
Id locationId = accountIdToLocation.get(acc.Id);
List<Opportunity> opportunities = acc.Opportunities;
if(opportunities!=null && opportunities.size()>0){
Opportunity opp = opportunities[0];
opp.Location__c = provs.get(locationId).Name;
opp.Location_Text_Id__c = provs.get(locationId).Id;
oppToUpdate.add(opp);
}
}
if(oppToUpdate!=null &&
Schema.sObjectType.Opportunity.fields.Location__c.isUpdateable() &&
Schema.sObjectType.Opportunity.fields.Location_Text_Id__c.isUpdateable()){
update oppToUpdate;
}
}*/
        Id patientTypeId;
        List<Recordtype> providerType = [SELECT Id, DeveloperName FROM RecordType
                                         WHERE DeveloperName='Patient_Provider' WITH SECURITY_ENFORCED LIMIT 1];
        if(providerType!=null && providerType.size()>0){
            patientTypeId = providerType[0].Id;
        }
        if(patientTypeId == null){
            return;
        }
        List<Provider__c> newProviders = new List<Provider__c>();
        try{
            for(Id accountId :accountIdToLocation.keySet()){
                Id providerId = accountIdToLocation.get(accountId);
                Provider__c providerDetails= provs.get(providerId);
                Provider__c newProv = new Provider__c(
                    RecordtypeId = patientTypeId,
                    Account__c = accountId,
                    Name = providerDetails.Name,
                    Address__c = providerDetails.Address__c,
                    Provider_First_Name__c = providerDetails.Provider_First_Name__c,
                    Provider_Last_Name__c = providerDetails.Provider_Last_Name__c,
                    Provider_Taxonomy__c = providerDetails.Provider_Taxonomy__c,
                    Provider_Code__c = providerDetails.Provider_Code__c,
                    Provider_Tax_Id__c = providerDetails.Provider_Tax_Id__c,
                    Provider_TaxId_Type__c = providerDetails.Provider_TaxId_Type__c,
                    Provider_City__c = providerDetails.Provider_City__c,
                    Provider_State__c = providerDetails.Provider_State__c,
                    Provider_Zip__c = providerDetails.Provider_Zip__c
                );
                newProviders.add(newProv);
            }
            if(newProviders.size()>0 &&
               Schema.sObjectType.Provider__c.fields.RecordtypeId.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Account__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Name.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Address__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_First_Name__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Last_Name__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Taxonomy__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Code__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Tax_Id__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_TaxId_Type__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_City__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_State__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Zip__c.isCreateable()
               && !StopRecursion.isLeadConverted){
                   insert newProviders;
               }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void updateChangedLocations(List<Visits__c> visits){
        Map<Id,Id> providerAccount = new Map<Id,Id>();
        Set<Id> locationIds = new Set<Id>();
        for(Visits__c visit :visits){
            if(visit.Care_Episode_Location__c!=null){
                providerAccount.put(visit.Account__c,visit.Care_Episode_Location__c);
                locationIds.add(visit.Care_Episode_Location__c);
            }
        }
        
        List<Provider__c> providersToDel = [SELECT Id,(SELECT Id,Provider__c,Account__c FROM Providers__r)
                                            FROM Provider__c 
                                            WHERE Id IN :locationIds 
                                            WITH SECURITY_ENFORCED];
        
        Set<Id> providerIds = new Set<Id>();
        for(Provider__c provider:providersToDel){
            List<Provider__c> patientProviders = provider.Providers__r;
            if(patientProviders!=null){
                
                for(Provider__c patientProvider :patientProviders){
                    Id accountId = patientProvider.Account__c;
                    Id locationId = patientProvider.Provider__c;
                    if(providerAccount.containsKey(accountId)){
                        Id providers=getProviderIds(locationId, providerAccount, patientProvider, accountId);
                        
                        providerIds.add(providers);
                        
                    }
                }
            }
        }
        
        
        List<Provider__c> providers = [SELECT Id FROM Provider__c WHERE Id IN :providerIds WITH SECURITY_ENFORCED];
        if(providers!=null && providers.size()>0){
            DMLManager.deleteAsUser(providers);
        }
        
        
        
    }
    public static Id getProviderIds(Id locationId, Map<Id,Id> providerAccount, Provider__c patientProvider, Id accountId){
        Id providers; 
        if(locationId == providerAccount.get(accountId)){
            providers=patientProvider.Id;
        }
        return providers;
        
    }
    public static void checkFormStatusWhenClosed(List<Visits__c> visits){ 
        boolean formStausValue = false;
        
        Set<Id> careEpisodeId = new Set<Id>();
        List<string> formUniqueids = new List<string>();
        for(Visits__c careValue:visits ){
            if(careValue.ElixirSuite__Status__c=='Closed'){
                careEpisodeId.add(careValue.Id);
            }
        }
        
        if(careEpisodeId.size()>0){
            List <ElixirSuite__Form_Value__c> ids = [select ElixirSuite__Form_Id__c from ElixirSuite__Form_Value__c where ElixirSuite__Care_Episode__c IN :careEpisodeId WITH SECURITY_ENFORCED ];
            
            
            for(ElixirSuite__Form_Value__c formstatus : ids){
                formUniqueids.add(formstatus.ElixirSuite__Form_Id__c);
            }
            List<Form_Value__c> values = [SELECT Id,ElixirSuite__Status__c FROM Form_Value__c WHERE ElixirSuite__Form_Detail__c=true and Form_Id__c  IN :formUniqueids WITH SECURITY_ENFORCED];
            
            for(ElixirSuite__Form_Value__c formstatus : values){
                if(formstatus.ElixirSuite__Status__c != 'Completed'){
                    formStausValue = true;
                }
            }
            if(formStausValue==true){
                visits[0].addError('The patient still has some open forms/notes for this care episode. Please complete all forms/notes before closing this care episode');
                
            }
        }
    }
    
    
    public static void checkCareEpisodeStatus(List<Visits__c> visits){
        boolean formStausValue = false;
        boolean careStausValue;
        careStausValue = false;
        //system.debug('visits:'+visits[0].ElixirSuite__Account__c);
        Set<Id> accountid = new Set<Id>();
        Set<Id> careid = new Set<Id>();
        List<string> formUniqueids = new List<string>();
        for (Visits__c accId : visits ){
            accountid.add(accId.ElixirSuite__Account__c);
        }
        
        
        //added by Anmol for LX3-7236
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
        if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
        String careStatus = 'Active';
        
        string querystr = '';
        querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c IN :accountid WITH SECURITY_ENFORCED order by ';
        querystr += careFilter ;
        List<Visits__c> carevalue = database.query(querystr);
        //end by Anmol for LX3-7236
        
        
        for(Visits__c i : carevalue){
            careid.add(i.id);
            /*if(i.Status__c == 'Active'){
careStausValue = true;
}*/
        }
        
        List <ElixirSuite__Form_Value__c> ids = [select ElixirSuite__Form_Id__c from ElixirSuite__Form_Value__c where ElixirSuite__Care_Episode__c IN :careid WITH SECURITY_ENFORCED ];
        
        
        for(ElixirSuite__Form_Value__c formstatus : ids){
            formUniqueids.add(formstatus.ElixirSuite__Form_Id__c);
        }
        List<Form_Value__c> values = [SELECT Id,ElixirSuite__Status__c FROM Form_Value__c WHERE ElixirSuite__Form_Detail__c=true and Form_Id__c  IN :formUniqueids WITH SECURITY_ENFORCED];
        
        for(ElixirSuite__Form_Value__c formstatus : values){
            if(formstatus.ElixirSuite__Status__c != 'Completed'){
                formStausValue = true;
            }
        }
        
        if(formStausValue==true && visits[0].ElixirSuite__Account__c != null){
            visits[0] .addError('The patient still has some open forms/notes from the previous care episode. Please complete all forms/notes from the previous care episode before creating a new care episode');
        }
        
    }   
    public static void checkReopenStaus(List<Visits__c> visits){ 
        boolean formStausValue;
        formStausValue = false;
        string customPermissionName = 'Permission_for_reopening_Care_Episode';
        boolean hasPermission = FeatureManagement.checkPermission(customPermissionName);
        
        for(Visits__c careValue:visits ){
            
            if(careValue.ElixirSuite__Status__c=='Reopened' && hasPermission == false){
                careValue.addError('The User not have required permissions to Reopen the Care episode. Please contact your administrator');
            }
        }
        
    }
    public static void setFlag(List<Visits__c> newVisits, Map<Id,Visits__c> oldVisits){ 
        Set<Id> careid = new Set<Id>();
        List<string> formUniqueids = new List<string>();
        for(Visits__c ids :newVisits){
            if(ids.ElixirSuite__Status__c == 'Reopened' && oldVisits.get(ids.id).ElixirSuite__Status__c == 'Closed'){
                careid.add(ids.id);
            }
        }
        List<Form_Value__c> uniquieids = [Select ElixirSuite__Form_Id__c 
                                          from Form_Value__c 
                                          where ElixirSuite__Care_Episode__c IN : careid
                                          WITH SECURITY_ENFORCED ];
        if(uniquieids.size()>0){
            for(ElixirSuite__Form_Value__c ids : uniquieids){
                formUniqueids.add(ids.ElixirSuite__Form_Id__c);
            }
        }
        List<Form_Value__c> sign = [select id,ElixirSuite__Form_Id__c,ElixirSuite__Approval_Level__c,ElixirSuite__Approved_Signature__c , 
                                    ElixirSuite__Is_old__c,ElixirSuite__Is_Approver__c ,ElixirSuite__Reopened_Date__c
                                    from ElixirSuite__Form_Value__c
                                    where ElixirSuite__Form_Id__c =:formUniqueids and ElixirSuite__Is_Approver__c  = true and Is_old__c = false
                                    WITH SECURITY_ENFORCED];
        
        for(Form_Value__c val :sign){
            
            val.ElixirSuite__Is_old__c = true;
            val.ElixirSuite__Reopened_Date__c = system.now();
        }
        /*if (Schema.sObjectType.Form_Value__c.isUpdateable()){
update sign;
}*/
        DMLManager.updateAsUser(sign);
        
    }
    public static void checkClosedStatus(List<Visits__c> careEpisodesLst){
        
        Set<id> closedVisitsIds = new set<id>();
        List<String> accountIds=new List<String>();
        Boolean approvalValue;
        //select id, Name, ElixirSuite__Account__c, ElixirSuite__Account__r.Name, ElixirSuite__Status__c from ElixirSuite__Visits__c 
        for (ElixirSuite__Visits__c visit : careEpisodesLst) {
            if(visit.ElixirSuite__Status__c == 'Closed'){
                accountIds.add(visit.ElixirSuite__Account__c);
                closedVisitsIds.add(visit.Id);
            }
        }
        
        List<String> eventIdList =  new List<String>();
        List<Event> eventList = [SELECT Id,WhatId,ElixirSuite__Virtual_Meeting_Link__c,
                                 ElixirSuite__Care_Episode__c,
                                 ElixirSuite__Appointment_Type__c,
                                 ElixirSuite__Practitioner__r.Name,
                                 StartDateTime,EndDateTime,Subject,
                                 Owner.FirstName, Owner.LastName 
                                 FROM Event WHERE WhatId IN:accountIds AND  StartDateTime<:system.now()
                                 AND ElixirSuite__Care_Episode__c IN:closedVisitsIds
                                 WITH SECURITY_ENFORCED ORDER BY StartDateTime DESC];
        for(Event ev: eventList){
            eventIdList.add(ev.Id);
        }
        List<ElixirSuite__Form_Value__c> formList = [SELECT Id, Name, ElixirSuite__Account__c,ElixirSuite__Status__c,
                                                     ElixirSuite__Is_Approver__c,ElixirSuite__Form_Id__c,
                                                     ElixirSuite__Form_Name__c, ElixirSuite__Enable_As__c, ElixirSuite__Care_Episode__c 
                                                     FROM ElixirSuite__Form_Value__c 
                                                     WHERE ElixirSuite__Care_Episode__c IN:closedVisitsIds AND ElixirSuite__Enable_As__c='VisitNote'
                                                     WITH SECURITY_ENFORCED];
        List<Map<String,String>> formsDataList = new  List<Map<String,String>>();
        for(ElixirSuite__Form_Value__c formValue : formList){
            Map<String, String> formData = new Map<String, String>();
            
            formData.put('formId', formValue.ElixirSuite__Form_Id__c);
            formData.put('formName', formValue.ElixirSuite__Form_Name__c);
            formsDataList.add(formData);
        }
        // comments are for FormApprovalDecision apex class
        //If obj1List is empty then isDisabled boolean value returns as false it mean approvers are not defined
        //if obj1List is not empty and formValueList is empty then isDisabled boolean value returns as true it mean approvers define but not sign and approved 
        //if obj1List is not empty and formValueList is not empty then it will compare the counts in formValueCountMap(sign & approve) with the counts in objCountMap(Approvers) for each form. If any counts do not match, then isDisabled boolean is true.
        
        approvalValue = FormApprovalDecision.getApprovalAndSignatureData(formsDataList);
        
        ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        if(settings.ElixirSuite__Notification_for_visit_notes__c == true &&
           settings.ElixirSuite__Enable_portal_in_Elixir__c == true && 
           approvalValue == false){
               CommunityNotificationForVisitNotes.visitNotesNotifications(eventIdList);
           }
        
        
    }
    
}