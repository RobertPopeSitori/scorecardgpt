({
	onInit: function(component){
        var scorecardId = this.getParameter("scorecard");
        var sectionId = this.getParameter("section");
        var questionId = this.getParameter("question");

        var action = component.get("c.getSectionList");
        action.setParams({scorecardId: scorecardId, sectionId: sectionId, questionId : questionId });
		action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){

                console.log('MODEL:' + actionResult.getReturnValue());

                var response = JSON.parse(actionResult.getReturnValue());
                if(response.success){
                    component.set("v.model", response.model);
                }else{
                    this.onError(component, response.message);
                }
            } else {
                this.onError(component, "There was an error sending the request to the server.\r\nPlease try again later..");
            }

            component.set("v.isLoading", false);
        });
        
        component.set("v.isLoading", true);
        component.set("v.scorecardId", scorecardId);
        $A.enqueueAction(action); 
    },

    onError: function(component, message){
        console.log('ERROR:' + message);
    },

    onSectionMenuClick: function(component, event){
        var menuId = event.currentTarget.id;
        var menus = document.getElementsByClassName("olc-section-menu");

        console.log('MENU-ID:' + menuId);

        for(var i = 0; i < menus.length; i++)
        {
            var className = menus[i].className;
            var isOpen = className.includes("slds-is-open");

            menus[i].className = menus[i].className.replace(" slds-is-open", "");

            if(menuId == menus[i].id && !isOpen){
                menus[i].className = menus[i].className + " slds-is-open";
            }
        }
    },

    getParameter: function(paramName){
        var url = decodeURIComponent(window.location.search.substring(1));
        var keyPairs = url.split('&');
        var value = '';

        for (var i = 0; i < keyPairs.length; i++) {
            var keyPair = keyPairs[i].split('=');
            if (keyPair[0] === paramName) {
                value = keyPair[1] === undefined ? '' : keyPair[1];
                break;
            }
        }

        return value;
    },
     getScorecardname : function(component){
        var scorecardId = component.get("v.scorecardId");
        var action = component.get("c.getscorecard");
        action.setParams({scorecardId: scorecardId});
        action.setCallback(this, function(actionResult) {
            debugger
            if(actionResult.getState() === 'SUCCESS'){
                
               component.set("v.scorecardname",actionResult.getReturnValue());
            } else {
                this.onError(component, "There was an error sending the request to the server.\r\nPlease try again later..");
            }
            
            
        });
        
        
        $A.enqueueAction(action); 
    }

})