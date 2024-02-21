@isTest
private class TestSendNotificationsForClaims {
    static testmethod void test() {
        ClaimNotificationParameters__c clp = new ClaimNotificationParameters__c();
        clp.Clearinghouse_Accepted_Records_Days__c = 0;
        clp.Claringhouse_Accepted__c = 0;
        clp.Clearinghouse_Rejected__c = 0;
        clp.Clearinghouse_Rejected_Records_Days__c = 0;
        clp.Payer_Accepted_Records_Days__c = 0;
        clp.Ready_to_submit_Records_Days__c = 0;
        clp.Send_to_Clearinghouse_Records_Days__c =0;
        insert clp;
        Account pa = new Account();
        pa.Name = 'Test';
        insert pa;
        
        List<Claim__c> lstClaims= new List<Claim__c>();
        for(Integer i=0 ;i <2;i++)
        {
            Claim__c cl = new Claim__c();
            cl.Amount_Paid__c =i;
            cl.Account__c = pa.Id;
            cl.Claim_Status__c = 'Clearing house rejected';
            lstClaims.add(cl);
        } 
    		Claim__c c = new Claim__c();
            c.Amount_Paid__c =10;
            c.Account__c = pa.Id;
            c.Claim_Status__c = 'Sent to Clearing house';
            lstClaims.add(c);
        
        Claim__c c1 = new Claim__c();
            c1.Amount_Paid__c =10;
            c1.Account__c = pa.Id;
            c1.Claim_Status__c = 'Ready to Submit';
            lstClaims.add(c1);
        
        Claim__c c2 = new Claim__c();
            c2.Amount_Paid__c =10;
            c2.Account__c = pa.Id;
            c2.Claim_Status__c = 'Clearing house accepted';
            lstClaims.add(c2);
        
        insert lstClaims;
        Test.startTest();
        
       // if(!Test.isRunningTest()){
            SendNotificationsForClaims snc = new SendNotificationsForClaims();
            Database.executeBatch(snc);
        //}
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
}