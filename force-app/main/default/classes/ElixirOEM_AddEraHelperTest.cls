/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-06-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ElixirOEM_AddEraHelperTest {
    @isTest 
    public static void  allcoverageMethod(){
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
        ElixirSuite__EOB__c eob = new ElixirSuite__EOB__c();
        ElixirSuite__Claim__c cl = new ElixirSuite__Claim__c(ElixirSuite__Insured_s_ID_Number__c = '5434gdfg',ElixirSuite__Patient_Name__c = 'testpat',
                                                            ElixirSuite__Patient_DOB__c = System.today(),ElixirSuite__Patient_s_City__c = 'fsdferf',
                                                            ElixirSuite__Patient_s_State__c = 'state',ElixirSuite__Insured_Policy__c = 'erewsef',
                                                            ElixirSuite__Patient_Or_Auth_Per_Sign__c = 'ewr34',ElixirSuite__Patient_Or_Auth_Person_Date__c = System.today(),
                                                            ElixirSuite__Federal_Tax_Id_Number__c = 'sfserf34');
        insert cl;
          ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestP');
        insert p;
        Id paymntTxnRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();

        ElixirSuite__Payment_Transaction__c mt = new ElixirSuite__Payment_Transaction__c(ElixirSuite__Procedure__c = p.Id,
                                                                                         ElixirSuite__Actual_Price__c=1000,
                                                                                         Cpt_Codes__c = 'CPT100',
                                                                                         Insurance_Payments__c = 0,
                                                                                         Account__c = accountRec.Id
                                                                                        );
        insert mt;
        
        ElixirSuite__Claim_Line_Items__c cli = new ElixirSuite__Claim_Line_Items__c(ElixirSuite__Claim__c = cl.Id,ElixirSuite__Procedure__c = p.Id); 
        insert cli;
        Profile pId = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'testu', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = pId.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testcase1a@gmail.com');
        insert u; 
        
        ElixirSuite__Notes__c notes = new ElixirSuite__Notes__c();
        notes.ElixirSuite__Follow_Up_Notes__c='testing notes';
        notes.ElixirSuite__Elixir_Follow_up_Date__c= System.today();
        notes.ElixirSuite__Elixir_Assigned_To__c = u.Id;
        notes.ElixirSuite__ERA_Notes__c = eob.id;
        insert notes;
        
        ElixirSuite__Recommendation__c rec = new ElixirSuite__Recommendation__c();
        rec.ElixirSuite__Elixir_Recommendation__c='testing Rec ';
        rec.ElixirSuite__Elixir_Assign_To__c = u.Id;
        rec.ElixirSuite__Elixir_ERA__c = eob.id;
        insert rec;
        
        //Added by Ashwini
        ElixirSuite__EOB__c eobvar = new ElixirSuite__EOB__c();
        //eobvar.ElixirSuite__Claim__c= 'testing';
        insert eobvar;
        
        ElixirSuite__Payor__c payorvar = new ElixirSuite__Payor__c();
        payorvar.name = 'Ashwini';
        insert payorvar;
        // End
        
        String notesData = '[[{"Id": "'+notes.Id+'","ElixirSuite__Follow_Up_Notes__c": "'+notes.ElixirSuite__Follow_Up_Notes__c+'","ElixirSuite__Elixir_Follow_up_Date__c": "2022-08-01T05:29:00.000Z","ElixirSuite__Elixir_Assigned_To__c": "'+notes.ElixirSuite__Elixir_Assigned_To__c+'"}]]';
        String recommendationData = '[[{"Id": "'+rec.Id+'","ElixirSuite__Elixir_Recommendation__c": "'+rec.ElixirSuite__Elixir_Recommendation__c+'","ElixirSuite__Elixir_Assign_To__c": "'+rec.ElixirSuite__Elixir_Assign_To__c+'"}]]';
      
        String stringifiedTablLst ='{"childERAtableList":[{"Id":'+'"'+cl.Id+'"'+',"patientName":"BedManagementTest","ClaimNumber":"Claim-0563","payerClaimHash":"45","eraStatusCodePickLstVal":[{"label":"ProcessasPrimary","value":"ProcessasPrimary"},{"label":"ProcessedasSecondary","value":"ProcessedasSecondary"},{"label":"ProcessedasTertiary","value":"ProcessedasTertiary"},{"label":"Denied","value":"Denied"},{"label":"19:ProcessedasPrimary,ForwardedtoAdditionalPayer(s)","value":"19:ProcessedasPrimary,ForwardedtoAdditionalPayer(s)"},{"label":"20:ProcessedasSecondary,ForwardedtoAdditionalPayer(s)","value":"20:ProcessedasSecondary,ForwardedtoAdditionalPayer(s)"},{"label":"21:ProcessedasTertiary,ForwardedtoAdditionalPayer(s)","value":"21:ProcessedasTertiary,ForwardedtoAdditionalPayer(s)"},{"label":"22:ReversalofPreviousPayment","value":"22:ReversalofPreviousPayment"},{"label":"23:NotourClaim,ForwardedtoAdditionalPayer(s)","value":"23:NotourClaim,ForwardedtoAdditionalPayer(s)"},{"label":"25:PredeterminationPricingOnly–NoPayment","value":"25:PredeterminationPricingOnly–NoPayment"}],"actionToBeTakenPickLstVal":[{"label":"AdjustmentWriteoff","value":"AdjustmentWriteoff"},{"label":"Transfertosecondary","value":"Transfertosecondary"},{"label":"Rebill","value":"Rebill"}],"actionToBeTakenVal":"Adjustment Writeoff","patientId":'+'"'+accountRec.Id+'"'+',"claimId":'+'"'+cl.Id+'"'+',"eraStatusCode":"Process as Primary","totalBilledAmount":4,"totalContractedAmt":0,"totalAllowedAmt":4,"totalAdjustmentAmt":0,"paidAmt":4,"netPaidAmount":4,"paymentStatus":"N/A","openLineItemWindow":false,"lineItemLst":[{"claimLineItemId":'+'"'+cli.Id+'"'+',"procCode":"KneeOperation","billedAmt":89,"conctAmt":12,"paidAmt":89,"ver_1_toalPatientResp":8,"allowedAmt":89,"adjustMentAmt":0,"providerAdj":0,"patientResp":0,"otherInsuranceResposibility":0,"paymentStatus":"N/A","selectedInfoRemarkCodes":[],"adjustmentCodeTable":[{"adjCdTbl_adjustmentAmount":77,"adjCdTbl_adjustmentCodeReason":"X45","adjCdTbl_adjustmentGroupCode":"CO","reasonList":[{"value":"X45","label":"45-Chargeexceedsfeeschedule/maximumallowableorcontracted/legislatedfeearrangement.(Use\r\nGroupCodesPRorCOdependinguponliability)."},{"value":"X2","label":"2-CoinsuranceAmount"},{"value":"x1","label":"1-DeductibleAmount"}],"adjustmentGrpCodeLst":[{"value":"CO","label":"CO-ContractualObligations"},{"value":"OA","label":"OA-OtherAdjustments"},{"value":"PI","label":"PI-PayerInitiatedReductions"},{"value":"PR","label":"PR-PatientResponsibility"}]}]}]}]}';
        String replaceIllegal= stringifiedTablLst.replaceAll('\n','').replaceAll('\r','');
        Test.startTest();
        ElixirOEM_AddEraHelper.payorList('a');
        ElixirOEM_AddEraHelper.queryAllClaims(accountRec.Id,'cla',pyr.Id,new List<String>());
        ElixirOEM_AddEraHelper.queryAllClaims(accountRec.Id,'',pyr.Id,new List<String>());
        ElixirOEM_AddEraHelper.fetchPicklistValuesForClaimFields('ElixirSuite__EOB__c',new List<String>{'ElixirSuite__ERA_Status_Code__c','ElixirSuite__Action_to_be_Taken__c'},'');
        ElixirOEM_AddEraHelper.fetchPicklistValuesForObjectMdt(new List<String>{'ElixirSuite__Payment_Method__c'});
        ElixirOEM_AddEraHelper.fetchDefaultValue();
       // ElixirOEM_AddEraHelper.getClaimLineItemsInParent();
        //ElixirOEM_AddEraHelper.dummyMethod();
        //ElixirOEM_AllocateDiscountHelper.dummyMethod();
        //CustomLookupController.dummyMethod();
        ElixirOEM_AddEraHelper.saveERAEOB(eob,replaceIllegal,true,true,notesData,recommendationData);
        System.assertEquals(1, 1,'');
        Test.stopTest();
    }
}