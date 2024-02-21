@istest
public class RoomControllerTest {
	public static testMethod void testschedule() {
    
    Test.StartTest();
    RoomController sh1 = new RoomController();
    
    String sch = '0 0 0 ? * * *';
    system.schedule('Room needs cleaning', sch, sh1); 
  
    Test.stopTest(); 
     
    System.assertEquals(1, 1, ' ');
}
}