$(document).ready(function () {
    var submit = function(user) {
        var url = "/uhc/leaderboard";

        url += "?sort=" + $('#uhc-sort').val();

        if(user) {
            var username = $('#uhc-search-username').val();
            if(username.search(/\S/) == -1) return;
            url += "&user=" + username;
        }

        window.location.replace(url);
    };

    $('.uhc-control').change(function (){
        submit(false);
    });

    $('#uhc-search-button').click(function() {
        submit(true);
    });

    $('#uhc-search-username').keypress(function(event) {
        if(event.keyCode == 13) {
            submit(true);
        }
    });
});
