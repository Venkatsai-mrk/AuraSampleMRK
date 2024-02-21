({
    COLUMNS: [
        { label: 'Medication Name', fieldName: 'ElixirSuite__Drug_Name__c' },
        { label: 'Reason', fieldName: 'ElixirSuite__Reason_new__c' },
        { label: 'Route', fieldName: 'ElixirSuite__Route_New__c' },
        { label: 'Created By', fieldName: 'CreatedBy.Name' },
        { label: 'Created Date', fieldName: 'CreatedDate',sortable: true},
        { label: 'Modified Date', fieldName: 'LastModifiedDate'}
        
    ],
    
    
    
    
    setColumns: function(cmp) {
        
        cmp.set('v.columns', this.COLUMNS);
        console.log('columns'+this.COLUMNS);
    },
    
    setData: function(cmp) {
        cmp.set('v.data', this.DATA);
    },
 
    // Used to sort the 'Age' column
    sortBy: function(field, reverse, primer) {
        var key = primer
        ? function(x) {
            return primer(x[field]);
        }
        : function(x) {
            return x[field];
        };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
    
    handleSort: function(cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        
        var cloneData = this.DATA.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        cmp.set('v.data', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    }
})