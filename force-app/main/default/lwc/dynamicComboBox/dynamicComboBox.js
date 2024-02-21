// dynamicComboBox.js
import { LightningElement, wire,track,api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFields from '@salesforce/apex/DynamicModalComboBoxController.saveFields';
import getFieldsFromCustomSetting from '@salesforce/apex/DynamicModalComboBoxController.getFieldsFromCustomSetting';
import getPageLayoutFileds from '@salesforce/apex/DynamicModalComboBoxController.getPageLayoutFileds';

export default class DynamicComboBox extends LightningElement {
    objectApiName = 'ElixirSuite__Medical_Examination__c';
    recordTypeId;
        isModalOpen=false;
    apexFields;
   @api hideButton;

   @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo;

    get fieldOptions() {
        if (this.objectInfo.data) {
            console.log('recordtype',JSON.stringify(this.objectInfo.data.fields));
            const customFields = Object.values(this.objectInfo.data.fields)
            .filter(actualField => this.apexFields.includes(actualField.apiName) && !(actualField.dataType === 'Reference'))
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
    getPageLayoutFileds({layoutName: 'ElixirSuite__Medical_Examination__c-ElixirSuite__ElixirDev_VitalFieldsOnForms'})
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
  console.log('hideButton',this.hideButton);
        // Use setTimeout to add fields after 1 second
        setTimeout(() => {
            this.selectedFields.push("ElixirSuite__Blood_Pressure_Systolic__c");
                        this.fetchDataFromCustomSetting();
            console.log('Interval stopped after 1 second.');
        }, 1000);
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
           if (this.selectedFields.length < 13){
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
                    message: 'Please select only 12 fileds',
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
         this.selectedFields = []
          this.selectedFields.push("ElixirSuite__Blood_Pressure_Systolic__c");
            this.selectedFields.push("ElixirSuite__End_Time__c");

            this.fetchDataFromCustomSetting();
    }
     openModal() {
        this.isModalOpen = true;
    }
}