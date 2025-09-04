(function () {
    'use strict';

    self.addEventListener('install', function () {
        self.skipWaiting();
    });

    self.addEventListener('activate', function () {

    });

    self.addEventListener('fetch', function () { });

    self.addEventListener('push', function (event) {
        var data = {};
        var icon = '/images/logo.png';
        if (!(self.Notification && self.Notification.permission === 'granted'))
            return;
        if (event.data) {
            try {
                data = event.data.json();
            } catch{
                data.Title = '¡Buen trabajo!';
                data.Message = 'Solo estoy haciendo un test.';
            }
        }
        var options = {
            body: data.Message,
            icon: icon,
            badge: icon,
            vibrate: [100, 50, 100],
            actions: [
                { action: 'show', title: 'Mostrar', icon: '/images/check.png' },
                { action: 'close', title: 'Cerrar', icon: '/images/cancel.png' }
            ]
        };
        event.waitUntil(self.registration.showNotification(data.Title, options));
    });

    self.addEventListener('pushsubscriptionchange', function (event) {
        console.log('Subscripción a las notificaciones expirada');
        $.get('/Account/ServerKey')
            .then(function (data) {
                var serverKey = data;
                var subscribeParams = { userVisibleOnly: true };
                var applicationServerKey = urlB64ToUint8Array(serverKey);
                subscribeParams.applicationServerKey = applicationServerKey;
                event.waitUntil(
                    self.registration
                        .pushManager
                        .subscribe(subscribeParams)
                        .then(function (subscription) {
                            var jsonObj = JSON.parse(JSON.stringify(subscription));
                            var p256dh = jsonObj.keys.p256dh;
                            var auth = jsonObj.keys.auth;
                            var form = JSON.parse(JSON.stringify({ 'devicePushEndpoint': subscription.endpoint, 'devicePushP256dh': p256dh, 'devicePushAuth': auth }));
                            $.ajax({
                                method: 'POST',
                                url: '/Account/RegisterDevice',
                                data: form,
                                error: function (e) {
                                    console.log('[Register Device]:' + e.status);
                                }
                            });
                        }));
            });
    });

    self.addEventListener('notificationclick', function (e) {
        e.notification.close();
        e.waitUntil(clients.matchAll({
            type: "window"
        }).then(function (clientList) {
            for (var i = 0; i < clientList.length; i++) {
                var client = clientList[i];
                if (client.url == '/' && 'focus' in client) {
                    client.focus();
                    break;
                }
            }
            if (clients.openWindow)
                return clients.openWindow('/');
        }));
    });
})();