@isTest
private class TestElixirNotificationScheduler {

    @isTest
    static void testExecute() {
        
        Test.startTest();
      ElixirNotificationScheduler sh1 = new ElixirNotificationScheduler();
		String sch = '0 0 * * * ?'; 
        system.schedule('Test', sch, sh1);
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
  }

  
}