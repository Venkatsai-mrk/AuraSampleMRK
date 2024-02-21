import { LightningElement, track, wire, api } from 'lwc';
//import getObjectFields from '@salesforce/apex/LabOrderRecords.getObjectFields';
export default class FilterGridComponent extends LightningElement {
    showFilter = false;
    @api selectedField = '';
    @track selectedOperator = '';
    @track selectedTValue = '';
    @track fields = [];
    @api show() {
        window.console.log('Filter Dialogue Show Called');
        this.showFilter = true;
        this.handleGetFieldOption();
        // this.fieldOptions();
    }
    handleDialogClose() {
        this.handleClearAll();
        this.showFilter = false;
    }
    handleClearAll() {
        this.selectedField = '';
        this.selectedOperator = '';
        this.selectedTValue = '';

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
    handleFieldOption(event) {
        this.selectedField = event.detail.value;
        console.log('Inside Handle Field' + this.selectedField);

    }
    get operatorOptions() {
        var optionList = [{ value: '=', label: 'Equal to' }, { value: '!=', label: 'Not equals to' }, { value: 'LIKE', label: 'Contains' }, { value: '>', label: 'Greater than' }, { value: '<', label: 'Less than' }, { value: '<=', label: 'Less or equal' }, { value: '>=', label: 'Greater or equal' }];
        return optionList;
    }
    handleOperatorChange(event) {
        this.selectedOperator = event.detail.value;
        console.log('Inside Handle Operator' + this.selectedOperator);
    }
    handleFieldValue(event) {
        this.selectedTValue = event.detail.value;
        //console.log('Inside Handle Value' + selectedTValue);
    }
    handleApplyFilter() {
        let selectedFieldValue = this.selectedField;
        let selectedOperatorValue = this.selectedOperator;
        let selectedTextValue = this.selectedTValue;
        console.log('Inside Handle Apply Filter 1 :  ' + selectedFieldValue);
        console.log('Inside Handle Apply Filter 2 :  ' + selectedOperatorValue);
        console.log('Inside Handle Apply Filter 3 :  ' + selectedTextValue);
        //custom event
        const passEvent = new CustomEvent('filteraddition', {
            detail: { fieldValue: selectedFieldValue, OperatorValue: selectedOperatorValue, TextValue: selectedTextValue }
        });
        this.dispatchEvent(passEvent);
        this.handleClearAll();
        this.showFilter = false;
    }
}