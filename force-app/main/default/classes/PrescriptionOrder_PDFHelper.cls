public with sharing class PrescriptionOrder_PDFHelper {
// Test class name : NOT YET WRITTEN 
    public Prescription_Order__c prescriptionOrder {get;set;}
    public Account accounts {get;set;}
    public Boolean startPDFGeneration {get;set;}   
    public List<Prescription_Order__c> allRecordsForPrescription{get;set;}
    public List<Frequency__c> dosagerecords{get;set;}
    public List<MedicationDataWrapper> medicationDataOnVF {get;set;}
    public List<ApprovalWrapper> approved {get;set;}
    
    public PrescriptionOrder_PDFHelper(){
        String orderId = ApexPages.currentPage().getParameters().get('orderId');
        System.debug('orderId for nprecription ---' + orderId);     
        getprescriptionOrderInfo(orderId);
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=PrescriptionprescriptionOrder Order'+prescriptionOrder.Name+'.pdf');
        
    }
    
    public List<MedicationDataWrapper> getprescriptionOrderInfo(Id orderId){
        List<ApprovalWrapper> approverLst = new List<ApprovalWrapper>();
        List<Prescription_Order__c> recordPrescription = new  List<Prescription_Order__c>();
        List<Frequency__c> dosageRecords  = new List<Frequency__c>();
        List<MedicationDataWrapper> medicationData = new  List<MedicationDataWrapper>();
        List<String> dosageStrengths = new List<String>();
         List<String> repeatedFrequency = new List<String>();
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
        List<Master_Object__c> approverLabels = [SELECT Id, Approval_Level__c, Approver_Custom_Label__c 
                                                 FROM Master_Object__c 
                                                 WHERE Approval_Level_For__c = 'Prescription Order' 
                                                 AND recordTypeId =:recordTypeId WITH SECURITY_ENFORCED
                                                 ORDER BY Approval_Level__c];
        Integer levels = approverLabels.size();
        
        List<Prescription_Order__c> orderLst = [SELECT id, Name ,Account__c, User_1__r.UserRole.Name, User_2__r.UserRole.Name, User_3__r.UserRole.Name,
                                                User_1__r.Name,User_2__r.Name, User_3__r.Name, User_1__r.Signature_Attachment_Id__c,
                                                User_2__r.Signature_Attachment_Id__c, User_3__r.Signature_Attachment_Id__c,
                                                Date_Of_Approval_1__c, Date_Of_Approval_2__c, Date_Of_Approval_3__c,
                                                Comment_1__c, Comment_2__c, Comment_3__c
                                                FROM Prescription_Order__c 
                                                WHERE id=:orderId 
                                                AND recordtype.developername = 'Order' 
                                                WITH SECURITY_ENFORCED];
        
        Prescription_Order__c order = orderLst[0];
        if(order.User_1__r.Name != null){
            ApprovalWrapper wrpr = new ApprovalWrapper();
            wrpr.UserName = order.User_1__r.Name;
            wrpr.UserRoleName = order.User_1__r.UserRole.Name;
            wrpr.attachId = order.User_1__r.Signature_Attachment_Id__c;
            wrpr.dateOfApproval = order.Date_Of_Approval_1__c;
            wrpr.comment = order.Comment_1__c;
            if(levels>=1){
                if(!String.isBlank(approverLabels[0].Approver_Custom_Label__c)){
                    wrpr.customLabel = approverLabels[0].Approver_Custom_Label__c;
                }
            }
            approverLst.add(wrpr);
        }
        if(order.User_2__r.Name != null){
            ApprovalWrapper wrpr = new ApprovalWrapper();
            wrpr.UserName = order.User_2__r.Name;
            wrpr.UserRoleName = order.User_2__r.UserRole.Name;
            wrpr.attachId = order.User_2__r.Signature_Attachment_Id__c;
            wrpr.dateOfApproval = order.Date_Of_Approval_2__c;
            wrpr.comment = order.Comment_2__c;
            if(levels>=2){
                if(!String.isBlank(approverLabels[1].Approver_Custom_Label__c)){
                    wrpr.customLabel = approverLabels[1].Approver_Custom_Label__c;
                }
            }
            approverLst.add(wrpr);
        }
        if(order.User_3__r.Name != null){
            ApprovalWrapper wrpr = new ApprovalWrapper();
            wrpr.UserName = order.User_3__r.Name;
            wrpr.UserRoleName = order.User_3__r.UserRole.Name;
            wrpr.attachId = order.User_3__r.Signature_Attachment_Id__c;
            wrpr.dateOfApproval = order.Date_Of_Approval_3__c;
            wrpr.comment = order.Comment_3__c;
            if(levels>=3){
                if(!String.isBlank(approverLabels[2].Approver_Custom_Label__c)){
                    wrpr.customLabel = approverLabels[2].Approver_Custom_Label__c;
                }
            }
            approverLst.add(wrpr);
        }
        

        approved = approverLst;
        system.debug('orderLst===='+orderLst);
        prescriptionOrder = orderLst[0];
        List<Prescription_Order__c> prescriptionRecord  = [select id,Number_of_Times_Days_Weeks__c,Type__c,Ferquency__c,Number_of_days__c,DRUG_NAME__C,After_Discharge__c,
                                                                                 (select id,Strength_1__c,Strength_2__c,Strength_3__c,Strength_4__c,Strength_5__c,Strength_6__c,Strength_7__c,Strength_8__c,
                                                                                  Strength_9__c,Strength_10__c,Strength_11__c,Strength_12__c,Strength_13__c,Strength_14__c,Strength_15__c,Strength_16__c
                                                                                  ,Strength_17__c,Strength_18__c,Strength_19__c,Strength_20__c,Strength_21__c,Strength_22__c,Strength_23__c,Strength_24__c,
                                                                                  Strength__c,Repeat__c,Dosage_Instruction__c from Frequency__r) from Prescription_Order__c where Prescription_Order__c=:orderId AND recordtype.developername = 'Medication' WITH SECURITY_ENFORCED]; 
        Integer counter= 0;
        
        
        for(Prescription_Order__c prescription : prescriptionRecord){
            system.debug('records prescription '+prescription);
            recordPrescription.add(prescription);
        }
        for(Prescription_Order__c prescription : prescriptionRecord){
			 for(Frequency__c dosage : prescription.Frequency__r){
                MedicationDataWrapper toAdd  = new MedicationDataWrapper();
                DosageRecordsForMedication childDosage  = new DosageRecordsForMedication();
                childDosage.strength=dosage.Strength__c;
                if(prescription.Type__c=='PRN'){                    
                    toAdd.medicationName=prescription.drug_name__c;
                    String nod  = String.valueOf(prescription.Number_of_Times_Days_Weeks__c);
                          /*  if(!String.isBlank(nod)){
                                system.debug('nod' + nod);
                                nod= nod.substring(0,nod.length()-3);
                                 system.debug('nod new' + nod);
                            }*/
                    toAdd.numberOfDays=nod;
                    toAdd.typeOfMedication=prescription.Type__c;
                    toAdd.strength=dosage.Strength__c;
                    toAdd.afterDisacharge= prescription.After_Discharge__c;  
                    if(dosage.Repeat__c.startsWith('\'n\' times') || dosage.Repeat__c.startsWith('After every \'n\'')){
                        String repeat  = dosage.Repeat__c;
                        String NumberOfTimes = dosage.Dosage_Instruction__c;
                        toAdd.frequency = repeat.replace('\'n\'', NumberOfTimes);                         
                    }
                    else {
                        toAdd.frequency = dosage.Repeat__c; 
                    }
                    counter=counter+1;
                    toAdd.counter=counter;
                    medicationData.add(toAdd);                    
                    
                }
                if(prescription.Type__c=='Action Order'){
                    toAdd.medicationName=prescription.Drug_Name__c;
                    String nod  = String.valueOf(prescription.Number_of_Times_Days_Weeks__c);
                          /*  if(!String.isBlank(nod)){
                                nod= nod.substring(0,nod.length()-3);
                            }*/
                    toAdd.numberOfDays=nod;
                    toAdd.typeOfMedication=prescription.Type__c;
                    toAdd.strength='--';
                    toAdd.afterDisacharge= prescription.After_Discharge__c;  
                    system.debug('done');
                    if(dosage.Repeat__c.startsWith('\'n\' times') || dosage.Repeat__c.startsWith('After every \'n\'')){
                        system.debug('done 233');
                        String repeat  = dosage.Repeat__c;
                        String NumberOfTimes = dosage.Dosage_Instruction__c;
                        toAdd.frequency = repeat.replace('\'n\'', NumberOfTimes);                         
                    }
                    else {
                        toAdd.frequency = dosage.Repeat__c; 
                    }
                    counter=counter+1;
                    toAdd.counter=counter;
                    
                    medicationData.add(toAdd);
                    
                }
                if(prescription.Type__c=='Taper'){
                   
                        
                    for(Integer i=1;i<=24;i++){
                        MedicationDataWrapper toAddTaperRecords  = new MedicationDataWrapper();
                        String StrengthAPIName = 'Strength_'+i+'__c';
                        String fieldValue  = String.valueOf(dosage.get(StrengthAPIName));
                        System.debug('fiedl value '+fieldValue);
                        if(!String.isBlank(fieldValue)){
                            fieldValue= fieldValue.replaceAll('\\s+', '');
                        }
                        System.debug('after field value  '+fieldValue);
                        //  fieldValue = fieldValue.trim();
                        //fieldValue = fieldValue.replaceAll('(\\s+)', ' ');
                        System.debug('field Vlaue '+fieldValue);
                        if(!String.isBlank(fieldValue) && (!dosageStrengths.contains(fieldValue)) && (!repeatedFrequency.contains(dosage.Repeat__c))){
                            System.debug('field Vlaue not contains '+fieldValue);
                            toAddTaperRecords.medicationName=prescription.Drug_Name__c;
                            String nod  = String.valueOf(prescription.Number_of_Times_Days_Weeks__c);
                          /*  if(!String.isBlank(nod)){
                                nod= nod.substring(0,nod.length()-3);
                            }*/
                            toAddTaperRecords.numberOfDays=nod;
                            toAddTaperRecords.typeOfMedication=prescription.Type__c;
                            toAddTaperRecords.strength=fieldValue;
                            toAddTaperRecords.afterDisacharge= prescription.After_Discharge__c;                                         
                            if(dosage.Repeat__c.startsWith('\'n\' times') || dosage.Repeat__c.startsWith('After every \'n\'')){
                                String repeat  = dosage.Repeat__c;
                                String NumberOfTimes = dosage.Dosage_Instruction__c;
                                toAddTaperRecords.frequency = repeat.replace('\'n\'', NumberOfTimes);                         
                            }
                            else {
                                toAddTaperRecords.frequency = dosage.Repeat__c; 
                            }
                            counter=counter+1;
                            toAddTaperRecords.counter=counter;
                            
                            medicationData.add(toAddTaperRecords);
                            
                            // toAdd.dosageRec.add(childDosage);
                            
                        }
                        else if (!String.isBlank(fieldValue) &&  !dosageStrengths.contains(fieldValue) && repeatedFrequency.contains(dosage.Repeat__c) ){
 							System.debug('field Vlaue not contains '+fieldValue);
                            toAddTaperRecords.medicationName=prescription.Drug_Name__c;
                            String nod  = String.valueOf(prescription.Number_of_Times_Days_Weeks__c);
                           /* if(!String.isBlank(nod)){
                                nod= nod.substring(0,nod.length()-3);
                            }*/ 
                            toAddTaperRecords.numberOfDays=nod;
                            toAddTaperRecords.typeOfMedication=prescription.Type__c;
                            toAddTaperRecords.strength=fieldValue;
                            toAddTaperRecords.afterDisacharge= prescription.After_Discharge__c;                                         
                            if(dosage.Repeat__c.startsWith('\'n\' times') || dosage.Repeat__c.startsWith('After every \'n\'')){
                                String repeat  = dosage.Repeat__c;
                                String NumberOfTimes = dosage.Dosage_Instruction__c;
                                toAddTaperRecords.frequency = repeat.replace('\'n\'', NumberOfTimes);                         
                            }
                            else {
                                toAddTaperRecords.frequency = dosage.Repeat__c; 
                            }
                            counter=counter+1;
                            toAddTaperRecords.counter=counter;
                            
                            medicationData.add(toAddTaperRecords);                            
                        }
                        
                        
                       else if (!String.isBlank(fieldValue) &&  dosageStrengths.contains(fieldValue) && !repeatedFrequency.contains(dosage.Repeat__c) ){
 							System.debug('field Vlaue not contains '+fieldValue);
                            toAddTaperRecords.medicationName=prescription.Drug_Name__c;
                            String nod  = String.valueOf(prescription.Number_of_Times_Days_Weeks__c);
                           /* if(!String.isBlank(nod)){
                                nod= nod.substring(0,nod.length()-3);
                            }*/
                            toAddTaperRecords.numberOfDays=nod;
                            toAddTaperRecords.typeOfMedication=prescription.Type__c;
                            toAddTaperRecords.strength=fieldValue;
                            toAddTaperRecords.afterDisacharge= prescription.After_Discharge__c;                                         
                            if(dosage.Repeat__c.startsWith('\'n\' times') || dosage.Repeat__c.startsWith('After every \'n\'')){
                                String repeat  = dosage.Repeat__c;
                                String NumberOfTimes = dosage.Dosage_Instruction__c;
                                toAddTaperRecords.frequency = repeat.replace('\'n\'', NumberOfTimes);                         
                            }
                            else {
                                toAddTaperRecords.frequency = dosage.Repeat__c; 
                            }
                            counter=counter+1;
                            toAddTaperRecords.counter=counter;
                            
                            medicationData.add(toAddTaperRecords);                            
                        }
                       
                        dosageStrengths.add(fieldValue);
                        repeatedFrequency.add(dosage.Repeat__c);
                    }
               
                  
                }
                System.debug('list contains strength '+dosageStrengths);
                 //dosageStrengths.clear();
                 
                
            }
           
            
            System.debug('medication data '+medicationData);
            
        }
        medicationDataOnVF=medicationData;
        allRecordsForPrescription = recordPrescription;
        getAccountInfo(prescriptionOrder.Account__c);
        return medicationDataOnVF; 
    }
    public void getAccountInfo(Id accountId){
        List<Account> accountList = [select Id, name, Age__c,DOB__c,Patient_s_Birth_Date__c from account where id=:accountId WITH SECURITY_ENFORCED];
        accounts = accountList.get(0);
    }
    
    public class ApprovalWrapper{
        public String userName{get;set;}
        public String userRoleName{get;set;}
        public DateTime dateOfApproval{get;set;}
        public String customLabel{get;set;}
        public String attachId{get;set;}
        public String comment{get;set;}
    }
    
    public class MedicationDataWrapper {
        public String medicationName {get;set;}
        public String numberOfDays  {get;set;}
        public String frequency  {get;set;}
        public String strength  {get;set;}
        public String typeOfMedication  {get;set;}
        public Boolean afterDisacharge  {get;set;}
        public Integer counter { get; set; }
        // List<DosageRecordsForMedication> dosageRec = new List<DosageRecordsForMedication>();
    }
    public class DosageRecordsForMedication { 
        String strength;
        String repeat;
        String numberOfDays; 
        String frequency;
    }
    
}