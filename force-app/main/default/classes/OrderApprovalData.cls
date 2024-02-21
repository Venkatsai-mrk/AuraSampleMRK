public with sharing class OrderApprovalData {
    public class currentUserInfo{
        @AuraEnabled public Id userId {get;set;}
        @AuraEnabled public Id profileId {get;set;}
        @AuraEnabled public Id roleId {get;set;}

        @AuraEnabled public List<ElixirSuite__Master_Object__c> defaultApprovalLevels {get;set;}
        @AuraEnabled public List<OrderSignatureSave.SignAndAprroveData> approvedValues {get;set;}
        @AuraEnabled public List<List<Object>> previousApprovedValues {get;set;}
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
        public void setDefaultLevels(List<ElixirSuite__Master_Object__c> defaultApprovalLevels){
            this.defaultApprovalLevels = defaultApprovalLevels;
        }
        public void setApprovedValues(List<OrderSignatureSave.SignAndAprroveData> approvedValues){
            this.approvedValues = approvedValues;
        }
        public void setpreviousApprovedValues(List<List<Object>> previousApprovedValues){
            this.previousApprovedValues = previousApprovedValues;
        }
    }
}