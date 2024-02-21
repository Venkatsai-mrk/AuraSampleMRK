/**@author: Srihari G K
 * Last modified on: 16-2-2023
 * Test class:labAndOtherTestResultsControllerTest
 */
public with sharing class filePreviewAndDownloadController {
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink 
                                           WHERE LinkedEntityId = :recordId WITH SECURITY_ENFORCED];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                     FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND Title LIKE 'Lab_Result__%' WITH SECURITY_ENFORCED
                                     ORDER BY LastModifiedDate DESC];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }
}