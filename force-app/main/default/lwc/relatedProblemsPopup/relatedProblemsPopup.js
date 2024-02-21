// relatedProblemsPopup.js
import { LightningElement, api, wire, track } from 'lwc';
import getPatientProblems from '@salesforce/apex/DiagnosisController.getPatientProblems';
import saveDiagnosisAndProblem from '@salesforce/apex/DiagnosisController.saveDiagnosisAndProblem';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RelatedProblemsPopup extends LightningElement {
 
    @api allProblems = []; // Assuming you have a list of all available problems to choose from
    @api recordId;
    @api patientID;
    @api selectedProblems;


    columns = [
        // Other columns
        
        { label: 'Problem', fieldName: 'Name', type: 'text' },
         { label: 'Description', fieldName: 'ElixirSuite__Description__c', type: 'text' }
    ];

  
    // Handle Cancel button click
    handleCancel() {
        // Notify the parent component to close the popup
        this.dispatchEvent(new CustomEvent('cancel'));
    }
    connectedCallback() {
        console.log('recordId' + this.recordId);
        console.log('patientID' + this.patientID);
      
    }
    

  handleSave() {
    var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
    console.log('selectedRecords are ', selectedRecords);

    this.selectedProblems = selectedRecords;
console.log('selectedRecords this.selectedProblems ', this.selectedProblems);
    // Dispatches the event.
    if (this.selectedProblems.length > 0) {

       var problemIds = [];

        for (var i = 0; i < this.selectedProblems.length; i++) {
    var record = this.selectedProblems[i];
    if (record && record.Id) {
      problemIds.push(record.Id);
    }
  }
        console.log('selectedRecords problemIds ', JSON.stringify( problemIds));

        saveDiagnosisAndProblem({ diagnosisId: this.recordId, problemIds: problemIds })
            .then((result) => {
                // Handle success, e.g., show a toast message
                console.log('Record created successfully!');
this.dispatchEvent(new CustomEvent('save'));
            })
            .catch(error => {
                // Handle error, e.g., show a toast message with the error details
                this.showErrorToast('Error');
            });
    
        
    }
    


        else {
                   console.log('Inside Error @@@@@@@@@@@');
                   this.showErrorToast('No Problem Selected');
                   console.log('Inside Error @@@@@@@@@@@#################111');
               }

    }
   

showErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    @wire(getPatientProblems, { accId: '$patientID' })
    patientProblems({ error, data }) {
        if (data) {
            this.allProblems = data;
        } else if (error) {
            console.error('Error fetching patient problems', error);
        }
    }
}