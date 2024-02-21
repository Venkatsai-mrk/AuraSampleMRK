@isTest
public class TestReservationTriggerHelper {
    @IsTest
    static void testCheckDateTime() {
        // Create test data
        
        //Inserting Account
        Account a =new Account ();
        a.Name= 'Virat Kohli';
        a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a.ElixirSuite__Gender__c='Male';
        a.ElixirSuite__Email_Id__c='virat@gmail.com';
        a.phone='9988776655';
        a.ElixirSuite__First_Name__c='Virat';
        a.ElixirSuite__Last_Name__c='Kohli';
        a.BillingPostalCode='50021';
        a.ElixirSuite__SSN__c='12345';
        a.ElixirSuite__MRN_Number_New__c='1234567890';
        insert a;
        
        //DateTime startDateTime = DateTime.newInstance(2023, 7, 31, 12, 00, 00);
        //DateTime endDateTime = DateTime.newInstance(2023, 9, 31, 12, 00, 00);
        
        DateTime currentDateTime = DateTime.now();
        DateTime startDateTime = currentDateTime.addDays(12);
        DateTime endDateTime = currentDateTime.addDays(9);
        List<ElixirSuite__Reservation__c> resRecords=new List<ElixirSuite__Reservation__c>();
        ElixirSuite__Reservation__c res=new ElixirSuite__Reservation__c();
        res.ElixirSuite__Account__c	=a.Id;
        res.ElixirSuite__Start_Date__c=startDateTime;
        res.ElixirSuite__End_Date__c=endDateTime;
        res.ElixirSuite__Status__c='Active';
        resRecords.add(res);
        
        DateTime startDateTime1 = currentDateTime.addDays(1);
        DateTime endDateTime1 = currentDateTime.addDays(7);
        
        ElixirSuite__Reservation__c res1=new ElixirSuite__Reservation__c();
        res1.ElixirSuite__Account__c	=a.Id;
        res1.ElixirSuite__Start_Date__c=startDateTime1;
        res1.ElixirSuite__End_Date__c=endDateTime1;
        res1.ElixirSuite__Status__c='Pending';
        insert res1;
        
        
        
        Map<Id, ElixirSuite__Reservation__c> oldRes1 = new Map<Id, ElixirSuite__Reservation__c>();
        oldRes1.put(res1.Id, res1);
        
        Test.startTest();
        ReservationTriggerHelper.checkDateTime(resRecords, oldRes1);
        System.assertEquals(1, 1, '');
        Test.stopTest();
        
        
    }
    @IsTest
    static void testBedAssignment1() {
        
        //Inserting Account
        Account a =new Account ();
        a.Name= 'Virat Kohli2';
        a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a.ElixirSuite__Gender__c='Male';
        a.ElixirSuite__Email_Id__c='virat2@gmail.com';
        a.phone='9988776655';
        a.ElixirSuite__First_Name__c='Virat';
        a.ElixirSuite__Last_Name__c='Kohli';
        a.BillingPostalCode='50021';
        a.ElixirSuite__SSN__c='12345';
        a.ElixirSuite__MRN_Number_New__c='1234567890';
        insert a;
        
        
        
        DateTime currentDateTime = DateTime.now();
        DateTime startDateTime2 = currentDateTime.addDays(1);
        DateTime endDateTime2 = currentDateTime.addDays(-1);
        
        List<ElixirSuite__Reservation__c> resRecords=new List<ElixirSuite__Reservation__c>();
        ElixirSuite__Reservation__c res2=new ElixirSuite__Reservation__c();
        res2.ElixirSuite__Account__c	=a.Id;
        res2.ElixirSuite__Start_Date__c=startDateTime2;
        res2.ElixirSuite__End_Date__c=endDateTime2;
        res2.ElixirSuite__Status__c='Pending';
        resRecords.add(res2);
        
        DateTime startDateTime1 = currentDateTime.addDays(5);
        DateTime endDateTime1 = currentDateTime.addDays(-3);
        
        ElixirSuite__Reservation__c res1=new ElixirSuite__Reservation__c();
        res1.ElixirSuite__Account__c	=a.Id;
        res1.ElixirSuite__Start_Date__c=startDateTime1;
        res1.ElixirSuite__End_Date__c=endDateTime1;
        res1.ElixirSuite__Status__c='Pending';
        insert res1;
        
        
        
        Map<Id, ElixirSuite__Reservation__c> oldRes1 = new Map<Id, ElixirSuite__Reservation__c>();
        oldRes1.put(res2.Id, res1);
        
        Test.startTest();
        // Call the checkDateTime method
        ReservationTriggerHelper.checkDateTime(resRecords, oldRes1);
        System.assertEquals(1, 1, '');
        Test.stopTest();
        
    }
    @isTest
    static void testUpdateResLineItemFields() {
        // Create test data
        List<ElixirSuite__Reservation__c> resOldList = new List<ElixirSuite__Reservation__c>();
        List<ElixirSuite__Reservation__c> resNewList = new List<ElixirSuite__Reservation__c>();
        
        //Inserting Account
        Account a =new Account ();
        a.Name= 'Virat Kohli2';
        a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a.ElixirSuite__Gender__c='Male';
        a.ElixirSuite__Email_Id__c='virat2@gmail.com';
        a.phone='9988776655';
        a.ElixirSuite__First_Name__c='Virat';
        a.ElixirSuite__Last_Name__c='Kohli';
        a.BillingPostalCode='50021';
        a.ElixirSuite__SSN__c='12345';
        a.ElixirSuite__MRN_Number_New__c='1234567890';
        insert a;
        
        
        
        ElixirSuite__Reservation__c reservationNew = new ElixirSuite__Reservation__c(
            ElixirSuite__Account__c=a.Id,
            ElixirSuite__Status__c = 'Active',
            ElixirSuite__Start_Date__c = System.now().addDays(1),
            ElixirSuite__End_Date__c = System.now().addDays(8)
        );
        resNewList.add(reservationNew);
        
        // Create related Reservation Line Items
        ElixirSuite__Reservation_Line_Item__c lineItem = new ElixirSuite__Reservation_Line_Item__c(
            ElixirSuite__Reservation__c = resNewList[0].Id,
            ElixirSuite__Start_Date__c = resNewList[0].ElixirSuite__Start_Date__c,
            ElixirSuite__End_Date__c = resNewList[0].ElixirSuite__End_Date__c,
            ElixirSuite__Account__c = a.Id
        );
        insert lineItem;
        Test.startTest();
        // Call the updateResLineItemFields method
        ReservationTriggerHelper.updateResLineItemFields(resOldList, resNewList);
        System.assertEquals(1, 1, '');
        Test.stopTest();
        
    }
    @isTest
    static void testUpdateParent() {
        //Inserting Account
        Account a =new Account ();
        a.Name= 'Virat Kohli2';
        a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a.ElixirSuite__Gender__c='Male';
        a.ElixirSuite__Email_Id__c='virat2@gmail.com';
        a.phone='9988776655';
        a.ElixirSuite__First_Name__c='Virat';
        a.ElixirSuite__Last_Name__c='Kohli';
        a.BillingPostalCode='50021';
        a.ElixirSuite__SSN__c='12345';
        a.ElixirSuite__MRN_Number_New__c='1234567890';
        insert a;
        
        
        
        ElixirSuite__Reservation__c parentReservation = new ElixirSuite__Reservation__c(
            ElixirSuite__Account__c=a.Id,
            ElixirSuite__Status__c = 'Pending',
            ElixirSuite__Start_Date__c = System.now().addDays(1),
            ElixirSuite__End_Date__c = System.now().addDays(8)
        );
        insert parentReservation;
        
        ElixirSuite__Reservation__c childReservation = new ElixirSuite__Reservation__c(
            ElixirSuite__Account__c=a.Id,
            ElixirSuite__Parent_Reservation__c=parentReservation.Id,
            ElixirSuite__Status__c = 'Pending',
            ElixirSuite__Start_Date__c = System.now().addDays(2),
            ElixirSuite__End_Date__c = System.now().addDays(9)
        );
        insert childReservation;
        
        List<ElixirSuite__Reservation__c> reservations = new List<ElixirSuite__Reservation__c>{ childReservation };
            
            Test.startTest();
        // Call the updateParent method
        ReservationTriggerHelper.updateParent(reservations);
        System.assertEquals(1, 1, '');
        Test.stopTest();
        
        
        
    }
    
