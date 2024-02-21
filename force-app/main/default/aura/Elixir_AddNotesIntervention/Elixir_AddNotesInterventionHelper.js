({
    notesRefresh : function(component , event , noteId ,idx) {
       var listOfNotes = component.get("v.listOfNotes");
       listOfNotes.splice(idx , 1); 
       component.set("v.listOfNotes" , listOfNotes);
    }
})