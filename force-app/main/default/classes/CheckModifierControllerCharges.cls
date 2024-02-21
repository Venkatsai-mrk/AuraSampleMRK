public with sharing class CheckModifierControllerCharges{
    //Assume EL and EB are coming from Medical coding screen - ids' as below
    //List<String> lstMedicalCodingModifiers = new List<String>{'a1I1m000001uVozEAE', 'a1I1m000001uVp4EAE'};
    
    //select customsettingModiferToBeconsidered from elixircustom;
    //if customsettingModiferToBeconsidered = false return;
    //List<String> lstModifiers, String strRefCPTCode
    public static masterWrapperRelated getTemplateProcedureForModifiers(Map<Id,List<String>> patientProcedureToModifiers,Map<Id,String> patientProcedureMap) {  
        //List<String> lstMedicalCodingModifiers = new List<String>{'a1I1m000001uVp4EAE'};
        //String strRefCPTCode1 = 'T1023';
        masterWrapperRelated wrpr = new masterWrapperRelated();
        Map<Id,List<String>> TemplateProcedureId = new Map<Id,List<String>>();
        Map<String,List<Id>> ReferralCode = new Map<String,List<Id>>();
        Map<Id,ElixirSuite__Procedure__c> idVsTemplateProcedure = new Map<Id,ElixirSuite__Procedure__c>();
        list<ElixirSuite__Procedure__c> finalTemplateProcedure = new list<ElixirSuite__Procedure__c>();
        Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();
        Map<String, ElixirSuite__Procedure__c>  templateProcToModifiers = new Map<String, ElixirSuite__Procedure__c>();
        if(mcs.ElixirSuite__Add_Modifiers_Feature__c==true){
            List<ElixirSuite__Procedure__c> lstTemplateProcedures = 
                [Select Id, name , ElixirSuite__Modifier1__c, ElixirSuite__Modifier2__c, ElixirSuite__Modifier3__c, ElixirSuite__Modifier4__c,
                 ElixirSuite__Modifier1__r.Name, ElixirSuite__Modifier2__r.Name,Reference_CPT_Code__c, ElixirSuite__Modifier3__r.Name, ElixirSuite__Modifier4__r.Name                             
                 from ElixirSuite__Procedure__c 
                 where RecordType.DeveloperName ='Template_Procedure' AND ElixirSuite__Code_Category__c!='Modifier'
                 And ElixirSuite__Reference_CPT_Code__c IN :patientProcedureMap.values() WITH SECURITY_ENFORCED];
            List<Id> tempProcIds = new List<Id>();
            for(ElixirSuite__Procedure__c tmeplateProc :lstTemplateProcedures){
                List<String> tempModifiers = new List<String>();
                String Key = tmeplateProc.Reference_CPT_Code__c;
                if(tmeplateProc.ElixirSuite__Modifier1__c!=null){
                  tempModifiers.add(tmeplateProc.ElixirSuite__Modifier1__c);
                }
                if(tmeplateProc.ElixirSuite__Modifier2__c!=null){
                    tempModifiers.add(tmeplateProc.ElixirSuite__Modifier2__c);
                }
                if(tmeplateProc.ElixirSuite__Modifier3__c!=null){
                    tempModifiers.add(tmeplateProc.ElixirSuite__Modifier3__c);
                }
                if(tmeplateProc.ElixirSuite__Modifier4__c!=null){
                     tempModifiers.add(tmeplateProc.ElixirSuite__Modifier4__c);
                }
                templateProcToModifiers.put(key, tmeplateProc);
                tempProcIds.add(tmeplateProc.Id);
                TemplateProcedureId.put(tmeplateProc.Id,tempModifiers);
                ReferralCode.put(tmeplateProc.Reference_CPT_Code__c,tempProcIds);
                idVsTemplateProcedure.put(tmeplateProc.Id,tmeplateProc);
            }
        }
        wrpr.TemplateProcedureId = TemplateProcedureId;
        wrpr.ReferralCode = ReferralCode;
        wrpr.idVsTemplateProcedure = idVsTemplateProcedure;
        
        return wrpr;
    }
    public class masterWrapperRelated {
       
        public Map<Id,List<String>> TemplateProcedureId;
        public Map<String,List<Id>> ReferralCode;
        public Map<Id,ElixirSuite__Procedure__c> idVsTemplateProcedure;
    }
}