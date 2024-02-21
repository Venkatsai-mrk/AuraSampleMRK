/*Author name           :  Shwetha KJ
* Purpose               :  To send notification for open procedures. 
* Schedule              :  Scheduling on the basis of days and hour. 
* Test Class            :  SendNotificationsForOpnProcBatch_Test
* Created Date          :  20-Oct-2020
* Last Modified Date    :  20-Oct-2020
*/

global with sharing  class SendNotificationsForOpnProc implements Database.Batchable<sObject>,database.stateful  {
    global List<Procedure__c> parentProceListToProcess = new List<Procedure__c>();
    global ProcedureAlertParameters__c statusParametres = [Select Id,No_of_days__c,No_of_hours__c from ProcedureAlertParameters__c 
    WITH SECURITY_ENFORCED LIMIT 1];
    global Decimal diffFromDate ;
    global MailWrapper allDataForMail = new MailWrapper();
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        String WhereClause = 'Claim__c = null';
        String query = 'SELECT Id, Name, Claim__c, From_Date__c,From_Date_of_Service__c,CPT_HCPCS_Code__c, Account__c,Account__r.Name, To_Date__c FROM Procedure__c where '+WhereClause;
        return Database.getQueryLocator(query);

    }
    global void execute(Database.BatchableContext bc,List<Procedure__c> scope){
        if(String.isNotBlank(String.valueOf(statusParametres)))
        {
            if(statusParametres.No_of_days__c!= null && statusParametres.No_of_hours__c== null)
            {
                diffFromDate = statusParametres.No_of_days__c;
                allDataForMail.dateDiff = statusParametres.No_of_days__c;
            }
            if(statusParametres.No_of_days__c== null && statusParametres.No_of_hours__c!= null)
            {
                diffFromDate = statusParametres.No_of_hours__c;
                allDataForMail.dateDiff = statusParametres.No_of_hours__c;
            }
        }
        List<Procedure__c> procedureToProcess = new List<Procedure__c>();
        for (Procedure__c procRecordsToFilter : scope) {
            Integer statusRecordQuo = 0;
            if(procRecordsToFilter.From_Date_of_Service__c != Null)
            {
                statusRecordQuo = getStatusQuo(procRecordsToFilter.From_Date_of_Service__c);
            }
            if(statusRecordQuo >=diffFromDate)
            {
                allDataForMail.procedureRecords.add(procRecordsToFilter);
                allDataForMail.allFilteredRecordsLst.add(procRecordsToFilter);
            }
            procedureToProcess.add(procRecordsToFilter);
        }
        parentProceListToProcess.addAll(procedureToProcess);
        
     
    }    
    global void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        if( allDataForMail.allFilteredRecordsLst!=null &&  allDataForMail.allFilteredRecordsLst.size()>0){
            String finalStringifiedList = JSON.serialize(parentProceListToProcess);
            sendPdfNotificationForClaimRecords(finalStringifiedList,parentProceListToProcess,allDataForMail);
            
        }
        
        String schdays;
        String schhours;
        List<ProcedureAlertParameters__c> prolist = [SELECT ID, days__c, After_every_hours__c, Active__c FROM ProcedureAlertParameters__c WHERE Active__c = true];
        for(ProcedureAlertParameters__c pro : prolist){ 
            Integer day = Integer.valueOf(pro.days__c);
            
            //Check for days value only in custom setting
            if(pro.days__c!= null && pro.After_every_hours__c== null){
                schdays = '0 0 1 '+day+' * * ?';
            }
            
            //Check for hours value only in custom setting
            if(pro.days__c== null && pro.After_every_hours__c!= null){
                Integer hour = Integer.valueOf(pro.After_every_hours__c);
                schhours = '0 0 '+hour+'* * * ?';
                
            }
        }
        SendNotificationsForOpnProc_schedule schd = new SendNotificationsForOpnProc_schedule();
        
        //Scheduling on the basis of days
        if(schdays!= null){
            system.schedule('SendNotificationsForOpnProc', schdays, schd);
        }
        
        //Scheduling on the basis of hours
        if(schhours!= null){
            system.schedule('SendNotificationsForOpnProc', schhours, schd);
        }       
    }

    public class MailWrapper 
    {   
        public Decimal dateDiff;
        public List<Procedure__c> procedureRecords = new List<Procedure__c>();
        public List<Procedure__c> allFilteredRecordsLst= new List<Procedure__c>();
    }
       
    public static Boolean validateEmail(String email) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches())
            res = false;
        return res;
    }
    public static Integer getStatusQuo(Datetime fromDate){
        ProcedureAlertParameters__c statusParams = [Select Id,No_of_days__c,No_of_hours__c from ProcedureAlertParameters__c LIMIT 1];
           
        Integer numberDaysDue;
        //Date startDate = Date.valueOf(fromDate);
        //Date dueDate = System.today();
        //numberDaysDue = startDate.daysBetween(dueDate);
        if(String.isNotBlank(String.valueOf(statusParams)))
        {
            if(statusParams.No_of_days__c!= null && statusParams.No_of_hours__c== null)
            {
                Datetime startDate = fromDate;
                Datetime dueDate = System.now();
                Long dt1Long1 = startDate.getTime();
                Long dt2Long1 = dueDate.getTime();
                Long milliseconds1 = dt2Long1 - dt1Long1;
                Long seconds1 = milliseconds1 / 1000;
                Long minutes1 = seconds1 / 60;
                Long hours1 = minutes1 / 60;
                Long days1 = hours1 / 24;
                numberDaysDue = Integer.valueOf(days1);               
            }           
         
            if(statusParams.No_of_days__c== null && statusParams.No_of_hours__c!= null)
            {
                Datetime startDate1 = fromDate;
                Datetime dueDate1 = System.now();
                Long dt1Long = startDate1.getTime();
                Long dt2Long = dueDate1.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                numberDaysDue = Integer.valueOf(hours);               
            }
        }
        return numberDaysDue;
            
    }
    public static void sendPdfNotificationForClaimRecords(String record,List<Procedure__c> procedRecords,MailWrapper allRecords)
    {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Boolean emaiNotExistsOrDirtyEmail = false;
        Boolean allowProceed = true;
        List<String> allEmailAdd = new List<String>();
        List<User> getAllUsers  = [select Id,Username,Email,profile.name,UserRole.Name,UserRole.id from user where profile.name='System Administrator' or UserRole.Name='Billing Team'];
                // THIS LOOP INCLUDES EMAIL IDs OF ALL THE  USERS IN THE ROLES OF BILLING (TBD), FOR NOW SYS ADMIN AND ROLES ARE QUERIED
                // FOR TESTING AND TO AVOID SINGLE EMAIL LIMIT HIT 2 OF THE EMAIL IDs ARE HARDCODED, ONE IS OF THE DEVELOPER 2ND OF TESTER
                // MAY COMMENT THE HARDCODED EMAIL IDs ONCE THE ROLES ARE IN.
       /* for(User forEmail : getAllUsers) {          
            System.debug('email forRepeaat '+forEmail.Email);
            if(validateEmail(forEmail.Email)){
                allEmailAdd.add(forEmail.Email);
            }                      
        }*/      
        allEmailAdd.add('shwetha.kj@mirketa.com');
       // allEmailAdd.add('tanveer.ahmed@mirketa.com');
        String currentUserFirstName = UserInfo.getFirstName();
        String currentUserLastName = UserInfo.getLastName();        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.setSaveAsActivity( false );
        mail.setUseSignature(false);
        mail.setToAddresses(allEmailAdd);
        System.debug('buffer array '+mail);
        mail.setSubject('PROCEDURE RECORDS || DELAYED CLAIM GENERATION');
        string htmlBody = '<div> ';
        Integer count  = 1;
        htmlBody += 'Hi '+currentUserFirstName+' '+currentUserLastName+'<br/><br/>'+'Greetings from Elixir.'+'<br/><br/>';
        if(allRecords.procedureRecords.size()>0 && allRecords.procedureRecords!=null){
             
             htmlBody += 'This email is to bring to your attention that the following list of open procedures are unattended for '+'<b>'+allRecords.dateDiff+'</b>'+' day/hours from the date of service.'+'<br/></br>'+'<table style="width:100%;" border="1" cellspacing="1px" cellpadding="1px">'+
                 '<tr><td> ' + 'SNO.' + '</td>'+'<td> Date of Service </td>'+'<td> CPT Code/HCPCS </td>'+'<td>Procedure Name</td>'+'<td>Patient Name</td>'+'<td>Number of day/hours unattended</td>'+'</tr>' ;
            for(Procedure__c proc : allRecords.procedureRecords)
            {   
                Integer statusRecordQuo = 0;
                String formatted;
                if(proc.From_Date_of_Service__c != Null)
                {
                   statusRecordQuo = getStatusQuo(proc.From_Date_of_Service__c); 
                   formatted=proc.From_Date_of_Service__c.format('MMMM dd, yyyy');
                }
                System.debug('from date'+Date.valueOf(proc.From_Date_of_Service__c));
                htmlBody += '<tr><td> ' + count + '</td><td>'+ formatted+'</td><td>'+proc.CPT_HCPCS_Code__c+'</td><td>'+proc.Name+' </td><td>'+proc.Account__r.Name+'</td><td>'+statusRecordQuo+'</td></tr>';
                count++;
            }  
            htmlBody += '</table>';
        }  
        htmlBody+=  '<br/><br/></div>'+'<br/>'+'<i>Note that this a system generated e-mail, please do not reply. In case of any discrepancies contact the administration.</i>'+'<br/></br>'+'Regards,'+'<br/>'+'Team Elixir'+'<br/></br>'+
            '<p style="font-size:12px;">DISCLAIMER: This e-mail message may contain confidential, proprietary or legally privileged information. It is confidential and may be legally privileged or protected by law. Unauthorized use, copying or disclosure of any part is strictly prohibited. If you are not the intended recipient, please contact the sender immediately and delete it from your system</p>';
        //mail.setHtmlBody('Following are the list of CLAIM that are in READY TO SUBMIT STATUS from more than or equal to 2 days.'+' '+'Please find out the attached pdf.');
        mail.setHtmlBody(htmlBody);
        emails.add(mail);
        if(allRecords.allFilteredRecordsLst.size()>0 && allRecords.allFilteredRecordsLst!=null){
            Messaging.sendEmail(emails);
        }
        else {
            htmlBody = 'Hi ,'+currentUserFirstName+' '+currentUserLastName+'<br/><br/>'+'Greetings from Elixir.'+'<br/><br/>';
            htmlBody += 'This email is to notify that the <b>NO CLAIMS WERE DELAYED AS SPECFIED IN SYSTEM FOR TODAY</b>';
            htmlBody+=  '<br/><br/></div>'+'<br/>'+'<i>Note that this a system generated e-mail, please do not reply. In case of any discrepancies contact the administration.</i>'+'<br/></br>'+'Regards,'+'<br/>'+'Team Elixir'+'<br/></br>'+
                '<p style="font-size:12px;">DISCLAIMER: This e-mail message may contain confidential, proprietary or legally privileged information. It is confidential and may be legally privileged or protected by law. Unauthorized use, copying or disclosure of any part is strictly prohibited. If you are not the intended recipient, please contact the sender immediately and delete it from your system</p>';
            mail.setHtmlBody(htmlBody);
            emails.add(mail);
            Messaging.sendEmail(emails); 
        }

    }
}