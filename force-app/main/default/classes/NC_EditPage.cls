/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class NC_EditPage {

    public string subscriptionXML;
    public string endpoint;
    public List<User> Userdata;
    public String recordId{get; set;}
     //public String pgId{get; set;}
    
    public String gender;
    public List<Account> accountdata ;
    //public static List<LX3_Prescription> lstSubscriptionXMLs = new List<LX3_Prescription>();
    public string getSubscriptionXML() {
        return subscriptionXML;
    }

    public string getEndPoint() {
        return endpoint;
    }

    public static List<Account> accDetails(Id recordId){
      List<Account> accountdata = [select id, Name,ElixirSuite__First_Name__c, ElixirSuite__Last_Name__c, Phone, ElixirSuite__Gender__c, ElixirSuite__DOB__c, BillingCountry, BillingCity, BillingStreet, BillingState, BillingPostalCode from Account Where Id = :recordId WITH SECURITY_ENFORCED limit 1 ];
        return accountdata;
    }
    public static String getOrganizationName() {
        String organizationName = '';

        try {
            Organization orgInfo = [SELECT Name FROM Organization LIMIT 1];
            organizationName = (orgInfo != null) ? orgInfo.Name : '';
        } catch (QueryException e) {
            // Handle the exception, such as logging an error
            // If an exception occurs, organizationName will remain null
        }

        return organizationName;
    }
    public  static List<ElixirSuite__ICD_Codes__c> diagnosisCode(Id rId){
       
         List<ElixirSuite__ICD_Codes__c>  diagnosisCode  = [select id ,Name, ElixirSuite__Version__c  from ElixirSuite__ICD_Codes__c Where ElixirSuite__Account__c =:rId  AND (Name != null AND ElixirSuite__Version__c != null) WITH SECURITY_ENFORCED limit 10];   
           
         return diagnosisCode;
    }         
    
    
    public void getRecordId(){
        recordId=ApexPages.currentPage().getParameters().get('recordId').escapeHtml4();
        string pg=ApexPages.currentPage().getParameters().get('page').escapeHtml4();
        getRecords(recordId ,pg);
    }
     public  static List<User> newUser(){
        // string accId ='0019D00000QRWrxQAH';
         List<User>  Userdata  = [select id, FirstName,LastName,Phone ,	ElixirSuite__Work_Phone__c,ElixirSuite__zip4__c, ElixirSuite__CustomText2__c, ElixirSuite__DEA_NUMBER__c,Fax ,City, State, PostalCode, Street, Country,ElixirSuite__License__c,ElixirSuite__User_Type__c,ElixirSuite__Role_Type__c,ElixirSuite__siteId__c from user  WHERE Id =:UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];   
            //user=Userdata[0].id;
         return Userdata;
    }
    
    public void getRecords(Id recordId ,string pg){
        
        accountdata =accDetails(recordId);
        
        Map<String,String> credMap= new Map<String,String>();        
        
        DOM.Document doc=new DOM.Document();
        
        List<User> Userdata =newUser();
        
        if(!Test.isRunningTest()){
            if(Userdata != null && Userdata.size() > 0){
                List<SObject> newCropValues = ElixirUtilityClass.getObjectRecord('Integration_Credentials__c',Userdata[0].ElixirSuite__Role_Type__c + '-rx');
                if(newCropValues != null && newCropValues.size() > 0){
                    SObject newCropValue = newCropValues[0]; 
                    credMap.put('name',(String)newCropvalue.get('UserName__c'));
                    credMap.put('partnername',(String)newCropvalue.get('Partner_Name__c'));   
                    credMap.put('password',(String)newCropvalue.get('Password__c'));
                    credMap.put('productname',(String)newCropvalue.get('Product_Name__c'));
                    credMap.put('productversion',(String)newCropvalue.get('Product_Version__c'));
                    credMap.put('accountId',(String)newCropvalue.get('Account_Id__c'));       
                    
                    endpoint= (String)newCropvalue.get('EndPointURL__c');
                    String XMLPayload = (String)newCropValue.get('XML_Payload__c');
                    
                    doc.load(XMLPayload);
                }     
            }
            
            
        }
        else{
            credMap.put('name','demo');
            credMap.put('partnername','Mirketa');
            credMap.put('password','demo');
            credMap.put('productname','Elixir');
            credMap.put('productversion','V3.2');
            credMap.put('accountId','005Dn0000ffRLIAg');
            endpoint ='https://example.com/api'; 
            
            string lst=('<NCScript ><Credentials><partnerName></partnerName><name></name><password></password><productName></productName><productVersion></productVersion></Credentials><UserRole><user></user><role></role></UserRole><Destination><requestedPage></requestedPage></Destination><Account><accountName>Your Customer Account Name</accountName><siteID></siteID><AccountAddress><address1>232323 Test</address1><address2>Suite 240</address2><city>Boston</city><state>MA</state><zip>10409</zip><zip4>1234</zip4><country>US</country></AccountAddress><accountPrimaryPhoneNumber>5555551212</accountPrimaryPhoneNumber><accountPrimaryFaxNumber>5555551313</accountPrimaryFaxNumber></Account><Location ID="DEMOLOC1"><locationName>Your Customer Location Name</locationName><LocationAddress><address1>232323 Test</address1><address2>Suite 240</address2><city>Boston</city><state>MA</state><zip>10409</zip><zip4>1234</zip4><country>US</country></LocationAddress><primaryPhoneNumber>5555551212</primaryPhoneNumber><primaryFaxNumber>5555551213</primaryFaxNumber><pharmacyContactNumber>5555551212</pharmacyContactNumber></Location><LicensedPrescriber ID="DEMOLP1"><LicensedPrescriberName><last>Smith</last><first>Doctor</first><middle>J</middle></LicensedPrescriberName><dea>AS1111111</dea><upin>12345678</upin><licenseState>TX</licenseState><licenseNumber>12345678</licenseNumber><npi/></LicensedPrescriber><Patient><PatientName><last></last><first></first><middle></middle></PatientName><medicalRecordNumber></medicalRecordNumber><memo></memo><PatientAddress><address1></address1><address2></address2><city></city><state></state><zip></zip><country></country></PatientAddress><PatientContact><homeTelephone></homeTelephone></PatientContact><PatientCharacteristics><dob></dob><gender></gender></PatientCharacteristics></Patient><OutsidePrescription></OutsidePrescription></NCScript >');
            doc.load(lst);
            
        }
        accountdata =accDetails(recordId);
        string pageName = 'rx-edit';
        
        String orgName = getOrganizationName();
        if(accountdata.size()>0){
            
            Date dt = accountdata[0].ElixirSuite__DOB__c;
                        
String dateStr = string.valueOf(dt);
 				dateStr=dateStr.replaceAll('-','');
            // String str = accountdata.ElixirSuite__DOB__c.year() + '' + accountdata.ElixirSuite__DOB__c.month() + '' + accountdata.ElixirSuite__DOB__c.day();
            
            string xGender =accountdata[0].ElixirSuite__Gender__c;
            if(xGender !='Male' && xGender !='Female'){
                gender ='U';
            }
            else{
                gender =xGender.substring(0,1);
            }
            //phone and fax
            String phoneNumber;
            If(String.isNotBlank(Userdata[0].Phone)) {
                phoneNumber = Userdata[0].Phone;
                phoneNumber = phoneNumber.replaceAll('[^0-9]', '');
            }
            
            String faxNumber;
            
            If(String.isNotBlank(Userdata[0].Fax)) {
                faxNumber = Userdata[0].Fax;
                faxNumber = faxNumber.replaceAll('[^0-9]', '');
            }
            
            //NcScript
            doc.getRootElement().setAttribute('xmlns','http://secure.newcropaccounts.com/interfaceV7');
            doc.getRootElement().setAttribute('xmlns:NCStandard','http://secure.newcropaccounts.com/interfaceV7:NCStandard');
            doc.getRootElement().setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
            
            //Setting the Creds
            Dom.XMLNode objCreds = doc.getRootElement().getChildElement('Credentials', null);
            objCreds.getChildElement('partnerName', null).addTextNode(credMap.get('partnername'));
            objCreds.getChildElement('name', null).addTextNode(credMap.get('name'));
            objCreds.getChildElement('password', null).addTextNode(credMap.get('password'));
            objCreds.getChildElement('productVersion', null).addTextNode(credMap.get('productversion'));
            objCreds.getChildElement('productName', null).addTextNode(credMap.get('productname'));
            
            //User Role
            doc.getRootElement().getChildElement('UserRole', null).getChildElement('user', null).addTextNode(Userdata[0].ElixirSuite__User_Type__c);
            doc.getRootElement().getChildElement('UserRole', null).getChildElement('role', null).addTextNode(Userdata[0].ElixirSuite__Role_Type__c);
            
            //Destination
            doc.getRootElement().getChildElement('Destination', null).getChildElement('requestedPage', null).addTextNode(pageName);
            
            //Setting the AccountID / SiteID
            //Udhay: replace the Demo1 with SF ID (18 digit - Account object)
            Dom.XMLNode objacc= doc.getRootElement().getChildElement('Account', null);
            objacc.setAttribute('ID',credMap.get('accountId'));
            objacc.getChildElement('accountName', null).addTextNode(orgName);
            objacc.getChildElement('siteID', null).addTextNode(Userdata[0].ElixirSuite__siteId__c);
            
            objacc.getChildElement('AccountAddress', null).getChildElement('address1', null).addTextNode(Userdata[0].Street);
            objacc.getChildElement('AccountAddress', null).getChildElement('city', null).addTextNode(Userdata[0].City);
            objacc.getChildElement('AccountAddress', null).getChildElement('state', null).addTextNode(Userdata[0].State);
            objacc.getChildElement('AccountAddress', null).getChildElement('zip', null).addTextNode(Userdata[0].PostalCode);
            objacc.getChildElement('AccountAddress', null).getChildElement('country', null).addTextNode(Userdata[0].Country);
            If(String.isNotBlank(Userdata[0].ElixirSuite__zip4__c)){
                objacc.getChildElement('AccountAddress', null).getChildElement('zip4', null).addTextNode(Userdata[0].ElixirSuite__zip4__c);
            }
            objacc.getChildElement('accountPrimaryPhoneNumber', null).addTextNode(phoneNumber);
            objacc.getChildElement('accountPrimaryFaxNumber', null).addTextNode(faxNumber);
            
            
            //Location
            Dom.XMLNode objloc = doc.getRootElement().getChildElement('Location', null);
            objloc.setAttribute('ID',Userdata[0].id);
            objloc.getChildElement('locationName', null).addTextNode(Userdata[0].FirstName +' '+ Userdata[0].LastName);
            objloc.getChildElement('LocationAddress', null).getChildElement('address1', null).addTextNode(Userdata[0].Street);
            objloc.getChildElement('LocationAddress', null).getChildElement('city', null).addTextNode(Userdata[0].City);
            objloc.getChildElement('LocationAddress', null).getChildElement('state', null).addTextNode(Userdata[0].State);
            objloc.getChildElement('LocationAddress', null).getChildElement('zip', null).addTextNode(Userdata[0].PostalCode);
            objloc.getChildElement('LocationAddress', null).getChildElement('country', null).addTextNode(Userdata[0].Country);
            If(String.isNotBlank(Userdata[0].ElixirSuite__zip4__c)){
                objloc.getChildElement('LocationAddress', null).getChildElement('zip4', null).addTextNode(Userdata[0].ElixirSuite__zip4__c);
            }
            objloc.getChildElement('primaryPhoneNumber', null).addTextNode(phoneNumber);
            objloc.getChildElement('primaryFaxNumber', null).addTextNode(faxNumber);
            if(Userdata[0].ElixirSuite__Work_Phone__c != null){
                String contactNumber = Userdata[0].ElixirSuite__Work_Phone__c;
                contactNumber = contactNumber.replaceAll('[^0-9]', '');
                objloc.getChildElement('pharmacyContactNumber', null).addTextNode(contactNumber);
            }
            
            //Setting the LicensedPrescriber
            Dom.XMLNode objlice = doc.getRootElement().getChildElement('LicensedPrescriber', null);
            objlice.setAttribute('ID',Userdata[0].id);
            objlice.getChildElement('LicensedPrescriberName', null).getChildElement('last', null).addTextNode(Userdata[0].LastName);
            objlice.getChildElement('LicensedPrescriberName', null).getChildElement('first', null).addTextNode(Userdata[0].FirstName);
            if(Userdata[0].State != null){
                objlice.getChildElement('licenseState', null).addTextNode(Userdata[0].State);
                }
            objlice.getChildElement('licenseNumber', null).addTextNode(Userdata[0].ElixirSuite__License__c);
            if(Userdata[0].ElixirSuite__DEA_NUMBER__c !=null){
                objlice.getChildElement('dea', null).addTextNode(Userdata[0].ElixirSuite__DEA_NUMBER__c);
            }
            if(Userdata[0].ElixirSuite__CustomText2__c !=null){
                objlice.getChildElement('npi', null).addTextNode(Userdata[0].ElixirSuite__CustomText2__c);
            }
            
            //Setting the PatientID e.g. DEMOPT1
            Dom.XMLNode objPatient = doc.getRootElement().getChildElement('Patient', null);
            objPatient.setAttribute('ID',accountdata[0].id);
            objPatient.getChildElement('PatientName', null).getChildElement('last', null).addTextNode(accountdata[0].ElixirSuite__Last_Name__c);
            objPatient.getChildElement('PatientName', null).getChildElement('first', null).addTextNode(accountdata[0].ElixirSuite__First_Name__c);
            
            objPatient.getChildElement('PatientAddress', null).getChildElement('address1', null).addTextNode(accountdata[0].BillingStreet);
            objPatient.getChildElement('PatientAddress', null).getChildElement('city', null).addTextNode(accountdata[0].BillingCity);
            objPatient.getChildElement('PatientAddress', null).getChildElement('state', null).addTextNode(accountdata[0].BillingState);
            objPatient.getChildElement('PatientAddress', null).getChildElement('zip', null).addTextNode(accountdata[0].BillingPostalCode);
            objPatient.getChildElement('PatientAddress', null).getChildElement('country', null).addTextNode(accountdata[0].BillingCountry);
            
            //Setting Patient Contact and DOB
            objPatient.getChildElement('PatientContact', null).getChildElement('homeTelephone', null).addTextNode(accountdata[0].Phone);
            objPatient.getChildElement('PatientCharacteristics', null).getChildElement('dob', null).addTextNode(dateStr);
            objPatient.getChildElement('PatientCharacteristics', null).getChildElement('gender', null).addTextNode(gender);
            
            List<ElixirSuite__ICD_Codes__c> allPateintDiagnosis = diagnosisCode(recordId);
            
            if(allPateintDiagnosis.size() > 0){
                for(Integer i=0; i<allPateintDiagnosis.size(); i++){
                    
                    string pdiag= allPateintDiagnosis[i].ElixirSuite__Version__c.deleteWhitespace();
                    //diagnosis
                    dom.XmlNode crd =objPatient.addChildElement('PatientDiagnosis', null, null);
                    dom.XmlNode d1 =crd.addChildElement('diagnosisID', null,null).addTextNode(allPateintDiagnosis[i].Name);
                    dom.XmlNode d2= crd.addChildElement('diagnosisType', null,null).addTextNode(pdiag);
                    
                    
                }
                
            }
            
            doc.getRootElement().getChildElement('OutsidePrescription', null).setAttribute('ID',pg);
            
            subscriptionXML = doc.toXmlString().replace( '<?xml version="1.0" encoding="UTF-8"?>', '' );
            
        }
        
    }
}