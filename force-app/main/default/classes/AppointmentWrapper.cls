/* @description      : fullCalendarByLwc wrapper
* @author            : Srihari
* @last modified on  : 13-01-2022
* @last modified by  : Srihari
*/
public with sharing class AppointmentWrapper {
    @AuraEnabled
    public String subject{get;set;}
    @AuraEnabled
    public String startTime{get;set;}
    @AuraEnabled
    public String endTime{get;set;}
    @AuraEnabled
    public String recordId{get;set;}

    public AppointmentWrapper(String subject, Datetime startTime, Datetime endTime, String recordId) {
        this.subject=subject;
        this.startTime = String.valueOf(startTime);
        this.endTime = String.valueOf(endTime);
        this.recordId = recordId;
    }
}