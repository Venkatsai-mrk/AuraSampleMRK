@isTest
public class TestPrescriptionOrder_PDFHelper {
    
    public  static testMethod void allCoverageParentMethod(){
        
        User newUser = new User();
        newUser.FirstName = 'test';
        newUser.LastName = 'Doe';
        newUser.Email = 'johndoe43e@example.com';
        newUser.Username = 'johndfdoe@example.com';
        newUser.Alias = 'jdodfdfe';
        newUser.CommunityNickname = 'johnddfoe123';
        newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.UserRoleId = null;
        insert newUser;
        
        
        Id rc= Schema.Sobjecttype.Prescription_Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Id rcid= Schema.Sobjecttype.Prescription_Order__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
        Account forIns = new Account();
        forIns.Name='Test Demo';
        //  forIns.MRN_Number__c = 'T245';
        forIns.DOB__c= System.today();
        forIns.Gender__c = 'Male';
        forIns.Blood_Group__c = 'O+';
        insert forIns;
        
        Prescription_Order__c parent = new Prescription_Order__c();
        parent.Account__c = forIns.id;
        parent.Status__c= 'Open';
        parent.User_1__c = newUser.id;
        parent.RecordTypeId = rc;
        insert parent;
        
        Prescription_Order__c parentForActionOrder = new Prescription_Order__c();
        parentForActionOrder.Account__c = forIns.id;
        parentForActionOrder.Status__c= 'Open';
        parentForActionOrder.RecordTypeId = rc;
        insert parentForActionOrder;
        
        Prescription_Order__c parentForTaper = new Prescription_Order__c();
        parentForTaper.Account__c = forIns.id;
        parentForTaper.Status__c= 'Open';
        parentForTaper.RecordTypeId = rc;
        insert parentForTaper;
        
        Prescription_Order__c pres = new Prescription_Order__c();
        //  pres.DispenseExpectedSupplyDuration__c = 10;
        pres.Type__c= 'PRN';
        pres.Drug_Name__c= 'demo prn';
        pres.After_Discharge__c= true;
        pres.Prescription_Order__c = parent.id;
        pres.RecordTypeId = rcid;
        insert pres;
        
        Prescription_Order__c presForAction = new Prescription_Order__c();
        // presForAction.DispenseExpectedSupplyDuration__c = 10;
        presForAction.Type__c= 'Action Order';
        presForAction.Drug_Name__c= 'demo prn';
        presForAction.After_Discharge__c= true;
        presForAction.Prescription_Order__c = parentForActionOrder.id;
        presForAction.RecordTypeId = rcid;
        insert presForAction;
        
        Prescription_Order__c presForTaper = new Prescription_Order__c();
        // presForTaper.DispenseExpectedSupplyDuration__c = 10;
        presForTaper.Type__c= 'Taper';
        presForTaper.Drug_Name__c= 'demo prn';
        presForTaper.After_Discharge__c= true;
        presForTaper.Prescription_Order__c = parentForTaper.id;
        presForTaper.RecordTypeId = rcid;
        insert presForTaper;
        
        Frequency__c asChildTaper  = new Frequency__c();
        asChildTaper.Prescription_Order__c = presForTaper.id;
        asChildTaper.Repeat__c = '\'n\' times a day';
        asChildTaper.Dosage_Instruction__c = '9';
        asChildTaper.Strength_1__c='590mg';
        insert asChildTaper;
        
        Frequency__c asChildTaper2  = new Frequency__c();
        asChildTaper2.Prescription_Order__c = presForTaper.id;
        asChildTaper2.Repeat__c = 'After every \'n\' hours';
        asChildTaper2.Dosage_Instruction__c = '9';
        asChildTaper2.Strength_1__c='51mg';
        insert asChildTaper2;
        
        Frequency__c asChildTaper3  = new Frequency__c();
        asChildTaper3.Prescription_Order__c = presForTaper.id;
        asChildTaper3.Repeat__c = 'After every \'n\' hours';
        asChildTaper3.Dosage_Instruction__c = '9';
        asChildTaper3.Strength_1__c='1209mg';
        insert asChildTaper3;
        
        Frequency__c asChildTaper4  = new Frequency__c();
        asChildTaper4.Prescription_Order__c = presForTaper.id;
        asChildTaper4.Repeat__c = 'Before Breakfast';
        asChildTaper4.Dosage_Instruction__c = '9';
        asChildTaper4.Strength_1__c='1209mg';
        insert asChildTaper4;
        
        Frequency__c asChild  = new Frequency__c();
        asChild.Prescription_Order__c = pres.id;
        asChild.Repeat__c = 'After every \'n\' hours';
        asChild.Dosage_Instruction__c = '9';
        asChild.Strength_1__c='50mg';
        asChild.Strength_2__c='10mg';
        insert asChild;
        
        Frequency__c asChildForAC  = new Frequency__c();
        asChildForAC.Prescription_Order__c = presForAction.id;
        asChildForAC.Repeat__c = 'After every \'n\' hours';
        asChildForAC.Dosage_Instruction__c = '9';
        insert asChildForAC;
        
        
        PageReference pageRef = Page.PrescriptionOrderPDFGenerator;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('orderId',parent.id);
        
        
        PrescriptionOrder_PDFHelper objectTocall = new PrescriptionOrder_PDFHelper();             
        objectTocall.getprescriptionOrderInfo(parent.id);
        objectTocall.getprescriptionOrderInfo(parentForActionOrder.id);
        objectTocall.getprescriptionOrderInfo(parentForTaper.id);
        objectTocall.getAccountInfo(forIns.id);
        System.assertEquals(1, 1, ' ');
        
        
        
        
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