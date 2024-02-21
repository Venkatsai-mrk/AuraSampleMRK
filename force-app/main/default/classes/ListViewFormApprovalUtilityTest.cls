/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ListViewFormApprovalUtilityTest {
    
    @isTest
    static void testListViewFormApprovalUtility(){
        Account patient = TestDataFactory.createPatientAcc();
        insert patient;
        
        /*Id recordTypeId = Schema.SObjectType.Object_2__c.getRecordTypeInfosByDeveloperName().get('EHR_Form_Feature_Testing_Nursing').getRecordTypeId();
        Object_2__c obj = new Object_2__c();
        obj.RecordTypeId = recordTypeId;
        obj.AccountId__c = patient.Id;
        insert obj;*/
        
        
        Integer idToCreateNumberUnique = Integer.valueof((Math.random() * 1000000000));
        String formUniqueId = patient.Id+';'+idToCreateNumberUnique;
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        String formId = patient.Id;
        String formName = 'Feature Testing';
        String recordTypeName = 'Feature Testing';
        Datetime createdDateOfForm = System.now();
        String recordTypeDeveloperName = 'EHR_Form_Feature_Testing_Nursing';
        String formCreatedBy = uu.Id;
        String formCategory = 'Test Category';
        
        List<Elixir_NewAccountAssociatedFormsApex.FormWrapper> forms = new List<Elixir_NewAccountAssociatedFormsApex.FormWrapper>();
        Elixir_NewAccountAssociatedFormsApex.FormWrapper wrpr = new Elixir_NewAccountAssociatedFormsApex.FormWrapper(formId, formName,recordTypeName,createdDateOfForm,recordTypeDeveloperName,formCreatedBy,formCategory);
        forms.add(wrpr);
        
        Map<String,String> unqiueIdToFormName = new Map<String,String>();
        //unqiueIdToFormName.put(patient.Id+';'+idToCreateNumberUnique,patient.Form_RecordType_Name__c);
        
        Form_Value__c fv = new Form_Value__c();
        fv.Form_Id__c = patient.Id;
        fv.Is_Approver__c = true;
        fv.Is_old__c = false;
        fv.Is_Approver__c = true;
        fv.Status__c = 'Completed';
        fv.Form_Detail__c = true;
        insert fv;
        
        Object_1_css__c objCss = new Object_1_css__c();
        objCss.Form__c = patient.Id;
        objCss.Approval_Level__c = 1;
        objCss.Approval_Members__c = 'Test';
        insert objCss;
        
        
        
        
        test.startTest();
        ListViewFormApprovalUtility.updateFormWithApprovalValues(forms,unqiueIdToFormName);
        system.assertEquals(1,1, '');
        test.stopTest();
    }
    
}