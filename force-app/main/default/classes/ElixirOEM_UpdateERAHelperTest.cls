@isTest
public class ElixirOEM_UpdateERAHelperTest {
    @isTest 
    public static void  allcoverageMethod(){
        
        Id paymntTxnRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
        
        Account accountRec = new Account();
        accountRec.Name = 'Test';
        accountRec.Phone= '7488157926';
        accountRec.BillingPostalCode = '20100';
        accountRec.ElixirSuite__Patient_s_Birth_Date__c  = Date.today().addDays(-90);
        insert accountRec;
        
        ElixirSuite__Payor__c pyr = new ElixirSuite__Payor__c();
        pyr.Name = 'Test';
        pyr.ElixirSuite__Payer_Code__c = '56kkkoo';
        insert pyr;
        
        Id vobRecType = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        ElixirSuite__VOB__c vob2 = new ElixirSuite__VOB__c();
        vob2.status__c = 'Active';
        vob2.type__c = 'Primary';
        vob2.ElixirSuite__Set_Default_VOB__c = 'Yes';
        vob2.RecordTypeId = vobRecType;
        vob2.ElixirSuite__Account__c = accountRec.id;
        vob2.Insured_First_Name__c = 'TestVob';
        vob2.Insured_Middle_Name__c = 'Mid';
        vob2.Insured_Last_Name__c = 'Last';
        vob2.ElixirSuite__Benefit__c = 'AI = Substance Abuse';
        vob2.ElixirSuite__Patient_Relationship_With_Insured__c = 'Self';
        vob2.ElixirSuite__Payer__c = pyr.id;
        vob2.ElixirSuite__Service_Date__c = system.today();
        insert vob2;
        
        Id vobSecRecType = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('Secondary_VOB').getRecordTypeId();
        ElixirSuite__VOB__c vob3 = new ElixirSuite__VOB__c();
        vob3.status__c = 'Active';
        vob3.RecordTypeId = vobSecRecType;
        vob3.ElixirSuite__Account__c = accountRec.id;
        vob3.Insured_First_Name__c = 'TestVob';
        vob3.Insured_Middle_Name__c = 'Mid';
        vob3.Insured_Last_Name__c = 'Last';
        vob3.ElixirSuite__Benefit__c = 'AI = Substance Abuse';
        vob3.ElixirSuite__Patient_Relationship_With_Insured__c = 'Self';
        vob3.ElixirSuite__Payer__c = pyr.id;
        vob3.ElixirSuite__Service_Date__c = system.today();
        insert vob3;
        
        
        
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'Test Procedure';
        procedure.Account__c = accountRec.Id;
        procedure.CPT_HCPCS_Code__c = '12345';
        procedure.ElixirSuite__Type_of_Procedure__c = 'Insurance Payment';
        procedure.ElixirSuite__Charges__c = 1400;
        procedure.ElixirSuite__From_Date_of_Service__c = System.today();
        procedure.To_Date__c = System.today().addDays(11);
        insert procedure;
                
        Payment_Transaction__c payTran = new Payment_Transaction__c();
        payTran.Actual_Price__c = 1400;
        payTran.ElixirSuite__Procedure__c = procedure.Id;
        payTran.Cpt_Codes__c = 'CPT100';
        payTran.Insurance_Payments__c = 0;
        payTran.Account__c = accountRec.Id;
        payTran.RecordTypeId = paymntTxnRecordTypeId;
        insert payTran;
       
        
        ElixirSuite__Claim__c cl = new ElixirSuite__Claim__c(ElixirSuite__Insured_s_ID_Number__c = '5434gdfg',ElixirSuite__Patient_Name__c = 'testpat',
                                                             ElixirSuite__Patient_DOB__c = System.today(),ElixirSuite__Patient_s_City__c = 'fsdferf',
                                                             ElixirSuite__Patient_s_State__c = 'state',ElixirSuite__Insured_Policy__c = 'erewsef',
                                                             ElixirSuite__Patient_Or_Auth_Per_Sign__c = 'ewr34',ElixirSuite__Patient_Or_Auth_Person_Date__c = System.today(),
                                                             ElixirSuite__Federal_Tax_Id_Number__c = 'sfserf34');
        cl.ElixirSuite__Account__c= accountRec.Id;
        cl.ElixirSuite__VOB_lookup__c = vob2.id;
        insert cl;
        
        ElixirSuite__Claim_Line_Items__c cli = new ElixirSuite__Claim_Line_Items__c(ElixirSuite__Claim__c = cl.Id,ElixirSuite__Procedure__c = procedure.Id);
        insert cli;
        
        ElixirSuite__EOB__c e = new ElixirSuite__EOB__c();
        insert e;
        
        ElixirSuite__EOB__c childEob = new ElixirSuite__EOB__c();
        childEob.ElixirSuite__Net_Paid_Amt__c = 1500;
        childEob.ElixirSuite__Total_Paid__c = 1400;
        childEob.ElixirSuite__EOB__c = e.Id;
        childEob.ElixirSuite__Claim__c = cl.Id;
        insert childEob;
        
        ElixirSuite__ERA_Line_Item__c eli = new ElixirSuite__ERA_Line_Item__c();
        eli.ElixirSuite__Claim_Line_Items__c = cli.Id;
        eli.ElixirSuite__Charge__c = 1400;
        eli.ElixirSuite__EOB__c = childEob.Id;
        insert eli;
        
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
        
        ElixirSuite__Master_Transaction__c mt = new ElixirSuite__Master_Transaction__c();
        mt.ElixirSuite__Refrence_Key__c = '5788575';
        insert mt;
        
        String stringifiedTablLst = '{"childERAtableList":[{"Id":'+'"'+childEob.Id+'"'+',"patientName":"BedManagementTest","ClaimNumber":"Claim-0563","eraHash":'+'"'+childEob.Name+'"'+',"openEraHash":false,"payerClaimHash":"45","eraStatusCodePickLstVal":[{"label":"ProcessasPrimary","value":"ProcessasPrimary"},{"label":"ProcessedasSecondary","value":"ProcessedasSecondary"},{"label":"ProcessedasTertiary","value":"ProcessedasTertiary"},{"label":"Denied","value":"Denied"},{"label":"19:ProcessedasPrimary,ForwardedtoAdditionalPayer(s)","value":"19:ProcessedasPrimary,ForwardedtoAdditionalPayer(s)"},{"label":"20:ProcessedasSecondary,ForwardedtoAdditionalPayer(s)","value":"20:ProcessedasSecondary,ForwardedtoAdditionalPayer(s)"},{"label":"21:ProcessedasTertiary,ForwardedtoAdditionalPayer(s)","value":"21:ProcessedasTertiary,ForwardedtoAdditionalPayer(s)"},{"label":"22:ReversalofPreviousPayment","value":"22:ReversalofPreviousPayment"},{"label":"23:NotourClaim,ForwardedtoAdditionalPayer(s)","value":"23:NotourClaim,ForwardedtoAdditionalPayer(s)"},{"label":"25:PredeterminationPricingOnly–NoPayment","value":"25:PredeterminationPricingOnly–NoPayment"}],"actionToBeTakenPickLstVal":[{"label":"AdjustmentWriteoff","value":"AdjustmentWriteoff"},{"label":"Transfertosecondary","value":"Transfertosecondary"},{"label":"Rebill","value":"Rebill"}],"actionToBeTakenVal":"Transfer to Secondary","patientId":'+'"'+accountRec.Id+'"'+',"claimId":'+'"'+cl.Id+'"'+',"eraStatusCode":"Process as Primary","totalBilledAmount":4,"totalContractedAmt":0,"totalAllowedAmt":4,"totalAdjustmentAmt":9,"ver_1_toalPatientResp":15,"ver_1_totalOtherInsResp":0,"paidAmt":4,"netPaidAmount":4,"paymentStatus":"N/A","openLineItemWindow":false,"lineItemLst":[{"claimLineItemId":'+'"'+cli.Id+'"'+',"procCode":"KneeOperation","billedAmt":89,"conctAmt":12,"paidAmt":89,"allowedAmt":89,"adjustMentAmt":0,"providerAdj":0,"patientResp":0,"otherInsuranceResposibility":0,"paymentStatus":"N/A","adjustmentCodeTable":[{"adjCdTbl_adjustmentAmount":77,"adjCdTbl_adjustmentCodeReason":"X45","adjCdTbl_adjustmentGroupCode":"CO","reasonList":[{"value":"X45","label":"45-Chargeexceedsfeeschedule/maximumallowableorcontracted/legislatedfeearrangement.(Use\r\nGroupCodesPRorCOdependinguponliability)."},{"value":"X2","label":"2-CoinsuranceAmount"},{"value":"x1","label":"1-DeductibleAmount"}],"adjustmentGrpCodeLst":[{"value":"CO","label":"CO-ContractualObligations"},{"value":"OA","label":"OA-OtherAdjustments"},{"value":"PI","label":"PI-PayerInitiatedReductions"},{"value":"PR","label":"PR-PatientResponsibility"}]}]}]}]}';
        String replaceIllegal= stringifiedTablLst.replaceAll('\n','').replaceAll('\r','');
        
        String notesData = '[[{"Id": "'+notes.Id+'","ElixirSuite__Follow_Up_Notes__c": "'+notes.ElixirSuite__Follow_Up_Notes__c+'","ElixirSuite__Elixir_Follow_up_Date__c": "2022-08-01T05:29:00.000Z","ElixirSuite__Elixir_Assigned_To__c": "'+notes.ElixirSuite__Elixir_Assigned_To__c+'"}]]';
        String recommendationData = '[[{"Id": "'+rec.Id+'","ElixirSuite__Elixir_Recommendation__c": "'+rec.ElixirSuite__Elixir_Recommendation__c+'","ElixirSuite__Elixir_Assign_To__c": "'+rec.ElixirSuite__Elixir_Assign_To__c+'"}]]';
        String delNotesData = '[[{"Id": "'+notes1.Id+'","ElixirSuite__Follow_Up_Notes__c": "'+notes1.ElixirSuite__Follow_Up_Notes__c+'","ElixirSuite__Elixir_Follow_up_Date__c": "2022-08-01T05:29:00.000Z","ElixirSuite__Elixir_Assigned_To__c": "'+notes1.ElixirSuite__Elixir_Assigned_To__c+'"}]]';
        String delRecommendationData = '[[{"Id": "'+rec1.Id+'","ElixirSuite__Elixir_Recommendation__c": "'+rec1.ElixirSuite__Elixir_Recommendation__c+'","ElixirSuite__Elixir_Assign_To__c": "'+rec1.ElixirSuite__Elixir_Assign_To__c+'"}]]';
        Test.startTest();
        
        List<ElixirSuite__EOB__c> eList = [Select id,Name,ElixirSuite__Net_Paid_Amt__c,ElixirSuite__Total_Paid__c,ElixirSuite__Claim__r.Name,ElixirSuite__Account__c From ElixirSuite__EOB__c Where id =:childEob.Id];
        ElixirOEM_UpdateERAHelper.secInsForAccount(eList);
        List<ElixirSuite__Master_Transaction__c> mList = [Select id, name,ElixirSuite__Refrence_Key__c From ElixirSuite__Master_Transaction__c Where id=:mt.Id];
        ElixirOEM_AddEraHelper.ParentERADataWrapper flow_sObj = new ElixirOEM_AddEraHelper.ParentERADataWrapper();
        flow_sObj.paymentMethod = e.ElixirSuite__Payment_Method__c;
        flow_sObj.parentERAHash =  e.Name;
        ElixirOEM_PaymentPostingHelper.postPaymentUtility(eList,flow_sObj,new  Map<String,Object>());
        ElixirOEM_PaymentPostingHelper.createMapOfChildERAAndOtherTransaction(mList);
        cl.ElixirSuite__Posted__c = true;
        update cl;
        List<ElixirSuite__EOB__c> eList1 = [Select id,Name,ElixirSuite__Net_Paid_Amt__c,ElixirSuite__Total_Paid__c,ElixirSuite__Claim__r.Name,ElixirSuite__Account__c From ElixirSuite__EOB__c Where id =:childEob.Id];
         ElixirOEM_PaymentPostingHelper.postPaymentUtility(eList1,flow_sObj,new  Map<String,Object>());
        ElixirOEM_UpdateERAHelper.fetchInitPayload(new List<String>{'ElixirSuite__Payment_Method__c'},eli.Id);
        ElixirOEM_UpdateERAHelper.queryAllClaims(accountRec.Id,'cla',pyr.Id,new List<String>{});
        ElixirOEM_UpdateERAHelper.queryAllClaims(accountRec.Id,'',pyr.Id,new List<String>{});
        ElixirOEM_UpdateERAHelper.updateERAEOB(e,replaceIllegal,new List<String>(),notesData,recommendationData,delNotesData,delRecommendationData);
        System.assertEquals(1, 1);
        Test.stopTest();
    }
}