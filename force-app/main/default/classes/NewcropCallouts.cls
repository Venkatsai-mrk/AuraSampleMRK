/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class NewcropCallouts{
    
     public static string DecodedXMlResponse;
    public static string xml;
    public static  list<ElixirSuite__Prescription_Order__c> prelist;
     public static  list<ElixirSuite__Prescription_Order__c> prelist2;
    public static ElixirSuite__Prescription_Order__c pre;
    
  public static HttpResponse makeHTTPXMLPost(string XMLPost) {
      string endpoint =getURL();
        Http getTestHttp = new Http();
        HttpRequest getTestHttpRequest = new HttpRequest();
        getTestHttpRequest.setEndpoint(endpoint);
        getTestHttpRequest.setMethod('POST');
        getTestHttpRequest.setHeader('Content-Type', 'text/xml; charset=utf-8');
        getTestHttpRequest.setBody(XMLPost);
        HttpResponse getTestResponse = getTestHttp.send(getTestHttpRequest);
     
      system.debug(getTestResponse.getBody());
      return getTestResponse;
  }

    
public static string getURL(){
      if(!Test.isRunningTest()){    
         List<SObject> newCropValues = ElixirUtilityClass.getObjectRecord('Integration_Credentials__c', 'getPrescription_Callouts_endpoint'); 
         if(newCropValues != null && newCropValues.size() > 0){
             SObject newCropValue = newCropValues[0];
             return (String)newCropValue.get('EndPointURL__c');
         }
         else{
                return 'https://example.com/api';
         } 
      }
      else{
         return 'https://example.com/api'; 
      }
  }     
  
    
  
    public static void setValues(string Response){
         prelist=new list<ElixirSuite__Prescription_Order__c>();
        prelist2=new list<ElixirSuite__Prescription_Order__c>();
        List<ElixirSuite__Prescription_Order__c> patintGuid =[select id ,ElixirSuite__Prescription_Guid__c from ElixirSuite__Prescription_Order__c WITH SECURITY_ENFORCED];
       Set<String> ids = new Set<String>();
        for(Prescription_Order__c lst :patintGuid){
            ids.add(lst.ElixirSuite__Prescription_Guid__c);
            system.debug(ids);
        }
        DOM.Document doc=new DOM.Document();
       
            doc.load(Response);
           // DOM.XmlNode rootNode=doc.getRootElement();
            for (Dom.XMLNode objChild: doc.getRootElement().getChildElements()) {
               
                string abc=objChild.getChildElement('PrescriptionGuid', null).getText();
                string sobj =objChild.getChildElement('Status', null).getText(); 
                system.debug(abc);
                if(!ids.contains(abc)){
             pre = new Prescription_Order__c();
                    pre.ElixirSuite__Prescription_Guid__c = objChild.getChildElement('PrescriptionGuid', null).getText();
                        string AccountId = objChild.getChildElement('PatientID', null).getText(); 
                    
                        pre.ElixirSuite__Drug_Name__c=objChild.getChildElement('DrugName', null).getText(); 
                        pre.ElixirSuite__Reason_new__c  =objChild.getChildElement('DrugInfo', null).getText();  
                            pre.ElixirSuite__Patient_SIG__c=objChild.getChildElement('PatientFriendlySIG', null).getText(); 
                            pre.ElixirSuite__Refills__c=objChild.getChildElement('Refills', null).getText(); 
                            pre.ElixirSuite__Archive_Status_NC__c=objChild.getChildElement('Archive', null).getText(); 
                            pre.ElixirSuite__SubStatus_NC__c=objChild.getChildElement('SubStatus', null).getText();
                            pre.ElixirSuite__Pharmacy_NC__c=objChild.getChildElement('PharmacyFullInfo', null).getText();
                            pre.ElixirSuite__Dispense_NC__c=objChild.getChildElement('Dispense', null).getText();
                            pre.ElixirSuite__Route_New__c=objChild.getChildElement('Route', null).getText();
                            pre.ElixirSuite__Dosage_Form__c=objChild.getChildElement('DosageForm', null).getText();
                            pre.ElixirSuite__Ferquency__c=objChild.getChildElement('DosageFrequencyDescription', null).getText();
                            pre.ElixirSuite__Status_NC__c = sobj;
                    system.debug('added a drug now');
                    List<ElixirSuite__Visits__c> lst_visits;
                    if(!Test.isRunningTest()){
                        pre.Account__c= AccountId; 
                       
                        
                    }
                    lst_visits = [Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c
                                                           from ElixirSuite__Visits__c where ElixirSuite__Status__c='Active' AND ElixirSuite__Account__c =:AccountId
                                                           WITH SECURITY_ENFORCED
                                                           ORDER BY CreatedDate DESC
                                                           LIMIT 1];
 						if(lst_visits.size() > 0)   {                          
                    pre.ElixirSuite__Care_Episode__c = lst_visits[0].Id;
                            }                           
                    prelist.add(pre);
               // system.debug(prelist);
        }
                else{
                    List<ElixirSuite__Prescription_Order__c> preLst =[select id from ElixirSuite__Prescription_Order__c where ElixirSuite__Prescription_Guid__c =:abc WITH SECURITY_ENFORCED];
                    ElixirSuite__Prescription_Order__c obj = new ElixirSuite__Prescription_Order__c(Id = preLst[0].id);
                    obj.ElixirSuite__Status_NC__c = sobj;
                    prelist2.add(obj);
                    //pre.ElixirSuite__Status_NC__c=objChild.getChildElement('Status', null).getText();  
                }
        }
            system.debug('>>>> '+prelist);
          
            DMLManager.insertAsUser(prelist);
        DMLManager.updateAsUser(prelist2);
    }
   
    public  static List<User> newUser(){
        // string accId ='0019D00000QRWrxQAH';
         List<User> Userdata  = [select id, FirstName, LastName,ElixirSuite__siteId__c from user  WHERE Id =:UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];   
         //system.debug(accId);
         return Userdata;
    }
    
    
    
    @AuraEnabled
    public static List<ElixirSuite__Prescription_Order__c> newPrescription(string accId , string status){
       // string accId ='0019D00000QRWrxQAH';
        //List<User> Userdata  = [select id, FirstName, LastName,ElixirSuite__siteId__c from user  WHERE Id =:UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];
        
        /* added for requirement LX3-8253 and logic for this will be written in subscriber org */
        List<ElixirSuite__Prescription_Order__c> pList = new List<ElixirSuite__Prescription_Order__c>();
        String virtualClassName = '';
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        pluggableClass = [SELECT
                          DeveloperName,
                          Virtual_Class__c
                          FROM Elixir_Pluggable_Classes__mdt
                          WHERE DeveloperName='NewCropPrescriptionCallout'
                          WITH SECURITY_ENFORCED];
        
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            virtualClassName = pluggableClass[0].Virtual_Class__c;
        }
        if(String.isNotBlank(virtualClassName)){
            
            Callable calloutPrescription = (Callable) Type.forName(virtualClassName).newInstance();
            pList = (List<ElixirSuite__Prescription_Order__c>) calloutPrescription.call('RefreshCallout', new Map<String, Object> { 
                'accId' => accId,
                'status' => status
            });
        }
        else{
           pList = [Select id,Name, ElixirSuite__Route__c,ElixirSuite__Ferquency__c, 
                    ElixirSuite__Dosage_Form__c,ElixirSuite__Prescription_Guid__c,
                    ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,
                    ElixirSuite__Patient_SIG__c,ElixirSuite__Refills__c,
                    ElixirSuite__Archive_Status_NC__c, ElixirSuite__Status_NC__c,
                    ElixirSuite__SubStatus_NC__c,ElixirSuite__Pharmacy_NC__c,
                    ElixirSuite__Dispense_NC__c,ElixirSuite__Direction__c ,
                    ElixirSuite__IsEditButtonActive__c, ElixirSuite__Start_Date__c, 
                    ElixirSuite__Route_New__c, ElixirSuite__Signature_Status__c, ElixirSuite__Quantity__c
                    from ElixirSuite__Prescription_Order__c 
                    where ElixirSuite__Account__c =:accId 
                    And ElixirSuite__Prescription_Guid__c !=null 
                    WITH SECURITY_ENFORCED]; 
        }
        
        return pList;
        
        /* end  LX3-8253 */
        
        /* commenting for as per LX3-8253
        system.debug(accId);
        List<User> Userdata =newUser();
        
        
          Map<String,String> credMap= new Map<String,String>();
            
        if(!Test.isRunningTest()){     
        String strJson = ElixirSuite__NewCropCredentials__mdt.getInstance('newCropData').value__c;
         credMap = (Map<String,String>)JSON.deserialize(strJson, Map<String,String>.class);
       
        }
        else{
            credMap.put('name','demo');
            credMap.put('partnername','Mirketa');
            credMap.put('password','demo');
            credMap.put('productname','Elixir');
            credMap.put('productversion','V3.2');
            credMap.put('accountId','005Dn0000ffRLIAg');
        }
        
        date myDate = system.today();
        date newDate = myDate.addYears(-5);
        system.debug(newDate);
        date myDate1 = system.today();
        date newDate1 = myDate.addYears(5);
        system.debug(newDate1);

        
        string startdate =String.valueOf(newDate);
        string enddate =String.valueOf(newDate1);
        
               DOM.Document doc = new DOM.Document();
        dom.XmlNode products = doc.createRootElement('soap:Envelope ', null, null);
            products.setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
        products.setAttribute('xmlns:xsd','http://www.w3.org/2001/XMLSchema');
        products.setAttribute('xmlns:soap','http://schemas.xmlsoap.org/soap/envelope/');
        
       dom.XmlNode body1= products.addChildElement('soap:Body', null, null);
        
        dom.XmlNode grtmed =body1.addChildElement('GetPatientFullMedicationHistory6', null, null);
          grtmed.setAttribute('xmlns','https://secure.newcropaccounts.com/V7/webservices');
        
        dom.XmlNode crd =grtmed.addChildElement('credentials', null, null);
        dom.XmlNode pn =crd.addChildElement('PartnerName', null, null).addTextNode(credMap.get('partnername'));
        dom.XmlNode n =crd.addChildElement('Name', null, null).addTextNode(credMap.get('name'));
        dom.XmlNode p =crd.addChildElement('Password', null, null).addTextNode(credMap.get('password'));
        
        dom.XmlNode ah =grtmed.addChildElement('accountRequest', null, null);
        dom.XmlNode ad =ah.addChildElement('AccountId', null, null).addTextNode(credMap.get('accountId'));
        dom.XmlNode sd =ah.addChildElement('SiteId', null, null).addTextNode(Userdata[0].ElixirSuite__siteId__c);
        
        dom.XmlNode pr =grtmed.addChildElement('patientRequest', null, null);
        dom.XmlNode patd =pr.addChildElement('PatientId', null, null).addTextNode(accId);
        
         dom.XmlNode phr =grtmed.addChildElement('prescriptionHistoryRequest', null, null);
        dom.XmlNode sh =phr.addChildElement('StartHistory', null, null).addTextNode(startdate);
        dom.XmlNode eh=phr.addChildElement('EndHistory', null, null).addTextNode(enddate);
        dom.XmlNode ps =phr.addChildElement('PrescriptionStatus', null, null).addTextNode(status);
        dom.XmlNode pss =phr.addChildElement('PrescriptionSubStatus', null, null).addTextNode('%');
        dom.XmlNode pas =phr.addChildElement('PrescriptionArchiveStatus', null, null).addTextNode('%');
        
        dom.XmlNode sch =grtmed.addChildElement('includeSchema', null, null).addTextNode('N');
        
        system.debug(doc);
        string prescriptionbody=doc.toXmlString();
        system.debug(prescriptionbody);
               HttpResponse getPrescriptionResponse = makeHTTPXMLPost(prescriptionbody);
                 system.debug(getPrescriptionResponse);
                System.debug(getPrescriptionResponse.getBody());
                string filterResponse =retriveListOfPrescription(getPrescriptionResponse);
            setvalues(filterResponse);
        
        List<ElixirSuite__Prescription_Order__c> lst= [Select id,Name,  ElixirSuite__Prescription_Guid__c,ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__Patient_SIG__c,ElixirSuite__Refills__c,
           ElixirSuite__Archive_Status_NC__c, ElixirSuite__Status_NC__c,ElixirSuite__SubStatus_NC__c,ElixirSuite__Pharmacy_NC__c,ElixirSuite__Dispense_NC__c,
            ElixirSuite__Direction__c ,ElixirSuite__IsEditButtonActive__c   from ElixirSuite__Prescription_Order__c where ElixirSuite__Account__c =:accId And (ElixirSuite__Prescription_Guid__c !='' OR ElixirSuite__Prescription_Guid__c !=null) WITH SECURITY_ENFORCED];
        system.debug(lst);
        return lst;

        */
       
    }
         
   
