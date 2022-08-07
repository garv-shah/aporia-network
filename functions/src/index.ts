import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";
import QueryDocumentSnapshot = firestore.QueryDocumentSnapshot;
import {UserRecord} from "firebase-admin/lib/auth";

const MathExpression = require('math-expressions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.createUser = functions
    .region('australia-southeast1')
    .auth.user().onCreate(async (user) => {
        await db.collection('quizPoints').doc(user.uid).set({
            'username': '',
            'experience': 0,
            'completedQuizzes': []
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

async function deleteFromRole(doc: QueryDocumentSnapshot, user: UserRecord) {

    let docData = await doc.data();
    let members: string[] = docData['members'];
    console.log(`Current Members: ${members}`)

    const index = members.indexOf(user.uid, 0);
    if (index > -1) {
        members.splice(index, 1);
    }

    await db.collection('roles').doc(doc.id).update({
        'members': members
    }).then(() => {
        console.log(`Deletion of ${user.uid} successful`)
    });
    //end if

}

exports.deleteUser = functions
    .region('australia-southeast1')
    .auth.user().onDelete(async (user) => {
        console.log(`Deleting User ${user.uid}`)
        await db.collection('quizPoints').doc(user.uid).delete()
        await db.collection('userInfo').doc(user.uid).delete()

        const userRoles = db.collection('roles');
        for (let index = 0; index < userRoles.docs.length; index++) {
            const doc = userRoles.docs[index];
            await deleteFromRole(doc, user);
        }
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

exports.updatePfp = functions
    .region('australia-southeast1')
    .https.onCall((data, context) => {
        let profilePicture = data.profilePicture;
        let pfpType = data.pfpType;
        if (profilePicture == null) {
            throw new functions.https.HttpsError('invalid-argument', 'A profile picture must be provided!');
        } else if (pfpType == null) {
            throw new functions.https.HttpsError('invalid-argument', 'A profile picture type must be provided!');
        } else if (context.auth?.uid == null) {
            throw new functions.https.HttpsError('unauthenticated', 'UID cannot be null');
        } else {
            functions.logger.info(`Updating profile picture for ${context.auth?.uid}`, {structuredData: true});

            // set displayName username
            admin.auth().updateUser(context.auth!.uid, {
                photoURL: profilePicture,
            })

            // set userInfo username
            db.collection("userInfo").doc(context.auth!.uid).update({
                profilePicture: profilePicture,
                pfpType: pfpType,
            });

            // set quizPoints username
            db.collection("quizPoints").doc(context.auth!.uid).update({
                profilePicture: profilePicture,
                pfpType: pfpType,
            });
        }
    });

exports.markQuestions = functions
    .region('australia-southeast1')
    .https.onCall(async (data, context) => {
        let questionAnswers: object = data.questionAnswers;
        console.log(questionAnswers);
        console.log(typeof questionAnswers);
        let quizID: string = data.quizID;
        console.log(quizID);
        console.log(typeof quizID);
        if (questionAnswers == null) {
            throw new functions.https.HttpsError('invalid-argument', 'Question answers must be provided!');
        } else if (quizID == null) {
            throw new functions.https.HttpsError('invalid-argument', 'A question ID must be provided!');
        } else if (context.auth?.uid == null) {
            throw new functions.https.HttpsError('unauthenticated', 'UID cannot be null');
        } else {
            functions.logger.info(`Marking questions for ${context.auth?.uid} with quiz ${quizID}`, {structuredData: true});

            let markedObject: { [key: string]: any; } = {'Experience': 0};
            let quiz = await db.collection("posts").doc(quizID).get();

            for (let i = 1; i <= Object.keys(questionAnswers).length; i++) {
                const data: { [key: string]: any; } = Object(quiz.data() as object)['questionData'][`Question ${i}`];
                const experience: number = data['Experience'];

                const correctAnswerLatex: string = data['Solution TEX'];
                console.log(correctAnswerLatex);
                const correctAnswer = MathExpression.fromLatex(correctAnswerLatex);

                const userAnswerLatex: string | undefined = Object(questionAnswers)[`Question ${i}`];
                console.log(userAnswerLatex);
                const userAnswer = MathExpression.fromLatex(userAnswerLatex);

                const isCorrect: boolean = correctAnswer.equals(userAnswer);
                markedObject[`Question ${i}`] = isCorrect;

                if (isCorrect) {
                    markedObject['Experience'] += experience;
                }
            }

            await db.collection("quizPoints").doc(context.auth!.uid).get().then((points: any) => {
                const currentData: { [key: string]: any; } = Object(points.data() as object)
                const completedQuizzes: string[] = currentData['completedQuizzes'];

                if (completedQuizzes.includes(quizID)) {
                    markedObject['Experience'] = 0
                } else {
                    completedQuizzes.push(quizID);

                    db.collection("quizPoints").doc(context.auth!.uid).update({
                        experience: currentData['experience'] + markedObject['Experience'],
                        completedQuizzes: completedQuizzes
                    });
                }
            });

            return markedObject;
        }
    });
