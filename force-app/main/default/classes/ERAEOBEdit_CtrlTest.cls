@isTest
public class ERAEOBEdit_CtrlTest {

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
        
        ElixirSuite__EOB__c eob = new ElixirSuite__EOB__c();
        eob.ElixirSuite__Claim__c = claimRecord.id;
        eob.ElixirSuite__Payer_Claim__c = 'PayerMT';
        eob.ElixirSuite__Total_Allowed__c = 800;
        eob.ElixirSuite__Total_Paid__c = 1000;
        eob.ElixirSuite__Net_Paid_Amt__c = 200;
        eob.ElixirSuite__ERA_Status_Code__c = 'Process as Primary';
        eob.ElixirSuite__Action_to_be_Taken__c = 'Adjustment Writeoff';
        insert eob;
        
        ElixirSuite__Claim_Line_Items__c claimLineItem = new ElixirSuite__Claim_Line_Items__c();
        claimLineItem.ElixirSuite__Contracted_Amount__c = 200;
        claimLineItem.ElixirSuite__Procedure_Charge__c = 1000;
        claimLineItem.claim__c = claimRecord.Id;
        insert claimLineItem;
        
        ElixirSuite__Claim_Line_Items__c claimLineItem2 = new ElixirSuite__Claim_Line_Items__c();
        claimLineItem2.ElixirSuite__Contracted_Amount__c = 200;
        claimLineItem2.ElixirSuite__Procedure_Charge__c = 1000;
        claimLineItem2.claim__c = claimRecord.Id;
        insert claimLineItem2;
        
        ElixirSuite__ERA_Line_Item__c eraLineITem = new ElixirSuite__ERA_Line_Item__c();
        eraLineITem.ElixirSuite__Proc_code__c = 'TS';
        eraLineITem.ElixirSuite__Claim_Line_Items__c = claimLineItem.Id;
        eraLineITem.ElixirSuite__EOB__c = eob.id;
        insert eraLineITem;
        
