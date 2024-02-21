import { LightningElement, wire, track } from 'lwc';
import getLabOrderList from '@salesforce/apex/LabOrderRecords.getLabOrderList';
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Lab Order #', fieldName: 'ElixirSuite__Lab_Order_Req__c',sortable:"true"},
    { label: 'Status', fieldName: 'ElixirSuite__Status__c' },
    { label: 'Lab Order Number', fieldName: 'ElixirSuite__Lab_Order_Number__c', sortable: "true" },
    { label: 'Last Modified Date', fieldName: 'LastModifiedDate' },
];
export default class TestSortingInDataTable extends LightningElement {
    @track labOrders;
    @track error;
    @track columns = columns;
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    @wire(getLabOrderList)
    labOrders(result) {
            if (result.data) {
                this.data = result.data;
                this.error = undefined;
            } else if (result.error) {
                this.error = result.error;
                this.data = undefined;
            }
        }
        /*  handleRowAction(event) {
              const actionName = event.detail.action.name;
              const row = event.detail.row;
              switch (actionName) {
                  case 'view':
                      this[NavigationMixin.Navigate]({
                          type: 'standard__recordPage',
                          attributes: {
                              recordId: row.Id,
                              actionName: 'view'
                          }
                      });
                      break;
                  case 'edit':
                      this[NavigationMixin.Navigate]({
                          type: 'standard__recordPage',
                          attributes: {
                              recordId: row.Id,
                              objectApiName: 'Lab_Order__c',
                              actionName: 'edit'
                          }
                      });
                      break;
                  default:
              }
          }*/
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.labOrders];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.accounts = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    sortBy(field, reverse, primer) {
        const key = primer ?

            function(x) {
                return primer(x[field]);
            } :
            function(x) {
                return x[field];
            };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };

    }

}