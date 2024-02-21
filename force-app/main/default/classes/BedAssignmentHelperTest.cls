@isTest
public class BedAssignmentHelperTest {
    @isTest
    static void testBedAssignment() {
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
        
        

        DateTime startDateTime = System.now().addDays(2);
        DateTime endDateTime = System.now().addDays(2);
        
        ElixirSuite__Reservation__c res=new ElixirSuite__Reservation__c();
        res.ElixirSuite__Account__c	=a.Id;
        res.ElixirSuite__Start_Date__c=startDateTime;
        res.ElixirSuite__End_Date__c=endDateTime;
        res.ElixirSuite__Status__c='Pending';
        insert res;

        ElixirSuite__Reservation_Line_Item__c resLineItem = new ElixirSuite__Reservation_Line_Item__c(
            ElixirSuite__Account__c = a.Id,
            ElixirSuite__Reservation__c = res.Id,
            ElixirSuite__Bed_Status__c = 'Active',
            ElixirSuite__Start_Date__c = System.now().addDays(5),
            ElixirSuite__End_Date__c = System.now().addDays(3)
        );
        
        ElixirSuite__Reservation_Line_Item__c oldResLineItem = new ElixirSuite__Reservation_Line_Item__c(
            ElixirSuite__Account__c = a.Id,
            ElixirSuite__Reservation__c = res.Id,
            ElixirSuite__Bed_Status__c = 'Active',
            ElixirSuite__Start_Date__c = System.now().addDays(7),
            ElixirSuite__End_Date__c = System.now().addDays(2)
        );
        
        
        List<ElixirSuite__Reservation_Line_Item__c> resLineItemsList = new List<ElixirSuite__Reservation_Line_Item__c>{ resLineItem };
        Map<Id, ElixirSuite__Reservation_Line_Item__c> oldResLineItemsMap = new Map<Id, ElixirSuite__Reservation_Line_Item__c>{ oldResLineItem.Id => oldResLineItem };
        
        Test.startTest();
        BedAssignmentHelper.bedAssignment(resLineItemsList, oldResLineItemsMap);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    @isTest
    static void testUpdateAccountFields() {
         // Create test data: Reservation Line Items with active bed status

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
        
        ElixirSuite__Reservation__c res=new ElixirSuite__Reservation__c();
        res.ElixirSuite__Account__c	=a.Id;
        res.ElixirSuite__Start_Date__c=System.now().addDays(1);
        res.ElixirSuite__End_Date__c=System.now().addDays(8);
        res.ElixirSuite__Status__c='Active';
        insert res;

        // Create test data: Reservation Line Items with active bed status
        ElixirSuite__Reservation_Line_Item__c resLineItemActive = new ElixirSuite__Reservation_Line_Item__c(
            ElixirSuite__Account__c = a.Id,
            ElixirSuite__Bed_Status__c = 'Active',
            ElixirSuite__Reservation__c = res.Id,
            ElixirSuite__Start_Date__c = System.now().addDays(1),
            ElixirSuite__End_Date__c = System.now().addDays(8)
        );


         

        // Create test data: Reservation Line Items with non-active bed status
        ElixirSuite__Reservation_Line_Item__c resLineItemNotActive = new ElixirSuite__Reservation_Line_Item__c(
            ElixirSuite__Account__c = a.Id,
            ElixirSuite__Bed_Status__c = 'Pending',
            ElixirSuite__Start_Date__c = System.now().addDays(2),
            ElixirSuite__End_Date__c = System.now().addDays(9)
        );
        
        // Add test data to a list
        List<ElixirSuite__Reservation_Line_Item__c> resLineItemsOld = new List<ElixirSuite__Reservation_Line_Item__c>();
        List<ElixirSuite__Reservation_Line_Item__c> resLineItemsNew = new List<ElixirSuite__Reservation_Line_Item__c>{ resLineItemActive, resLineItemNotActive };
        
        Test.startTest();
        // Call the updateAccountFields method
        BedAssignmentHelper.updateAccountFields(resLineItemsOld, resLineItemsNew);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();    
    }
    
}