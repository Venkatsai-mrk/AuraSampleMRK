public class CreatePatientInChcController {
    
    
    
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
    
     public static CHCCredentials__mdt getCredentials(){
        
            CHCCredentials__mdt getcrd  = [SELECT Id, Password__c, Label, UserName__c FROM CHCCredentials__mdt where Label='MirketaChcCrdentials'];
            System.debug(getcrd);
            return getcrd;
    }
    
    
    public static string getHsiLabel(){
        
        
            CHCCredentials__mdt credentials = getCredentials();
            string hsiLabel='';
        
        string requestBody='request=<?xml version=\'1.0\'?>'+
                '<REQUEST userid="'+credentials.UserName__c+'" password="'+credentials.Password__c+'">'+
                '<OBJECT name="hsilabel" op="search">'+
                '<organization>3004423326</organization>'+
                '<is_hsi_for>Patient</is_hsi_for>'+
                '<registration>y</registration>'+
                '<label_name>PAN</label_name>'+
                '</OBJECT>'+
                '</REQUEST>';
            
            HttpResponse gethsiResponse = makeHTTPXMLPost(requestBody);
            
            if( gethsiResponse.getStatusCode() != 201) { 
                System.debug(gethsiResponse.getBody());
                hsiLabel= retrieveFromXMLDom(gethsiResponse,'hsilabel');
                System.debug('hsiLabel '+hsiLabel);
                              
            }
        
        return hsiLabel;
        
    }
     @InvocableMethod
    public static void createPatientInChc(List<Id> accId){
        
        string hsiLabel=getHsiLabel();
         string personId='';
        CHCCredentials__mdt credentials = getCredentials();
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String patAccRecType = val.ElixirSuite__Patient_Account_Recordtype__c; 
        Account acc=[Select Id,DOB__c,First_Name__c,Last_Name__c,SSN__c,Gender__c,Phone,BillingStreet, BillingCity, BillingState, BillingPostalCode From Account where Id=:accId[0] And RecordType.DeveloperName=:patAccRecType];
        
        if(acc.Id!=null){
            string Phone=acc.Phone;
            String areacode = phone.subString(0,3);
            String phonenum = phone.substring(3,10);
        string DOBStr = string.valueOfGmt(acc.DOB__c);
            // Date_Of_Birth__c
            String yearsplit= DOBStr.substring(0,4);
            String monthsplit = DOBStr.substring(5,7);
            String daysplit  = DOBStr.substring(8,10);
            String gDOBactual = monthsplit+'/'+daysplit+'/'+yearsplit;
            System.debug('dobactual'+gDOBactual);
        
        string addPatienthttpBody = 'request=<?xml version=\'1.0\'?>'+
                '<REQUEST userid="'+credentials.UserName__c+'" password="'+credentials.Password__c+'">'+
                '<OBJECT name="person" op="put_partial">'+
                '<birth_date>'+gDOBactual+'</birth_date>'+
                '<first_name>'+acc.First_Name__c+'</first_name>'+
                '<last_name>'+acc.Last_Name__c+'</last_name>'+
                //'<middle_name>E</middle_name>'+
                '<suffix></suffix>'+
                '<ssn>'+acc.SSN__c+'</ssn>'+
                '<address_1>'+acc.BillingStreet+'</address_1>'+
                '<address_2></address_2>'+
                '<city>'+acc.BillingCity+'</city>'+
                '<state>'+acc.BillingState+'</state>'+
                '<sex>'+acc.Gender__c+'</sex>'+
                '<zip>'+acc.BillingPostalCode+'</zip>'+
                '<hsi_value>'+accId[0]+'</hsi_value>'+
                '<hsilabel>'+hsiLabel+'</hsilabel>'+
                '<home_phone_area_code>'+areacode+'</home_phone_area_code>'+
                '<home_phone_number>'+phonenum+'</home_phone_number>'+
                '</OBJECT></REQUEST>';
        
                HttpResponse addPatientResponse = makeHTTPXMLPost(addPatienthttpBody);
            
            if(addPatientResponse.getStatusCode() != 201) { 
                System.debug(addPatientResponse.getBody());
                personId= retrieveFromXMLDom(addPatientResponse,'person'); 
            }
            
        }
            
        
        
        
    }

}