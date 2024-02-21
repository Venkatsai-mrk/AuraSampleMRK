public with sharing class PatientChartPDFHelper {
    
    public List<ElixirSuite__Notes__c> doctorNotes {get;set;}
    public List<ElixirSuite__Notes__c> nursingNotes {get;set;}
    public List<ElixirSuite__Notes__c> clinicalNotes {get;set;}
    public List<ElixirSuite__Notes__c> sessionNotes {get;set;}
    public  List<CareEpisodePDFWrapper> finalSObjInstance {get;set;}
    public String acctRecordID {get;set;}
    public List<String> finalJSON {get;set;}
    public List<ElixirSuite__Dataset1__c> probList {get;set;}
    public List<ElixirSuite__Medical_Examination__c> allerList {get;set;}
    public List<ElixirSuite__UA_Sample_Details__c> labOrderList {get;set;}
    public List<ElixirSuite__Lab_Order__c> chcLabOrderList {get;set;}
    public List<ElixirSuite__Prescription_Order__c> presList {get;set;}
    public List<ElixirSuite__MAR_MOR__c> morList {get;set;}
    //public List<ElixirSuite__Diagnosis_Code__c> diagnosisCodeList {get;set;}
    public List<ElixirSuite__ICD_Codes__c> diagnosisCodeList {get;set;}
    public List<ElixirSuite__Medical_Examination__c> vitalSigns {get;set;}
    public List<ElixirSuite__Procedure__c> procedureCodeList {get;set;}
    public Boolean allowPDFRender {get;set;}
    public wrapperAcc doctorNote {get;set;}
    public wrapperAcc AccData {get;set;}
    public ElixirSuite__Elixir_Custom_Setting__c pdfData {get; set;}
    public List<ElixirSuite__Visits__c> careEp {get;set;}
    public List<ElixirSuite__Medical_Examination__c> medExam {get;set;}
    public List<ElixirSuite__UA_Sample_Details__c> labOrder {get;set;}
    public List<ElixirSuite__Prescription_Order__c> presOrder {get;set;}
    public Boolean showMar {get;set;}
    public Boolean problems {get;set;}
    public Boolean prescriptions {get;set;}
    public Boolean allergies {get;set;}
    public Boolean showLabOrder {get;set;}
    public Boolean showDiagnosisCode {get;set;}
    public Boolean showVitalSigns {get; set;}
    public Boolean showProcedureCode {get; set;}
    public Boolean showCHCLabOrder {get;set;}
    
    public PatientChartPDFHelper(){
        allowPDFRender = false;       
        String orderId = ApexPages.currentPage().getParameters().get('caseId');
        String category = ApexPages.currentPage().getParameters().get('cat');
        List<String> categories = category.split(';');
        if(categories!=null && categories.size()>0){
            for(String cat :categories){
                switch on cat{
                    when 'ElixirSuite__MOR_MAR__c'{
                        showMar = true;
                    }
                    when 'ElixirSuite__Lab_Order__c'{
                        showLabOrder = true;
                    }
                    when 'ElixirSuite__Prescriptions__c'{
                        prescriptions = true;
                    }
                    when 'ElixirSuite__Problem_List__c'{
                        problems = true;
                        System.debug('found problems setting it true: ' + problems);
                    }
                    when 'ElixirSuite__Allergies_Medical_Alerts__c'{
                        allergies = true;
                    }
                    when 'ElixirSuite__Diagnosis_Code__c' {
                        showDiagnosisCode = true;
                    }   
                    when 'ElixirSuite__Vital_Signs__c' {
                        showVitalSigns = true;
                    }
                    when 'ElixirSuite__Procedure_Code__c' {
                        showProcedureCode = true;
                    }
                }
            }
        }
        //String formsCategoryBundle = ApexPages.currentPage().getParameters().get('fBundle');
        //System.debug('orderId---' + orderId+'formsCategoryBundle '+formsCategoryBundle); 
        careEp=[select id,Name,CreatedDate,ElixirSuite__Account__c 
                from ElixirSuite__Visits__c 
                where Id =:orderId WITH SECURITY_ENFORCED];
        getlabOrderInfo(careEp[0].ElixirSuite__Account__c, orderId);
        AccData= getAccData(careEp[0].ElixirSuite__Account__c, orderId);
        acctRecordID = careEp[0].ElixirSuite__Account__c;
        //getFormsDataForPDF(careEp[0].ElixirSuite__Account__c,formsCategoryBundle);
        allowPDFRender = true;
        // AccData= getAccData(orderId);
        pdfData= getPDFData();
        
        
    }
    public static boolean doesFieldExist(String objName, string fieldName)
    {
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception e) {
            ExceptionLog.logError(e);
        }
        
        return false;
    }
    public class CareEpisodePDFWrapper {
        public String fName {get;set;}
        public String fCName {get;set;}
        public String formUniqueID {get;set;}
        public String accountRecordID {get;set;}
        public String joinedValue {get;set;}
    }
    
    public List<Form_Object__mdt> fetchAllObjectsInCS(){ 
        return [select Object_Name__c from Form_Object__mdt WHERE Object_Name__c!=NULL WITH SECURITY_ENFORCED];
    }
    
    public  void getlabOrderInfo(Id accId, Id visitId){    
        
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

        allerList =  [ SELECT Id, ElixirSuite__Allergy_Name__c, ElixirSuite__Allergy_Name1__c,ElixirSuite__Allergy_Name1__r.Name,
                      ElixirSuite__Reaction__c, ElixirSuite__Reaction1__c, ElixirSuite__Reaction1__r.Name,
                      ElixirSuite__Substance__c, ElixirSuite__Substance1__c, ElixirSuite__Substance1__r.Name,
                      ElixirSuite__Severity__c, ElixirSuite__Severity1__c,  ElixirSuite__Severity1__r.Name
                      FROM ElixirSuite__Medical_Examination__c
                      WHERE ElixirSuite__Account__c = :accId
                      AND ElixirSuite__Care_Episode__c = :visitId
                      AND RecordType.Name = 'Allergy'
                      WITH SECURITY_ENFORCED
                     ];
        
        // labOrderList= [SELECT Id,Name,ElixirSuite__Status__c,ElixirSuite__Frequency__c,CreatedDate
                       
        //                FROM ElixirSuite__UA_Sample_Details__c  
        //                WHERE ElixirSuite__Account__c= :accId
        //                AND ElixirSuite__Care_Episode__c= :visitId WITH SECURITY_ENFORCED] ;
        
        // fill labOrderList or chcLabOrderList based on custom setting
        String labOrderPriority = getLabOrderPriority();
        switch on labOrderPriority {
            when 'Dummy LabOrder' {
                showCHCLabOrder = false;
                chcLabOrderList = new List<ElixirSuite__Lab_Order__c>();                
                // labOrderList = [SELECT Id ,Name, ElixirSuite__Status__c, ElixirSuite__Frequency__c, CreatedDate
                //                   FROM ElixirSuite__UA_Sample_Details__c  
                //                  WHERE ElixirSuite__Account__c= :accId
                //                    AND ElixirSuite__Care_Episode__c= :visitId
                //                   WITH SECURITY_ENFORCED];

                // SELECT Id, Name, ElixirSuite__Medical_Test__c, ElixirSuite__Status__c, ElixirSuite__Start_Date__c FROM ElixirSuite__UA_Sample_Details__c
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
      
        // ElixirSuite__Prescription_Order__c[] parentPresLst  = [SELECT Id,Name,ElixirSuite__Type__c,ElixirSuite__Route_New__c,ElixirSuite__Drug_Name__c,ElixirSuite__Ferquency__c,ElixirSuite__Route__c,CreatedDate,
        //            ElixirSuite__Prescription_Order__c
        //            FROM ElixirSuite__Prescription_Order__c  
        //            WHERE ElixirSuite__Account__c = :accId
        //            AND ElixirSuite__Care_Episode__c= :visitId WITH SECURITY_ENFORCED] ;
        // Set<Id> presId = new Set<Id>();
        // for(ElixirSuite__Prescription_Order__c pc : parentPresLst){
        //     presId.add(pc.Id);
        // }
       /*  presList = [SELECT Id,Name,ElixirSuite__Type__c,ElixirSuite__Drug_Name__c,ElixirSuite__Route_New__c,ElixirSuite__Ferquency__c,ElixirSuite__Route__c,CreatedDate,
                   ElixirSuite__Prescription_Order__c, ElixirSuite__Reason_new__c
                   FROM ElixirSuite__Prescription_Order__c  
                   WHERE ElixirSuite__Account__c = :accId
                   AND ElixirSuite__Care_Episode__c= :visitId
                   AND ElixirSuite__Drug_Name__c !=null
                   WITH SECURITY_ENFORCED ];*/
            presList = [SELECT Id,Name,ElixirSuite__Drug_Name__c,ElixirSuite__Medication__c,ElixirSuite__Dosage_Form__c,
                        ElixirSuite__Status__c,ElixirSuite__Start_Date__c,ElixirSuite__Direction__c,
                        ElixirSuite__Patient_SIG__c, ElixirSuite__Prescription_Guid__c, ElixirSuite__Reason_new__c
                        FROM ElixirSuite__Prescription_Order__c  
                        WHERE ElixirSuite__Account__c = :accId
                        AND ElixirSuite__Care_Episode__c= :visitId
                        WITH SECURITY_ENFORCED ];
      
        
        morList= [SELECT Id,Name,ElixirSuite__Drug_Name__c,ElixirSuite__Frequency__c,ElixirSuite__Medication_Name__c,
                  CreatedDate,ElixirSuite__Status__c,ElixirSuite__Reasons__c, ElixirSuite__Frequency__r.Name
                  FROM ElixirSuite__MAR_MOR__c  
                  WHERE ElixirSuite__Account__c = :accId 
                  AND ElixirSuite__Care_Episode__c= :visitId WITH SECURITY_ENFORCED] ;
        
       /* diagnosisCodeList = [SELECT Id, ElixirSuite__Diagnosis_Code__r.name, ElixirSuite__Diagnosis_Code__r.ElixirSuite__ICD_Description__c, ElixirSuite__Diagnosis_Code__r.ElixirSuite__Diagnosis_Type__c, ElixirSuite__Diagnosis_Code__r.ElixirSuite__Effective_Date__c
                            FROM ElixirSuite__Diagnosis_Code__c
                            WHERE ElixirSuite__Diagnosis_Code__r.ElixirSuite__Care_Episode__c = :visitId
                            AND ElixirSuite__Problem__r.ElixirSuite__Account__c = :accId
                            AND ElixirSuite__Diagnosis_Code__c != null
                            WITH SECURITY_ENFORCED
        					];*/
        diagnosisCodeList = [SELECT Id, Name,  ElixirSuite__Diagnosis_Code_and_Name__c, RecordType.Name,
                             ElixirSuite__Account__c, ElixirSuite__Code_Description1__c, ElixirSuite__Care_Episode__c,
                             ElixirSuite__Diagnosis_Type__c, ElixirSuite__Effective_Date__c
                             FROM ElixirSuite__ICD_Codes__c
                             WHERE ElixirSuite__Care_Episode__c = :visitId
                             AND ElixirSuite__Account__c = :accId
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

        // String patientProcedureRecordTypeId = '';
        // List<RecordType> allProcedureRecordTypes = [SELECT Id,Name FROM RecordType WHERE sObjectType='ElixirSuite__Procedure__c' AND Name = 'Patient Procedure'];
        // if (allProcedureRecordTypes != null && allProcedureRecordTypes.size() > 0) {
        //     patientProcedureRecordTypeId = allProcedureRecordTypes[0].Id;
        // }

        String patientProcedureRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
        procedureCodeList = [
            SELECT Id, Name, ElixirSuite__Code_Category__c, ElixirSuite__Code_Description__c, ElixirSuite__Place_Of_Service_Picklist__c, ElixirSuite__Days_Units__c, ElixirSuite__Modifier1__r.Name, ElixirSuite__Modifier2__r.Name,  ElixirSuite__Modifier3__r.Name,  ElixirSuite__Modifier4__r.Name
              FROM ElixirSuite__Procedure__c
             WHERE ElixirSuite__Account__c = :accId
               AND ElixirSuite__Visits__c = :visitId
               AND RecordTypeId = :patientProcedureRecordTypeId
              WITH SECURITY_ENFORCED
        ];
        
        
        doctorNotes = [select Id,Name,ElixirSuite__Notes__c,ElixirSuite__Form__r.Name, CreatedDate
                       from ElixirSuite__Notes__c  where ElixirSuite__Account__c =:accId
                       AND ElixirSuite__Type__c ='Doctor Notes' 
                       WITH SECURITY_ENFORCED
                       order by CreatedDate asc] ;
        System.debug('doc note '+doctorNotes);
        nursingNotes = [select Id,Name,ElixirSuite__Note__c,ElixirSuite__Form__r.Name,ElixirSuite__Notes__c,CreatedDate
                        from ElixirSuite__Notes__c  where ElixirSuite__Account__c =:accId
                        AND ElixirSuite__Type__c ='Nursing Notes'
                        WITH SECURITY_ENFORCED
                         order by CreatedDate asc] ;
        clinicalNotes = [select Id,Name,ElixirSuite__Note__c,ElixirSuite__Form__r.Name,ElixirSuite__Notes__c,CreatedDate
                         from ElixirSuite__Notes__c  where ElixirSuite__Account__c =:accId
                         AND ElixirSuite__Type__c ='Clinician Notes' 
                         WITH SECURITY_ENFORCED
                         order by CreatedDate asc] ;
        sessionNotes = [select Id,Name,ElixirSuite__Note__c,ElixirSuite__Form__r.Name , recordtype.name ,ElixirSuite__Notes__c,
                        CreatedDate
                        from ElixirSuite__Notes__c  where ElixirSuite__Account__c =:accId
                        AND ElixirSuite__Type__c ='Session Notes'
                        WITH SECURITY_ENFORCED
                        order by CreatedDate asc] ;
        
    }
    public static ElixirSuite__Elixir_Custom_Setting__c getPDFData(){
        ElixirSuite__Elixir_Custom_Setting__c record = ElixirSuite__Elixir_Custom_Setting__c.getInstance() ;
        return record ;
    }
    
    public static wrapperAcc getAccData(Id accId, Id orderId)
    {
        
        wrapperAcc wrpData = new wrapperAcc();
        try{
        List<Account> accList = [SELECT Id,Name,ElixirSuite__Insured_s_Address__c,BillingAddress,ElixirSuite__Gender__c,
                                 ShippingAddress,Phone,ElixirSuite__Email_Id__c, ElixirSuite__Outstanding_Amount__c,
                                 ElixirSuite__MRN_Number_New__c,ElixirSuite__Patient_s_Birth_Date__c,ElixirSuite__DOB__c
                                 FROM Account 
                                 WHERE Id= :accId  WITH SECURITY_ENFORCED
                                 LIMIT 1];
        if(accList!=null && accList.size()>0){
            
            for(Account acc:accList){
                wrpData.Name = acc.Name;
                wrpData.MRN = acc.ElixirSuite__MRN_Number_New__c;
                wrpData.Dob = acc.ElixirSuite__DOB__c;
                wrpData.Gender = acc.ElixirSuite__Gender__c;
                wrpData.phn=acc.Phone;
                
                wrpData.add=acc.ElixirSuite__Insured_s_Address__c;
                wrpData.email=acc.ElixirSuite__Email_Id__c;
                
            }
        }
        
        list<ElixirSuite__Visits__c> TranData = new list<ElixirSuite__Visits__c>();
        TranData=[SELECT Id,Name,CreatedDate,CreatedById, CreatedBy.Name,ElixirSuite__Visit_Start__c,ElixirSuite__Visit_End__c 
                  FROM ElixirSuite__Visits__c 
                  WHERE Id = :orderId WITH SECURITY_ENFORCED];
        
        if(TranData!=null && TranData.size()>0){
            for(ElixirSuite__Visits__c mt:TranData){
                wrpData.visitName = mt.Name;
                wrpData.VisitCreatedDate= mt.CreatedDate;
                wrpData.createdBy= mt.CreatedBy.Name;
                wrpData.todaysDate= system.today();
                wrpData.dos=mt.ElixirSuite__Visit_Start__c;
                wrpData.dosEnd=mt.ElixirSuite__Visit_End__c;              
            }
        }
        
        
        
        
        
        List<ElixirSuite__Notes__c> doctorNote = [select Id,Name,ElixirSuite__Notes__c,ElixirSuite__Form__r.Name,
                                                  CreatedDate
                                                  from ElixirSuite__Notes__c  where ElixirSuite__Account__c =:accId
                                                  AND ElixirSuite__Type__c ='Doctor Notes' WITH SECURITY_ENFORCED] ;
        
        if(doctorNote!=null && doctorNote.size()>0){
            
            for(ElixirSuite__Notes__c nt:doctorNote){
                wrpData.docName = nt.Name;
                wrpData.Notes = nt.ElixirSuite__Notes__c;
                wrpData.CrDate = nt.CreatedDate;
                
                
            }
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return wrpData;
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
    
    public class wrapperAcc {
        
        public String docName {get;set;} 
        public String Notes {get;set;}
        public DateTime CrDate {get;set;}
        public String Name {get;set;} 
        public String MRN {get;set;}
        public Date Dob {get;set;}
        public String Gender {get;set;}
        public String add {get;set;}
        public String phn {get;set;}
        public String email {get;set;}
        public String tranName {get;set;} 
        public Date tranDate {get;set;}
        public Date payDue {get;set;} 
        public Decimal amtDue {get;set;}
        public String item {get;set;}
        public Integer quantity {get;set;}
        public decimal price {get;set;}
        public decimal amount {get;set;}
        public decimal total {get;set;}
        public String visitName {get;set;}
        public Datetime VisitCreatedDate {get; set;}
        public String createdBy {get;set;}
        public Date todaysDate {get; set;}
        public Integer Phone {get; set;}
        public String probName {get; set;}
        public Datetime dos {get; set;}
        public Datetime dosEnd {get; set;}        
    }
    
}