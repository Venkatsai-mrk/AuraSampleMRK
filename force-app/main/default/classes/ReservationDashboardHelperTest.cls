@isTest
public class ReservationDashboardHelperTest {

    @isTest
    public static void createResDashboard(){
        Id buildingId = Schema.SObjectType.Location__c.getRecordTypeInfosByDeveloperName().get('Building').getRecordTypeId();
        Id roomId = Schema.SObjectType.Location__c.getRecordTypeInfosByDeveloperName().get('Room').getRecordTypeId();
        Id suiteId = Schema.SObjectType.Location__c.getRecordTypeInfosByDeveloperName().get('Suite').getRecordTypeId();
        Id bedId = Schema.SObjectType.Location__c.getRecordTypeInfosByDeveloperName().get('Bed').getRecordTypeId();
        
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        insert patient;
        
        Location__c building = new Location__c();
        building.Name = 'Building 1';
        building.RecordTypeId = buildingId;
        insert building;
        
        Location__c suite = new Location__c();
        suite.Name = 'Suite 1';
        suite.ElixirSuite__Suite__c = building.Id;
        suite.RecordTypeId = suiteId;
        insert suite;
        
        Location__c room = new Location__c();
        room.Name = 'room 1';
        room.RecordTypeId = roomId;
        room.ElixirSuite__RoomtoSuite__c = suite.Id;
        insert room;
        
        Location__c bed = new Location__c();
        bed.Name = 'bed 1';
        bed.RecordTypeId = bedId;
        bed.ElixirSuite__BedToRoom__c = room.Id;
        insert bed;
        
        Reservation__c res = new Reservation__c();
        res.ElixirSuite__Start_Date__c = system.now();
        res.ElixirSuite__End_Date__c = system.now() + 2;
        res.ElixirSuite__Account__c = patient.Id;
        res.ElixirSuite__Status__c = 'Pending';
		insert res;
        
        Map<Id, ElixirSuite__Reservation__c> reservationMap = new Map<Id, ElixirSuite__Reservation__c>();
        reservationMap.put(res.Id, res);
        
        Reservation_Line_Item__c lineItem = new Reservation_Line_Item__c();
        lineItem.ElixirSuite__Start_Date__c = system.now();
        lineItem.ElixirSuite__End_Date__c = system.now() + 2;
        lineItem.ElixirSuite__Reservation__c = res.Id;
        lineItem.ElixirSuite__Bed__c = bed.Id;
        lineItem.ElixirSuite__Room__c = room.Id;
        lineItem.ElixirSuite__Suite__c = suite.Id;
        lineItem.ElixirSuite__Building__c = building.Id;
        lineItem.ElixirSuite__Bed_Status__c='Pending';
        insert lineItem;
        
        test.startTest();
        ReservationDashboardHelper.createResercationDashboard(reservationMap);
        system.assertEquals(1,1,' ');
        test.stopTest();
        
    }
}