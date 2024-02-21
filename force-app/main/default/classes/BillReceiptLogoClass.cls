public with sharing class BillReceiptLogoClass {
    @AuraEnabled
    public static void uploadFile(String base) {
        String base64=base;
        system.debug('base64'+base64);
       /* List<ElixirSuite__Master_Object__c> masterRecList=new List<ElixirSuite__Master_Object__c>();
        List<ElixirSuite__Master_Object__c> masterRecList1=[select id,Name,ElixirSuite__Company_logo__c,
                        ElixirSuite__Is_Company_logo__c from ElixirSuite__Master_Object__c where ElixirSuite__Is_Company_logo__c=true];
        if(masterRecList1.size() == 0 ){
            ElixirSuite__Master_Object__c masterRec= new ElixirSuite__Master_Object__c();
            masterRec.ElixirSuite__Company_logo__c=base64;
            masterRec.ElixirSuite__Is_Company_logo__c=true;
        masterRecList.add(masterRec);
        }
        else if(masterRecList1.size()== 1){
            for(ElixirSuite__Master_Object__c mr:masterRecList1){
                mr.ElixirSuite__Company_logo__c=base64;
                masterRecList.add(mr);
            }
        }
        
        upsert masterRecList;*/
        uploadStaticResource(base64);
    }
    public static void uploadStaticResource(String base64){
        system.debug('base64'+base64);
        List<Attachment> attachRecordList= new  List<Attachment>();
        Id recordTypeIdTemp = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        List<ElixirSuite__Provider__c> provRecord =[SELECT Id, Name, ElixirSuite__Provider_Code__c, RecordTypeId FROM ElixirSuite__Provider__c  WHERE RecordTypeId =:recordTypeIdTemp WITH SECURITY_ENFORCED];
        List<Attachment> attachRecord=[SELECT Id,  Name, Body, BodyLength, ContentType, CreatedDate,ParentId, Description  FROM Attachment where Name='Company Logo' AND ParentId=:provRecord[0].Id WITH SECURITY_ENFORCED];
       
        string myTextContent=base64;
       // Blob tempBlob = Blob.valueOf(myTextContent);
       if(attachRecord.size() == 0 ){
        Attachment attRecord = new Attachment();
        attRecord.Name='Company Logo';
        attRecord.ContentType='PNG';
        attRecord.ParentId = provRecord[0].id;
        attRecord.Body =EncodingUtil.base64Decode(myTextContent) ;
        attRecord.IsPrivate = false;
        attachRecordList.add(attRecord);

       }
       else if(attachRecord.size() == 1){
        for(Attachment att:attachRecord){
            att.ContentType='PNG';
            att.Body=EncodingUtil.base64Decode(myTextContent) ;
            attachRecordList.add(att);
        }
       
       }
       //upsert attachRecordList;
       DMLManager.upsertAsUser(attachRecordList);
       
        



       


    }
}
