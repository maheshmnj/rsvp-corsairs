/// APP CONSTANTS GO HERE IN THIS FILE

const String APP_TITLE = 'RSVP';
const String BASE_URL = '';
const VERSION = 'v0.0.1';
const VERSION_KEY = 'version';
const UPDATE_URL_KEY = 'update_url';
const FORCE_UPDATE_KEY = 'forceUpdate';
const CONFIG_COLLECTION_KEY = 'config';
const UPDATE_DOC_KEY = 'update';
const BUILD_NUMBER_KEY = 'buildNumber';
const REPO_NAME = 'rsvp-corsairs';
const SOURCE_CODE_URL = 'https://github.com/maheshmnj/$REPO_NAME';

const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.wml.rsvp';
const AMAZON_APP_STORE_URL = '';

const REPORT_URL = 'https://github.com/maheshmnj/$REPO_NAME/issues/new/choose';

const String signInScopeUrl =
    'https://www.googleapis.com/auth/contacts.readonly';
// const SHEET_URL =
//     'https://docs.google.com/spreadsheets/d/1G1RtQfsEDqHhHP4cgOpO9x_ZtQ1dYa6QrGCq3KFlu50';

const PRIVACY_POLICY = 'https://maheshmnj.github.io/privacy';

const String profileUrl = 'assets/profile.png';

const FEEDBACK_EMAIL_TO = 'maheshmn121@gmail.com';

/// TABLES
const EVENTS_TABLE_NAME = 'events';
const ATTENDEES_TABLE_NAME = 'attendees';

const USER_TABLE_NAME = 'user';
const BOOKMARKS_TABLE_NAME = 'bookmarks';
// const VOCAB_TABLE_NAME = 'vocabsheet_copy';
// const USER_TABLE_NAME = 'users_test';
const FEEDBACK_TABLE_NAME = 'feedback';

const WORD_STATE_TABLE_NAME = 'word_state';
const WORD_OF_THE_DAY_TABLE_NAME = 'word_of_the_day';

/// VOCAB TABLE COLUMNS
const EVENT_NAME_COLUMN = 'name';
const ID_COLUMN = 'id';
const HOST_COLUMN = 'host';
const EVENT_ID_COLUMN = 'event_id';
const EVENT_USER_ID_COLUMN = 'user_id';
const SYNONYM_COLUMN = 'synonyms';
const MEANING_COLUMN = 'meaning';
const EXAMPLE_COLUMN = 'example';
const NOTE_COLUMN = 'notes';
const STATE_COLUMN = 'state';
const CREATED_AT_COLUMN = 'createdAt';

/// USER TABLE COLUMNS
const USER_ID_COLUMN = 'user_id';
const USER_NAME_COLUMN = 'name';
const USER_EMAIL_COLUMN = 'email';
const USERNAME_COLUMN = 'username';
const USER_BOOKMARKS_COLUMN = 'bookmarks';
const USER_CREATED_AT_COLUMN = 'created_at';
const USER_LOGGEDIN_COLUMN = 'isLoggedIn';
const STUDENT_ID_COLUMN = 'studentId';

/// EDIT HISTORY TABLE COLUMNS
const EDIT_ID_COLUMN = 'edit_id';
const EDIT_USER_ID_COLUMN = 'user_id';
const EDIT_WORD_ID_COLUMN = 'word_id';

enum EditState {
  approved('approved'),

  /// Admin has rejected the request
  rejected('rejected'),
  pending('pending'),

  /// user can cancel the edit request
  cancelled('cancelled');

  final String state;
  const EditState(this.state);

  String toName() => state;
}

enum WordState { known, unknown, unanswered }

enum EditType {
  /// request to add a new word
  add,

  /// request to edit an existing word
  edit,

  /// request to delete an existing word
  delete,
}

const String dateFormatter = 'MMMM dd, y';
const String timeFormatter = 'h:mm a';

enum Status { success, notfound, error }

const int HOME_INDEX = 0;
const int SEARCH_INDEX = 1;
const int EXPLORE_INDEX = 2;
const int PROFILE_INDEX = 3;

int maxExampleCount = 3;
int maxSynonymCount = 5;
int maxMnemonicCount = 5;

const int NAME_VALIDATOR = 0;
const int EMAIL_VALIDATOR = 1;
const int STUDENT_ID_VALIDATOR = 2;
const int PASSWORD_VALIDATOR = 3;
const int USER_ID_VALIDATOR = 12;

enum RequestState { active, done, error, none }

const String emailPattern = r'^[a-zA-Z]+[a-zA-Z0-9_.+-]+@[a-z]{4,}.[a-z]{3}$';
const String firstAndLastNamePattern = r'^[a-zA-Z]{3,}\s[a-zA-Z]{3,}$';
const String studentIdPattern = r'^[0-9]{8}$';
