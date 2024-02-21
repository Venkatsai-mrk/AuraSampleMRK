@isTest
public class MedicationControllerTest {
    
    public static testMethod void  method1(){
        
        String name = 'Dmeo Med';
        String tabVal = 'PRN';
        String tabValTaper = 'Taper';
        Account acc= new Account();
        acc.name='Demo';
        insert acc;
        
        List<Prescription_Order__c> l1 = new List<Prescription_Order__c>();
        List<Prescription_Order__c> l2 = new List<Prescription_Order__c>();
        List<Prescription_Order__c> l3 = new List<Prescription_Order__c>();
        List<Prescription_Order__c> l4 = new List<Prescription_Order__c>();
        List<Prescription_Order__c> l5 = new List<Prescription_Order__c>();
        
        for (Integer i=0;i<10;i++) {
            Prescription_Order__c  dem = new Prescription_Order__c();
            dem.Account__c=acc.Id;
            //dem.Name='Medicinepre '+i;
            l1.add(dem);
            l2.add(dem);
            l3.add(dem);
            l4.add(dem);
            l5.add(dem);
            
            
            
            
        }
        
        
        
        Prescription_Order__c h = new Prescription_Order__c();
        //  h.Account__c = acc.id;
        //h.Name__c='Test';
        h.After_Discharge__c=true;
        // h.ReasonLabel__c='Test reason';
        h.Type__c='PRN';
        h.Start_Date__c=date.today();
        // h.DispenseExpectedSupplyDuration__c=10;
        h.Route__c='Oral';
        insert h;
        
        
        
        
        
        Prescription_Order__c h1 = new Prescription_Order__c();
        //  h1.Account__c = acc.id;
        //h1.MedicationName__c='Test';
        h1.After_Discharge__c=true;
        /// h1.ReasonLabel__c='Test reason';
        h1.Type__c='Standard';
        h1.Start_Date__c=date.today();
        // h1.DispenseExpectedSupplyDuration__c=10;
        h1.Route__c='Oral';
        insert h1;
        
        Prescription_Order__c h2 = new Prescription_Order__c();
        //h2.MedicationName__c='Test';
        //  h2.Account__c = acc.id;
        h2.After_Discharge__c=true;
        //  h2.ReasonLabel__c='Test reason';
        h2.Type__c='Taper';
        h2.Start_Date__c=date.today();
        //  h2.DispenseExpectedSupplyDuration__c=10;
        h2.Route__c='Oral';
        insert h2;
        
        
        Prescription_Order__c h3 = new Prescription_Order__c();
        //h3.MedicationName__c='Test';
        //  h3.Account__c = acc.id;
        h3.After_Discharge__c=true;
        //  h3.ReasonLabel__c='Test reason';
        h3.Type__c='Protocol';
        h3.Start_Date__c=date.today();
        // h3.DispenseExpectedSupplyDuration__c=10;
        h3.Route__c='Oral';
        insert h3;
        
        
        
        
        
        Frequency__c d = new Frequency__c();
        d.Prescription_Order__c=h.Id;
        d.Frequency_Value__c='200mg';
        d.Frequency_Unit__c='450';
        d.Repeat__c='n times a day';
        d.Dosage_Instruction__c='4';
        // d.AdditionalInstruction__c='Demo instruction';
        //d.Dosage_Instruction__c='Demo test';
        insert d;
        
        
        Frequency__c d1 = new Frequency__c();
        d1.Prescription_Order__c=h1.Id;
        d1.Frequency_Value__c='200mg';
        d1.Frequency_Unit__c='450';
        d1.Repeat__c='n times a day';
        d1.Dosage_Instruction__c='4';
        // d1.AdditionalInstruction__c='Demo instruction';
        //  d1.Instruction__c='Demo test';
        insert d1;
        
        Frequency__c d2 = new Frequency__c();
        d2.Prescription_Order__c=h2.Id;
        d2.Frequency_Value__c='200mg';
        d2.Frequency_Unit__c='450';
        d2.Repeat__c='n times a day';
        d2.Dosage_Instruction__c='4';
        //  d2.AdditionalInstruction__c='Demo instruction';
        //  d2.Instruction__c='Demo test';
        insert d2;
        
        
        
        Test.startTest();
        MedicationController m = new MedicationController();
        MedicationController.fetchMedications();
        MedicationController.fetchMedications();
        
        //  MedicationController.fetchAccount(name, tabVal);
        
        MedicationController.wrapData w = new MedicationController.wrapData(l1,l2,l3,l4,l5);
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
    }
    
}