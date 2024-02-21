import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProceduresCode from '@salesforce/apex/LabTestBundleController.getProceduresCode';

const columns = [
   { label: 'Procedure Name', fieldName: 'Name' }
];

//export default class AddMoreProcedure extends LightningElement {}
export default class Modal extends LightningElement {
    showModal = false;
    @track searchValue;
    @api selectedRows;
    @track count;

    @api show() {
        //window.console.log('Modal Show Called');
        // window.console.log('Child : LabID : ' + this.labid);
        this.showModal = true;
        this.searchKey = '';
        this.handleSearch();
    }
    handleDialogClose() {
        this.showModal = false;
    }
    columns = columns;
    @track data;
    error;

    //searchKey = '';
    handleSearchKey(event) {
        var str = event.detail.value;
        this.searchKey = str.trim();
        if (this.searchKey == '') {
            this.show();
        }
    }

    handleSearch() {
        getProceduresCode({ searchKey: this.searchKey })
            .then((response) => {
                //var i = 0;
                //this.facilities = result;
                this.error = undefined;
                this.data = response;
                this.count = response.length;
                //console.log('getTestList call completed : '+result);
            })
            .catch((error) => {
                this.error = error;
                //this.returnedOrderID = undefined;
                window.console.log('getDiagnosis Function Call NOT Completed!!');
                window.console.log('ERROR : ' + error.body.message);
            });

    }

    showSuccessToast(message) {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
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

    getSelectedDiagnosisRecords() {

            var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
            // console.log('selectedRecords are ', selectedRecords);
            // console.log('selectedRecords 1 ', selectedRecords[0].Test_Description__c);
            this.selectedRows = selectedRecords;
            //Fire Custom Event
            // Creates the event with the data.
            const selectedEvent = new CustomEvent("codesadded", {
                detail: this.selectedRows
            });

            // Dispatches the event.
            if (this.selectedRows.length > 0) {
                this.dispatchEvent(selectedEvent);
                this.handleDialogClose();
            } else {
                this.showErrorToast('No Procedure Code Selected');
            }
        }      
}