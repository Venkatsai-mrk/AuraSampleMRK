public with sharing class AutoPatientStatementGeneration implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        ElixirSuite__Patient_Statment_GenerInterval__c mc = ElixirSuite__Patient_Statment_GenerInterval__c.getOrgDefaults();
        if(mc.ElixirSuite__Active__c && mc.ElixirSuite__No_of_Days__c!=null && mc.ElixirSuite__No_of_Days__c > 0){
            System.enqueueJob(new PayerStatusHandler());
        }
        
    }
    
    public static void autoPdfGen(){
        try{
            ElixirSuite__Patient_Statment_GenerInterval__c mc = ElixirSuite__Patient_Statment_GenerInterval__c.getOrgDefaults();
            
            if(mc.ElixirSuite__Active__c && mc.ElixirSuite__No_of_Days__c!=null && mc.ElixirSuite__No_of_Days__c > 0){
                Date todayDate = System.today();
                Integer days1 = (Integer) mc.No_of_Days__c;
                
                Date fromDate1 = todayDate.addDays(-days1);
                
                String fName = 'Bulk Patient Statements '+ String.valueOf(fromDate1)+' - '+String.valueOf(todayDate);  
                
                String finalPar = String.valueOf(fromDate1)+ '$' +String.valueOf(todayDate);
                //Save pdf
                PageReference pdf = Page.ElixirSuite__BulkAccountPatientStatementPDFPage;
                pdf.getParameters().put('orderId',finalPar);
                             
                ContentVersion cont = new ContentVersion();
                cont.Title = fName;
                cont.PathOnClient = fName + '.pdf';
                if(!test.isRunningTest()){
                cont.VersionData = pdf.getContentAsPdf();
                }else{
                cont.VersionData = Blob.valueof('avhyhjbj');    
                }
                cont.Origin = 'H';
                
                DMLManager.insertAsUser(cont);
                
                ElixirSuite__Patient_Statement__c patSt = new ElixirSuite__Patient_Statement__c();
                patSt.ElixirSuite__Statement_from__c = fromDate1;
                patSt.ElixirSuite__Statement_to__c = todayDate;
                patSt.ElixirSuite__Notes__c = fName;
                DMLManager.insertAsUser(patSt);
                
                Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cont.Id].ContentDocumentId; 
                //Create ContentDocumentLink 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = patSt.Id;
                cdl.ContentDocumentId = conDocId;
                cdl.shareType = 'V';
                DMLManager.insertAsUser(cdl);
                
            }
        }
        
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
    
}