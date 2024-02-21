@isTest
public class inlineEditCareEpisodeControllerTest {
    
    @isTest
    public static void insCareEps(){
        
        Account accRec = new Account();
        accRec.Name = 'Mahima';
        accRec.ElixirSuite__DOB__c = System.today();
        accRec.ElixirSuite__Gender__c = 'Female';
        accRec.ElixirSuite__Email_Id__c = 'anmolsaxena.25@gmail.com';
        accRec.ElixirSuite__MRN_Number_New__c = 'mir770';
        insert accRec;
        
        ElixirSuite__Visits__c careRec = new ElixirSuite__Visits__c();
        careRec.ElixirSuite__Account__c = accRec.Id;
        careRec.Name = 'Mahima Vist';
        careRec.ElixirSuite__Status__c = 'Active';
        insert careRec;
        
        Form_Template_Data__c tdRec = new Form_Template_Data__c(Form_Unique_Id__c = 'I874841232323', Section_Number__c = '2', Account__c = accRec.Id);
        
        DMLManager.insertAsUser(tdRec);
        
        String formUnId = tdRec.Form_Unique_Id__c;
        
        String res = inlineEditCareEpisodeController.updateCareEpisode(careRec.Id,accRec.Id,formUnId);
        
        System.AssertEquals('completed',res);
        
    }
    
    @isTest
    public static void updCareEps(){
        
        Account accRec = new Account();
        accRec.Name = 'Mahima';
        accRec.ElixirSuite__DOB__c = System.today();
        accRec.ElixirSuite__Gender__c = 'Female';
        accRec.ElixirSuite__Email_Id__c = 'anmolsaxena.25@gmail.com';
        accRec.ElixirSuite__MRN_Number_New__c = 'mir770';
        insert accRec;
        
        ElixirSuite__Visits__c careRec = new ElixirSuite__Visits__c();
        careRec.ElixirSuite__Account__c = accRec.Id;
        careRec.Name = 'Mahima Vist';
        careRec.ElixirSuite__Status__c = 'Active';
        insert careRec;
        
        Form_Template_Data__c tdRec = new Form_Template_Data__c(Form_Unique_Id__c = 'I874841232323', Section_Number__c = '2', Account__c = accRec.Id);
        
        DMLManager.insertAsUser(tdRec);
        
        String formUnId = tdRec.Form_Unique_Id__c;
        
        String formValueName = '';
        formValueName = 'Form -' + system.now().format();
        Form_value__c formValue = new Form_Value__C(
            Name = formValueName,
            Form_Name__c= formValueName,
            Form_Id__c = formUnId,
            Account__c = accRec.Id,
            Is_CareEpisode__c = true,
            Care_Episode__c = careRec.Id,
            Episode_Id__c = careRec.Id
        );
        DMLManager.insertAsUser(formValue);
        
        String res = inlineEditCareEpisodeController.updateCareEpisode(careRec.Id,accRec.Id,formUnId);
        
        System.AssertEquals('completed',res);
        
    }
    
}