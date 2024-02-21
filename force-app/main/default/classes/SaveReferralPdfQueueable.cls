/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SaveReferralPdfQueueable  implements Queueable , Database.AllowsCallouts{
    public Map<String, String> sObjMap = new Map<String, String>();  
    public String accId;
    public Integer counter;
    public Set<Id> fileIds = new Set<Id>();
    public String careId;
    public String otherAttributes;
    public String parentReferralId;
    public SaveReferralPdfQueueable(Map<String, String> sObjMap, String accId, Integer counter, Set<Id> fileIds, 
                                    String careId, String otherAttributes,String parentReferralId){
                                        this.sObjMap = sObjMap;
                                        this.accId = accId;
                                        this.counter = counter;
                                        this.fileIds = fileIds;
                                        this.careId = careId;
                                        this.otherAttributes = otherAttributes;
                                        this.parentReferralId = parentReferralId;
                                    }                    
    public void execute(QueueableContext context) {
        try{
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
        //Insert form pdf pdf
        
        
        PageReference pdf = Page.Elixir_FormsPdfGenerator;
        pdf.getParameters().put('fName',fName);
        pdf.getParameters().put('aId',accId);
        pdf.getParameters().put('fId',formUniqueID);
        pdf.getParameters().put('fCName',fCName);
        Blob body;                 
        Attachment attach = new Attachment();
        Blob b ;
          if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        } else {
            b = PDf.getContentAsPDF();
        }        

     
        attach.Body = b;
        attach.Name = fName+'.pdf';
        attach.IsPrivate = false;
        attach.ParentId = parentReferralId;
      
        //insert attach;
        DMLManager.insertAsUser(attach);
        
        fileIds.add(attach.Id);
        system.debug('sObjMap'+sObjMap);
        if(sObjMap.keySet().size()>0){
            if(Math.mod(++counter,5) != 0){
                system.debug('LINE NO 70');
                System.enqueueJob(new SaveReferralPdfQueueable(sObjMap, accId, ++counter, fileIds, careId, otherAttributes,parentReferralId));
            }else{
                system.debug('LINE NO 73');
                SaveReferralPdfFuture(sObjMap, accId, fileIds, careId, otherAttributes,parentReferralId);
            }
        }else{
            system.debug('LINE NO 77');
                ElixirOEM_ReferralUtility.sendReferralFormAsAttachmentOnEmail(fileIds,parentReferralId);
               
        }
        
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }     
    }
    @future 
    public static void SaveReferralPdfFuture(Map<String, String> sObjMap, String accId, Set<Id> fileIds, String careId, String otherAttributes,
                                             String parentReferralId){
                                                 System.enqueueJob(new SaveReferralPdfQueueable(sObjMap, accId, 1, fileIds, careId, otherAttributes,parentReferralId));
                                             }
}