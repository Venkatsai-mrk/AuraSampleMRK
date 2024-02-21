import { LightningElement, wire, track ,api} from 'lwc';
import getFieldsFromCustomSetting from '@salesforce/apex/DynamicModalComboBoxController.getFieldsFromCustomSetting';
import createRecord from '@salesforce/apex/DynamicModalComboBoxController.createRecord';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ExaminComponent extends LightningElement {
    @track isModalOpen = false;
    @track selectedFields = [];
   @track listViewConfigs = [];
    @track fieldValues = {};
    @api patientID;
    objectApiName = 'ElixirSuite__Medical_Examination__c';
    @api notesSpecificData; 
    @api formUniqueId;

   
    handleCancelClick(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

connectedCallback() {
        this.handleData();
    }

      @api callMethodInLwc2() {
      
         this.handleData();
    }


    handleData() {
                getFieldsFromCustomSetting()
            .then(customSettingFields => {
                console.log('Matching Fields:', JSON.stringify(customSettingFields));

                // Update listViewConfigs if needed
                this.listViewConfigs = customSettingFields;

                // Other logic if needed
            })
            .catch(customSettingError => {
                // Handle error from getFieldsFromCustomSetting
                console.error('Error fetching custom setting fields:', customSettingError);
            });
    }



    // Handle input value change
    handleInputChange(event) {
        
         const fieldName = event.target.fieldName;
        const fieldValue = event.detail.value;

        this.fieldValues[fieldName] = fieldValue;
       
    }


    // Save button click handler
    handleSaveClick(){
       
        const firstKey = Object.keys(this.fieldValues)[0];
        const value = this.fieldValues[firstKey];

console.log(value);
        if(Object.keys(this.fieldValues).length > 0){
        // Pass the dynamic field values to Apex for saving
        createRecord({ fieldValues: this.fieldValues, patientID: this.patientID, formUniqueId: this.formUniqueId })
            .then(result => {
               if (result.isSuccess) {
                this.notesSpecificData = {...this.notesSpecificData,vitalData: result.lstVitalIds};
                let vitalData = this.notesSpecificData;
               // Display a success message
                // Display a success message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Saved Record Successfully.',
                            variant: 'success',
                        })
                    );
                    this.dispatchEvent(new CustomEvent('updatevitalList', { detail: {vitalData} }));
                    this.handleCancelClick();
                     
                }
                 else {
                // Handle failure, e.g., show an error message
                console.error('Error creating record:', result.errorMessage);
                this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result.errorMessage,
                            variant: 'error',
                        })
                    );
            }
            })
            .catch(error => {
                // Display an error message
                 console.error('Error:', error);

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An error is occurring when attempting to save the record.',
                            variant: 'error',
                        })
                    );
            });}
            else{
                        this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Ensure that at least one input field is filled',
                            variant: 'error',
                        })
                    );
            }
    }

}