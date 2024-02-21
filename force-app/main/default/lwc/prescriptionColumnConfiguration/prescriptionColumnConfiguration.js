import {LightningElement, wire,track,api  } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFields from '@salesforce/apex/PrescriptionColumnConfigurationClass.saveFields';
import getFieldsFromCustomSetting from '@salesforce/apex/PrescriptionColumnConfigurationClass.getFieldsFromCustomSetting';
import getPageLayoutFileds from '@salesforce/apex/PrescriptionColumnConfigurationClass.getPageLayoutFileds';
export default class PrescriptionColumnConfiguration extends LightningElement {
    objectApiName = 'ElixirSuite__Prescription_Order__c';
    isModalOpen=false;
    apexFields;
    @api hideButton;

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
objectInfo;

get fieldOptions() {
    const excludedFields = [
        'Name',
        'ElixirSuite__Drug_Name__c',
        'ElixirSuite__Reason_new__c',
        'ElixirSuite__Patient_SIG__c',
        'ElixirSuite__Refills__c',
        'ElixirSuite__Status_NC__c',
        'ElixirSuite__Archive_Status_NC__c',
        'ElixirSuite__IsEditButtonActive__c',
    ];

    if (this.objectInfo.data && this.objectInfo.data.fields) {
        console.log('recordtype', JSON.stringify(this.objectInfo.data.fields));

        const customFields = Object.values(this.objectInfo.data.fields)
            .filter(actualField =>
                this.apexFields.includes(actualField.apiName) &&
                !excludedFields.includes(actualField.apiName)
            )
            .map(field => ({
                label: field.label,
                value: field.apiName,
            }));

        console.log('Custom Fields (excluding references):', JSON.stringify(customFields));
        return customFields;
    }
    return [];
}


    fetchData() {
    getPageLayoutFileds({layoutName: 'ElixirSuite__Prescription_Order__c-ElixirSuite__NewCrop Prescription'})
        .then(apexFields => {
            console.log('Apex Fields:', JSON.stringify(apexFields));
            this.apexFields = apexFields;
        })
        .catch(error => {
            console.error('Error calling Apex method:', error);
        });
}
    connectedCallback() { 
         this.fetchData();
          this.fetchDataFromCustomSetting();
    }
    fetchDataFromCustomSetting() {
        getFieldsFromCustomSetting()
            .then(result => {
                // Remove duplicates and add fields to selectedFields
                const uniqueFields = [...new Set([...this.selectedFields, ...result])];
                this.selectedFields = uniqueFields;

                // Log the result to console (optional)
                console.log('Fields from custom setting:', JSON.stringify(result));
            })
            .catch(error => {
                // Handle errors (e.g., log to console)
                console.error('Error fetching fields from custom setting:', error);
            });
    }
    @track selectedFields = [];

    handleSelection(event) {
        this.selectedFields = event.detail.value;
        console.log('inside selection'+JSON.stringify(this.selectedFields));
    }

    saveFields() {
        if (this.selectedFields.length > 0) {
           if (this.selectedFields.length < 16){
            console.log('inside save'+JSON.stringify(this.selectedFields));
            // Call the Apex method to save the selected fields
            saveFields({ fields: this.selectedFields })
                .then(result => {
                    // Handle the result if needed
                    console.log('Result:', result);

                    // Display a success message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Selected fields saved successfully.',
                            variant: 'success',
                        })
                    );
               
                     this.dispatchEvent(new CustomEvent('save'));
                     console.log('Childlwc1');
                    this.cancel();
                    // Reset the selected fields after saving
                   
                    
                })
                .catch(error => {
                    // Handle the error
                    console.error('Error:', error);

                    // Display an error message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An error occurred while saving fields.',
                            variant: 'error',
                        })
                    );
                });
       } else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select only 10 fileds',
                    variant: 'error',
                })
            );
       }}else {
            // Display an error message if no fields are selected
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select at least one field.',
                    variant: 'error',
                })
            );
        }
    }
    cancel(){
        this.isModalOpen = false;
         this.fetchDataFromCustomSetting();
    }
     openModal() {
        this.isModalOpen = true;
    }
}