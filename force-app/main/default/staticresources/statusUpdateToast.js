function showToast() {
            sforce.one.showToast({
                "title": "Success!",
                "message": "Status updated successfully",
                "type": "success"
            });
        }
    window.location.top.reload();