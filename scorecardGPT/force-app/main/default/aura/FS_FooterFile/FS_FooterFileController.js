({
	doInit : function(component, event, helper) {
		fetch('https://onlinelearningconsortium.org/wp-json/menus/v1/menus/footer-menu-links').then(function(response) {
            return response.json();
        }).then(function(data) {
            var footerItems = data.items;
            component.set("v.Items", footerItems);
        }).catch(function() {
            console.log("Booo");
        });
	}
})