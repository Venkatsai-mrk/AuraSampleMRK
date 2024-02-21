/*Author name           :  Shwetha K J
* Purpose               :  Sending notifications to user if the claim in the same status for more number of days.
* Schedule              :  Scheduling on the basis of days
* Test Class            :  SendNotificationsForClaims_Test
* Schedular class       :  SendNotificationsForClaims_Schedule
* Created Date          :  13-Oct-2020
* Last Modified Date    :  16-Oct-2020
*/
global   with sharing  class SendNotificationsForClaims implements Database.Batchable<sObject>,database.stateful  {
    global List<Claim__c> parentclaimListToProcess = new List<Claim__c>();
    global ClaimNotificationParameters__c statusParametres = [SELECT ID,Claringhouse_Accepted__c,Clearinghouse_Accepted_Records_Days__c,Clearinghouse_Rejected__c,Payer_Accepted__c,
                                                              Clearinghouse_Rejected_Records_Days__c,Ready_to_submit__c,
                                                              Send_to_ClaringHouse__c,
                                                              Payer_Accepted_Records_Days__c,Ready_to_submit_Records_Days__c,
                                                              Denied_Notify_Days__c,Denied_Records_Days__c,
                                                              Payer_Rejected_Notify_Days__c,Payer_Rejected_Records_Days__c,
                                                              Underpaid_Notify_Days__c,Underpaid_Records_Days__c,
                                                              Send_to_Clearinghouse_Records_Days__c FROM ClaimNotificationParameters__c LIMIT 1];
    global Decimal CHAccepted ;
    global Decimal CHRejected ;
    global Decimal payerAccepted ;
    global Decimal readyToSubmit ;
    global String currentStatusExecution = 'Ready to submit';
    global Decimal sendToClearingHouse ;
    
    global Decimal payerRejected ;
    global Decimal underPaid ;
    global Decimal denied ;
    
    global MailWrapper allDataForMail = new MailWrapper();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Accept_Assignment__c,Additional_Claim_Information__c,Account__r.Name,Amount_Paid__c,Any_Other_Health_Benefit_Plan__c,Auto_Accident_Related__c,Batch_Id__c,Billing_Provider_Address_1__c,Billing_Provider_Address_2__c,Billing_Provider_City__c,Billing_Provider_Info__c,Billing_Provider_Legacy_ID_Provider_Lice__c,Billing_Provider_Name__c,Billing_Provider_State__c,Billing_Provider_Taxonomy__c,Billing_Provider_Tax_ID_Type__c,Billing_Provider_Tax_ID__c,Billing_Provider_Zip__c,Bill_Phone__c,bill_taxid__c,Charge_Amount__c,Claimid__c,Claim_Codes__c,Claim_Md_Id__c,Claim_Status__c,CreatedById,CreatedDate,Dates_Patient_Unable_To_Work__c,Date_Of_Current_Illness__c,Diagnosis_Reference__c,Employment_Related__c,fdos__c,Federal_Tax_Id_Number__c,File_Id__c,File_Name__c,First_Diagnosis__c,From_Date__c,Hospitalization_Dates__c,Id,Insurance_Number__c,Insurance_Plan_Name__c,Insurance_Type__c,Insured_Address__c,Insured_Authorized_Person_Signature__c,Insured_City__c,Insured_Country_Code__c,Insured_DOB__c,Insured_Policy__c,Insured_Sex__c,Insured_State__c,Insured_s_ID_Number__c,Insured_s_Name__c,Insured_Telephone__c,Insured_Zipcode__c,IsDeleted,isRecordInReadyToSubmitStatus__c,LastModifiedById,LastModifiedDate,Message__c,Name,Name_of_referring_provider_Other_sourc__c,NPI__c,Other_Claim_Id__c,Other_Date__c,Other_Insurance_Plan_Name__c,Other_Insured_s_Name__c,Other_Insured_s_Policy_Group_Number__c,Other_Payer_Name__c,Outside_Lab__c,OwnerId,Account__c,Patient_Condition_Related_To_Accident__c,Patient_Condition_Related_To_Employment__c,Patient_Condition_to_Other_Accident__c,Patient_Country_Code__c,Patient_DOB__c,Patient_First_Name__c,Patient_Last_Name__c,Patient_Name__c,Patient_Relationship_to_Insured__c,Patient_Sex__c,Patient_Signature__c,Patient_s_Address__c,Patient_s_City__c,Patient_s_Phone__c,Patient_s_State__c,Patient_s_Zipcode__c,Payerid__c,Payer_ID__c,Payer_Order__c,Pcn__c,Place_of_Service__c,Procedure_Code__c,RecordTypeId,Referring_Physician_Signature__c,Reserved_For_NUCC_Use1__c,Reserved_For_NUCC_Use2__c,Reserved_For_NUCC_Use3__c,Resubmission_Code__c,Sender_Icn__c,Sender_Id__c,Sender_Name__c,Service_Facility_Location_Information__c,status__c,Thru_Date__c,Total_Adjustment_Amount__c,Total_Allowed_Amount__c,Total_Amount_Paid_By_Insurance__c,Total_Charge__c,Total_Patient_Responsibility__c,Units__c FROM Claim__c'
            
        );
    }
    global void execute(Database.BatchableContext bc, List<Claim__c> scope){
        if(String.isNotBlank(String.valueOf(statusParametres))){
            CHAccepted = statusParametres.Clearinghouse_Accepted_Records_Days__c;
            CHRejected = statusParametres.Clearinghouse_Rejected_Records_Days__c;
            payerAccepted = statusParametres.Payer_Accepted_Records_Days__c;
            readyToSubmit = statusParametres.Ready_to_submit_Records_Days__c;
            sendToClearingHouse = statusParametres.Send_to_Clearinghouse_Records_Days__c;
            
            payerRejected = statusParametres.Payer_Rejected_Records_Days__c;
            underPaid = statusParametres.Underpaid_Records_Days__c;
            denied = statusParametres.Denied_Records_Days__c;
                
            allDataForMail.clHouseAccepted = statusParametres.Clearinghouse_Accepted_Records_Days__c;
            allDataForMail.payAccepted = statusParametres.Payer_Accepted_Records_Days__c;
            allDataForMail.rdyToSubmit = statusParametres.Ready_to_submit_Records_Days__c;
            allDataForMail.sendToClHouse = statusParametres.Send_to_Clearinghouse_Records_Days__c;
            allDataForMail.clHouseRejected = statusParametres.Clearinghouse_Rejected_Records_Days__c;
            
            allDataForMail.payerRejected = statusParametres.Payer_Rejected_Records_Days__c;
            allDataForMail.underPaid = statusParametres.Underpaid_Records_Days__c;
            allDataForMail.denied = statusParametres.Denied_Records_Days__c;
        }
        
        List<Claim__c> claimsToProcess = new List<Claim__c>();
        for (Claim__c claimRecordsToFilter : scope) {
            Integer statusRecordQuo = 0;
            //If the claim is in ready to submit status for more than X number of days, email will be sent.
            if(claimRecordsToFilter.Claim_Status__c=='Ready to Submit'){
                //  allDataForMail.rdyToSubmitLstRecords.add(claimRecordsToFilter);
                statusRecordQuo = getStatusQuo(claimRecordsToFilter.LastModifiedDate);
                if(statusRecordQuo >=readyToSubmit){
                    allDataForMail.rdyToSubmitLstRecords.add(claimRecordsToFilter);
                    allDataForMail.allFilteredRecordsLst.add(claimRecordsToFilter); 
                }
            }
            //If the claim is in Sent to Clearing house status for more than X number of days, email will be sent.
            else if(claimRecordsToFilter.Claim_Status__c=='Sent to Clearing house'){
                //  allDataForMail.sendToClHouseLstRecords.add(claimRecordsToFilter);
                statusRecordQuo = getStatusQuo(claimRecordsToFilter.LastModifiedDate);
                if(statusRecordQuo >=sendToClearingHouse){
                    allDataForMail.sendToClHouseLstRecords.add(claimRecordsToFilter);
                    allDataForMail.allFilteredRecordsLst.add(claimRecordsToFilter); 
                }  
            }
            //If the claim is in Payer accepted status for more than X number of days, email will be sent.
            else if(claimRecordsToFilter.Claim_Status__c=='Payer Accepted'){
                //  allDataForMail.payAcceptedLstRecords.add(claimRecordsToFilter);
                statusRecordQuo = getStatusQuo(claimRecordsToFilter.LastModifiedDate);
                if(statusRecordQuo >=payerAccepted){
                    allDataForMail.payAcceptedLstRecords.add(claimRecordsToFilter);
                    allDataForMail.allFilteredRecordsLst.add(claimRecordsToFilter); 
                }  
            }
            //If the claim is in Clearing house accepted status for more than X number of days, email will be sent.
            else if(claimRecordsToFilter.Claim_Status__c=='Clearing house accepted'){
                //   allDataForMail.clHouseAcceptedLstRecords.add(claimRecordsToFilter);
                statusRecordQuo = getStatusQuo(claimRecordsToFilter.LastModifiedDate);
                if(statusRecordQuo >=CHAccepted){
                    allDataForMail.clHouseAcceptedLstRecords.add(claimRecordsToFilter);
                    allDataForMail.allFilteredRecordsLst.add(claimRecordsToFilter); 
                }  
            }
            //EB-139 - If the claim is in payer rejected status for more than X number of days, email will be sent.
            else if(claimRecordsToFilter.Claim_Status__c=='Payer Rejected'){
                //   allDataForMail.clHouseAcceptedLstRecords.add(claimRecordsToFilter);
                statusRecordQuo = getStatusQuo(claimRecordsToFilter.LastModifiedDate);
                if(statusRecordQuo >=payerRejected){
                    allDataForMail.payerRejectedLstRecords.add(claimRecordsToFilter);
                    allDataForMail.allFilteredRecordsLst.add(claimRecordsToFilter); 
                }  
            }
            //EB-262 - If the claim is in underpaid status for more than X number of days, email will be sent.
            else if(claimRecordsToFilter.Claim_Status__c=='Underpaid'){
                //   allDataForMail.clHouseAcceptedLstRecords.add(claimRecordsToFilter);
                statusRecordQuo = getStatusQuo(claimRecordsToFilter.LastModifiedDate);
                if(statusRecordQuo >=underPaid){
                    allDataForMail.underpaidLstRecords.add(claimRecordsToFilter);
                    allDataForMail.allFilteredRecordsLst.add(claimRecordsToFilter); 
                }  
            }
            //EB-263 - If the claim is Denied status for more than X number of days, email will be sent.
            else if(claimRecordsToFilter.Claim_Status__c=='Denied'){
                //   allDataForMail.clHouseAcceptedLstRecords.add(claimRecordsToFilter);
                statusRecordQuo = getStatusQuo(claimRecordsToFilter.LastModifiedDate);
                if(statusRecordQuo >=denied){
                    allDataForMail.deniedLstRecords.add(claimRecordsToFilter);
                    allDataForMail.allFilteredRecordsLst.add(claimRecordsToFilter); 
                }  
            }
            //If the claim is in Clearing house rejected status for more than X number of days, email will be sent.
            else if(claimRecordsToFilter.Claim_Status__c=='Clearing house rejected'){
                //   allDataForMail.clHouseRejectedLstRecords.add(claimRecordsToFilter);
                statusRecordQuo = getStatusQuo(claimRecordsToFilter.LastModifiedDate);
                if(statusRecordQuo >=CHRejected){
                    allDataForMail.clHouseRejectedLstRecords.add(claimRecordsToFilter);
                    allDataForMail.allFilteredRecordsLst.add(claimRecordsToFilter); 
                } 
            }
            
            claimsToProcess.add(claimRecordsToFilter);
        }
        parentclaimListToProcess.addAll(claimsToProcess);
    }    
    global void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        if( allDataForMail.allFilteredRecordsLst!=null &&  allDataForMail.allFilteredRecordsLst.size()>0){
            String finalStringifiedList = JSON.serialize(parentclaimListToProcess);
            sendPdfNotificationForClaimRecords(finalStringifiedList,parentclaimListToProcess,'',allDataForMail);
            
        }
    }
    public class MailWrapper {
        public Decimal clHouseAccepted;
        public Decimal clHouseRejected;
        public Decimal payAccepted;
        public Decimal rdyToSubmit;
        public Decimal sendToClHouse;
        
        public Decimal payerRejected;
        public Decimal underPaid;
        public Decimal denied;
        
        public List<Claim__c> payerRejectedLstRecords = new List<Claim__c>();
        public List<Claim__c> underpaidLstRecords = new List<Claim__c>();
        public List<Claim__c> deniedLstRecords = new List<Claim__c>();
        
        public List<Claim__c> clHouseAcceptedLstRecords = new List<Claim__c>();
        public List<Claim__c> clHouseRejectedLstRecords= new List<Claim__c>();
        public List<Claim__c> payAcceptedLstRecords= new List<Claim__c>();
        public List<Claim__c> rdyToSubmitLstRecords= new List<Claim__c>();
        public List<Claim__c> sendToClHouseLstRecords= new List<Claim__c>();
        public List<Claim__c> allFilteredRecordsLst= new List<Claim__c>();
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
    public static Integer getStatusQuo(DateTime recordRecordLastModifiedDate){
        Date startDate = Date.valueOf(recordRecordLastModifiedDate);
        Date dueDate = System.today();
        Integer numberDaysDue = startDate.daysBetween(dueDate);
        return numberDaysDue;
    }
    public static void sendPdfNotificationForClaimRecords(String record,List<Claim__c> claimRecords,String sta,MailWrapper allRecords){
        System.debug('record to send mail '+allRecords);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Boolean emaiNotExistsOrDirtyEmail = false;
        Boolean allowProceed = true;
        List<String> allEmailAdd = new List<String>();
        List<User> getAllUsers  = [select Id,Username,Email,profile.name,UserRole.Name,UserRole.id from user where profile.name='System Administrator' or UserRole.Name='Billing Team'];
         		// THIS LOOP INCLUDES EMAIL IDs OF ALL THE  USERS IN THE ROLES OF BILLING (TBD), FOR NOW SYS ADMIN AND ROLES ARE QUERIED
        		// FOR TESTING AND TO AVOID SINGLE EMAIL LIMIT HIT 2 OF THE EMAIL IDs ARE HARDCODED, ONE IS OF THE DEVELOPER 2ND OF TESTER
        		// MAY COMMENT THE HARDCODED EMAIL IDs ONCE THE ROLES ARE IN.
        for(User forEmail : getAllUsers) {          
            if(validateEmail(forEmail.Email)){
                allEmailAdd.add(forEmail.Email);
            }                      
        }    
        //allEmailAdd.add('shwetha.kj@mirketa.com');
       // allEmailAdd.add('tanveer.ahmed@mirketa.com');
        String currentUserFirstName = UserInfo.getFirstName();
        String currentUserLastName = UserInfo.getLastName();        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.setSaveAsActivity( false );
        mail.setUseSignature(false);
        mail.setToAddresses(allEmailAdd);
        System.debug('buffer array '+mail);
        mail.setSubject('CLAIM RECORDS || DELAYED STATUSES');
        string htmlBody = '<div> ';
        Integer count  = 1;
        htmlBody += 'Hi '+currentUserFirstName+' '+currentUserLastName+'<br/><br/>'+'Greetings from Elixir.'+'<br/><br/>'+'This email is to notify that<br/>';
        if(allRecords.rdyToSubmitLstRecords.size()>0 && allRecords.rdyToSubmitLstRecords!=null){
            htmlBody += 'The following list of claims are in the status '+'<b>Ready to Submit</b>'+' for '+allRecords.rdyToSubmit+' number of days.'+'<br/></br>'+'<table style="width:100%;" border="1" cellspacing="1px" cellpadding="1px">'+
                '<tr><td> ' + 'SNO.' + '</td>'+'<td> Claim ID </td>'+'<td> Patient Name </td>'+'<td>Date Of Creation</td>'+'</tr>' ;
            for(Claim__c c : allRecords.rdyToSubmitLstRecords){  
                Datetime dt = (Datetime)c.CreatedDate; 
                String d = dt.format('dd/MM/yyyy');
                htmlBody += '<tr><td> ' + count + '</td><td>'+ c.Name+'</td><td>'+c.Account__r.Name+'</td><td> '+d+' </td></tr>';
                count++;
            }
            htmlBody += '</table>';
        }
        if(allRecords.clHouseAcceptedLstRecords.size()>0 && allRecords.clHouseAcceptedLstRecords!=null){
            htmlBody +='<br/><p>The following list of claims are in the status <b>Clearing House Accepted</b>  for '+allRecords.clHouseAccepted+' number of days</p>'+'<br/></br>'+
                '<table style="width:100%;" border="1" cellspacing="1px" cellpadding="1px">'+
                '<tr><td> ' + 'SNO.' + '</td>'+'<td> Claim ID </td>'+'<td> Patient Name </td>'+'<td>Date Of Creation</td>'+'</tr>' ;
            Integer countClAccepted = 1;   
            for(Claim__c c : allRecords.clHouseAcceptedLstRecords){
                htmlBody += '<tr><td> ' + countClAccepted + '</td><td>'+ c.Name+'</td><td>'+c.Account__r.Name+'</td><td>'+c.CreatedDate+' </td></tr>';
                countClAccepted++;
            }  
            htmlBody+=   '</table>';
        }
        if(allRecords.clHouseRejectedLstRecords.size()>0 && allRecords.clHouseRejectedLstRecords!=null){
            htmlBody +='<br/><p>The following list of claims are in the status <b>Clearing House Rejected</b>  for '+allRecords.clHouseRejected+' number of days</p>'+'<br/></br>'+
                '<table style="width:100%;" border="1" cellspacing="1px" cellpadding="1px">'+
                '<tr><td> ' + 'SNO.' + '</td>'+'<td> Claim ID </td>'+'<td> Patient Name </td>'+'<td>Date Of Creation</td>'+'</tr>' ;
            Integer countClRejected = 1;  
            for(Claim__c c : allRecords.clHouseRejectedLstRecords){
                Integer baseCount = count++;   
                htmlBody += '<tr><td> ' + countClRejected + '</td><td>'+ c.Name+'</td><td>'+c.Account__r.Name+'</td><td> '+c.CreatedDate+' </td></tr>';
                countClRejected++;
            }  
            htmlBody+=   '</table>';
        }
        //Email template is configured to send an email.
        if(allRecords.payerRejectedLstRecords.size()>0 && allRecords.payerRejectedLstRecords!=null){
            htmlBody +='<br/><p>The following list of claims are in the status <b> Payer Rejected</b>  for '+allRecords.clHouseRejected+' number of days</p>'+'<br/></br>'+
                '<table style="width:100%;" border="1" cellspacing="1px" cellpadding="1px">'+
                '<tr><td> ' + 'SNO.' + '</td>'+'<td> Claim ID </td>'+'<td> Patient Name </td>'+'<td>Date Of Creation</td>'+'</tr>' ;
            Integer countPayerRejected = 1;  
            for(Claim__c c : allRecords.payerRejectedLstRecords){
                Integer baseCount = count++;   
                htmlBody += '<tr><td> ' + countPayerRejected + '</td><td>'+ c.Name+'</td><td>'+c.Account__r.Name+'</td><td> '+c.CreatedDate+' </td></tr>';
                countPayerRejected++;
            }  
            htmlBody+=   '</table>';
        }
        if(allRecords.underpaidLstRecords.size()>0 && allRecords.underpaidLstRecords!=null){
            htmlBody +='<br/><p>The following list of claims are in the status <b>Underpaid</b>  for '+allRecords.clHouseRejected+' number of days</p>'+'<br/></br>'+
                '<table style="width:100%;" border="1" cellspacing="1px" cellpadding="1px">'+
                '<tr><td> ' + 'SNO.' + '</td>'+'<td> Claim ID </td>'+'<td> Patient Name </td>'+'<td>Date Of Creation</td>'+'</tr>' ;
            Integer countUnderpaid = 1;  
            for(Claim__c c : allRecords.underpaidLstRecords){
                Integer baseCount = count++;   
                htmlBody += '<tr><td> ' + countUnderpaid + '</td><td>'+ c.Name+'</td><td>'+c.Account__r.Name+'</td><td> '+c.CreatedDate+' </td></tr>';
                countUnderpaid++;
            }  
            htmlBody+=   '</table>';
        }
        if(allRecords.deniedLstRecords.size()>0 && allRecords.deniedLstRecords!=null){
            htmlBody +='<br/><p>The following list of claims are in the status <b>Denied</b>  for '+allRecords.clHouseRejected+' number of days</p>'+'<br/></br>'+
                '<table style="width:100%;" border="1" cellspacing="1px" cellpadding="1px">'+
                '<tr><td> ' + 'SNO.' + '</td>'+'<td> Claim ID </td>'+'<td> Patient Name </td>'+'<td>Date Of Creation</td>'+'</tr>' ;
            Integer countDenied = 1;  
            for(Claim__c c : allRecords.deniedLstRecords){
                Integer baseCount = count++;   
                htmlBody += '<tr><td> ' + countDenied + '</td><td>'+ c.Name+'</td><td>'+c.Account__r.Name+'</td><td> '+c.CreatedDate+' </td></tr>';
                countDenied++;
            }  
            htmlBody+=   '</table>';
        }
        
        if(allRecords.payAcceptedLstRecords.size()>0 && allRecords.payAcceptedLstRecords!=null){
            htmlBody +='<br/><p>The following list of claims are in the status <b>Payer Accepted</b> for '+allRecords.payAccepted+' number of days</p>'+'<br/></br>'+
                '<table style="width:100%;" border="1" cellspacing="1px" cellpadding="1px">'+
                '<tr><td> ' + 'SNO.' + '</td>'+'<td> Claim ID </td>'+'<td> Patient Name </td>'+'<td>Date Of Creation</td>'+'</tr>' ;
            Integer countPayAccepted = 1; 
            for(Claim__c c : allRecords.payAcceptedLstRecords){
                Integer baseCount = count++;   
                htmlBody += '<tr><td> ' + countPayAccepted + '</td><td>'+ c.Name+'</td><td>'+c.Account__r.Name+'</td><td>'+c.CreatedDate+' </td></tr>';
                countPayAccepted++;
            }  
            htmlBody+=   '</table>';
        }
        if(allRecords.sendToClHouseLstRecords.size()>0 && allRecords.sendToClHouseLstRecords!=null){
            htmlBody +='<br/><p>The following list of claims are in the status <b>Send to ClearingHouse</b>  for '+allRecords.sendToClHouse+' number of days</p>'+'<br/></br>'+
                '<table style="width:100%;" border="1" cellspacing="1px" cellpadding="1px">'+
                '<tr><td> ' + 'SNO.' + '</td>'+'<td> Claim ID </td>'+'<td> Patient Name </td>'+'<td>Date Of Creation</td>'+'</tr>' ;
            Integer countSendToClHouse = 1; 
            for(Claim__c c : allRecords.sendToClHouseLstRecords){
                Integer baseCount = count++;   
                htmlBody += '<tr><td> ' + countSendToClHouse + '</td><td>'+ c.Name+'</td><td>'+c.Account__r.Name+'</td><td>'+c.CreatedDate+' </td></tr>';
                countSendToClHouse++;
            }  
            htmlBody+=   '</table>';
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