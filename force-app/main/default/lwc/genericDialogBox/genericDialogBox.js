import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTestList from '@salesforce/apex/GenericDialogBox.records';

export default class Modal extends LightningElement {
    @api columns;
    @api filterClause;
    @api columnsInClause;
    @api objectApiName;
    @track data;
    count;
    selectedRows;
    _columns;
    error;
    searchKey = '';

    connectedCallback(){
        let columnsList = [];
        this.columns.forEach(column => {
            columnsList.push(column.fieldName);
        })
        this._columns = columnsList;
    }

    handleSearchKey(event) {
        var str = event.detail.value;
        this.searchKey = str.trim();
    }
    handleSearch() {
        console.log('this._columns '+this._columns);
            getTestList({ searchKey: this.searchKey,
                objName: this.objectApiName,
                columns : this._columns,
                columnsInClause : this.columnsInClause,
                filterClause : this.filterClause
                })
                .then((result) => {
                    var i = 0;
                    this.data = result;
                    this.count = result.length;
                })
                .catch((error) => {
                    this.error = error;
                    console.log('getTestList Function Call NOT Completed!!');
                    console.log('ERROR : ' + error.body.message);
                });
                /*else {
            // alert('Please select a lab before adding tests!');
            this.showErrorToast('Please select a lab before adding tests!');
            this.showModal = false;
        }*/
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

    getSelectedTestRecords() {
            var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
            this.selectedRows = selectedRecords;
            //Fire Custom Event
            // Creates the event with the data.
            const selectedEvent = new CustomEvent("selectedrecords", {
                detail: this.selectedRows
            });
            // Dispatches the event.
            if (this.selectedRows.length > 0) {
                this.dispatchEvent(selectedEvent);
            } else {
                this.showErrorToast('No Test Selected');
            }
        }
}