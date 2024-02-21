import { LightningElement, wire, track, api } from 'lwc';
import {subscribe,unsubscribe,MessageContext} from 'lightning/messageService';
import fetchRecordIdMC from '@salesforce/messageChannel/FetchLabRecordId__c';

export default class TableForLabOrder extends LightningElement {
    @api rId;
    subscription = null;
    
    @wire(MessageContext)
    messageContext;
    
    //function related to message channel for enabling subscription
    connectedCallback(){
        //subscribing to the Lightning Message Service Channel
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                fetchRecordIdMC,
                (message) => this.SetRecordId(message)
                
            );
        }
        //this.loadRelatedContacts("");
    }
    //function related to message channel for disabling subscription
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    
    @api recordId;

    @api createOrder;
    @api temp;
    //function to set the values coming from other component through message channels
    SetRecordId(message){
        console.log('message'+JSON.stringify(message));
      this.recordId = message.recordId;
      window.console.log("record id recieved" + this.recordId);
      
      
      window.console.log("createorder" + this.createOrder);
      
    }
    

    handleClose() {
        //setting the value of the recordId to null. So, that grid can be displayed again.
        this.recordId = null;
    }
    
}