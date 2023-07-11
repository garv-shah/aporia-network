import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";
import QueryDocumentSnapshot = firestore.QueryDocumentSnapshot;
import {UserRecord} from "firebase-admin/lib/auth";
import DocumentData = firestore.DocumentData;
import {createTraverser} from '@firecode/admin';
import {google} from 'googleapis';
import { GaxiosError } from "gaxios";
const calendar = google.calendar('v3');
const googleCredentials = require('./credentials.json');

const MathExpression = require('math-expressions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

function makeid(length: number) {
    let result = '';
    const characters = 'abcdefghijklmnopqrstuv0123456789';
    const charactersLength = characters.length;
    let counter = 0;
    while (counter < length) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
        counter += 1;
    }
    return result;
}

exports.createUser = functions
    .region('australia-southeast1')
    .auth.user().onCreate(async (user) => {
        await db.collection('publicProfile').doc(user.uid).set({
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
        await db.collection('publicProfile').doc(user.uid).delete()
        await db.collection('userInfo').doc(user.uid).delete()

        const userRoles = db.collection('roles');
        for (let index = 0; index < userRoles.docs.length; index++) {
            const doc = userRoles.docs[index];
            await deleteFromRole(doc, user);
        }
    });

exports.updateUsername = functions
    .region('australia-southeast1')
    .https.onCall(async (data, context) => {
        let username = data.username;
        let appID = data.appID;
        let forceUID: string | null = data.uid;
        if (!username) {
            throw new functions.https.HttpsError('invalid-argument', 'A username must be provided!');
        } else if (!appID) {
            throw new functions.https.HttpsError('invalid-argument', 'An app ID must be provided!');
        } else if (context.auth?.uid == null) {
            throw new functions.https.HttpsError('unauthenticated', 'UID cannot be null');
        } else if (username.length > 12) {
            throw new functions.https.HttpsError('permission-denied', 'The username cannot exceed 12 characters');
        } else {
            let userInfoList = (await db.collection('userInfo').where("lowerUsername", '==', username.toLowerCase()).get()).docs;

            if (userInfoList.length != 0) {
                throw new functions.https.HttpsError('already-exists', 'The username already exists!');
            }

            let uid: string = '';
            // if a separate uid is provided, use that
            if (forceUID == null) {
                uid = context.auth!.uid;
            // if not, use the uid of the person that called the function
            } else {
                // the user must be an administrator to set other people's usernames
                const userRole = db.collection('roles').doc('admins');
                const doc = await userRole.get();
                let admins: string[] = doc.data()['members'];

                // the current list of admins contains the person that called the function
                if (admins.includes(context.auth!.uid)) {
                    uid = forceUID;
                } else {
                    throw new functions.https.HttpsError('permission-denied', "The user must be an admin to be able to change other users' usernames");
                }
            }

            functions.logger.info(`Updating username for ${uid}`, {structuredData: true});

            // set displayName username
            await admin.auth().updateUser(uid, {
                displayName: username,
            })

            // set userInfo username
            await db.collection("userInfo").doc(uid).update({
                lowerUsername: username.toString().toLowerCase(),
                username: username,
                userType: appID,
            });

            // set publicProfile username
            await db.collection("publicProfile").doc(uid).update({
                username: username,
                userType: appID,
            });
        }
    });

async function updatePublicProfile(id: string, jobID: string, volunteer: boolean, remove: boolean) {
    const publicProfile = db.collection('publicProfile').doc(id);
    const profileDoc = await publicProfile.get();
    let jobList: string[] | null = profileDoc.data()['jobList'];
    let volunteerRecord: string[] | null = profileDoc.data()['volunteerRecord'];
    if (jobList == null) {
        jobList = [];
    }
    if (volunteerRecord == null) {
        volunteerRecord = [];
    }

    if (remove) {
        const index = jobList.indexOf(jobID, 0);
        if (index > -1) {
            jobList.splice(index, 1);
        }
    } else {
        jobList.push(jobID);
    }

    let data: DocumentData = {
        jobList: jobList
    }

    if (volunteer) {
        // if we are unassigning and the jobList is now empty then user is no longer a volunteer
        data['volunteer'] = !(remove && jobList.length == 0);
        data['volunteerRecord'] = volunteerRecord;
    }

    await db.collection("publicProfile").doc(id).update(data);
}

exports.claimJob = functions
    .region('australia-southeast1')
    .https.onCall(async (data, context) => {
        let jobID: string | null = data.jobID;
        let timezone: string | null = data.timezone;
        let startTime: string | null = data.startTime;
        let endTime: string | null = data.endTime;
        if (!jobID) {
            throw new functions.https.HttpsError('invalid-argument', 'A job ID must be provided!');
        } else if (!startTime) {
            throw new functions.https.HttpsError('invalid-argument', 'A start time must be provided!');
        } else if (!endTime) {
            throw new functions.https.HttpsError('invalid-argument', 'An end time must be provided!');
        } else if (!timezone) {
            throw new functions.https.HttpsError('invalid-argument', 'A timezone must be provided!');
        } else if (context.auth?.uid == null) {
            throw new functions.https.HttpsError('unauthenticated', 'UID cannot be null');
        } else {
            functions.logger.info(`Claiming job ${jobID} for ${context.auth?.uid}`, {structuredData: true});

            const userInfo = db.collection('userInfo').doc(context.auth!.uid);
            const userDoc = await userInfo.get();
            let userData = userDoc.data();

            const jobInfo = db.collection('jobs').doc(jobID);
            const jobDoc = await jobInfo.get();
            let jobData = jobDoc.data();

            const googleResourceID = makeid(32);

            // You already have the user emails from your NodeJS app
            const attendeesEmails = [
                {
                    'email': jobData['createdBy']['email'],
                    'displayName': jobData['createdBy']['username']
                },
                {
                    'email': userData['email'],
                    'displayName': userData['username']
                },
            ];

            const event = {
                id: googleResourceID,
                summary: jobData['Job Title'],
                location: '2cousins',
                description: jobData['Job Description'],
                creator: {
                    displayName: "2cousins Admin",
                    email: "admin@2cousins.org",
                },
                organiser: {
                    displayName: "2cousins Admin",
                    email: "admin@2cousins.org",
                },
                start: {
                    dateTime: startTime,
                    timeZone: timezone,
                },
                end: {
                    dateTime: endTime,
                    timeZone: timezone,
                },
                attendees: attendeesEmails,
                reminders: {
                    useDefault: true,
                },
                "recurrence": [
                    "RRULE:FREQ=WEEKLY;UNTIL=40110701T170000Z",
                ],
                conferenceData: {
                    createRequest: {
                        conferenceSolutionKey: {
                            type: 'hangoutsMeet'
                        },
                        requestId: googleResourceID,
                    },
                    conferenceSolution: {
                        name: "2cousins",
                        iconUri: "https://2cousins.org/logo.png"
                    },
                    notes: "This is an official 2cousins meeting. By joining the room, you agree to the 2cousins terms of service and privacy policy.",
                },
            };

            const oAuth2Client = new google.auth.OAuth2(
                googleCredentials.web.client_id,
                googleCredentials.web.client_secret,
                googleCredentials.web.redirect_uris[0]
            );

            oAuth2Client.setCredentials({
                refresh_token: googleCredentials.refresh_token
            });

            // @ts-ignore
            const response = await calendar.events.insert({
                auth: oAuth2Client,
                calendarId: '057d48896ad3b71f8302bcd00dcfc74b6986c9ea749610b59fecd60a32699dea@group.calendar.google.com',
                sendUpdates: "all",
                resource: event,
                conferenceDataVersion: 1
            });

            // @ts-ignore
            const { config: { data: { summary, location, start, end, attendees } }, data: { conferenceData } } = response;

            const { uri } = conferenceData.entryPoints[0];
            console.log(`📅 Calendar event created: ${summary} at ${location}, from ${start.dateTime} to ${end.dateTime}, attendees:\n${attendees.map((person: { email: any; }) => `🧍 ${person.email}`).join('\n')} \n 💻 Join conference call link: ${uri}`);

            await db.collection("jobs").doc(jobID).update({
                assignedTo: userData,
                timezone: timezone,
                status: 'assigned',
                lessonTimes: {
                    start: startTime,
                    end: endTime
                },
                googleResourceID: googleResourceID,
                meetUrl: uri
            });

            // update profile of both volunteer and company
            await updatePublicProfile(context.auth!.uid, jobID, true, false);
            await updatePublicProfile(jobData['createdBy']['id'], jobID, false, false);

            console.log(`Job claim for ${context.auth!.uid} completed!`);
        }
    });

exports.unassignJob = functions
    .region('australia-southeast1')
    .https.onCall(async (data, context) => {
        let jobID: string | null = data.jobID;
        let deleteOperation: boolean | null = data.deleteOperation;
        if (!jobID) {
            throw new functions.https.HttpsError('invalid-argument', 'A job ID must be provided!');
        } else if (deleteOperation == null) {
            throw new functions.https.HttpsError('invalid-argument', 'It must be specified whether this is a delete operation or not!');
        } else if (context.auth?.uid == null) {
            throw new functions.https.HttpsError('unauthenticated', 'UID cannot be null');
        } else {
            functions.logger.info(`Deleting job ${jobID}, called by ${context.auth?.uid}`, {structuredData: true});

            const jobInfo = db.collection('jobs').doc(jobID);
            const jobDoc = await jobInfo.get();
            let jobData = jobDoc.data();

            const googleResourceID: string = jobData['googleResourceID']

            const oAuth2Client = new google.auth.OAuth2(
                googleCredentials.web.client_id,
                googleCredentials.web.client_secret,
                googleCredentials.web.redirect_uris[0]
            );

            oAuth2Client.setCredentials({
                refresh_token: googleCredentials.refresh_token
            });

            // @ts-ignore
            const response = await calendar.events.delete({
                auth: oAuth2Client,
                calendarId: '057d48896ad3b71f8302bcd00dcfc74b6986c9ea749610b59fecd60a32699dea@group.calendar.google.com',
                sendUpdates: "all",
                eventId: googleResourceID,
            })
                .catch((err: GaxiosError) => {
                    console.log(`📅 Error occurred while trying to delete calendar event ${jobID} by ${context.auth?.uid}`);
                    console.log(err);
                });

            // calendar event has been deleted, now either delete the document or unassign it
            if (deleteOperation) {
                // delete the document
                await db.collection("jobs").doc(jobID).delete();
                console.log(`📅 Job ${jobID} deleted by ${context.auth?.uid}`);
            } else {
                // unassign the job
                await db.collection("jobs").doc(jobID).update({
                    assignedTo: null,
                    status: 'pending_assignment',
                    lessonTimes: null,
                    googleResourceID: null,
                    meetUrl: null
                });
                console.log(`📅 Job ${jobID} unassigned by ${context.auth?.uid}`);
            }

            // finally, update profile of both volunteer and company
            await updatePublicProfile(context.auth!.uid, jobID, true, true);
            await updatePublicProfile(jobData['createdBy']['id'], jobID, false, true);
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

            // set publicProfile username
            db.collection("publicProfile").doc(context.auth!.uid).update({
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

            await db.collection("publicProfile").doc(context.auth!.uid).get().then((points: any) => {
                const currentData: { [key: string]: any; } = Object(points.data() as object)
                const completedQuizzes: string[] = currentData['completedQuizzes'];

                if (completedQuizzes.includes(quizID)) {
                    markedObject['Experience'] = 0
                } else {
                    completedQuizzes.push(quizID);

                    db.collection("publicProfile").doc(context.auth!.uid).update({
                        experience: currentData['experience'] + markedObject['Experience'],
                        completedQuizzes: completedQuizzes
                    });
                }
            });

            return markedObject;
        }
    });

exports.fixValidationIssues = functions
    .region("australia-southeast1")
    .pubsub.schedule("0 * * * *")
    .timeZone("Australia/Melbourne")
    .onRun(async () => {
        const publicProfileCollections = await db.collection("publicProfile");
        const traverser = createTraverser(publicProfileCollections);

        const requiredFields = ['pfpType', 'profilePicture', 'username']
        let missingFields: {[key: string]: Array<string>} = {};

        await traverser.traverse(async (batchDocs) => {
            await Promise.all(
                batchDocs.map(async (document: QueryDocumentSnapshot<DocumentData>) => {
                    const data = document.data();

                    requiredFields.forEach((field) => {
                        if (data[field] == undefined || data[field]?.isEmpty || data[field] == '') {
                            if (missingFields[document.id] == undefined) {
                                missingFields[document.id] = [];
                            }

                            missingFields[document.id].push(field);
                        }
                    })
                })
            );
        });

        for (let uid in missingFields) {
            await db.collection("userInfo").doc(uid).get().then(async (data: any) => {
                const userInfo: { [key: string]: any; } = Object(data.data() as object)

                if (userInfo['username'] != undefined) {
                    let updateObject: { [key: string]: string; } = {};

                    missingFields[uid].forEach((entry) => {
                        updateObject[entry] = userInfo[entry];
                    });

                    await db.collection('publicProfile').doc(uid).update(updateObject);
                    console.log(`Fixed validation issues for user ${userInfo['username']} with uid ${uid}`);
                } else {
                    await admin.auth().deleteUser(uid);
                    console.log(`Deleted user ${userInfo['username']} with uid ${uid} for likely being a bot account`)
                }
            });
        }
    });
