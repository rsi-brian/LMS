'use strict';

import { ErrorHandler } from './ErrorHandler.js';

export class ServerLogger extends ErrorHandler {

    static sendToServer(errorEntry) {
        console.log("Sending extended log to the server...");

        fetch('/log/extended', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                ...errorEntry,
                additionalInfo: "Extended error logging",
            })
        }).catch(err => console.warn('Extended logging failed:', err));
    }

    static logCritical(error, context = 'Critical') {
        super.logError(error, context, 'critical');
        this.sendToServer({
            message: error.toString(),
            context,
            level: 'critical',
            timestamp: new Date().toISOString()
        });
    }

}