// auth-guard.js — ModUrWall
// Guards any page at any depth under docs/
// Token key: modurwall_token (sessionStorage only)
(function () {
    var token = sessionStorage.getItem('modurwall_token');
    if (!token) {
        var base = (location.pathname.match(/^(.*\/docs\/)/) || ['', '/'])[1];
        window.location.replace(base + 'login/');
    }
})();
