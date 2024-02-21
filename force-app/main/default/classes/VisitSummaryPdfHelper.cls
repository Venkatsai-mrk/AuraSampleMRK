public with sharing class VisitSummaryPdfHelper {
    public static Account patientInfo { get; set; }  
    public Boolean problems {get;set;}
    public Boolean prescriptions {get;set;}
    public Boolean allergies {get;set;}
    public Boolean showLabOrder {get;set;}
    public Boolean showDiagnosisCode {get;set;}
    public Boolean showVitalSigns {get; set;}
    public Boolean showProcedureCode {get; set;}
    public Boolean showCHCLabOrder {get;set;}
    public String acctRecordID {get;set;}
    public List<String> finalJSON {get;set;}
    public List<ElixirSuite__Dataset1__c> probList {get;set;}
    public List<ElixirSuite__Medical_Examination__c> allerList {get;set;}
    public List<ElixirSuite__UA_Sample_Details__c> labOrderList {get;set;}
    public List<ElixirSuite__Lab_Order__c> chcLabOrderList {get;set;}
    public List<ElixirSuite__Prescription_Order__c> presList {get;set;}
    public List<ElixirSuite__MAR_MOR__c> morList {get;set;}
    public List<ElixirSuite__Diagnosis_Code__c> diagnosisCodeList {get;set;}
    public List<ElixirSuite__Medical_Examination__c> vitalSigns {get;set;}
    public List<ElixirSuite__Procedure__c> procedureCodeList {get;set;}
    public Boolean allowPDFRender {get;set;}
    
    public ElixirSuite__Elixir_Custom_Setting__c pdfData {get; set;}
    public List<ElixirSuite__Visits__c> careEp {get;set;}
    public List<ElixirSuite__Medical_Examination__c> medExam {get;set;}
    public List<ElixirSuite__UA_Sample_Details__c> labOrder {get;set;}
    public List<ElixirSuite__Prescription_Order__c> presOrder {get;set;}
    public VisitSummaryPdfHelper() {
        String accountId = ApexPages.currentPage().getParameters().get('accountId'); 
        system.debug('accountId vf: '+accountId);//'0019D00000Yzq0oQAB';
        String visitId = ApexPages.currentPage().getParameters().get('visitId'); // 'a1x9D0000009J3IQAU'; //
        system.debug('visitId vf: '+visitId);
        getPatientInfo(accountId);
        visitSummaryPDFDecision();
        generateChartEntites(accountId,visitId);
    }
    
    
    public static void getPatientInfo(String accountId) {
        Account[] patientDetailLst = [SELECT ID,Name,ElixirSuite__Patient_s_Birth_Date__c,ElixirSuite__Gender__c,ElixirSuite__DOB__c,
                                      ElixirSuite__MRN_Number_New__c,Phone
                                      FROM Account where id = : accountId
                                      WITH SECURITY_ENFORCED];
        if(patientDetailLst!=null && patientDetailLst.size()>0){
            patientInfo = patientDetailLst[0];
        }
        
    }
    public  void visitSummaryPDFDecision() {
        Id recordTypeId =
            Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName()
            .get('Patient_Portal').getRecordTypeId();
        List<ElixirSuite__Master_Object__c> visitDecisionLst = [SELECT ID,ElixirSuite__Visit_Summary_Sections__c FROM ElixirSuite__Master_Object__c WHERE 
                                                                ElixirSuite__Patient_Tile_Entity__c = 'Visit Summary'
                                                                AND RecordtypeId = : recordTypeId
                                                                WITH SECURITY_ENFORCED];
        String[] decisionEntity = visitDecisionLst[0].ElixirSuite__Visit_Summary_Sections__c.split(';');
        for(String cat :decisionEntity){
            switch on cat{
                
                when 'Lab Order(s)'{
                    showLabOrder = true;
                }
                when 'Prescription(s)'{
                    prescriptions = true;
                }
                when 'Problem(s)'{
                    problems = true;
                }
                when 'Allergies'{
                    allergies = true;
                }
                when 'Diagnosis Code(s)' {
                    showDiagnosisCode = true;
                }   
                when 'Vital Signs' {
                    showVitalSigns = true;
                }
                when 'Procedure Code(s)' {
                    showProcedureCode = true;
                }
            }
        }
        
    }
    public static String getLabOrderPriority() {
        //SELECT Id, ElixirSuite__LabOrder_Priority__c FROM ElixirSuite__TabPermissionBasedOnProfiles__c
        try {
            List<ElixirSuite__TabPermissionBasedOnProfiles__c> customSettingObject = [SELECT Id, ElixirSuite__LabOrder_Priority__c FROM ElixirSuite__TabPermissionBasedOnProfiles__c WITH SECURITY_ENFORCED];
            
            if (customSettingObject != null && customSettingObject.size() > 0) {
                return customSettingObject[0].ElixirSuite__LabOrder_Priority__c;
            }
            else {
                return '';
            }   
        } catch (Exception e) {
            ExceptionLog.logError(e);
            return '';
        }
    }
    public  void generateChartEntites(Id accId, Id visitId){    
        
        //   Id recordTypeId = Schema.SObjectType.ElixirSuite__Dataset1__c.getRecordTypeInfosByDeveloperName().get('Non_Templatized').getRecordTypeId();
        //    probList = [SELECT Id,Name,ElixirSuite__Problem_Name__c,ElixirSuite__Form_Unique_ID__c,
        //                 CreatedDate,ElixirSuite__Description__c,ElixirSuite__Dataset1__c
        //                 FROM ElixirSuite__Dataset1__c  
        //                 WHERE ElixirSuite__Account__c = :accId
        //                 AND ElixirSuite__Care_Episode__c= :visitId WITH SECURITY_ENFORCED] ;
        //     system.debug('problist'+probList);
        
        //new probList ask why it is commented above then only work with problem list
        probList = [
            SELECT Id, Name, ElixirSuite__SNOMED_CT_Code__c, ElixirSuite__Problem_Type__c, ElixirSuite__Date_Onset__c
            FROM ElixirSuite__Dataset1__c
            WHERE ElixirSuite__Account__c = :accId
            AND ElixirSuite__Care_Episode__c= :visitId
            WITH SECURITY_ENFORCED
        ];
        system.debug('problist'+probList);
        
        
        Id medalertrecordTypeId = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Medical_Alerts').getRecordTypeId();
        Id allerrecordTypeId = Schema.SObjectType.ElixirSuite__Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Allergy').getRecordTypeId();
        
        // allerList= [SELECT Id,Name,ElixirSuite__Allergy_Name__c,ElixirSuite__Category__c,ElixirSuite__Frequency__c,
        //             ElixirSuite__Medical_Examination_Name__c,ElixirSuite__Note__c,CreatedDate, recordtype.name
        
        //             FROM ElixirSuite__Medical_Examination__c  
        //             WHERE ElixirSuite__Account__c = :accId
        //             AND ElixirSuite__Care_Episode__c= :visitId WITH SECURITY_ENFORCED] ;
        
        allerList =  [
            SELECT Id, ElixirSuite__Allergy_Name__c, ElixirSuite__Reaction__c, ElixirSuite__Substance__c, ElixirSuite__Severity__c
            FROM ElixirSuite__Medical_Examination__c
            WHERE ElixirSuite__Account__c = :accId
            AND ElixirSuite__Care_Episode__c = :visitId
            AND RecordType.Name = 'Allergy'
            WITH SECURITY_ENFORCED
        ];
        
       
        String labOrderPriority = getLabOrderPriority();
        switch on labOrderPriority {
            when 'Dummy LabOrder' {
                showCHCLabOrder = false;
                chcLabOrderList = new List<ElixirSuite__Lab_Order__c>();                
               
                labOrderList = [
                    SELECT Id, Name, ElixirSuite__Medical_Test__c, ElixirSuite__Status__c, ElixirSuite__Start_Date__c
                    FROM ElixirSuite__UA_Sample_Details__c
                    WHERE ElixirSuite__Account__c= :accId
                    AND ElixirSuite__Care_Episode__c= :visitId
                    WITH SECURITY_ENFORCED
                ];
                system.debug('meghna lab order' + labOrderList);       
            }
            when 'CHC LabOrder' {
                showCHCLabOrder = true;
                labOrderList = new List<ElixirSuite__UA_Sample_Details__c>();
                chcLabOrderList = [
                    SELECT Id, Name, ElixirSuite__Test_Name__c, ElixirSuite__Status__c, ElixirSuite__Collection_Date_Time__c
                    FROM ElixirSuite__Lab_Order__c
                    WHERE ElixirSuite__Account_Id__c= :accId
                    AND ElixirSuite__Care_Episode__c= :visitId
                    WITH SECURITY_ENFORCED
                ];
                System.debug('chcLabOrderList: ' + chcLabOrderList);
            }
            when else {
                System.debug('Error: Invalid TabPermissionBasedOnProfiles__c.LabOrder_Priority__c');
                labOrderList = new List<ElixirSuite__UA_Sample_Details__c>();
                chcLabOrderList = new List<ElixirSuite__Lab_Order__c>();
                
            }
        }
        
        
        presList = [SELECT Id,Name,ElixirSuite__Type__c,ElixirSuite__Drug_Name__c,ElixirSuite__Route_New__c,ElixirSuite__Ferquency__c,ElixirSuite__Route__c,CreatedDate,
                    ElixirSuite__Prescription_Order__c, ElixirSuite__Reason_new__c
                    FROM ElixirSuite__Prescription_Order__c  
                    WHERE ElixirSuite__Account__c = :accId
                    AND ElixirSuite__Care_Episode__c= :visitId
                    AND ElixirSuite__Drug_Name__c !=null
                    WITH SECURITY_ENFORCED ];
        system.debug('meghna' + presList);
        
        morList= [SELECT Id,Name,ElixirSuite__Drug_Name__c,ElixirSuite__Frequency__c,ElixirSuite__Medication_Name__c,
                  CreatedDate,ElixirSuite__Status__c,ElixirSuite__Reasons__c
                  FROM ElixirSuite__MAR_MOR__c  
                  WHERE ElixirSuite__Account__c = :accId 
                  AND ElixirSuite__Care_Episode__c= :visitId WITH SECURITY_ENFORCED] ;
        
        diagnosisCodeList = [
            SELECT Id, ElixirSuite__Diagnosis_Code__r.name, ElixirSuite__Diagnosis_Code__r.ElixirSuite__Code_Description1__c, ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c, ElixirSuite__Diagnosis_Code__r.ElixirSuite__Effective_Date__c
            FROM ElixirSuite__Diagnosis_Code__c
            WHERE ElixirSuite__Diagnosis_Code__r.ElixirSuite__Care_Episode__c = :visitId
            AND ElixirSuite__Problem__r.ElixirSuite__Account__c = :accId
            AND ElixirSuite__Diagnosis_Code__c != null
            WITH SECURITY_ENFORCED
        ];
        vitalSigns = [
            SELECT Id, ElixirSuite__Blood_Pressure_Diasystolic__c, ElixirSuite__Blood_Pressure_Systolic__c, ElixirSuite__Temperature__c, ElixirSuite__Pulse__c, ElixirSuite__Weight__c
            FROM ElixirSuite__Medical_Examination__c
            WHERE RecordType.Name='Vital Sign'
            AND ElixirSuite__Account__c = :accId
            AND ElixirSuite__Care_Episode__c = :visitId
            WITH SECURITY_ENFORCED
        ];
        
        
        
        String patientProcedureRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
        procedureCodeList = [
            SELECT Id, Name, ElixirSuite__Code_Category__c, ElixirSuite__Code_Description__c, ElixirSuite__Place_Of_Service_Picklist__c, ElixirSuite__Days_Units__c, ElixirSuite__Modifier1__r.Name, ElixirSuite__Modifier2__r.Name,  ElixirSuite__Modifier3__r.Name,  ElixirSuite__Modifier4__r.Name
            FROM ElixirSuite__Procedure__c
            WHERE ElixirSuite__Account__c = :accId
            AND ElixirSuite__Visits__c = :visitId
            AND RecordTypeId = :patientProcedureRecordTypeId
            WITH SECURITY_ENFORCED
        ];
        
        
        
        
    }
    
}