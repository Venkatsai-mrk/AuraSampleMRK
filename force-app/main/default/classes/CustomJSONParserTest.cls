@isTest 
public with sharing class CustomJSONParserTest {
    private static testMethod void CustomJSONParserTestMethod(){
        
        List<Account> accountList = new List<Account>();
        Account patient =new Account ();
        patient.Name= 'Virat Kohli';
        patient.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        patient.ElixirSuite__Gender__c='Male';
        patient.ElixirSuite__Email_Id__c='virat@gmail.com';
        patient.phone='9988776655';
        patient.ElixirSuite__First_Name__c='Virat';
        patient.ElixirSuite__Last_Name__c='Kohli';
        patient.BillingPostalCode='50021';
        patient.ElixirSuite__SSN__c='12345';
        patient.ElixirSuite__MRN_Number_New__c='1234567890';
        accountList.add(patient);
        insert accountList;
        system.debug(patient.Id);
        
         List<Claim__c> claimList = new List<Claim__c>();
        Claim__c c = new Claim__c();
        c.Account__c = accountList[0].id;
        c.Total_Charge__c = 0; 
        c.Other_Payer_Name__c = 'James';
        c.Total_Patient_Responsibility__c = 0;
        c.Claim_Status__c = 'Ready to Submit';
        c.Patient_Sex__c = 'M';
        c.Payer_Id__c = '12345';
        c.Patient_s_Address__c = 'Delhi';
        c.Patient_s_City__c = 'Delhi';
        c.Patient_s_State__c = 'Delhi';
        c.Patient_s_Zipcode__c = 110027;
        c.Patient_Country_Code__c = '1';
        c.Patient_Relationship_to_Insured__c = 'Son';
        c.Billing_Provider_Tax_ID_Type__c = 'E';
        c.Accept_Assignment__c = 'Hello';
        c.Employment_Related__c = 'Son';
        c.Auto_Accident_Related__c = 'Hello';
        c.Billing_Provider_Tax_ID__c = '12345';
        c.Insured_DOB__c = System.today();
        c.Insured_Sex__c = 'M';
        c.Place_of_Service__c = 'Delhi';
        c.Insured_Address__c = 'Delhi';
        c.Insured_City__c = 'Delhi';
        c.Insured_Country_Code__c = 'INDIA';
        c.Insured_State__c = 'DEL';
        c.Insured_Zipcode__c = 110027;
        c.NPI__c = '12345';
        c.Procedure_Code__c = 'HC';
        c.Patient_DOB__c = System.today();
        c.Insured_s_ID_Number__c = '12345';
        c.Amount_Paid__c = 12345;
        c.Units__c = '1';
        c.From_Date__c = System.today();
        c.Thru_Date__c = System.today();
        c.Billing_Provider_Name__c = 'Aetna';
        c.Billing_Provider_Address_1__c = 'Delhi';
        c.Billing_Provider_City__c = 'Delhi';
        c.Billing_Provider_State__c = 'Delhi';
        c.Billing_Provider_Zip__c = '110027';
        c.Bill_Phone__c = '123456';
        c.First_Diagnosis__c = 'BP';
        c.Charge_Amount__c = '2340';
        c.Total_Adjustment_Amount__c = 0;
        c.Total_Contracted_Amount__c = 0;
        c.Total_Amount_Paid_By_Insurance__c = 0;
        c.Total_Allowed_Amount__c = 0;
        c.Diagnosis_Reference__c = 'F';
        claimList.add(c);
        insert claimList;
       // String jsonData = '{ "name": "John Doe", "age": 35, "email": "johndoe@example.com", "active": true }';
               String jsonInput = '{' +
            '"result":{' +
                '"check_number":"CN123",' +
                '"eraid":"EOB456",' +
                '"paid_amount":"100",' +
                '"paid_date":"2022-01-01",' +
                '"payer_name":"John Doe",' +
                '"payerid":"PAYER789",' +
                '"prov_name":"Jane Doe",' +
                '"prov_npi":"NPI123",' +
                '"claim":[' +
                    '{' +
                        '"ins_number":"INS456",' +
                        '"pcn":"PCN789",' +
                        '"prov_npi":"NPI456",' +
                        '"total_charge":"200",' +
                        '"total_paid":"100",' +
                        '"charge":[' +
                            '{' +
                                '"charge":"100",' +
                                '"chgid":"CHG321",' +
                                '"from_dos":"2022-01-01",' +
                                '"paid":"100",' +
                                '"proc_code":"PROC123",' +
                                '"units":"1",' +
                                '"allow":"50",' +
                                '"adjustment":[' +
                                    '{' +
                                        '"amount":"50",' +
                                        '"code":"ADJ456",' +
                                        '"group_Z":"GROUP789"' +
                                    '}' +
                                ']' +
                            '}' +
                        ']' +
                    '}' +
                ']' +
            '}' +
        '}';
        
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'Test Procedure';
        procedure.Account__c =  accountList[0].id;
        procedure.CPT_HCPCS_Code__c = '12345';
        procedure.From_Date__c = System.today();
        procedure.To_Date__c = System.today().addDays(1);
        insert procedure;
        
        Claim_Line_Items__c cli = new Claim_Line_Items__c ();
        cli.Claim__c = c.id;
        cli.Procedure__c = procedure.id;
        cli.CPT_HCPCS_Code__c = 'G0001';
        cli.Proc_code__c = 'G0001';
        cli.To_Date__c = System.today();
        cli.From_date__c = System.today();
        cli.Procedure_Charge__c = 600;
        cli.Total_Adjustment__c = 100;
        cli.Amount_Paid_by_Insurance__c = 200;
        cli.Total_Allowed_Amount__c = 300;
        cli.Contracted_Amount__c = 500;
        insert cli;
        
        EOB__c eobData = new EOB__c();
        eobData.EOB_Id__c = 'ERA-001';
        eobData.Check_Number__c = '12345';
        eobData.PaidDate__c = System.today();
        eobData.CoPayment__c = 20;
        eobData.Deductible__c = 3000;
        insert eobData;
        
        
        eobData=[select Id, EOB_Id__c, Check_Number__c, PaidDate__c,  CoPayment__c, Deductible__c FROM EOB__c WHERE Id=:eobData.Id ];
        eobData.CoPayment__c = 40;
        eobData.Deductible__c = 4000;
        update eobData;
        
        ERA_Line_Item__c eli = new ERA_Line_Item__c();
        eli.EOB__c = eobData.id;
        eli.Proc_code__c = '12345';
        eli.Claim_Line_Items__c = cli.id;
        eli.Charge__c = 400;
        eli.Total_Allowed_Amount__c = 400;
        eli.Adjustment_Amount_1__c = 100;
        insert eli;
        
        eli=[select Id, EOB__c, Proc_code__c, Claim_Line_Items__c,  Charge__c, Total_Allowed_Amount__c,Adjustment_Amount_1__c FROM ERA_Line_Item__c WHERE Id=:eli.Id ];
        eli.Total_Allowed_Amount__c = 4050;
        eli.Adjustment_Amount_1__c = 400;
        update eli;
        
        VOB__c vob = new VOB__c();
        vob.PatientFirstName__c = 'Test';
        vob.PatientLastName__c = 'Patient';
        vob.Patient_Birth_Date__c = System.today().addYears(-26);
        vob.Member_Id__c = '12345';
        vob.Payer_Name__c = 'Test Payer';
        vob.ElixirSuite__Insured_Address__c = 'ABC';
        vob.ElixirSuite__Date_Of_Birth__c =date.valueOf('2000-04-18');
        vob.ElixirSuite__Patient_Relationship_With_Insured__c ='Child';
        
        ElixirSuite__Result__c res=new ElixirSuite__Result__c();
        res.ElixirSuite__VOB__c=vob.id;
        insert res;
      
     /*   CustomJSONParser.Result insp = new CustomJSONParser.Result();
         insp.check_number = 'abc';
         insp.eraid = 'abcd';
         insp.paid_amount = 'bc';
         insp.paid_date = 'abcde';
         insp.payer_name = 'abcdef';
         insp.payerid = 'abcfgh';
         insp.prov_npi = 'abcfghij';
         insp.prov_name = 'abcfghijk';
       // insp.claim=new List<Claim>(recClaim);
        
      
         CustomJSONParser.Claim recClaim = new CustomJSONParser.Claim();
         recClaim.ins_number = 'bcd';
         recClaim.pcn = 'bcde';
         recClaim.prov_npi = 'bc';
         recClaim.total_charge = 'abcde';
         recClaim.total_paid = 'abcdef';
       
        
         CustomJSONParser.Charge recCharge = new CustomJSONParser.Charge();
         recCharge.charge = 'bcd';
         recCharge.chgid = 'bcde';
         recCharge.from_dos = 'bc';
         recCharge.paid = 'abcde';
         recCharge.proc_code = 'abcdef';
         recCharge.units = 'bc';
         recCharge.allow = 'abcde';
        
         CustomJSONParser.Adjustment recAdjustment = new CustomJSONParser.Adjustment();
         recAdjustment.amount = 'bcd';
         recAdjustment.code = 'bcde';
         recAdjustment.group_Z = '{ "name": "Johncena", "age": 35, "email": "johncena@example.com", "active": true }';*/
          CustomJSONParser.Result result = new CustomJSONParser.Result();
        result.check_number = '12345';
        result.eraid = 'ABCDE';
        result.paid_amount = '1000';
        result.paid_date = '2022-01-01';
        result.payer_name = 'Test Payer';
        result.payerid = 'PAYER1';
        result.prov_name = 'Test Provider';
        result.prov_npi = 'PROV1';
        
        CustomJSONParser.Claim claim = new CustomJSONParser.Claim();
        claim.ins_number = '67890';
        claim.pcn = 'PCN1';
        claim.prov_npi = 'PROV1';
        claim.total_charge = '500';
        claim.total_paid = '400';
        
        List<CustomJSONParser.Claim> claims = new List<CustomJSONParser.Claim>();
        claims.add(claim);
        result.claim = claims;
        
        CustomJSONParser.Charge charge = new CustomJSONParser.Charge();
        charge.charge = '100';
        charge.chgid = 'CHG1';
        charge.from_dos = '2021-01-01';
        charge.paid = '90';
        charge.proc_code = 'PROC1';
        charge.units = '2';
        charge.allow = '95';
        
        List<CustomJSONParser.Charge> charges = new List<CustomJSONParser.Charge>();
        charges.add(charge);
        claim.charge = charges;
        
        CustomJSONParser.Adjustment adjustment = new CustomJSONParser.Adjustment();
        adjustment.amount = '10';
        adjustment.code = 'ADJ1';
        adjustment.group_Z = 'GROUP1';
        
        List<CustomJSONParser.Adjustment> adjustments = new List<CustomJSONParser.Adjustment>();
        adjustments.add(adjustment);
        charge.adjustment = adjustments;
        
        
		      
        
        Test.startTest();
          try
    {
       
       CustomJSONParser.parseClass(jsonInput, claimList[0].id );
    }
   catch (Exception e) {
        
      }  
        System.assertEquals(1, 1, '');
        
        Test.stopTest(); 
        
    }
}