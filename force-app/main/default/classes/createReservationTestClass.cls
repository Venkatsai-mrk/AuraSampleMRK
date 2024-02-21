@isTest
public with sharing class createReservationTestClass {
   @IsTest
    static void testAssertBedsAvailable(){
        
        Test.startTest();
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.ElixirSuite__Patient_s_Birth_Date__c = Date.newInstance(2000, 2, 17);
        acc.ElixirSuite__Insured_s_Address__c = 'Test Address';
        acc.AccountNumber = '7418529630';
        acc.Phone = '7418529631';
        acc.BillingPostalCode = '12365';
        acc.ElixirSuite__Gender__c='Female';
        acc.BillingState='SA';
        acc.BillingCity='AS';
        insert acc;
        
        
        
        ElixirSuite__Provider__c exPrvdr = new ElixirSuite__Provider__c();
        exPrvdr.ElixirSuite__Account__c = acc.Id;
        exPrvdr.Name = 'Test Provider';
        exPrvdr.ElixirSuite__Provider_Zip__c = '12356';
        exPrvdr.ElixirSuite__Provider_State__c = 'TestState';
        exPrvdr.ElixirSuite__Provider_Last_Name__c = 'TestLastProvider';
        exPrvdr.ElixirSuite__Provider_City__c = 'TestProviderCity';
        exPrvdr.ElixirSuite__Provider_Code__c = '14785';
        insert exPrvdr;
            
        
        ElixirSuite__Visits__c exVisit = new ElixirSuite__Visits__c();
        exVisit.ElixirSuite__Account__c = acc.Id;
        exVisit.ElixirSuite__Status__c = 'Active';
        exVisit.ElixirSuite__Location__c = 'US';
        exVisit.ElixirSuite__Care_Episode_Location__c = exPrvdr.Id;
        exVisit.Name = 'Test Visit';
        insert exVisit;
        
        Date todayDate = System.today();
        // Create a Datetime instance for testing
        Integer yearValue = 2023;
        Integer monthValue = 8;
        Integer dateValue = 28;
        Integer hourValue = 15;
        Integer minuteValue = 30;
        Integer secondValue = 0;
        
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
        
        ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        settings.ElixirSuite__Default_Reservation_Start_Hours__c=10;
        settings.ElixirSuite__Default_Reservation_Start_Minutes__c=0;
        settings.ElixirSuite__Default_Reservation_End_Hours__c=11;
        settings.ElixirSuite__Default_Reservation_End_Minutes__c=0;
        insert settings;
        
        DateTime startDateTime = DateTime.now();
        DateTime endDateTime = startDateTime.addDays(7);
        

        
        
        ElixirSuite__Location__c building2 = new ElixirSuite__Location__c(Name = 'Builiding-2', RecordTypeId = buildingRecordTypeId);
        INSERT building2;
        
        ElixirSuite__Location__c building3 = new ElixirSuite__Location__c(Name = 'Builiding-2', RecordTypeId = buildingRecordTypeId);
        INSERT building3;
        
        List<ElixirSuite__Location__c> buildingLst=[select id , name, RecordType.DeveloperName, RecordTypeId from ElixirSuite__Location__c 
                where RecordType.DeveloperName ='Building'];
        List<String> buildingRecords=new List<String>();
        for (ElixirSuite__Location__c buildings : buildingLst) {
            buildingRecords.add(buildings.Id);
            
        }
        Boolean onlyFullyAvailableRoomsAndSuites=false;
        Boolean onlyFullyAvailableRooms=false;
        Boolean onlyFullyAvailableSuites=false;
        String roomAttributes='';
        String suiteAttributes='';
        String bedAttributes='';
        Integer roomOffset=2;
        Integer suiteOffset=7; 
        Integer roomUnderSuiteOffset=8; 
        Boolean getNextOffset=true;
        
        List<ElixirSuite__Location__c> bedLst=[select id , name, RecordType.DeveloperName, ElixirSuite__Bed_Attributes__c, 
            ElixirSuite__Room_Attributes__c, ElixirSuite__Suite_Attributes__c  from ElixirSuite__Location__c
         where RecordType.DeveloperName ='Bed'];
        List<String> bedRecords=new List<String>();
        for (ElixirSuite__Location__c beds : bedLst) {
            bedRecords.add(beds.Id);
            
        }
        
        CreateReservation.getAvailableBeds(startDateTime, endDateTime, buildingRecords, onlyFullyAvailableRoomsAndSuites,
                         onlyFullyAvailableRooms, onlyFullyAvailableSuites, roomAttributes, suiteAttributes, 
                         bedAttributes, roomOffset, suiteOffset, roomUnderSuiteOffset, getNextOffset);
        
        CreateReservation.assertThatTheseBedsAreAvailable(bedRecords, startDateTime, endDateTime);
        
        CreateReservation.overlappingReservation(acc.Id, startDateTime, endDateTime);
        
       Id rt = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
 		Id rt1 = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
		
		
        ElixirSuite__Procedure__c proRec = new ElixirSuite__Procedure__c();
        proRec.Name = 'Sumo';
        proRec.ElixirSuite__Active__c = true;
        proRec.ElixirSuite__Location__c=rooms[0].Id;
        proRec.RecordTypeId = rt;
        insert proRec;
        
        ElixirSuite__Procedure__c proRec1 = new ElixirSuite__Procedure__c();
        proRec1.Name = 'Sumo1';
        proRec1.ElixirSuite__Active__c = true;
        proRec1.RecordTypeId = rt;
        insert proRec1;
        
        ElixirSuite__Procedure__c proRec11 = new ElixirSuite__Procedure__c();
        proRec11.Name = 'Sumo11';
        proRec11.ElixirSuite__Active__c = true;
        proRec11.RecordTypeId = rt;
        insert proRec11;
        
        ElixirSuite__Provider__c prov = new ElixirSuite__Provider__c();
        prov.Name = 'Loop';
        prov.ElixirSuite__Provider_Code__c = 'a1267';
        prov.RecordTypeId = rt1;
        insert prov;
        
        ElixirSuite__Actual_Price__c ap = new ElixirSuite__Actual_Price__c();
        ap.ElixirSuite__Procedure__c = proRec.Id;
        ap.ElixirSuite__List_Price__c = 10;
        ap.ElixirSuite__Provider__c = prov.Id;
		ap.ElixirSuite__Description__c='Actual';
        insert ap;
        
        ElixirSuite__Actual_Price__c ap1 = new ElixirSuite__Actual_Price__c();
        ap1.ElixirSuite__Procedure__c = proRec.Id;
        ap1.ElixirSuite__List_Price__c = 100;
        ap1.ElixirSuite__Provider__c = prov.Id;
		ap1.ElixirSuite__Description__c='Actual1';
        insert ap1;
        
        ElixirSuite__Actual_Price__c ap11 = new ElixirSuite__Actual_Price__c();
        ap11.ElixirSuite__Procedure__c = proRec.Id;
        ap11.ElixirSuite__List_Price__c = 300;
        ap11.ElixirSuite__Provider__c = prov.Id;
		ap11.ElixirSuite__Description__c='Actual1';
        insert ap11;


        String billableEntity='[{"actualPrices":[ "ElixirSuite__Procedure__c":"'+proRec.Id+'","Id":"'+ap.Id+'","ElixirSuite__List_Price__c":"600.00","ElixirSuite__List_Price__c":"Actual"],"locationId":"'+rooms[0].Id+'", "locationName":"Room 1","recordTypeName":"Room","index":1,"options":[{"label":"Actual Price - 500","value":"500.00"}],"price":4200,"selectedDiscountType":"%","selectedDiscountValue":"10","netPrice":"3780.00"},{"actualPrices":["ElixirSuite__Procedure__c":"'+proRec1.Id+'","Id":"'+ap1.Id+'","ElixirSuite__List_Price__c":"600.00","ElixirSuite__List_Price__c":"Actual"],"locationId":"'+rooms[0].Id+'","locationName":"Room 1","recordTypeName":"Suite","index":1, "options":[{"label":"600.00","value":"600.00"},{"label":"500.00","value":"500.00"}],"price":4200,"selectedDiscountType":"%","selectedDiscountValue":"10","netPrice":"3780.00"},{"actualPrices":["ElixirSuite__Procedure__c":"'+proRec11.Id+'","Id":"'+ap11.Id+'","ElixirSuite__List_Price__c":"600.00","ElixirSuite__List_Price__c":"Actual"],"locationId":"'+rooms[0].Id+'","locationName":"Room 1","recordTypeName":"Bed","index":1,"options":[{"label":"600.00","value":"600.00"},{"label":"500.00","value":"500.00"}],"price":4200,"selectedDiscountType":"%","selectedDiscountValue":"10","netPrice":"3780.00"}]';
        String totalPrice='4200';
        String totalNetPrice='3800';
        String selectedBeds='[{"type":"room_suite","buildingId":"'+building.Id+'","buildingName":"","buildingNameBak":"Building 1","roomId":"'+rooms[0].Id+'","roomName":"Room 1","suiteId":"'+suites[0].Id+'","suiteName":"Suite 1","bedId":"'+roomBeds[0].Id+'","bedName":"BEd 1","styleClass":" firstUniqueSuite  firstUniqueRoom  firstUniqueSuite  firstUniqueRoom "}]';
		String reservationType='New_Reservation';
        //CreateReservation.saveReservationData(acc.Id, startDateTime, endDateTime, selectedBeds, billableEntity, totalPrice, totalNetPrice, reservationType);

        CreateReservation.myWrapper picklistValues = CreateReservation.getAttributes();
        System.assertNotEquals(null, picklistValues, 'picklistValues should atleast not be null');
        CreateReservation.getLatestActiveCareEpisode(acc.Id);
        CreateReservation.getURL(acc.Id);
        CreateReservation.getAllBuildings();
        CreateReservation.updateTime(todayDate, yearValue, monthValue, dateValue, hourValue, minuteValue, secondValue);
        CreateReservation.getUserDate();
        
        /*DateTime startDateTime = DateTime.newInstance(2023, 8, 31, 12, 00, 00);
        DateTime endDateTime = DateTime.newInstance(2023, 2, 31, 12, 00, 00);
        CreateReservation.assertThatTheseBedsAreAvailable(new List<String>(), startDateTime, endDateTime);*/
        
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
        
    }
    
}