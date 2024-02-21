public with sharing class SignOffController {
    @AuraEnabled
    public static Sorted_List_Wrapper_For_Match newVal(String veriCode , Id OrderId , String verCode , Id patientId ){
        Boolean matchedValue ; 
        String msg ;
        Id imageAttId ;
        system.debug('bfjs' + veriCode + OrderId + verCode);
        List<Prescription_Order__c> result = new List<Prescription_Order__c>();
        result = [SELECT id , name , Signature_Status__c,CreatedDate, LastModifiedDate 
                   FROM Prescription_Order__c where id=: OrderId WITH SECURITY_ENFORCED]; 
        Attachment imageAtt = [SELECT Id, ParentId, Body, ContentType FROM Attachment 
                         where parentId =: patientId WITH SECURITY_ENFORCED order by createdDate desc limit 1];
        if(veriCode == verCode ){
            result[0].Signature_Status__c = True;
            if(Schema.sObjectType.Prescription_Order__c.isUpdateable()){
            update result ;
            }
            matchedValue = true ;
            msg = 'The Form has been verified and e-signed';
            imageAttId = imageAtt.Id ;
        }
        else{ 
            matchedValue = false ;
            msg = 'The Verification Code entered is incorrect. Please check it again';
            imageAttId = '' ;
        }
         String dateNow = system.today().format();
      
        
        system.debug('the data is234567890' + msg);
      Sorted_List_Wrapper_For_Match obj = new Sorted_List_Wrapper_For_Match( result , msg , matchedValue, imageAttId,dateNow);
     system.debug('alldata is' + obj);
        return obj ;
    }
      public class Sorted_List_Wrapper_For_Match{
        
        @AuraEnabled public List<Prescription_Order__c> allData;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean checkedvalue;
        @AuraEnabled public Id attachmentId;
        @AuraEnabled public String datesNow;
        
        public Sorted_List_Wrapper_For_Match(List<Prescription_Order__c> allDatas , String messages , Boolean checkedvalues , Id attachmentIds,
                                              String dateNow){
            this.allData = allDatas ;
            this.message = messages ;
            this.checkedvalue = checkedvalues ;
            this.attachmentId = attachmentIds ;
            this.datesNow = dateNow ;
         }
    }
}