import 'dart:convert';

import 'config_parser.dart';

const String name = 'Aporia';
const String detailedName = 'The Aporia Network';
const String appID = 'aporia_app';
Map<String, Config> globalConfig = {
  'aporia_app': configFromJson(jsonEncode(configString['aporia_app'])),
  'maths_club': configFromJson(jsonEncode(configString['maths_club'])),
  'two_cousins': configFromJson(jsonEncode(configString['two_cousins'])),
};
Config configMap = globalConfig[appID]!;

const Map configString = {
  "aporia_app": {
    "views": [
      {
        "name": "leaderboards",
        "displayName": "Leaderboards",
        "show": {
          "ability": [
            "points"
          ]
        }
      },
      {
        "name": "createJob",
        "displayName": "Create Job",
        "show": {
          "role": [
            "companies"
          ]
        }
      },
      {
        "name": "availability",
        "displayName": "Availability",
        "show": {
          "role": [
            "users"
          ]
        }
      },
      {
        "name": "schedule",
        "displayName": "My Schedule",
        "show": {
          "ability": [
            "scheduling"
          ]
        }
      },
      {
        "name": "manageJobs",
        "displayName": "Manage Jobs",
        "show": {
          "role": [
            "companies",
            "users"
          ]
        }
      },
      {
        "name": "adminView",
        "displayName": "Admin View",
        "show": {
          "role": [
            "admins"
          ]
        }
      },
      {
        "name": "createPost",
        "displayName": "Create Post",
        "show": {
          "role": [
            "admins",
            "users"
          ]
        }
      },
      {
        "name": "settings",
        "displayName": "Settings",
        "show": {
          "role": [
            "admins",
            "companies",
            "users"
          ]
        }
      }
    ],
    "roles": {
      "admins": {
        "name": "admins",
        "abilities": [
          "moderation",
          "curation",
          "points",
          "scheduling"
        ]
      },
      "companies": {
        "name": "companies",
        "abilities": [
          "points",
          "scheduling"
        ]
      },
      "users": {
        "name": "users",
        "abilities": [
          "points",
          "scheduling",
          "volunteering"
        ]
      }
    }
  },
  "maths_club": {
    "views": [
      {
        "name": "leaderboards",
        "displayName": "Leaderboards",
        "show": {
          "ability": [
            "points"
          ]
        }
      },
      {
        "name": "adminView",
        "displayName": "Admin View",
        "show": {
          "role": [
            "admins"
          ]
        }
      },
      {
        "name": "createPost",
        "displayName": "Create Post",
        "show": {
          "role": [
            "admins",
            "users"
          ]
        }
      },
      {
        "name": "settings",
        "displayName": "Settings",
        "show": {
          "role": [
            "admins",
            "companies",
            "users"
          ]
        }
      }
    ],
    "roles": {
      "admins": {
        "name": "Admin",
        "abilities": [
          "moderation",
          "curation",
          "points"
        ]
      },
      "companies": {
        "name": "Null",
        "abilities": []
      },
      "users": {
        "name": "Student",
        "abilities": [
          "points"
        ]
      }
    }
  },
  "two_cousins": {
    "views": [
      {
        "name": "leaderboards",
        "displayName": "Leaderboards",
        "show": {
          "ability": [
            "points"
          ]
        }
      },
      {
        "name": "createJob",
        "displayName": "Create Job",
        "show": {
          "role": [
            "companies"
          ]
        }
      },
      {
        "name": "availability",
        "displayName": "Availability",
        "show": {
          "role": [
            "users"
          ]
        }
      },
      {
        "name": "schedule",
        "displayName": "My Schedule",
        "show": {
          "ability": [
            "scheduling"
          ]
        }
      },
      {
        "name": "manageJobs",
        "displayName": "Manage Jobs",
        "show": {
          "role": [
            "companies",
            "users"
          ]
        }
      },
      {
        "name": "adminView",
        "displayName": "Admin View",
        "show": {
          "role": [
            "admins"
          ]
        }
      },
      {
        "name": "createPost",
        "displayName": "Create Post",
        "show": {
          "role": [
            "admins",
            "users"
          ]
        }
      },
      {
        "name": "settings",
        "displayName": "Settings",
        "show": {
          "role": [
            "admins",
            "companies",
            "users"
          ]
        }
      }
    ],
    "roles": {
      "admins": {
        "name": "Staff",
        "abilities": [
          "moderation",
          "curation",
          "points",
          "scheduling"
        ]
      },
      "companies": {
        "name": "Organisation",
        "abilities": [
          "points",
          "scheduling"
        ]
      },
      "users": {
        "name": "Volunteer",
        "abilities": [
          "scheduling",
          "volunteering"
        ]
      }
    }
  }
};
