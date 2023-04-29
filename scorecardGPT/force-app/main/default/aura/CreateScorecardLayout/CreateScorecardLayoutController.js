({
    doInit : function(component, event, helper){
        helper.fetchingTemplate(component, event, helper);
    },
    validate : function(component, event){
        var temId=component.get("v.TemplateId");
        //alert(component.get("v.TemplateId"));
        if(typeof temId=='undefined'){
            //alert('NO');
        }
    },
    handleMyComponentEvent : function(component, event) {
		var value = event.getParam("TemplateId");
        //alert(value);
        component.set("v.TemplateId",value);
	},
      handleSubmit : function(component, event, helper) {
           event.preventDefault();         
          /*var templateId= component.get("v.TemplateId");
          if(typeof templateId !='undefined' ){
              var fields= event.getParam('fields');        
          fields.Template__c =  component.get("v.TemplateId");
        component.find('myRecordForm').submit(fields);
          } else {
             var childComp = component.find('lookupComp');
              childComp.displayError();
                  
          }*/
          
          var templateId= component.get("v.selectedValue");
          if(typeof templateId !='undefined' ){
              var fields= event.getParam('fields');        
          fields.Template__c =  component.get("v.selectedValue");
        component.find('myRecordForm').submit(fields);
          } else {
             var childComp = component.find('lookupComp');
              childComp.displayError();
                  
          }
          
       },
   handleOnSuccess : function(component, event, helper) {
         var eve = component.getEvent("createScorecardLayoutEvent");
                eve.setParams({"closeModal":true});
              
                eve.fire();
    var record = event.getParam("response");
       var eventName='';
       if(component.get("v.isNewRecordCreated")){
           eventName='updated'
       }else {
           component.set("v.isNewRecordCreated",true);
           eventName='created';
       }
      // alert(event.getParam("id"));
 component.find('notificationsLibrary').showToast({
                            "variant": "success",
                            "title": "Scorecard was successfully "+eventName,
                            //"message": "Record ID: " + event.getParam("id")
                        });
       $A.get('e.force:refreshView').fire();
       
},
    handleError : function(component, event, helper) {
    var error = event.getParam("error");
    console.log(error);
    component.find("notificationsLibrary").showToast({ "variant":"error", "title": "Error Message", "message": "An error occured while saving record" });
}
})