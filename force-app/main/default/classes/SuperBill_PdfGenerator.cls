public with sharing class SuperBill_PdfGenerator {
    public Account acc{get;set;}
    public ElixirSuite__Visits__c care{get;set;}
    public ElixirSuite__VOB__c vobRec{get;set;}
    public ElixirSuite__VOB__c secondaryVobRec{get;set;}
    public String accDob{get;set;}
    public List<Wrapper> wrpLst{get;set;}
    public List<DiagnosisWrapper> diagWrpLst{get;set;}
    public static string imagePdf{get; set;}
    public Decimal totalCharges{get;set;}
    public Decimal totalPaid{get;set;}
    public Decimal totalDue{get;set;}
    public static String patientAddress {get;set;}
    public static String renderingProviderAddress {get;set;}
    
    public SuperBill_PdfGenerator(){
        try{
            wrpLst = new List<Wrapper>();
            diagWrpLst = new List<DiagnosisWrapper>();
            totalCharges=0;
            totalPaid = 0;
            totalDue = 0;
            Integer fieldCode = 64;
            Id accountId = ApexPages.currentPage().getParameters().get('aId');
            Id careId = ApexPages.currentPage().getParameters().get('careId');
            imagePdf=getPdfImg();
            if(accountId != null && String.isNotBlank(accountId)){
                acc = [SELECT Id, 
                       Name,BillingAddress, 
                       BillingStreet, 
                       BillingCity, 
                       BillingState, 
                       BillingPostalCode, 
                       Phone,
                       ElixirSuite__SSN__c,
                       ElixirSuite__First_Name__c,
                       ElixirSuite__Last_Name__c, 
                       ElixirSuite__DOB__c 
                       FROM Account 
                       where Id=:accountId
                       WITH SECURITY_ENFORCED];
                
                DateTime dt = acc.ElixirSuite__DOB__c;
                string  st= dt.format('MM-dd-yyyy');
                accDob = st;
                // added by jami for LX3-12330
                if (acc != null && acc.BillingAddress != null){
                String street = '';
                String city = '';
                String state = '';
                String postalCode = '';
                if(acc.BillingAddress.getStreet() != null){
                    street = acc.BillingAddress.getStreet();
                }
                if(acc.BillingAddress.getCity() != null){
                    city = acc.BillingAddress.getCity();
                }
                if(acc.BillingAddress.getState() != null){
                    state = acc.BillingAddress.getState();
                }
                if(acc.BillingAddress.getPostalCode() != null){
                    postalCode = acc.BillingAddress.getPostalCode();
                }
                patientAddress = street+' '+ city +' ' +state + ' ' + postalCode;
                }
                Id primaryRecordTypeId =
                    Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName()
                    .get('VOB_record_type').getRecordTypeId();
                
                Id secondaryRecordTypeId =
                    Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName()
                    .get('Secondary_VOB').getRecordTypeId();
                
                List<ElixirSuite__VOB__c> vobLst = [SELECT Id, 
                                                    ElixirSuite__Account__c, 
                                                    ElixirSuite__Status__c,
                                                    ElixirSuite__Set_Default_VOB__c,
                                                    ElixirSuite__Member_Id__c,
                                                    ElixirSuite__Insured_Policy_Group_FECA_Number__c,
                                                    ElixirSuite__Payer__r.Name 
                                                    FROM ElixirSuite__VOB__c 
                                                    WHERE ElixirSuite__Account__c= :accountId
                                                    AND ElixirSuite__Status__c='Active'
                                                    AND RecordTypeId=:primaryRecordTypeId
                                                    AND ElixirSuite__Set_Default_VOB__c='Yes' 
                                                    WITH SECURITY_ENFORCED
                                                    order by createddate DESC];
                
                List<ElixirSuite__VOB__c> activeVobLst = new List<ElixirSuite__VOB__c>();
                List<ElixirSuite__VOB__c> secondaryActiveVobLst = new List<ElixirSuite__VOB__c>();
                
                if(vobLst != null && vobLst.size() > 0){
                    vobRec = vobLst[0];
                }
                else{
                    
                    activeVobLst = [SELECT Id, 
                                    ElixirSuite__Account__c, 
                                    ElixirSuite__Status__c,
                                    ElixirSuite__Member_Id__c,
                                    ElixirSuite__Insured_Policy_Group_FECA_Number__c,
                                    ElixirSuite__Payer__r.Name 
                                    FROM ElixirSuite__VOB__c 
                                    WHERE ElixirSuite__Account__c= :accountId
                                    AND RecordTypeId=:primaryRecordTypeId
                                    AND ElixirSuite__Status__c='Active'
                                    WITH SECURITY_ENFORCED
                                    order by createddate DESC];
                    
                    if(activeVobLst != null && activeVobLst.size() > 0){
                        vobRec = activeVobLst[0];
                    }
                    
                }
                
                List<ElixirSuite__VOB__c> secondaryVobLst = [SELECT Id, 
                                                             ElixirSuite__Account__c, 
                                                             ElixirSuite__Status__c,
                                                             ElixirSuite__Set_Default_VOB__c,
                                                             ElixirSuite__Member_Id__c,
                                                             ElixirSuite__Insured_Policy_Group_FECA_Number__c,
                                                             ElixirSuite__Payer__r.Name 
                                                             FROM ElixirSuite__VOB__c 
                                                             WHERE ElixirSuite__Account__c= :accountId
                                                             AND ElixirSuite__Status__c='Active'
                                                             AND RecordTypeId=:secondaryRecordTypeId
                                                             AND ElixirSuite__Set_Default_VOB__c='Yes' 
                                                             WITH SECURITY_ENFORCED
                                                             order by createddate DESC];
                
                if(secondaryVobLst != null && secondaryVobLst.size() > 0){
                    secondaryVobRec = secondaryVobLst[0];
                }
                else{
                    
                    secondaryActiveVobLst = [SELECT Id, 
                                             ElixirSuite__Account__c, 
                                             ElixirSuite__Status__c,
                                             ElixirSuite__Member_Id__c,
                                             ElixirSuite__Insured_Policy_Group_FECA_Number__c,
                                             ElixirSuite__Payer__r.Name 
                                             FROM ElixirSuite__VOB__c 
                                             WHERE ElixirSuite__Account__c= :accountId
                                             AND RecordTypeId=:secondaryRecordTypeId
                                             AND ElixirSuite__Status__c='Active'
                                             WITH SECURITY_ENFORCED
                                             order by createddate DESC];
                    
                    if(secondaryActiveVobLst != null && secondaryActiveVobLst.size() > 0){
                        secondaryVobRec = secondaryActiveVobLst[0];
                    }
                    
                }
                
            }
            if(careId != null && String.isNotBlank(careId)){
                care = [SELECT Id, 
                        Name,ElixirSuite__Care_Episode_Location__c,
                        ElixirSuite__Care_Episode_Location__r.Name,
                        ElixirSuite__Care_Episode_Location__r.ElixirSuite__Address__c,
                        ElixirSuite__Care_Episode_Location__r.ElixirSuite__Provider_Code__c,
                        ElixirSuite__Care_Episode_Location__r.ElixirSuite__Provider_Tax_Id__c,
                        ElixirSuite__Rendering_Provider__c,
                        ElixirSuite__Rendering_Provider__r.Name,
                        ElixirSuite__Rendering_Provider__r.MailingStreet,
                        ElixirSuite__Rendering_Provider__r.MailingCity,
                        ElixirSuite__Rendering_Provider__r.MailingState,
                        ElixirSuite__Rendering_Provider__r.MailingPostalCode,
                        ElixirSuite__Rendering_Provider__r.ElixirSuite__Practitioner_NPI__c,
                        ElixirSuite__Rendering_Provider__r.ElixirSuite__Tax_Id__c
                        FROM ElixirSuite__Visits__c 
                        where Id=:careId
                        WITH SECURITY_ENFORCED];
                // added by jami for LX3-12330
                if (care != null) {
                String street = '';
                String city = '';
                String state = '';
                String postalCode = '';
                if(care.ElixirSuite__Rendering_Provider__r.MailingStreet != null){
                    street = care.ElixirSuite__Rendering_Provider__r.MailingStreet;
                }
                if(care.ElixirSuite__Rendering_Provider__r.MailingCity != null){
                    city = care.ElixirSuite__Rendering_Provider__r.MailingCity;
                }
                if(care.ElixirSuite__Rendering_Provider__r.MailingState != null){
                    state = care.ElixirSuite__Rendering_Provider__r.MailingState;
                }
                if(care.ElixirSuite__Rendering_Provider__r.MailingPostalCode != null){
                    postalCode = care.ElixirSuite__Rendering_Provider__r.MailingPostalCode;
                }
                renderingProviderAddress = street+' '+city +' ' +state + ' ' + postalCode;
                }
                List<ElixirSuite__Procedure__c> lstProcedure = [SELECT Id, 
                                                                ElixirSuite__From_Date_of_Service__c, 
                                                                Name,
                                                                (select id,ElixirSuite__Total_Actual_Patient_Paid_Amount__c from ElixirSuite__Payment_Transaction__r), 
                                                                ElixirSuite__Code_Description__c, 
                                                                ElixirSuite__Days_Units__c, 
                                                                ElixirSuite__Modifier1__r.Name, 
                                                                ElixirSuite__Modifier2__r.Name, 
                                                                ElixirSuite__Modifier3__r.Name, 
                                                                ElixirSuite__Modifier4__r.Name, 
                                                                ElixirSuite__Charges__c, 
                                                                ElixirSuite__Visits__c 
                                                                FROM ElixirSuite__Procedure__c
                                                                where ElixirSuite__Visits__c=:careId
                                                                WITH SECURITY_ENFORCED];
                
                if(lstProcedure != null && lstProcedure.size() > 0){
                    
                    List<Id> procId = new List<Id>();
                    Map<id,Set<String>> procDiagnosisCode = new Map<id,Set<String>>();//
                    Map<id,Integer> careDiagnosisPointer = new Map<id,Integer>();//
                    Map<String,String> diagCodeVsPointer = new Map<String,String>();
                    
                    for(ElixirSuite__Procedure__c eachProc : lstProcedure){
                        procId.add(eachProc.Id);
                    }
                    
                    List<ElixirSuite__Procedure_Diagnosis__c> diagList =[Select id,
                                                                         ElixirSuite__ICD_Codes__r.name,
                                                                         ElixirSuite__ICD_Codes__r.ElixirSuite__Code_Description1__c,
                                                                         ElixirSuite__Procedure__c 
                                                                         from 
                                                                         ElixirSuite__Procedure_Diagnosis__c 
                                                                         where ElixirSuite__Procedure__c in :procId 
                                                                         WITH SECURITY_ENFORCED];
                    
                    if(diagList != null && diagList.size() > 0){
                        for(ElixirSuite__Procedure_Diagnosis__c diag:diagList){
                            if(procDiagnosisCode.containsKey(diag.ElixirSuite__Procedure__c)) {
                                procDiagnosisCode.get(diag.ElixirSuite__Procedure__c).add(diag.ElixirSuite__ICD_Codes__c);
                            }else{
                                procDiagnosisCode.put(diag.ElixirSuite__Procedure__c,new Set<String>{diag.ElixirSuite__ICD_Codes__c});
                            }  
                        }//      
                        
                        for(ElixirSuite__Procedure__c eachProc : lstProcedure){
                            
                            Wrapper wrpr = new Wrapper();
                            
                            wrpr.dateOfProcedure = (eachProc.ElixirSuite__From_Date_of_Service__c).format('MM-dd-yyyy');
                            wrpr.cptCode = eachProc.Name;
                            wrpr.cptDescription = eachProc.ElixirSuite__Code_Description__c;
                            wrpr.units = eachProc.ElixirSuite__Days_Units__c;
                            wrpr.m1 = eachProc.ElixirSuite__Modifier1__r.Name;
                            wrpr.m2 = eachProc.ElixirSuite__Modifier2__r.Name;
                            wrpr.m3 = eachProc.ElixirSuite__Modifier3__r.Name;
                            wrpr.m4 = eachProc.ElixirSuite__Modifier4__r.Name;
                            wrpr.charges = eachProc.ElixirSuite__Charges__c;
                            
                            List<ElixirSuite__Payment_Transaction__c> masterTransRec = eachProc.ElixirSuite__Payment_Transaction__r;
                            wrpr.amountPaid = 0;
                            wrpr.amountDue = 0;
                            if(masterTransRec != null && masterTransRec.size() > 0){
                                wrpr.amountPaid = masterTransRec[0].ElixirSuite__Total_Actual_Patient_Paid_Amount__c;
                                
                                wrpr.amountDue = eachProc.ElixirSuite__Charges__c - masterTransRec[0].ElixirSuite__Total_Actual_Patient_Paid_Amount__c;
                            }
                            
                            if(careDiagnosisPointer!=null && careDiagnosisPointer.get(eachProc.ElixirSuite__Visits__c)!=null){
                                
                                fieldCode = careDiagnosisPointer.get(eachProc.ElixirSuite__Visits__c);
                                
                            }
                            for(String diag: procDiagnosisCode.get(eachProc.Id)){
                                
                                
                                if(fieldCode <= 76){
                                    if(diagCodeVsPointer!=null && diagCodeVsPointer.containsKey(diag)){
                                        
                                        
                                        if(wrpr.diagnosisPointer != null){
                                            wrpr.diagnosisPointer = wrpr.diagnosisPointer + ','+diagCodeVsPointer.get(diag); 
                                        }else{
                                            wrpr.diagnosisPointer = diagCodeVsPointer.get(diag);
                                        }
                                        
                                    }
                                    else{
                                        
                                        ElixirSuite__ICD_Codes__c icdRec = [Select Id,
                                                                            Name,
                                                                            ElixirSuite__Code_Description1__c
                                                                            from ElixirSuite__ICD_Codes__c
                                                                            where Id=:diag
                                                                            WITH SECURITY_ENFORCED];
                                        
                                        DiagnosisWrapper diagWrpr = new DiagnosisWrapper();
                                        diagWrpr.diagnosisPointer = string.fromCharArray(new List<Integer> {fieldCode+1});
                                        diagWrpr.icdCode = icdRec.Name;
                                        diagWrpr.diagnosisName = icdRec.ElixirSuite__Code_Description1__c;
                                        diagCodeVsPointer.put(diag,string.fromCharArray(new List<Integer> {fieldCode+1}));
                                        diagWrpLst.add(diagWrpr);
                                        
                                        if(wrpr.diagnosisPointer != null){
                                            wrpr.diagnosisPointer = wrpr.diagnosisPointer + ','+string.fromCharArray(new List<Integer> {fieldCode+1}); 
                                        }else{
                                            wrpr.diagnosisPointer = string.fromCharArray(new List<Integer> {fieldCode+1});
                                        }
                                        
                                        
                                        fieldCode = fieldCode + 1;
                                        careDiagnosisPointer.put(eachProc.ElixirSuite__Visits__c,fieldCode);
                                        
                                    }
                                    
                                }
                                
                            }
                            wrpLst.add(wrpr);
                        }
                        
                        for(Wrapper wrpr : wrpLst){
                            
                            totalCharges = totalCharges + wrpr.charges;
                            totalPaid = totalPaid + wrpr.amountPaid;
                            totalDue = totalDue + wrpr.amountDue;
                            
                        }
                    }
                    
                }
                
            }
        }
        catch(Exception e){
           // ExceptionLog.logError(e);
        }
    }
    
    @future(callout=true)
    public static void createPdf(List<Id> lstCareIds,String accId){
        
        List<ContentDocumentLink> conAttachment = new List<ContentDocumentLink>();
        String fName = '';
        try{
            if(lstCareIds != null && lstCareIds.size() > 0){
                for(Id careId: lstCareIds){
                    ElixirSuite__Visits__c careRec = [Select Id,
                                                      Name
                                                      from
                                                      ElixirSuite__Visits__c
                                                      where Id=:careId
                                                      WITH SECURITY_ENFORCED];
                    
                    fName = 'Super Bill - '+    careRec.Name;                             
                    //Save pdf
                    PageReference pdf = Page.SuperBillPage;
                    pdf.getParameters().put('fName',fName);
                    pdf.getParameters().put('aId',accId);
                    pdf.getParameters().put('careId',careId);
                    Blob body;                 
                    ContentVersion cont = new ContentVersion();
                    cont.Title = fName;
                    cont.PathOnClient = fName + '.pdf';
                    cont.VersionData = pdf.getContentAsPdf();
                    cont.Origin = 'H';
                    
                    DMLManager.insertAsUser(cont);
                    
                    Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cont.Id].ContentDocumentId; 
                    //Create ContentDocumentLink 
                    ContentDocumentLink cdl = New ContentDocumentLink();
                    cdl.LinkedEntityId = careId;
                    cdl.ContentDocumentId = conDocId;
                    cdl.shareType = 'V';
                    conAttachment.add(cdl);
                    
                }
                DMLManager.insertAsUser(conAttachment);
            }
        }
        catch(Exception e){
         //   ExceptionLog.logError(e);
        }
        
        
    }
    
    public static string getPdfImg(){
        String fileId = '';
        List<Attachment> attchRecord =[SELECT  Id,  Name, Body, BodyLength, ContentType, CreatedDate, Description FROM Attachment where Name='Company Logo' WITH SECURITY_ENFORCED];
        if( attchRecord != null && attchRecord.size() > 0 ) {
            fileId = attchRecord[0].Id;
        }
        String body = '/servlet/servlet.FileDownload?file='+fileId;
        return body;
    }
    
    public class Wrapper{
        @AuraEnabled public String dateOfProcedure{get;set;}
        @AuraEnabled public String cptCode{get;set;}
        @AuraEnabled public String cptDescription{get;set;}
        @AuraEnabled public String diagnosisPointer{get;set;}
        @AuraEnabled public Decimal units{get;set;}
        @AuraEnabled public String m1{get;set;}
        @AuraEnabled public String m2{get;set;}
        @AuraEnabled public String m3{get;set;}
        @AuraEnabled public String m4{get;set;}
        @AuraEnabled public Decimal charges{get;set;}
        @AuraEnabled public Decimal amountPaid{get;set;}
        @AuraEnabled public Decimal amountDue{get;set;}
    }
    
    public class DiagnosisWrapper{
        @AuraEnabled public String diagnosisName{get;set;}
        @AuraEnabled public String icdCode{get;set;}
        @AuraEnabled public String diagnosisPointer{get;set;}
    }
    
}