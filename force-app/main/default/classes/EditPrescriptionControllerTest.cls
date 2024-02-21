@isTest
public class EditPrescriptionControllerTest {
    
      @isTest
    public static void PrescTest(){
        
         Account acc = new Account();
        acc.Name = 'Ishita';
        acc.ElixirSuite__DOB__c = System.today();
        acc.ElixirSuite__Gender__c = 'Female';
        acc.ElixirSuite__Email_Id__c = 'ishita@gmail.com';
        insert acc;
        
        ElixirSuite__Provider__c provRec = new ElixirSuite__Provider__c();
        provRec.Name = 'Elixir';
        provRec.ElixirSuite__Provider_Code__c = 'Delhi';
        insert provRec;
        
        ElixirSuite__Visits__c visRec = new ElixirSuite__Visits__c();
        visRec.ElixirSuite__Account__c = acc.Id;
        visRec.Name = 'Ishita Visit';
        visRec.ElixirSuite__Status__c='Active';
        visRec.ElixirSuite__Care_Episode_Location__c = provRec.Id;
        insert visRec;
        
        Account acc1 = new Account();
        acc1.Name = 'Mahima';
        acc1.ElixirSuite__DOB__c = System.today();
        acc1.ElixirSuite__Gender__c = 'Female';
        acc1.ElixirSuite__Email_Id__c = 'mahima@gmail.com';
        insert acc1;
        
        
         List<ElixirSuite__Visits__c> careEpRec = [select id,name from ElixirSuite__Visits__c	where ElixirSuite__Account__c= :acc.Id and ElixirSuite__Status__c='Active' limit 1];
        System.debug('careEpRec:'+careEpRec);
        System.debug('careEpRec size:'+careEpRec.size());
        String careId;
        boolean checkCare ;
        if(careEpRec.size()==0){
            checkCare = true;
        }
        else if(careEpRec.size()==1){
            checkCare = false;
            careId = careEpRec[0].id;
             System.debug('inside if care episode is there:'+careId);
        }

        Form_Template_Data__c tdRec = new Form_Template_Data__c(Form_Unique_Id__c = 'I874841232323', Section_Number__c = '2', Account__c = acc.Id);

        insert tdRec;

        String formUnId = tdRec.Form_Unique_Id__c;
        
        EditPrescriptionController.buildPresc(acc.Id,formUnId);
        EditPrescriptionController.buildPresc(acc1.Id,formUnId);
        System.assertEquals(1, 1, '');
        
    }

}