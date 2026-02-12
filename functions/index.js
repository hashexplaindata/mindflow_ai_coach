const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

admin.initializeApp();

const REVENUECAT_WEBHOOK_SECRET = 'Uy6HUCCosaP0Iol5sTxS1hrmuf0er0ktxthmdvbL5cw';

exports.revenuecatWebhook = onRequest(async (req, res) => {
    // Verify webhook signature
    const authHeader = req.headers.authorization;
    if (!authHeader || authHeader !== `Bearer ${REVENUECAT_WEBHOOK_SECRET}`) {
        console.error('Unauthorized webhook request');
        return res.status(401).send('Unauthorized');
    }

    try {
        const event = req.body;
        const eventType = event.type;
        const appUserId = event.event.app_user_id;

        console.log(`RevenueCat event received: ${eventType} for user: ${appUserId}`);

        // Determine if user should be Pro
        let isPro = false;

        switch (eventType) {
            case 'INITIAL_PURCHASE':
            case 'RENEWAL':
            case 'UNCANCELLATION':
                isPro = true;
                break;
            case 'CANCELLATION':
            case 'EXPIRATION':
            case 'BILLING_ISSUE':
                isPro = false;
                break;
            default:
                console.log(`Unhandled event type: ${eventType}`);
                return res.status(200).send('Event acknowledged but not processed');
        }

        // Update Firestore
        const userRef = admin.firestore().collection('customers').doc(appUserId);

        await userRef.set({
            isPro: isPro,
            lastRevenueCatEvent: eventType,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        console.log(`Updated user ${appUserId} - isPro: ${isPro}`);

        return res.status(200).send('Webhook processed successfully');
    } catch (error) {
        console.error('Error processing webhook:', error);
        return res.status(500).send('Internal server error');
    }
});
