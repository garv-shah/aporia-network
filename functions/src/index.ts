import * as functions from "firebase-functions";
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.createUser = functions
    .region('australia-southeast1')
    .auth.user().onCreate(async (user) => {
        await db.collection('quizPoints').doc(user.uid).set({
            'username': '',
            'experience': 0
        });

        console.log(`Creating User For ${user.uid}`)

        const userRole = db.collection('roles').doc('users');
        const doc = await userRole.get();
        let members: string[] = doc.data()['members'];
        console.log(`Current Members: ${members}`)

        members.push(user.uid)

        await userRole.update({
            'members': members
        }).then(() => {
            console.log(`Creation of ${user.uid} successful`)
        });
    });

exports.updateUsername = functions
    .region('australia-southeast1')
    .https.onCall((data, context) => {
    let username = data.username;
    if (username == null) {
        throw new functions.https.HttpsError('invalid-argument', 'A username must be provided!');
    } else if (context.auth?.uid == null) {
        throw new functions.https.HttpsError('unauthenticated', 'UID cannot be null');
    } else {
        functions.logger.info(`Updating username for ${context.auth?.uid}`, {structuredData: true});

        // set displayName username
        admin.auth().updateUser(context.auth!.uid, {
            displayName: username,
        })

        // set userInfo username
        db.collection("userInfo").doc(context.auth!.uid).update({
            lowerUsername: username.toString().toLowerCase(),
            username: username,
        });

        // set quizPoints username
        db.collection("quizPoints").doc(context.auth!.uid).update({
            username: username,
        });
    }
});
