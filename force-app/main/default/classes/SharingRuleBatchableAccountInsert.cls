/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SharingRuleBatchableAccountInsert implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id,List<Id>> userAllLocationsAccess = new Map<Id,List<Id>>();
    public SharingRuleBatchableAccountInsert(Map<Id,List<Id>> userAllLocationsAccess) {
        this.userAllLocationsAccess = userAllLocationsAccess;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,(SELECT Id,Provider__c FROM Providers__r) FROM Account';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Account> accounts = (List<Account>) scope;
       Map<Id,List<Id>> accountProviders = new Map<Id,List<Id>>();
       for(Account acc :accounts){
        accountProviders.put(acc.Id,new List<Id>{});
            for(Provider__c provider :acc.Providers__r){
                accountProviders.get(acc.Id).add(provider.provider__c);
            }
       }
       List<AccountShare> sharedAccounts = [SELECT Id,AccountId, UserOrGroupId FROM AccountShare 
                                            WHERE UserOrGroupId IN :userAllLocationsAccess.keySet() AND RowCause='Manual' WITH SECURITY_ENFORCED];
        Map<Id,List<Id>> accountVsUsers = new Map<Id,List<Id>>();
        for(AccountShare sharedAccount :sharedAccounts){
            Id accountId = sharedAccount.AccountId;
            if(accountVsUsers.containsKey(accountId)){
                accountVsUsers.get(accountId).add(sharedAccount.UserOrGroupId);
            }else{
                accountVsUsers.put(accountId, new List<Id>{sharedAccount.UserOrGroupId});
            }
        }

       List<AccountShare> newRecords = new List<AccountShare>();
       for(Account acc :accounts){
            for(Id userId :userAllLocationsAccess.keySet()){
                if(accountVsUsers.containsKey(acc.Id)){
                    List<Id> sharedLocations = accountVsUsers.get(acc.Id);
                    if(sharedLocations!=null && sharedLocations.contains(userId)){
                        continue;
                    }
                }
                List<Id> allowedProviders = userAllLocationsAccess.get(userId);
                if(allowedProviders!=null){
                    List<Id> accountRelatedProviders = accountProviders.get(acc.Id);
                    for(Id allowedProvider :allowedProviders){
                        if(accountRelatedProviders.contains(allowedProvider)){
                            AccountShare accountShare = new AccountShare();
                            accountShare.AccountId = acc.Id;
                            accountShare.UserOrGroupId = userId;
                            accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                            accountShare.AccountAccessLevel = 'Edit';
                            accountShare.OpportunityAccessLevel = 'Edit';
                            newRecords.add(accountShare);
                            break;
                        }
                    }
                }
            }
        }
        if(newRecords!=null && newRecords.size()>0){
            if(Schema.sObjectType.AccountShare.isCreateable() &&
            Schema.sObjectType.AccountShare.fields.AccountId.isCreateable() &&
            Schema.sObjectType.AccountShare.fields.UserOrGroupId.isCreateable() &&
            Schema.sObjectType.AccountShare.fields.RowCause.isCreateable() &&
            Schema.sObjectType.AccountShare.fields.AccountAccessLevel.isCreateable() &&
            Schema.sObjectType.AccountShare.fields.OpportunityAccessLevel.isCreateable()){
            insert newRecords;
        }
    }
    }
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new SharingRuleBatchableVOBInsert(userAllLocationsAccess),2000);
    }
}