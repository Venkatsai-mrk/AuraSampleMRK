public with sharing class NC_RxAdminController {
    public string subscriptionXML;
    public string endpoint;
    public List<User> Userdata;
      

      
    
      public string getSubscriptionXML() {
          return subscriptionXML;
      }
      public string getEndPoint() {
        return endpoint;
    }
      
      public void getRecordId(){
         getRecords();
      }
       public  static List<User> newUser(){
          // string accId ='0019D00000QRWrxQAH';
           List<User>  Userdata  = [select id, FirstName,LastName,Phone ,ElixirSuite__CustomText2__c,ElixirSuite__CustomText1__c,	ElixirSuite__Work_Phone__c, ElixirSuite__DEA_NUMBER__c,Fax ,City, State, PostalCode, Street, Country,ElixirSuite__License__c,ElixirSuite__User_Type__c,ElixirSuite__Role_Type__c,ElixirSuite__siteId__c from user  WHERE Id =:UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];   
              //user=Userdata[0].id;
           return Userdata;
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
      public void getRecords(){
         
            Map<String,String> credMap= new Map<String,String>();
          
          
           DOM.Document doc=new DOM.Document();
        String orgName = getOrganizationName();
           List<User> Userdata =newUser();
            
           if(!Test.isRunningTest()){     

          List<SObject> newCropValues = ElixirUtilityClass.getObjectRecord('Integration_Credentials__c', 'RxAdmin');
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
          else{
              credMap.put('name','demo');
              credMap.put('partnername','Mirketa');
              credMap.put('password','demo');
              credMap.put('productname','Elixir');
              credMap.put('productversion','V3.2');
              credMap.put('accountId','005Dn0000ffRLIAg');
              endpoint ='https://example.com/api';
              
             string lst=('<NCScript ><Credentials><partnerName></partnerName><name></name><password></password><productName></productName><productVersion></productVersion></Credentials><UserRole><user></user><role></role></UserRole><Destination><requestedPage></requestedPage></Destination><Account><accountName>Your Customer Account Name</accountName><siteID></siteID><AccountAddress><address1>232323 Test</address1><address2>Suite 240</address2><city>Boston</city><state>MA</state><zip>10409</zip><zip4>1234</zip4><country>US</country></AccountAddress><accountPrimaryPhoneNumber>5555551212</accountPrimaryPhoneNumber><accountPrimaryFaxNumber>5555551313</accountPrimaryFaxNumber></Account><Location ID="DEMOLOC1"><locationName>Your Customer Location Name</locationName><LocationAddress><address1>232323 Test</address1><address2>Suite 240</address2><city>Boston</city><state>MA</state><zip>10409</zip><zip4>1234</zip4><country>US</country></LocationAddress><primaryPhoneNumber>5555551212</primaryPhoneNumber><primaryFaxNumber>5555551213</primaryFaxNumber><pharmacyContactNumber>5555551212</pharmacyContactNumber></Location><Staff><StaffName><last></last><first></first></StaffName></Staff></NCScript >');
           doc.load(lst);
            
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
          doc.getRootElement().getChildElement('Destination', null).getChildElement('requestedPage', null).addTextNode('admin');
          
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
          objacc.getChildElement('accountPrimaryPhoneNumber', null).addTextNode(Userdata[0].Phone);
          objacc.getChildElement('accountPrimaryFaxNumber', null).addTextNode(Userdata[0].Fax);
          
             //Location
              Dom.XMLNode objloc = doc.getRootElement().getChildElement('Location', null);
              objloc.setAttribute('ID',Userdata[0].id);
              objloc.getChildElement('locationName', null).addTextNode(Userdata[0].FirstName +' '+ Userdata[0].LastName);
                objloc.getChildElement('LocationAddress', null).getChildElement('address1', null).addTextNode(Userdata[0].Street);
                 objloc.getChildElement('LocationAddress', null).getChildElement('city', null).addTextNode(Userdata[0].City);
                 objloc.getChildElement('LocationAddress', null).getChildElement('state', null).addTextNode(Userdata[0].State);
                 objloc.getChildElement('LocationAddress', null).getChildElement('zip', null).addTextNode(Userdata[0].PostalCode);
                 objloc.getChildElement('LocationAddress', null).getChildElement('country', null).addTextNode(Userdata[0].Country);
              objloc.getChildElement('primaryPhoneNumber', null).addTextNode(Userdata[0].Phone);
              objloc.getChildElement('primaryFaxNumber', null).addTextNode(Userdata[0].Fax);
              if(Userdata[0].ElixirSuite__Work_Phone__c != null){
                  objloc.getChildElement('pharmacyContactNumber', null).addTextNode(Userdata[0].ElixirSuite__Work_Phone__c);
                 }
                           
         


                 if(Userdata[0].ElixirSuite__Role_Type__c == 'doctor'){
          Dom.XMLNode objlice = doc.getRootElement().addChildElement('LicensedPrescriber', null,null);
          objlice.setAttribute('ID',Userdata[0].id);
          dom.XmlNode licenseName =objlice.addChildElement('LicensedPrescriberName', null,null);
          licenseName.addChildElement('last', null,null).addTextNode(Userdata[0].LastName);
          licenseName.addChildElement('first', null,null).addTextNode(Userdata[0].FirstName);
       if(Userdata[0].State != null){
                objlice.addChildElement('licenseState', null,null).addTextNode(Userdata[0].State);
                }
          objlice.addChildElement('licenseNumber',null, null).addTextNode(Userdata[0].ElixirSuite__License__c);
          if(Userdata[0].ElixirSuite__DEA_NUMBER__c !=null){
            objlice.addChildElement('dea', null,null).addTextNode(Userdata[0].ElixirSuite__DEA_NUMBER__c);
             }
             if(Userdata[0].ElixirSuite__CustomText2__c !=null){
              objlice.addChildElement('npi', null,null).addTextNode(Userdata[0].ElixirSuite__CustomText2__c);
               }
                 }
                 else if(Userdata[0].ElixirSuite__Role_Type__c == 'admin' || Userdata[0].ElixirSuite__Role_Type__c == 'nurse'){

                  Dom.XMLNode staffObj = doc.getRootElement().addChildElement('Staff', null,null);
                  staffObj.setAttribute('ID',Userdata[0].id);
          dom.XmlNode staffName =staffObj.addChildElement('StaffName', null,null);
          staffName.addChildElement('last', null,null).addTextNode(Userdata[0].LastName);
          staffName.addChildElement('first', null,null).addTextNode(Userdata[0].FirstName);

            
                 }
          
          subscriptionXML = doc.toXmlString().replace( '<?xml version="1.0" encoding="UTF-8"?>', '' );
                 system.debug(subscriptionXML);
             
             
         
         }
     
      }