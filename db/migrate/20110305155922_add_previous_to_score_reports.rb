class AddPreviousToScoreReports < ActiveRecord::Migration
  def self.up
    change_column :score_reports, :created_at, :datetime, :null => false
    execute 'alter table score_reports add column previous_report_id int(11) after id'
    execute 'alter table score_reports add constraint previous_report_id_fk foreign key (previous_report_id) references score_reports (id)'
    if ! Rails.env.test?
      execute <<EOS
        create procedure add_previous_report_ids()
        begin
          declare done int default 0;
          declare previous_id, current_id int(11);
          declare cu cursor for select id from score_reports order by id;
          declare continue handler for not found set done = 1;

          open cu;
          fetch cu into previous_id;
          read_loop: loop
            fetch cu into current_id;
            if done then
              leave read_loop;
            end if;
            update score_reports set previous_report_id = previous_id where id = current_id;
            set previous_id = current_id;
          end loop;

        end
EOS
      execute 'call add_previous_report_ids()'
      execute 'drop procedure add_previous_report_ids'
    end
  end

  def self.down
    execute 'alter table score_reports drop foreign key previous_report_id_fk'
    remove_column :score_reports, :previous_report_id
    change_column :score_reports, :created_at, :datetime, :null => true
  end

end
