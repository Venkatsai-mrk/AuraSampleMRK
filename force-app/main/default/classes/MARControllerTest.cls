@isTest
public class MARControllerTest {
    @isTest
    public static void testMethod1(){
        //Insert test account
        List<Integer> t = new List<Integer>{1,2,3,4,5};
            List<Integer> t1 = new List<Integer>{1,2,3,4,5,6,7,8,9,10,11};
                List<Wrapper> lst = new list<Wrapper>();
        List<Wrapper> dosageLst = new list<Wrapper>();
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        System.assertEquals('1', '1','');

        Prescription_Order__c mp = new Prescription_Order__c();
        mp.After_Discharge__c = false; 
        mp.Account__c = acc.id ;
        insert mp ;
        System.assertEquals('1', '1','');
         
        Frequency__c  dr = new  Frequency__c();
        dr.Last_Activity_Date_MAR__c = system.today() + 8;
        dr.Prescription_Order__c = mp.id ;
        insert dr;
        System.assertEquals('1', '1','');
        
        Prescription_Order__c mp1 = new Prescription_Order__c();
        mp1.After_Discharge__c = false; 
        mp1.Account__c = acc.id ;
        insert mp1 ;
        System.assertEquals('1', '1','');  
        
        Frequency__c  dr1 = new  Frequency__c();
        dr1.Last_Activity_Date_MAR__c = system.today() + 8;
        dr1.Prescription_Order__c = mp1.id ;
        insert dr1;
        System.assertEquals('1', '1','');
        
        Wrapper wrpr = new Wrapper();
        wrpr.dosageID=dr1.id;
        wrpr.parentID=mp1.id;
        wrpr.timings= t;
        lst.add(wrpr);
        Wrapper wrpr1 = new Wrapper();
        wrpr1.dosageID=dr1.id;
        wrpr1.parentID=mp1.id;
        wrpr1.timings= t1;
        dosageLst.add(wrpr1);	        
        string a=dr.Id;
        System.debug('gdvgw' + dr.id);
        String genericTime = String.valueOf(System.now());
        String endDate= String.valueOf(System.now().addDays(1));
        String demoJSONTaper = '[{"dosageId":"'+dr.id+'","medicationName":"Taper Medication", "Type":"Taper","Start_Date":"2020-02-16","DispenseExpectedSupplyDuration" : 1 ,"After_Discharge":false,"Dosage_Form":"film","Strength":"5mg","Route":"IM","Units":"film","Dosage":"1","times":"17:00","Owner":"Elixir Development","Frequency":"Once a day (HS)","NoOfTimes": 1 ,"MedicationNameRadio":"False" ,"commentData":"Not Taken", "Warning":"Take regularly"}]';
        String demoJSONPRN = '[{"dosageId":"'+dr.id+'","medicationName":"PRN Medication","Type":"PRN","Start_Date":"2020-02-16","DispenseExpectedSupplyDuration":"1","After_Discharge":false,"Route":"IM","Dosage":"1","Warning":"To be taken regularly","Strength":"5mg","Units":"film","Owner":"Elixir Development","NoOfTimes":"0","Frequency":"Once a day (HS)","commentData":"take regularly" ,"MedicationNameRadio":"False"}]';
        String demoJSONActionOrder = '[{"dosageId":"'+dr.id+'" , "medicationName":"Action Order Medication","Type":"Action Order","Start_Date":"2020-02-16","DispenseExpectedSupplyDuration": 1 ,"After_Discharge":false,"Warning":"To be taken regularly","timesActionOrder":"16:00","Owner":"Elixir Development","NoOfTimes": 1 ,"Frequency":"Once a day (HS)","commentData":"take regularly" ,"MedicationNameRadio":"False"}]';
        string new1=string.valueof(JSON.serialize(lst));
        string new2=string.valueof(JSON.serialize(dosageLst));
        string new3=acc.id;
        
        ElixirSuite__Visits__c objVisist = new ElixirSuite__Visits__c();
        objVisist.ElixirSuite__Status__c = 'Active';
        objVisist.ElixirSuite__Account__c = new3;
        StopRecursion.stopLocationUpdation = false;
        insert objVisist;
        
        test.startTest();
        System.debug('debug wrapper se '+JSON.serialize(wrpr));
        MARController.getMORDetails(acc.id);
        
       // MARController.saveMarForActionOrder(demoJSONActionOrder, '16:30', acc.id);
      //  MARController.saveMarForPRN(demoJSONPRN, '17:49', acc.id);
        MARController.sendEmailToUR(demoJSONPRN);
       // MARController.updateMissedMedication('');

        //added by Anmol for LX3-7236
        Elixir_Custom_Setting__c customSetting = new Elixir_Custom_Setting__c();
        customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c = 'createddate asc';
        insert customSetting;
        //end by Anmol for LX3-7236

        MARController.saveData(demoJSONTaper, demoJSONPRN,demoJSONActionOrder , new3, '22:38','','',genericTime,endDate,'');
        test.stopTest();
    }
    public class Wrapper{ // Wrapper class
        
        public String dosageID;
        public String parentID;
        public List<Integer> timings;
        
    }
    
}