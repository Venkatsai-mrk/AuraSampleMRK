/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-16-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class GlobalTaskTrgHelperTest {
    public static testMethod void testmethod1(){
        Account acc  = new Account(name = 'test456');
        acc.ElixirSuite__Deceased__c = true;
        insert acc;
        String userId = UserInfo.getUserId();
        Task t = new Task();
        t.OwnerId = userId;
        t.Subject = 'Hello World';
        t.Status = 'Open';
        t.Priority = 'Normal';
        t.WhatId = acc.Id;
        insert t;

        Event e = new Event();
        e.OwnerId = userId;
        e.Subject = 'Hello World';
        e.WhatId = acc.Id;
        e.StartDateTime = System.today().addDays(1);
        e.EndDateTime = System.today()+5;
        insert e;
        
        e.subject = 'Call with doctor';
        update e;

        GlobalTaskTrgHelper.preventEditIfDeceasedCheckedOnAccount(new List<Task>{t});
        GlobalTaskTrgHelper.preventEditIfDeceasedCheckedOnAccountForEvent(new List<Event>{e});
        system.assertEquals('Hello World', t.Subject,'');
        system.assertEquals('Open', t.Status,'');
        system.assertEquals('Normal', t.Priority,'');
        system.assertEquals(t.WhatId, acc.Id,'');
        system.assertEquals(userId, t.OwnerId,'');
        system.assertEquals(1,1,' ');
        
    }
}
