public with sharing class CheckModifierController {
    //Assume EL and EB are coming from Medical coding screen - ids' as below
    //List<String> lstMedicalCodingModifiers = new List<String>{'a1I1m000001uVozEAE', 'a1I1m000001uVp4EAE'};
    
    //select customsettingModiferToBeconsidered from elixircustom;
    //if customsettingModiferToBeconsidered = false return;
    
    public static ElixirSuite__Procedure__c[] getTemplateProcedureForModifiers(List<String> lstModifiers, String strRefCPTCode) {  
        //List<String> lstMedicalCodingModifiers = new List<String>{'a1I1m000001uVp4EAE'};
        //String strRefCPTCode1 = 'T1023';
        list<ElixirSuite__Procedure__c> finalTemplateProcedure = new list<ElixirSuite__Procedure__c>();
        Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();
        if(mcs.ElixirSuite__Add_Modifiers_Feature__c==true){
            List<ElixirSuite__Procedure__c> lstTemplateProcedures = 
                [Select Id, name , ElixirSuite__Modifier1__c, ElixirSuite__Modifier2__c, ElixirSuite__Modifier3__c, ElixirSuite__Modifier4__c,
                 ElixirSuite__Modifier1__r.Name, ElixirSuite__Modifier2__r.Name, ElixirSuite__Modifier3__r.Name, ElixirSuite__Modifier4__r.Name                             
                 from ElixirSuite__Procedure__c 
                 where RecordType.DeveloperName ='Template_Procedure' AND ElixirSuite__Code_Category__c!='Modifier'
                 And ElixirSuite__Reference_CPT_Code__c = :strRefCPTCode WITH SECURITY_ENFORCED];
            System.debug('All Template Procs ' + lstTemplateProcedures);
            System.debug('Actual Modifiers' + lstModifiers);
            
            List<String> idsModifiers = new List<String>();
          
            
            for( ElixirSuite__Procedure__c objProcedure: lstTemplateProcedures) {
                  Integer matchingCount = 0;
                idsModifiers.clear();
                if(objProcedure.ElixirSuite__Modifier1__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier1__c);
                if(objProcedure.ElixirSuite__Modifier2__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier2__c);
                if(objProcedure.ElixirSuite__Modifier3__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier3__c);
                if(objProcedure.ElixirSuite__Modifier4__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier4__c);
                system.debug(objProcedure.name + ' ===> ' + idsModifiers);
                
                //Check the size first and remove unwanted template proc records
                if(idsModifiers.size() != lstModifiers.size()) {
                    system.debug('There is no matching template procedure code since size itself is different move on!');
                    continue;
                }
                else system.debug('This template proc might match - check out!');
                
                //Find how many matching modifiers are present
                for (String strModifier : lstModifiers) {
                    if(idsModifiers.contains(strModifier)){
                        matchingCount = matchingCount + 1;
                            }
                }
                if (matchingCount != lstModifiers.size()) system.debug('Size might match. But, there is no matching provider that has these modifiers.');
                if (matchingCount == lstModifiers.size()) {
                    system.debug('Size also matches. Matching count also matches.  This is the right template Procedure');
                    finalTemplateProcedure.add(objProcedure);
                    System.debug('The final template procedure decided is ' + finalTemplateProcedure[0].Name);
                    break;
                }
            }
        }else{
            finalTemplateProcedure = null;  
        }
        return finalTemplateProcedure; 
    }
    
    
}