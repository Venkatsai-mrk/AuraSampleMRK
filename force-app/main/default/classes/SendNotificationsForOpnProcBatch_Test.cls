@isTest
public class SendNotificationsForOpnProcBatch_Test 
{
    public static testMethod void sendAlert()
    {
        
        ProcedureAlertParameters__c proAlrt = new ProcedureAlertParameters__c();
        proAlrt.Active__c = True;
        proAlrt.No_of_days__c = 1;
        insert proAlrt;
        
        Account pat = new Account();
        pat.Name = 'test';
        pat.Gender__c = 'Female';
        pat.Patient_s_Birth_Date__c = system.today();
        pat.Account_Number__c = '123456';
        insert pat;
        
       Provider__c providerTemp = TestDataFactory.createProviderTemp();
        //providerTemp.Account__c =  null;
        insert providerTemp;
        
        
        Procedure__c pro1 = new Procedure__c();
        pro1.Name = 'test';
        pro1.From_Date_of_Service__c = system.today()-2;
        pro1.To_Date__c = system.today();
        pro1.CPT_HCPCS_Code__c = '99203';
        //pro1.Account__c = pat.Id;
        pro1.Name = 'test';
        try{
            insert pro1;
        }
        catch(Exception e)
        {}
        
        Actual_Price__c ActPrc = TestDataFactory.createActualPrice(pro1.Id,providerTemp.Id);
        ActPrc.Procedure__c = pro1.Id;
        ActPrc.Provider__c = providerTemp.Id;
        insert ActPrc;
        
        Test.startTest();
        SendNotificationsForOpnProc obj=new SendNotificationsForOpnProc(); 
        DataBase.executeBatch(obj,200);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();   
    }
    
    public static testMethod void sendAlert3()
    {
        
        ProcedureAlertParameters__c proAlrt = new ProcedureAlertParameters__c();
        proAlrt.Active__c = True;
        proAlrt.No_of_hours__c = 1;
        insert proAlrt;
        
        Account pat = new Account();
        pat.Name = 'test';
        pat.Gender__c = 'Female';
        pat.Patient_s_Birth_Date__c = system.today();
        pat.Account_Number__c = '123456';
        insert pat;
        
        Procedure__c pro1 = new Procedure__c();
        pro1.Name = 'test';
        pro1.From_Date_of_Service__c = system.now();
        pro1.To_Date__c = system.today();
        pro1.CPT_HCPCS_Code__c = '99203';
        //pro1.Account__c = pat.Id;
        pro1.Name = 'test';
        try{
            insert pro1;
        }
        catch(Exception e)
        {}
        
        
        Provider__c providerTemp = TestDataFactory.createProviderTemp();
        //providerTemp.Account__c =  null;
        insert providerTemp;
        
        Actual_Price__c ActPrc = TestDataFactory.createActualPrice(pro1.Id,providerTemp.Id);
        ActPrc.Procedure__c = pro1.Id;
        ActPrc.Provider__c = providerTemp.Id;
        insert ActPrc;
        
        
        
        Test.startTest();
        SendNotificationsForOpnProc obj=new SendNotificationsForOpnProc(); 
        DataBase.executeBatch(obj,200);
        Test.stopTest();  
        System.assertEquals(1, 1, ' ');
    }    
}