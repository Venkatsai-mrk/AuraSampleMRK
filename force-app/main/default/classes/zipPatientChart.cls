/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-16-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class zipPatientChart implements Queueable, Database.AllowsCallouts{
    public Map<String, String> sObjMap = new Map<String, String>();
    public String accId = '';
    public Set<Id> fileIds = new Set<Id>();
    public String careId = '';
    public String otherAttributes = '';
    public Set<String> allEpisodeIds = new Set<String>();
    public String formsCategoryBundle = '';
    public Set<Id> zipIds = new Set<Id>();

    public zipPatientChart(
        Map<String, String> sObjMap,
        String accId,
        Set<Id> fileIds,
        String careId,
        String otherAttributes,
        Set<String> allEpisodeIds,
        String formsCategoryBundle,
        Set<Id> zipIds) {
            
            this.sObjMap = sObjMap;
            this.accId = accId;
            this.fileIds = fileIds;
            this.careId = careId;
            this.otherAttributes = otherAttributes;
            this.allEpisodeIds = allEpisodeIds;
            this.formsCategoryBundle = formsCategoryBundle;
            this.zipIds = zipIds;
    }

    public void execute(QueueableContext context){
        PageReference pdf = Page.PatientChartPdfNew;
        pdf.getParameters().put('caseId',careId);
        pdf.getParameters().put('cat',otherAttributes);
        Blob body;                 
        ContentVersion cont = new ContentVersion();
        cont.Title = 'Chart.pdf';
        cont.PathOnClient = 'Chart.pdf';
        if(!Test.isRunningTest()){
        cont.VersionData = pdf.getContentAsPdf();
        }
        cont.Origin = 'H';
        try{
       // if (Schema.sObjectType.ContentVersion.fields.Title.isCreateable() && 
            //Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() && 
           // Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable() && 
           // Schema.sObjectType.ContentVersion.fields.Origin.isCreateable() ) {
                //insert cont;
                DMLManager.insertAsUser(cont);
           // }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        fileIds.add(cont.Id);
        //system.debug('fileIds '+fileIds);
        String docName = 'PatientChart.zip'; // Document's name
        Zippex sampleZip = new Zippex();
        List<ContentVersion> contents = [SELECT Id, ContentUrl, ContentBodyId, VersionData, Title, FileType FROM ContentVersion
                                         WHERE Id IN :fileIds];
        Map<String,Integer> duplicateTitles = new Map<String,Integer>();
        for(ContentVersion content :contents){
            if(duplicateTitles.containsKey(content.Title)){
                duplicateTitles.put(content.Title,1);
            }else{
                duplicateTitles.put(content.Title,0);
            }
        }  
        String escapedFileName = '';
        for(ContentVersion file : contents) {
            escapedFileName = file.Title.replace('/', '_');
            escapedFileName = escapedFileName.replace('\\', '_');

            Integer count = duplicateTitles.get(file.Title);
            if( count!=0 ){
                sampleZip.addFile(escapedFileName + '(' + count + ')' + '.' + file.FileType.toLowerCase(), file.VersionData , null);
                duplicateTitles.put(file.Title,++count);
            }else{
                if (escapedFileName.endsWith('.pdf')) {
                    sampleZip.addFile(escapedFileName, file.VersionData , null);
                }
                else {
                    sampleZip.addFile(escapedFileName + '.' + file.FileType.toLowerCase(), file.VersionData , null);
                }
            }
        }
        try{
            //SELECT Id, Name, ElixirSuite__Account__c FROM ElixirSuite__Visits__c WHERE Id = 'a1hN0000002bhckIAA'
            List<Visits__c> currentVisit = [SELECT Id, Name, ElixirSuite__Account__c FROM ElixirSuite__Visits__c WHERE Id = :careId];
            String fileName = 'Patient Chart';
            if (currentVisit != null && currentVisit.size() > 0) {
                fileName = currentVisit[0].Name + '_Patient Chart';
            }
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName + '.zip';
            cv.VersionData = sampleZip.getZipArchive(); 
            cv.IsMajorVersion = true;
           // if (Schema.sObjectType.ContentVersion.fields.Title.isCreateable() && 
                //Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() && 
                //Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable() && 
                //Schema.sObjectType.ContentVersion.fields.IsMajorVersion.isCreateable() ) {
                  //  Insert cv;
                    DMLManager.insertAsUser(cv);
                //}
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId; 
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = careId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            
          //  if (Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable() && 
               // Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable() && 
              //  Schema.sObjectType.ContentDocumentLink.fields.shareType.isCreateable() 
              // ) {
                  // Insert cdl;
                   DMLManager.insertAsUser(cdl);
             //  }
            
            Set<Id> docIds = new Set<Id>();
            List<ContentVersion> versionsToDel = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :fileIds];
            for(ContentVersion file :versionsToDel){
                docIds.add(file.ContentDocumentId);
            }
            List<ContentDocument> contentsToDel = [SELECT Id FROM ContentDocument WHERE Id IN :docIds WITH SECURITY_ENFORCED];
            //if(Schema.sObjectType.ContentDocument.isDeletable()){
           // delete contentsToDel;
            DMLManager.deleteAsUser(contentsToDel);
           // }
            
            // remove the care episode we just handled
            allEpisodeIds.remove(careId);
            // add the zip id for handled care episode
            zipIds.add(cv.id);

            if (allEpisodeIds.size() > 0) {
                // call PatientChartController.getFormsDataForPDF with next care episode id
                // getFormsDataForPDF(Id accId,String formsCategoryBundle, Id episodeId, String otherAttributes, Set<String> allEpisodeIds)
                String nextCareEpisodeId = new List<String>(allEpisodeIds)[0];
                // if called 5 times, 
                if (Math.mod(zipIds.size(),5) != 0) {
                    PatientChartController.getFormsDataForPDF((Id) accId, formsCategoryBundle, (Id) nextCareEpisodeId, otherAttributes, allEpisodeIds, zipIds);
                }
                else {
                    futurePatientChartCaller((Id) accId, formsCategoryBundle, (Id) nextCareEpisodeId, otherAttributes, allEpisodeIds, zipIds);
                }
            }
            else if (allEpisodeIds.size() == 0) {
                // ZipTheFollowing.start('Combined_Patient_Chart', zipIds, (Id) accId, false);
                ZipTheFollowing.start('Combined_Patient_Chart', zipIds, (Id) accId, false);
            }
            
        } catch ( Exception ex ) {
            //System.debug('>>> ERROR ' + ex);
        }
    }

    @future 
    public static void futurePatientChartCaller(Id accId,String formsCategoryBundle, Id nextCareEpisodeId, String otherAttributes, Set<String> allEpisodeIds, Set<Id> zipIds){
        PatientChartController.getFormsDataForPDF(accId, formsCategoryBundle, nextCareEpisodeId, otherAttributes, allEpisodeIds, zipIds);
    }
}