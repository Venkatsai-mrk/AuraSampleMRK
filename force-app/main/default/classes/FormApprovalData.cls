/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class FormApprovalData {
    public class currentUserInfo{
        @AuraEnabled public Id userId {get;set;}
        @AuraEnabled public Id profileId {get;set;}
        @AuraEnabled public Id roleId {get;set;}
        @AuraEnabled public List<Object_1_css__c> defaultApprovalLevels {get;set;}
        @AuraEnabled public List<Form_Value__c> approvedValues {get;set;}
        @AuraEnabled public List<List<Form_Value__c>> previousApprovedValues {get;set;}
        public void setUserId(){
            this.userId = UserInfo.getUserId();
            //methods
        }
        public void setProfileId(){
            this.profileId = UserInfo.getProfileId();
        }
        public void setRoleId(){
            this.roleId = UserInfo.getUserRoleId();
        }
        public void setDefaultLevels(List<Object_1_css__c> defaultApprovalLevels){
            this.defaultApprovalLevels = defaultApprovalLevels;
        }
        public void setApprovedValues(List<Form_Value__c> approvedValues){
            this.approvedValues = approvedValues;
        }
        public void setpreviousApprovedValues(List<List<Form_Value__c>> previousApprovedValues){
            this.previousApprovedValues = previousApprovedValues;
        }
    }
}