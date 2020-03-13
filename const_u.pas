unit const_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  view_freq = '0.000"."00';
  port_udp: array [0..5] of integer = (49153, 49155, 49157, 49159, 49161, 52300);
  port_tcp: array [0..5] of integer = (49154, 49156, 49158, 49160, 49162, 52301);
//  port_udp: array [0..5] of integer = (49153, 49155, 49157, 49159, 49161, 52300);
//  port_tcp: array [0..5] of integer = (49152, 49156, 49158, 49160, 49162, 52301);
  min_sqlite_version = '3.24.0';
  curr_sqlite_version = '3.31.1';
  etalonField: array [0..56] of string =
    ('UnUsedIndex', 'CallSign', 'QSODate', 'QSOTime', 'QSOBand', 'QSOMode',
    'QSOReportSent', 'QSOReportRecived', 'OMName',
    'OMQTH', 'State', 'Grid', 'IOTA', 'QSLManager', 'QSLSent', 'QSLSentAdv',
    'QSLSentDate', 'QSLRec', 'QSLRecDate', 'MainPrefix', 'DXCCPrefix', 'CQZone',
    'ITUZone', 'QSOAddInfo', 'Marker', 'ManualSet', 'DigiBand', 'Continent',
    'ShortNote', 'QSLReceQSLcc', 'LoTWRec', 'LoTWRecDate', 'QSLInfo',
    'Call', 'State1', 'State2', 'State3', 'State4', 'WPX', 'AwardsEx', 'ValidDX',
    'SRX', 'SRX_STRING', 'STX', 'STX_STRING', 'SAT_NAME',
    'SAT_MODE', 'PROP_MODE', 'LoTWSent', 'QSL_RCVD_VIA', 'QSL_SENT_VIA',
    'DXCC', 'USERS', 'NoCalcDXCC', 'QSOSubMode', 'MY_STATE', 'MY_GRIDSQUARE');
  constColumnName: array [0..29] of string =
    ('QSL', 'QSLs', 'QSODate', 'QSOTime', 'QSOBand', 'CallSign',
    'QSOMode', 'QSOSubMode', 'OMName',
    'OMQTH', 'State', 'Grid', 'QSOReportSent', 'QSOReportRecived', 'IOTA', 'QSLManager',
    'QSLSentDate', 'QSLRecDate', 'LoTWRecDate', 'MainPrefix', 'DXCCPrefix', 'CQZone',
    'ITUZone', 'ManualSet', 'Continent', 'ValidDX', 'QSL_RCVD_VIA', 'QSL_SENT_VIA',
    'USERS', 'NoCalcDXCC');
  constLanguageISO: array [0..141] of string =
    ('aa', 'ab', 'af', 'am', 'ar', 'as', 'ay', 'az', 'ba', 'be', 'bg', 'bh', 'bi',
    'bn', 'bo', 'br', 'ca', 'co',
    'cs', 'cy', 'da', 'de', 'dz', 'el', 'en', 'eo', 'es', 'et', 'eu', 'fa', 'fi',
    'fj', 'fo', 'fr', 'fy', 'ga',
    'gd', 'gl', 'gn', 'gu', 'ha', 'hi', 'he', 'hr', 'hu', 'hy', 'ia', 'id', 'ie',
    'ik', 'in', 'is', 'it', 'iu',
    'iw', 'ja', 'ji', 'jw', 'ka', 'kk', 'kl', 'km', 'kn', 'ko', 'ks', 'ku', 'ky',
    'la', 'ln', 'lo', 'lt', 'lv',
    'mg', 'mi', 'mk', 'ml', 'mn', 'mo', 'mr', 'ms', 'mt', 'my', 'na', 'ne', 'nl',
    'no', 'oc', 'om', 'or', 'pa',
    'pl', 'ps', 'pt', 'qu', 'rm', 'rn', 'ro', 'ru', 'rw', 'sa', 'sd', 'sg', 'sh',
    'si', 'sk', 'sl', 'sm', 'sn',
    'so', 'sq', 'sr', 'ss', 'st', 'su', 'sv', 'sw', 'ta', 'te', 'tg', 'th', 'ti',
    'tk', 'tl', 'tn', 'to', 'tr',
    'ts', 'tt', 'tw', 'ug', 'uk', 'ur', 'uz', 'vi', 'vo', 'wo', 'xh',
    'yi', 'yo', 'za', 'zh', 'zu');
  constLanguage: array [0..141] of string =
    ('Afar', 'Abkhazian', 'Afrikaans', 'Amharic', 'Arabic', 'Assamese',
    'Aymara', 'Azerbaijani',
    'Bashkir', 'Byelorussian', 'Bulgarian', 'Bihari', 'Bislama', 'Bengali',
    'Tibetan', 'Breton', 'Catalan',
    'Corsican', 'Czech', 'Welch', 'Danish', 'German', 'Bhutani', 'Greek',
    'English', 'Esperanto', 'Spanish',
    'Estonian', 'Basque', 'Persian', 'Finnish', 'Fiji', 'Faeroese',
    'French', 'Frisian', 'Irish',
    'Scots Gaelic', 'Galician', 'Guarani', 'Gujarati', 'Hausa', 'Hindi',
    'Hebrew', 'Croatian', 'Hungarian',
    'Armenian', 'Interlingua', 'Indonesian', 'Interlingue', 'Inupiak',
    'former Indonesian', 'Icelandic',
    'Italian', 'Inuktitut (Eskimo)', 'former Hebrew', 'Japanese',
    'former Yiddish', 'Javanese', 'Georgian',
    'Kazakh', 'Greenlandic', 'Cambodian', 'Kannada', 'Korean',
    'Kashmiri', 'Kurdish', 'Kirghiz',
    'Latin', 'Lingala', 'Laothian', 'Lithuanian', 'Latvian', 'Malagasy',
    'Maori', 'Macedonian', 'Malayalam',
    'Mongolian', 'Moldavian', 'Marathi', 'Malay', 'Maltese', 'Burmese',
    'Nauru', 'Nepali', 'Dutch', 'Norwegian',
    'Occitan', '(Afan) Oromo', 'Oriya', 'Punjabi', 'Polish', 'Pashto',
    'Portuguese', 'Quechua', 'Rhaeto-Romance',
    'Kirundi', 'Romanian', 'Russian', 'Kinyarwanda', 'Sanskrit', 'Sindhi',
    'Sangro', 'Serbo-Croatian', 'Singhalese',
    'Slovak', 'Slovenian', 'Samoan', 'Shona', 'Somali', 'Albanian', 'Serbian',
    'Siswati', 'Sesotho', 'Sudanese',
    'Swedish', 'Swahili', 'Tamil', 'Tegulu', 'Tajik', 'Thai', 'Tigrinya',
    'Turkmen', 'Tagalog', 'Setswana',
    'Tonga', 'Turkish', 'Tsonga', 'Tatar', 'Twi', 'Uigur', 'Ukrainian',
    'Urdu', 'Uzbek', 'Vietnamese',
    'Volapuk', 'Wolof', 'Xhosa', 'Yiddish', 'Yoruba', 'Zhuang', 'Chinese', 'Zulu');
  constColumnWidth: array[0..29] of integer =
    (30, 35, 65, 45, 65, 65, 50, 50, 70, 90, 40, 50, 35, 35, 50, 64, 64,
    64, 64, 55, 55, 55, 55,
    64, 70, 64, 64, 64, 64, 64);

implementation

end.
