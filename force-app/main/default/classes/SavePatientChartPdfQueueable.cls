public with sharing class SavePatientChartPdfQueueable implements Queueable , Database.AllowsCallouts{
    public Map<String, String> sObjMap = new Map<String, String>();  
    public String accId;
        public Integer counter;
    public Set<Id> fileIds = new Set<Id>();
    public String careId;
    public String otherAttributes;
    public Set<String> allEpisodeIds;
    public String formsCategoryBundle;
    public Set<Id> zipIds;
    
    public SavePatientChartPdfQueueable(Map<String, String> sObjMap, String accId, Integer counter, Set<Id> fileIds, 
                                        String careId, String otherAttributes, Set<String> allEpisodeIds, String formsCategoryBundle, Set<Id> zipIds){
        this.sObjMap = sObjMap;
        this.accId = accId;
        this.counter = counter;
        this.fileIds = fileIds;
        this.careId = careId;
        this.otherAttributes = otherAttributes;
        this.allEpisodeIds = allEpisodeIds;
        this.formsCategoryBundle = formsCategoryBundle;
        this.zipIds = zipIds;
        
    }                    
    public void execute(QueueableContext context) {
        Set<String> keys = sObjMap.keySet();
        List<String> keyInOrder = new List<String>(keys);
        String keyAtTop = keyInOrder[0];
        String formValues = sObjMap.get(keyAtTop);
        sObjMap.remove(keyAtTop);//Removing evaluated key
        List<String> formAttributes = formValues.split('&');
        String formUniqueID = keyAtTop;
        String fName = formAttributes[1];
        String fCName = formAttributes[2]; 
        system.debug('File Ids '+fileIds);
        //Save pdf
        PageReference pdf = Page.Elixir_FormsPdfGenerator;
        pdf.getParameters().put('fName',fName);
        pdf.getParameters().put('aId',accId);
        pdf.getParameters().put('fId',formUniqueID);
        pdf.getParameters().put('fCName',fCName);
        Blob body;                 
        ContentVersion cont = new ContentVersion();
        cont.Title = fName;
        cont.PathOnClient = fName + '.pdf';
        cont.VersionData = pdf.getContentAsPdf();
        cont.Origin = 'H';
         if(Schema.sObjectType.ContentVersion.isCreateable() && 
            Schema.sObjectType.ContentVersion.fields.Title.isCreateable() && 
               Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() && 
               Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable() && 
               Schema.sObjectType.ContentVersion.fields.Origin.isCreateable() ) {
        insert cont;
        }
        fileIds.add(cont.Id);
        if(sObjMap.keySet().size()>0){
            if(Math.mod(++counter,4) != 0 || Math.mod(++counter,5) != 0){
                SavePatientChartPdfFuture(sObjMap, accId, fileIds, careId, otherAttributes, allEpisodeIds, formsCategoryBundle, zipIds);
            }else{
                SavePatientChartPdfFuture(sObjMap, accId, fileIds, careId, otherAttributes, allEpisodeIds, formsCategoryBundle, zipIds);
            }
        }else{
            // zipPatientChart.startZip(sObjMap, accId, fileIds, careId, otherAttributes, allEpisodeIds, formsCategoryBundle);
            fututeZipPatientCaller(sObjMap, accId, fileIds, careId, otherAttributes, allEpisodeIds, formsCategoryBundle, zipIds);
        }
        //fName : fName  accId : accId  formuniqueID : formUniqueID
    }
    @future 
    public static void SavePatientChartPdfFuture(Map<String, String> sObjMap, String accId, Set<Id> fileIds, String careId, String otherAttributes, Set<String> allEpisodeIds, String formsCategoryBundle, Set<Id> zipIds){
        System.enqueueJob(new SavePatientChartPdfQueueable(sObjMap, accId, 1, fileIds, careId, otherAttributes, allEpisodeIds, formsCategoryBundle, zipIds));
    }

    @future  
    public static void fututeZipPatientCaller(
        Map<String, String> sObjMap,
        String accId,
        Set<Id> fileIds,
        String careId,
        String otherAttributes,
        Set<String> allEpisodeIds,
        String formsCategoryBundle,
        Set<Id> zipIds) {
            System.enqueueJob(new zipPatientChart(sObjMap, accId, fileIds, careId, otherAttributes, allEpisodeIds, formsCategoryBundle, zipIds));
    }
}