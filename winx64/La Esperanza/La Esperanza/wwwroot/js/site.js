const MODALFORM = 'ModalForm';
const SESSIONTIMEOUT = 'SessionTimeout';
const ORDEREVENTS = 'OrderEvents';
const MODALPRIORITY = 'ModalPriority';
const PRINTTICKET = 'PrintTicket';
const SMARTSEARCH = 'SmartSearch';

function urlB64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding)
        .replace(/\-/g, '+')
        .replace(/_/g, '/');

    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);

    for (let i = 0; i < rawData.length; ++i) {
        outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
}

(function ($) {
    "use strict";

    var standalone = window.navigator.standalone,
        userAgent = window.navigator.userAgent.toLowerCase(),
        safari = /safari/.test(userAgent),
        iOS = /ios|iphone|ipad|ipod|ipados/.test(userAgent),
        android = /android [0-9].[0-9].[0-9];.*mobile;.*firefox|safari|chrome/.test(userAgent);

    $.sessionTimeout = function () {
        this.init();
    };

    $.modalForm = function (element) {
        this.init(element);
    };

    $.orderEvents = function (element) {
        this.init(element);
    }

    $.modalPriority = function (element, options) {
        this.init(element, options);
    }

    $.printTicket = function (element, options) {
        this.init(element, options);
    }

    $.smartSearch = function (element, options) {
        this.init(element, options);
    }

    $.sendPrintToApple = function (pdfUrl) {
        window.webkit.messageHandlers.openPDF.postMessage(pdfUrl);
    }

    $.showNotification = function (title, content) {
        if (Notification.permission == 'granted') {
            navigator.serviceWorker.getRegistration().then(function (reg) {
                var options = {
                    body: content,
                    icon: '/images/logo.png',
                    badge: '/images/logo.png',
                    vibrate: [100, 50, 100],
                    actions: [
                        {
                            action: 'show', title: 'Mostrar',
                            icon: '/images/check.png'
                        },
                        {
                            action: 'close', title: 'Cerrar',
                            icon: '/images/cancel.png'
                        },
                    ]
                };
                reg.showNotification(title, options);
            });
        }
    }

    $.extend($.sessionTimeout, {
        prototype: {
            settings: {
                modalId: '#timeoutModal',
                time: 60000,
                login: '/Account/Login',
                url: '/Account/CheckSession'
            },
            init: function () {
                this.modal = $(this.settings.modalId);
                this.modal.modalPriority({ index: 3001 });
                this.bind();
            },
            bind: function () {
                this.modal.on('hide.bs.modal', this.hide);
                setTimeout(this.check, this.settings.time, this);
            },
            hide: function () {
                window.location.reload();
            },
            check: function (api) {
                api = api === undefined ? this : api;
                if (window.location.pathname !== api.settings.login) {
                    $.ajax({
                        method: 'GET',
                        url: api.settings.url,
                        success: function () {
                            setTimeout(api.check, api.settings.time, api);
                        },
                        error: function (error) {
                            if (error.status == 401) {
                                api.show(api);
                            }
                        }
                    });
                }
            },
            show: function (api) {
                api = api === undefined ? this : api;
                api.modal.modal('show');
            }
        }
    });

    $.extend($.modalForm, {
        prototype: {
            settings: {
                succesElement: '.alert-success',
                successTemplate: '<i class="fa fa-check-circle fa-fw"></i> Aceptar',
                successClass: 'btn btn-success',
                waitModalId: '#waitModal'
            },
            init: function (element) {
                this.element = $(element);
                this.title = this.element.find('.modal-title');
                this.body = this.element.find('.modal-body');
                this.footer = this.element.find('.modal-footer');
                this.form = undefined;
                this.submitButton = this.footer.find('button[type=submit]');
                this.cancelButton = this.footer.find('button[type=button]');
                this.waitModal = $(this.settings.waitModalId);
                this.bind();
            },
            bind: function () {
                this.element.on('show.bs.modal', this, this.show);
                this.element.on('hide.bs.modal', this, this.hide);
                this.submitButton.on('click', this, this.submit);
                this.waitModal.modalPriority();
            },
            hide: function () {
                window.location.reload();
            },
            show: function (e) {
                var api = e.data;
                var btn = $(e.relatedTarget);
                var title = btn.data('title');
                var id = btn.data('id');
                var url = id != undefined ? btn.data('url') + '/' + id : btn.data('url');
                api.title.html(title);
                $.ajax({
                    method: 'GET',
                    url: url,
                    success: function (result) {
                        api.body.html(result);
                        api.form = api.body.find('form');
                        $.validator.unobtrusive.parse(api.form);
                        api.form.find("[data-mask=true]").inputmask({ autoUnmask: true });
                        api.form.orderEvents();
                        api.body.find('[data-smart="true"]').smartSearch();
                        api.footer.find('[data-print="true"]').printTicket();
                    },
                    error: function (error) {
                        if (error.status == 401) {
                            $('body').sessionTimeout('show');
                        }
                    }
                });
            },
            submit: function (e) {
                var api = e.data;
                var form = api.form;
                var method = form.attr('method');
                var url = form.attr('action');
                if (form.valid()) {
                    api.submitButton.addClass('disabled').attr('disabled', true);
                    api.waitModal.modal('show');
                    $.ajax({
                        method: method,
                        url: url,
                        data: form.serialize(),
                        success: function (data) {
                            api.body.html(data);
                            if (api.body.find(api.settings.succesElement).length > 0) {
                                api.submitButton.remove();
                                api.cancelButton
                                    .removeAttr('class')
                                    .addClass(api.settings.successClass)
                                    .html(api.settings.successTemplate);
                            } else {
                                api.submitButton.removeClass('disabled').removeAttr('disabled');
                            }
                            api.waitModal.modal('hide');
                        },
                        error: function (error) {
                            if (error.status == 401) {
                                $('body').sessionTimeout('show');
                            }
                        }
                    });
                }
            }
        }
    });

    $.extend($.orderEvents, {
        prototype: {
            settings: {
                productUrl: '/Product/Products',
                priceUrl: '/Product/Price/',
                rowTemplate: '<div class="card my-3" data-index="{idx}">' +
                    '<div class="card-header d-flex justify-content-between p-1">' +
                    '<h5 class="m-2">Art&iacute;culo #{pdx}</h5>' +
                    '<button type="button" class="btn btn-danger" data-action="remove">' +
                    '<i class="fa fa-trash-alt"></i>' +
                    '</button>' +
                    '</div>' +
                    '<div class="card-body p-1">' +
                    '<input type="hidden" id="OrderDetails{idx}_OrderDetailId" name="OrderDetails[{idx}].OrderDetailId" value="0" />' +
                    '<div class="form-row my-2">' +
                    '<label for="OrderDetails{idx}_OrderDetailQuantity" class="col-form-label col-3 text-right">Cantidad</label>' +
                    '<div class="col-9">' +
                    '<input type="text" inputmode="decimal" id="OrderDetails{idx}_OrderDetailQuantity" name="OrderDetails[{idx}].OrderDetailQuantity" class="form-control text-right" value="1" data-val="true" data-val-required="La cantidad para el artículo #{pdx} es requerida." />' +
                    '</div>' +
                    '</div>' +
                    '<div class="form-row my-2">' +
                    '<label for="OrderDetails{idx}_ProductId" class="col-form-label col-3 text-right">Producto</label>' +
                    '<div class="col-9">' +
                    '<select id="OrderDetails{idx}_ProductId" name="OrderDetails[{idx}].ProductId" class="form-control" data-val="true" data-val-required="Seleccione un producto en el artículo #{pdx}"></select>' +
                    '</div>' +
                    '</div>' +
                    '<div class="form-row my-2">' +
                    '<label for="OrderDetails{idx}_OrderDetailPrice" class="col-form-label col-3 text-right">Precio</label>' +
                    '<div class="col-9">' +
                    '<input type="text" inputmode="decimal" id="OrderDetails{idx}_OrderDetailPrice" name="OrderDetails[{idx}].OrderDetailPrice" class="form-control" value="0" data-val="false" data-mask="true" data-inputmask="\'alias\': \'decimal\', \'groupSeparator\': \',\', \'autoGroup\': true, \'digits\': 2, \'digitsOptional\': false, \'placeholder\': \'0\'" />' +
                    '</div>' +
                    '</div>' +
                    '<div class="form-row my-2">' +
                    '<label for="OrderDetails{idx}_OrderDetailTotal" class="col-form-label col-3 text-right">Total</label>' +
                    '<div class="col-9">' +
                    '<input type="text" inputmode="decimal" id="OrderDetails{idx}_OrderDetailTotal" name="OrderDetails[{idx}].OrderDetailTotal" class="form-control" value="0" data-val="false" data-mask="true" data-inputmask="\'alias\': \'decimal\', \'groupSeparator\': \',\', \'autoGroup\': true, \'digits\': 2, \'digitsOptional\': false, \'placeholder\': \'0\'" />' +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>'
            },
            init: function (element) {
                this.element = $(element);
                if (this.element.data('action') === 'order') {
                    this.addButton = this.element.find('[data-action="add"]');
                    this.removeButton = this.element.find('[data-action="remove"]');
                    this.deliveryTax = this.element.find('input[id*="OrderDeliveryTax"]');
                    this.products = [];
                    this.index = 0;
                    this.bind();
                    this.fetch();
                }
            },
            bind: function () {
                this.addButton.on('click', this, this.addRow);
                this.removeButton.on('click', this, this.removeRow);
                this.deliveryTax.on('change blur', this, this.doTotal);
            },
            fetch: function () {
                var api = this;
                $.ajax({
                    method: 'GET',
                    url: this.settings.productUrl,
                    success: function (data) {
                        api.products = data;
                        api.index = api.element.find('[data-index]').length - 1;
                        if (api.index > 0)
                            api.bindRows(api);
                        else {
                            api.fill(api);
                            api.bindRow(api);
                        }
                    },
                    error: function (error) {
                        if (error.status == 401) {
                            $('body').sessionTimeout('show');
                        }
                    }
                });
            },
            fill: function (api) {
                var select = api.element.find('#OrderDetails' + api.index + '_ProductId');
                select.append('<option value="">--- Seleccione uno ---</option>');
                $.each(api.products, function (_i, product) {
                    select.append('<option value="' + product.Key + '">' + product.Value + '</option>');
                });
            },
            addRow: function (e) {
                var api = e.data;
                api.index++;
                var row = api.settings.rowTemplate.replace(/{idx}/g, api.index).replace(/{pdx}/g, api.index + 1);
                api.element.find('[data-articles]').append(row).find("[data-mask=true]").inputmask({ autoUnmask: true });
                api.fill(api);
                api.bindRow(api);
                api.addValidation(api);
            },
            addValidation: function (e) {
                var api = e.data != undefined ? e.data : e;
                $(api.element).removeData('validator');
                $(api.element).removeData('unobtrusiveValidation');
                $.validator.unobtrusive.parse(api.element);
            },
            bindRows: function (api) {
                api.element.find('input[id*=_OrderDetailQuantity]').on('change blur', api, api.doCalculate);
                api.element.find('input[id*=_OrderDetailPrice]').on('change blur', api, api.doCalculate);
                api.element.find('input[id*=_OrderDetailTotal]').on('change blur', api, api.getQuantity);
                api.element.find('select[id*=_ProductId]').on('change', api, api.getPrice);
                api.element.find('[data-action="remove"]').on('click', api, api.removeRow);
            },
            bindRow: function (api) {
                api.element.find('#OrderDetails' + api.index + '_OrderDetailQuantity').on('change blur', api, api.doCalculate);
                api.element.find('#OrderDetails' + api.index + '_OrderDetailPrice').on('change blur', api, api.doCalculate);
                api.element.find('#OrderDetails' + api.index + '_OrderDetailTotal').on('change blur', api, api.getQuantity);
                api.element.find('#OrderDetails' + api.index + '_ProductId').on('change', api, api.getPrice);
                api.element.find('[data-action="remove"]').on('click', api, api.removeRow);
            },
            removeRow: function (e) {
                var api = e.data;
                $(this).parent().parent().remove();
                api.doTotal(api);
            },
            getPrice: function (e) {
                var api = e.data;
                var selected = $(this).val();
                var rowidx = $(this).closest('.card').data('index');
                $.ajax({
                    method: 'GET',
                    url: api.settings.priceUrl + selected,
                    success: function (price) {
                        api.element.find('#OrderDetails' + rowidx + '_OrderDetailPrice').val(price);
                        api.doCalculate(e);
                    },
                    error: function (error) {
                        if (error.status == 401) {
                            $('body').sessionTimeout('show');
                        }
                    }
                });
            },
            doCalculate: function (e) {
                var api = e.data;
                var rowidx = $(e.currentTarget).closest('.card').data('index');
                var inputQ = api.element.find('#OrderDetails' + rowidx + '_OrderDetailQuantity');
                var inputP = api.element.find('#OrderDetails' + rowidx + '_OrderDetailPrice');
                var inputT = api.element.find('#OrderDetails' + rowidx + '_OrderDetailTotal');

                var valQ = parseFloat(inputQ.val());
                var valP = parseFloat(inputP.val());
                var valT = valQ * valP;

                inputT.val(valT);
                api.doTotal(api);
            },
            doTotal: function (api) {
                api = api.data != undefined ? api.data : api;
                var total = 0, tax = 0, subtotal = 0;

                api.element.find('input[id*=OrderDetailTotal]').each(function () {
                    total += parseFloat($(this).inputmask('unmaskedvalue'));
                });

                total += parseFloat($('#OrderDeliveryTax').inputmask('unmaskedvalue'));

                tax = total * 0.16;
                subtotal = total - tax;

                $('#OrderTax').val(tax);
                $('#OrderSubtotal').val(subtotal);
                $('#OrderTotal').val(total);
                $('#TextTotal').text('$' + total.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,'));
            },
            getQuantity: function (e) {
                var api = e.data;
                var rowidx = $(e.currentTarget).closest('.card').data('index');
                var inputQ = api.element.find('#OrderDetails' + rowidx + '_OrderDetailQuantity');
                var inputP = api.element.find('#OrderDetails' + rowidx + '_OrderDetailPrice');
                var inputT = api.element.find('#OrderDetails' + rowidx + '_OrderDetailTotal');

                var valT = parseFloat(inputT.val());
                var valP = parseFloat(inputP.val());
                var valQ = valT / valP;

                inputQ.val(valQ.toFixed(2));
                api.doTotal(api);
            }
        }
    });

    $.extend($.modalPriority, {
        prototype: {
            settings: {
                index: 2001
            },
            init: function (element, options) {
                this.element = $(element);
                this.config = $.extend({}, this.settings, options);
                this.bind();
            },
            bind: function () {
                this.element.on('shown.bs.modal', this, this.style);
            },
            style: function (e) {
                var api = e.data;
                $(e.currentTarget).css('z-index', api.config.index);
                $('.modal-backdrop').last().css('z-index', api.config.index - 1);
            }
        }
    });

    $.extend($.printTicket, {
        prototype: {
            settings: {
                target: '#detailsModal .modal-body',
                id: '#OrderId',
                wait: '#waitModal'
            },
            init: function (element, options) {
                this.element = $(element);
                this.config = $.extend({}, this.settings, options);
                this.orderId = $(this.config.id).val();
                if (this.orderId == 0 || this.orderId == undefined) {
                    this.hide();
                } else {
                    this.bind();
                }
            },
            bind: function () {
                this.element.on('click', this, this.receipt);
            },
            receipt: function (e) {
                var api = e.data;
                e.preventDefault();
                e.stopPropagation();
                if (iOS) {
                    api.iosShare(e);
                } else {
                    api.download(e);
                }
            },
            hide: function () {
                this.element.remove();
            },
            iosShare: function (e) {
                var api = e.data != undefined ? e.data : e;
                var pdfUrl = "/print/printappleorder/" + api.orderId;
                $(api.config.wait).modal('show');
                $.sendPrintToApple(pdfUrl);
            },
            download: function (e) {
                var api = e.data != undefined ? e.data : e;
                var link = document.createElement('a');
                link.href = "/print/printorder/" + api.orderId;
                link.download = api.orderId + ".pdf";
                link.click();
            }
        }
    });

    $.extend($.smartSearch, {
        prototype: {
            settings: {
                url: '/Customer/SearchCustomer',
                count: 10,
                template: '<div class="smart-results py-2 px-0"><ul class="list-unstyled mb-0"></ul></div>',
                resultTemplate: '<li data-id="{id}" class="py-3 px-2 pointer"><i class="fa fa-user-tie fa-fw"></i>&nbsp;<span aria-label="name">{name}</span></li>',
                storage: '#CustomerId'
            },
            init: function (element, options) {
                this.element = $(element);
                this.config = $.extend({}, this.settings, options);
                $('body').append(this.config.template);
                this.wrapper = $('.smart-results');
                this.list = this.wrapper.find('ul');
                this.collapseSection = this.element.data('target');
                this.bind();
            },
            bind: function () {
                this.element.on('focus', this, this.clear);
                this.element.on('keyup.smartSearch', this, this.search);
                this.wrapper.on('mouseenter touchstart', this, this.in);
                this.wrapper.on('mouseleave touchend', this, this.out);
                $(document).on('click', this, this.hide);
            },
            clear: function (e) {
                var api = e.data != undefined ? e.data : e;
                $(this).val('').removeClass('is-valid').removeClass('is-invalid');
                $(api.storage).val('');
                api.hideSection(e);
            },
            search: function (e) {
                var api = e.data != undefined ? e.data : e;
                var val = $(this).val().trim();
                if (val.length >= 2) {
                    api.post(e, val);
                } else {
                    api.hide(e);
                }
            },
            post: function (e, search) {
                var api = e.data != undefined ? e.data : e;
                var form = JSON.parse(JSON.stringify({ 'search': search, 'count': this.config.count }));
                $.ajax({
                    method: 'POST',
                    url: api.config.url,
                    data: form,
                    success: function (data) {
                        api.list.html('');
                        $.each(data, function (_i, v) {
                            var rowTemplate = api.config.resultTemplate.replace(/{id}/g, v.Key).replace(/{name}/g, v.Value);
                            api.list.append(rowTemplate);
                            api.list.find('li').last().on('click', api, api.select);
                        });
                        api.show(e);
                    },
                    error: function (err) {
                        console.log(err.statusText);
                    }
                });
            },
            show: function (e) {
                var api = e.data != undefined ? e.data : e;
                api.wrapper.css({
                    top: api.element.offset().top + 38,
                    left: api.element.offset().left,
                    width: api.element.css('width')
                });
                api.wrapper.slideDown('slow');
            },
            hide: function (e) {
                var api = e.data != undefined ? e.data : e;
                if (!api.isVisible) {
                    api.wrapper.slideUp('slow');
                    api.list.html('');
                }
            },
            in: function (e) {
                var api = e.data != undefined ? e.data : e;
                api.isVisible = true;
            },
            out: function (e) {
                var api = e.data != undefined ? e.data : e;
                api.isVisible = false;
            },
            select: function (e) {
                var api = e.data != undefined ? e.data : e;
                var id = $(this).data('id');
                var name = $(this).find('[aria-label="name"]').text();
                if (id == 0) {
                    api.showSection(e);
                } else {
                    api.hideSection(e);
                }
                api.element.val(name);
                $(api.config.storage).val(id);
                api.isVisible = false;
                api.hide(e);
            },
            showSection: function (e) {
                var api = e.data != undefined ? e.data : e;
                $(api.collapseSection).slideDown('slow');
            },
            hideSection: function (e) {
                var api = e.data != undefined ? e.data : e;
                $(api.collapseSection).slideUp('slow');
            }
        }
    });

    $.extend($.fn, {
        modalForm: function () {
            return this.each(function () {
                var modal = $(this).data(MODALFORM);
                if (!modal) {
                    modal = new $.modalForm(this);
                    $(this).data(MODALFORM, modal);
                }
                return modal;
            });
        },
        sessionTimeout: function (options) {
            var arg = arguments;
            return this.each(function () {
                var timeout = $(this).data(SESSIONTIMEOUT);
                if (!timeout) {
                    timeout = new $.sessionTimeout();
                    $(this).data(SESSIONTIMEOUT, timeout);
                }
                if (typeof options === 'string') {
                    if (arg.length > 1) {
                        timeout[options].apply(timeout, Array.prototype.slice.call(arg, 1));
                    } else {
                        timeout[options]();
                    }
                }
                return timeout;
            });
        },
        orderEvents: function () {
            return this.each(function () {
                var oevents = $(this).data(ORDEREVENTS);
                if (!oevents) {
                    oevents = new $.orderEvents(this);
                    $(this).data(ORDEREVENTS, oevents);
                }
                return oevents;
            });
        },
        modalPriority: function (options) {
            return this.each(function () {
                var wM = $(this).data(MODALPRIORITY);
                if (!wM) {
                    wM = new $.modalPriority(this, options);
                    $(this).data(MODALPRIORITY, wM);
                }
                return wM;
            });
        },
        printTicket: function (options) {
            return this.each(function () {
                var pT = $(this).data(PRINTTICKET);
                if (!pT) {
                    pT = new $.printTicket(this, options);
                    $(this).data(PRINTTICKET, pT);
                }
                return pT;
            })
        },
        smartSearch: function (options) {
            return this.each(function () {
                var ss = $(this).data(SMARTSEARCH);
                if (!ss) {
                    ss = new $.smartSearch(this, options);
                    $(this).data(SMARTSEARCH, ss);
                }
                return ss;
            });
        }
    });

    $('body').sessionTimeout();

    $('.modal-form').modalForm();

    $('.sb-sidenav a.nav-link').each(function (_i, link) {
        if ($(link).attr('href') === window.location.pathname) {
            $(link).addClass('active');
        }
    });

    $('#sidebarToggle').on('click', function (e) {
        e.preventDefault();
        $('body').toggleClass('sb-sidenav-toggled');
    });

    $('.goTop').on('click', function (e) {
        $('html, body').animate({ scrollTop: 0 }, 1500, 'easeOutBack');
    });

    $(window).on('scroll', function () {
        if ($(this).scrollTop() > 150) {
            $('.goTop').addClass('show');
        } else {
            $('.goTop').removeClass('show');
        }
    });

    if ($.validator && $.validator.unobtrusive) {
        var defaultOptions = {
            validClass: 'is-valid',
            errorClass: 'is-invalid',
            highlight: function (element, errorClass, validClass) {
                $(element).removeClass(validClass).addClass(errorClass);
            },
            unhighlight: function (element, errorClass, validClass) {
                $(element).removeClass(errorClass).addClass(validClass);
            }
        };
        $.validator.setDefaults(defaultOptions);
        $.validator.unobtrusive.options = {
            errorClass: defaultOptions.errorClass,
            validClass: defaultOptions.validClass,
            invalidHandler: function (_e, validator) {
                if (validator.numberOfInvalids() > 0) {
                    $('.modal-body').animate({ scrollTop: 0 }, 500);
                }
            }
        };
    }

    if ((!standalone && !safari) || (standalone && !android)) {
        $('.sb-nav-fixed').addClass('body-pwa-fix');
        $('.sb-topnav').addClass('pwa-fix');
        $('a').not('[data-toggle=modal]').click(function (e) {
            e.preventDefault();
            window.location = $(this).attr('href');
        });
    };
})(jQuery);