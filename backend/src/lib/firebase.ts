import admin from 'firebase-admin';

/**
 * Initialize Firebase Admin SDK.
 *
 * In production, set GOOGLE_APPLICATION_CREDENTIALS env var to point to your
 * service account key JSON file. In development, you can also use
 * FIREBASE_SERVICE_ACCOUNT_KEY as a JSON string.
 *
 * This module exports the initialized app so other services can use messaging.
 */

let firebaseApp: admin.app.App;

export function initializeFirebase(): admin.app.App {
  if (firebaseApp) return firebaseApp;

  // Option 1: JSON string in env var
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (serviceAccountJson) {
    try {
      const serviceAccount = JSON.parse(serviceAccountJson);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      console.log('✅ Firebase Admin initialized (from env JSON)');
      return firebaseApp;
    } catch (e) {
      console.warn('⚠️ Failed to parse FIREBASE_SERVICE_ACCOUNT_KEY:', e);
    }
  }

  // Option 2: Default credentials (GOOGLE_APPLICATION_CREDENTIALS env var)
  try {
    firebaseApp = admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
    console.log('✅ Firebase Admin initialized (default credentials)');
    return firebaseApp;
  } catch (e) {
    console.warn('⚠️ Firebase Admin not initialized — FCM will be disabled:', e);
    // Create a dummy app that won't crash the server
    firebaseApp = admin.initializeApp();
    return firebaseApp;
  }
}

export function getFirebaseApp(): admin.app.App {
  if (!firebaseApp) {
    return initializeFirebase();
  }
  return firebaseApp;
}

export { admin };
