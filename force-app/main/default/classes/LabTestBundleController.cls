/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class LabTestBundleController {

    // Shaurya Pratap Singh (13/12/2022)
    @AuraEnabled(cacheable=true)
    public static String getNamespace(){
        ElixirSuite__Elixir_Custom_Setting__c customSetting = new ElixirSuite__Elixir_Custom_Setting__c();
        if(!test.isRunningTest()){
        customSetting = [SELECT ElixirSuite__Namespace__c FROM ElixirSuite__Elixir_Custom_Setting__c WITH SECURITY_ENFORCED];
        }
        String nameSpace = String.valueOf(customSetting.ElixirSuite__Namespace__c)+'__';
        return nameSpace;
     }

    // Shaurya Pratap Singh (23/11/2022) 
    //Updated Shaurya Pratap Singh (12/01/2023)
    @AuraEnabled
    public static void saveRecords(string labId,String labTestBundleName,String description, String listOfLabTest,String listOfDiagnosisCodes,String listOfProcedureCodes, String listOfLabTestsSFIds,String listOfProcedureCodesSFIds,String listOfDiagnosisCodesSFIds){

        ElixirSuite__Lab_Test_Bundle__c newLabTestBundle = new ElixirSuite__Lab_Test_Bundle__c();

        newLabTestBundle.ElixirSuite__Lab__c = labId;
        newLabTestBundle.Name = labTestBundleName;
        newLabTestBundle.ElixirSuite__DescriptionField__c = description;
        
        newLabTestBundle.ElixirSuite__Diagnosis_Codes_SF_Ids__c = listOfDiagnosisCodesSFIds;
        newLabTestBundle.ElixirSuite__Procedure_Codes_SF_Ids__c = listOfProcedureCodesSFIds;
        newLabTestBundle.ElixirSuite__Lab_Tests_SF_Ids__c = listOfLabTestsSFIds;

        
        //if(Schema.sObjectType.ElixirSuite__Lab_Test_Bundle__c.isCreateable()) {
            //insert newLabTestBundle;
            DMLManager.insertAsUser(newLabTestBundle);
        //}

    }

    // Shaurya Pratap Singh (19/12/2022) 
    // Shaurya Pratap Singh Updated (13/01/2022)
    @AuraEnabled(cacheable = true)
    public static ElixirSuite__Lab_Test_Bundle__c getRecordData(String bundleId){

        ElixirSuite__Lab_Test_Bundle__c bundleData = [SELECT Name,ElixirSuite__DescriptionField__c
                                                    FROM ElixirSuite__Lab_Test_Bundle__c 
                                                    WHERE Id =: bundleId 
                                                    WITH SECURITY_ENFORCED 
                                                    LIMIT 1];

        return bundleData;                                          
    }

    // Shaurya Pratap Singh (21/12/2022)
    @AuraEnabled
    public static void updateRecords(String labId,String bundleRecordId,String labTestBundleName,String description, String listOfLabTest,String listOfLabTestsSFIds,String listOfProcedureCodesSFIds,String listOfDiagnosisCodesSFIds,String listOfDiagnosisCodes,String listOfProcedureCodes){
        ElixirSuite__Lab_Test_Bundle__c toUpdateLabTestBundle = [SELECT Name,ElixirSuite__DescriptionField__c,ElixirSuite__Diagnosis_Codes_SF_Ids__c, ElixirSuite__Procedure_Codes_SF_Ids__c
                                                            FROM ElixirSuite__Lab_Test_Bundle__c WHERE Id =: bundleRecordId WITH SECURITY_ENFORCED LIMIT 1];
        //toUpdateLabTestBundle.ElixirSuite__Lab__c = labId;
        toUpdateLabTestBundle.Name = labTestBundleName;
        toUpdateLabTestBundle.ElixirSuite__DescriptionField__c = description;
        
        toUpdateLabTestBundle.ElixirSuite__Diagnosis_Codes_SF_Ids__c = listOfDiagnosisCodesSFIds;
        toUpdateLabTestBundle.ElixirSuite__Procedure_Codes_SF_Ids__c = listOfProcedureCodesSFIds;
        toUpdateLabTestBundle.ElixirSuite__Lab_Tests_SF_Ids__c = listOfLabTestsSFIds;
        
        if (Schema.sObjectType.ElixirSuite__Lab_Test_Bundle__c.isUpdateable()) {
            Database.update(toUpdateLabTestBundle);
        }

    }

    // Shaurya Pratap Singh (16/01/2022)
    @AuraEnabled(cacheable=true)
    public static String getFieldValue(String recordId) {
        String fieldValue;
        try {
            ElixirSuite__Lab__c record = [SELECT Id,ElixirSuite__Lab_Id__c FROM ElixirSuite__Lab__c WHERE Id =:recordId WITH SECURITY_ENFORCED];
            fieldValue = record.ElixirSuite__Lab_Id__c;
        } catch (Exception e) {
            system.debug(e);
            fieldValue = null;
        }
        return fieldValue;
    }

    // Shaurya Pratap Singh (17/01/2022)
    public static List<ElixirSuite__ICD_Codes__c> getDiagnosisRecordFields(String recordIds) {
        List<ElixirSuite__ICD_Codes__c> fieldValues = new List<ElixirSuite__ICD_Codes__c>();
        List<Id> recordIdList = recordIds.split(';');
    
        for (Id recordId : recordIdList) {
            ElixirSuite__ICD_Codes__c record = [SELECT Id,Name FROM ElixirSuite__ICD_Codes__c WHERE Id = :recordId WITH SECURITY_ENFORCED];
            // system.debug(record);
            fieldValues.add(record);
        }
        return fieldValues;
    }

    //By Shubanghi & Sanjay
    @AuraEnabled(cacheable=true)
    public static List<ICD_Codes__c> getProceduresCode(string searchKey){
        try{
            Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
            //String query_first = 'select Id,Name from Procedure__c where recordTypeId =:recordTypeId';
            String query_first = 'SELECT Id, Name FROM Procedure__c WHERE recordTypeId =:recordTypeId AND ElixirSuite__Code_Category__c != \'Modifier\'';

            String query_last='';
            
            if ( searchKey != null && searchKey != '' ) {
                String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
                query_last += ' and (Name LIKE :key)';
            }
            
            query_first += query_last ;
            system.debug('Find Test Query :' + query_first );
            return Database.query(query_first);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //By Shubanghi & Sanjay
    @AuraEnabled(cacheable=true)
    public static List<ICD_Codes__c> getDiagnosisCode(string searchKey){
        try{
            Id recordTypeId = Schema.SObjectType.ElixirSuite__ICD_Codes__c.getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();
            String query_first = 'select id,name from ICD_Codes__c where recordTypeId =:recordTypeId';
            String query_last='';
            
            if ( searchKey != null && searchKey != '' ) {
                String key = '%' + searchKey + '%';
                query_last += ' and (Name LIKE :key)';
            }
            
            query_first += query_last ;
            system.debug('Find Test Query :' + query_first );
            return Database.query( String.escapeSingleQuotes(query_first) );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Fetching data from SF Ids field by Shubhangi Vats
    @AuraEnabled(cacheable = true)
    public static ElixirSuite__Lab_Test_Bundle__c fetchRecords(String bundleId){
        ElixirSuite__Lab_Test_Bundle__c newBundleData = [SELECT Id,Name,ElixirSuite__DescriptionField__c,ElixirSuite__Lab_Tests_SF_Ids__c,ElixirSuite__Diagnosis_Codes_SF_Ids__c,ElixirSuite__Procedure_Codes_SF_Ids__c 
                                                    FROM ElixirSuite__Lab_Test_Bundle__c 
                                                    WHERE Id =: bundleId 
                                                    WITH SECURITY_ENFORCED 
                                                    LIMIT 1];
        system.debug(newBundleData);
        return newBundleData;
    }


    //Apex class to fetch Procedure records by Shubhangi Vats
    @AuraEnabled(cacheable=true)
    public static List<ElixirSuite__Procedure__c> fetchData(List<String> procedure){

    system.debug(procedure);
    
       List<ElixirSuite__Procedure__c> proc = [SELECT Id FROM ElixirSuite__Procedure__c where Id =:procedure
                                            WITH SECURITY_ENFORCED 
                                            ];
											
		Set<Id> ID = new Set<Id>();
			for(ElixirSuite__Procedure__c proc1 : proc){
			ID.add(proc1.Id);
		}
		
		List<ElixirSuite__Procedure__c> finalresult = [SELECT Name,Id FROM ElixirSuite__Procedure__c where Id IN: ID
                                                      WITH SECURITY_ENFORCED
                                                      ];
        system.debug(finalresult);
        return finalresult;
    }

    //Apex class to fetch Diagnosis Records by Shubhangi Vats
    @AuraEnabled(cacheable=true)
    public static List<ICD_Codes__c> fetchDataDiagnosis(List<String> diagnosis){

    system.debug(diagnosis);
    
       List<ICD_Codes__c> dia = [SELECT Id FROM ICD_Codes__c where Id =:diagnosis
                                            WITH SECURITY_ENFORCED 
                                            ];
											
		Set<Id> ID = new Set<Id>();
			for(ICD_Codes__c dai1 : dia){
			ID.add(dai1.Id);
		}
		
		List<ICD_Codes__c> finalresult = [SELECT Name,Id FROM ICD_Codes__c where Id IN: ID
                                        WITH SECURITY_ENFORCED
                                        ];
        system.debug(finalresult);
        return finalresult;
    }

    //Apex class to fetch Lab Tests records by Shubhangi Vats
    @AuraEnabled(cacheable=true)
    public static List<ElixirSuite__Test__c> fetchDataTest(List<String> test){

    system.debug(test);
    
       List<ElixirSuite__Test__c> tests = [SELECT Id FROM ElixirSuite__Test__c where Id =:test
                                            WITH SECURITY_ENFORCED 
                                            ];
											
		Set<Id> ID = new Set<Id>();
			for(ElixirSuite__Test__c test1 : tests){
			ID.add(test1.Id);
		}
		
		List<ElixirSuite__Test__c> finalresult = [SELECT Name,Test_Name__c,Id FROM ElixirSuite__Test__c where Id IN: ID
                                                WITH SECURITY_ENFORCED
                                                ];
        system.debug(finalresult);
        return finalresult;
    }

}