        ElixirSuite__ERA_Line_Item__c eraLineITem2 = new ElixirSuite__ERA_Line_Item__c();
        eraLineITem2.ElixirSuite__Proc_code__c = 'TS2';
        eraLineITem2.ElixirSuite__Claim_Line_Items__c = claimLineItem2.Id;
        eraLineITem2.ElixirSuite__EOB__c = eob.id;
        insert eraLineITem2;
        
            
        
    }
    @isTest
    public static void getERARecordTestMethod(){
        dataSetup();
        ElixirSuite__EOB__c eob = [Select id,Name,ElixirSuite__Payer_Claim__c,ElixirSuite__Total_Paid__c,ElixirSuite__Action_to_be_Taken__c from ElixirSuite__EOB__c limit 1];
        
        Test.startTest();
        ERAEOBEdit_Ctrl.ERAWrapper eraWrap=ERAEOBEdit_Ctrl.getERARecord(eob.id);
        
        Test.stopTest();
        
        ElixirSuite__EOB__c eobFetched =  eraWrap.eob;
        
        system.assertEquals('PayerMT', eobFetched.ElixirSuite__Payer_Claim__c,'');
        system.assertEquals(1000, eobFetched.ElixirSuite__Total_Paid__c,'');
        system.assertEquals('Adjustment Writeoff', eobFetched.ElixirSuite__Action_to_be_Taken__c,'');
        
    }
    @isTest
    public static void getERALineItemsTestMethod(){
        dataSetup();
        ElixirSuite__EOB__c eob = [Select id,Name from ElixirSuite__EOB__c limit 1];
        ElixirSuite__ERA_Line_Item__c eraline = [Select id,Name,ElixirSuite__EOB__c,ElixirSuite__Proc_code__c from ElixirSuite__ERA_Line_Item__c limit 1];
        
        Test.startTest();
        List<ElixirSuite__ERA_Line_Item__c> lineItemList= ERAEOBEdit_Ctrl.getERALineItems(eob.Id);
        Test.stopTest();
        system.assertEquals(2, lineItemList.size(),'');
        system.assertEquals('TS', lineItemList[0].ElixirSuite__Proc_code__c,'');
        system.assertEquals(eob.id, lineItemList[0].ElixirSuite__EOB__c,'');
    }
    @isTest
    public static void saveEraRecordTestMethod(){
        dataSetup();
        ElixirSuite__EOB__c eob = [Select id,Name from ElixirSuite__EOB__c limit 1];
        ElixirSuite__ERA_Line_Item__c eraline1 = [Select id,Name,ElixirSuite__Claim_Line_Items__c,ElixirSuite__EOB__c from ElixirSuite__ERA_Line_Item__c where ElixirSuite__Proc_code__c = 'TS' limit 1];
        ElixirSuite__ERA_Line_Item__c eraline2 = [Select id,Name from ElixirSuite__ERA_Line_Item__c where ElixirSuite__Proc_code__c = 'TS2' limit 1];
        
        
        String json2 = getJsonStringForDeleteERA(eraline2.id);
        String json =getJsonString(eraline1.id,eraline1.ElixirSuite__Claim_Line_Items__c,eraline1.ElixirSuite__EOB__c);
        Test.startTest();
       
        ERAEOBEdit_Ctrl.saveEraRecord(eob.Id, 'PayerMTT', 'Process as Primary', 100, 700, 550,400, 350, 400, 'Rebill', 300,400,json2,json,false,'');
        Test.stopTest();
        
        ElixirSuite__EOB__c updatedEob = [Select id,Name,ElixirSuite__Payer_Claim__c,ElixirSuite__ERA_Status_Code__c,ElixirSuite__Total_Paid__c,ElixirSuite__Action_to_be_Taken__c from ElixirSuite__EOB__c limit 1];
        
        system.assertEquals('PayerMTT', updatedEob.ElixirSuite__Payer_Claim__c,'');
        system.assertEquals(550, updatedEob.ElixirSuite__Total_Paid__c,'');
        system.assertEquals('Rebill', updatedEob.ElixirSuite__Action_to_be_Taken__c,'');
        system.assertEquals('Process as Primary', updatedEob.ElixirSuite__ERA_Status_Code__c,'');
    }
    @isTest
    public static void saveChildEralineRecordsTestMethod(){
        dataSetup();
        ElixirSuite__ERA_Line_Item__c eraline = [Select id,Name from ElixirSuite__ERA_Line_Item__c limit 1];
        ElixirSuite__Claim_Line_Items__c claimLineItem = [Select id,Name from ElixirSuite__Claim_Line_Items__c limit 1];
        Test.startTest();
        List<ERAEOBEdit_Ctrl.childEraLineClass> rowLst = new List<ERAEOBEdit_Ctrl.childEraLineClass>();
        ERAEOBEdit_Ctrl.childEraLineClass  cl = new ERAEOBEdit_Ctrl.childEraLineClass();
        cl.lineItem = eraline;
        rowLst.add(cl);
        
        ElixirSuite__EOB__c e = new ElixirSuite__EOB__c();
        insert e;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'testu', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testcase1a@gmail.com');
        insert u;
        
        ElixirSuite__Notes__c notes = new ElixirSuite__Notes__c();
        notes.ElixirSuite__Follow_Up_Notes__c='testing notes';
        notes.ElixirSuite__Elixir_Follow_up_Date__c= System.today();
        notes.ElixirSuite__Elixir_Assigned_To__c = u.Id;
        notes.ElixirSuite__ERA_Notes__c = e.id;
        insert notes;
        
        ElixirSuite__Notes__c notes1 = new ElixirSuite__Notes__c();
        notes1.ElixirSuite__Follow_Up_Notes__c='testing notes 1';
        notes1.ElixirSuite__Elixir_Follow_up_Date__c= System.today();
        notes1.ElixirSuite__Elixir_Assigned_To__c = u.Id;
        notes1.ElixirSuite__ERA_Notes__c = e.id;
        insert notes1;
        
        ElixirSuite__Notes__c notes2 = new ElixirSuite__Notes__c();
        notes2.ElixirSuite__Follow_Up_Notes__c='testing notes 2';
        notes2.ElixirSuite__Elixir_Follow_up_Date__c= System.today();
        notes2.ElixirSuite__Elixir_Assigned_To__c = u.Id;
        notes2.ElixirSuite__ERA_Notes__c = e.id;
        insert notes2;
        
        ElixirSuite__Recommendation__c rec = new ElixirSuite__Recommendation__c();
        rec.ElixirSuite__Elixir_Recommendation__c='testing Rec ';
        rec.ElixirSuite__Elixir_Assign_To__c = u.Id;
        rec.ElixirSuite__Elixir_ERA__c = e.id;
        insert rec;
        
        ElixirSuite__Recommendation__c rec1 = new ElixirSuite__Recommendation__c();
        rec1.ElixirSuite__Elixir_Recommendation__c='testing Rec 1';
        rec1.ElixirSuite__Elixir_Assign_To__c = u.Id;
        rec1.ElixirSuite__Elixir_ERA__c = e.id;
        insert rec1;
        
        ElixirSuite__Recommendation__c rec2 = new ElixirSuite__Recommendation__c();
        rec2.ElixirSuite__Elixir_Recommendation__c='testing Rec 2';
        rec2.ElixirSuite__Elixir_Assign_To__c = u.Id;
        rec2.ElixirSuite__Elixir_ERA__c = e.id;
        insert rec2;
       
        String notesData = '[{"Id": "'+notes.Id+'","ElixirSuite__Follow_Up_Notes__c": "'+notes.ElixirSuite__Follow_Up_Notes__c+'","ElixirSuite__Elixir_Follow_up_Date__c": "2022-08-01T05:29:00.000Z","ElixirSuite__Elixir_Assigned_To__c": "'+notes.ElixirSuite__Elixir_Assigned_To__c+'"}]';
        String recommendationData = '[{"Id": "'+rec.Id+'","ElixirSuite__Elixir_Recommendation__c": "'+rec.ElixirSuite__Elixir_Recommendation__c+'","ElixirSuite__Elixir_Assign_To__c": "'+rec.ElixirSuite__Elixir_Assign_To__c+'"}]';
        String delNotesData = '[{"Id": "'+notes1.Id+'","ElixirSuite__Follow_Up_Notes__c": "'+notes1.ElixirSuite__Follow_Up_Notes__c+'","ElixirSuite__Elixir_Follow_up_Date__c": "2022-08-01T05:29:00.000Z","ElixirSuite__Elixir_Assigned_To__c": "'+notes1.ElixirSuite__Elixir_Assigned_To__c+'"}]';
        String delRecommendationData = '[{"Id": "'+rec1.Id+'","ElixirSuite__Elixir_Recommendation__c": "'+rec1.ElixirSuite__Elixir_Recommendation__c+'","ElixirSuite__Elixir_Assign_To__c": "'+rec1.ElixirSuite__Elixir_Assign_To__c+'"}]';
        
        ERAEOBEdit_Ctrl.saveChildEralineRecords(JSON.serialize(rowLst),'',recommendationData,delRecommendationData,notesData,delNotesData);
       
       
        Test.stopTest();
        List<ElixirSuite__ERA_Line_Item__c> updatedEralines = [Select id,Name,ElixirSuite__Claim_Line_Items__c from ElixirSuite__ERA_Line_Item__c ];
       
        system.assertEquals(2,updatedEralines.size(),'');
        system.assertEquals(claimLineItem.id, updatedEralines[0].ElixirSuite__Claim_Line_Items__c,'');
    }
    
    public static String getJsonString(String eralineId, String eobId, String claimlineId){
        String jsonString = '{"key":[{"eralineItem":{"Id":"' + eralineId + '","ElixirSuite__Claim_Line_Items__c":"' + claimlineId + '","ElixirSuite__Charge__c":90,"ElixirSuite__EOB__c":"' + eobId + '","ElixirSuite__Adjustment_Amount_1__c":910,"ElixirSuite__Adjustment_Amount_2__c":0,"ElixirSuite__Adjustment_Amount_3__c":0,"ElixirSuite__Adjustment_Amount_4__c":0,"ElixirSuite__Adjustment_Amount_5__c":0,"ElixirSuite__Adjustment_Amount_6__c":0,"ElixirSuite__Code_1__c":"X45","ElixirSuite__Group_1__c":"CO","ElixirSuite__Adjustment_Amount_7__c":0,"ElixirSuite__Adjustment_Amount_8__c":0,"ElixirSuite__Proc_code__c":"Knee Operation","ElixirSuite__Paid__c":90,"ElixirSuite__Total_Allowed_Amount__c":90,"ElixirSuite__Total_Adjustment_Amount__c":0,"ElixirSuite__Patient_Responsibility__c":0,"ElixirSuite__Other_Insurance_Responsibility__c":0,"ElixirSuite__Provider_Adjustment__c":0,"ElixirSuite__Claim_Line_Items__r":{"ElixirSuite__Procedure_Charge__c":1000,"Id":"' + claimlineId + '"}},"lineId":"' + eralineId + '","IsEdited":true,"isOpen":false,"isOpenforMap":false,"isOpenforDelete":false,"claimLineItemId":"' + claimlineId + '","billedAmount":1000,"allowedAmount":90,"paidAmount":90,"adjustmentAmount":910,"providerAdjustment":910,"insuranceResponsibility":0,"patientResponsibility":0,"ProcedureCode":"Knee Operation","ajcdList":[{"AdjustmentAmount":910,"SelectedAdjustmentGroupCode":"CO","SelectedAdjustmentReason":"X45"}],"selectedInfoList":["M16-Alert"]}]}';
       
        return jsonString;
    }
    public static String getJsonStringForDeleteERA(String claimlineId){
        String jsonString = '{"key":["' + claimlineId + '"]}';
       
        return jsonString;
    }
}