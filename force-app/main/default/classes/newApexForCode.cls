public with sharing class newApexForCode { 
    @AuraEnabled
    public static Sorted_List_Wrapper_For_Match newVal(String veriCode , Id formId , String verCode , Id patientId , String sObjectNameVal,String comment){
        Boolean matchedValue ; 
        String msg ;
        Id imageAttId ;
        /*List<String> strList = new List<String>();
        system.debug('bfjs' + veriCode + '   ' + formId + '   ' + verCode + ' ' + comment);
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(sObjectNameVal).getDescribe().fields.getMap();
        strList = new List<String>(objectFields.keySet());
        String resultInitial = 'SELECT ' + String.join( strList, ',' ) + ' FROM ' + sObjectNameVal + ' ' + 'where id ='+ '\'' + formId + '\'' + '' + 'limit 1' ;
        system.debug('the new val is' + resultInitial);
        String listType = 'List<' + sObjectNameVal + '>';
        List<SObject> result = (List<SObject>)Type.forName(listType).newInstance();
        
        result = Database.query(resultInitial);*/
       // system.debug('the new val is' + result);
        // List<Form__c> result = new List<Form__c>();
        //  String value = 'SELECT Id , name , Patient_Sign_Status__c , CreatedDate FROM '
        /*  result = [SELECT id , name , Patient_Sign_Status__c,CreatedDate, LastModifiedDate 
FROM sObjectNameVal where id=: formId]; */
        String imageAtt ;
        String signerName ;
        try{
        if(sObjectNameVal == 'Account'){
        Account acc = [SELECT Id,Signature_Attachment_Id__c,name FROM Account 
                               where id =: patientId 
                               WITH SECURITY_ENFORCED
                               order by createdDate desc ];
            imageAtt = acc.Signature_Attachment_Id__c ;
            signerName = acc.name ;
        }
        if(sObjectNameVal== 'User'){
            imageAtt = [Select id,Signature_Attachment_Id__c From User 
            Where Id = :UserInfo.getUserId()
            WITH SECURITY_ENFORCED][0].Signature_Attachment_Id__c;
            signerName = UserInfo.getName();
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        if(veriCode == verCode ){
          /*  if(sObjectNameVal== 'Form__c'){
                string val = 'Patient_Sign_Status__c';
                result[0].put(val,true); 
                update result ;
            }
             if(sObjectNameVal== 'Case'){
                String valPatient = 'Approval_Level_1__c';
                String commentPatient = 'Comment_1__c';
                result[0].put(valPatient,true); 
                result[0].put(commentPatient , comment);
                update result ;
            }*/
            matchedValue = true ;
            msg = 'The Form has been verified and e-signed';
            imageAttId = imageAtt ;
        }
        else{
            matchedValue = false ;
            msg = 'The Verification Code entered is incorrect. Please check it again';
            imageAttId = ' ' ;
        }
        String dateNow = system.today().format();
        
        
        system.debug('the data is234567890' + signerName);
        Sorted_List_Wrapper_For_Match obj = new Sorted_List_Wrapper_For_Match( msg , matchedValue, imageAttId,dateNow,signerName);
        system.debug('alldata is' + obj);
        
        return obj ;
    }
    
    
    
    public class Sorted_List_Wrapper_For_Match{
        
        @AuraEnabled public String message;
        @AuraEnabled public Boolean checkedvalue;
        @AuraEnabled public Id attachmentId;
        @AuraEnabled public String datesNow;
        @AuraEnabled public String signeeName;
        
        public Sorted_List_Wrapper_For_Match(String messages , Boolean checkedvalues , Id attachmentIds,
                                             String dateNow , String signeeNames){
                                                 this.message = messages ;
                                                 this.checkedvalue = checkedvalues ;
                                                 this.attachmentId = attachmentIds ;
                                                 this.datesNow = dateNow ;
                                                 this.signeeName = signeeNames ;
                                             }
    }
    
}