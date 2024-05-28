({
	handleLWCEvent : function(component, event, helper) {
       debugger;
        //alert('LWC event handled');

        const childcompname= event.getParam('childcompname');

        const childcompdescription= event.getParam('childcompdescription');

        //alert('childcompname is:'+childcompname);

        //alert('childcompdescription is:'+childcompdescription);
         $A.get("e.force:closeQuickAction").fire(); 
          $A.get("e.force:refreshView").fire(); 

      }
})