public static String retriveListOfPrescription(HTTPResponse getTestResponse)
{
    DOM.Document doc = new DOM.Document();
String toParse = getTestResponse.getBody();
doc.load(toParse);

DOM.XMLNode root = doc.getRootElement();

String nms = root.getNameSpace();

System.Debug('namespace: ' + nms);

DOM.XMLNode body = root.getChildElement('Body', nms);

System.Debug('body: ' + body);

List<DOM.XMLNode> bodyChildrenList = body.getChildElements();

for (DOM.XMLNode GetPatientFullMedicationHistory6Response : bodyChildrenList) {
	//System.Debug('GetPatientFullMedicationHistory6Response: ' + GetPatientFullMedicationHistory6Response.getName());

	List<DOM.XMLNode> GetPatientFullMedicationHistory6ResultList = GetPatientFullMedicationHistory6Response.getChildElements();

	for (DOM.XMLNode GetPatientFullMedicationHistory6Result : GetPatientFullMedicationHistory6ResultList) {
		//System.Debug('passThroughReqResult: ' + GetPatientFullMedicationHistory6Result.getName());

		List<DOM.XMLNode> pickResponseList = GetPatientFullMedicationHistory6Result.getChildElements();

		for (DOM.XMLNode pickResponse : pickResponseList) {
			//System.Debug('pickResponse: ' + pickResponse.getName());
            if(pickResponse.getName()=='XmlResponse'){
                System.Debug('xmlResponse: ' + pickResponse.getText());
                xml =pickResponse.getText();
            }
			
	}
}
}
       DecodedXMlResponse=EncodingUtil.base64Decode(xml).tostring();
      system.debug(DecodedXMlResponse);
    return DecodedXMlResponse;
     // NewcropCallouts.insertRecord();
}
}