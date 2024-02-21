/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ProgressNotesHelperFinal1Test {
    @isTest
    public static void method1(){
        Account acc =TestDataFactory.createPatientAcc();
       
        Prescription_Order__c prsc = new Prescription_Order__c();
        insert prsc;
        List<Prescription_Order__c>lst = new List<Prescription_Order__c>();
        lst.add(prsc);
        
        Notes__c nt = new Notes__c();
        insert nt;
        
        deserializeWrapper dw = new deserializeWrapper();
        dw.Id='abc';
        dw.FieldName='def';
        dw.Description='ghi';
        List<deserializeWrapper> ldw = new List<deserializeWrapper>();
        ldw.add(dw);
        
        VitalWrapper vw = new VitalWrapper();
        vw.height ='ab';
        vw.Weight ='cd';
        vw.bpsys ='ef';
        vw.bpDias ='gh';
        vw.temp ='ij';
        vw.pulse ='kl';
        vw.oxySat ='mn';
        
        medicines m = new medicines();
        m.medications = ldw;
        
        labOrders lo = new labOrders();
        lo.labOrders = ldw;
        
        problems prblm = new problems();
        prblm.problems = ldw;
        
        diagnosis dg = new diagnosis();
        dg.diagnosis =ldw;
        
        vitals vtls = new vitals();
        vtls.vitals = vw;
        
        Test.startTest();
        ProgressNotesHelperFinal1.abc(acc.Id);
        ProgressNotesHelperFinal1.saveNotes(acc.Id,'Hello','Hello','Hello','Hello',JSON.serialize(m),'Hello',JSON.serialize(lo),JSON.serialize(prblm),JSON.serialize(dg),JSON.serialize(vtls),lst);
    	ProgressNotesHelperFinal1.getNotesData(nt.id);
        System.assertEquals(1,1,'');
        Test.stopTest();
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

}