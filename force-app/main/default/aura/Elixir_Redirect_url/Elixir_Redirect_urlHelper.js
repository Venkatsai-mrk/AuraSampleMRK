({
	generateReceipt : function(component) {
		var url = '/apex/ElixirSuite__SqaurePaymentsBill?orderId='+component.get("v.customerId")+'$'+component.get("v.orderId");
		var newWindow;	
		newWindow = window.open(url,'_self');	
	}
})