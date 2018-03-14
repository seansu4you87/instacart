require "csv"
require "yaml"
require "active_record"

config = YAML::load(File.open("config.yml"))
ActiveRecord::Base.establish_connection(config)
class Applicant < ActiveRecord::Base
  STATE_ORDER = {
    "quiz_started" => 0,
    "quiz_completed" => 1,
    "applied" => 3,
    "onboarding_requested" => 4,
    "onboarding_completed" => 5,
    "hired" => 6,
  }
end

INDEX_NAME = "applicants_created_at_workflow_state"

def idempotent_sql(&blk)
  begin
    blk.call
  rescue Exception => e
    puts "SQL already executed, caught and moving on...exception: #{e}"
  end
end

def create_index
  puts "Creating index #{INDEX_NAME}..."
  Applicant.connection.execute(
<<-SQL
CREATE INDEX #{INDEX_NAME}
ON applicants(created_at, workflow_state)
;
SQL
  )
end

def drop_index
  puts "Dropping index #{INDEX_NAME}..."
  Applicant.connection.execute(
<<-SQL
DROP INDEX #{INDEX_NAME};
SQL
  )
end

def analyze_sql(start_date, end_date)

  raw = Applicant.connection.execute(
<<-SQL
SELECT
  COUNT(*) as count,
  STRFTIME('%W %Y', created_at) AS week_of_year,
  created_at,
  workflow_state
FROM applicants
WHERE
  created_at BETWEEN '#{start_date}' AND '#{end_date}'
GROUP BY week_of_year, workflow_state
;
SQL
  )

  raw
    .map do |row|
      monday = row["created_at"].to_date.beginning_of_week.to_date.to_s
      state = row["workflow_state"]
      count = row["count"]
      [[monday, state], count]
    end
    .sort_by { |(monday, state), _| [monday, Applicant::STATE_ORDER[state]] }
    .tap { |me| pretty(me) }
end

def analyze_orm(start_date, end_date)
  Applicant
    .select("created_at", "workflow_state")
    .where(created_at: start_date..end_date)
    .group_by { |a| [a.created_at.beginning_of_week.to_date, a.workflow_state] }
    .map { |k, v| [k, v.count] }
    .sort_by { |(monday, state), _| [monday, Applicant::STATE_ORDER[state]] }
    .tap { |me| pretty(me) }
end

def analyze_orm_plucked(start_date, end_date)
  Applicant
    .where(created_at: start_date..end_date)
    .pluck("created_at", "workflow_state")
    .group_by { |a| [a[0].beginning_of_week.to_date, a[1]] }
    .map { |k, v| [k, v.count] }
    .sort_by { |(monday, state), _| [monday, Applicant::STATE_ORDER[state]] }
    .tap { |me| pretty(me) }
end

def pretty(results)
  puts "#{"count".rjust(10)}, #{"week".rjust(10)}, #{"workflow_state".rjust(30)}"
  results.each do |(monday, state), count|
    string = ""
    string << count.to_s.rjust(10)
    string << ", "
    string << monday.to_s.rjust(10)
    string << ", "
    string << state.rjust(30)
    puts string
  end
  nil
end

def write_csv(results, filename)
  CSV.open("./#{filename}", "wb") do |csv|
    csv << ["count", "week", "workflow_state"]
    results.each do |(monday, state), count|
      csv << [count, monday, state]
    end
  end
end

def timed(&blk)
  s = Time.now
  blk.call
  e = Time.now
  puts "Took #{e - s} seconds"
end





# SCRIPTING STARTS
@s = "2014-07-14".to_date
@e = "2014-07-21".to_date

# timed { idempotent_sql { drop_index } }
timed { idempotent_sql { create_index } }

if ARGV[0] == nil
  puts <<-HELP

Please call this ruby file like so:
ruby compute.rb "2014-7-01" "2015-07-01"

This will create an output csv named: output_2014-07-01_to_2015-07-01.csv

  HELP
else
  begin
    start_date = ARGV[0].to_date
  rescue
    puts "#{ARGV[0]} is not a valid date, please use YYYY-MM-DD format"
    return
  end

  begin
    end_date = ARGV[1].to_date
  rescue
    puts "#{ARGV[1]} is not a valid date, please use YYYY-MM-DD format"
    return
  end

  filename = "output_#{start_date}_to_#{end_date}.csv"
  results = nil
  puts "Fetching data between #{start_date} and #{end_date}"

  puts "\nvia SQL"
  timed { results = analyze_sql(start_date, end_date) }

  puts "\nwriting to #{filename}..."
  timed { write_csv(results, filename) }

  # puts "\nvia ORM"
  # timed { analyze_orm(start_date, end_date) }

  # puts "\nvia ORM plucked"
  # timed { analyze_orm_plucked(start_date, end_date) }
end

