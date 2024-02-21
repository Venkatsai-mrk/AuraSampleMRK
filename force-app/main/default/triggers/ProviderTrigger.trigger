trigger ProviderTrigger on Provider__c (before insert,before update, after insert,after update,after delete) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return;  //LX3-6835 - Bypass the trigger execution during data migration
    
    String virtualClassName = 'GlobalVirtualProviderTriggerHelper';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='ProviderTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalVirtualProviderTriggerHelper providerObj = (GlobalVirtualProviderTriggerHelper) t.newInstance(); 
    
    Set<Id> accountIds = new Set<Id>();

    if(trigger.isBefore && trigger.isInsert){
        providerObj.beforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        providerObj.beforeUpdate(trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){
        providerObj.afterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
       providerObj.afterUpdate(trigger.new);
    }
    if(trigger.isAfter && trigger.isDelete){
        providerObj.afterDelete(trigger.old);
    }

    
    /*if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
            for(Provider__c provider :trigger.new){
                accountIds.add(provider.Account__c);
            }
        }
        if(trigger.isDelete){
            for(Provider__c provider :trigger.old){
                accountIds.add(provider.Account__c);
            }
        }
        if(accountIds!=null && accountIds.size()>0){
            //ProviderTriggerHelper.evaluateOpportunityLocation(accountIds);
        }
        //Added to Permit Accounts
        if(trigger.isInsert || trigger.isUpdate){
            system.enqueueJob(new ProviderPermissionHelper(trigger.new));
        }
        if(trigger.isDelete){
            system.enqueueJob(new ProviderPermissionDeletion(trigger.old));
        }
    }
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            ProviderTriggerHelper.populateProviders(trigger.new);
        }
        if(trigger.isInsert || trigger.isUpdate && trigger.isBefore){
            ProviderNpiClass.duplicateProviderNpi(trigger.new);
        }
    }*/
}