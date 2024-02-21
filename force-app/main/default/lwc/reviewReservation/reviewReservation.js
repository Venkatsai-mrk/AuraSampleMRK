import { LightningElement, api, track, wire } from 'lwc';
import getAccountDetails from '@salesforce/apex/ReviewReservationController.getAccountDetails';
import getLocationDetails from '@salesforce/apex/ReviewReservationController.getLocationDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecord from '@salesforce/apex/CreateReservation.saveReservationData';
import Reservation_Schedule_Reservation_Type from '@salesforce/label/c.Reservation_Schedule_Reservation_Type';
import RESERVATION_OBJECT from '@salesforce/schema/Reservation__c'
import RESERVATION_TYPE_FIELD from '@salesforce/schema/Reservation__c.Reservation_Type__c';
import { getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi'



export default class ReviewReservation extends LightningElement {
    @track isButtonDisabled =false;
    @api accountId;
    @api startDate;
    @api endDate;
    @api billableEntity;
    @api selectedBedIds;
    @api selectedValue
    accountName;
    accountBirthDate;
    accountPhone;
    accountEmail;
    @track data;
    @track totalPrice = 0;
    @track totalNetPrice = 0;
    priceBookValues=[];
    @track picklistOptions = [];
    selectedValue1;
    
    
    discountOptions = [
        { label: '%', value: '%' },
        { label: '$', value: '$' }
    ];

    computeSNo(index) {
        return index + 1;
    }

    labelValue = Reservation_Schedule_Reservation_Type;

    validateSelectedPrices() {
        const invalidRows = this.data.filter(item => !item.price);
        return invalidRows.length === 0;
    }

    connectedCallback() {
        this.getAccountInfo();
        this.getLocationInfo();
        console.log('billableEntity ', this.billableEntity)
        console.log('selectedValue ', this.selectedValue)
    }
    get priceBookValueForRow() {
    return this.priceBookValues && this.priceBookValues[this.index];
}

    @wire(getObjectInfo, {objectApiName:RESERVATION_OBJECT})
    objectInfo
 

    @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:RESERVATION_TYPE_FIELD})
    wiredPicklistValues({ error, data }) {
        console.log('data of wiredPicklistValues '+JSON.stringify(data));
        console.log('error '+error);
        if (data) {
            this.picklistOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
            this.selectedValue1=this.selectedValue;
            console.log('picklistOptions', JSON.stringify(this.picklistOptions));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }

    getAccountInfo() {
        getAccountDetails({ accountId: this.accountId })
            .then(result => {
                if (result) {
                    this.accountName = result.name;
                    this.accountBirthDate = result.birthDate;
                    this.accountPhone = result.phone;
                    this.accountEmail = result.email;
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
    getLocationInfo() {
    getLocationDetails({ locationIds: this.billableEntity })
        .then(result => {
            console.log('getLocationDetails result ' + JSON.stringify(result));
            let resultArray = result;
            this.data = resultArray.map((record, index) => {
                return {
                    ...record, index: index + 1,
                    options: [
                        ...record.actualPrices.map(price => ({
                            label: price.ElixirSuite__Description__c != undefined ? price.ElixirSuite__Description__c + ' - ' + price.ElixirSuite__List_Price__c : price.ElixirSuite__List_Price__c.toString(),
                            value: `${price.ElixirSuite__List_Price__c}`
                        })),
                        ...record.contractPrices.map(contractedPrice => ({
                            label: contractedPrice.ElixirSuite__Description__c != undefined ? contractedPrice.ElixirSuite__Description__c + ' - ' + contractedPrice.ElixirSuite__Contracted_Amount__c : contractedPrice.ElixirSuite__Contracted_Amount__c.toString(),
                            value: `${contractedPrice.ElixirSuite__Contracted_Amount__c}`
                        }))
                    ],
                    price: 0,
                    selectedDiscountType: '',
                    selectedDiscountValue: 0,
                    netPrice: 0
                };
            });
            // Initialize priceBookValues array for each row
            this.priceBookValues = Array.from({ length: this.data.length }, () => '');
        })
        .catch(error => {
            console.log(error);
        })
}
 calculateNumberOfDays(startDate, endDate) {
        const start = new Date(startDate);
        const end = new Date(endDate);
        const timeDifference = end - start;
        const numberOfDays = timeDifference / (1000 * 60 * 60 * 24); // Calculate days
        return numberOfDays;
    }

    handleChangeForPrice(event) {
       const selectedValue = parseFloat(event.detail.value);
        console.log('selectedValue'+selectedValue);
       const rowIndex = event.target.dataset.rowIndex; // Get the row index from the dataset
        const numberOfDays = this.calculateNumberOfDays(this.startDate, this.endDate); // Calculate number of days
         this.priceBookValues[rowIndex]=event.detail.value;
        this.data[rowIndex].price = selectedValue*numberOfDays;
        this.calculateNetPriceAndUpdate(rowIndex);

        this.totalPrice = this.calculateTotalPrice();
        this.calculateTotalNetPrice();
    }

    calculateTotalPrice() {
        return this.data.reduce((total, item) => total + parseFloat(item.price), 0);
    }

    handleChangeForDiscountType(event) {
        const selectedValue = event.detail.value;
        const rowIndex = event.target.dataset.rowIndex;
        console.log('rowIndex'+rowIndex);
        console.log('selectedValue'+selectedValue);
        this.data[rowIndex].selectedDiscountType = selectedValue;
        this.calculateNetPriceAndUpdate(rowIndex);
    }

    handleChangeForDiscountValue(event) {
        const newValue = event.target.value;
        const rowIndex = event.target.dataset.rowIndex;
        console.log('newValue'+newValue);
        console.log('Data Type:', typeof newValue);
        console.log('rowIndex'+rowIndex);
        if(this.data[rowIndex].selectedDiscountType == ''){
            this.showErrorToast('Please select discount type');
        }
        if (newValue == null || newValue =='') {
            console.log('If');
            this.data[rowIndex].selectedDiscountValue = 0;
        this.calculateNetPriceAndUpdate(rowIndex);
        }
        else{
            console.log('else');
            this.data[rowIndex].selectedDiscountValue = newValue;
            this.calculateNetPriceAndUpdate(rowIndex);
        }
       
    }

    calculateNetPriceAndUpdate(rowIndex) {
        const item = this.data[rowIndex];
        const netPrice = this.calculateNetPrice(item.price, item.selectedDiscountType, item.selectedDiscountValue);
        console.log('item'+item);
        console.log('netPrice'+netPrice);
        this.data[rowIndex].netPrice = netPrice;
        this.data = [...this.data];
        this.calculateTotalNetPrice();
    }

    calculateTotalNetPrice() {
        this.totalNetPrice = this.data.reduce((total, item) => total + parseFloat(item.netPrice), 0);
    }

    calculateNetPrice(selectedPrice, discountType, discountValue) {
        let netPrice = parseFloat(selectedPrice);
    
        if (discountType === '%') {
            netPrice *= (100 - parseFloat(discountValue)) / 100;
        } else if (discountType === '$') {
            netPrice -= parseFloat(discountValue);
        }
        return netPrice.toFixed(2);
    }

    get totalPriceFormatted() {
        return `$ ${this.totalPrice.toFixed(2)}`;
    }

    get totalNetPriceFormatted() {
        return `$ ${this.totalNetPrice.toFixed(2)}`;
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
    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleConfirmClick() {
        if (!this.validateSelectedPrices()) {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please select the relevant price book.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        for(let i=0; i<this.data.length; i++){
            if(this.data[i].selectedDiscountValue !== 0){
                if(this.data[i].selectedDiscountType == ''){
                    this.showErrorToast('Please select discount type');
                    return;
                }
            }
        }
        
        this.saveReservation();
        
    }

    confirmAndNew = false;

    confirmNew(){
        if (!this.validateSelectedPrices()) {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please select the relevant price book.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        for(let i=0; i<this.data.length; i++){
            if(this.data[i].selectedDiscountValue !== 0){
                if(this.data[i].selectedDiscountType == ''){
                    this.showErrorToast('Please select discount type');
                    return;
                }
            }
        }
        this.confirmAndNew = true;
        this.saveReservation();
    }

    saveReservation() {
        this.isButtonDisabled=true;
        //Call the Apex method to save the reservation
        
        saveRecord({
            accountId: this.accountId,
            startDate: this.startDate,
            endDate: this.endDate,
            selectedBeds: JSON.stringify(this.selectedBedIds),
            billableEntity: JSON.stringify(this.data),
            totalPrice: this.totalPrice,
            totalNetPrice: this.totalNetPrice,
            reservationType:this.selectedValue1
        })
            .then(result => {
                this.isButtonDisabled=false;
                // Handle the success case
                console.log('Record saved successfully:', result);
                this.showSuccessToast('Reservation has been successfully created');
                
                if(this.confirmAndNew){
                    this.dispatchEvent(new CustomEvent('saveandnew', {
                        detail: {
                            message: 'save and new'
                        }
                    }));
                }
                else{
                    this.dispatchEvent(new CustomEvent('save', {
                        detail: {
                            message: 'Increased count to '
                        }
                    }));
                }
            })
            .catch(error => {
                this.isButtonDisabled=false;
                // Handle the error case
                console.error('Error saving record:', error);
                this.showErrorToast(error.body.message);

            });
    }


    handleModify() {
        this.dispatchEvent(new CustomEvent('modify', {
            detail: {
                message: 'Modify'
            }
        }));
    }

    
}