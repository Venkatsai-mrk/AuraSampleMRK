public with sharing class SendStatementAsEmail 
{
    @InvocableMethod
	public static void sendEmailNotif(List<Patient_Statement__c> lst_patStmts)
    {
        for(Patient_Statement__c patSt : lst_patStmts)
        {
             List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> allEmailAdd = new List<String>();
        List<User> getAllUsers  = [select Id,Username,Email,profile.name,UserRole.Name,
        UserRole.id from user where profile.name='System Administrator'
        WITH SECURITY_ENFORCED];
        // THIS LOOP INCLUDES EMAIL IDs OF ALL THE  USERS IN THE ROLES OF BILLING (TBD), FOR NOW SYS ADMIN AND ROLES ARE QUERIED
        // FOR TESTING AND TO AVOID SINGLE EMAIL LIMIT HIT 2 OF THE EMAIL IDs ARE HARDCODED, ONE IS OF THE DEVELOPER 2ND OF TESTER
        // MAY COMMENT THE HARDCODED EMAIL IDs ONCE THE ROLES ARE IN.
        /* for(User forEmail : getAllUsers) {          
        if(validateEmail(forEmail.Email)){
        allEmailAdd.add(forEmail.Email);
        }                      
        } */  
         

        //allEmailAdd.add('rajeev@mirketa.com');
        allEmailAdd.add('shwetha.kj@mirketa.com');
        //allEmailAdd.add('sivaprasad@mirketa.com');
        String currentUserFirstName = UserInfo.getFirstName();
        String currentUserLastName = UserInfo.getLastName(); 
        String firstName = '';
        String lastName = '';
            
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.setSaveAsActivity( false );
        mail.setUseSignature(false);
        mail.setToAddresses(allEmailAdd);
        mail.setSubject('PATIENT STATEMENT');
        string htmlBody = '<div> ';
        Integer count  = 1;
        htmlBody += 'Hi '+firstName+' '+lastName+'<br/><br/>'+'Greetings from Elixir!'+'<br/><br/>'+'Your statement for '+System.Today()+' has been generated. ';
        htmlBody += 'Please find the attachment for the same.' ;
        
        htmlBody+=  '<br/><br/></div>'+'<br/>'+'<i>Note that this a system generated e-mail, please do not reply. In case of any discrepancies contact the administration.</i>'+'<br/></br>'+'Regards,'+'<br/>'+'Team Elixir'+'<br/></br>'+
            '<p style="font-size:12px;">DISCLAIMER: This e-mail message may contain confidential, proprietary or legally privileged information. It is confidential and may be legally privileged or protected by law. Unauthorized use, copying or disclosure of any part is strictly prohibited. If you are not the intended recipient, please contact the sender immediately and delete it from your system</p>';
        //mail.setHtmlBody('Following are the list of CLAIM that are in READY TO SUBMIT STATUS from more than or equal to 2 days.'+' '+'Please find out the attached pdf.');
        mail.setHtmlBody(htmlBody);

        emails.add(mail);
        Messaging.sendEmail(emails);
        }
    }
}