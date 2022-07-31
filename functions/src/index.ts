import * as functions from "firebase-functions";
const admin = require('firebase-admin');
const app = admin.initializeApp();

const db = admin.firestore();

exports.createUser = functions
    .region('australia-southeast1')
    .auth.user().onCreate((user) => {
    db.collection('quizPoints').doc(user.uid).set({
        'username': '',
        'experience': 0
    });

    const userRole = db.collection('roles').doc('users');

    let members:string[] = userRole.get().members;
    members.push(user.uid)

    userRole.update({
        'members': members
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
        admin.auth(app).updateUser(context.auth!.uid, {
            displayName: username,
        })

        // set userInfo username
        admin.database().ref(`/userInfo/${context.auth?.uid}`).update({
            lowerUsername: username.toLowerCase(),
            username: username,
        });

        // set quizPoints username
        admin.database().ref(`/quizPoints/${context.auth?.uid}`).update({
            username: username,
        });
    }
});
