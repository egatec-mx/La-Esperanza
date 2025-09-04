(function ($) {
    var alertInstall = $('#alertInstall');
    var linkInstall = $('#linkInstall');

    window.addEventListener('beforeinstallprompt', (event) => {
        window.deferredPrompt = event;
        alertInstall.slideDown('slow');
    });

    linkInstall.on('click', () => {
        const promptEvent = window.deferredPrompt;
        if (!promptEvent) { return; }
        promptEvent.prompt();
        promptEvent.userChoice.then(() => {
            window.deferredPrompt = null;
            alertInstall.slideUp('slow');
        });
    });

    window.addEventListener('appinstalled', (event) => {
        console.log('👍', 'App instalada', event);
    });

    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register('/service-worker.js');
        });
    }

})(jQuery);