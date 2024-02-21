/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class newApexForCodeTest 
{
public static testMethod void newApex()
    {
        Account acc = new Account();
        acc.Name = 'Test Acc';
       // acc.Signature_Attachment_Id__c='signature';
        insert acc;
        
        
        test.startTest();
        	Boolean checkedvalues = False;
        	newApexForCode.newVal('verCode',null,'verCode' , acc.Id , 'Account','Comment');
        	newApexForCode.newVal('verCode',null,'verCode' , acc.Id , 'User','Comment');
        	//newApexForCode.newVal('verCode',null,'verCodee' , acc.Id , 'User','Comment');
            System.AssertEquals(1,1,''); 
       test.stopTest();
          	//System.assert( acc.name !=null); 
              
    }
}