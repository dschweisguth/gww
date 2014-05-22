class AlterTagsRawCaseSensitive < ActiveRecord::Migration
  def up
    # Some photos in GWSF have tags which differ only by characters which utf8_unicode_ci considers the same, e.g. e and é.
    # mysql unique indexes use collation to determine uniqueness.
    execute "alter table tags convert to character set utf8 collate utf8_bin"
  end

  def down
    execute "alter table tags convert to character set utf8 collate utf8_unicode_ci"
  end

end
