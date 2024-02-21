// medicalObjectList.js
import { LightningElement, wire, api,track } from 'lwc';

import getFieldsFromCustomSetting from '@salesforce/apex/DynamicModalComboBoxController.getFieldsFromCustomSetting';
import deleteRecords from '@salesforce/apex/DynamicModalComboBoxController.deleteRecords';
import fetchAccountSpecificVitals from '@salesforce/apex/FormRenderClass.fetchAccountSpecificVitals';
import getObjectFields from '@salesforce/apex/DynamicModalComboBoxController.getObjectFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class VitalListView extends LightningElement {
    columns = [];
    data = [];
    @api currentDateTime;
    @api patientID;
    @api disabled;
@track isLoading = false;
sortedBy;
    sortedDirection;
@api showConfirmWarning = false;
     @api rowIdToDelete;
    @api notesSpecificData;
    @api formUniqueId;

     get hasData() {
        return this.data && this.data.length > 0;
    }


    connectedCallback() {
        // Fetch data when the component is connected to the DOM
        this.fetchData();
    }

    @api
    callMethodInLwc3() {
this.isLoading = true;

        // Simulate an asynchronous operation
        setTimeout(() => {
            this.fetchData();

            // Set isLoading to false once the operation is complete
            this.isLoading = false;
        }, 3000);
        // Public method to trigger data fetching (can be called from another component)
        
    }
handleSort(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortedDirection = event.detail.sortDirection;
    // Implement your sorting logic and fetch data accordingly
    console.log( this.sortedBy+''+this.sortedDirection);
    this.fetchData();
}
   fetchData() {
    // Fetch data from server
    fetchAccountSpecificVitals({ acctId: this.patientID ,sortBy: this.sortedBy,sortDirection: this.sortedDirection, vitalIds: this.notesSpecificData.vitalData, formUniqueId : this.formUniqueId})
        .then(result => {
            for (let i = 0; i < result.length; i++) {
    // Format Start Time

    if(result[i].ElixirSuite__Start_Time__c !=null){
        let startDateTime = new Date(result[i].ElixirSuite__Start_Time__c);
        let startYear = startDateTime.getFullYear();
        let startMonth = String(startDateTime.getMonth() + 1).padStart(2, '0');
        let startDay = String(startDateTime.getDate()).padStart(2, '0');
        let startHours = String(startDateTime.getHours() % 12 || 12).padStart(2, '0');
        let startMinutes = String(startDateTime.getMinutes()).padStart(2, '0');
        let startAMPM = startDateTime.getHours() >= 12 ? 'PM' : 'AM';
        let formattedStartTime = `${startYear}-${startMonth}-${startDay}, ${startHours}:${startMinutes} ${startAMPM}`;

        result[i].ElixirSuite__Start_Time__c = formattedStartTime;
    }
    
    // Format End Time
    if(result[i].ElixirSuite__End_Time__c !=null) {
        let endDateTime = new Date(result[i].ElixirSuite__End_Time__c);
        let endYear = endDateTime.getFullYear();
        let endMonth = String(endDateTime.getMonth() + 1).padStart(2, '0');
        let endDay = String(endDateTime.getDate()).padStart(2, '0');
        let endHours = String(endDateTime.getHours() % 12 || 12).padStart(2, '0');
        let endMinutes = String(endDateTime.getMinutes()).padStart(2, '0');
        let endAMPM = endDateTime.getHours() >= 12 ? 'PM' : 'AM';
        let formattedEndTime = `${endYear}-${endMonth}-${endDay}, ${endHours}:${endMinutes} ${endAMPM}`;

        result[i].ElixirSuite__End_Time__c = formattedEndTime;
    }
}

            this.data = result;
                
        })
        .catch(error => {
            console.error('Error loading account data:', error);
        });

    this.fetchCustomSettingFields();
}
 

fetchCustomSettingFields() {
    Promise.all([getObjectFields(), getFieldsFromCustomSetting()])
        .then(([objectData, customSettingFields]) => {
            // Create a map to quickly look up the index of each custom setting field
            const customSettingFieldIndex = {};
            customSettingFields.forEach((field, index) => {
                customSettingFieldIndex[field] = index;
            });

            // Filter object fields based on custom setting fields and order them
            this.columns = objectData
                .filter(fieldInfo => customSettingFields.includes(fieldInfo.apiName))
.sort((a, b) => customSettingFieldIndex[a.apiName] - customSettingFieldIndex[b.apiName])
                .map(fieldInfo => ({
                    label: fieldInfo.label,
                    fieldName: fieldInfo.apiName,
                    type: 'text',
                    sortable: true,
                }));

            // Push delete button configuration into the columns array
            this.columns.push({
                type: 'button',
                fixedWidth: 100,
                typeAttributes: {
                    iconName: 'utility:delete',
                   
                    name: 'delete',
                    title: 'Delete Record',
                    disabled: this.disabled,
                    value: 'delete',
                   class: 'delete-button-class',
                },
            });
        })
        .catch(error => {
            console.error('Error fetching data:', error);
            // Handle specific error scenarios if needed
        });
}

 handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'delete') {
           this.showConfirmWarning = true;
             this.rowIdToDelete = row.Id;
            
        }
    }

    deleteRow(recordId) {
        deleteRecords({ recordIds: recordId })
            .then(result => {
                console.log('Delete Result:', result);
                this.fetchData();
               this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: result,
                            variant: 'success',
                        })
                    );
            })
            .catch(error => {
                console.error('Error deleting records:', error);
                this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error',
                        })
                    );
            });
            
    }

    handleVitalDelete() {
       const recordId = this.rowIdToDelete;
        this.showConfirmWarning = false;
        this.deleteRow(recordId);
    } 
    handleProblemCancel() {
        this.showConfirmWarning = false;
    }
}