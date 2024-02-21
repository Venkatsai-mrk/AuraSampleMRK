public class gethl7Message implements Queueable,Database.AllowsCallouts{
    /*NOT USED anymore*/
    public static CHCCredentials__mdt getCredentials(){
        
        CHCCredentials__mdt getcrd  = [SELECT Id, Password__c, Label, UserName__c FROM CHCCredentials__mdt where label = 'MirketaChcCrdentials'];
        System.debug(getcrd);
        return getcrd;
    }
    
    public static HttpResponse makeHTTPXMLPost(String XMLPost) {
        Http getTestHttp = new Http();
        HttpRequest getTestHttpRequest = new HttpRequest();
        getTestHttpRequest.setEndpoint('https://cli-cert.changehealthcare.com/servlet/XMLServlet');
        getTestHttpRequest.setMethod('POST');
        getTestHttpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        getTestHttpRequest.setBody(XMLPost);
        HttpResponse getTestResponse = getTestHttp.send(getTestHttpRequest);
        return getTestResponse;
    }
    public static String retrieveFromXMLDom(HttpResponse Response, String XMLAttribute) {
        String XMLAttributevalue ='';
        Dom.Document getDoc = new Dom.Document();
        getDoc.load(Response.getBody());
        Dom.XmlNode getRoot =getDoc.getRootElement();
        
        if(getRoot.getName()=='RESULT') {
            for(Dom.XmlNode getNode: getRoot.getChildElements()) {
                XMLAttributevalue = getNode.getChildElement(XMLAttribute, null).getText();
                return XMLAttributevalue;
            }
        }
        return XMLAttributevalue;
    }
    
    public void execute(QueueableContext context) {
        
        CHCCredentials__mdt credentials = getCredentials();
        List<Clinician_Report__c > clinicalreport   = [SELECT Id, Clinical_Report_ID__c,PlacerOrder__c FROM Clinician_Report__c where isDownloaded__c=false AND PlacerOrder__c!='1RADLFKNEE3'];
        List<String> placerList = new List<String>();
        List<String> LabOrderId = new List<String>();
        List<Hl7__c> HL7Result = new List<Hl7__c>();
        Map<String,String> hl7ClinicalIdMap = new Map<String,String>();
        Map<String,String> hl7placerIdMap = new Map<String,String>();
        String HL7Msg='';
        for(Integer i=0;i<clinicalReport.size();i++){
            string getHL7Body ='request=<?xml version=\'1.0\'?>'+
                '<REQUEST userid="'+credentials.UserName__c+'" password="'+credentials.Password__c+'">'+
                '<OBJECT name="reportdoc" op="search">'+ 
                '<clinicalreport>'+clinicalReport[i].Clinical_Report_ID__c+'</clinicalreport>'+
                '<emr_ready_only>y</emr_ready_only>'+ 
                '</OBJECT></REQUEST>';
            
            HttpResponse addHL7Response = makeHTTPXMLPost(getHL7Body);
            
            if(addHL7Response.getStatusCode() != 201) { 
                
                HL7Msg= retrieveFromXMLDom(addHL7Response,'body_text');              
            
            if(HL7Msg!='' ){
                hl7ClinicalIdMap.put(clinicalReport[i].Clinical_Report_ID__c, HL7Msg);
                hl7PlacerIdMap.put(clinicalReport[i].PlacerOrder__c, HL7Msg);
            }
            }
            
        }
        System.debug('Placer Map '+hl7PlacerIdMap);
        for (String placerIterate : hl7PlacerIdMap.keySet()){
            placerList.add(placerIterate);
            
        }
        System.debug('placerList'+placerList.size());
        System.debug('PlacerOrder'+placerList);
        List<Lab_Order__c> labvalue = [select Id,Lab_Order_Req__c from Lab_Order__c where Lab_Order_Req__c IN :placerList  ];
        For(Integer i=0;i<labvalue.size();i++)
        {   
            LabOrderId.add(labvalue[i].Id);
            
        }
        System.debug('LabOrderId '+LabOrderId);
        For(Integer i=0;i<labvalue.size();i++)
            
        {  
            For(String placerIterate : hl7PlacerIdMap.keySet()){
                if(placerIterate.equals(labvalue[i].Lab_Order_Req__c)){
                    
                    HL7__c HL7data = new HL7__c(Order_ID__c=LabOrderId[i],Full_HL7_Dump_Message__c= hl7PlacerIdMap.get(placerIterate),Placer_Order__c = LabOrderId[i]);
                    HL7Result.add(HL7data);
                    
                }
            }
        }
        
        if( HL7Result.size()>0 && HL7Result!=null ){
            try{
                Database.upsert(HL7Result,HL7__c.Placer_Order__c);
            }
            catch (DmlException e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        if(clinicalreport.size()>0){
            For(Integer i=0;i<clinicalreport.size();i++){
                for (String placerIterate : hl7PlacerIdMap.keySet()){
                    if( clinicalreport[i].PlacerOrder__c.equals(placerIterate)){
                        
                        clinicalreport[i].isDownloaded__c=true;
                    }
                    else{
                        
                        clinicalreport[i].isDownloaded__c=false;
                    }
                }   
            }
        
            try{
                Database.update(clinicalreport);
            }
            catch (DmlException e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
           // System.enqueueJob(new updateStatusClinical());
            
        
    }
}