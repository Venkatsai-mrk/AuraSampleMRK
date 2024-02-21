@isTest
public class NewcropCallsTest {
private static final String REQUEST_BODY_XML = '<input>Test Input</input>';
    private static final String label = 'AUTHORIZED';
    @isTest
    static void testChcMethods(){
        Account acc = TestData_NC.createAccount();
        insert acc;
        ElixirSuite__Visits__c vl = new ElixirSuite__Visits__c();
        vl.ElixirSuite__Account__c = acc.Id;
        vl.ElixirSuite__Status__c='Active';
        insert vl;
       
        //String personBody1='request=<?xml version=\'1.0\'?><REQUEST userid="p_mirketa1" password="Practice00!"><OBJECT name="rx" op="search_patient_history_api"><person>3006829693</person><organization>3004423326</organization><rx_status>AUTHORIZED</rx_status></OBJECT></REQUEST>';
        String personBody = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><GetPatientFullMedicationHistory6 xmlns="https://secure.newcropaccounts.com/V7/webservices"><credentials><PartnerName>Mirketa</PartnerName><Name>demo</Name><Password>demo</Password></credentials><accountRequest><AccountId>100</AccountId><SiteId>150</SiteId></accountRequest><patientRequest><PatientId>0019D00000QRWxVQAX</PatientId></patientRequest><prescriptionHistoryRequest><StartHistory>2004-01-01</StartHistory><EndHistory>2023-01-31</EndHistory><PrescriptionStatus>C</PrescriptionStatus><PrescriptionSubStatus>%</PrescriptionSubStatus><PrescriptionArchiveStatus>N</PrescriptionArchiveStatus></prescriptionHistoryRequest><includeSchema>N</includeSchema></GetPatientFullMedicationHistory6></soap:Body></soap:Envelope>';
        string resp ='<NewDataSet><Table><AccountGuid>f7c65daf-c047-4a8b-91cf-cba25e0ae83a</AccountGuid><AccountName>Your Customer Account Name</AccountName><ExternalAccountID>005N000000CJflzIAD</ExternalAccountID><SiteID>100</SiteID><PatientGUID>f3b70db2-4de2-4fb4-92ea-36dffbe6bd6a</PatientGUID><FullName> freddie  GH </FullName><ExternalPatientID>001N0000028B1onIAC</ExternalPatientID><PrescriptionDate>2023-02-14T01:07:00-06:00</PrescriptionDate><DrugID>178150</DrugID><DrugTypeID>F</DrugTypeID><DrugName>danazol</DrugName><DrugInfo>danazol 50 mg capsule</DrugInfo><Strength>50</Strength><StrengthUOM>mg</StrengthUOM><DosageNumberDescription>1</DosageNumberDescription><DosageForm>capsule</DosageForm><Route>by mouth</Route><DosageFrequencyDescription>DAILY</DosageFrequencyDescription><Dispense>30</Dispense><TakeAsNeeded>N</TakeAsNeeded><DispenseAsWritten>N</DispenseAsWritten><Refills>0</Refills><Status>C</Status><SubStatus>S</SubStatus><Archive>Y</Archive><PrescriptionGuid>04914c44-c483-4eaf-88e4-fc2d3fb9555d</PrescriptionGuid><OrderGUID>00000000-0000-0000-0000-000000000000</OrderGUID><PrescriptionNotes /><PharmacistNotes /><ExternalPhysicianID>DEMOLP1</ExternalPhysicianID><PhysicianName> User  User   </PhysicianName><DateMovedToPreviousMedications xml:space="preserve"> </DateMovedToPreviousMedications><FormularyTypeID>S</FormularyTypeID><ModifiedSig>true</ModifiedSig><ModifiedSigStatus>S</ModifiedSigStatus><ExternalPrescriptionID /><EpisodeIdentifier /><EncounterIdentifier /><ExternalSource /><DosageNumberTypeID>2</DosageNumberTypeID><DosageFormTypeId>2</DosageFormTypeId><DosageRouteTypeId>2</DosageRouteTypeId><DosageFrequencyTypeID>2</DosageFrequencyTypeID><DaysSupply>0</DaysSupply><PrescriptionTimestamp>2023-02-15T23:13:27.69-06:00</PrescriptionTimestamp><OriginalPrescriptionGuid>fec122e3-04b7-4e6a-9e64-e1338eb8de0e</OriginalPrescriptionGuid><ExternalUserID>DEMOLP1</ExternalUserID><ExternalUserType /><DeaGenericNamedCode>1</DeaGenericNamedCode><Diagnosis /><DiagnosisSource>ICD9CM></DiagnosisSource><DiagnosisName /><DispenseNumberQualifier>AV</DispenseNumberQualifier><DispenseNumberQualifierDescription>Capsule</DispenseNumberQualifierDescription><LocationName>Your Customer Location Name</LocationName><GenericName /><PatientFriendlySIG>Take 1 capsule by mouth daily</PatientFriendlySIG><PrintLeaflet>F</PrintLeaflet><DeaClassCode>0</DeaClassCode><PharmacyType>0</PharmacyType><PharmacyDetailType>0</PharmacyDetailType><FinalDestinationType>0</FinalDestinationType><FinalStatusType>0</FinalStatusType><PharmacyNCPDP /><PharmacyFullInfo /><SourcePrescriptionGuid>00000000-0000-0000-0000-000000000000</SourcePrescriptionGuid><DeaLegendDescription>Prescription Required</DeaLegendDescription><ExternalMidLevelID /><DrugSubID1>6602</DrugSubID1><FormularyChecked>true</FormularyChecked><StrengthUnknown>N</StrengthUnknown><PatientID>001N0000028B1onIAC</PatientID><PatientIDType /><rxcui>197556</rxcui><PUC>C48480</PUC><StopDate>20230216</StopDate><EffectiveDate>20230214</EffectiveDate></Table></NewDataSet>';
        Test.setMock(HttpCalloutMock.class, new newCropMock());
        
        test.startTest();
        
        HttpResponse response = new HttpResponse();
        response = NewcropCallouts.makeHTTPXMLPost(personBody);
        system.debug(response);
        String TestpersonId  = NewcropCallouts.retriveListOfPrescription(response);
        //NewcropCallouts.setValues(resp);
        List<ElixirSuite__Prescription_Order__c> TestnewPrescription= NewcropCallouts.newPrescription(acc.id,'%');
        //NewcropCallouts.setValues('');
        test.stopTest();
        
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'text/xml; charset=utf-8');
        System.assertEquals(200, response.getStatusCode());
}
}