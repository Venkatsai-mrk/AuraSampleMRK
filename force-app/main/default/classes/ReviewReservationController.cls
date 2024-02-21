public with sharing class ReviewReservationController {

    public class AccountInfoWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public Date birthDate;
        @AuraEnabled public String phone;
        @AuraEnabled public String email;        
    }
    
    public class LocationWrapper{
        @AuraEnabled public String locationId;
        @AuraEnabled public String locationName;
        @AuraEnabled public List<ElixirSuite__Actual_Price__c> actualPrices;
        @AuraEnabled public List<ElixirSuite__Contracted_Price__c> contractPrices;
        @AuraEnabled public String recordTypeName;  
        
    }
    
    @AuraEnabled
    public static AccountInfoWrapper getAccountDetails(String accountId){
        Account acc = [SELECT Id, Name, ElixirSuite__Email_Id__c, ElixirSuite__DOB__c, Phone
                       FROM Account
                       WHERE Id=:accountId
                       WITH SECURITY_ENFORCED];
        
        AccountInfoWrapper wrpr = new AccountInfoWrapper();
        wrpr.name = acc.Name;
        wrpr.birthDate = acc.ElixirSuite__DOB__c;
        wrpr.phone = acc.Phone;
        wrpr.email = acc.ElixirSuite__Email_Id__c;
        return wrpr;
    }
   
    @AuraEnabled
    public static List<LocationWrapper> getLocationDetails(List<String> locationIds){
        // Map<String, List<String>> locationIdToActualPrice = new Map<String, List<String>>();
        // Map<String, List<String>> locationIdToActualPrice = new Map<String, List<String>>();
        Map<String, List<ElixirSuite__Contracted_Price__c>> locationIdToContractedPrice = new Map<String, List<ElixirSuite__Contracted_Price__c>>();
        Map<String, List<Actual_Price__c>> locationIdToActualPrice = new Map<String, List<Actual_Price__c>>();
        List<LocationWrapper> wrprList = new List<LocationWrapper>();
        List<Location__c> location = [SELECT Id, Name, RecordType.Name
                                      FROM Location__c
                                      WHERE Id IN:locationIds
                                      WITH SECURITY_ENFORCED];
        Id recordTypId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
      

        List<ElixirSuite__Procedure__c> procedures = [SELECT Id, ElixirSuite__Location__c,ElixirSuite__Type_of_Procedure__c,
                                                (SELECT Id, ElixirSuite__List_Price__c, ElixirSuite__Description__c FROM ElixirSuite__Actual_Price__r ORDER BY CreatedDate DESC LIMIT 10),
                                                (SELECT Id, ElixirSuite__Contracted_Amount__c,ElixirSuite__Description__c FROM ElixirSuite__Contracted_Price__r ORDER BY CreatedDate DESC LIMIT 10)
                                            FROM ElixirSuite__Procedure__c
                                            WHERE ElixirSuite__Location__c IN :locationIds AND
                                                RecordTypeId = :recordTypId
                                            WITH SECURITY_ENFORCED
                                        ];



        

        for (Procedure__c p : procedures) { 
           
            
            if (p.Actual_Price__r != null) {
                 if (!locationIdToActualPrice.containsKey(p.Location__c)) {
                    locationIdToActualPrice.put(p.Location__c, new List<Actual_Price__c>());
                    }
                for (Actual_Price__c actualPriceRecord : p.Actual_Price__r) {
                    locationIdToActualPrice.get(p.Location__c).add(actualPriceRecord);
                }
            }

            
            if (p.ElixirSuite__Contracted_Price__r != null) {
                if (!locationIdToContractedPrice.containsKey(p.Location__c)) {
                locationIdToContractedPrice.put(p.Location__c, new List<ElixirSuite__Contracted_Price__c>());
                    }
            
                for (ElixirSuite__Contracted_Price__c contractedPriceRecord : p.ElixirSuite__Contracted_Price__r) {
                    locationIdToContractedPrice.get(p.Location__c).add(contractedPriceRecord);
                }
            }
        }
        for(Location__c l : location){
            LocationWrapper wrpr = new LocationWrapper();
            wrpr.locationId = l.Id;
            wrpr.locationName = l.Name;
            wrpr.actualPrices = locationIdToActualPrice.get(l.Id);
            wrpr.contractPrices = locationIdToContractedPrice.get(l.Id);
            wrpr.recordTypeName = l.RecordType.Name;
            wrprList.add(wrpr);
        }
        
        
        return wrprList;
        
    }
    
    
}