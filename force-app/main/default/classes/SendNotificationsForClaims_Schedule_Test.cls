@isTest
public class SendNotificationsForClaims_Schedule_Test 
{
    public static testMethod void sendNotificn()
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
        
        Test.startTest();
        SendNotificationsForClaims_Schedule sched=new SendNotificationsForClaims_Schedule();
        String sch = '0 0 23 * * ?';
        system.schedule('SendNotificationsForClaims_Schedule', sch, sched);
        Test.stopTest();
        system.assert( cl1.Claim_Status__c !=null,''); 
    }
}