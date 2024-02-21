public with sharing class PractitionerMultiCtrl {
    @AuraEnabled
    public static List<sObject> fetchLookUpValues(List<Account> acc) {
        List<sObject> returnList = new List <sObject>();
        List<String> setContactId= new List<String>();
        Set<String> lstOfPatientstate=new Set<String>();
        Set<String> lstOfPatientservices=new Set<String>();
        Set<String> lstSelectedIds=new Set<String>();
        
        List<ElixirSuite__License_and_Certifications__c> lstStatePractitioners = new List<ElixirSuite__License_and_Certifications__c>();
        List<ElixirSuite__License_and_Certifications__c> lstCertifiedPractitioners = new List<ElixirSuite__License_and_Certifications__c>();
        Account a = [Select Id,ElixirSuite__State__c,ElixirSuite__Services_Requested__c From Account where Id IN :acc WITH SECURITY_ENFORCED];
           
        for(Account object1:acc){
            lstOfPatientstate.add(object1.ElixirSuite__State__c);     
            String[] tmpString = a.ElixirSuite__Services_Requested__c.split(';');
            for(String s : tmpString){
                lstOfPatientservices.add(s);
            }      
        }

        lstStatePractitioners=[select Id,ElixirSuite__Practitioner__r.Name,ElixirSuite__Value__c,ElixirSuite__Criteria_Type__c,
                               ElixirSuite__Practitioner__c,ElixirSuite__Practitioner__r.Id from  ElixirSuite__License_and_Certifications__c
                               where ElixirSuite__Criteria_Type__c = 'State' AND  ElixirSuite__Is_Active__c = true 
                               AND ElixirSuite__Value__c IN:lstOfPatientstate WITH SECURITY_ENFORCED];
        
        lstCertifiedPractitioners=[select Id,ElixirSuite__Practitioner__r.Name,ElixirSuite__Criteria_Type__c,ElixirSuite__Practitioner__c,
                                   ElixirSuite__Value__c,ElixirSuite__Practitioner__r.Id,ElixirSuite__Valid_from__c,ElixirSuite__Valid_To__c
                                   from  ElixirSuite__License_and_Certifications__c
                                   where ElixirSuite__Criteria_Type__c ='Certification' AND ElixirSuite__Is_Active__c = true AND
                                   ElixirSuite__Valid_from__c<TODAY AND ElixirSuite__Valid_To__c>TODAY AND 
                                   ElixirSuite__Value__c IN:lstOfPatientservices WITH SECURITY_ENFORCED];
        
        for(ElixirSuite__License_and_Certifications__c statelst:lstStatePractitioners){
            for(ElixirSuite__License_and_Certifications__c certificationlst: lstCertifiedPractitioners){
                if(statelst.ElixirSuite__Practitioner__r.id == certificationlst.ElixirSuite__Practitioner__r.id &&
                   lstOfPatientstate.contains(statelst.ElixirSuite__Value__c) && 
                   lstOfPatientservices.contains(certificationlst.ElixirSuite__Value__c)  
                  ){
                      setContactId.add(certificationlst.ElixirSuite__Practitioner__r.id);
                      
                  }
            }
        }
          
        list<contact> lstOfRecords = [Select Id,Name,(Select Id,ElixirSuite__Value__c,ElixirSuite__Criteria_Type__c from 
                                      ElixirSuite__License_and_Certifications__r where ElixirSuite__Criteria_Type__c ='Certification' ) 
                                      from Contact where  Id IN :setContactId WITH SECURITY_ENFORCED];
        
        for (Contact obj: lstOfRecords) {
            returnList.add(obj);       
        }   
        return returnList;       
    }
    
}