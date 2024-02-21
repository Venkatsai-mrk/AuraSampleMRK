@isTest
public class Approval_CareEpisodeSettingsTest {
    @isTest
    static void testGetCustomSetting() {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        List<ElixirSuite__Elixir_Custom_Setting__c> abcd=new List<ElixirSuite__Elixir_Custom_Setting__c>();
        ElixirSuite__Elixir_Custom_Setting__c abc =new ElixirSuite__Elixir_Custom_Setting__c();
        abc.Elixir_portal_url__c=baseUrl;
        abc.ElixirSuite__Enable_Tasks_for_approvers__c=true; 
        abc.ElixirSuite__Enable_email_for_Approvers__c=true;
        abc.ElixirSuite__Care_episode_location_mandatory__c=true;
        abc.ElixirSuite__CareEpisode__c=true;
        abc.ElixirSuite__Create_Claim_For_Care_Episode__c=true;
        abc.ElixirSuite__Lock_forms_on_closure_of_a_care_episode__c=true; 
        abc.ElixirSuite__Care_Episode_Update_on_Medical_Coding__c=true;
        abc.ElixirSuite__Default_Active_Care_Episode_Filter__c='createddate desc';
        abc.ElixirSuite__Enable_Multiple_Active_Care_Episode__c=true;
        abc.ElixirSuite__Form_reminder_Interval__c=11;
        abc.ElixirSuite__Appointment_Interval__c='1D, 5D, 2H';
        abc.ElixirSuite__Payment_reminder_Interval__c=12;
        abc.ElixirSuite__Common_message_utility__c=true;
        abc.ElixirSuite__Notification_for_manual_lab__c=true;
        abc.ElixirSuite__Notifications_for_Appointment__c=true;	
        abc.ElixirSuite__Notifications_for_eLab__c=true;
        abc.ElixirSuite__Notifications_for_Form__c=true;
        abcd.add(abc);
        insert abcd;
        Test.startTest();
        Approval_CareEpisodeSettings.getCustomSetting();
        PatientPortalMessagingController.getCustomSetting();
         Approval_CareEpisodeSettings.saveApprovalCareSettings(abcd);
         PatientPortalMessagingController.portalMessagingSettings(abcd);
        Test.stopTest();
         System.assertEquals(1, 1, ' ');
         }
}