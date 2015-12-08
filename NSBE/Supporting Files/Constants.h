//
//  Constants.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/26/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#ifndef NSBE_Constants_h
#define NSBE_Constants_h

#define APP_PASSWORD @"NSBE2015"
#define XOR_CIPHER_SECRET_KEY "N_sB3!key"

#define CHALLENGE_TOTAL_DAYS [[[CLUser user] currentMiniGame] durationDays]
#define CHALLENGE_DAY_WINNER_RESULT_HOUR 12

#define BACKGROUND_IMAGE_PARALLAX_OFFSET 20.0f

#define PROFILE_PICTURE_ADD_PICTURE_IMAGE [UIImage imageNamed:@"AddPhoto"]
#define PROFILE_PICTURE_THUMBNAIL_SIZE 250
#define PROFILE_PICTURE_THUMBNAIL_QUALITY 0.8f
#define PROFILE_PICTURE_DOWNLOAD_TIMEOUT 60

#define WEB_SERVICE_CACHE_EXPIRATION_TIME_SHORT 900
#define WEB_SERVICE_CACHE_EXPIRATION_TIME_MEDIUM 1800
#define WEB_SERVICE_CACHE_EXPIRATION_TIME_LONG 86400

#define PARTICIPANTS_PHOTOS_CACHE_COUNT 69

#define KNOTIFICATION_SYNC_FINISHED @"kNotificationSyncFinished"

#define NOTIFICATION_SYNC_STEPS_HOURS @[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10), @(11), @(12), @(13),\
                                        @(14), @(15), @(16), @(17), @(18), @(19), @(20), @(21), @(22), @(23), @(24)]

#define NOTIFICATION_CHECK_WINNER_HOURS @[@(12)]
#define NOTIFICATION_REGISTER_TYPES (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound)

#define TEXT_FIELD_NAME_CHARACTER_LIMIT 26
#define TEXT_FIELD_EMAIL_CHARACTER_LIMIT 30
#define TEXT_FIELD_PHONE_NUMBER_CHARACTER_LIMIT 10

#define DATE_FORMAT_DAY_MONTH_YEAR @"EEEE, MMM d, yyyy"
#define DATE_FORMAT_HOUR_MINUTE @"h:mm a"

#define DATE_PICKER_PAST_YEAR_COUNT 100
#define DATE_PICKER_MONTH_POSITION 0
#define DATE_PICKER_DAY_POSITION 1
#define DATE_PICKER_YEAR_POSITION 2

#define GENDER_PICKER_MALE_CHARACTER @"Male"
#define GENDER_PICKER_MALE_IMAGE_PATH @"MaleIcon"
#define GENDER_PICKER_MALE_NAME @"Male"
#define GENDER_PICKER_FEMALE_CHARACTER @"Female"
#define GENDER_PICKER_FEMALE_IMAGE_PATH @"FemaleIcon"
#define GENDER_PICKER_FEMALE_NAME @"Female"

#define HEIGHT_PICKER_DEFAULT_FEET_INDEX 5
#define HEIGHT_PICKER_DEFAULT_INCHES_INDEX 7

#define HEIGHT_PICKER_FEET_POSITION 0
#define HEIGHT_PICKER_INCHES_POSITION 1
//#define HEIGHT_PICKER_FEET_SUFFIX @"′"
#define HEIGHT_PICKER_FEET_SUFFIX @"’"
#define HEIGHT_PICKER_FEET_SUFFIX_TEXT @" feet "
//#define HEIGHT_PICKER_INCHES_SUFFIX @"″"
#define HEIGHT_PICKER_INCHES_SUFFIX @"’’"
#define HEIGHT_PICKER_INCHES_SUFFIX_TEXT @" inches"
#define HEIGHT_PICKER_FEET_ARRAY @[@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7)]
#define HEIGHT_PICKER_INCHES_ARRAY @[@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10), @(11)]

#define WEIGHT_PICKER_DEFAULT_LBS_INDEX 155 - 60

