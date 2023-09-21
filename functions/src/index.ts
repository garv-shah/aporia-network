import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";
import QueryDocumentSnapshot = firestore.QueryDocumentSnapshot;
import {getAuth, UserRecord} from "firebase-admin/auth";
import DocumentData = firestore.DocumentData;
import {createTraverser} from '@firecode/admin';
import {google} from 'googleapis';
import { GaxiosError } from "gaxios";
const {getStorage} = require("firebase-admin/storage");
const calendar = google.calendar('v3');
const googleCredentials = require('./credentials.json');

const MathExpression = require('math-expressions');
const admin = require('firebase-admin');

const PdfPrinter = require('pdfmake');

admin.initializeApp();

const db = admin.firestore();

const timezoneToOffset: {[key: string]: number} = {
    'UTC': 0,
    'Indian/Mayotte': 10800000,
    'Europe/London': 3600000,
    'Europe/Zurich': 7200000,
    'Pacific/Gambier': -32400000,
    'US/Alaska': -28800000,
    'US/Eastern': -14400000,
    'Canada/Atlantic': -10800000,
    'US/Central': -18000000,
    'US/Mountain': -21600000,
    'US/Pacific': -25200000,
    'Atlantic/South_Georgia': -7200000,
    'Canada/Newfoundland': -9000000,
    'Pacific/Pohnpei': 39600000,
    'Indian/Christmas': 25200000,
    'Pacific/Saipan': 36000000,
    'Indian/Maldives': 18000000,
    'Pacific/Tongatapu': 46800000,
    'Indian/Chagos': 21600000,
    'Pacific/Wallis': 43200000,
    'Indian/Reunion': 14400000,
    'Australia/Perth': 28800000,
    'Pacific/Palau': 32400000,
    'Asia/Kolkata': 19800000,
    'Asia/Kabul': 16200000,
    'Asia/Kathmandu': 20700000,
    'Indian/Cocos': 23400000,
    'Asia/Tehran': 12600000,
    'Atlantic/Cape_Verde': -3600000,
    'Australia/Broken_Hill': 37800000,
    'Australia/Darwin': 34200000,
    'Australia/Eucla': 31500000,
    'Pacific/Chatham': 49500000,
    'US/Hawaii': -36000000,
    'Pacific/Kiritimati': 50400000,
    'Pacific/Marquesas': -34200000,
    'Pacific/Pago_Pago': -39600000
};

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

