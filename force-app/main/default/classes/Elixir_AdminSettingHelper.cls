public with sharing class Elixir_AdminSettingHelper {
    @AuraEnabled
    public static String getProfileName() 
    {
        List<Profile> prf = [SELECT Name FROM Profile WHERE Id=:userinfo.getProfileId () WITH security_enforced];
        string PfName;
        for(Profile pf:prf){
            PfName = pf.Name;
        }
        system.debug('PROFILE ' + prf );
        system.debug('PfName ' + PfName);
        return PfName;
    }
    
}