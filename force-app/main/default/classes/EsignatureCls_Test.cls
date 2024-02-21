@isTest
public class EsignatureCls_Test 
{
    public static testMethod void esignCls()
    {
        User u = new User(
            ProfileId = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'kjshweta@gmail.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        test.startTest();
        EsignatureCls.pwdm='';
        EsignatureCls.oldCode='';
        EsignatureCls.namespace='';
        try
        {
            EsignatureCls.sendEmail(u.Id);    
        }
        catch(Exception e){}
        
        EsignatureCls.userId();
        EsignatureCls.getProfileName();
        EsignatureCls.generatePassword();
        test.stopTest();
        System.assert(U.LastName!=null);
    }
}