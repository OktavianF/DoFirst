(function () {
  if (!window._flutter) {
    window._flutter = {};
  }

  _flutter.buildConfig = {
    engineRevision: "425cfb54d01a9472b3e81d9e76fd63a4a44cfbcb",
    builds: [
      {
        compileTarget: "dart2js",
        renderer: "canvaskit",
        mainJsPath: "main.dart.js",
      },
      {},
    ],
  };

  _flutter.loader.load({
    serviceWorkerSettings: {
      serviceWorkerVersion: "2877176884",
    },
  });
})();