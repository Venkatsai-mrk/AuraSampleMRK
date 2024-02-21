public with sharing class carePlanApprovalApex {
     @AuraEnabled
    public static CarePlanApprovalData.currentUserInfo fetchApprovalLevels(String typeOfApproval, String orderId){ // formId is formUniqueId
        try {
            typeOfApproval = String.escapeSingleQuotes(typeOfApproval);
            String approvalRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();

            // This is configuration data about approvals(level of approvals)
            List<ElixirSuite__Master_Object__c> defaultApprovalLevels = new List<ElixirSuite__Master_Object__c>();
            SObjectAccessDecision decisionNonApproved = Security.stripInaccessible(
                AccessType.READABLE,
                [
                    SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Approver__c, ElixirSuite__Approval_Members__c, ElixirSuite__Approver_Custom_Label__c, ElixirSuite__Approval_Level_For__c
                      FROM ElixirSuite__Master_Object__c
                     WHERE ElixirSuite__Approval_Level__c != null
                       AND ElixirSuite__Approval_Level_For__c = :typeOfApproval
                       AND RecordTypeId = :approvalRecordTypeId
                  ORDER BY ElixirSuite__Approval_Level__c
                ]
            ); 

            defaultApprovalLevels = decisionNonApproved.getRecords();

            List<CareplanSignatureSaveApex.SignAndAprroveData> approvedValues = new List<CareplanSignatureSaveApex.SignAndAprroveData>();
            switch on typeOfApproval {
                when 'Care Plan' {
                    if (String.isNotEmpty(orderId)) {
                        approvedValues = fetchCarePlanApprovedValues(orderId);
                    }
                }

            }

            CarePlanApprovalData.currentUserInfo userInfo = new CarePlanApprovalData.currentUserInfo();
            userInfo.setUserId();
            userInfo.setProfileId(); 
            userInfo.setRoleId();
            userInfo.setDefaultLevels(defaultApprovalLevels);
            userInfo.setApprovedValues(approvedValues);
            
            return userInfo;
        } catch (Exception e) {
            ExceptionLog.logError(e);
            return null;
        }

    }

    @AuraEnabled
    public static List<CareplanSignatureSaveApex.SignAndAprroveData> fetchCarePlanApprovedValues(String parentPrescriptionId){
        try {
            parentPrescriptionId = String.escapeSingleQuotes(parentPrescriptionId);
            List<Treatment_Plan__c> parentPrescription = [
                SELECT Id,
                       ElixirSuite__Signed_Date_1__c, ElixirSuite__Comment_1__c, ElixirSuite__Primary_Therapist__c, ElixirSuite__Primary_Therapist__r.Signature_Attachment_Id__c, ElixirSuite__Primary_Therapist__r.Name, ElixirSuite__Primary_Therapist__r.userrole.name,
                       ElixirSuite__Signed_Date_2__c, ElixirSuite__Comment_2__c, ElixirSuite__Clinical_supervisor__c, ElixirSuite__Clinical_supervisor__r.Signature_Attachment_Id__c, ElixirSuite__Clinical_supervisor__r.Name, ElixirSuite__Clinical_supervisor__r.userrole.name,
                       ElixirSuite__Signed_Date_3__c, ElixirSuite__Comment_3__c, ElixirSuite__User_3__c, ElixirSuite__User_3__r.Signature_Attachment_Id__c, ElixirSuite__User_3__r.Name, ElixirSuite__User_3__r.userrole.name
                  FROM Treatment_Plan__c 
                 WHERE Id = :parentPrescriptionId WITH SECURITY_ENFORCED];

            if (parentPrescription != null && parentPrescription.size() > 0) {
                Treatment_Plan__c thisParentPrescription = parentPrescription[0];

                // query master object for custom label
                String approvalRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('CarePlan_Configuration').getRecordTypeId();
                List<ElixirSuite__Master_Object__c> prescriptionApprovalConfiguration = [
                    SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Approver__c, ElixirSuite__Approval_Members__c, ElixirSuite__Approver_Custom_Label__c, ElixirSuite__Approval_Level_For__c
                      FROM ElixirSuite__Master_Object__c
                     WHERE ElixirSuite__Approval_Level__c != null
                       AND ElixirSuite__Approval_Level_For__c = 'Care Plan'
                       AND RecordTypeId = :approvalRecordTypeId WITH SECURITY_ENFORCED
                ORDER BY ElixirSuite__Approval_Level__c];

                List<CareplanSignatureSaveApex.SignAndAprroveData> allApprovedValues = new List<CareplanSignatureSaveApex.SignAndAprroveData>();
                // Approval level one
                if (thisParentPrescription.ElixirSuite__Signed_Date_1__c != null && thisParentPrescription.ElixirSuite__Primary_Therapist__c != null) {
                    CareplanSignatureSaveApex.SignAndAprroveData approvalLevelOne = new CareplanSignatureSaveApex.SignAndAprroveData();
                    approvalLevelOne.approvalLevel = 1;
                    approvalLevelOne.comments = thisParentPrescription.ElixirSuite__Comment_1__c;
                    // As prescriptionApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    approvalLevelOne.customLabel = prescriptionApprovalConfiguration[0].ElixirSuite__Approver_Custom_Label__c;
                    approvalLevelOne.dateOfApproval = thisParentPrescription.ElixirSuite__Signed_Date_1__c;
                    
                    String signature = thisParentPrescription.ElixirSuite__Primary_Therapist__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images1 = [SELECT Id FROM ContentDocument WHERE Id= :signature];
                        if (images1 != null && images1.size() > 0) {
                            approvalLevelOne.signatureContentDocumentId = images1[0].Id;
                        }
                    }

                    approvalLevelOne.userId = thisParentPrescription.ElixirSuite__Primary_Therapist__c;
                    approvalLevelOne.userName = thisParentPrescription.ElixirSuite__Primary_Therapist__r.Name;
                    approvalLevelOne.userRole = thisParentPrescription.ElixirSuite__Primary_Therapist__r.userrole.name;

                    allApprovedValues.add(approvalLevelOne);
                }

                // Approval level two
                if (thisParentPrescription.ElixirSuite__Signed_Date_2__c != null && thisParentPrescription.ElixirSuite__Clinical_supervisor__c != null) {
                    CareplanSignatureSaveApex.SignAndAprroveData approvalLevelTwo = new CareplanSignatureSaveApex.SignAndAprroveData();
                    approvalLevelTwo.approvalLevel = 2;
                    approvalLevelTwo.comments = thisParentPrescription.ElixirSuite__Comment_2__c;
                    // As prescriptionApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    approvalLevelTwo.customLabel = prescriptionApprovalConfiguration[1].ElixirSuite__Approver_Custom_Label__c;
                    approvalLevelTwo.dateOfApproval = thisParentPrescription.ElixirSuite__Signed_Date_2__c;
                    
                    String signature = thisParentPrescription.ElixirSuite__Clinical_supervisor__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images2 = [SELECT Id FROM ContentDocument WHERE Id= :signature];
                        if (images2 != null && images2.size() > 0) {
                            approvalLevelTwo.signatureContentDocumentId = images2[0].Id;
                        }
                    }

                    approvalLevelTwo.userId = thisParentPrescription.ElixirSuite__Clinical_supervisor__c;
                    approvalLevelTwo.userName = thisParentPrescription.ElixirSuite__Clinical_supervisor__r.Name;
                    approvalLevelTwo.userRole = thisParentPrescription.ElixirSuite__Clinical_supervisor__r.userrole.name;

                    allApprovedValues.add(approvalLevelTwo);
                }

                // Approval level three
                if (thisParentPrescription.ElixirSuite__Signed_Date_3__c != null && thisParentPrescription.ElixirSuite__User_3__c != null) {
                    CareplanSignatureSaveApex.SignAndAprroveData approvalLevelThree = new CareplanSignatureSaveApex.SignAndAprroveData();
                    approvalLevelThree.approvalLevel = 3;
                    approvalLevelThree.comments = thisParentPrescription.ElixirSuite__Comment_3__c;
                    // As prescriptionApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    approvalLevelThree.customLabel = prescriptionApprovalConfiguration[2].ElixirSuite__Approver_Custom_Label__c;
                    approvalLevelThree.dateOfApproval = thisParentPrescription.ElixirSuite__Signed_Date_3__c;
                    
                    String signature = thisParentPrescription.ElixirSuite__User_3__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images3 = [SELECT Id FROM ContentDocument WHERE Id= :signature];
                        if (images3 != null && images3.size() > 0) {
                            approvalLevelThree.signatureContentDocumentId = images3[0].Id;
                        }
                    }

                    approvalLevelThree.userId = thisParentPrescription.ElixirSuite__User_3__c;
                    approvalLevelThree.userName = thisParentPrescription.ElixirSuite__User_3__r.Name;
                    approvalLevelThree.userRole = thisParentPrescription.ElixirSuite__User_3__r.userrole.name;

                    allApprovedValues.add(approvalLevelThree);
                }

                return allApprovedValues;
            }
            else {
                throw new AuraHandledException('No parent prescription found with given Id');
            }
        } catch (Exception e) {
            ExceptionLog.logError(e);
             return null;
        }
    }     
}