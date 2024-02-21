public with sharing class LabOrderOnForms {
    public class LabOrder {
        @AuraEnabled public String labOrderSerial;
        @AuraEnabled public String labName;
        @AuraEnabled public String id;
        @AuraEnabled public String testName;
        @AuraEnabled public String status;
        @AuraEnabled public String labOrderType;
        @AuraEnabled public Boolean noLabOrderResultAvailable;
        @AuraEnabled public String linkToLabOrderResult;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String createdBy;
        @AuraEnabled public Datetime lastModifiedDate;
        public LabOrder(
            String labOrderSerial,
            String labName,
            String id,
            String testName,
            String status,
            String labOrderType,
            String linkToLabOrderResult,
            Datetime createdDate,
            String createdBy,
            Datetime lastModifiedDate) {

                this.labOrderSerial = labOrderSerial;
                this.labName = labName;
                this.id = id;
                this.testName = testName;
                this.status = status;
                this.labOrderType = labOrderType;
                this.linkToLabOrderResult = linkToLabOrderResult;
                
                if (String.isEmpty(linkToLabOrderResult)) {
                    this.noLabOrderResultAvailable = true;
                }
                else {
                    this.noLabOrderResultAvailable = false;
                }

                this.createdDate = createdDate;
                this.createdBy = createdBy;
                this.lastModifiedDate = lastModifiedDate;
        }
    }

    @AuraEnabled
public static List<LabOrder> fetchLabOrders(String accountId) {
    try {
        String activeCareEpisodeId = getActiveCareEpisodeId(accountId);
        Boolean careEpisodeBasedFilter = getCustomSettingBooleanValue();
        String labOrderPriority = getLabOrderPriority();
        List<LabOrder> labOrders = new List<LabOrder>();

        List<ElixirSuite__Lab_Order__c> eLabOrders = fetchELabOrders(accountId, activeCareEpisodeId, careEpisodeBasedFilter);
        Set<Id> elabOrderIds = new Map<Id, ElixirSuite__Lab_Order__c>(eLabOrders).keySet();

        List<Attachment> allAttachments = [
            SELECT Id, ParentId
            FROM Attachment
            WHERE ParentId IN :elabOrderIds AND Name = 'PdfReport.pdf'
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];

        Map<Id, Id> eLabOrderToAttchmentIdMap = new Map<Id, Id>();
        Map<Id, String> labOrderToContentDocumentIdMap = new Map<Id, String>();
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
         links = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :elabOrderIds
            ORDER BY ContentDocument.CreatedDate DESC Limit 1
        ];

        for (ContentDocumentLink link : links) {
            labOrderToContentDocumentIdMap.put(link.LinkedEntityId, link.ContentDocumentId);
        }

        for (Attachment i : allAttachments) {
            if (!eLabOrderToAttchmentIdMap.containsKey(i.ParentId)) {
                eLabOrderToAttchmentIdMap.put(i.ParentId, i.Id);
            }
        }

        for (ElixirSuite__Lab_Order__c i : eLabOrders) {
            String linkToLabOrderResult = '';

            if (i.ElixirSuite__Lab_Type__c == 'Manual' && labOrderToContentDocumentIdMap.containsKey(i.Id)) {
                linkToLabOrderResult = '/sfc/servlet.shepherd/document/download/' + labOrderToContentDocumentIdMap.get(i.Id);
            } else if (i.ElixirSuite__Lab_Type__c == 'eLab' && eLabOrderToAttchmentIdMap.containsKey(i.Id)) {
                linkToLabOrderResult = '/servlet/servlet.FileDownload?file=' + eLabOrderToAttchmentIdMap.get(i.Id);
            }

            labOrders.add(new LabOrder(
                i.ElixirSuite__Lab_Order_Req__c,
                i.ElixirSuite__LabName__c,
                i.Id,
                i.ElixirSuite__Test_Name__c,
                i.ElixirSuite__Status__c,
                i.ElixirSuite__Lab_Type__c,
                linkToLabOrderResult,
                i.CreatedDate,
                i.CreatedBy.Name,
                i.LastModifiedDate
            ));
        }

        return labOrders;

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}





    @AuraEnabled
    public static List<ElixirSuite__Lab_Order__c> fetchELabOrders(String accountId, String activeCareEpisodeId, Boolean careEpisodeSettingFilter){
        try {
            if (String.isNotBlank(activeCareEpisodeId) && careEpisodeSettingFilter == true) {
                // If this custom setting is turned on in the customer org, user will be able to view a filtered data
                return [
                    SELECT
                        Id, ElixirSuite__Lab_Order_Req__c,ElixirSuite__Lab_Type__c,ElixirSuite__LabName__c, ElixirSuite__Test_Name__c, toLabel(ElixirSuite__Status__c), CreatedDate, CreatedBy.Name, LastModifiedDate,
                        (
                            SELECT
                                Id
                            FROM
                                ElixirSuite__LabOrder_HL7_Results__r
                        )
                    FROM
                        ElixirSuite__Lab_Order__c
                    WHERE
                        ElixirSuite__Account_Id__c = :accountId
                    AND
                        ElixirSuite__Care_Episode__c = :activeCareEpisodeId
                    WITH
                        SECURITY_ENFORCED
                    ORDER BY
                        CreatedDate DESC
                    
                ];

                
            }
            else {
                
                // If this custom setting is turned off in the customer org, user will be able to view all the data 
                return [
                    SELECT
                        Id, ElixirSuite__Lab_Order_Req__c,ElixirSuite__Lab_Type__c,ElixirSuite__LabName__c, ElixirSuite__Test_Name__c, toLabel(ElixirSuite__Status__c), CreatedDate, CreatedBy.Name, LastModifiedDate
                    FROM
                        ElixirSuite__Lab_Order__c
                    WHERE
                        ElixirSuite__Account_Id__c = :accountId
                    WITH
                        SECURITY_ENFORCED
                    ORDER BY
                        CreatedDate DESC
                    
                ];
            }

        } catch (Exception e) {
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ElixirSuite__UA_Sample_Details__c> fetchManualLabOrders(String accountId, String activeCareEpisodeId, Boolean careEpisodeFilter){
        try {
            if (careEpisodeFilter == false) {
                // If this custom setting is turned off in the customer org, user will be able to view all the data 
                
                return [
                    SELECT
                        Id, Name, ElixirSuite__Medical_Test__c, ElixirSuite__Status__c, CreatedDate, CreatedBy.Name, LastModifiedDate
                    FROM
                        ElixirSuite__UA_Sample_Details__c
                    WHERE
                        ElixirSuite__Account__c = :accountId
                    WITH
                        SECURITY_ENFORCED
                    ORDER BY
                        CreatedDate DESC
                    LIMIT 50
                ];
            }
            else {
                // If this custom setting is turned on in the customer org, user will be able to view a filtered data
                return [
                    SELECT
                        Id, Name, ElixirSuite__Medical_Test__c, ElixirSuite__Status__c, CreatedDate, CreatedBy.Name, LastModifiedDate
                    FROM
                        ElixirSuite__UA_Sample_Details__c
                    WHERE
                        ElixirSuite__Account__c = :accountId
                    AND
                        ElixirSuite__Care_Episode__c = :activeCareEpisodeId
                    WITH
                        SECURITY_ENFORCED
                    ORDER BY
                        CreatedDate DESC
                    LIMIT 50
                ];
            }

        } catch (Exception e) {
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getActiveCareEpisodeId(String accountId) {
        try {
            List<ElixirSuite__Visits__c> allCareEpisodes = [
                SELECT
                    Id
                FROM
                    ElixirSuite__Visits__c
                WHERE
                    ElixirSuite__Account__c = :accountId
                AND
                    ElixirSuite__Status__c = 'Active'
                WITH 
                    SECURITY_ENFORCED
                ORDER BY
                    CreatedDate DESC
                LIMIT 1];
        
            if (allCareEpisodes != null && allCareEpisodes.size() > 0) {
                return allCareEpisodes[0].Id;
            }

            return '';   
        } catch (Exception e) {
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getLabOrderPriority(){
        try {
            ID uid =UserInfo.getProfileId();
            List<ElixirSuite__TabPermissionBasedOnProfiles__c> tb = [
                SELECT
                    Id, ElixirSuite__LabOrder_Priority__c 
                FROM
                    ElixirSuite__TabPermissionBasedOnProfiles__c
                WHERE
                    SetupOwnerId = :uid
                WITH
                    SECURITY_ENFORCED
                LIMIT 1
            ];

            if(tb!=null && tb.size()>0){
                return tb[0].ElixirSuite__LabOrder_Priority__c;
            }
            
            throw new AuraHandledException('Failed to get lab order priority');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    @AuraEnabled
    public static Boolean getCustomSettingBooleanValue() {
    try {
        ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        
        if (customSetting.ElixirSuite__Care_Episode_based_filtering_for_Notes__c) {
            return customSetting.ElixirSuite__Care_Episode_based_filtering_for_Notes__c;
        } else {
            return false; // Default value if custom setting instance is not found
        }
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

    
}