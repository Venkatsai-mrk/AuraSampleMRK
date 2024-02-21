/*Author name           :  Shwetha K J
* Purpose               :  Sending notifications to user if the claim in the same status for more number of days.
* Schedule              :  Scheduling on the basis of days
* Test Class            :  SendNotificationsForClaims_Schedule_Test
* Batch class       	:  SendNotificationsForClaims
* Created Date          :  14-Oct-2020
* Last Modified Date    :  16-Oct-2020
*/
global  with sharing class SendNotificationsForClaims_Schedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        SendNotificationsForClaims reCls = new SendNotificationsForClaims();
        DataBase.executeBatch(reCls);    
    }
}