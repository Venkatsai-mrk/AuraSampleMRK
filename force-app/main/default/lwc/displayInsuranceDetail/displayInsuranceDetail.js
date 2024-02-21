import { api, LightningElement, track } from 'lwc';
import sendmail from '@salesforce/apex/displayInsuranceCommunity.sendmail';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DisplayInsuranceDetail extends NavigationMixin(LightningElement) {
    userId = Id;
    @api parentId;
    emailStatus = '';
    organizationName = '';
    disabledButton = false;
    
    navToPage(){
        this[NavigationMixin.Navigate]({  
            type: 'standard__webPage',  
            attributes: {  
                url: '/vob/ElixirSuite__VOB__c/Default'
            }  
        },true);
    }

    requestUpdateHandler(event){
        var search = window.location.href;
        if (search) {
            sendmail({userId : this.userId}).then(result=>{
                if(result){
                    var resultData = JSON.parse(result);
                    console.log('inside requestUpdateHandler',resultData);
                    this.organizationName = resultData.OrganizationName;
                    this.emailStatus = resultData.status;
                    if(this.emailStatus == 'sent' && this.organizationName != null){
                        const eventToast = new ShowToastEvent({
                            title: 'Message',
                            message: `Request has been successfully sent. ${this.organizationName} will get in touch in the next 24 hours`,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(eventToast);
                        this.disabledButton = true;
                    }
                }
                else{
                    console.log('inside requestUpdateHandler');
                }
            }).catch(error=>{
                console.log('error inside requestUpdateHandler',error)
            })
        }
    }
}