exports.manualCreateUser = functions
    .region('australia-southeast1')
    .https.onCall(async (data, context) => {
        let username = data.username;
        let password = data.password;
        let email = data.email;
        let role = data.role;
        if (!username) {
            throw new functions.https.HttpsError('invalid-argument', 'A username must be provided!');
        } else if (context.auth?.uid == null) {
            throw new functions.https.HttpsError('unauthenticated', 'UID cannot be null');
        } else if (username.length > 12) {
            throw new functions.https.HttpsError('permission-denied', 'The username cannot exceed 12 characters');
        } else if (!password) {
            throw new functions.https.HttpsError('invalid-argument', 'A password must be provided!');
        } else if (!email) {
            throw new functions.https.HttpsError('invalid-argument', 'An email must be provided!');
        } else if (!role) {
            throw new functions.https.HttpsError('invalid-argument', 'A role must be provided!');
        } else {
            // the user must be an administrator to create new accounts
            const userRole = db.collection('roles').doc('admins');
            const doc = await userRole.get();
            let admins: string[] = doc.data()['members'];

            // the current list of admins contains the person that called the function
            if (admins.includes(context.auth!.uid)) {
                getAuth()
                    .createUser({
                        email: email,
                        emailVerified: false,
                        password: password,
                        displayName: username,
                        disabled: false,
                    })
                    .then(async (user) => {
                        console.log(`Creating User For ${user.uid}`)

                        await db.collection('userInfo').doc(user.uid).create({
                            lowerUsername: username.toString().toLowerCase(),
                            username: username,
                            profilePicture: `https://avatars.dicebear.com/api/avataaars/${username}.svg`,
                            pfpType: 'image/svg+xml',
                            email: email
                        });

                        if (role != 'users') {
                            const userRole = db.collection('roles').doc('users');
                            const doc = await userRole.get();
                            let userMembers: string[] = doc.data()['members'];
                            console.log(`Current Members: ${userMembers}`)

                            // delete from the default users role
                            const index = userMembers.indexOf(user.uid, 0);
                            if (index > -1) {
                                userMembers.splice(index, 1);
                            }

                            await db.collection('roles').doc(doc.id).update({
                                'members': userMembers
                            }).then(() => {
                                console.log(`Deletion of ${user.uid} from users role successful`)
                            });

                            // now instead add to the correct role

                            const roleData = db.collection('roles').doc(role);
                            const roleDoc = await roleData.get();
                            let roleMembers: string[] = roleDoc.data()['members'];
                            console.log(`Current Role Members: ${roleMembers}`)

                            roleMembers.push(user.uid)

                            await roleData.update({
                                'members': roleMembers
                            }).then(() => {
                                console.log(`Creation of ${user.uid} successful`)
                            });
                        }
                    })
                    .catch((error) => {
                        console.log('Error creating new user:', error);
                    });
            }
        }
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

async function updatePublicProfile(id: string, jobID: string, jobData: DocumentData | null, volunteer: boolean, remove: boolean) {
    const publicProfile = db.collection('publicProfile').doc(id);
    const profileDoc = await publicProfile.get();
    let jobList: DocumentData[] | null = profileDoc.data()['jobList']; // a list of jobIDs
    let volunteerRecord: string[] | null = profileDoc.data()['volunteerRecord'];
    let hoursPerSubject: DocumentData | null = profileDoc.data()['hoursPerSubject'];
    if (jobList == null) {
        jobList = [];
    }
    if (hoursPerSubject == null) {
        hoursPerSubject = {};
    }
    if (volunteerRecord == null) {
        volunteerRecord = [];
    }

    let jobDataWithID: DocumentData = {};
    if (jobData) {
        jobDataWithID = jobData;
        jobDataWithID['ID'] = jobID;
    }

    if (remove) {
        const index = jobList.findIndex((job) => job['ID'] == jobID);
        if (index > -1) {
            jobList.splice(index, 1);
        }
    } else {
        // if already has hours in that subject, set
        let currentHours: number = 0;
        if (hoursPerSubject[jobID] != null) {
            currentHours = hoursPerSubject[jobID]['hours'];
        }

        jobList.push(jobDataWithID);
        hoursPerSubject[jobID] = {
            hours: currentHours,
            data: jobDataWithID
        };
    }

    let data: DocumentData = {
        jobList: jobList,
        hoursPerSubject: hoursPerSubject,
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
            let uri: string | null = null;

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
            calendar.events.insert({
                auth: oAuth2Client,
                calendarId: '057d48896ad3b71f8302bcd00dcfc74b6986c9ea749610b59fecd60a32699dea@group.calendar.google.com',
                sendUpdates: "all",
                resource: event,
                conferenceDataVersion: 1
            }).then(async (response) => {
                console.log(response.data);

                // @ts-ignore
                const {config: {data: {summary, location, start, end, attendees}}, data: {hangoutLink}} = response;

                uri = hangoutLink;
                console.log(`📅 Calendar event created: ${summary} at ${location}, from ${start.dateTime} to ${end.dateTime}, attendees:\n${attendees.map((person: {
                    email: any;
                }) => `🧍 ${person.email}`).join('\n')} \n 💻 Join conference call link: ${uri}`);

                userData['id'] = context.auth!.uid;
                jobData['assignedTo'] = userData;
                jobData['timezone'] = timezone;
                jobData['status'] = 'assigned';
                jobData['lessonTimes'] = {
                    'start': startTime,
                    'end': endTime
                };
                jobData['googleResourceID'] = googleResourceID;
                jobData['meetUrl'] = uri;

                if (jobID != null) {
                    await db.collection("jobs").doc(jobID).update(jobData);

                    // update profile of both volunteer and company
                    await updatePublicProfile(userData['id'], jobID, jobData, true, false);
                    await updatePublicProfile(jobData['createdBy']['id'], jobID, jobData, false, false);

                    console.log(`Job claim for ${context.auth!.uid} completed!`);
                } else {
                    console.log(`Job claim for ${context.auth!.uid} failed because jobID was null somehow :(`);
                }
            })
                .catch((error) => {
                    console.error(error);
                    console.log(`Job claim for ${context.auth!.uid} failed because of the above error!`);
                });
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
            await updatePublicProfile(jobData['assignedTo']['id'], jobID, null, true, true);
            await updatePublicProfile(jobData['createdBy']['id'], jobID, null, false, true);
        }
    });

exports.startShift = functions
    .region('australia-southeast1')
    .https.onCall(async (data, context) => {
        let jobID: string | null = data.jobID;
        let starting: boolean = data.starting;
        if (!jobID) {
            throw new functions.https.HttpsError('invalid-argument', 'A job ID must be provided!');
        } else if (starting == null) {
            throw new functions.https.HttpsError('invalid-argument', 'You must specify whether you are starting or ending a shift!');
        } else if (context.auth?.uid == null) {
            throw new functions.https.HttpsError('unauthenticated', 'UID cannot be null');
        } else {
            functions.logger.info(`Starting shift on job ${jobID} for ${context.auth?.uid}`, {structuredData: true});
            const country: string | string[] | undefined = context.rawRequest.headers["x-appengine-country"];

            const publicProfile = db.collection('publicProfile').doc(context.auth!.uid);
            const doc = await publicProfile.get();
            let profileData = doc.data();

            if (profileData['jobList'] == null) {
                throw new functions.https.HttpsError('unauthenticated', 'User has no active jobs to start!');
            }

            let jobList: DocumentData[] = profileData['jobList'];
            let hoursPerSubject: DocumentData | null = profileData['hoursPerSubject']; // volunteer record but collated to hours per subject

            if (hoursPerSubject == null) {
                hoursPerSubject = {};
            }

            let lessonRunning: boolean = false;
            // TODO: add in day of the week check

            jobList.forEach((job) => {
                let start: Date = new Date(job['lessonTimes']['start']);
                let end: Date = new Date(job['lessonTimes']['end']);
                console.log(`Start: ${start}, End: ${end}`);
                console.log(`job['lessonTimes']['start']: ${job['lessonTimes']['start']}, job['lessonTimes']['end']: ${job['lessonTimes']['end']}`);
                let now: Date = new Date(new Date().toLocaleString('en', {timeZone: job['timezone']}));

                if (new Date(now.getFullYear(), now.getMonth(), now.getDate(), start.getHours(), start.getMinutes(), 0) <= now
                    && now <= new Date(now.getFullYear(), now.getMonth(), now.getDate(), end.getHours(), end.getMinutes(), 0)) {
                    lessonRunning = true;
                }
            });

            if (lessonRunning || !starting) {
                // save lesson started data to firestore volunteerRecord
                if (starting) {
                    let volunteerRecord: DocumentData[] = profileData['volunteerRecord'];
                    volunteerRecord.push({'start': new Date()});
                    await publicProfile.update({'volunteerRecord': volunteerRecord});

                    console.log(`Volunteer ${context.auth!.uid} started their lesson ${jobID}!`);
                } else {
                    // the lesson is ending but make sure to double-check
                    let volunteerRecord: DocumentData[] = profileData['volunteerRecord'];
                    let previous = volunteerRecord.pop();

                    if (previous == undefined || previous['end'] != null) {
                        throw new functions.https.HttpsError('unauthenticated', 'An error seems to have occurred where you ended a lesson that never started.');
                    } else {
                        let job: DocumentData | undefined = jobList.find((job) => job['ID'] == jobID);

                        if (job == undefined) {
                            throw new functions.https.HttpsError('unauthenticated', 'An error seems to have occurred where you ended a lesson that you never claimed.');
                        }

                        let now: Date = new Date(new Date().toLocaleString('en', {timeZone: job['timezone']}));
                        console.log(`Starting end is ${job['lessonTimes']['end']}`);
                        let end: Date = new Date(job['lessonTimes']['end']);
                        end = new Date(now.getFullYear(), now.getMonth(), now.getDate(), end.getHours(), end.getMinutes(), 0);

                        console.log(`right now is ${now}`);
                        console.log(`end is ${end}`);

                        if (now > end) {
                            // recalculate date accounting for timezone difference in storage
                            previous['end'] = new Date(end.getTime() - timezoneToOffset[job['timezone']]);
                        } else {
                            previous['end'] = new Date();
                        }

                        volunteerRecord.push(previous);
                    }

                    // finally, update the number of hours the volunteer has volunteered
                    let volunteerHours: number | null = profileData['volunteerHours'];
                    if (volunteerHours == null) {
                        volunteerHours = 0;
                    }

                    const timestamp: firestore.Timestamp = previous['start'];

                    let start: Date = timestamp.toDate();
                    let end: Date = previous['end'];

                    console.log(`Type of start: ${typeof start}`);
                    console.log(`Type of end: ${typeof end}`);
                    console.log(`Start: ${start}, End: ${end}`);
                    let hoursVolunteeredNow: number = Math.abs(end.getTime() - start.getTime()) / 3.6e6;
                    volunteerHours += hoursVolunteeredNow

                    // processed volunteer hours based on country
                    let processedVolunteerHours: number = 0;
                    if (country === 'US') {
                        processedVolunteerHours = 4 * volunteerHours;
                    } else {
                        processedVolunteerHours = 2 * volunteerHours;
                    }

                    // add hours volunteered now to hoursPerSubject
                    if (hoursPerSubject[jobID] != undefined) {
                        hoursPerSubject[jobID]['hours'] = hoursPerSubject[jobID]['hours'] + hoursVolunteeredNow
                    }

                    await publicProfile.update({
                        'volunteerRecord': volunteerRecord,
                        'volunteerHours': volunteerHours,
                        'hoursPerSubject': hoursPerSubject,
                        'processedVolunteerHours': processedVolunteerHours,
                    });

                    console.log(`Volunteering has finished for ${context.auth?.uid} in lesson ${jobID}. Hours volunteered now is ${hoursVolunteeredNow} with total of ${volunteerHours} volunteer hours globally.`);
                }
            } else {
                throw new functions.https.HttpsError('unauthenticated', 'Volunteer hours cannot be counted if the lesson is not currently running');
            }
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

exports.generateCertificate = functions
    .region('australia-southeast1')
    .https.onCall(async (data, context) => {
        if (context.auth?.uid == null) {
            throw new functions.https.HttpsError('unauthenticated', 'UID cannot be null');
        } else {
            functions.logger.info(`Generating Certificate of Completion for ${context.auth?.uid}`, {structuredData: true});

            const country: string | string[] | undefined = context.rawRequest.headers["x-appengine-country"];

            let multiplier: number = 1;

            if (country === 'US') {
                multiplier = 4;
            } else {
                multiplier = 2;
            }

            const publicProfile = db.collection('publicProfile').doc(context.auth!.uid);
            const doc = await publicProfile.get();
            let profileData = doc.data();

            if (profileData['hoursPerSubject'] == null || profileData['volunteer'] != true) {
                throw new functions.https.HttpsError('unauthenticated', 'User has no subjects they have volunteered for!');
            }

            let hoursPerSubject: DocumentData = profileData['hoursPerSubject'];
            let name: string = profileData['username'];
            let hours: number = Math.round(((profileData['volunteerHours'] * multiplier) + Number.EPSILON) * 100) / 100;
            const firstTime: firestore.Timestamp = profileData['volunteerRecord'][0]['start'];
            const lastTime: firestore.Timestamp = profileData['volunteerRecord'][profileData['volunteerRecord'].length - 1]['end'];
            let startDate = firstTime.toDate();
            let endDate = lastTime.toDate();
            const formatOptions: Intl.DateTimeFormatOptions = {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };

            let subjectData: DocumentData[] = [
                [
                    {
                        text: 'Subject Name',
                        fillColor: '#eaf2f5',
                        border: [false, true, false, true],
                        margin: [0, 5, 0, 5],
                        textTransform: 'uppercase',
                    },
                    {
                        text: 'Volunteer Hours',
                        border: [false, true, false, true],
                        alignment: 'right',
                        fillColor: '#eaf2f5',
                        margin: [0, 5, 0, 5],
                        textTransform: 'uppercase',
                    },
                ]
            ];

            for (let key in hoursPerSubject) {
                const subjectName: string = hoursPerSubject[key]['data']['Job Title'];
                const hours: number = Math.round(((hoursPerSubject[key]['hours'] * multiplier) + Number.EPSILON) * 100) / 100;
                subjectData.push(
                    [
                        {
                            text: subjectName,
                            border: [false, false, false, true],
                            margin: [0, 5, 0, 5],
                            alignment: 'left',
                        },
                        {
                            border: [false, false, false, true],
                            text: `${hours} Hours`,
                            fillColor: '#f5f5f5',
                            alignment: 'right',
                            margin: [0, 5, 0, 5],
                        },
                    ]
                );
            }

            let docDefinition = {
                ownerPassword: 'TCOwnerPass19!',
                permissions: {
                    modifying: false,
                },
                content: [
                    { text: 'Certificate of Completion', style: 'header' },
                    {
                        text: [
                            'This is to certify that ',
                            { text: name, style: 'information'},
                            ' has completed ',
                            { text: hours, style: 'hours'},
                            ' hours of volunteer work at ',
                            { text: 'Two Cousins', style: 'information'},
                            ' from ',
                            { text: startDate.toLocaleDateString('en-US', formatOptions), style: 'information'},
                            ' to ',
                            { text: endDate.toLocaleDateString('en-US', formatOptions), style: 'information'},
                            '. The following is a list of subjects ',
                            { text: name, style: 'information'},
                            ' has tutored'
                        ]
                    },
                    {
                        width: '100%',
                        alignment: 'center',
                        text: name + "'s Subjects",
                        bold: true,
                        margin: [0, 10, 0, 10],
                        fontSize: 15,
                    },
                    {
                        layout: {
                            defaultBorder: false,
                            hLineWidth: function(_: any, __: any) {
                                return 1;
                            },
                            vLineWidth: function(_: any, __: any) {
                                return 1;
                            },
                            hLineColor: function(i: number, _: any) {
                                if (i === 1 || i === 0) {
                                    return '#bfdde8';
                                }
                                return '#eaeaea';
                            },
                            vLineColor: function(_: any, __: any) {
                                return '#eaeaea';
                            },
                            hLineStyle: function(_: any, __: any) {
                                // if (i === 0 || i === node.table.body.length) {
                                return null;
                                //}
                            },
                            // vLineStyle: function (i, node) { return {dash: { length: 10, space: 4 }}; },
                            paddingLeft: function(_: any, __: any) {
                                return 10;
                            },
                            paddingRight: function(_: any, __: any) {
                                return 10;
                            },
                            paddingTop: function(_: any, __: any) {
                                return 2;
                            },
                            paddingBottom: function(_: any, __: any) {
                                return 2;
                            },
                            fillColor: function(_: any, __: any, ___: any) {
                                return '#fff';
                            },
                        },
                        table: {
                            headerRows: 1,
                            widths: ['*', 100],
                            body: subjectData,
                        },
                    },
                    '\n',
                    'Signature:',
                    { text: '_______________________', style: 'signature'},
                    { text: 'Garv Shah - Two Cousins', style: 'subheader'},
                    {
                        text: 'NOTES',
                        style: 'notesTitle',
                    },
                    {
                        text: 'This document has been auto-generated by Two Cousins. Any tampering of the contents of this file is strictly prohibited and violates the Terms and Conditions agreed upon by the user. This document is intended solely for verification purposes and may not be used to impersonate, imitate or harm any Two Cousins employee or volunteer.',
                        style: 'notesText',
                    },
                ],
                styles: {
                    header: {
                        fontSize: 18,
                        bold: true,
                        alignment: 'center',
                        margin: [0, 0, 0, 20]
                    },
                    information: {
                        fontSize: 12,
                        bold: true
                    },
                    subheader: {
                        fontSize: 14,
                        bold: true
                    },
                    hours: {
                        fontSize: 12,
                        bold: true,
                        italics: true
                    },
                    signature: {
                        margin: [0, 40, 0, 10]
                    },
                    notesTitle: {
                        fontSize: 10,
                        bold: true,
                        margin: [0, 50, 0, 3],
                    },
                    notesText: {
                        fontSize: 10,
                    },
                }
            };

            const fontDescriptors = {
                Roboto: {
                    normal: './fonts/Roboto-Regular.ttf',
                    bold: './fonts/Roboto-Medium.ttf',
                    italics: './fonts/Roboto-Italic.ttf',
                    bolditalics: './fonts/Roboto-MediumItalic.ttf',
                }
            };

            const printer = new PdfPrinter(fontDescriptors);
            const pdfDoc = printer.createPdfKitDocument(docDefinition);
            const bucket = getStorage().bucket();
            const pdfFile = bucket.file(`certificates/${context.auth!.uid}/certificate.pdf`);
            pdfDoc
                .pipe(pdfFile.createWriteStream())
                .on('finish', function (){
                    console.log('PDF successfully created!');
                })
                .on('error', function(err: any){
                    console.log('Error during the writestream operation in the new file');
                    console.log(err);
                });
            pdfDoc.end();
        }
    });
