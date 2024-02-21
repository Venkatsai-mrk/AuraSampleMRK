public class getPlacerOrderId implements Queueable,Database.AllowsCallouts {
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
        List<Clinician_Report__c > clinicalreport   = [SELECT Id, Clinical_Report_ID__c FROM Clinician_Report__c where isDownloaded__c=false OR PlacerOrder__c=''];
        CHCCredentials__mdt credentials = getCredentials();
        //List<String> placerOrderList = new List<String>();
        List<Clinician_Report__c> placerInsertionList  = new List<Clinician_Report__c>();
        String placerOrder='';
        
        for(Integer i=0;i<clinicalreport.size();i++){
            string getPlacerOrderBody ='request=<?xml version=\'1.0\'?>'+
                '<REQUEST userid="'+credentials.UserName__c+'" password="'+credentials.Password__c+'">'+
                '<OBJECT name="clinicalreport" op="get">'+ 
                '<clinicalreport>'+clinicalreport[i].Clinical_Report_ID__c +'</clinicalreport>'+
                '</OBJECT></REQUEST>';
            
            
            HttpResponse getPlacerOrderResponse = makeHTTPXMLPost(getPlacerOrderBody);
            
            if(getPlacerOrderResponse.getStatusCode() != 201) { 
                //   System.debug(addHL7Response.getBody());
                placerOrder= retrieveFromXMLDom(getPlacerOrderResponse,'placer_order_number');
                //placerOrderList.add(placerOrder);
                Clinician_Report__c insertPlacerID = new Clinician_Report__c(Clinical_Report_ID__c =clinicalreport[i].Clinical_Report_ID__c ,PlacerOrder__c=placerOrder );
                placerInsertionList.add(insertPlacerID );
            }
            
        }
        
        System.debug(placerInsertionList);
        if(placerInsertionList.size()>0 && placerInsertionList!=null){
                try
                {
                    Database.upsert (placerInsertionList,Clinician_Report__c.Clinical_Report_ID__c);
                     System.enqueueJob(new gethl7Message());
                }
                catch (DmlException e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
           
        
        
        
        
    }
    
    
    
}