@isTest
public class CHC_TestClass {
     private static final String REQUEST_BODY_XML = '<input>Test Input</input>';
    private static final String label = 'AUTHORIZED';
    @isTest
    static void testChcMethods(){
        Account acc = TestDataChc.createAccount();
        insert acc;
        //String personBody1='request=<?xml version=\'1.0\'?><REQUEST userid="p_mirketa1" password="Practice00!"><OBJECT name="rx" op="search_patient_history_api"><person>3006829693</person><organization>3004423326</organization><rx_status>AUTHORIZED</rx_status></OBJECT></REQUEST>';
        String personBody = 'request=<?xml version=\'1.0\'?><REQUEST userid="p_mirketa1" password="Practice00!"><OBJECT name="person" op="search_hsi"><hsi_value>0015300000GOh4dAAD</hsi_value><organization>3004423326</organization></OBJECT></REQUEST>';
        Test.setMock(HttpCalloutMock.class, new CHC_MockCallouts());
        
        test.startTest();
        
        HttpResponse response = new HttpResponse();
        response = CHC_PrescriptionsCallout.makeHTTPXMLPost(personBody);
        system.debug(response);
        String TestpersonId  = CHC_PrescriptionsCallout.retrieveFromXMLDom(response,'person');
       
        Map<String,String> crdMap= CHC_PrescriptionsCallout.getCredentials();
       
        CHC_PrescriptionsCallout.CHC_Prescription testName = new CHC_PrescriptionsCallout.CHC_Prescription();
       String TestDrugName = testName.DrugName;
         String Testsig = testName.sig;
         String Testprescriber=testName.prescriber;
         String TestrxStatus =testName.rxStatus;
         String TestQuantity =testName.Quantity;
         String TestRxType =testName.RxType;
        
        List<CHCCredentials__mdt> chcXml= CHC_PrescriptionsCallout.getXmlList('');
       
       //CHC_PrescriptionsCallout.getPersonId(acc.id);
        Dom.Document getDoc = new Dom.Document();
        getDoc.load(REQUEST_BODY_XML);
        //Dom.XMLNode address = getDoc.getRootElement();
        CHC_PrescriptionsCallout.getPrescriptionList(acc.id,label);
        
        test.stopTest();
        
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/x-www-form-urlencoded');
        System.assertEquals(200, response.getStatusCode());
    }
    
    
}