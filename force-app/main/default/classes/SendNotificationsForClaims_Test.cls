@isTest
public class SendNotificationsForClaims_Test 
{
    public static testMethod void sendNotif()
    {
        ClaimNotificationParameters__c cusSet = new ClaimNotificationParameters__c();
        cusSet.Claringhouse_Accepted__c=-1;
        cusSet.Clearinghouse_Accepted_Records_Days__c=-1;
        cusSet.Clearinghouse_Rejected__c=-1;
        cusSet.Payer_Accepted__c=-1;
        cusSet.Clearinghouse_Rejected_Records_Days__c=-1;
        cusSet.Ready_to_submit__c=-1;
        cusSet.Send_to_ClaringHouse__c=-1;
        cusSet.Payer_Accepted_Records_Days__c=-1;
        cusSet.Ready_to_submit_Records_Days__c=-1;
        cusSet.Denied_Notify_Days__c=-1;
        cusSet.Denied_Records_Days__c=-1;
        cusSet.Payer_Rejected_Notify_Days__c=-1;
        cusSet.Payer_Rejected_Records_Days__c=-1;
        cusSet.Underpaid_Notify_Days__c=-1;
        cusSet.Underpaid_Records_Days__c=-1;
        cusSet.Send_to_Clearinghouse_Records_Days__c=-1;
        insert cusSet;
        
        
        Claim__c cl1 = new Claim__c();
        cl1.Claim_Status__c = 'Payer Accepted';          
        insert cl1;
        
        
        Claim__c cl2 = new Claim__c();
        cl2.Claim_Status__c = 'Payer Rejected';
        insert cl2;
        
        Claim__c cl3 = new Claim__c();
        cl3.Claim_Status__c = 'Ready to Submit';
        insert cl3;
        
        Claim__c cl4 = new Claim__c();
        cl4.Claim_Status__c = 'Sent to Clearing house';
        insert cl4;
        
        Claim__c cl5 = new Claim__c();
        cl5.Claim_Status__c = 'Clearing house accepted';
        insert cl5;
        
        Claim__c cl6 = new Claim__c();
        cl6.Claim_Status__c = 'Clearing house rejected';
        insert cl6;
        
        Claim__c cl7 = new Claim__c();
        cl7.Claim_Status__c = 'Denied';
        insert cl7;
        
        Claim__c cl8 = new Claim__c();
        cl8.Claim_Status__c = 'Underpaid';
        insert cl8;
        
        Test.startTest();
        SendNotificationsForClaims obj=new SendNotificationsForClaims(); 
        DataBase.executeBatch(obj,200);
        Test.stopTest();  
        system.assert( cl1.Claim_Status__c !=null,''); 
    }
}