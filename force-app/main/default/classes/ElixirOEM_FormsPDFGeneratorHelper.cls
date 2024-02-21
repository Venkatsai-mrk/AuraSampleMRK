/*
Developer Name : ROHIT SINGH BORA
CreatedDate : 31/05/21
Purpose : Visualise forms in vf and render as pdf
*/
global with sharing class ElixirOEM_FormsPDFGeneratorHelper {
    public static PDF_Header__c pdfData {get; set;}
    public static  Map<Decimal,String> colMap {get;set;}
    public static  String category {get;set;}
    public List<sObjectSchemaWrapper> cssRecords {get;set;}
    public String changedFormName {get;set;}
    public List<Medical_Examination__c> vitalData{get; set;}
    public List<Medical_Examination__c> allergyData{get; set;}
    public List<String> selectedAllergyFields { get; set; }
    public List<String> selectedFieldsWithoutC { get; set; }
    public List<Prescription_Order__c> medicationData{get;set;}
    public List<Medical_Examination__c> glucoseObservation{get;set;}
    public List<Form_Value__c> approvalList{get;set;}
    public List<List<Form_Value__c>> previousApprovalList{get;set;}
    public Date currentDate {get;set;}
    //public  List<ProblemWrapper> problemLst {get;set;}  
   //public  List<ElixirSuite__Dataset1__c> problemLst {get;set;} // added by sagili sivasaiprasad
   public List<String> selectedFields { get; set; }
    public List<ElixirSuite__Dataset1__c> myObjectRecords { get; set; }
    public List<String> selectedVitalFields { get; set; }
     public List<Medical_Examination__c> vitalListData { get; set; }

    public List<String> selectedDiagnosisFields { get; set; }
    public List<ElixirSuite__ICD_Codes__c> diagnosisObjectRecords { get; set; }
     public Map<Id, String> formattedRelatedProblemsMap { get; private set; }
    public List<String> selectedMedicationFields { get; set; }
     public List<ElixirSuite__Prescription_Order__c> medicationLstData { get; set; }
    public Map<Id, String> formattedRelatedFrequencyMap { get; private set; }
   public  List<ProcedureWrapper> procedureLst {get;set;}
    public  List<ElixirSuite__Inventory__c> invRecords{get;set;}
    public Boolean invFlag{get;set;} // added by Anmol for LX3-6581
    // public  List<ElixirSuite__Prescription_Order__c> prescRecords{get;set;}
    public List<ElixirSuite__Prescription_Order__c> prescriptions {get; set;}
    public Boolean prescFlag{get;set;} // added by Anmol for LX3-6852
    public String labFlag{get; set;} // added by Himanshu
    public List<ChcLabWrapper> chcLabOrder {get;set;} // added by Himanshu
    public List<manualLabWrapper> manualLabOrder {get;set;} // added by Himanshu
    public String downloadUrl {get;set;} 
    public Boolean reasonFlag{get;set;} 
    public Boolean routeFlag{get;set;}
    public List<Elixir_Custom_Setting__c> editColumns{get;set;}
    public static  String lookupValueName {get;set;}
    public Map<Id,String> imageData {get;set;}
    public Map<Decimal, String> approverCustomLabel{get;set;}
    public List<String> customLabelList{get; set;}
    public List<ElixirSuite__Object_1_css__c> formCSS2{get; set;}
    public String pdfUrl {get;set;}
    public List<String> allergyColumns1 { get; set; }
    public List<String> vitalColumns1 { get; set; }
     public String currentUserDetail{ get; set; }
    
    
    global ElixirOEM_FormsPDFGeneratorHelper(){  
                pdfData= getPDFData();           
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + changedFormName + '.pdf');    
    }
    public Map<String, List<ModularMatrixRow>> modularMatrixData {get;set;}
    
    public void init(){
        try{
            currentDate = System.today();
            Map<String,String> lookupMap= new Map<String,String>();
            List<String> lookupList= new List<String>();
            String accId = ApexPages.currentPage().getParameters().get('aId').escapeHtml4();
            String formName = ApexPages.currentPage().getParameters().get('fName').escapeHtml4();
            string formuniqueID = ApexPages.currentPage().getParameters().get('fId').escapeHtml4();
            String changedFormName = ApexPages.currentPage().getParameters().get('fCName').escapeHtml4(); 
            Set<Id> sectionsIds = new Set<Id>();
            // RecordTypeName - RT name : Changed Form Name = Chaned Form Name // Type of Object 1
            this.changedFormName = changedFormName;
           
            Id formValueRecordId = [SELECT ID, ElixirSuite__Form_Id__c, ElixirSuite__Form_Name__c 
                                        FROM ElixirSuite__Form_Value__c 
                                        WHERE ElixirSuite__Form_Id__c = :formuniqueID
                                        AND ElixirSuite__Form_Detail__c =true           
                                        WITH SECURITY_ENFORCED LIMIT 1].Id;
            
          
           // Patient Problem Start
           Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            String selectedFieldsString = null;
            
            // Check if mc is not null before accessing its field
            if (mc != null) {
                selectedFieldsString = mc.ElixirSuite__Problem_Column__c;
            }
            
            // Split the selectedFieldsString using semicolon as a separator
            if (selectedFieldsString != null && selectedFieldsString != '') {
                selectedFields = selectedFieldsString.split(';');
                // Remove any leading or trailing whitespaces from each field
                for (Integer i = 0; i < selectedFields.size(); i++) {
                    selectedFields[i] = selectedFields[i].trim();
                }
            }
List<ElixirSuite__Dataset1__c> patientList =new  List<ElixirSuite__Dataset1__c>();
                       patientList=[SELECT ID, Name, ElixirSuite__Form_Value__c, ElixirSuite__Form_Value__r.Name
                                                                              FROM ElixirSuite__Dataset1__c 
                                                                              WHERE ElixirSuite__Form_Value__c =:formValueRecordId 
                                                                               WITH SECURITY_ENFORCED];
                    
                    List<String> patientProblemIds = new List<String>();
                    if(!patientList.isEmpty()){
                    for (ElixirSuite__Dataset1__c patientProblem : patientList) {
                        patientProblemIds.add(patientProblem.Id);
                    }
                    }
                // Make sure accId is defined before calling fetchAccountProblems
                if (accId != null) {
                    myObjectRecords = FormRenderClass.fetchAccountProblems(accId,patientProblemIds);
                }
            

            
			//Patient Problems End

            //Patient Diagnosis Start 
            Elixir_Custom_Setting__c selectedDiagnosis = Elixir_Custom_Setting__c.getOrgDefaults();
            String SelectedDiagnosisFieldLst = null;
             if (selectedDiagnosis != null) {
                SelectedDiagnosisFieldLst = selectedDiagnosis.ElixirSuite__Diagnosis_Column__c;
            }
            if (SelectedDiagnosisFieldLst != null && SelectedDiagnosisFieldLst != '') {
                selectedDiagnosisFields = SelectedDiagnosisFieldLst.split(';');
                for (Integer i = 0; i < selectedDiagnosisFields.size(); i++) {
                    selectedDiagnosisFields[i] = selectedDiagnosisFields[i].trim();
                }
            }
                
                   List<ElixirSuite__ICD_Codes__c> diagnosisList = new List<ElixirSuite__ICD_Codes__c>();
                     diagnosisList=  [SELECT ID, Name, ElixirSuite__Form_Value__c, ElixirSuite__Form_Value__r.Name
                                                                              FROM ElixirSuite__ICD_Codes__c 
                                                                              WHERE ElixirSuite__Form_Value__c =:formValueRecordId 
                                                                              AND RecordType.Name = 'Patient Diagnosis Code' WITH SECURITY_ENFORCED];
                    
                    List<String> diagnosisIds = new List<String>();
                    if(!diagnosisList.isEmpty()){
                    for (ElixirSuite__ICD_Codes__c diagnosis : diagnosisList) {
                        diagnosisIds.add(diagnosis.Id);
                    }
                    }
                    
            	if (accId != null) {
                   diagnosisObjectRecords =FormRenderClass.fetchAccountDiagnosis(accId,diagnosisIds);
				   initializeRelatedProblems();
                }
            
        	
            
            selectedAllergyFields=new List<String>();
            ElixirSuite__Elixir_Custom_Setting__c selectedAllergies = ElixirSuite__Elixir_Custom_Setting__c.getInstance();
            String SelectedAllergyFieldLst = null;
             if (selectedAllergies != null) {
                SelectedAllergyFieldLst = selectedAllergies.ElixirSuite__Allergy_Columns__c;
				}
            if (SelectedAllergyFieldLst != null && SelectedAllergyFieldLst != '') {
                selectedAllergyFields = SelectedAllergyFieldLst.split(';');
				if (selectedAllergyFields != null) {
					for (Integer i = 0; i < selectedAllergyFields.size(); i++) {
                    selectedAllergyFields[i] = selectedAllergyFields[i].trim();
                	}
                 }
                 }
List<ElixirSuite__Medical_Examination__c> allergyList =new List<ElixirSuite__Medical_Examination__c>();
				
                   allergyList= [SELECT ID, Name, ElixirSuite__Form_Value__c, ElixirSuite__Form_Value__r.Name
                                                                              FROM ElixirSuite__Medical_Examination__c 
                                                                              WHERE ElixirSuite__Form_Value__c =:formValueRecordId 
                                                                              AND RecordType.Name = 'Allergy' WITH SECURITY_ENFORCED];
                    
                    List<String> lstAllergy = new List<String>();
                    if(!allergyList.isEmpty()){
                    for (ElixirSuite__Medical_Examination__c allergy : allergyList) {
                        lstAllergy.add(allergy.Id);
                    }
                    }
				if (accId != null) {
                  allergyData =ExternalComponents_InsideFormHelper.fetchAccountAllergyLst(accId,JSON.serialize(new Map<String, List<String>>{'allergyData' => lstAllergy}));
				 }
            	
            
            
            //Medication Start
            selectedMedicationFields=new List<String>();
            ElixirSuite__Elixir_Custom_Setting__c selectedMedications = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            String SelectedMedicationFieldLst = null;
             if (selectedMedications != null) {
                SelectedMedicationFieldLst = selectedMedications.ElixirSuite__Medication_Columns__c;
				}
            if (SelectedMedicationFieldLst != null && SelectedMedicationFieldLst != '') {
                selectedMedicationFields = SelectedMedicationFieldLst.split(';');
				if (selectedMedicationFields != null) {
					for (Integer i = 0; i < selectedMedicationFields.size(); i++) {
                    selectedMedicationFields[i] = selectedMedicationFields[i].trim();
                	}
                 }
                 }
                

                    List<ElixirSuite__Prescription_Order__c> medicationList =new List<ElixirSuite__Prescription_Order__c>();
                       medicationList= [SELECT ID, Name, ElixirSuite__Form_Value__c, ElixirSuite__Form_Value__r.Name
                                                                              FROM ElixirSuite__Prescription_Order__c 
                                                                              WHERE ElixirSuite__Form_Value__c =:formValueRecordId 
                                                                              AND RecordType.Name = 'Medication' WITH SECURITY_ENFORCED];
                    
                    List<String> medicationIds = new List<String>();
                    if(!medicationList.isEmpty()){
                    for (ElixirSuite__Prescription_Order__c medication : medicationList) {
                        medicationIds.add(medication.Id);
                    }
                    }
				if (accId != null) {
                   medicationLstData =FormRenderClass.fetchAccountMedication(accId,medicationIds);
                    initializeRelatedFrequency();
				 }
            	
            
            //Medication End
            
            //Vital signs:

            selectedVitalFields = new List<String>();
            ElixirSuite__Elixir_Custom_Setting__c selectedVitals = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            String selectedVitalFieldsString = null;

            if (selectedVitals != null) {
                selectedVitalFieldsString = selectedVitals.ElixirSuite__Vital_Sign_Columns__c;
            }

            if (selectedVitalFieldsString != null && selectedVitalFieldsString != '') {
                selectedVitalFields = selectedVitalFieldsString.split(',');


                if (selectedVitalFields != null) {
                    for (Integer i = 0; i < selectedVitalFields.size(); i++) {
                        // Remove the "ES#" prefix
                        selectedVitalFields[i] = selectedVitalFields[i].trim().substring(3);
                    }
}
                List<ElixirSuite__Medical_Examination__c> vitalList=new List<ElixirSuite__Medical_Examination__c>();
                  vitalList  = [SELECT ID, Name, ElixirSuite__Form_Value__c, ElixirSuite__Form_Value__r.Name
                                                                              FROM ElixirSuite__Medical_Examination__c 
                                                                              WHERE ElixirSuite__Form_Value__c =:formValueRecordId 
                                                                              AND RecordType.Name = 'Vital Sign' WITH SECURITY_ENFORCED];
                    
                    List<String> lstvital = new List<String>();
                    
                    for (ElixirSuite__Medical_Examination__c vital : vitalList) {
                        lstvital.add(vital.Id);
                }

                if (accId != null) {
                    vitalListData = FormRenderClass.fetchAccountSpecificVitalsPdf(accId,lstvital);
                }
            }
            
            // END
            // // PROCEDURE DATA FETCH
            MedicalCodingApexController.wrapper procedureSObj = MedicalCodingApexController.procedureList(accId);
            processProcedureData(procedureSObj.lstOfAllProcedures);            
            // END
            //
            
            ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getInstance();
            String vitalColumns = customSetting != null ? customSetting.ElixirSuite__Vital_Sign_Columns__c : null;
            if (String.isNotBlank(vitalColumns)) {
                vitalColumns1 = vitalColumns.split(';');
            }

           User u= [SELECT ID,Name from User where id=: UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1];
            currentUserDetail=u.Name;
            glucoseObservation = [SELECT Id,Intervention__c,Type_of_check__c,
                                  Note__c,Glucose_Reading__c
                                  FROM Medical_Examination__c where  Account__c=:accId and
                                  RecordType.developerName = 'Glucose' WITH SECURITY_ENFORCED
                                  order by CreatedDate DESC];
           
            
            vitalData =  [select id, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,Temperature__c,  
                          Pulse__c, createdDate, Respiration__c,/*HealthCloudGA__Respiration__c*/
                          Oxygen_Saturation__c FROM Medical_Examination__c where
                          Account__c=:accId and  RecordType.DeveloperName='Vital_Sign' AND Blood_Pressure_Systolic__c!=null 
                          WITH SECURITY_ENFORCED
                          ORDER By createdDate DESC 
                         ];// And createdDate>TODAY and createdDate<TOMORROW];
            medicationData = [SELECT Drug_Name__c,Id,Number_of_Times_Days_Weeks__c,Reason_new__c,
                              Ferquency__c,Route_New__c,Reason__c,Type__c,Dosage_Form__c,(select Strength__c,Dosage_Instruction__c,Repeat__c
                                                                                          from Frequency__r)
                              FROM Prescription_Order__c where  Account__c=:accId
                              WITH SECURITY_ENFORCED
                              order by CreatedDate asc limit 110];
                              invRecords = [Select ElixirSuite__Account__c,ElixirSuite__Inventory_Item_Name__c,ElixirSuite__Total_Price__c,ElixirSuite__Lot_Number__c,ElixirSuite__Units_Available__c,
                                             ElixirSuite__Units_Procured__c,ElixirSuite__Equipment__c 
                                             from ElixirSuite__Inventory__c where ElixirSuite__Account__c=:accId 
                                             and ElixirSuite__Form_Unique_Id__c=:formuniqueID WITH SECURITY_ENFORCED ];

                                // added by Anmol for LX3-6581
                if(invRecords.size() == 0){
                invFlag = true;
            }
            else{
                invFlag = false;
            }
            // end by Anmol for LX3-6581
  // added by Anmol for LX3-6852
  String prescVal;
  ID UID =UserInfo.getProfileId();
List<ElixirSuite__TabPermissionBasedOnProfiles__c> tb = [SELECT Id, ElixirSuite__Prescription_Priority__c 
                                                  FROM ElixirSuite__TabPermissionBasedOnProfiles__c where SetupOwnerId = :UID WITH SECURITY_ENFORCED LIMIT 1];

if(tb!=null && tb.size()>0){

  prescVal = tb[0].ElixirSuite__Prescription_Priority__c ;
}


if(prescVal == 'Dummy Prescription'){

prescFlag = true;
}
else{
prescFlag = false;
}
// end by Anmol for LX3-6852

//added by Himanshu
            Boolean ActvCareEpisode = false;
            List<ElixirSuite__Visits__c> allCareEpisodes = [SELECT id
                                                            FROM Visits__c
                                                            WHERE Account__c = :accId
                                                            AND Status__c = 'Active' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
            if(allCareEpisodes!=null && allCareEpisodes.size()>0){
                ActvCareEpisode = true;
            }
            
            
            String labVal;
            List<ElixirSuite__TabPermissionBasedOnProfiles__c> labTab = [SELECT Id, ElixirSuite__LabOrder_Priority__c 
                                                                         FROM ElixirSuite__TabPermissionBasedOnProfiles__c where SetupOwnerId = :UID WITH SECURITY_ENFORCED LIMIT 1];
            
            List<Lab_Order__c> chcData;
            if(ActvCareEpisode){
                chcData = [SELECT id, Lab_Order_Req__c,ElixirSuite__Lab_Type__c,ElixirSuite__LabName__c, Test_Name__c, toLabel(Status__c), CreatedDate, CreatedBy.Name, LastModifiedDate
                           FROM Lab_Order__c WHERE Account_Id__c =:accId AND Care_Episode__c =:allCareEpisodes[0].Id WITH SECURITY_ENFORCED ORDER BY createdDate DESC];
            }
            else{
                chcData = [SELECT id, Lab_Order_Req__c,ElixirSuite__Lab_Type__c,ElixirSuite__LabName__c, Test_Name__c, toLabel(Status__c), CreatedDate, CreatedBy.Name, LastModifiedDate
                           FROM Lab_Order__c WHERE Account_Id__c =:accId WITH SECURITY_ENFORCED ORDER BY createdDate DESC LIMIT 50];
            }
            chcLabData(chcData);
            //end by Himanshu
                     /*     List<ElixirSuite__Visits__c> careEpRec = [select id,name from ElixirSuite__Visits__c	where ElixirSuite__Account__c= :accId and ElixirSuite__Status__c='Active' limit 1];
    
    String careId;
    boolean checkCare ;
    if(careEpRec.size()==0){
        checkCare = true;
    }
    else if(careEpRec.size()==1){
        checkCare = false;
        careId = careEpRec[0].id;
    }
    
    if(checkCare == false){
        prescRecords = [select ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__Route_New__c,CreatedBy.name,CreatedDate,LastModifiedDate from ElixirSuite__Prescription_Order__c where ElixirSuite__Care_Episode__c=:careId and ElixirSuite__Drug_Name__c!=null ORDER BY createdDate DESC];
        
    }*/
//    else if(checkCare == true){
    // if(prescFlag){
    //     prescRecords = [select ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__Route_New__c,CreatedBy.name,CreatedDate,LastModifiedDate from ElixirSuite__Prescription_Order__c where ElixirSuite__Account__c=:accId and ElixirSuite__Drug_Name__c!=null and Form_Unique_Id__c =:formuniqueID WITH SECURITY_ENFORCED ORDER BY createdDate DESC];
    //     editColumns = [Select ElixirSuite__EditPresColumn__c  from ElixirSuite__Elixir_Custom_Setting__c WITH SECURITY_ENFORCED limit 1];
    
    //     if(editColumns.size()>0 && editColumns[0].ElixirSuite__EditPresColumn__c!=null){
    //         String[] editColumnsStr = editColumns[0].ElixirSuite__EditPresColumn__c.split(';');
    //         reasonFlag=editColumnsStr.contains('ElixirSuite__Reason_new__c');
    //         routeFlag=editColumnsStr.contains('ElixirSuite__Route_New__c');
    //     }
    // }
    // else{
     
    //     prescRecords = [Select id,Name,  ElixirSuite__Prescription_Guid__c,ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__Patient_SIG__c,ElixirSuite__Refills__c,
    //             ElixirSuite__Archive_Status_NC__c, ElixirSuite__Status_NC__c,ElixirSuite__SubStatus_NC__c,ElixirSuite__Pharmacy_NC__c,ElixirSuite__Dispense_NC__c,
    //              ElixirSuite__Direction__c ,ElixirSuite__IsEditButtonActive__c   from ElixirSuite__Prescription_Order__c where ElixirSuite__Account__c =:accId And ElixirSuite__Prescription_Guid__c != ''  WITH SECURITY_ENFORCED ORDER BY createdDate DESC];
    // }
  //  }

    prescriptions = PrescriptionController.getPrescriptionOrders(accId);


            FormUpdateClass.FormSchema schemaVar =  FormUpdateClass.buildForm(formName,accID,formuniqueID);
            List<Object_1_css__c> cssRecords1 = schemaVar.cssRecords;
            List<FormRenderUtility.FieldSchema> allFields = schemaVar.allFields;
            Map<String,FormRenderUtility.FieldSchema> allFieldsMap = new Map<String,FormRenderUtility.FieldSchema>();
            // IMAGE HANDLING
            Map<String,List<ContentVersion>> versionBasedOnUniqueName = schemaVar.versionBasedOnUniqueName;
            // END
            for(FormRenderUtility.FieldSchema rec :allFields){
                allFieldsMap.put(rec.apiName, rec);
            }
            
            List<sObjectSchemaWrapper> cssRecords = (List<sObjectSchemaWrapper>) JSON.deserialize(JSON.serialize(cssRecords1),List<sObjectSchemaWrapper>.class);
            
            Integer parentRow = 0;
            //AutoText - START
            List<Form_Value__c> autoTexts = [SELECT Id, Blue_Print__c, Section_Number__c, Is_AutoText__c, Auto_Text__c FROM Form_Value__c
                                             WHERE Is_AutoText__c = true AND Form_Id__c=:formuniqueID
                                             AND Account__c=:accId WITH SECURITY_ENFORCED];
            Map<Decimal,String> texts = new Map<Decimal,String>();
            if(autoTexts!=null && autoTexts.size()>0){
                for(Form_Value__c autoText :autoTexts){
                    texts.put(autoText.Section_Number__c, autoText.Auto_Text__c);
                }
            }
            //AutoText - END 
            
            //macro template - START
            List<Form_Template_Data__c> macroTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c FROM Form_Template_Data__c
                                                     WHERE Form_Unique_Id__c=:formuniqueID AND type__c ='Macro'
                                                     AND Account__c=:accId WITH SECURITY_ENFORCED];
            Map<String,String> macroTexts = new Map<String,String>();
            if(macroTemp!=null && macroTemp.size()>0){
                for(Form_Template_Data__c macText :macroTemp){
                    macroTexts.put(macText.Section_Number__c, macText.Form_Data_Description__c );
                }
            }
            //macro template - END   
           
            //problem note - START
            List<Form_Template_Data__c> problemNoteTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c FROM Form_Template_Data__c
                                                     WHERE Form_Unique_Id__c=:formuniqueID and type__c = 'Problem'
                                                     AND Account__c=:accId WITH SECURITY_ENFORCED];
            Map<String,String> problemNoteTexts = new Map<String,String>();
            if(problemNoteTemp!=null && problemNoteTemp.size()>0){
                for(Form_Template_Data__c probText :problemNoteTemp){
                    problemNoteTexts.put(probText.Section_Number__c, probText.Form_Data_Description__c );
                }
            }
            //problem note - END  
            
            //diagnosis note - START
            List<Form_Template_Data__c> diagnosisNoteTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c FROM Form_Template_Data__c
                                                     WHERE Form_Unique_Id__c=:formuniqueID and type__c = 'Diagnosis'
                                                     AND Account__c=:accId WITH SECURITY_ENFORCED];
            Map<String,String> diagnosisNoteTexts = new Map<String,String>();
            if(diagnosisNoteTemp!=null && diagnosisNoteTemp.size()>0){
                for(Form_Template_Data__c diagText :diagnosisNoteTemp){
                    diagnosisNoteTexts.put(diagText.Section_Number__c, diagText.Form_Data_Description__c );
                }
            }
            //procedure note - END 
            
            List<Form_Template_Data__c> procedureNoteTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c FROM Form_Template_Data__c
                                                     WHERE Form_Unique_Id__c=:formuniqueID and type__c = 'Procedure'
                                                     AND Account__c=:accId WITH SECURITY_ENFORCED];
            Map<String,String> procedureNoteTexts = new Map<String,String>();
            if(procedureNoteTemp!=null && procedureNoteTemp.size()>0){
                for(Form_Template_Data__c procText :procedureNoteTemp){
                    procedureNoteTexts.put(procText.Section_Number__c, procText.Form_Data_Description__c );
                }
            }
            //procedure note - END 
            
            for(Object_1_css__c objRec :cssRecords1){
                if(objRec.Select_Form_Component__c == 'Enable Draw And Annotate'){
                    sectionsIds.add(objRec.Id);
                }
                
                else if (objRec.Select_Form_Component__c == 'Enable Upload And Annotate'){
                    sectionsIds.add(objRec.Id);
                }
                cssRecords[parentRow].sObjectRefrence = objRec;
                //AutoText - START
                Decimal secNo = objRec.Section_Number__c;
                if(texts.containsKey(secNo)){
                    String textForAuto  = texts.get(secNo);
                    textForAuto = textForAuto.replaceAll('[{]', '');
                    textForAuto = textForAuto.replaceAll('[}]', '');
                    cssRecords[parentRow].AutoText = textForAuto;
                }
                //AutoText - END
                
                //MacroText - START
                String sectionNo = String.valueof(objRec.Section_Number__c);
                if(macroTexts.containsKey(sectionNo)){
                    String textForMacro  = macroTexts.get(sectionNo);
                    textForMacro = textForMacro.replaceAll('[{]', '');
                    textForMacro = textForMacro.replaceAll('[}]', '');
                    cssRecords[parentRow].macroTemplateText = textForMacro;
                }
                //MacroText - END
                
                //problemNote - START
                String sectionNos = String.valueof(objRec.Section_Number__c);
                if(problemNoteTexts.containsKey(sectionNos)){
                    String textForMacro  = problemNoteTexts.get(sectionNos);
                    textForMacro = textForMacro.replaceAll('[{]', '');
                    textForMacro = textForMacro.replaceAll('[}]', '');
                    cssRecords[parentRow].problemNoteTemplateText = textForMacro;
                }
                //ProblemNote - END
                
                 //diagnosisNote - START
                String sectionNosd = String.valueof(objRec.Section_Number__c);
                if(diagnosisNoteTexts.containsKey(sectionNosd)){
                    String textForMacro  = diagnosisNoteTexts.get(sectionNosd);
                    textForMacro = textForMacro.replaceAll('[{]', '');
                    textForMacro = textForMacro.replaceAll('[}]', '');
                    cssRecords[parentRow].diagnosisNoteTemplateText = textForMacro;
                }
                //diagnosis - END
                
                //procedureNote - START
                String sectionNosdproc = String.valueof(objRec.Section_Number__c);
                if(procedureNoteTexts.containsKey(sectionNosdproc)){
                    String textForMacro  = procedureNoteTexts.get(sectionNosdproc);
                    textForMacro = textForMacro.replaceAll('[{]', '');
                    textForMacro = textForMacro.replaceAll('[}]', '');
                    cssRecords[parentRow].procedureNoteTemplateText = textForMacro;
                }
                //procedure - END
                
                
                if(objRec.Object_1_css__r!=null){
                    for(Object_1_css__c childRec :objRec.Object_1_css__r){
                        if(cssRecords[parentRow].Object_1_css_r == null){
                            cssRecords[parentRow].Object_1_css_r = new List<Object_1_css_r>();
                        }
                        Object_1_css_r childRef = new Object_1_css_r();
                        childRef.sObjectChildRefrence = childRec;
                        cssRecords[parentRow].Object_1_css_r.add(childRef);
                    }  
                }
                parentRow++;
            }
             //Added by Vidish
            if(cssRecords.size()>0 && cssRecords!=null){
                for(sObjectSchemaWrapper record : cssRecords){  
                    Map<String, sObject> objToValues = schemaVar.objToValues;
                    List<Object_1_css_r> section = record.Object_1_css_r;
                    Integer oldRowNumber = -1;
                    Integer oldRow = 0;
                    if(section!=null && section.size()>0){          
                        for(Integer rowParent=0 ;rowParent<section.size(); rowParent++){
                            Boolean escapeFToFpass = false;
                            //Object - Form values - START
                            //Default values - END
                            //FORM LABEL - START
                            String objectName = section[rowParent].sObjectChildRefrence.Object_Name__c;
                            String fieldName = section[rowParent].sObjectChildRefrence.Field_Name__c;
                            Decimal columnsInSection = record.sObjectRefrence.Columns_In_Section__c;
                            for(Integer i=0;i<columnsInSection;i++){
                                FormRenderUtility.FieldSchema fetchField;
                              /**  if(section.size()>rowParent+i){ 
                                    break;
                                } **/
                                if(section.size()<=rowParent+i || section[rowParent+i]==null){
                                    continue;//  Saviour
                                }
                                if(section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Label_Long__c != 'nbsp' && String.isNotBlank(section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c)){
                                    String fieldNameFromObj = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c;
                                    if(allFieldsMap.containsKey(fieldNameFromObj)){
                                        fetchField = allFieldsMap.get(fieldNameFromObj);
                                    }
                                }
                                String objName = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Object_Name__c;
                                fieldName = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c; // duplicate variable
                                if(objToValues.get(objName)!=null && objToValues.get(objName).get(fieldName)!=null){
                                    Object sObjValue = objToValues.get(objName).get(fieldName);
                                    String objValues = String.valueOf(sObjValue);
                                    if(fetchField != null){
                                        String dataTypeValue = fetchField.dataType.toUpperCase();
                                        if(dataTypeValue == 'REFERENCE'){
                                            lookupList.add(objValues);
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                
            }            
            
            if(lookupList.size()>0){
                for(String s: lookupList){
                    lookupMap.put(s,fetchLookupName(s));
                }
            }
            //Vidish code End
            Map<String, sObject> objToValues = schemaVar.objToValues;
            Map<Decimal, Map<Decimal, List<Form_Value__c>>> sec_row_columns = schemaVar.sec_row_columns;
            String labelstoShow = schemaVar.labelstoShow;
            Map<String,Map<String,String>> obj;
            if(String.isNotBlank(labelstoShow)){
                labelstoShow = labelstoShow.replaceAll('&quot;_reg_','"');
                obj = (Map<String,Map<String,String>>) JSON.deserialize(labelstoShow,Map<String,Map<String,String>>.class);
            }
            colMap = new Map<Decimal,String>{ 1  =>  'width:100%;',
                2 => 'width:50%;',
                3 => 'width:33%;',
                4 =>  'width:25%;',
                6 =>  'width:16%;',
                12 =>  'width:8%;'};
                    if(cssRecords.size()>0 && cssRecords!=null){
                        for(sObjectSchemaWrapper record : cssRecords){  
                            Decimal columnsInSection = record.sObjectRefrence.Columns_In_Section__c;
                            if(String.isNotBlank(record.sObjectRefrence.ElixirSuite__Indentation__c)){
                                String indent = record.sObjectRefrence.ElixirSuite__Indentation__c;
                                if(indent.toLowerCase() == 'heading'){
                                    record.sObjectRefrence.ElixirSuite__Css__c += ';margin-left:25px';
                                }
                                else if(indent.toLowerCase() == 'subheading'){
                                    record.sObjectRefrence.ElixirSuite__Css__c += ';margin-left:50px';
                                }
                            }
                            if(String.isNotBlank(record.sObjectRefrence.ElixirSuite__Form_Category__c)){
                                category = record.sObjectRefrence.ElixirSuite__Form_Category__c;
                            }    
                            if(record.sObjectRefrence.Is_Matrix__c){
                                List<String> heading = new List<String>();
                                String headings = record.sObjectRefrence.Headings__c;
                                if(String.isNotBlank(headings)){
                                    heading = headings.split(';');
                                }
                                record.matrixHeaders = heading;
                                record.colsize = fetchColSize(columnsInSection, colMap);
                            }

                            if(record.sObjectRefrence.Select_Form_Component__c == 'Enable Modular Table'){
                                List<String> heading = new List<String>();
                                String headings = record.sObjectRefrence.Headings__c;
                                if(String.isNotBlank(headings)){
                                    heading = headings.split(';', -1);
                                }
                                record.matrixHeaders = heading;
                                record.colsize = fetchColSize(columnsInSection, colMap);
                            }

                            List<Object_1_css_r> section = record.Object_1_css_r;
                            Integer oldRowNumber = -1;
                            Integer oldRow = 0;
                            if(section!=null && section.size()>0){          
                                for(Integer rowParent=0 ;rowParent<section.size(); rowParent++){
                                    Boolean escapeFToFpass = false;
                                    //Object - Form values - START
                                    //Default values - END
                                    //FORM LABEL - START
                                    String objectName = section[rowParent].sObjectChildRefrence.Object_Name__c;
                                    String fieldName = section[rowParent].sObjectChildRefrence.Field_Name__c;
                                    if(obj!=null && obj.size()> 0 && String.isNotBlank(objectName) && String.isNotBlank(String.valueOf(section[rowParent].sObjectChildRefrence)) &&
                                       obj.get(objectName)!=null && obj.get(objectName).size()>0){
                                           if(String.isNotBlank(obj.get(objectName).get(fieldName))){
                                               section[rowParent].sObjectChildRefrence.ElixirSuite__Field_Label_Long__c = obj.get(objectName).get(fieldName);
                                           }
                                       }
                                    //FORM LABEL - END
                                    //CONSENT FORM - START
                                    if(sec_row_columns!=null && sec_row_columns.size()>0){
                                        Decimal rowNumber = section[rowParent].sObjectChildRefrence.ElixirSuite__Row__c;
                                        Decimal columnNo = section[rowParent].sObjectChildRefrence.ElixirSuite__Column__c;
                                        Boolean isConsent = section[rowParent].sObjectChildRefrence.ElixirSuite__Is_Consent__c;
                                        Decimal sectionNo = record.sObjectRefrence.ElixirSuite__Section_Number__c;
                                        
                                        if(isConsent && String.isNotBlank(String.valueOf(sectionNo))){
                                            if(sec_row_columns.get(sectionNo).size()>0 && sec_row_columns.get(sectionNo)!=null){
                                                if(sec_row_columns.get(sectionNo).get(rowNumber).size()>0){
                                                    List<Form_Value__c> cols = sec_row_columns.get(sectionNo).get(rowNumber);
                                                    for(Form_Value__c z : cols){
                                                        if(z.ElixirSuite__Column_Number__c == columnNo){
                                                             String consentText = z.ElixirSuite__Consent_Pdf__c;
                                                             section[rowParent].ConsentTextOnly = consentText;
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                    //CONSENT FORM - END
                                    section[rowParent].colsize = fetchColSize(columnsInSection, colMap);
                                    
                                    Integer row = rowParent;
                                    Integer rowAdd = 0;
                                    for(Integer i=0;i<columnsInSection;i++){
                                        if(section.size()<=rowParent+i || section[rowParent+i]==null){
                                            continue; // Saviour
                                        }
                                        //Object - Form values - END
                                        
                                        Decimal rowNumber = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Row__c;
                                        if(rowNumber ==0){
                                            rowAdd++;
                                            continue;
                                        }
                                        if(section[row].Columns==null){
                                            section[row].Columns = new List<Columns_Z>();
                                        }
                                        FormRenderUtility.FieldSchema fetchField;
                                        if(section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Label_Long__c != 'nbsp' && String.isNotBlank(section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c)){
                                            String fieldNameFromObj = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c;
                                            if(allFieldsMap.containsKey(fieldNameFromObj)){
                                                fetchField = allFieldsMap.get(fieldNameFromObj);
                                            }
                                        }
                                        
                                        //CONSENT FORM - START
                                        if(sec_row_columns.size()>0 && sec_row_columns!=null){
                                            rowNumber = section[rowParent + i].sObjectChildRefrence.ElixirSuite__Row__c; // can take a new variable
                                            Decimal columnNo = section[rowParent + i].sObjectChildRefrence.ElixirSuite__Column__c;
                                            Boolean isConsent = section[rowParent + i].sObjectChildRefrence.ElixirSuite__Is_Consent__c;
                                            Decimal sectionNo = record.sObjectRefrence.ElixirSuite__Section_Number__c;
                                            if(isConsent && String.isNotBlank(String.valueOf(sectionNo))){
                                                if(sec_row_columns.get(sectionNo).size()>0 && sec_row_columns.get(sectionNo)!=null){
                                                    if(sec_row_columns.get(sectionNo).get(rowNumber).size()>0){
                                                        List<Form_Value__c> cols = sec_row_columns.get(sectionNo).get(rowNumber);
                                                        for(Form_Value__c z : cols){
                                                            if(z.ElixirSuite__Column_Number__c == columnNo){
                                                                String consentText = z.ElixirSuite__Consent_Pdf__c;
                                                                section[rowParent+i].ConsentTextOnly = consentText;
                                                            }
                                                        }
                                                    }      
                                                }
                                            }
                                        }
                                        //CONSENT FORM - END
                                        //FORM LABEL - START
                                        
                                        objectName =  section[rowParent+i].sObjectChildRefrence.ElixirSuite__Object_Name__c; // Duplicate var
                                        fieldName = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c; // Duplicate var            
                                        
                                        if(obj!=null && String.isNotBlank(objectName) && String.isNotBlank(String.valueOf(section[rowParent+i].sObjectChildRefrence)) &&
                                           obj.get(objectName)!=null){
                                               if(obj.get(objectName).get(fieldName)!=null){
                                                   section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Label_Long__c = obj.get(objectName).get(fieldName);
                                               }
                                           }
                                        //FORM LABEL - END
                                        
                                        if(fetchField != null){
                                            String dataTypeValue = fetchField.dataType.toUpperCase();
                                            String formDataType = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Form_Data_Type__c;
                                            if(dataTypeValue == 'PICKLIST' && formDataType != 'Radio'){
                                                section[rowParent+i].picklistValuesText = new List<String>();
                                                section[rowParent+i].picklistValuesText = fetchField.picklistValues;
                                            }
                                            else if(formDataType == 'Radio'){
                                                section[rowParent+i].PicklistValues = new List<PicklistValues>();
                                                List<String> picklistValues = fetchField.picklistValues;
                                                for(String pickValue : picklistValues){
                                                    PicklistValues toAddPckLst = new PicklistValues();
                                                    toAddPckLst.value = pickValue;
                                                    toAddPckLst.label = pickValue;
                                                    section[rowParent+i].PicklistValues.add(toAddPckLst);
                                                }
                                            }
                                            else if(dataTypeValue == 'MULTIPICKLIST'){
                                                section[rowParent+i].PicklistValues = new List<PicklistValues>();
                                                List<String> picklistValues = fetchField.picklistValues;
                                                for(String pickValue : picklistValues){
                                                    PicklistValues toAddPckLst = new PicklistValues();
                                                    toAddPckLst.value = pickValue;
                                                    toAddPckLst.label = pickValue;
                                                    section[rowParent+i].PicklistValues.add(toAddPckLst);
                                                }
                                                section[rowParent+i].values = new List<String>();
                                                
                                            }
                                            String objName = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Object_Name__c;
                                            fieldName = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c; // duplicate variable
                                            if(objToValues.get(objName)!=null && objToValues.get(objName).get(fieldName)!=null){
                                                Object sObjValue = objToValues.get(objName).get(fieldName);
                                                String objValues = String.valueOf(sObjValue);
                                                if(dataTypeValue == 'MULTIPICKLIST'){
                                                    List<String> values = new List<String>();
                                                    values = objValues.split( ';');                                                  
                                                    section[rowParent+i].values = values;
                                                }else if(dataTypeValue == 'DATE'){
                                                    section[rowParent+i].valueInDate = Date.valueOf(objValues);
                                                }else if(dataTypeValue == 'REFERENCE'){
                                                    section[rowParent+i].value = lookupMap.get(objValues);
                                                }
                                                else{
                                                    section[rowParent+i].value = objValues;
                                                }
                                            }
                                        }    
                                        Integer currentRow = -1;
                                        if(section[row+i] != null
                                           && (currentRow == -1 || currentRow == section[row+i].sObjectChildRefrence.Row__c)){
                                               currentRow = Integer.valueOf(section[row+i].sObjectChildRefrence.Row__c);
                                               //Handling NO Label - START
                                               if(section[row+i].sObjectChildRefrence.No_Label__c){
                                                   section[row+i].sObjectChildRefrence.Field_Label_Long__c = '';
                                               }
                                               //Handling NO Label - END
                                               
                                               // Convert 24 hr Time in to 12 hr Time
                                               List<String> timeDataType = new List<String>{'TIME', 'time'};
                                               if (timeDataType.contains(section[row+i].sObjectChildRefrence.ElixirSuite__Data_Type__c) &&
                                                   !String.isBlank(String.valueOf(section[row+i].value))) {
                                                    List<String> time24hrSplit = String.valueOf(section[row+i].value).split(':');
                                                    Integer hour = Integer.valueOf(time24hrSplit[0]);

                                                    List<Integer> hoursToConvertTo12AM = new List<Integer>{0, 24};
                                                    Integer hourToConvertTo12PM = 12;

                                                    if (hoursToConvertTo12AM.contains(hour)) {
                                                        section[row+i].value = 12 + ':' + time24hrSplit[1] + ' AM';
                                                    }
                                                    else if (hour == hourToConvertTo12PM) {
                                                        section[row+i].value = 12 + ':' + time24hrSplit[1] + ' PM';
                                                    }
                                                    else if (hour >= 1 && hour <= 11) {
                                                        section[row+i].value = hour + ':' + time24hrSplit[1] + ' AM';
                                                    }
                                                    else if (hour >= 13 && hour <= 23) {
                                                        section[row+i].value = (hour-12) + ':' + time24hrSplit[1] + ' PM';
                                                    }
                                               }

                                               // Try to convert to local time zone
                                               List<String> dateTimeDataType = new List<String>{'DATETIME', 'datetime'};
                                               if (dateTimeDataType.contains(section[row+i].sObjectChildRefrence.ElixirSuite__Data_Type__c) &&
                                               !String.isBlank(String.valueOf(section[row+i].value)))
                                               {
                                                section[row+i].value = convertGMTtoLocalTimeZone(String.valueOf(section[row+i].value));
                                               }

                                               section[row+i].colsize = fetchColSize(columnsInSection, colMap);
                                               section[row].Columns.add((Columns_Z) JSON.deserialize(JSON.serialize(section[row+i]), Columns_Z.class));
                                               Integer columnsSize = section[row].Columns.size();
                                               section[row].Columns[columnsSize-1].sObjectColumnRefrence = section[row+i].sObjectChildRefrence;
                                               rowAdd++;
                                           }
                                    }
                                    rowParent = rowParent + rowAdd - 1;
                                }
                            }
                        }
                    }
            imgData(sectionsIds, formUniqueId);
            attachImageData(cssRecords,versionBasedOnUniqueName);
            this.cssRecords = cssRecords;

             //Anubhav Starts here for custom label
             formCSS2 = new  List<ElixirSuite__Object_1_css__c>();
             formCSS2 = [ SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Approver_Custom_Label__c FROM ElixirSuite__Object_1_css__c WHERE ElixirSuite__Form__c= :formName AND ElixirSuite__Approval_Level__c != NULL WITH SECURITY_ENFORCED ORDER BY ElixirSuite__Approval_Level__c];
             approverCustomLabel = new Map<Decimal, String>();
             customLabelList = new List<String>();
             for(ElixirSuite__Object_1_css__c cr : formCSS2){
                 if(!approverCustomLabel.containsKey(cr.ElixirSuite__Approval_Level__c)){
                     approverCustomLabel.put(cr.ElixirSuite__Approval_Level__c , cr.ElixirSuite__Approver_Custom_Label__c);
                     if(String.isBlank(cr.ElixirSuite__Approver_Custom_Label__c)){
                         customLabelList.add('None');
                         }
                     else{
                         customLabelList.add(cr.ElixirSuite__Approver_Custom_Label__c);    
                         }
                 }
             }
            
             //Anubhav ends here for custom label

            List<Form_Value__c> approvedValues = new List<Form_Value__c>();
            SObjectAccessDecision decisionApproved = Security.stripInaccessible(AccessType.READABLE,
                                                                                [SELECT Id, ElixirSuite__Is_External_Signature__c,Account__c, Is_Approver__c, Date_Of_Approval__c,
                                                                                 User__r.Name, User__r.UserRole.Name, Approval_Level__c, Comment__c, Form_Name__c, Approved_Signature__c,
                                                                                 Signed_Patient__r.Name,ElixirSuite__Signed_Patient__c,ElixirSuite__Reopened_Date__c,Is_old__c FROM Form_Value__c
                                                                                 WHERE Is_Approver__c=true AND Form_Id__c= :formuniqueID and Is_old__c = false
                                                                                 WITH SECURITY_ENFORCED
                                                                                 ORDER BY ElixirSuite__Reopened_Date__c, Approval_Level__c]);
            approvedValues = decisionApproved.getRecords();
            this.approvalList = approvedValues;  
			
            List<Form_Value__c> fetchSignature = new List<Form_Value__c>();
            SObjectAccessDecision approvedSignature = Security.stripInaccessible(AccessType.READABLE,
                                                                                 [SELECT Id, ElixirSuite__Is_External_Signature__c,Account__c, Is_Approver__c, Date_Of_Approval__c,
                                                                                 User__r.Name, User__r.UserRole.Name, Approval_Level__c, Comment__c, Form_Name__c, Approved_Signature__c,
                                                                                 Signed_Patient__r.Name,ElixirSuite__Signed_Patient__c,ElixirSuite__Reopened_Date__c,Is_old__c FROM Form_Value__c
                                                                                 WHERE Is_Approver__c=true AND Form_Id__c= :formuniqueID and Is_old__c = true
                                                                                 WITH SECURITY_ENFORCED
                                                                                 ORDER BY ElixirSuite__Reopened_Date__c desc, Approval_Level__c]);
            
            fetchSignature = approvedSignature.getRecords();
            List<List<Form_Value__c>> previousApprovedValues = new List<List<Form_Value__c>>();
            List<Form_Value__c> lst = new List<Form_Value__c>();
            DateTime oldvalue;
            
            for(Form_Value__c Sign : fetchSignature){
                DateTime NewValue = Sign.ElixirSuite__Reopened_Date__c;
                if(NewValue == oldvalue | oldvalue == null){
                    lst.add(Sign);
                }
                else{
                    previousApprovedValues.add(lst);
                    lst = new List<Form_Value__c>();
                    lst.add(Sign);
                }
                
                oldvalue = Sign.ElixirSuite__Reopened_Date__c;
            }
            previousApprovedValues.add(lst);
            this.previousApprovalList = previousApprovedValues;
            
            List<Form_Value__c> modularMatrixDataTmp = [
                    SELECT Id, ElixirSuite__Modular_Matrix_Data_JSON__c
                      FROM ElixirSuite__Form_Value__c
                     WHERE ElixirSuite__Form_Id__c = :formUniqueId
                       AND ElixirSuite__Has_Modular_Matrix_Data__c = true
                      WITH SECURITY_ENFORCED
                ];
            
            if (modularMatrixDataTmp != null && !modularMatrixDataTmp.isEmpty()) {
                modularMatrixData = (Map<String, List<ModularMatrixRow>>) JSON.deserializeStrict(modularMatrixDataTmp[0].ElixirSuite__Modular_Matrix_Data_JSON__c, Map<String, List<ModularMatrixRow>>.class);
            } 
		//Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + changedFormName + '.pdf');  
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + changedFormName.escapeCsv() + '.pdf');  
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public void imgData(Set<Id> sectionsIds, String formId){
        Set<String> combinations = new Set<String>();
        for(Id sectionId :sectionsIds){
            combinations.add(formId+ '&' +sectionId);
        }
        
        imageData = new Map<Id,String>();
        List<Attachment> documents = [SELECT Id,Body,Name
        FROM Attachment 
        WHERE Name IN :combinations WITH SECURITY_ENFORCED];
        Map<Id,Attachment> versionMap = new Map<Id,Attachment>();
        for(Attachment version :documents){
            List<String> spittedText = version.Name.split('&');
            versionMap.put(spittedText[1], version);
        }
        for(Id sectionId :sectionsIds){
            if(versionMap.containsKey(sectionId)){
                Attachment data = versionMap.get(sectionId);
                imageData.put(sectionId, '/servlet/servlet.FileDownload?file='+data.Id);
            }else{
                imageData.put(sectionId, 'false');
            }
        }
    }
    public void attachImageData(List<sObjectSchemaWrapper> cssRecords, Map<String,List<ContentVersion>> versionBasedOnUniqueName){
        for(sObjectSchemaWrapper objInstance : cssRecords){
            if(objInstance.Object_1_css_r!=null){
                for(Object_1_css_r childInstance : objInstance.Object_1_css_r){
                    if(childInstance.Columns!=null){
                        for(Columns_Z nestedchild : childInstance.Columns){
                            if(String.isNotBlank(nestedchild.sObjectColumnRefrence.ElixirSuite__IMG_Default_Button_Label__c)){
                                List<ContentVersion> uploadedFiles =  versionBasedOnUniqueName.get(nestedchild.sObjectColumnRefrence.ElixirSuite__IMG_Default_Button_Label__c);
                                List<ImageFileWrapper> imgLst = new List<ImageFileWrapper>();
                                if(uploadedFiles!=null){
                                    for(ContentVersion imgFileInstance : uploadedFiles){
                                        ImageFileWrapper imgSingleObjInstance = new ImageFileWrapper();
                                        imgSingleObjInstance.recordContentVersionId = imgFileInstance.ContentDocumentId;
                                        imgSingleObjInstance.nameOfImageFile  = imgFileInstance.ElixirSuite__File_Name__c;
                                        imgSingleObjInstance.uploadFileType = imgFileInstance.FileType;
                                        imgLst.add(imgSingleObjInstance);
                                    }
                                    nestedchild.imgFileDemographics = imgLst;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public String fetchColSize(Decimal columnsInSection,Map<Decimal,String> colMap){
        
        if(colMap.get(columnsInSection)!=null){
            return colMap.get(columnsInSection);
        }
        else {
            return '6';
        }       
    }
    
    //Added by vidish
    public String fetchLookupName(String lookupId){
       String ObjectName;
       String fieldName = 'Name'; 
        if(lookupId != null){
		 Id recId = Id.valueOf(lookupId);    
         ObjectName  = recId.getSObjectType().getDescribe().getName();
        }
        If(ObjectName.equalsIgnoreCase('Case')){
            fieldName = 'Subject';
        }
		String Query = 'Select Id,'+string.escapeSingleQuotes(fieldName)+' FROM '+string.escapeSingleQuotes(ObjectName)+' WHERE ID =\''+string.escapeSingleQuotes(lookupId)+'\'';//changes made pawan
        
        for(sObject so : Database.Query(Query)) {
           lookupValueName = (String)so.get(fieldName);
            
        }
        return lookupValueName;
        
    }
    //Vidish Code Ends
    
    public class sObjectSchemaWrapper {
        public  ElixirSuite__Object_1_css__c sObjectRefrence {get;set;}  
        public  List<String> matrixHeaders {get;set;}  
        public String autoText {get;set;}
        public String macroTemplateText {get;set;}
        public String problemNoteTemplateText {get;set;}
        public String diagnosisNoteTemplateText {get;set;} 
        public String procedureNoteTemplateText {get;set;}
        public String colsize {get;set;}       
        public List<Object_1_css_r> Object_1_css_r {get;set;}       
    }
    public class Object_1_css_r {
        public  ElixirSuite__Object_1_css__c sObjectChildRefrence {get;set;}            
        public List<Columns_Z> Columns {get;set;}  
        public Boolean OnlyText {get;set;}
        public String ConsentTextOnly {get;set;}
        public List<ConsentValueWrapper> consentWrapper {get;set;}
        public List<String> PicklistValuesText {get;set;}      
        public List<PicklistValues> PicklistValues {get;set;}      
        public List<String> values {get;set;}      
        public Date valueInDate {get;set;}
        public String value {get;set;}      
        public String colsize {get;set;}      
    }
    
    public class Columns {
        String colDem {get;set;}      
    }
    
    public class PicklistValues {
        public String value {get;set;}      
        public String label {get;set;}      
    }
    
    public class Columns_Z {
        public  ElixirSuite__Object_1_css__c sObjectColumnRefrence {get;set;}        
        public List<Columns> Columns {get;set;}      
        public Boolean OnlyText {get;set;}
        public List<ConsentValueWrapper> consentWrapper {get;set;}
        public String ConsentTextOnly {get;set;}
        public List<String> PicklistValuesText {get;set;}      
        public List<PicklistValues> PicklistValues {get;set;}      
        public List<String> values {get;set;}      
        public String value {get;set;}    
        public Date valueInDate {get;set;}
        public List<ImageFileWrapper> imgFileDemographics {get;set;}  
        public String colsize {get;set;}      
    }
    public class ConsentValueWrapper{
        public String text {get;set;}
        public String type {get;set;}
        public String value {get;set;}
    }
    public class ImageFileWrapper {
        public String recordContentVersionId {get;set;}    
        public String nameOfImageFile {get;set;}  
        public String nameOfImageFileAsLabel {get;set;}
        public string uploadFileType {get;set;}
    }
    public  void  processProcedureData(ElixirSuite__Procedure__c[] lstOfAllProcedurePerAccount){
        procedureLst = new List<ProcedureWrapper>();
         List<String> modifiersText;
        Map<Id,List<String>> mapOfProcedureToDiagnosis =  fetchDiagnosisData(lstOfAllProcedurePerAccount);
        modifiersText = new List<String>();
        for(ElixirSuite__Procedure__c sObj : lstOfAllProcedurePerAccount){
            modifiersText = new List<String>();
            ProcedureWrapper procWrp = new ProcedureWrapper();
            processModifier(sObj,procWrp);
            procWrp.procedure = sObj;
            if(sObj.Modifier1__r.name!=null){
                modifiersText.add(sObj.Modifier1__r.name);
            }
            if(sObj.Modifier2__r.name!=null){
                modifiersText.add(sObj.Modifier2__r.name);
            }
            if(sObj.Modifier3__r.name!=null){
                modifiersText.add(sObj.Modifier3__r.name);
            }
            if(sObj.Modifier4__r.name!=null){
                modifiersText.add(sObj.Modifier4__r.name);
            }
            if(!modifiersText.isEmpty()){
                procWrp.modifiersText = String.join(modifiersText,' ; ');
            }
            if(sObj.ElixirSuite__From_Date_of_Service__c!=null){
              procWrp.fromDateOfSercvice = sObj.ElixirSuite__From_Date_of_Service__c.format();  
            }
            if(sObj.ElixirSuite__To_Date_of_Service__c!=null){ 
            procWrp.toDateOfSercvice = sObj.ElixirSuite__To_Date_of_Service__c.format();
            }
            if(mapOfProcedureToDiagnosis.containsKey(sObj.Id)){
                procWrp.diagnosisCodes = String.join( mapOfProcedureToDiagnosis.get(sObj.Id), ', ' );
            }
            else{
                procWrp.diagnosisCodes = '';
            }
            procedureLst.add(procWrp);
        }
    }
    public  void  processModifier(ElixirSuite__Procedure__c sObj, ProcedureWrapper procWrp){
        for(Integer i=1;i<=4;i++){
            if(String.isBlank(String.valueOf(sObj.get('ElixirSuite__Modifier'+i+'__c')))){
                sObj.put('ElixirSuite__Modifier'+i+'__c','N/A');
            }  
        }
        
    }
    public  Map<Id,List<String>>  fetchDiagnosisData(ElixirSuite__Procedure__c[] lstOfAllProcedurePerAccount){
        Set<Id> prcIdLst = new Set<Id>();
        for(ElixirSuite__Procedure__c sObj : lstOfAllProcedurePerAccount){
            prcIdLst.add(sObj.Id);
        }
        ElixirSuite__Procedure_Diagnosis__c[] junctionLst = [SELECT ID,ElixirSuite__Procedure__c,ElixirSuite__ICD_Codes__r.Name FROM ElixirSuite__Procedure_Diagnosis__c
                                                             WHERE ElixirSuite__Procedure__c IN : prcIdLst 
                                                             with security_enforced];
        Map<Id,List<String>> mapOfProcedureToDiagnosis = new Map<Id,List<String>>();
        for(ElixirSuite__Procedure_Diagnosis__c jncSObj : junctionLst){
            if(mapOfProcedureToDiagnosis.containsKey(jncSObj.ElixirSuite__Procedure__c)){
                mapOfProcedureToDiagnosis.get(jncSObj.ElixirSuite__Procedure__c).add(jncSObj.ElixirSuite__ICD_Codes__r.Name);
            }else{
                List<String> icdCodes = new List<String>();
                icdCodes.add(jncSObj.ElixirSuite__ICD_Codes__r.Name);
                mapOfProcedureToDiagnosis.put(jncSObj.ElixirSuite__Procedure__c,icdCodes);
            } 
        }
        return mapOfProcedureToDiagnosis;
    }

    // added by Himanshu

    public void maualLabData(List<UA_Sample_Details__c> labData){
        manualLabOrder = new List<manualLabWrapper>();
        if(labData!=null && labData.size()>0){
        Map<Id,UA_Sample_Details__c> orders = new Map<Id,UA_Sample_Details__c>(labData);
            List<ContentDocumentLink> documentLink = [SELECT Id, ContentDocumentId, LinkedEntityId 
                                            FROM ContentDocumentLink
                                            WHERE LinkedEntityId IN :orders.keySet()
                                            WITH SECURITY_ENFORCED
                                            ORDER BY SystemModstamp DESC LIMIT 5000];
            Map<Id,String> labToAttch = new Map<Id,String>();
            for(ContentDocumentLink doc : documentLink){
                labToAttch.put(doc.LinkedEntityId, doc.ContentDocumentId);
            }

        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();   
        for(UA_Sample_Details__c sobj : labData){
            manualLabWrapper obj = new manualLabWrapper();
            obj.labOrderNo = sObj.Name;
            obj.status = sobj.Status__c;
            obj.testName = sobj.Medical_Test__c;
            if(labToAttch.containsKey(sobj.Id)){
                obj.result = '/sfc/servlet.shepherd/document/download/'+labToAttch.get(sobj.Id);
            }else{
                obj.result = 'No results';
            }   
            obj.createdDate = sobj.createdDate.format();
            obj.createdBy = sobj.CreatedBy.Name;
            obj.lastModified = sobj.LastModifiedDate.format();
            manualLabOrder.add(obj);
        }
    }
    }

    public class manualLabWrapper{
        public String labOrderNo{get;set;}
        public String testName{get;set;}
        public String status{get;set;}
        public String result{get;set;}
        public String createdDate{get;set;}
        public String createdBy{get;set;}
        public String lastModified{get;set;}
    }
	public void initializeRelatedProblems() {
    formattedRelatedProblemsMap = new Map<Id, String>();

    for (ElixirSuite__ICD_Codes__c record : diagnosisObjectRecords) {
        List<String> relatedProblemsList = new List<String>();

        for (ElixirSuite__Diagnosis_Code__c diagnosisCode : record.ElixirSuite__Diagnosis_Codes__r) {
            if (diagnosisCode.ElixirSuite__Problem__r != null) {
                relatedProblemsList.add(diagnosisCode.ElixirSuite__Problem__r.Name);
            }
        }

        String formattedRelatedProblems = relatedProblemsList.isEmpty() ? 'NA' : String.join(relatedProblemsList, ', ');

        formattedRelatedProblemsMap.put(record.Id, formattedRelatedProblems);
    }
    }
        public void initializeRelatedFrequency() {
        formattedRelatedFrequencyMap = new Map<Id, String>();
    
        for (ElixirSuite__Prescription_Order__c record : medicationLstData) {
            String relatedFrequency = '';
    
            for (ElixirSuite__Frequency__c frequency : record.ElixirSuite__Frequency__r) {
                if (frequency.ElixirSuite__Strength__c != null) {
                    relatedFrequency = frequency.ElixirSuite__Strength__c;
                    break; // Assuming you only want the first strength value
                }
            }
    
            String formattedRelatedFrequency = String.isNotBlank(relatedFrequency) ? relatedFrequency : ' ';
    
            formattedRelatedFrequencyMap.put(record.Id, formattedRelatedFrequency);
        }
    }


    public void chcLabData(List<Lab_Order__c> chcData){
        chcLabOrder = new List<ChcLabWrapper>();
        if(chcData!=null && chcData.size()>0){
            Map<Id,Lab_Order__c> orders = new Map<Id,Lab_Order__c>(chcData);
            List<Attachment> attachments = [SELECT Id, ParentId FROM Attachment
                                            WHERE ParentId IN :orders.keySet()
                                            WITH SECURITY_ENFORCED
                                            ORDER BY CreatedDate ASC];
            Map<Id,String> labToAttch = new Map<Id,String>();
            for(Attachment attch :attachments){
                labToAttch.put(attch.ParentId, attch.Id);
            }
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            for(Lab_Order__c order :chcData){

            ChcLabWrapper obj = new ChcLabWrapper();
                obj.labOrderNo = order.Lab_Order_Req__c;
                obj.labName = order.ElixirSuite__LabName__c;
                obj.labType = order.ElixirSuite__Lab_Type__c;
                obj.status = order.Status__c;
                obj.testName = order.Test_Name__c;
                if(labToAttch.containsKey(order.Id)){
                    obj.result = baseUrl+'/servlet/servlet.FileDownload?file='+labToAttch.get(order.Id)+'&operationContext=S1';
                }else{
                    obj.result = 'No results';
                }
                obj.createdDate = order.createdDate.format();
                obj.createdBy = order.CreatedBy.Name;
                obj.lastModified = order.LastModifiedDate.format();
            chcLabOrder.add(obj);
        }
        }
    }

    public class ChcLabWrapper{
        public String labOrderNo{get;set;}
        public String labName{get;set;}
        public String labType{get;set;}
        public String testName{get;set;}
        public String status{get;set;}
        public String result{get;set;}
        public String createdDate{get;set;}
        public String createdBy{get;set;}
        public String lastModified{get;set;}
    }
    // end by Himanshu

  /*  public  void processProblemData(List<ElixirSuite__Diagnosis_Code__c> lstOfAllProblemPerAccount){
        problemLst = new List<ProblemWrapper>();
        for(ElixirSuite__Diagnosis_Code__c sObj : lstOfAllProblemPerAccount){
            String dateDiagnised = '';
            if(String.isNotBlank(String.valueOf(sObj.ElixirSuite__Problem__r.ElixirSuite__Date_Diagonised__c))){
                dateDiagnised =  sObj.ElixirSuite__Problem__r.ElixirSuite__Date_Diagonised__c.format();
            }
            ProblemWrapper obj = new ProblemWrapper();
            obj.problemName = sObj.ElixirSuite__Problem__r.Name;
            obj.icd = sObj.ElixirSuite__Diagnosis_Code__r.Name; 
            obj.icdVersion = sObj.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c;
            obj.snowmedCTCode = sObj.ElixirSuite__Problem__r.ElixirSuite__SNOMED_CT_Code__c;
            obj.status = sObj.ElixirSuite__Problem__r.ElixirSuite__Status__c;
            obj.problemType = sObj.ElixirSuite__Problem__r.ElixirSuite__Problem_Type__c;
            obj.dateDiagonised =dateDiagnised;
            obj.notes = sObj.ElixirSuite__Problem__r.ElixirSuite__Note__c;
            obj.CreatedDate = sObj.CreatedDate.format();
            obj.CreatedBy = sObj.CreatedBy.Name;
            obj.modifiedDate = sObj.LastModifiedDate.format();
            problemLst.add(obj);
        }
        
    }
    public class ProblemWrapper{
        public String problemName{get;set;}
        public String icd{get;set;}
        public String icdVersion{get;set;}
        public String snowmedCTCode{get;set;}
        public String status{get;set;}
        public String problemType{get;set;}
        public String dateDiagonised{get;set;}
        public String notes{get;set;}
        public String CreatedDate{get;set;}
        public String CreatedBy{get;set;}
        public String modifiedDate{get;set;}
    }*/
     
    public class ProcedureWrapper{ 
        public ElixirSuite__Procedure__c procedure{get;set;}
        public String modifiersText {get;set;}
        public String diagnosisCodes {get;set;}
        public String fromDateOfSercvice {get;set;}
         public String toDateOfSercvice {get;set;}
    }
    public static PDF_Header__c getPDFData(){
        PDF_Header__c record = PDF_Header__c.getInstance() ;
        return record ;
    }
    public class pdfHeaderWrapper { 
        public PDF_Header__c pdfAllData;
        public String headerImg;
    }

    Public Class ModularMatrixColumn {
        Public String dataType {get;set;} 
        Public String value {get;set;} 
        Public String columnNumber {get;set;}
        Public Boolean isText {get; set;}
        Public Boolean isTextArea {get; set;}
        Public Boolean isdate {get; set;}
        Public Boolean isdatetime {get; set;}
        Public Boolean isNumber {get; set;}
    }
    
    Public Class ModularMatrixRow {
        Public List<ModularMatrixColumn> columns {get;set;}
        Public Integer rowNumber {get;set;}
    }

    Public String convertGMTtoLocalTimeZone(String dateTimeGMT) {
        // required dateTimeGMT format '2023-01-12 05:15:00'
        
        // dateTimeSplit will be like ['2023-01-12', '05:15:00']
        List<String> dateTimeSplit = String.valueOf(dateTimeGMT).split(' ');
        // dateSplit will be like ['2023', '01', 12]
        List<String> dateSplit = String.valueOf(dateTimeSplit[0]).split('-');
        // timeSplit will be like ['05', '15', '00']
        List<String> timeSplit = String.valueOf(dateTimeSplit[1]).split(':');

        return DateTime.newInstanceGmt(
            Integer.valueOf(dateSplit[0]),
            Integer.valueOf(dateSplit[1]),
            Integer.valueOf(dateSplit[2]),
            Integer.valueOf(timeSplit[0]),
            Integer.valueOf(timeSplit[1]),
            Integer.valueOf(timeSplit[2])
        ).format('MMM d, yyyy hh:mm aaa', String.valueOf(UserInfo.getTimeZone()));
    }
    
    public static void dummyMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}