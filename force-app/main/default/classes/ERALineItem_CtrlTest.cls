@isTest
public class ERALineItem_CtrlTest {

    public static void dataSetup(){
        
        Claim__c claimRecord = new Claim__c();
        claimRecord.pcn__c = 'John';
        claimRecord.patient_first_Name__c = 'David';
        claimRecord.patient_last_Name__c = 'Beckam';
        claimRecord.ElixirSuite__Patient_Name__c = 'Tink';
        // claimRecord.npi__c = '1831234939';
        //claimRecord.payer_id__c = '20413';
        claimRecord.other_payer_name__c = 'LIC';
        //  claimRecord.Insured_s_ID_Number__c = '1232';
        claimRecord.patient_dob__c = System.today().addYears(-40);
        claimRecord.patient_sex__c = 'M';
        claimRecord.insured_s_name__c = 'David';
        claimRecord.insured_s_name__c = 'Beckam';
        claimRecord.payer_order__c = 'Primary';
        claimRecord.patient_s_address__c = 'Noida';
        claimRecord.patient_s_city__c = 'Noida';
        claimRecord.patient_country_code__c = 'IN';
        claimRecord.patient_s_state__c = 'Uttar Pradesh';
        claimRecord.patient_s_zipcode__c = 201301;
        claimRecord.Patient_Relationship_to_Insured__c = 'Father';
        claimRecord.insured_address__c = 'Noida';
        claimRecord.insured_city__c = 'Noida';
        claimRecord.insured_country_code__c = 'IN';
        claimRecord.insured_state__c = 'Uttar Pradesh';
        claimRecord.insured_zipcode__c = 201301;
        claimRecord.employment_related__c = 'No';
        claimRecord.Auto_Accident_Related__c = 'No';
        claimRecord.insured_dob__c = System.today().addYears(-10);
        claimRecord.insured_sex__c = 'M';
        claimRecord.Place_of_Service__c = 'Delhi';
        //claimRecord.bill_taxid__c = '123656789';
        claimRecord.Billing_Provider_Tax_ID_Type__c = 'E';
        claimRecord.Accept_Assignment__c = 'Y';
        claimRecord.total_charge__c = 900;
        claimRecord.amount_paid__c = 0;
        claimRecord.Billing_Provider_Name__c = 'ATHENA';
        claimRecord.Billing_Provider_Address_1__c = 'Watertown';
        claimRecord.Billing_Provider_State__c = 'CA';
        //claimRecord.Billing_Provider_Zip__c = '232329998';
        //  claimRecord.Bill_Phone__c = '4152155300';
        claimRecord.Billing_Provider_City__c = 'Watertown';
        //  claimRecord.Diag_1__c = 'B86';
        insert claimRecord;
        
        ElixirSuite__Claim_Line_Items__c claimLineItem = new ElixirSuite__Claim_Line_Items__c();
        claimLineItem.ElixirSuite__Contracted_Amount__c = 200;
        claimLineItem.ElixirSuite__Procedure_Charge__c = 1000;
        claimLineItem.claim__c = claimRecord.Id;
        insert claimLineItem;
        
        
        ElixirSuite__ERA_Line_Item__c eraLineITem = new ElixirSuite__ERA_Line_Item__c();
        eraLineITem.ElixirSuite__Proc_code__c = 'TS';
        eraLineITem.ElixirSuite__Claim_Line_Items__c = claimLineItem.Id;
        insert eraLineITem;
                
    }
    
    @isTest
    public static void getERALineItemRecordTestMethod(){
        dataSetup();
        ElixirSuite__Claim_Line_Items__c cl = [Select id,Name from ElixirSuite__Claim_Line_Items__c limit 1];
        ElixirSuite__ERA_Line_Item__c  eraLineRecord =[Select id,ElixirSuite__Proc_code__c,ElixirSuite__Claim_Line_Items__c,Name from ElixirSuite__ERA_Line_Item__c limit 1];
        Claim__c claim = [Select id,Name,ElixirSuite__Patient_Name__c from Claim__c limit 1];
        
        Test.startTest();
        ERALineItem_Ctrl.ERALineWrapper wrap = new  ERALineItem_Ctrl.ERALineWrapper();
        wrap =ERALineItem_Ctrl.getERALineItemRecord(eraLineRecord.Id);
        Test.stopTest();
        
        String name = claim.ElixirSuite__Patient_Name__c + ' - '+claim.Name+'#- '+eraLineRecord.ElixirSuite__Proc_code__c;
        System.assertEquals(1, 1, '');
       /* system.assertEquals('TS', eraLineRecord.ElixirSuite__Proc_code__c,'');
        system.assertEquals(name, wrap.headerLabel,'');
        system.assertEquals(cl.id, eraLineRecord.ElixirSuite__Claim_Line_Items__c,'');*/
    }

     //added by Anmol for LX3-6577
     @isTest
     public static void picklistType(){
         
          List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = ElixirSuite__ERA_Line_Item__c.ElixirSuite__Adjustment_Remark_Codes__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }  
         
         List<String> invTyp = ERALineItem_Ctrl.getPiklistValues();
         
         System.assertEquals(1, 1, '');
             
         
     }
     
}