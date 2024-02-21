/* @description       : fullCalendarByLwc Controller
* @author            : Srihari
* @last modified on  : 13-01-2022
* @last modified by  : Srihari
*/
public with sharing class MyCalendarController {
    @AuraEnabled
    public static List<AppointmentWrapper> getMyAppointments() {
        List<Event> appointmentList = [select Id, Subject, 
                StartDateTime, EndDateTime from Event WITH SECURITY_ENFORCED order by StartDateTime Limit 100];
        List<AppointmentWrapper> wrapper = new List<AppointmentWrapper>();
        for(Event appointment : appointmentList) {
            wrapper.add(new AppointmentWrapper(appointment.Subject,
                                                appointment.StartDateTime, 
                                                appointment.EndDateTime,
                                                appointment.Id));    
        }
        return wrapper;
    }
}