({
    doInit : function(component, event, helper){
        if($A.get("$SObjectType.CurrentUser.Id") == undefined || $A.get("$SObjectType.CurrentUser.Id") ==''){
             component.set("v.showLogout", "false");
        }
    },
	scriptsLoaded : function(component, event, helper) {
		setTimeout(function() {
            if(window.parent.location != undefined){
                var location = window.parent.location.pathname;
                if(location.includes("/OLC/s/login/")){
                    component.set("v.showLogout", "false");
                }
            }
        }, 10);
	},
    /*callPrint:function(component, event, helper){
        window.print();return false;
    },
    
    getUrlFB:function(component, event, helper){
        var strWindowFeatures = "location=yes,height=570,width=520,scrollbars=yes,status=yes";
        var URL = "https://www.facebook.com/sharer/sharer.php?u=" + location.href;
        var win = window.open(URL, "_blank", strWindowFeatures);
    },
    getUrlTwitter:function(component, event, helper){
        var strWindowFeatures = "location=yes,height=570,width=520,scrollbars=yes,status=yes";
        var URL = "https://twitter.com/intent/tweet?text=Online Learning Consortium (OLC) - Enhancing Online Education&url=" + location.href;
        var win = window.open(URL, "_blank", strWindowFeatures);
    },
    getUrlLinkedin:function(component, event, helper){
        var strWindowFeatures = "location=yes,height=570,width=520,scrollbars=yes,status=yes";
        var URL = "https://www.linkedin.com/shareArticle?mini=true&url="+location.href+"&amp;title=Online Learning Consortium (OLC) - Enhancing Online Education";
        var win = window.open(URL, "_blank", strWindowFeatures);
    }*/
    
})