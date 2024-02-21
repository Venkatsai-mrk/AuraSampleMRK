public class CHC_PrescriptionsCallout{
    public static List<CHC_Prescription> lstSubscriptionXMLs = new List<CHC_Prescription>();
    public static string prescriptionJSON ;
    public static string subscriptionXML;
    public static string personId;
    
    public class CHC_Prescription {
        public String DrugName {get; set;}
        public String sig {get; set;}
        public String prescriber {get; set;}
        public String rxStatus {get; set;}
        public String Quantity {get; set;}
        public String RxType {get; set;}
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
               
            }
        }
        return XMLAttributevalue;
    }
    
    public static Map<String,String> getCredentials(){
       String strJson = CHCCredentials__mdt.getInstance('newCHCData').value__c;
        Map<String,String> credMap = (Map<String,String>)JSON.deserialize(strJson, Map<String,String>.class);
        return credMap;
    }
     public static List<CHCCredentials__mdt> getXmlList(String label){
       
           List<CHCCredentials__mdt> chcXml = [Select ElixirSuite__XMLCHC_Payload__c from ElixirSuite__CHCCredentials__mdt where Label =: label];
      return chcXml;
    }
    
    //Fetch person Id 
    public static string getPersonId(string accountId){
        
        
        Map<String,String> credMap =getCredentials();
        List<CHCCredentials__mdt> chcXml= getXmlList('PersonId');
        //List<ePrescriptionXml__c> chcXml =[SELECT Id , XMLCHC__c from ePrescriptionXml__c where Name='PersonId'];
        //List<CHCCredentials__mdt> chcXml = [Select ElixirSuite__XMLCHC_Payload__c from ElixirSuite__CHCCredentials__mdt where Label = 'PersonId'];
        
        DOM.Document doc1=new DOM.Document();
        doc1.load(chcXml[0].XMLCHC_Payload__c);
        
        doc1.getRootElement().setAttribute('userid',credMap.get('userid'));
        doc1.getRootElement().setAttribute('password',credMap.get('password'));
        
        Dom.XMLNode obj = doc1.getRootElement().getChildElement('OBJECT', null);
        obj.setAttribute('name','person');
        obj.setAttribute('op','search_hsi');
        
        Dom.XMLNode hsi = doc1.getRootElement().getChildElement('OBJECT', null);
        hsi.getChildElement('hsi_value', null).addTextNode(accountId);
        hsi.getChildElement('organization', null).addTextNode(credMap.get('organization'));
        //system.debug(doc1.toXmlString());
        String getpersonbody = doc1.toXmlString().replace( '<?xml version="1.0" encoding="UTF-8"?>', 'request=<?xml version=\'1.0\'?>' );
         system.debug(getpersonbody);
        
    HttpResponse getTestResponse = makeHTTPXMLPost(getpersonbody);
         System.debug('Person'+getTestResponse.getBody());
      // if( getTestResponse.getStatusCode() == 200) { 
           System.debug(getTestResponse.getStatusCode());
            System.debug('Person'+getTestResponse.getBody());
             Dom.Document getDoc = new Dom.Document();
          getDoc.load(getTestResponse.getBody());
          system.debug(getDoc);
            string xml = getDoc.toXmlString().replace( '<?xml version="1.0" encoding="UTF-8"?>', '' );
            system.debug(xml);
            Dom.Document getDoc1 = new Dom.Document();
            getDoc1.load(xml);
           personId= retrieveFromXMLDom( getTestResponse,'person');
           System.debug('Person ID '+ personId);
           
            
        //} 
        return personId;
         
    }
    
    @AuraEnabled(Cacheable=true)
    public static String getPrescriptionList(string accId , string rxStatus1){
        //deleteAllRelatedRecords(accId);
        //List<Prescription_Order__c> allRecords = [Select id from Prescription_Order__c where Account__c =: accId];
        
        //database.delete(allRecords, false);
        string personId=getPersonId(accId);
        //string drugNames='';
        
        
        if(rxStatus1 == 'AUTHORIZED' || rxStatus1 == 'VOID' ||rxStatus1 == 'DISCONTINUED' ||rxStatus1 ==''){
            
        Map<String,String> credMap =getCredentials();
        List<CHCCredentials__mdt> chcXml= getXmlList('filterMedication');
        //List<ePrescriptionXml__c> chcXml =[SELECT Id , XMLCHC__c from ePrescriptionXml__c where Name='MedicationHistory'];
        //List<CHCCredentials__mdt> chcXml = [Select ElixirSuite__XMLCHC_Payload__c from ElixirSuite__CHCCredentials__mdt where Label = 'filterMedication'];
        
        DOM.Document doc2=new DOM.Document();
        doc2.load(chcXml[0].XMLCHC_Payload__c);
        
        doc2.getRootElement().setAttribute('userid',credMap.get('userid'));
        doc2.getRootElement().setAttribute('password',credMap.get('password'));
        
        Dom.XMLNode obj = doc2.getRootElement().getChildElement('OBJECT', null);
        obj.setAttribute('name','rx');
        obj.setAttribute('op','search_patient_history_api');
        
        Dom.XMLNode hsi = doc2.getRootElement().getChildElement('OBJECT', null);
        hsi.getChildElement('person', null).addTextNode(personId);
        hsi.getChildElement('organization', null).addTextNode(credMap.get('organization'));
        hsi.getChildElement('rx_status', null).addTextNode(rxStatus1);
        //CHCCredentials__mdt credentials = getCredentials();
        string prescriptionbody=doc2.toXmlString().replace( '<?xml version="1.0" encoding="UTF-8"?>', 'request=<?xml version=\'1.0\'?>' );
            
        HttpResponse getPrescriptionResponse = makeHTTPXMLPost(prescriptionbody);
        system.debug(getPrescriptionResponse);
      
        if( getPrescriptionResponse.getStatusCode() != 201) { 
            System.debug(getPrescriptionResponse.getBody());
            //retriveListOfPrescription(getPrescriptionResponse);
            DOM.Document doc=new DOM.Document();
            doc.load(getPrescriptionResponse.getBody());
            subscriptionXML = doc.toXmlString().replace( '<?xml version="1.0" encoding="UTF-8"?>', '' );
            system.debug(subscriptionXML);
        }
        
        //List<ePrescriptionXml__c> lstChc = new  List<ePrescriptionXml__c>();
        DOM.Document doc1=new DOM.Document();
        system.debug(subscriptionXML);
        doc1.load(subscriptionXML);
        for (Dom.XMLNode objChild: doc1.getRootElement().getChildElements()){
            CHC_Prescription objCHC = new CHC_Prescription();
            objCHC.DrugName = objChild.getChildElement('drug_name', null).getText();
            objCHC.sig = objChild.getChildElement('sig', null).getText();
            objCHC.prescriber = objChild.getChildElement('prescriber_name', null).getText();
            objCHC.rxStatus = objChild.getChildElement('rx_status', null).getText();
            objCHC.Quantity = objChild.getChildElement('quantity', null).getText();
            objCHC.RxType = objChild.getChildElement('rx_type', null).getText();
            system.debug('added a drug now');
            lstSubscriptionXMLs.add(objCHC);
            system.debug(lstSubscriptionXMLs);
            //system.debug('----------------------------');
           
                
    }
        system.debug(lstSubscriptionXMLs);
     
             prescriptionJSON =(String)JSON.serialize(lstSubscriptionXMLs); 
        system.debug(prescriptionJSON);
    
    }
    
   
    
    return prescriptionJSON;
    }
}