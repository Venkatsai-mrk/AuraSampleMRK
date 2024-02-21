global with sharing virtual class GlobalSavePdfReport {
    
    global virtual void afterInsert(List<Test_Result_Detail__c> testResultsLst){
        Set<Id> labOrderIds = new Set<Id>();
        List<Lab_Order__c> labOrders = new List<Lab_Order__c>();
        List<Attachment> pdfToDelete = new List<Attachment>();
        List<Attachment> pdflist = new List<Attachment>();
        Map<Id, Attachment> parentIdToAttachment = new Map<Id, Attachment>();
        
        Map<Id, Test_Result_Detail__c> mapObx = new Map<Id, Test_Result_Detail__c>([Select Id,HL7_Id__r.Order_ID__c, HL7_Id__r.Clinician_Report__c from Test_Result_Detail__c where Id In:testResultsLst WITH SECURITY_ENFORCED]);
        for(Test_Result_Detail__c result : mapObx.values()){
            labOrderIds.add(result.HL7_Id__r.Order_ID__c);
        }
        
        Map<Id, Lab_Order__c> mapOfLabOrder = new Map<Id, Lab_Order__c>([Select id, Name, Order_result_received__c from Lab_Order__c where id IN:labOrderIds WITH SECURITY_ENFORCED]);
        
        List<Attachment> oldpfdflist = [Select Id, ParentId from Attachment where ParentId IN:labOrderIds AND Name='pdfReport.pdf' WITH SECURITY_ENFORCED];
        if(Oldpfdflist!=null && Oldpfdflist.size()>0){
            for(Attachment a : Oldpfdflist){
                parentIdToAttachment.put(a.ParentId, a);
            }
        }
        List<String> duplicateId = new List<String>();
        for(Test_Result_Detail__c t : testResultsLst){
            if(t.Observation_Identifier_Analyte_Code__c == 'PDFReport1' || t.Observation_Identifier_Analyte_Code__c == 'ClinicalPDFReport1'){
                Id orderId = mapObx.get(t.Id).HL7_Id__r.Order_ID__c;
                Id clinicalId = mapObx.get(t.Id).HL7_Id__r.Clinician_Report__c;
                Attachment a = new Attachment();
                a.contentType = 'application/pdf';
                a.name = 'pdfReport.pdf';
                if(OrderId != null){
                    a.parentId = OrderId;//It will take clinical if no laborder
                }
                else if(clinicalId != null){
                    a.parentId = clinicalId;
                }
                a.body = EncodingUtil.base64Decode(t.Observation_Value_Image__c);
                
                Pdflist.add(a);
                // if(OrderId != null){
                    if(parentIdToAttachment!=null && parentIdToAttachment.size()>0){
                        Attachment attch = parentIdToAttachment.get(OrderId);
                        pdfToDelete.add(attch);
                    }
                    Lab_Order__c ordr =  mapOfLabOrder.get(OrderId);
                    ordr.Order_result_received__c = system.now();
                    
                    if (!duplicateId.contains(ordr.Id)) {
                    labOrders.add(ordr);   
                    duplicateId.add(ordr.Id);  
                    }
                // }
            }
            
            else if((t.Observation_Value_type__c == 'ED' && t.Observation_Value_Image_Data_type__c == 'Image' )&&(t.Observation_Value_Image_Data_subtype__c == 'JPEG'||t.Observation_Value_Image_Data_subtype__c == 'JPG'||t.Observation_Value_Image_Data_subtype__c == 'PNG') ){
                
                Attachment a = new Attachment();
                a.contentType = 'image/'+ t.Observation_Value_Image_Data_subtype__c;
                a.name = t.Test_Result_Detail_Name__c+'.'+t.Observation_Value_Image_Data_subtype__c;
                a.parentId = t.Id;
                a.body = EncodingUtil.base64Decode(t.Observation_Value_Image__c);
                
                Pdflist.add(a);
                
                // if(t.Id != null){
                    if(parentIdToAttachment!=null && parentIdToAttachment.size()>0){
                        Attachment attch = parentIdToAttachment.get(t.Id);
                        pdfToDelete.add(attch);
                    }
                    Lab_Order__c ordr =  mapOfLabOrder.get(t.Id);
                    ordr.Order_result_received__c = system.now();
                    if (!duplicateId.contains(ordr.Id)) {
                    labOrders.add(ordr); 
                    duplicateId.add(ordr.Id);  
                     }
                    
                // }
            }
        }
        DMLManager.deleteAsUser(pdfToDelete);
        DMLManager.insertAsUser(Pdflist);
        DMLManager.updateAsUser(labOrders);
    }
}