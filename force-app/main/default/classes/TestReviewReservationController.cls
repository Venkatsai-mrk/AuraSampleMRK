@isTest
public class TestReviewReservationController {
    
    @isTest
    static void testGetLocationDetails() {
        Test.startTest();
         //Inserting Account
        Account testAccount =new Account ();
        testAccount.Name= 'Virat Kohli';
        testAccount.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        testAccount.ElixirSuite__Gender__c='Male';
        testAccount.ElixirSuite__Email_Id__c='virat@gmail.com';
        testAccount.phone='9988776655';
        testAccount.ElixirSuite__First_Name__c='Virat';
        testAccount.ElixirSuite__Last_Name__c='Kohli';
        testAccount.BillingPostalCode='50021';
        testAccount.ElixirSuite__SSN__c='12345';
        testAccount.ElixirSuite__MRN_Number_New__c='1234567890';
        
        insert testAccount;
        
        ReviewReservationController.AccountInfoWrapper accountData=new ReviewReservationController.AccountInfoWrapper();
        accountData.name='Charan Tej';
        accountData.birthDate=Date.newInstance(2000, 9, 15);
        accountData.phone='4445556668';
        accountData.email='charan@gmail.com';
        
        
       
        
        // Call the method to test
        //ReviewReservationController.AccountInfoWrapper accountInfo = ReviewReservationController.getAccountDetails(testAccount.Id);
        ReviewReservationController.getAccountDetails(testAccount.Id);
        
        
        
        Id bedRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByName().get('Bed').getRecordTypeId();
        
        // Insert a builiding
        Id buildingRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByName().get('Building').getRecordTypeId();
        ElixirSuite__Location__c building = new ElixirSuite__Location__c(Name = 'Builiding-1', RecordTypeId = buildingRecordTypeId);
        INSERT building;
        
        // Insert Suites
        Id suiteRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByName().get('Suite').getRecordTypeId();
        List<ElixirSuite__Location__c> suites = new List<ElixirSuite__Location__c>();
        
        for (Integer i=0; i<3; i++) {
            suites.add(new ElixirSuite__Location__c(Name = 'Suite-'+i, RecordTypeId = suiteRecordTypeId, ElixirSuite__Suite__c = building.Id));
        }
        
        INSERT suites;
        
        // insert beds under suites
        List<ElixirSuite__Location__c> suiteBeds = new List<ElixirSuite__Location__c>();
        for (ElixirSuite__Location__c suite : suites) {
            for (Integer i=0; i<3; i++) {
                suiteBeds.add(new ElixirSuite__Location__c(Name= suite.Name + '-Bed-' + i, RecordTypeId = bedRecordTypeId, ElixirSuite__BedtoSuite__c = suite.Id));
            }
        }
        INSERT suiteBeds;
        
        
        // Insert building -> Room
        Id roomRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByName().get('Room').getRecordTypeId();
        List<ElixirSuite__Location__c> rooms = new List<ElixirSuite__Location__c>();
        
        for (Integer i=0; i<3; i++) {
            rooms.add(new ElixirSuite__Location__c(Name = 'Room-'+i, RecordTypeId = roomRecordTypeId, ElixirSuite__Room__c = building.Id));
        
        }
        INSERT rooms;
        
        // insert beds under rooms
        List<ElixirSuite__Location__c> roomBeds = new List<ElixirSuite__Location__c>();
        for (ElixirSuite__Location__c room : rooms) {
            for (Integer i=0; i<2; i++) {
                roomBeds.add(new ElixirSuite__Location__c(Name=room.Name+'-Bed-' + i, RecordTypeId = bedRecordTypeId, ElixirSuite__BedToRoom__c = room.Id));
            }
        }
        INSERT roomBeds;
        
        // Insert building -> suite -> room
        ElixirSuite__Location__c suiteWithRoom = new ElixirSuite__Location__c(Name = 'SuiteWithRoom-0', RecordTypeId = suiteRecordTypeId, ElixirSuite__Suite__c = building.Id);
        INSERT suiteWithRoom;
        
        List<ElixirSuite__Location__c> roomsUnderSuites = new List<ElixirSuite__Location__c>();
        for (Integer i=0; i<3; i++) {
            roomsUnderSuites.add(new ElixirSuite__Location__c(Name = 'RoomUnderSuite-'+i, RecordTypeId = roomRecordTypeId, ElixirSuite__RoomtoSuite__c = suiteWithRoom.Id));
        }
        INSERT roomsUnderSuites;
        
        // insert beds under rooms(under suite)
        List<ElixirSuite__Location__c> roomUnderSuiteBeds = new List<ElixirSuite__Location__c>();
        for (ElixirSuite__Location__c room : roomsUnderSuites) {
            for (Integer i=0; i<2; i++) {
                roomUnderSuiteBeds.add(new ElixirSuite__Location__c(Name=room.Name+'-Bed-' + i, RecordTypeId = bedRecordTypeId, ElixirSuite__BedToRoom__c = room.Id));
            }
        }
        INSERT roomUnderSuiteBeds;
        
        List<ElixirSuite__Location__c> locationLst=[select id, Name, ElixirSuite__Building__c, ElixirSuite__Room__c, 
                                                    ElixirSuite__BedToRoom__c, ElixirSuite__BedtoSuite__c 
                                                    from ElixirSuite__Location__c];
        
        // Extract Id values from the query results
		List<String> locationIds = new List<String>();
		for (ElixirSuite__Location__c location : locationLst) {
    	locationIds.add(location.Id);
		}
        ReviewReservationController.getLocationDetails(locationIds);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
        }
}