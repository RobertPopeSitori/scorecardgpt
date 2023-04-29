({
    doInit : function(component, event, helper){
        if($A.get("$SObjectType.CurrentUser.Id") == undefined || $A.get("$SObjectType.CurrentUser.Id") ==''){
            component.set("v.showLogout", "false");
        }
        
        fetch('https://onlinelearningconsortium.org/wp-json/menus/v1/menus/menu-a').then(function(response) {
            return response.json();
        }).then(function(data) {
            //data.items[10].child_items[0].title = (data.items[10].child_items[0].title).replaceAll('&#038;', '&');
            //data.items[10].child_items[8].title = (data.items[10].child_items[8].title).replaceAll('&#038;', '&');
            component.set("v.headerItems", data.items);
        }).catch(function() {
            console.log("Booo");
        });        
    },
    
    toggleMenu : function(component, event, helper) {
        //var tr = component.find('collapsibleNavbar');
        //$A.util.addClass(tr, 'show');
        
            var element = document.getElementById("collapsibleNavbar");
            element.classList.toggle("show");
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
})