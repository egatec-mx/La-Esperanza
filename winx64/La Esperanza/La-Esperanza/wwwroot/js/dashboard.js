(function ($) {
    var reloadTime = 5 * 60 * 1000;

    String.prototype.padZero = function (len, c) {
        var s = this, c = c || '0';
        while (s.length < len) s = c + s;
        return s;
    }

    $.newOrders = function () {
        $.ajax({
            method: 'GET',
            url: '/Home/NewOrders',
            success: function (data) {
                $('#newtotal').text(data.total);
                var tbody = $('#neworders').find('tbody');
                tbody.html('');
                if (data.orders.length > 0) {
                    $.each(data.orders, function (_i, e) {
                        tbody.append('<tr><td><a href="#" class="btn btn-link m-0 p-0" data-toggle="modal" data-target="#detailsModal" data-title="<i class=\'fa fa-list fa-fw\'></i> Detalles del pedido" data-url="/Order/DetailsOrder/' + e.orderId + '">' + e.orderId.toString().padZero(6, '0') + '</a></td><td>$' + e.orderTotal.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</td><td>' + e.customerName + '</td></tr>');
                    });
                } else {
                    tbody.append('<tr><td colspan="3"><span>No hay nuevos pedidos</span></td></tr>');
                }
                setTimeout($.newOrders, reloadTime);
            }, error: function (error) {
                if (error.status == 401) {
                    $('body').sessionTimeout('show');
                }
            }
        });
    };

    $.processingOrders = function () {
        $.ajax({
            method: 'GET',
            url: '/Home/ProcessingOrders',
            success: function (data) {
                $('#processtotal').text(data.total);
                var tbody = $('#processorders').find('tbody');
                tbody.html('');
                if (data.orders.length > 0) {
                    $.each(data.orders, function (_i, e) {
                        tbody.append('<tr><td><a href="#" class="btn btn-link m-0 p-0" data-toggle="modal" data-target="#detailsModal" data-title="<i class=\'fa fa-list fa-fw\'></i> Detalles del pedido" data-url="/Order/DetailsOrder/' + e.orderId + '">' + e.orderId.toString().padZero(6, '0') + '</a></td><td>$' + e.orderTotal.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</td><td>' + e.customerName + '</td></tr>');
                    });
                } else {
                    tbody.append('<tr><td colspan="3"><span>No hay pedidos para preparar</span></td></tr>');
                }
            }, error: function (error) {
                if (error.status == 401) {
                    $('body').sessionTimeout('show');
                }
            }
        });
    };

    $.deliveryOrders = function () {
        $.ajax({
            method: 'GET',
            url: '/Home/DeliveryOrders',
            success: function (data) {
                $('#delivertotal').text(data.total);
                var tbody = $('#deliverorders').find('tbody');
                tbody.html('');
                if (data.orders.length > 0) {
                    $.each(data.orders, function (_i, e) {
                        tbody.append('<tr><td><a href="#" class="btn btn-link m-0 p-0" data-toggle="modal" data-target="#detailsModal" data-title="<i class=\'fa fa-list fa-fw\'></i> Detalles del pedido" data-url="/Order/DetailsOrder/' + e.orderId + '">' + e.orderId.toString().padZero(6, '0') + '</a></td><td>$' + e.orderTotal.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</td><td>' + e.customerName + '</td></tr>');
                    });
                } else {
                    tbody.append('<tr><td colspan="3"><span>No hay pedidos por entregar</span></td></tr>');
                }
                setTimeout($.processingOrders, reloadTime);
            }, error: function (error) {
                if (error.status == 401) {
                    $('body').sessionTimeout('show');
                }
            }
        });
    };

    $.completedOrders = function () {
        $.ajax({
            method: 'GET',
            url: '/Home/CompletedOrders',
            success: function (data) {
                $('#completetotal').text(data.total);
                var tbody = $('#completeorders').find('tbody');
                tbody.html('');
                if (data.orders.length > 0) {
                    $.each(data.orders, function (_i, e) {
                        tbody.append('<tr><td><a href="#" class="btn btn-link m-0 p-0" data-toggle="modal" data-target="#detailsModal" data-title="<i class=\'fa fa-list fa-fw\'></i> Detalles del pedido" data-url="/Order/DetailsOrder/' + e.orderId + '">' + e.orderId.toString().padZero(6, '0') + '</a></td><td>$' + e.orderTotal.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</td><td>' + e.customerName + '</td></tr>');
                    });
                } else {
                    tbody.append('<tr><td colspan="3"><span>No hay pedidos completados</span></td></tr>');
                }
                setTimeout($.completedOrders, reloadTime);
            }, error: function (error) {
                if (error.status == 401) {
                    $('body').sessionTimeout('show');
                }
            }
        });
    };

    $.canceledOrders = function () {
        $.ajax({
            method: 'GET',
            url: '/Home/CanceledOrders',
            success: function (data) {
                $('#canceltotal').text(data.total);
                var tbody = $('#cancelorders').find('tbody');
                tbody.html('');
                if (data.orders.length > 0) {
                    $.each(data.orders, function (_i, e) {
                        tbody.append('<tr><td><a href="#" class="btn btn-link m-0 p-0" data-toggle="modal" data-target="#detailsModal" data-title="<i class=\'fa fa-list fa-fw\'></i> Detalles del pedido" data-url="/Order/DetailsOrder/' + e.orderId + '">' + e.orderId.toString().padZero(6, '0') + '</a></td><td>$' + e.orderTotal.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</td><td>' + e.customerName + '</td></tr>');
                    });
                } else {
                    tbody.append('<tr><td colspan="3"><span>No hay pedidos cancelados</span></td></tr>');
                }
                setTimeout($.canceledOrders, reloadTime);
            }, error: function (error) {
                if (error.status == 401) {
                    $('body').sessionTimeout('show');
                }
            }
        });
    };

    $.rejectedOrders = function () {
        $.ajax({
            method: 'GET',
            url: '/Home/RejectedOrders',
            success: function (data) {
                $('#rejectedtotal').text(data.total);
                var tbody = $('#rejectedorders').find('tbody');
                tbody.html('');
                if (data.orders.length > 0) {
                    $.each(data.orders, function (_i, e) {
                        tbody.append('<tr><td><a href="#" class="btn btn-link m-0 p-0" data-toggle="modal" data-target="#detailsModal" data-title="<i class=\'fa fa-list fa-fw\'></i> Detalles del pedido" data-url="/Order/DetailsOrder/' + e.orderId + '">' + e.orderId.toString().padZero(6, '0') + '</a></td><td>$' + e.orderTotal.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</td><td>' + e.customerName + '</td></tr>');
                    });
                } else {
                    tbody.append('<tr><td colspan="3"><span>No hay pedidos rechazados</span></td></tr>');
                }
                setTimeout($.rejectedOrders, reloadTime);
            }, error: function (error) {
                if (error.status == 401) {
                    $('body').sessionTimeout('show');
                }
            }
        });
    };

    $.salesByDay = function () {
        $.ajax({
            method: 'GET',
            url: '/Home/SalesByDay',
            success: function (data) {
                var tbody = $('#salesbyday').find('tbody');
                tbody.html('');
                $.each(data, function (_i, e) {
                    tbody.append('<tr><td>' + e.date + '</td><td>' + e.orders + '</td><td>$' + e.total.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</td><td><a href="#" class="btn btn-link m-0 p-0" data-toggle="modal" data-target="#detailsModal" data-title="<i class=\'fa fa-list fa-fw\'></i> Detalles de la venta" data-url="/Home/SalesByDayDetails/' + e.date.replace(/\//g, '-') + '"><i class=\"fa fa-info-circle fa-fw\"></i></a></td></tr>');
                });
                setTimeout($.salesByDay, reloadTime);
            }, error: function (error) {
                if (error.status == 401) {
                    $('body').sessionTimeout('show');
                }
            }
        });
    };

    $.registerDevice = function () {
        if ('serviceWorker' in navigator) {
            Notification.requestPermission(function (status) {
                console.log('Status de las notificaciones:', status);
                if (status === 'granted') {
                    navigator.serviceWorker.ready.then(function (reg) {
                        reg.pushManager
                            .getSubscription()
                            .then(function (subscription) {
                                if (subscription) {
                                    console.log('El usuario ya recibe notificaciones');
                                } else {
                                    $.get('/Account/ServerKey')
                                        .then(function (data) {
                                            var serverKey = data;
                                            var subscribeParams = { userVisibleOnly: true };
                                            var applicationServerKey = urlB64ToUint8Array(serverKey);
                                            subscribeParams.applicationServerKey = applicationServerKey;
                                            reg.pushManager
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
                                                            console.log('[Error:' + e.status + '] No se registro el dispositivo para las notificaciones WebPush');
                                                        }
                                                    });
                                                });
                                        });
                                }
                            });
                    });
                }
            });
        }
    };

    $.registerAppleDevice = function (id) {
        if (id != '') {
            var form = JSON.parse(JSON.stringify({ 'devicePushEndpoint': 'Apple', 'devicePushP256dh': id, 'devicePushAuth': 'Apple' }));
            $.ajax({
                method: 'POST',
                url: '/Account/RegisterDevice',
                data: form,
                error: function (e) {
                    console.log('[Error:' + e.status + '] No se registro el dispositivo para las notificaciones de Apple');
                }
            });
        }
    };

    $.submitSearch = function (element) {
        this.init(element);
    }

    $.extend($.submitSearch, {
        prototype: {
            init: function (element) {
                this.element = $(element);
                this.form = this.element.closest('form');
                this.bind();
            },
            bind: function () {
                this.element.on('click', this, this.submit);
            },
            submit: function (e) {
                var api = e.data != undefined ? e.data : e;
                e.preventDefault();
                var data = api.form.serialize();
                $.ajax({
                    method: 'POST',
                    url: api.form.attr('action'),
                    data: data,
                    success: function (response) {
                        var tbody = $('#salesbyday').find('tbody');
                        tbody.html('');
                        if (response.length > 0) {
                            $.each(response, function (_i, e) {
                                tbody.append('<tr><td>' + e.date + '</td><td>' + e.orders + '</td><td>$' + e.total.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</td><td><a href="#" class="btn btn-link m-0 p-0" data-toggle="modal" data-target="#detailsModal" data-title="<i class=\'fa fa-list fa-fw\'></i> Detalles de la venta" data-url="/Home/SalesByDayDetails/' + e.date.replace(/\//g, '-') + '"><i class=\"fa fa-info-circle fa-fw\"></i></a></td></tr>');
                            });
                        } else {
                            tbody.append('<tr><td colspan="4" class="text-center"><i class="fa fa-sad-cry fa-fw"></i> ¡No hay registros para esas fechas!</td><tr>');
                        }
                    }
                });
            }
        }
    });

    $.extend($.fn, {
        submitSearch: function () {
            return this.each(function () {
                var ss = $(this).data('SUBMITSEARCH');
                if (!ss) {
                    ss = new $.submitSearch(this);
                    $(this).data('SUBMITSEARCH', ss);
                }
                return ss;
            });
        }
    });

    $.newOrders();
    $.processingOrders();
    $.deliveryOrders();
    $.completedOrders();
    $.canceledOrders();
    $.rejectedOrders();
    $.salesByDay();
    $.registerDevice();

    $('[data-action="submitSearch"]').submitSearch();

})(jQuery);