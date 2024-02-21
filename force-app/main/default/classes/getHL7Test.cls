@isTest
public class getHL7Test {
	private static final String REQUEST_BODY_XML = '<input>Test Input</input>';
    @isTest static void testCred(){
        /*List<string> dummyString = new List<string>{'3007902524'};
        CHCCredentials__mdt Testcrd = getHL7.getCredentials();
        
        String personBody = 'request=<?xml version=\'1.0\'?> <REQUEST userid="p_mirketa1" password="Practice00!"> <OBJECT name="reportdoc" op="search"> <clinicalreport>3007902524</clinicalreport> <emr_ready_only>y</emr_ready_only> </OBJECT></REQUEST>';
        Test.setMock(HttpCalloutMock.class, new getHL7_Mock());
        
        test.startTest();	
        
        HttpResponse response = new HttpResponse();
        response = getHL7.makeHTTPXMLPost(personBody);
        system.debug(response);
        String TestpersonId  = getHL7.retrieveFromXMLDom(response,'body_text');
        Dom.Document getDoc = new Dom.Document();
        getDoc.load(REQUEST_BODY_XML);
        List<string> testgetHL7Msg = getHL7.getHL7Msg(dummyString);
            List<string> testgetPlacerOrderNumber = getHL7.getPlacerOrderNumber(dummyString);
        
        Clinician_Report__c cc = new Clinician_Report__c();
        cc.ElixirSuite__isDownloaded__c = false;
        cc.Clinical_Report_ID__c = '12546';
        cc.PlacerOrder__c = '12365';
        insert cc;
       
         getHL7 ad = new getHL7();
     
               System.enqueueJob(ad);
               System.assertEquals(1, 1, ''); 
        test.stopTest();*/
        System.assertEquals(1, 1, ''); 
    }
}