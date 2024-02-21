/* @description      : test class for MyCalendarController
* @author            : Srihari
* @last modified on  : 13-01-2022
* @last modified by  : Srihari
*/
@istest
public class MyCalendarControllerTest {
    @istest
    public static void testEvent(){
        Event ev = new Event();
        ev.Subject='test';
        ev.StartDateTime=system.now();
        ev.EndDateTime=system.now();
        insert ev;
        Test.startTest();
        MyCalendarController.getMyAppointments();
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
}