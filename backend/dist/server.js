"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const app_1 = require("./app");
const env_1 = require("./config/env");
const PORT = env_1.env.PORT;
app_1.app.listen(PORT, () => {
    console.log(`🚀 DoFirst API running on http://localhost:${PORT}`);
    console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🌍 Environment: ${env_1.env.NODE_ENV}`);
});
//# sourceMappingURL=server.js.map