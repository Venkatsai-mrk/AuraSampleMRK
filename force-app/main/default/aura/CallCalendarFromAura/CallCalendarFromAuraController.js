({
    doInit : function(component, event, helper) {
        var jsonList = [{
            id:'00UN000000BqkXUMAZ',
            start:'2023-01-17 11:22:00',
            end:'2023-01-17 11:22:00',
            title:'Email',
            textColor: 'black',
            backgroundColor: 'yellow',
            url: '/lightning/r/Event/00UN000000BqkXUMAZ/view'
        },
        {
            id:'00UN000000BqkXUMAy',
            start:'2023-01-18 11:22:00',
            end:'2023-01-18 11:22:00',
            title:'Email',
            textColor: 'pink',
            backgroundColor: 'black',
            url: '/lightning/r/Event/00UN000000BqkXUMAZ/view'
        }];
        component.set("v.jsonToSave",jsonList);


    }
})