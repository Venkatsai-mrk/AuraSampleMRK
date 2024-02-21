public with sharing class OrderApproval {
    @AuraEnabled
    public static OrderApprovalData.currentUserInfo fetchApprovalLevels(String typeOfApproval, String orderId){ // formId is formUniqueId
        try {
            typeOfApproval = String.escapeSingleQuotes(typeOfApproval);
            String approvalRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();

            // This is configuration data about approvals(level of approvals)
            List<ElixirSuite__Master_Object__c> defaultApprovalLevels = new List<ElixirSuite__Master_Object__c>();
            SObjectAccessDecision decisionNonApproved = Security.stripInaccessible(
                AccessType.READABLE,
                [
                    //     SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c, ElixirSuite__Approver_Custom_Label__c
                    //       FROM Object_1_css__c
                    //      WHERE Form__c = :recordTypeName
                    //        AND Approval_Level__c!=NULL
                    //   ORDER BY Approval_Level__c
                    SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Approver__c, ElixirSuite__Approval_Members__c, ElixirSuite__Approver_Custom_Label__c, ElixirSuite__Approval_Level_For__c
                      FROM ElixirSuite__Master_Object__c
                     WHERE ElixirSuite__Approval_Level__c != null
                       AND ElixirSuite__Approval_Level_For__c = :typeOfApproval
                       AND RecordTypeId = :approvalRecordTypeId
                  ORDER BY ElixirSuite__Approval_Level__c
                ]
            ); //TODO: remove hard coded Ids. They are only for testing purpose

            defaultApprovalLevels = decisionNonApproved.getRecords();

            // in new no approved values
            // List<ElixirSuite__Prescription_Order__c> approvedValues = new List<ElixirSuite__Prescription_Order__c>();
            // SObjectAccessDecision decisionApproved = Security.stripInaccessible(AccessType.READABLE,
            // // [SELECT Id, Account__c, Is_Approver__c, Date_Of_Approval__c,Is_External_Signature__c,
            // // User__r.Name, User__r.UserRole.Name, Approval_Level__c, Comment__c, Is_old__c, Form_Name__c, Approved_Signature__c,
            // // Signed_Patient__r.Name FROM Form_Value__c
            // // WHERE Is_Approver__c=true AND Form_Id__c= :formId AND Is_old__c != true
            // // ORDER BY Approval_Level__c]
            // [SELECT Id, Name FROM ElixirSuite__Prescription_Order__c WHERE Name='ObiviouslyFakeName12']
            // );
            // approvedValues = decisionApproved.getRecords();
            // system.debug('approvedValues'+approvedValues);


            // FormApprovalData.currentUserInfo userInfo = new FormApprovalData.currentUserInfo();
            // userInfo.setUserId();
            // userInfo.setProfileId(); 
            // userInfo.setRoleId();
            // userInfo.setDefaultLevels(defaultApprovalLevels);
            // userInfo.setApprovedValues(approvedValues);

            List<OrderSignatureSave.SignAndAprroveData> approvedValues = new List<OrderSignatureSave.SignAndAprroveData>();
            switch on typeOfApproval {
                when 'Prescription Order' {
                    if (String.isNotEmpty(orderId)) {
                        approvedValues = fetchPrescriptionApprovedValues(orderId);
                    }
                }

                when 'Lab Order' {
                    if (String.isNotEmpty(orderId)) {
                        approvedValues = fetchLabOrderApprovedValues(orderId);
                    }
                }
            }

            OrderApprovalData.currentUserInfo userInfo = new OrderApprovalData.currentUserInfo();
            userInfo.setUserId();
            userInfo.setProfileId(); 
            userInfo.setRoleId();
            userInfo.setDefaultLevels(defaultApprovalLevels);
            userInfo.setApprovedValues(approvedValues);

            system.debug('userInfo'+userInfo);
            
            return userInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static List<OrderSignatureSave.SignAndAprroveData> fetchPrescriptionApprovedValues(String parentPrescriptionId){
        try {
            parentPrescriptionId = String.escapeSingleQuotes(parentPrescriptionId);
            List<ElixirSuite__Prescription_Order__c> parentPrescription = [
                SELECT Id,
                       ElixirSuite__Date_Of_Approval_1__c, ElixirSuite__Comment_1__c, ElixirSuite__User_1__c, ElixirSuite__User_1__r.Signature_Attachment_Id__c, ElixirSuite__User_1__r.Name, ElixirSuite__User_1__r.userrole.name,
                       ElixirSuite__Date_Of_Approval_2__c, ElixirSuite__Comment_2__c, ElixirSuite__User_2__c, ElixirSuite__User_2__r.Signature_Attachment_Id__c, ElixirSuite__User_2__r.Name, ElixirSuite__User_2__r.userrole.name,
                       ElixirSuite__Date_Of_Approval_3__c, ElixirSuite__Comment_3__c, ElixirSuite__User_3__c, ElixirSuite__User_3__r.Signature_Attachment_Id__c, ElixirSuite__User_3__r.Name, ElixirSuite__User_3__r.userrole.name
                  FROM ElixirSuite__Prescription_Order__c 
                 WHERE Id = :parentPrescriptionId WITH SECURITY_ENFORCED];

            if (parentPrescription != null && parentPrescription.size() > 0) {
                ElixirSuite__Prescription_Order__c thisParentPrescription = parentPrescription[0];

                // query master object for custom label
                String approvalRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
                List<ElixirSuite__Master_Object__c> prescriptionApprovalConfiguration = [
                    SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Approver__c, ElixirSuite__Approval_Members__c, ElixirSuite__Approver_Custom_Label__c, ElixirSuite__Approval_Level_For__c
                      FROM ElixirSuite__Master_Object__c
                     WHERE ElixirSuite__Approval_Level__c != null
                       AND ElixirSuite__Approval_Level_For__c = 'Prescription Order'
                       AND RecordTypeId = :approvalRecordTypeId WITH SECURITY_ENFORCED
                ORDER BY ElixirSuite__Approval_Level__c];

                List<OrderSignatureSave.SignAndAprroveData> allApprovedValues = new List<OrderSignatureSave.SignAndAprroveData>();
                // Approval level one
                if (thisParentPrescription.ElixirSuite__Date_Of_Approval_1__c != null && thisParentPrescription.ElixirSuite__User_1__c != null) {
                    OrderSignatureSave.SignAndAprroveData ApprovalLevelOne = new OrderSignatureSave.SignAndAprroveData();
                    ApprovalLevelOne.approvalLevel = 1;
                    ApprovalLevelOne.comments = thisParentPrescription.ElixirSuite__Comment_1__c;
                    // As prescriptionApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    ApprovalLevelOne.customLabel = prescriptionApprovalConfiguration[0].ElixirSuite__Approver_Custom_Label__c;
                    ApprovalLevelOne.dateOfApproval = thisParentPrescription.ElixirSuite__Date_Of_Approval_1__c;
                    
                    String signature = thisParentPrescription.ElixirSuite__User_1__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images1 = [SELECT Id FROM ContentDocument WHERE Id= :signature];
                        if (images1 != null && images1.size() > 0) {
                            ApprovalLevelOne.signatureContentDocumentId = images1[0].Id;
                        }
                    }

                    ApprovalLevelOne.userId = thisParentPrescription.ElixirSuite__User_1__c;
                    ApprovalLevelOne.userName = thisParentPrescription.ElixirSuite__User_1__r.Name;
                    ApprovalLevelOne.userRole = thisParentPrescription.ElixirSuite__User_1__r.userrole.name;

                    allApprovedValues.add(ApprovalLevelOne);
                }

                // Approval level two
                if (thisParentPrescription.ElixirSuite__Date_Of_Approval_2__c != null && thisParentPrescription.ElixirSuite__User_2__c != null) {
                    OrderSignatureSave.SignAndAprroveData ApprovalLevelTwo = new OrderSignatureSave.SignAndAprroveData();
                    ApprovalLevelTwo.approvalLevel = 2;
                    ApprovalLevelTwo.comments = thisParentPrescription.ElixirSuite__Comment_2__c;
                    // As prescriptionApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    ApprovalLevelTwo.customLabel = prescriptionApprovalConfiguration[1].ElixirSuite__Approver_Custom_Label__c;
                    ApprovalLevelTwo.dateOfApproval = thisParentPrescription.ElixirSuite__Date_Of_Approval_2__c;
                    
                    String signature = thisParentPrescription.ElixirSuite__User_2__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images2 = [SELECT Id FROM ContentDocument WHERE Id= :signature];
                        if (images2 != null && images2.size() > 0) {
                            ApprovalLevelTwo.signatureContentDocumentId = images2[0].Id;
                        }
                    }

                    ApprovalLevelTwo.userId = thisParentPrescription.ElixirSuite__User_2__c;
                    ApprovalLevelTwo.userName = thisParentPrescription.ElixirSuite__User_2__r.Name;
                    ApprovalLevelTwo.userRole = thisParentPrescription.ElixirSuite__User_2__r.userrole.name;

                    allApprovedValues.add(ApprovalLevelTwo);
                }

                // Approval level three
                if (thisParentPrescription.ElixirSuite__Date_Of_Approval_3__c != null && thisParentPrescription.ElixirSuite__User_3__c != null) {
                    OrderSignatureSave.SignAndAprroveData ApprovalLevelThree = new OrderSignatureSave.SignAndAprroveData();
                    ApprovalLevelThree.approvalLevel = 3;
                    ApprovalLevelThree.comments = thisParentPrescription.ElixirSuite__Comment_3__c;
                    // As prescriptionApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    ApprovalLevelThree.customLabel = prescriptionApprovalConfiguration[2].ElixirSuite__Approver_Custom_Label__c;
                    ApprovalLevelThree.dateOfApproval = thisParentPrescription.ElixirSuite__Date_Of_Approval_3__c;
                    
                    String signature = thisParentPrescription.ElixirSuite__User_3__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images3 = [SELECT Id FROM ContentDocument WHERE Id= :signature];
                        if (images3 != null && images3.size() > 0) {
                            ApprovalLevelThree.signatureContentDocumentId = images3[0].Id;
                        }
                    }

                    ApprovalLevelThree.userId = thisParentPrescription.ElixirSuite__User_3__c;
                    ApprovalLevelThree.userName = thisParentPrescription.ElixirSuite__User_3__r.Name;
                    ApprovalLevelThree.userRole = thisParentPrescription.ElixirSuite__User_3__r.userrole.name;

                    allApprovedValues.add(ApprovalLevelThree);
                }

                return allApprovedValues;
            }
            else {
                throw new AuraHandledException('No parent prescription found with given Id');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<OrderSignatureSave.SignAndAprroveData> fetchLabOrderApprovedValues(String labOrderId){
        try {
            labOrderId = String.escapeSingleQuotes(labOrderId);
            List<ElixirSuite__UA_Sample_Details__c> labOrder = [
                SELECT Id,
                       ElixirSuite__Date_Of_Approval_1__c, ElixirSuite__Comment_1__c, ElixirSuite__User_1__c, ElixirSuite__User_1__r.Signature_Attachment_Id__c, ElixirSuite__User_1__r.Name, ElixirSuite__User_1__r.userrole.name,
                       ElixirSuite__Date_Of_Approval_2__c, ElixirSuite__Comment_2__c, ElixirSuite__User_2__c, ElixirSuite__User_2__r.Signature_Attachment_Id__c, ElixirSuite__User_2__r.Name, ElixirSuite__User_2__r.userrole.name,
                       ElixirSuite__Date_Of_Approval_3__c, ElixirSuite__Comment_3__c, ElixirSuite__User_3__c, ElixirSuite__User_3__r.Signature_Attachment_Id__c, ElixirSuite__User_3__r.Name, ElixirSuite__User_3__r.userrole.name
                  FROM ElixirSuite__UA_Sample_Details__c 
                 WHERE Id = :labOrderId WITH SECURITY_ENFORCED];

            if (labOrder != null && labOrder.size() > 0) {
                ElixirSuite__UA_Sample_Details__c thisLabOrder = labOrder[0];

                // query master object for custom label
                String approvalRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
                List<ElixirSuite__Master_Object__c> labOrderApprovalConfiguration = [
                    SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Approver__c, ElixirSuite__Approval_Members__c, ElixirSuite__Approver_Custom_Label__c, ElixirSuite__Approval_Level_For__c
                      FROM ElixirSuite__Master_Object__c
                     WHERE ElixirSuite__Approval_Level__c != null
                       AND ElixirSuite__Approval_Level_For__c = 'Lab Order'
                       AND RecordTypeId = :approvalRecordTypeId WITH SECURITY_ENFORCED
                ORDER BY ElixirSuite__Approval_Level__c];

                List<OrderSignatureSave.SignAndAprroveData> allApprovedValues = new List<OrderSignatureSave.SignAndAprroveData>();
                // Approval level one
                if (thisLabOrder.ElixirSuite__Date_Of_Approval_1__c != null && thisLabOrder.ElixirSuite__User_1__c != null) {
                    OrderSignatureSave.SignAndAprroveData ApprovalLevelOne = new OrderSignatureSave.SignAndAprroveData();
                    ApprovalLevelOne.approvalLevel = 1;
                    ApprovalLevelOne.comments = thisLabOrder.ElixirSuite__Comment_1__c;
                    // As labOrderApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    ApprovalLevelOne.customLabel = labOrderApprovalConfiguration[0].ElixirSuite__Approver_Custom_Label__c;
                    ApprovalLevelOne.dateOfApproval = thisLabOrder.ElixirSuite__Date_Of_Approval_1__c;
                    
                    String signature = thisLabOrder.ElixirSuite__User_1__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images1 = [SELECT Id FROM ContentDocument WHERE Id= :signature];
                        if (images1 != null && images1.size() > 0) {
                            ApprovalLevelOne.signatureContentDocumentId = images1[0].Id;
                        }
                    }

                    ApprovalLevelOne.userId = thisLabOrder.ElixirSuite__User_1__c;
                    ApprovalLevelOne.userName = thisLabOrder.ElixirSuite__User_1__r.Name;
                    ApprovalLevelOne.userRole = thisLabOrder.ElixirSuite__User_1__r.userrole.name;

                    allApprovedValues.add(ApprovalLevelOne);
                }

                // Approval level two
                if (thisLabOrder.ElixirSuite__Date_Of_Approval_2__c != null && thisLabOrder.ElixirSuite__User_2__c != null) {
                    OrderSignatureSave.SignAndAprroveData ApprovalLevelTwo = new OrderSignatureSave.SignAndAprroveData();
                    ApprovalLevelTwo.approvalLevel = 2;
                    ApprovalLevelTwo.comments = thisLabOrder.ElixirSuite__Comment_2__c;
                    // As labOrderApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    ApprovalLevelTwo.customLabel = labOrderApprovalConfiguration[1].ElixirSuite__Approver_Custom_Label__c;
                    ApprovalLevelTwo.dateOfApproval = thisLabOrder.ElixirSuite__Date_Of_Approval_2__c;
                    
                    String signature = thisLabOrder.ElixirSuite__User_2__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images2 = [SELECT Id FROM ContentDocument WHERE Id= :signature];
                        if (images2 != null && images2.size() > 0) {
                            ApprovalLevelTwo.signatureContentDocumentId = images2[0].Id;
                        }
                    }

                    ApprovalLevelTwo.userId = thisLabOrder.ElixirSuite__User_2__c;
                    ApprovalLevelTwo.userName = thisLabOrder.ElixirSuite__User_2__r.Name;
                    ApprovalLevelTwo.userRole = thisLabOrder.ElixirSuite__User_2__r.userrole.name;

                    allApprovedValues.add(ApprovalLevelTwo);
                }

                // Approval level three
                if (thisLabOrder.ElixirSuite__Date_Of_Approval_3__c != null && thisLabOrder.ElixirSuite__User_3__c != null) {
                    OrderSignatureSave.SignAndAprroveData ApprovalLevelThree = new OrderSignatureSave.SignAndAprroveData();
                    ApprovalLevelThree.approvalLevel = 3;
                    ApprovalLevelThree.comments = thisLabOrder.ElixirSuite__Comment_3__c;
                    // As labOrderApprovalConfiguration will be sorted by approval level, we can assume 1st record crossponds to first approval level
                    ApprovalLevelThree.customLabel = labOrderApprovalConfiguration[2].ElixirSuite__Approver_Custom_Label__c;
                    ApprovalLevelThree.dateOfApproval = thisLabOrder.ElixirSuite__Date_Of_Approval_3__c;
                    
                    String signature = thisLabOrder.ElixirSuite__User_3__r.Signature_Attachment_Id__c;
                    if (String.isNotEmpty(signature)) {
                        List<ContentDocument> images3 = [SELECT Id FROM ContentDocument WHERE Id= :signature WITH SECURITY_ENFORCED];
                        if (images3 != null && images3.size() > 0) {
                            ApprovalLevelThree.signatureContentDocumentId = images3[0].Id;
                        }
                    }

                    ApprovalLevelThree.userId = thisLabOrder.ElixirSuite__User_3__c;
                    ApprovalLevelThree.userName = thisLabOrder.ElixirSuite__User_3__r.Name;
                    ApprovalLevelThree.userRole = thisLabOrder.ElixirSuite__User_3__r.userrole.name;

                    allApprovedValues.add(ApprovalLevelThree);
                }

                return allApprovedValues;
            }
            else {
                throw new AuraHandledException('No lab order found with given Id');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


        @AuraEnabled
    public static FormApprovalData.currentUserInfo fetchApprovalLevelsOnCreate(String recordTypeName){
        try {
            system.debug('Inside fetchApprovalLevelsOnCreate');
            List<Object_1_css__c> defaultApprovalLevels = new List<Object_1_css__c>();
            SObjectAccessDecision decisionNonApproved = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Approval_Level__c, Approv__c, Approval_Members__c, ElixirSuite__Approver_Custom_Label__c FROM 
                            Object_1_css__c WHERE Form__c= :recordTypeName AND Approval_Level__c!=NULL
                            ORDER BY Approval_Level__c]);
            defaultApprovalLevels = decisionNonApproved.getRecords();
            List<Form_Value__c> approvedValues = new List<Form_Value__c>();
            
            FormApprovalData.currentUserInfo userInfo = new FormApprovalData.currentUserInfo();
            userInfo.setUserId();
            userInfo.setProfileId();
            userInfo.setRoleId();
            userInfo.setDefaultLevels(defaultApprovalLevels);
            userInfo.setApprovedValues(approvedValues);
            system.debug('userInfo'+userInfo);
            return userInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


     //To display insert signature img for portal users - Srihari
     @AuraEnabled
     public static String getNotesFlag(String accId,String formId){
         String status='';
         string query = 'select id,AccountId__c,Is_Patient_Portal_Form__c from Object_2__c where AccountId__c =:accId AND Form_unique_id__c=:formId';
         
         List<sObject> portalStatus = Database.query(query);
         
         for(sObject obj :portalStatus){
             status=String.valueOf(obj.get('Is_Patient_Portal_Form__c'));
         }
         
         return status;
     }
}