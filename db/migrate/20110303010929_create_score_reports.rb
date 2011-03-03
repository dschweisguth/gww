class CreateScoreReports < ActiveRecord::Migration
  def self.up
    create_table :score_reports do |t|
      t.datetime :created_at
    end
    if RAILS_ENV != 'test'
      execute <<EOS
        create procedure insert_score_reports()
        begin
          declare done int default 0;
          declare n int default 0;
          declare start, previous, current datetime;
          declare cu cursor for (select added_at from guesses) union (select added_at from revelations) order by added_at;
          declare continue handler for not found set done = 1;

          open cu;
          fetch cu into previous;
          set start = previous;
          read_loop: loop
            fetch cu into current;
            set	n = n +	1;
            if done then
              leave read_loop;
            end if;
            if previous < subtime(current, '1 0:0:0') then
              insert into score_reports values(null, start);
              set n = 0;
              set start	= current;
            end	if;
            set previous = current;
          end loop;

        end
EOS
      execute 'call insert_score_reports()'
      execute 'drop procedure insert_score_reports'
    end
  end

  def self.down
    drop_table :score_reports
  end

end
