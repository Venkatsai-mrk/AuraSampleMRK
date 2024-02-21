/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-13-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ChangeStatusHelper {
    
    @AuraEnabled
    public static void checkClaimStatus(String claimId)
    {
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='NewClaimMDIntegration' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null){
            Callable calloutGetPayer = (Callable) Type.forName(virtualClassName).newInstance();
            calloutGetPayer.call('GetpayerStatusClaimMD', new Map<String, Object> {
                'claimId' => claimId
                    });
            
        }else{
           throw new AuraHandledException('Please configure a clearing house to get the payer status');
        }
    }
    
    
    
}