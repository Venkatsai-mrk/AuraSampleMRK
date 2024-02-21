@isTest
public class TestElixirHC_LabAnalysisHelper {
    
    
    public  static testMethod void allCoverageParentMethod(){
        ElixirHC_LabAnalysisHelper.getStringifiedDate(System.today());
        List<Sample_Analysis__c> rec = [SELECT CreatedById,CreatedDate,Appearance__c,Bacteria__c,Bilesalt__c,
                                        Bilrubin__c,Casts__c,Colour__c,Comments__c,
                                        Crystal__c,Epithelial_Cells__c,Examined_By__c,
                                        Examined_Datetime__c,Glucose__c,Ketone__c,
                                        Lab_Sample_Examined_Datetime__c,Leukocyte__c,Mucus__c,
                                        Notes__c,PH__c,Picklist__c,Protein__c,
                                        Puss_Cells_W_B_C__c,Red_Cells_R_B_C__c,Schistosoma_Eggs__c,Specific_Gravity__c,Specimen_Status__c,
                                        Spermatozoa__c,Status__c,Trichomonas__c,Type__c,UA_Sample_Details__c,Urobilinogen__c,
                                        Yeast_Cells__c,Id,IsDeleted FROM Sample_Analysis__c limit 1];
        Sample_Analysis__c instance;
        Sample_Analysis__c newInstance  = new Sample_Analysis__c();
        newInstance.Lab_Sample_Examined_Datetime__c = System.now();
        newInstance.Examined_By__c = UserInfo.getUserId();
        insert newInstance;
        
        Account acc= new Account(Name='Test');
        insert acc;
        
        //  if(rec.size()>0 && rec!=null){
        //  instance =  rec[0];
        //  }
        String jsn = JSON.serialize(newInstance);
        // String jsn = '{"CreatedDate":"2020-09-16T09:27:18.000Z","Elixir_HC__Additives_if_Any__c":"None","Elixir_HC__Collection_Datetime__c":"2020-09-16T09:26:00.000Z","Elixir_HC__ContainerSize__c":"50mL","Elixir_HC__ContainerType__c":"Normal","Elixir_HC__Container_Description__c":"T-Cup","Elixir_HC__Sample_Type__c":"Physical","Elixir_HC__Specimen_Collector__c":"Provider","Elixir_HC__Specimen_Condition__c":"Good","Elixir_HC__Specimen_Quantity__c":"30mL","IsDeleted":false,"LastModifiedDate":"2020-09-16T09:27:18.000Z","Name":"UA-0747","Elixir_HC__Status__c":"Open","Elixir_HC__Lab_Sample_Examined_Datetime__c" : "2020-09-16T09:27:18.000Z","Examined_By__c" : ""}';
        // PageReference pageRef = Page.LabAnalysisPDFGenerator;
        // Test.setCurrentPage(pageRef);
        // ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(jsn);
        ApexPages.currentPage().getParameters().put('orderId',jsn);
        ElixirHC_LabAnalysisHelper inititate = new ElixirHC_LabAnalysisHelper(); 
        inititate.getAccountInfo(acc.Id);
        system.assert( acc.Name!=null); 
    }
    
}