({
    doInit: function (cmp, event, helper) {
        debugger
        helper.fetchData(cmp, event, helper);
        helper.getDates(cmp, event, helper);
    },
    firetoPDf: function(component, event, helper){
        debugger
       // $A.get("e.force:closeQuickAction").fire();
        var tickettypeID = event.getSource().get("v.value");
        var startdate= component.get("v.startdate");
        var enddate= component.get("v.enddate");
        console.log(tickettypeID);
        console.log(startdate);
                console.log(enddate);

         var callingclass = component.get("c.getAttende");
        callingclass.setParams({"tickettypeID":tickettypeID,
                                "startdate" : startdate,
                                "enddate" : enddate});
        callingclass.setCallback(this,function(response){
            debugger
            var state = response.getState();
            if (state === "SUCCESS") {  
                console.log(response.getReturnValue());
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": response.getReturnValue()
                });
                urlEvent.fire();
                 // var urlEvent = $A.get("e.force:navigateToURL");
        //urlEvent.setParams({
          //  "url": "https://olc--uat.my.salesforce.com/apex/AttendeeBadgeVFP?Id="+tickettypeID+"&&sd="+startdate+"&&ed="+enddate
        //});
        //urlEvent.fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        console.log("Error Line: " + 
                                    errors[0].LineNumber);
                    }
                } else {
                    console.log("Unknown error");
                    alert('Unknown');
                }
            }
        });
        $A.enqueueAction(callingclass);
    
        
      
    },
    date : function(cmp, event, helper){
        debugger
        var sdate = cmp.get("v.startdate");
        var edate = cmp.get("v.enddate");
        if(sdate != null && edate != null){
            cmp.set("v.Enable",false);
        }else{
             cmp.set("v.Enable",true);
        }
        
        
    }
})