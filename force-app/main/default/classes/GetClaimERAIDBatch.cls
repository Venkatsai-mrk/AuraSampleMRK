/*Author name           :  Rohit Singh
* Purpose               :  To automatically create Integration data records to store ERA Id for specific claims
* Schedule              :  Scheduling on daily basis
* Test Class            :  
* Schedular class       :   
*/
public with sharing class GetClaimERAIDBatch {
    
    @AuraEnabled
    public static void entryPointCallout(){
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='NewClaimMDIntegration' WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName !=null && !Test.isRunningTest()){
             Callable calloutclaimMd = (Callable) Type.forName(virtualClassName).newInstance();
            calloutclaimMd.call('GetERA', new Map<String, Object> {
                });
            
        }else if(!Test.isRunningTest()){
            throw new AuraHandledException('Please configure a clearing house to get the ERA');
        }
    }  
    @AuraEnabled
    public static Id viewId(){
        List<ListView> views = [SELECT Id, DeveloperName, SobjectType 
        FROM ListView 
        WHERE DeveloperName='All_Claims' WITH SECURITY_ENFORCED LIMIT 1];
        system.debug(views);
        Id viewId = null;
        if(views!=null && views.size()>0){ 
            viewId = views[0].Id;
        }
        return viewId;
    }
}