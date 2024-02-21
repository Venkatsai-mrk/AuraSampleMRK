import { LightningElement, api, track } from 'lwc';
import sendEmailMethod from '@salesforce/apex/activeMedicationApex.sendEmailMethod';
//import sendEmail from '@salesforce/apex/activeMedicationApex.sendEmail';
//import sendEmail from '@salesforce/apex/PortalEmailRecipientsUtility.fetchPatientPortalMedicationRecipients';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DisplayActiveMedication extends NavigationMixin(LightningElement) {
    parameters = {};
    @api parentId;
    userId = Id;
    @track medicationRecords =[];
    prescriptionId;
    @track buttonDisabled=false;
    
    navToPage(){
        this[NavigationMixin.Navigate]({  
            type: 'standard__webPage',  
            attributes: {  
                url: '/prescription-order/ElixirSuite__Prescription_Order__c/Default'
            }  
        },true);
    }

    requestRefillHandler(event){
        var search = window.location.href;
       
        if (search) {
            //this.recordId = search.substring(search.indexOf('prescription-order/')+19,100);
            //console.log('recordId update', this.recordId);
            sendEmailMethod({userId : this.userId, prescriptionId : this.parentId}).then(result=>{
                var data = result;
                if(data){
                    var resultData = JSON.parse(data);
                    this.medicationRecords = resultData.objPO;
                    console.log('inside requestUpdateHandler medicationRecords',this.medicationRecords);
                    this.emailStatus = resultData.status;
                    console.log('inside requestUpdateHandler emailStatus',this.emailStatus);
                    console.log('inside requestRefillHandler12',data);
                    if(this.emailStatus == 'sent'){
                        const eventToast = new ShowToastEvent({
                            title: 'Message',
                            message: `Refill request has been sent successfully!`,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(eventToast);
                    this.buttonDisabled=true;
                }
            }
                else{
                    console.log('inside requestRefillHandler');
                }
            }).catch(error=>{
                console.log('error inside requestRefillHandler',error.message);
            })
        }
    }
}