#define WEIGHT_PICKER_LBS_SUFFIX @"lbs"
#define WEIGHT_PICKER_LBS_SUFFIX_FONT_RATIO 0.5
#define WEIGHT_PICKER_LBS_ARRAY @[@(60), @(61), @(62), @(63), @(64), @(65), @(66), @(67), @(68), @(69), @(70), @(71), @(72),\
                                  @(73), @(74), @(75), @(76), @(77), @(78), @(79), @(80), @(81), @(82), @(83), @(84), @(85),\
                                  @(86), @(87), @(88), @(89), @(90), @(91), @(92), @(93), @(94), @(95), @(96), @(97), @(98),\
                                  @(99), @(100), @(101), @(102), @(103), @(104), @(105), @(106), @(107), @(108), @(109),\
                                  @(110), @(111), @(112), @(113), @(114), @(115), @(116), @(117), @(118), @(119), @(120),\
                                  @(121), @(122), @(123), @(124), @(125), @(126), @(127), @(128), @(129), @(130), @(131),\
                                  @(132), @(133), @(134), @(135), @(136), @(137), @(138), @(139), @(140), @(141), @(142),\
                                  @(143), @(144), @(145), @(146), @(147), @(148), @(149), @(150), @(151), @(152), @(153),\
                                  @(154), @(155), @(156), @(157), @(158), @(159), @(160), @(161), @(162), @(163), @(164),\
                                  @(165), @(166), @(167), @(168), @(169), @(170), @(171), @(172), @(173), @(174), @(175),\
                                  @(176), @(177), @(178), @(179), @(180), @(181), @(182), @(183), @(184), @(185), @(186),\
                                  @(187), @(188), @(189), @(190), @(191), @(192), @(193), @(194), @(195), @(196), @(197),\
                                  @(198), @(199), @(200), @(201), @(202), @(203), @(204), @(205), @(206), @(207), @(208),\
                                  @(209), @(210), @(211), @(212), @(213), @(214), @(215), @(216), @(217), @(218), @(219),\
                                  @(220), @(221), @(222), @(223), @(224), @(225), @(226), @(227), @(228), @(229), @(230),\
                                  @(231), @(232), @(233), @(234), @(235), @(236), @(237), @(238), @(239), @(240), @(241),\
                                  @(242), @(243), @(244), @(245), @(246), @(247), @(248), @(249), @(250), @(251), @(252),\
                                  @(253), @(254), @(255), @(256), @(257), @(258), @(259), @(260), @(261), @(262), @(263),\
                                  @(264), @(265), @(266), @(267), @(268), @(269), @(270), @(271), @(272), @(273), @(274),\
                                  @(275), @(276), @(277), @(278), @(279), @(280), @(281), @(282), @(283), @(284), @(285),\
                                  @(286), @(287), @(288), @(289), @(290), @(291), @(292), @(293), @(294), @(295), @(296),\
                                  @(297), @(298), @(299), @(300), @(301), @(302), @(303), @(304), @(305), @(306), @(307),\
                                  @(308), @(309), @(310), @(311), @(312), @(313), @(314), @(315), @(316), @(317), @(318),\
                                  @(319), @(320), @(321), @(322), @(323), @(324), @(325), @(326), @(327), @(328), @(329),\
                                  @(330), @(331), @(332), @(333), @(334), @(335), @(336), @(337), @(338), @(339), @(340),\
                                  @(341), @(342), @(343), @(344), @(345), @(346), @(347), @(348), @(349), @(350)]

#define CHECKBOX_CHECKED_IMAGE [UIImage imageNamed:@"CheckboxChecked"]
#define CHECKBOX_UNCHECKED_IMAGE [UIImage imageNamed:@"CheckboxUnchecked"]

#define DEVICE_TYPE_WRISTBAND_TEXT @"Your Device"
#define DEVICE_TYPE_IPHONE_TEXT @"Your iPhone"
#define DEVICE_NAME_FITBIT_TEXT @"Fitbit"
#define DEVICE_NAME_JAWBONE_TEXT @"Jawbone"
#define DEVICE_NAME_HEALTHKIT_TEXT @"Health"

#define DEVICE_ICON_FITBIT_IMAGE [UIImage imageNamed:@"intro_s4_fitbit"]
#define DEVICE_ICON_JAWBONE_IMAGE [UIImage imageNamed:@"intro_s4_up"]
#define DEVICE_ICON_HEALTHKIT_IMAGE [UIImage imageNamed:@"intro_s4_health"]


#endif