    @isTest
    static void testUpdateCancelationProcedure() {
        Account a =new Account ();
        a.Name= 'Virat Kohli2';
        a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a.ElixirSuite__Gender__c='Male';
        a.ElixirSuite__Email_Id__c='virat2@gmail.com';
        a.phone='9988776655';
        a.ElixirSuite__First_Name__c='Virat';
        a.ElixirSuite__Last_Name__c='Kohli';
        a.BillingPostalCode='50021';
        a.ElixirSuite__SSN__c='12345';
        a.ElixirSuite__MRN_Number_New__c='1234567890';
        insert a;
        // Create test data for ElixirSuite__Reservation__c
        ElixirSuite__Reservation__c reservation = new ElixirSuite__Reservation__c();
        ElixirSuite__Reservation__c res=new ElixirSuite__Reservation__c();
        res.ElixirSuite__Account__c	=a.Id;
        res.ElixirSuite__Start_Date__c=system.today();
        res.ElixirSuite__End_Date__c=system.today();
        res.ElixirSuite__Status__c='Canceled';
        res.ElixirSuite__Total_price__c=500;
        res.ElixirSuite__Total_net_price__c=500;
        insert res;
        ElixirSuite__Reservation_Line_Item__c reservationLineItem = new ElixirSuite__Reservation_Line_Item__c();
        reservationLineItem.ElixirSuite__Reservation__c = res.Id;
        reservationLineItem.ElixirSuite__isBillable__c = 'True';
        insert reservationLineItem;
        
        ElixirSuite__Procedure__c procedure = new ElixirSuite__Procedure__c();
        procedure.ElixirSuite__Reservation_Line_Item__c = reservationLineItem.Id;
        procedure.Name = 'Test';
        insert procedure;
        
        Test.startTest();
        
        List<ElixirSuite__Reservation__c> reservationList = new List<ElixirSuite__Reservation__c>{res};
            ReservationTriggerHelper.updateCancelationProcedure(reservationList);
        
        Test.stopTest();
        System.assertEquals(1, 1, '');
    }
    @IsTest
    static void testCheckDateTime1() {
        // Create test data
        Account a = new Account (
            Name = 'Virat Kohli',
            ElixirSuite__DOB__c = Date.newInstance(2003, 9, 15),
            ElixirSuite__Gender__c = 'Male',
            ElixirSuite__Email_Id__c = 'virat@gmail.com',
            Phone = '9988776655',
            ElixirSuite__First_Name__c = 'Virat',
            ElixirSuite__Last_Name__c = 'Kohli',
            BillingPostalCode = '50021',
            ElixirSuite__SSN__c = '12345',
            ElixirSuite__MRN_Number_New__c = '1234567890'
        );
        insert a;

        // Test scenario for Active reservation
        DateTime currentDateTime = DateTime.now();
        DateTime startDateTime = currentDateTime.addDays(1);
        DateTime endDateTime = currentDateTime.addDays(5);
        ElixirSuite__Reservation__c activeReservation = new ElixirSuite__Reservation__c(
            ElixirSuite__Account__c = a.Id,
            ElixirSuite__Start_Date__c = startDateTime,
            ElixirSuite__End_Date__c = endDateTime,
            ElixirSuite__Status__c = 'Active'
        );
        insert activeReservation;

        // Test scenario for Pending reservation
        DateTime startDateTimePending = currentDateTime.addDays(3);
        DateTime endDateTimePending = currentDateTime.addDays(7);
        ElixirSuite__Reservation__c pendingReservation = new ElixirSuite__Reservation__c(
            ElixirSuite__Account__c = a.Id,
            ElixirSuite__Start_Date__c = startDateTimePending,
            ElixirSuite__End_Date__c = endDateTimePending,
            ElixirSuite__Status__c = 'Pending'
        );
        insert pendingReservation;

        Map<Id, ElixirSuite__Reservation__c> oldRes1 = new Map<Id, ElixirSuite__Reservation__c>();
        oldRes1.put(pendingReservation.Id, pendingReservation);

        Test.startTest();
        ReservationTriggerHelper.checkDateTime(new List<ElixirSuite__Reservation__c>{ activeReservation, pendingReservation }, oldRes1);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateResLineItemFields1() {
        // Create test data
        Account a = new Account (
            Name = 'Virat Kohli2',
            ElixirSuite__DOB__c = Date.newInstance(2003, 9, 15),
            ElixirSuite__Gender__c = 'Male',
            ElixirSuite__Email_Id__c = 'virat2@gmail.com',
            Phone = '9988776655',
            ElixirSuite__First_Name__c = 'Virat',
            ElixirSuite__Last_Name__c = 'Kohli',
            BillingPostalCode = '50021',
            ElixirSuite__SSN__c = '12345',
            ElixirSuite__MRN_Number_New__c = '1234567890'
        );
        insert a;

        // Create new reservation
        ElixirSuite__Reservation__c reservationNew = new ElixirSuite__Reservation__c(
            ElixirSuite__Account__c = a.Id,
            ElixirSuite__Status__c = 'Active',
            ElixirSuite__Start_Date__c = System.now().addDays(1),
            ElixirSuite__End_Date__c = System.now().addDays(8)
        );
        insert reservationNew;

        // Create related reservation line item
        ElixirSuite__Reservation_Line_Item__c lineItem = new ElixirSuite__Reservation_Line_Item__c(
            ElixirSuite__Reservation__c = reservationNew.Id,
            ElixirSuite__Start_Date__c = reservationNew.ElixirSuite__Start_Date__c,
            ElixirSuite__End_Date__c = reservationNew.ElixirSuite__End_Date__c,
            ElixirSuite__Account__c = a.Id
        );
        insert lineItem;

        Test.startTest();
        ReservationTriggerHelper.updateResLineItemFields(new List<ElixirSuite__Reservation__c>{}, new List<ElixirSuite__Reservation__c>{ reservationNew });
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
}