class RemoveVeryShortScoreReports < ActiveRecord::Migration
  IDS_TO_REMOVE = [ 547, 545, 528, 498, 477, 463, 438, 430, 373, 283, 280,
      274, 266, 262, 256, 255, 251, 246, 243, 240, 238, 222, 220, 217, 212,
      211, 208, 206, 203, 197, 181, 179, 175, 156, 152, 137, 1 ]

  def self.up
    execute "update score_reports set previous_report_id = id - 2 " +
      "where id in (#{IDS_TO_REMOVE[0, IDS_TO_REMOVE.length - 1].map { |id| id + 1 }.join ', '})"
    execute "update score_reports set previous_report_id = null where id = 2"
    execute "update score_reports set previous_report_id = 210 where id = 213"
    execute "update score_reports set previous_report_id = 254 where id = 257"
    ScoreReport.delete IDS_TO_REMOVE
  end

  def self.down
    if ! Rails.env.test?
      execute "insert into score_reports values(1, null, '2005-03-19 17:27:13')"
      execute "insert into score_reports values(137, 136, '2007-06-07 20:41:37')"
      execute "insert into score_reports values(152, 151, '2007-07-12 22:23:15')"
      execute "insert into score_reports values(156, 155, '2007-07-23 14:57:11')"
      execute "insert into score_reports values(175, 174, '2007-10-10 19:27:19')"
      execute "insert into score_reports values(179, 178, '2007-10-22 13:30:06')"
      execute "insert into score_reports values(181, 180, '2007-10-27 15:29:15')"
      execute "insert into score_reports values(197, 196, '2007-12-22 23:34:03')"
      execute "insert into score_reports values(203, 202, '2008-01-17 16:53:53')"
      execute "insert into score_reports values(206, 205, '2008-01-25 13:37:44')"
      execute "insert into score_reports values(208, 207, '2008-01-29 00:37:52')"
      execute "insert into score_reports values(211, 210, '2008-02-05 13:29:21')"
      execute "insert into score_reports values(212, 211, '2008-02-07 00:27:52')"
      execute "insert into score_reports values(217, 216, '2008-02-22 16:28:43')"
      execute "insert into score_reports values(220, 219, '2008-03-01 22:42:37')"
      execute "insert into score_reports values(222, 221, '2008-03-05 22:30:07')"
      execute "insert into score_reports values(238, 237, '2008-04-26 06:57:37')"
      execute "insert into score_reports values(240, 239, '2008-04-28 20:36:17')"
      execute "insert into score_reports values(243, 242, '2008-05-15 15:19:17')"
      execute "insert into score_reports values(246, 245, '2008-05-29 13:22:44')"
      execute "insert into score_reports values(251, 250, '2008-06-27 15:10:48')"
      execute "insert into score_reports values(255, 254, '2008-07-13 22:05:15')"
      execute "insert into score_reports values(256, 255, '2008-07-15 19:32:52')"
      execute "insert into score_reports values(262, 261, '2008-08-10 01:33:23')"
      execute "insert into score_reports values(266, 265, '2008-08-24 19:40:25')"
      execute "insert into score_reports values(274, 273, '2008-10-05 13:05:16')"
      execute "insert into score_reports values(280, 279, '2008-10-19 01:13:41')"
      execute "insert into score_reports values(283, 282, '2008-10-28 21:06:13')"
      execute "insert into score_reports values(373, 372, '2009-07-21 08:58:10')"
      execute "insert into score_reports values(430, 429, '2009-12-16 07:44:59')"
      execute "insert into score_reports values(438, 437, '2010-01-14 22:42:22')"
      execute "insert into score_reports values(463, 462, '2010-03-31 06:11:41')"
      execute "insert into score_reports values(477, 476, '2010-05-03 08:21:42')"
      execute "insert into score_reports values(498, 497, '2010-07-11 20:36:06')"
      execute "insert into score_reports values(528, 527, '2010-10-09 16:55:15')"
      execute "insert into score_reports values(545, 544, '2011-01-01 20:45:59')"
      execute "insert into score_reports values(547, 546, '2011-01-06 03:24:27')"
    end
    execute "update score_reports set previous_report_id = id - 1 " +
      "where id in (#{IDS_TO_REMOVE.map { |id| id + 1 }.join ', '})"
  end

end
