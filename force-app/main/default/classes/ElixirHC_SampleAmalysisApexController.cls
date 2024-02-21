public with sharing class ElixirHC_SampleAmalysisApexController {
    @AuraEnabled
    public static wrapper getAccountDetails(String accountId , String sampleId) {
        Wrapper wrpr = new Wrapper();
        List<String> picklistValues = new List<String>();
        Map<String,List<String>> mapOfNameToField = new  Map<String,List<String>>();
        Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> object_fields_map = global_describe.get('ElixirSuite__Sample_Analysis__c').getDescribe().fields.getMap();
        try{
        for(Schema.SObjectField sfield : object_fields_map.values()){
            Schema.DescribeFieldResult dfield = sfield.getDescribe();
            if(String.valueof(dfield.getType())=='PICKLIST'){
                picklistValues = new List<String>();
                for(Schema.PicklistEntry pickListVal : dfield.getPicklistValues()){
                    picklistValues.add(String.valueOf(pickListVal.getLabel()));
                }             
                mapOfNameToField.put(dfield.getName(),picklistValues);
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        wrpr.mapOfNameToField = mapOfNameToField;
        //HealthCloudGA__MedicalRecordNumber__c
        List<Account> listOfAccount = [SELECT Id, Name, Age__c, DOB__c, Gender__c,Blood_Group__c,MRN_Number__c FROM Account
         WHERE Id= :accountId WITH SECURITY_ENFORCED];
        Contact con=[select Id,name,birthdate from contact where AccountId=:listOfAccount[0].id 
        WITH SECURITY_ENFORCED limit 1];
                                      
        Integer age ;
        try{
          if(con.birthdate!=null){
                Date birthdate1=con.birthdate;
                Integer days = birthdate1.daysBetween(Date.Today());
                age = Integer.valueOf(days/365);
          }
        
        List<User> listOfUsers = [SELECT Id, Name FROM User WITH SECURITY_ENFORCED];
        List<UA_Sample_Details__c> listOfSampleDetails = [SELECT Name,Name_of_container__c,Sample_Type__c, ContainerType__c, Container_Description__c, 
                                                          ContainerSize__c, Specimen_Quantity__c, Specimen_Condition__c,
                                                          Additives_if_Any__c, Notes__c, Collection_Datetime__c, Specimen_Collector__c,
                                                          Order_to__c, Order_By__c, Lab_Name__c, Lab_Code__c, Lab_Location__c,
                                                          Lab_email__c, Account__c, Comments__c FROM UA_Sample_Details__c
                                                          WHERE Id= :sampleId AND Sample_Type__c = 'Physical' WITH SECURITY_ENFORCED];
        if(listOfSampleDetails!=null && listOfSampleDetails.size()>0 ){
            wrpr.sampleDetails = listOfSampleDetails[0];
            List<Sample_Analysis__c> listOfPhysiSampleAnalysis = [SELECT Id, Name,Specimen_Status__c, Picklist__c, Appearance__c,
                                                                  Notes__c, Status__c, Comments__c, Examined_By__c, Bilesalt__c,Yeast_Cells__c,
                                                                  Examined_Datetime__c, Specific_Gravity__c, PH__c, Leukocyte__c,Spermatozoa__c,
                                                                  Protein__c, Urobilinogen__c, Glucose__c, Puss_Cells_W_B_C__c,Epithelial_Cells__c, 
                                                                  Bilrubin__c, Red_Cells_R_B_C__c, Mucus__c, Casts__c, Crystal__c,Colour__c,Ketone__c,
                                                                  Bacteria__c, Trichomonas__c, Schistosoma_Eggs__c, Type__c FROM Sample_Analysis__c
                                                                  WHERE UA_Sample_Details__c= :listOfSampleDetails[0].Id WITH SECURITY_ENFORCED]; 
            if(listOfPhysiSampleAnalysis!=null && listOfPhysiSampleAnalysis.size()>0 ){
                wrpr.physicalSampleAnalysis = listOfPhysiSampleAnalysis[0]; 
                List<UA_Sample_Details__c> listOfLabSampleDetails = [SELECT Sample_Type__c, Name_of_container__c,ContainerType__c, Container_Description__c, 
                                                                     ContainerSize__c, Specimen_Quantity__c, Specimen_Condition__c,UA_Sample_Details__c,
                                                                     Additives_if_Any__c, Notes__c, Collection_Datetime__c, Specimen_Collector__c,
                                                                     Order_to__c, Order_By__c, Lab_Name__c, Lab_Code__c, Lab_Location__c,
                                                                     Lab_email__c, Account__c, Comments__c FROM UA_Sample_Details__c
                                                                     WHERE UA_Sample_Details__c= :sampleId AND Sample_Type__c = 'Laboratory' WITH SECURITY_ENFORCED];
                if(listOfLabSampleDetails!=null && listOfLabSampleDetails.size()>0 ){
                    wrpr.labDetails = listOfLabSampleDetails[0];
                    List<Sample_Analysis__c> labAnalysis = [SELECT Id, Name, Specimen_Status__c, Picklist__c, Appearance__c,
                                                            Notes__c, Status__c, Comments__c, Examined_By__c, Bilesalt__c,Yeast_Cells__c,
                                                            Examined_Datetime__c, Specific_Gravity__c, PH__c, Leukocyte__c,Spermatozoa__c,
                                                            Protein__c, Urobilinogen__c, Glucose__c, Puss_Cells_W_B_C__c,Epithelial_Cells__c,Ketone__c, 
                                                            Bilrubin__c, Red_Cells_R_B_C__c, Mucus__c, Casts__c, Crystal__c,Colour__c,
                                                            Bacteria__c, Trichomonas__c, Schistosoma_Eggs__c, Type__c, Lab_Sample_Examined_Datetime__c FROM Sample_Analysis__c
                                                            WHERE UA_Sample_Details__c= :listOfLabSampleDetails[0].Id WITH SECURITY_ENFORCED]; 
                    if(labAnalysis!=null && labAnalysis.size()>0){
                        wrpr.labAnalysis = labAnalysis[0];
                    }    
                }                                      
                
            }                              
        }                               
        
        wrpr.accountRec = listOfAccount[0];
        wrpr.listOfUsers = listOfUsers;
        wrpr.patientAge = age ;
        wrpr.patientBirthdate = con.Birthdate ;
        wrpr.nameSpace = Elixir_Utility.getNamespace();
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    @AuraEnabled
    public static void saveDetails(Sample_Analysis__c physicalSampleAnalysis ,UA_Sample_Details__c labDetails ,
                                   Sample_Analysis__c labSampleAnalysis,String patientId,String emailOutSectionIdentifier,
                                   String stringifiedPhysicalSample,String stringifiedLabSample){
                                       try{
                                       if(physicalSampleAnalysis != null){
                                           DMLManager.upsertAsUser(physicalSampleAnalysis);   
                                       }
                                       if(labDetails != null){
                                           DMLManager.upsertAsUser(labDetails);
                                       }
                                       if(labSampleAnalysis != null){
                                           DMLManager.upsertAsUser(labSampleAnalysis);
                                       }
                                       if(emailOutSectionIdentifier=='PhysicalSampleAnalysis'){
                                           if(!String.isBlank(physicalSampleAnalysis.Id)) {
                                               if(physicalSampleAnalysis.Status__c=='Positive'){
                                                   ElixirHC_UAListViewController.sendPdfForUA('PhysicalAnalysis',physicalSampleAnalysis.Id,patientId,stringifiedPhysicalSample);
                                               }
                                           }
                                           
                                       }
                                       if(emailOutSectionIdentifier=='LabSampleAnalysis'){
                                           if(!String.isBlank(labSampleAnalysis.Id)) {
                                               if(labSampleAnalysis.Status__c=='Positive'){
                                                   ElixirHC_UAListViewController.sendPdfForUA('LabSampleAnalysis',labSampleAnalysis.Id,patientId,stringifiedLabSample);
                                               }
                                           }
                                       }
                                       
                                       
                                   }
                                       catch(Exception e){
                                     ExceptionLog.logError(e);
                                                }
                                   }
    public class wrapper{
        @AuraEnabled public Account accountRec;
        @AuraEnabled public UA_Sample_Details__c sampleDetails;
        @AuraEnabled public UA_Sample_Details__c labDetails;
        @AuraEnabled public Sample_Analysis__c physicalSampleAnalysis;
        @AuraEnabled public Sample_Analysis__c labAnalysis;
        @AuraEnabled public List<User> listOfUsers;
        @AuraEnabled public Map<String,List<String>> mapOfNameToField ;
        @AuraEnabled public integer patientAge ;
        @AuraEnabled public date patientBirthdate ;
        @AuraEnabled public String nameSpace ;
    }
}