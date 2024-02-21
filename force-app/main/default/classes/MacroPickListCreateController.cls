public with sharing class MacroPickListCreateController {

    @AuraEnabled
    public static List<ElixirSuite__Form_Template__c> formLabels(String keyword, String formName) {
        List<ElixirSuite__Form_Template__c> filteredFormTemplates = new List<ElixirSuite__Form_Template__c>();

        String searchKeyword = '%' + keyword + '%';
        Id currentUserId = UserInfo.getUserId();

        // Fetch the junction records that link User and Form_Template
        List<ElixirSuite__User_and_Form_Template__c> junctionRecords = [
            SELECT Id, ElixirSuite__Form_Template__c, ElixirSuite__Contact__r.ElixirSuite__Practitioner_User__c
            FROM ElixirSuite__User_and_Form_Template__c WITH SECURITY_ENFORCED
        ];
        System.debug('Junction Records: ' + junctionRecords);

        // Collect Form_Template Ids based on the junction records
        Set<Id> formTemplateIds = new Set<Id>();
        Map<Id, List<Id>> formTemplateToUserMap = new Map<Id, List<Id>>();

        for (ElixirSuite__User_and_Form_Template__c junction : junctionRecords) {
            formTemplateIds.add(junction.ElixirSuite__Form_Template__c);

            if (!formTemplateToUserMap.containsKey(junction.ElixirSuite__Form_Template__c)) {
                formTemplateToUserMap.put(junction.ElixirSuite__Form_Template__c, new List<Id>());
            }

            Id practitionerUserId = junction.ElixirSuite__Contact__r != null ? junction.ElixirSuite__Contact__r.ElixirSuite__Practitioner_User__c : null;
            System.debug('Practitioner User ID: ' + practitionerUserId);

            if (practitionerUserId != null) {
                formTemplateToUserMap.get(junction.ElixirSuite__Form_Template__c).add(practitionerUserId);
            }
        }
        System.debug('FormTemplateToUserMap: ' + formTemplateToUserMap);

        // Fetch Form_Template records based on criteria
        List<ElixirSuite__Form_Template__c> formTemplates = [
            SELECT Id, ElixirSuite__Form_Label__c, ElixirSuite__Form_Description__c, ElixirSuite__Select_Forms__c
            FROM ElixirSuite__Form_Template__c
            WHERE ElixirSuite__Active__c = true
                AND Id IN :formTemplateIds
                AND ElixirSuite__Form_Label__c LIKE :searchKeyword
                AND ElixirSuite__Select_Forms__c INCLUDES (:formName) WITH SECURITY_ENFORCED
            ORDER BY ElixirSuite__Form_Label__c ASC
        ];
 System.debug('formTemplates Form Templates: ' + formTemplates);
        // Filter Form_Template records based on the practitioner's association with User_and_Form_Template__c
        for (ElixirSuite__Form_Template__c formTemplate : formTemplates) {
            List<Id> userIdList = formTemplateToUserMap.get(formTemplate.Id);

            if (userIdList != null && !userIdList.isEmpty() && userIdList.contains(currentUserId)) {
                filteredFormTemplates.add(formTemplate);
            }
        }
        System.debug('Filtered Form Templates: ' + filteredFormTemplates);

        return filteredFormTemplates;
    }
}