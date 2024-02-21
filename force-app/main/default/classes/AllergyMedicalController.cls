public with sharing class AllergyMedicalController {
    
    Public class WrrprAllergiesAndMedical{
        @AuraEnabled public list<Medical_Examination__c> SkinAllergy{get;set;}
        @AuraEnabled public list<Medical_Examination__c> FoodAllergy{get;set;}
        @AuraEnabled public list<Medical_Examination__c> DrugAllergy{get;set;}
        @AuraEnabled public list<Medical_Examination__c> MedicalAlerts{get;set;}
    }
    @AuraEnabled
    public static WrrprAllergiesAndMedical getData(string accId){
        
            list<Medical_Examination__c> AllData = new list<Medical_Examination__c>();
            list<Medical_Examination__c> FoodAllergyData = new list<Medical_Examination__c>();
            list<Medical_Examination__c> SkinAllergyData = new list<Medical_Examination__c>();
            list<Medical_Examination__c> DrugAllergyData = new list<Medical_Examination__c>();
            list<Medical_Examination__c> MedicalAlertsData = new list<Medical_Examination__c>();
            AllData = [select id,name,Allergy_Name__c,Category__c,RecordType.Name,Alert_Name__c,Account__c FROM Medical_Examination__c 
                       where Account__c=:accId AND (Allergy_Name__c != Null OR Alert_Name__c != Null)
                       WITH SECURITY_ENFORCED];
            
            for(Medical_Examination__c i : AllData){
                try{
                if(i.RecordType.Name == 'Allergy' && i.Category__c == 'Food Allergy'){
                    FoodAllergyData.add(i); // Adding Allergy RecordType Data.                
                }
               }
                 catch(Exception e){
                 ExceptionLog.logError(e);
        }
                try{
                if(i.RecordType.Name == 'Allergy' && i.Category__c == 'Skin Allergy'){
                    SkinAllergyData.add(i); // Adding Allergy RecordType Data.                
                }
                }
                catch(Exception e){
                 ExceptionLog.logError(e);
        }
                try{
                if(i.RecordType.Name == 'Allergy' && i.Category__c == 'Drug Allergy'){
                    DrugAllergyData.add(i); // Adding Allergy RecordType Data.                
                }
                }
                catch(Exception e){
                 ExceptionLog.logError(e);
        }
                try{
                if(i.RecordType.Name == 'Medical Alerts'){
                    MedicalAlertsData.add(i); // Adding Allergy RecordType Data.
                }
            }
                 catch(Exception e){
                 ExceptionLog.logError(e);
        }
            }
            System.debug('MedicalAlertsData'+MedicalAlertsData);
            WrrprAllergiesAndMedical wrpr = new WrrprAllergiesAndMedical();
            wrpr.FoodAllergy=FoodAllergyData;
            wrpr.SkinAllergy=SkinAllergyData;
            wrpr.DrugAllergy=DrugAllergyData;
            wrpr.MedicalAlerts=MedicalAlertsData;
            return wrpr;
        }
        
    
    @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User
                               where Id =:currentUid WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
        System.debug('licence type '+AvailLicense);
        License_Class lCls = new License_Class();
        try{
            if(AvailLicense == 'Type of license - EHR')
            {
                lCls.isEhr = True;
                lCls.isRcm = False;
                lCls.isContactCenter = False;
            }
            else if(AvailLicense == 'Type of license - EPM')
            {
                lCls.isEhr = False;
                lCls.isRcm = False;
                lCls.isContactCenter = True;
            }
            else if(AvailLicense == 'Type of license - RCM')
            {
                lCls.isEhr = False;
                lCls.isRcm = True;
                lCls.isContactCenter = False;
            }
          }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return lCls;
       
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    } 
}
//