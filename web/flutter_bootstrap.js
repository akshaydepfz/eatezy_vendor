{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  },
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
      var loading = document.getElementById('loading');
      if (loading) loading.style.display = 'none';
    } catch (e) {
      console.error('Flutter failed to start:', e);
      window.loadError = e && e.message ? e.message : String(e);
      var loadingText = document.getElementById('loading-text');
      var fallback = document.getElementById('loading-fallback');
      var errorMsg = document.getElementById('error-message');
      if (loadingText) loadingText.style.display = 'none';
      if (errorMsg) errorMsg.textContent = window.loadError || 'Failed to load.';
      if (fallback) fallback.style.display = 'block';
    }
  }
});
