$(document).ready(function () {
    var submit = function(user) {
        var url = "/stats";

        url += "?time=" + $('#playerstats-time').val();
        url += "&game=" + $('#playerstats-game').val();
        url += "&sort=" + $('#playerstats-sort').val();

        if(user) {
            var username = $('#search-username').val();
            if(username.search(/\S/) == -1) return;
            url += "&user=" + username;
        }

        window.location.replace(url);
    };

    $('.playerstats-control').change(function (){
        submit(false);
    });

    $('#search-button').click(function() {
        submit(true);
    });

    $('#search-username').keypress(function(event) {
        if(event.keyCode == 13) {
            submit(true);
        }
    });
});
