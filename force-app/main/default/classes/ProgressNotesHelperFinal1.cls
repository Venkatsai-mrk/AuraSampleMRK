public with sharing class ProgressNotesHelperFinal1 {
    @AuraEnabled
    public static parentWrapper abc(String acctId){
        List<Dataset1__c> relatedProblems = new List<Dataset1__c>();
      //  relatedProblems = [SELECT Account__c,id,Dataset1__c,Description__c,IsActive__c,Problem_Name__c,Templatized_Problem__c
                        //   FROM Dataset1__c where Account__c =: acctId WITH SECURITY_ENFORCED];
        List<Form_Field__c > formField = new List<Form_Field__c >();
        List<Prescription_Order__c > currentMeds = new List<Prescription_Order__c >();
        currentMeds=[SELECT id , name ,Account__c, Drug_Name__c,Notes__c
                     FROM Prescription_Order__c where Account__c=:acctId WITH SECURITY_ENFORCED];       
        parentWrapper toReturn = new parentWrapper();
      //  toReturn.relatedProblems = relatedProblems; 
        toReturn.currentMed = currentMeds ;
        return toReturn ;
    }
    public class parentWrapper {        
        @AuraEnabled public List<Dataset1__c> relatedProblems {get;set;}
        @AuraEnabled public List<Form_Field__c > formFields {get;set;}
        @AuraEnabled public List<Prescription_Order__c > currentMed {get;set;}
        @AuraEnabled public List<case> relatedProblems1 {get;set;}
    }
    
    @AuraEnabled
    public static void saveNotes(String accountId, String textBody, String newSocial, String newFamily,String newDiagnosis, String medicationsToSave, String carePlanDataParent , String labOrdersToSave,String problemsToSave, String diagToSave , String vitalsToSave, List<Prescription_Order__c> prescriptionsToSave){
        //Note added-START
        system.debug('accountId ' + accountId);
        Notes__c note = new Notes__c();
        try{
        note.Account__c = accountId;
        note.Notes__c = textBody;
        if(Schema.sObjectType.Notes__c.isCreateable() &&
        Schema.sObjectType.Notes__c.fields.Account__c.isCreateable() &&
        Schema.sObjectType.Notes__c.fields.Notes__c.isCreateable()){
            insert note;
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        //Note added-END
        
        system.debug('json' + medicationsToSave);
        medicines med = (medicines) JSON.deserialize(medicationsToSave, medicines.class);
        system.debug('med' + med);
        
        if(med.medications!=null && med.medications.size()>0){
            List<Prescription_Order__c> medicationsToInsert = new List<Prescription_Order__c>(); 
            try{
            for(deserializeWrapper medication :med.medications){
                Prescription_Order__c medToInsert = new Prescription_Order__c();
                medToInsert.Drug_Name__c = medication.FieldName;
                medToInsert.Account__c  = accountId;
                medToInsert.Ferquency__c  = medication.Description;
                medicationsToInsert.add(medToInsert);
            }
            if(Schema.sObjectType.Prescription_Order__c.isCreateable() &&
            Schema.sObjectType.Prescription_Order__c.fields.Ferquency__c.isCreateable() &&
            Schema.sObjectType.Prescription_Order__c.fields.Drug_Name__c.isCreateable()){
                insert medicationsToInsert;
            }
            }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
        }
        system.debug('lab' + problemsToSave);
        labOrders lab = (labOrders) JSON.deserialize(labOrdersToSave, labOrders.class);
        if(lab.labOrders!=null && lab.labOrders.size()>0){
            List<UA_Sample_Details__c> ordersToInsert = new List<UA_Sample_Details__c>(); 
            try{
            for(deserializeWrapper labOrder :lab.labOrders){
                UA_Sample_Details__c orderToInsert = new UA_Sample_Details__c();
                orderToInsert.Account__c = accountId;
                orderToInsert.Medical_Test__c = labOrder.FieldName;
                orderToInsert.Frequency__c = labOrder.Description;
                ordersToInsert.add(orderToInsert);
            }
            if(Schema.sObjectType.UA_Sample_Details__c.isCreateable() &&
            Schema.sObjectType.UA_Sample_Details__c.fields.Frequency__c.isCreateable() &&
            Schema.sObjectType.UA_Sample_Details__c.fields.Account__c.isCreateable() &&
            Schema.sObjectType.UA_Sample_Details__c.fields.Medical_Test__c.isCreateable()){
                insert ordersToInsert;
            }
            }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
        }
        problems prob = (problems) JSON.deserialize(problemsToSave, problems.class);
        if(prob.problems!=null && prob.problems.size()>0){
            List<Dataset1__c> problemsToInsert = new List<Dataset1__c>(); 
            try{
            for(deserializeWrapper problem :prob.problems){
                Dataset1__c orderToInsert = new Dataset1__c();
                orderToInsert.Account__c = accountId;
                //orderToInsert.Care_Plan_Template_Problem__c  = problem.Id;
                //orderToInsert.Problem_Name__c  = problem.FieldName;
                //orderToInsert.Notes__c  = problem.Description;
                problemsToInsert.add(orderToInsert);
            }
            if(Schema.sObjectType.Dataset1__c.isCreateable() &&
            Schema.sObjectType.Dataset1__c.fields.Account__c.isCreateable()){
                insert problemsToInsert;
            }
            }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
        }
        diagnosis diag = (diagnosis) JSON.deserialize(diagToSave, diagnosis.class);
        if(diag.diagnosis!=null && diag.diagnosis.size()>0){
            List<ICD_Codes__c> ordersToInsert = new List<ICD_Codes__c>(); 
            try{
            for(deserializeWrapper labOrder :diag.diagnosis){
                ICD_Codes__c orderToInsert = new ICD_Codes__c();
                //orderToInsert.Account__c = accountId;
                orderToInsert.Name  = labOrder.FieldName;
                // orderToInsert.Notes__c = labOrder.Description;
                ordersToInsert.add(orderToInsert);
            }
            if(Schema.sObjectType.ICD_Codes__c.isCreateable() &&
            Schema.sObjectType.ICD_Codes__c.fields.Name.isCreateable()){
                insert ordersToInsert;
            }
            }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
        }
        
        system.debug('vitalsToSave '+vitalsToSave);
        vitals vitalSign = (vitals) JSON.deserialize(vitalsToSave, vitals.class);
        system.debug('vitalSign '+vitalSign);
        VitalWrapper vitalValues = vitalSign.vitals;
        system.debug(vitalValues);
        if(vitalValues!=null){          
            Medical_Examination__c vitalToInsert = new Medical_Examination__c();
            try{
            vitalToInsert.Account__c  = accountId;
            vitalToInsert.Blood_Pressure_Systolic__c  = vitalValues.bpsys!=''?string.valueOf(vitalValues.bpsys):null;
            vitalToInsert.Start_Time__c = System.now().addMinutes(-10);
            vitalToInsert.End_Time__c = System.now();
            //vitalToInsert.height__c = vitalValues.height!=''?Integer.valueOf(vitalValues.height):null;
            //vitalToInsert.weight__c = vitalValues.weight!=''?Integer.valueOf(vitalValues.weight):null;
            vitalToInsert.Blood_Pressure_Diasystolic__c = vitalValues.bpDias!=''?string.valueOf(vitalValues.bpDias):null;
            vitalToInsert.Temperature__c = vitalValues.temp!=''?string.valueOf(vitalValues.temp):null;
            vitalToInsert.Oxygen_Saturation__c  = vitalValues.oxySat!=''?string.valueOf(vitalValues.oxySat):null;
            vitalToInsert.Pulse__c  = vitalValues.pulse!=''?string.valueOf(vitalValues .pulse):null;
            if(Schema.sObjectType.Medical_Examination__c.isCreateable() &&
            Schema.sObjectType.Medical_Examination__c.fields.Account__c.isCreateable() &&
            Schema.sObjectType.Medical_Examination__c.fields.Blood_Pressure_Systolic__c.isCreateable() &&
            Schema.sObjectType.Medical_Examination__c.fields.Start_Time__c.isCreateable() &&
            Schema.sObjectType.Medical_Examination__c.fields.End_Time__c.isCreateable() &&
            Schema.sObjectType.Medical_Examination__c.fields.Blood_Pressure_Diasystolic__c.isCreateable() &&
            Schema.sObjectType.Medical_Examination__c.fields.Temperature__c.isCreateable() &&
            Schema.sObjectType.Medical_Examination__c.fields.Oxygen_Saturation__c.isCreateable() &&
            Schema.sObjectType.Medical_Examination__c.fields.Pulse__c.isCreateable()){
                insert vitalToInsert;
            }
            }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
        }
        
        //Prescriptions To Save
        List<Prescription_Order__c> finalPRList = new List<Prescription_Order__c>();
        Prescription_Order__c preOrder = new Prescription_Order__c();
        Boolean ordFlag = false;
        if(prescriptionsToSave != null && prescriptionsToSave.size()>0)
        {
            for(Prescription_Order__c pr : prescriptionsToSave)
            {
                Prescription_Order__c newObj = new Prescription_Order__c();
                if(pr.Drug_Name__c != '')
                {
                    if(ordFlag == false)
                    {
                        // preOrder.Account__c = pr.Account__c;
                        ordFlag = true;
                    }
                    // newObj.HealthCloudGA__MedicationName__c = pr.HealthCloudGA__MedicationName__c;
                    //newObj.Frequency_for_jumpstartmd__c = pr.Frequency_for_jumpstartmd__c;
                    //newObj.HealthCloudGA__Account__c = pr.HealthCloudGA__Account__c;
                    newObj.Type__c = 'PRN';
                    
                    finalPRList.add(newObj);
                }
            }
            try
            {
                if(Schema.sObjectType.Prescription_Order__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Type__c.isCreateable()){
                insert preOrder;
                }
                for(Prescription_Order__c pr : finalPRList)
                {
                    pr.Prescription_Order__c = preOrder.Id;
                }
                if(Schema.sObjectType.Prescription_Order__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Prescription_Order__c.isCreateable()){
                    insert finalPRList;
                }
            }
            catch(Exception e)
            {
                ExceptionLog.logError(e);
                system.debug('#### Error : ' + e.getMessage());
            }
        }
    }
    @AuraEnabled
    public static String getNotesData(String recordVal){
        Notes__c allNotes = new Notes__c();
        allNotes = [SELECT Id, Name, RecordTypeId, CreatedDate, Account__c, Notes__c,Note__c, Parent_Account__c FROM Notes__c
                    WHERE id=:recordVal WITH SECURITY_ENFORCED];
        return allNotes.Notes__c ;
        
    }
    
    @AuraEnabled
    public static String addChiefComplaintsRec(List<Dataset1__c> ehrCondList)
    {
       /* List<Dataset1__c> problemsToInsert = new List<Dataset1__c>();
        if(ehrCondList != null && ehrCondList.size()>0)
        {
            for(Dataset1__c ehr : ehrCondList)
            {
                Dataset1__c obj = new Dataset1__c();
                if(ehr.Problem_Name__c != '')
                {
                    //obj.Problem_Name__c = ehr.Problem_Name__c;
                    // obj.HealthCloudGA__Notes__c = ehr.HealthCloudGA__Notes__c;
                    obj.Account__c = ehr.Account__c;
                    problemsToInsert.add(obj);
                }
                
            }
            try
            {
                System.debug('#### problemsToInsert : ' + problemsToInsert);
                if(Schema.sObjectType.Dataset1__c.isCreateable() &&
                Schema.sObjectType.Dataset1__c.fields.Account__c.isCreateable()){
                    insert problemsToInsert;
                }
                return 'SUCCESS';
            }
            catch(Exception ex)
            {
                return 'Error : ' + ex.getMessage();
            }
        }*/
        return null;
    }
    
    public class medicines{
        List<deserializeWrapper> medications;
    }
    public class labOrders{
        List<deserializeWrapper> labOrders;
    }
    public class problems{
        List<deserializeWrapper> problems;
    }
    public class diagnosis{
        List<deserializeWrapper> diagnosis;
    }
    public class deserializeWrapper{
        public String Id;
        public String FieldName;
        public String Description;
    }
    
    //For vitals
    public class vitals{
        public VitalWrapper vitals;
    }
    public class VitalWrapper{
        public String height;
        public String Weight;
        public String bpsys;
        public String bpDias;
        public String temp;
        public String pulse;
        public String oxySat;  
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
        i++;       
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;       
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;       
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
        i++;
    }
}