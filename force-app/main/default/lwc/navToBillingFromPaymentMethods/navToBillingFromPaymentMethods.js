import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavToBillingFromPaymentMethods extends NavigationMixin(LightningElement) {
    showBilling = false;
    showListView = false;

    connectedCallback() {
        var search = window.location.href;
        if(search.includes('ElixirSuite__Payment_Information__c')){
            this.showBilling = true;
            this.showListView = false;
        }
        else{
            this.showBilling = false;
            this.showListView = true;
        }
    }

    navToBillingPage(){
        this[NavigationMixin.Navigate]({  
            type: 'standard__webPage',  
            attributes: {  
                url: '/billing'
            }  
        },true);
    }

    navToListView(){
        this[NavigationMixin.Navigate]({  
            type: 'standard__webPage',  
            attributes: {  
                url: '/payment-information/ElixirSuite__Payment_Information__c/Default'
            }  
        },true);
    }
}