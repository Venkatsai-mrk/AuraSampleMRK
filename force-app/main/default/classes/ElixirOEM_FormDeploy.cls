public with sharing class ElixirOEM_FormDeploy {
    private static final String NAMED_CREDENTIAL = 'Deploy_Form_Named_Credential';


    public static void assertThatFormDoesNotExistInTargetOrg(String formName) { 
        HttpRequest request = new HttpRequest();

        // escaping single quotes to prevent SOQL injection.
        // Recommended by salesforce here- https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_soql.htm
        formName = String.escapeSingleQuotes(formName);
        String templateQuery = 'SELECT Id FROM ElixirSuite__Object_1_Css__c WHERE ElixirSuite__Section_Number__c = 1 AND ElixirSuite__Form__c = \'' + formName + '\'';

        request.setEndpoint('callout:'+ NAMED_CREDENTIAL + '/services/data/v56.0/query/?q=' + EncodingUtil.urlEncode(templateQuery, 'UTF-8'));
        request.setMethod('GET');
        request.setHeader('Content-Type','application/json');

        Http http = new Http();
        HttpResponse response = http.send(request);	

        Map<String, Object> responseBodyAsMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Integer numberOfSectionsForThisFormInTargetOrg = (Integer) responseBodyAsMap.get('totalSize');
        
        if (numberOfSectionsForThisFormInTargetOrg != 0) {
            CalloutException e = new CalloutException();
            e.setMessage('Form configuration already exists in target org. Please delete it before deploying.');
            throw e;
        }        
    }

    public static String serializeRecords(List<ElixirSuite__Object_1_Css__c> records) {
        String serializedRecords = JSON.serialize(records);

        // initially serializedRecords look like this
        // [
        //     {
        //         "attributes": {
        //             "type": "ElixirSuite__Object_1_css__c",
        //             "url": "/services/data/v56.0/sobjects/ElixirSuite__Object_1_css__c/a0n0p000002P0pmAAC"
        //         },
        //         "Id": "a0n0p000002P0pmAAC",
        //         "ElixirSuite__Form__c": "Feature Testing"
        //     }
        // ]

        // we need to add 'referenceId' : 'any string identifier' in attributes, so that it will look like this.
        // why we add referenceId? https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_composite_sobject_tree_flat.htm
        // [
        //     {
        //         "attributes": {
        //             "type": "ElixirSuite__Object_1_css__c",
        //             "url": "/services/data/v56.0/sobjects/ElixirSuite__Object_1_css__c/a0n0p000002P0pmAAC"
        //             "referenceId": "a0n0p000002P0pmAAC",
        //         },
        //         "Id": "a0n0p000002P0pmAAC",
        //         "ElixirSuite__Form__c": "Feature Testing"
        //     }
        // ]

        List<Object> deserializedRecords = (List<Object>) JSON.deserializeUntyped(serializedRecords);
        
        for (Object record : deserializedRecords) {
            Map<String, Object> mappedRecord = (Map<String, Object>) record;
            Map<String, Object> attributesValue = (Map<String, Object>) mappedRecord.get('attributes');
            
            attributesValue.put('referenceId', mappedRecord.get('Id'));
            // make id of records null, as these records are to be created afresh in target orgs with new ids assigned by target org
            mappedRecord.put('Id', null);
        }

        // now we need to return deserializedRecords formatted as JSON, so that it can be used as body in POST request 
        return '{"records":'+ JSON.serialize(deserializedRecords) +'}';
    }

    public static Map<String, String> createRecords(String requestBody) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:'+ NAMED_CREDENTIAL +'/services/data/v56.0/composite/tree/ElixirSuite__Object_1_css__c/');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setBody(requestBody);

        Http http = new Http();
        HttpResponse response = http.send(request);

        // only accepting 201 as we need that the record was created
        if(response.getStatusCode() != 201) {
            CalloutException e = new CalloutException();
            try {
                List<Object> responseBodyAsList = (List<Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> firstEntryInResponseBodyAsMap = (Map<String, Object>) responseBodyAsList[0];  
                e.setMessage(firstEntryInResponseBodyAsMap.get('errorCode') + ' : ' + firstEntryInResponseBodyAsMap.get('message')); 
            } catch (Exception ee) {
                // so salesforce serves some slip-ups as Map<String, Object>, let's handle those. sample json is below-
                // {
                //     "hasErrors": true,
                //     "results": [
                //         {
                //             "referenceId": "a111m000001d4G3AAI",
                //             "errors": [
                //                 {
                //                     "statusCode": "INVALID_CROSS_REFERE (7 more) ...",
                //                     "message": "invalid cross refere (6 more) ...",
                //                     "fields": []
                //                 }
                //             ]
                //         }
                //     ]
                // }
                Map<String, Object> responseBodyAsMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> responseResults = (List<Object>) responseBodyAsMap.get('results');
                Map<String, Object> firstResult = (Map<String, Object>) responseResults[0];
                List<Object> errors = (List<Object>) firstResult.get('errors');
                Map<String, Object> firstError = (Map<String, Object>) errors[0];
                e.setMessage((String) firstError.get('statusCode') + ' : ' + (String) firstError.get('message'));
            }

            throw e;
        }

        // success response looks like this
        // {
        //     "hasErrors" : false,
        //     "results" : [ {
        //       "referenceId" : "a0n0p000002P0pmAAC",
        //       "id" : "a175i000000JFZVAA4"
        //     }, {
        //       "referenceId" : "a0n0p000002P0pnAAC",
        //       "id" : "a175i000000JFZWAA4"
        //     } ]
        // }

        Map<String, Object> responseBodyAsMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        
        // referenceId(Id of record in source org) and Id(Id of records created in target org)
        List<Object> referenceIdAndIdList = (List<Object>) responseBodyAsMap.get('results');
        
        // Mapping referenceId to id to easily access id with respect to referenceId, used in deployForms fucnction
        Map<String, String> srcIdToTargetIdMap = new Map<String, String>();
        for (Object i : referenceIdAndIdList) {
            Map<String, Object> j = (Map<String, Object>) i;
            srcIdToTargetIdMap.put(
                (String) j.get('referenceId'),
                (String) j.get('id')
            );
        }

        return srcIdToTargetIdMap;
        
    }

    public static List<String> findDeployableFields() {
        // queries source & target org  for all Fields in ElixirSuite__Object_1_css__c
        // filters common & custom fields as deployable
        List<String> availableFields = new List<String>{'Id'};
        // Id is not deployable, before deploying we will set it to null. we use it's value as referencId which gets mapped & replaced with Ids created in target org.

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:'+ NAMED_CREDENTIAL + '/services/data/v56.0/sobjects/ElixirSuite__Object_1_css__c/describe/');
        request.setMethod('GET');
        request.setHeader('Content-Type','application/json');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            CalloutException e = new CalloutException();
            e.setMessage('Failed to fetch available fields in target org');
            throw e;
        }

        // success
        Map<String, Object> responseBodyAsMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> targetOrgfields = (List<Object>) responseBodyAsMap.get('fields');
        Set<String> sourceOrgFields = ElixirSuite__Object_1_css__c.sObjectType.getDescribe().fields.getMap().keySet();
        for ( Object i : targetOrgfields) {
            Map<String, Object> iMap = (Map<String, Object>) i;
            Boolean isCustomField = (Boolean) iMap.get('custom');
            String iName = (String) iMap.get('name');
            if (isCustomField && sourceOrgFields.contains(iName.toLowerCase())) {
                availableFields.add(iName);
            } 
        }

        return availableFields;
    }

    Public static List<ElixirSuite__Object_1_css__c> fetchAllSectionsOfThisForm(String formName,  List<String> requiredFields) {
        // escaping single quotes to prevent SOQL injection.
        // Recommended by salesforce here- https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_soql.htm
        formName = String.escapeSingleQuotes(formName);
        String dynamicQuery = 'SELECT ' + String.join(requiredFields, ',') + ' FROM ElixirSuite__Object_1_css__c WHERE ElixirSuite__Form__c = :formName';
        return Database.query(String.escapeSingleQuotes(dynamicQuery));
    }

    Public static List<ElixirSuite__Object_1_css__c> fetchAllRowsOfTheseSections(Set<String> sectionIds,  List<String> requiredFields) {
        String dynamicQuery = 'SELECT ' + String.join(requiredFields, ',') + ' FROM ElixirSuite__Object_1_css__c WHERE ElixirSuite__Object_1_css__c IN :sectionIds';
        return Database.query(String.escapeSingleQuotes(dynamicQuery));
    }

    @AuraEnabled
    public static void deployForm(String formName, String formId){
        try {
            // Deploying forms which already exist in target org will create duplicate form configration everywhere. It would be problematic.
            // Throw exception(saying to delete form configration) if it exists in target org.
            assertThatFormDoesNotExistInTargetOrg(formName);
            
            // Find fields which can be populated in target org
            List<String> requiredFields = findDeployableFields();

            // first we will create sections in target org and map id of sections in source org to id of sections created in target org
            // for the map below key is srcID(id of record in source org) and value is TargetId(id of record created in target org)
            Map<String, String> srcIdToTargetIdMap = createRecords(serializeRecords(fetchAllSectionsOfThisForm(formName, requiredFields)));
            

            // let's fetch rows of all section
            Set<String> idOfAllSectionOfThisForm = srcIdToTargetIdMap.keySet();
            List<ElixirSuite__Object_1_Css__c> allRowsOfThisForm = fetchAllRowsOfTheseSections(idOfAllSectionOfThisForm, requiredFields);

            // Rows have id of section in a field called ElixirSuite__Object_1_Css__c. This effectively makes them row of that section
            // Currently this ElixirSuite__Object_1_Css__c contains section id of source org.
            // we are sending these row in target org so let's replace section id of source org with section id of target org

            for (ElixirSuite__Object_1_Css__c row : allRowsOfThisForm) {
                row.ElixirSuite__Object_1_Css__c = srcIdToTargetIdMap.get(row.ElixirSuite__Object_1_Css__c);
            }

            createRecords(serializeRecords(allRowsOfThisForm));

        } catch (Exception e) {
            // Logging errors via ExceptionLog as per guidelines
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}
