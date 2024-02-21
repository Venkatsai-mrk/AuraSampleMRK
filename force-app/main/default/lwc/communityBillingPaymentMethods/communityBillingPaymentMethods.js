import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; 

export default class CommunityBillingPaymentMethods extends NavigationMixin(LightningElement) {
    connectedCallback(){
        this.navToPage();
    }

    navToPage(){
        this[NavigationMixin.Navigate]({  
            type: 'standard__webPage',  
            attributes: {  
                url: '/payment-information/ElixirSuite__Payment_Information__c/Default'
            }  
        },true);
    }
}