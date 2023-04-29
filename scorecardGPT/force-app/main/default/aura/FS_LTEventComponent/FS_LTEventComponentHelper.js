/**
 * Created by daweima on 2019-09-04.
 */
({

    addListener: function(cmp) {
        window.addEventListener("hashchange",function(){
            console.log('check url called');
            var vars = {};

            window.location.href.replace(/\/s\/([^#]*)/, function (m, key, value) {
                vars['startURL'] = key;
            });

            window.location.href.replace(/[#]+([^=&]+)/, function (m, key, value) {
                vars['#'] = key;
            });


            var param=vars['#'];
            var startURL=vars['startURL'];
            console.log(vars);
            if (param !== null && param !== undefined && (param === 'loginredirectTT'|| param === 'login') ) {
                cmp.set('v.endUrlNotLogin', false);
                if (startURL !== null && startURL !== undefined && startURL !== '') {
                    if (param === 'login')
                        startURL = '/OLC/s/' + startURL;
                    else
                        startURL = '/OLC/s/' + startURL+'#rp-tickets';
                    var action = cmp.get('c.encodeString');
                    action.setParams({
                        input:startURL
                    });

                    action.setCallback(this, function(response){
                        var state = response.getState();
                        if (state === 'SUCCESS') {
                            var result = response.getReturnValue();
                            window.location.assign('login?startURL=' + result);
                        }
                    });

                    $A.enqueueAction(action);
                } else {
                    window.location.assign('login');
                }
            }
        });
    }
})