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

def timed(&blk)
  s = Time.now
  blk.call
  e = Time.now
  puts "Took #{e - s} seconds"
end

@s = "2014-07-14".to_date
@e = "2014-07-21".to_date

if ARGV[0] != nil
  start_date = ARGV[0].to_date
  end_date = ARGV[1].to_date
  puts "Fetching data between #{start_date} and #{end_date}"

  puts "\nvia SQL"
  timed { analyze_sql(start_date, end_date) }

  puts "\nvia ORM"
  timed { analyze_orm(start_date, end_date) }

  puts "\nvia ORM plucked"
  timed { analyze_orm_plucked(start_date, end_date) }
end

