public with sharing class LeadConversionHelper {
    static Map<Id,Account> recordTypesMap = new Map<Id,Account>();
    static List<String> leadRecTypes = new  List<String>();
    public static void convertLead(List<Lead> leads) {
        List<UserLocation__c> userLocations = [SELECT Id FROM UserLocation__c WITH SECURITY_ENFORCED LIMIT 1];
        if(userLocations==null){
            return;//In case, no Location is configured 
        }
        Map<Id,Id> allAccountIdsForProviderCreation = new Map<Id,Id>();
        Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
        String leadRecordTypes = mc.Record_Type_for_Conversion__c;
        Boolean areTypesMentioned = false;
        if(String.isNotBlank(leadRecordTypes)){
            leadRecTypes = leadRecordTypes.split(';');
            areTypesMentioned = true;
        }
        Set<Id> accountIds = new Set<Id>(); 
        for(Lead ld :leads){
            if(ld.isConverted){
                if(areTypesMentioned){
                    accountIds.add(ld.ConvertedAccountId);
                }
                if(ld.Provider__c!=null){
                    allAccountIdsForProviderCreation.put(ld.ConvertedAccountId,ld.Provider__c);
                }
            }
        }
        if(accountIds.size()>0){
            recordTypesMap = new Map<Id,Account>([SELECT Id,RecordtypeId, Recordtype.DeveloperName 
                                                  FROM Account
                                                  WHERE Id IN :accountIds
                                                  WITH SECURITY_ENFORCED
                                                  LIMIT 999]);
        }
        for(Lead ld :leads){
            if(ld.isConverted){
                checkError(ld, areTypesMentioned);
            }
        }
        StopRecursion.stopLocationUpdation = false;
        if(allAccountIdsForProviderCreation.size()>0){
            StopRecursion.isLeadConverted = true;
            createProviders(allAccountIdsForProviderCreation);
            createCareEpisode(allAccountIdsForProviderCreation);
        }
    }
    private static void checkError(Lead ld, Boolean areTypesMentioned){
        if(areTypesMentioned){
            Id accountId = ld.ConvertedAccountId;
            if(recordTypesMap.containsKey(accountId)){
                String developerName = recordTypesMap.get(accountId).Recordtype.DeveloperName;
                if(leadRecTypes.contains(developerName) && ld.provider__c==null){
                    ld.provider__c.addError('Please fill the location first!!');
                }
            }
        }
    }
    private static void createCareEpisode(Map<Id,Id> allAccountIdsForProviderCreation){
        Id patientTypeId;
        List<Recordtype> providerType = [SELECT Id, DeveloperName FROM RecordType
                                         WHERE DeveloperName='Template_Provider' WITH SECURITY_ENFORCED LIMIT 1];
        if(providerType!=null && providerType.size()>0){
            patientTypeId = providerType[0].Id;
        }
        if(patientTypeId == null){
            return;
        }
        List<Visits__c> visits = new List<Visits__c>();
        try{
            for(Id accountId :allAccountIdsForProviderCreation.keySet()){
                visits.add(new Visits__c(
                    Name = 'Visit - 01',
                    Status__c = 'Active',
                    Account__c = accountId,
                    Care_Episode_Location__c = allAccountIdsForProviderCreation.get(accountId)
                ));
            }
            if(visits.size()>0 &&
               Schema.sObjectType.Visits__c.fields.Status__c.isCreateable() &&
               Schema.sObjectType.Visits__c.fields.Account__c.isCreateable() &&
               Schema.sObjectType.Visits__c.fields.Care_Episode_Location__c.isCreateable()){
                   insert visits;
               }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    private static void createProviders(Map<Id,Id> allAccountIdsForProviderCreation){
        Id patientTypeId;
        List<Recordtype> providerType = [SELECT Id, DeveloperName FROM RecordType
                                         WHERE DeveloperName='Patient_Provider' WITH SECURITY_ENFORCED LIMIT 1];
        if(providerType!=null && providerType.size()>0){
            patientTypeId = providerType[0].Id;
        }
        if(patientTypeId == null){
            return;
        }
        List<Provider__c> providers = [SELECT Id, Name, Address__c, Provider_First_Name__c, Patient_Provider__c, 
                                       Provider_Code__c, Provider_Last_Name__c, Account__c, Provider_Taxonomy__c, 
                                       Provider_Tax_Id__c, Provider_TaxId_Type__c, Provider_City__c, 
                                       Provider_State__c, Provider_Zip__c, ID_Qualifier__c FROM Provider__c
                                       WHERE Id IN :allAccountIdsForProviderCreation.values() 
                                       WITH SECURITY_ENFORCED
                                       LIMIT 999];
        Map<Id,Provider__c> provs = new Map<Id,Provider__c>(providers);
        List<Provider__c> newProviders = new List<Provider__c>();
        try{
            for(Id accountId :allAccountIdsForProviderCreation.keySet()){
                Id providerId = allAccountIdsForProviderCreation.get(accountId);
                Provider__c providerDetails= provs.get(providerId);
                Provider__c newProv = new Provider__c(
                    RecordtypeId = patientTypeId,
                    Account__c = accountId,
                    Name = providerDetails.Name,
                    Address__c = providerDetails.Address__c,
                    Provider_First_Name__c = providerDetails.Provider_First_Name__c,
                    Provider_Last_Name__c = providerDetails.Provider_Last_Name__c,
                    Provider_Taxonomy__c = providerDetails.Provider_Taxonomy__c,
                    Provider_Code__c = providerDetails.Provider_Code__c,
                    Provider_Tax_Id__c = providerDetails.Provider_Tax_Id__c,
                    Provider_TaxId_Type__c = providerDetails.Provider_TaxId_Type__c,
                    Provider_City__c = providerDetails.Provider_City__c,
                    Provider_State__c = providerDetails.Provider_State__c,
                    Provider_Zip__c = providerDetails.Provider_Zip__c
                );
                newProviders.add(newProv);
            }
            if(newProviders.size()>0 &&
               Schema.sObjectType.Provider__c.fields.RecordtypeId.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Account__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Name.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Address__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_First_Name__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Last_Name__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Taxonomy__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Code__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Tax_Id__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_TaxId_Type__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_City__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_State__c.isCreateable() &&
               Schema.sObjectType.Provider__c.fields.Provider_Zip__c.isCreateable()){
                   insert newProviders;
               }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void changeAccountName(List<Lead> leads){
        Set<Id> convertedIds = new Set<Id>();
        Map<Id,String> accountIds = new Map<Id,String>();
        Map<Id,String> accountFirstName = new Map<Id,String>();
        Map<Id,String> accountLastName = new Map<Id,String>();
        
        for(Lead ld :leads){
            if(ld.IsConverted){
                List<String> names = new List<String>();
                if(String.isNotBlank(ld.FirstName)){
                    names.add(ld.FirstName);
                }
                if(String.isNotBlank(ld.LastName)){
                    names.add(ld.LastName);
                }
                convertedIds.add(ld.Id);
                accountIds.put(ld.ConvertedAccountId, String.join(names,' '));
                accountFirstName.put(ld.ConvertedAccountId,ld.FirstName);
                accountLastName.put(ld.ConvertedAccountId,ld.LastName);
            }
        }
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String patAccRecType = val.ElixirSuite__Patient_Account_Recordtype__c; 
        List<String> recordTypes = new List<String>{patAccRecType};
            List<Account> accounts = [SELECT Id, Name, RecordType.DeveloperName FROM Account 
                                      WHERE Id IN :accountIds.keySet() AND RecordType.DeveloperName IN :recordTypes WITH SECURITY_ENFORCED];
        List<Account> accUpdate = new List<Account>();
        try{
            if(accounts!=null && accounts.size()>0){
                for(Account acc :accounts){
                    if(accountIds.containsKey(acc.Id)){
                        acc.Name = accountIds.get(acc.Id);
                        if(accountFirstName != null && accountFirstName.get(acc.Id) != null && !string.isBlank(accountFirstName.get(acc.Id))){
                        acc.ElixirSuite__First_Name__c = accountFirstName.get(acc.Id);
                        }
                        if(accountLastName != null && accountLastName.get(acc.Id) != null){
                        acc.ElixirSuite__Last_Name__c = accountLastName.get(acc.Id);
                        }
                    }
                    accUpdate.add(acc);
                }
                if (accUpdate != null && accUpdate.size() >0 && Schema.sObjectType.Account.isUpdateable()){
                    DMLManager.updateAsUser(accUpdate);
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
        
}