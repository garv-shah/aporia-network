const String name = 'Aporia';
const String detailedName = 'The Aporia Network';
const String appID = 'aporia_app';

const Map<String, Map<String, dynamic>> appMap = {
  'aporia_app': {
    'views': ['posts', 'scheduling'],
    'roles': {
      'users': {
        'name': 'users',
        'abilities': ['points']
      },
      'moderators': {
        'name': 'moderators',
        'abilities': ['points']
      }
    }
  },
  'maths_club': {
    'views': ['posts'],
    'roles': {
      'users': {
        'name': 'students',
        'abilities': ['points']
      },
      'moderators': {
        'name': 'staff',
        'abilities': ['points']
      }
    }
  },
  'two_cousins': {
    'views': ['posts', 'scheduling'],
    'roles': {
      'users': {
        'name': 'volunteers',
        'abilities': []
      },
      'moderators': {
        'name': 'schools',
        'abilities': ['points']
      }
    }
  },
};
