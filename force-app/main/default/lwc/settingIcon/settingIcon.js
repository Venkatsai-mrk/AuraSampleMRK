import { LightningElement, api, wire, track } from 'lwc';
//import getObjectFields from '@salesforce/apex/LabOrderRecords.getObjectFields';
export default class SettingIcon extends LightningElement {
    @track nameSpace='ElixirSuite__';
    showSettingModel = false;
    @track selectedFields = [];
    @track fields = [];
    @api show() {
        window.console.log('Filter Dialogue Show Called');
        this.showSettingModel = true;
        this.handleGetFieldOption();
        // this.fieldOptions();
    }
    handleGetFieldOption() {
        getObjectFields()
            .then((result) => {
                //this.facilities = result;
                this.error = undefined;
                for (const [key, value] of Object.entries(result)) {
                    this.fields = [...this.fields, { value: key, label: value }];

                    // console.log(`${key}: ${value}`);
                }
                console.log('Map return Value @@@@@@@@@@' + JSON.stringify(this.fields));
            })
            .catch((error) => {
                this.error = error;
            });

    }
    get fieldOptions() {
        console.log('Inside FieldOption' + this.fields);
        return this.fields;
    }
    handelFieldsAdded(event) {
        var selectedRows = event.detail;
        console.log('Parent selectedRecord 1  ', selectedRows[0]);
        var i = 0;
        for (i = 0; i < selectedRows.length; i++) {

            var flag = 0;
            var j = 0;
            for (j = 0; j < this.fields.length; j++) {
                if (this.tests[j].value == selectedRows[i][this.nameSpace+'Test_Id__c']) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                this.tests = [...this.tests, { value: selectedRows[i][this.nameSpace+'Test_Id__c'], label: selectedRows[i][this.nameSpace+'Test_Name__c'] }];
            }
            if (!this.selectedTests.includes(selectedRows[i][this.nameSpace+'Test_Id__c'])) {
                this.selectedTests = [...this.selectedTests, selectedRows[i][this.nameSpace+'Test_Id__c']];
            }
        }

    }
    handleAddFields() {
        const passEvent = new CustomEvent('onsettingaddition', {
            detail: { settingfieldlist: selectedFields }
        });
        this.dispatchEvent(passEvent);
    }
    handleClear() {
        this.showSettingModel = false;
    }
}